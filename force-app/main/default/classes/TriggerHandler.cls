/**
 * @description Main trigger dispatcher class
 * Metadata-driven framework using Trigger_Handler_Config__mdt and Trigger_Action__mdt.
 *
 * Usage: Place 'new TriggerHandler().run();' in each trigger
 *
 * Features:
 * - Metadata-driven configuration
 * - Bypass logic (per user, object, or method)
 * - Execution order control
 * - Async execution support
 * - Recursion prevention
 *
 * @author Haribaskar
 * @date 2025
 */
public class TriggerHandler {
  // Static variables for bypass and recursion prevention
  private static Map<String, Set<String>> bypassedHandlers = new Map<String, Set<String>>();
  private static Set<String> bypassedMethods = new Set<String>();
  private static Map<String, Integer> executionCounts = new Map<String, Integer>();

  /**
   * @description Main entry point - called from triggers
   */
  public void run() {
    if (!Trigger.isExecuting) {
      return;
    }

    TriggerContext context = new TriggerContext();

    // ========== CHECK CUSTOM SETTINGS BYPASS ==========
    // Check if triggers should be bypassed for this object
    // Uses hierarchy custom settings (Org/Profile/User level)
    if (!TriggerBypassManager.shouldExecuteTriggers(context.sObjectType)) {
      System.debug(
        LoggingLevel.WARN,
        TriggerHandlerConstants.MSG_BYPASS_OBJECT + ' ' + context.sObjectType
      );
      return; // Exit early if bypassed
    }
    // ==================================================

    // Get parent configuration for this object
    Trigger_Handler_Config__mdt parentConfig = getParentConfig(
      context.sObjectType
    );

    // Check if parent config exists and is active
    if (
      parentConfig == null ||
      !parentConfig.Active__c ||
      parentConfig.Bypass_All_Actions__c
    ) {
      if (parentConfig != null && parentConfig.Bypass_All_Actions__c) {
        System.debug(
          LoggingLevel.WARN,
          'All trigger actions bypassed for ' +
            context.sObjectType +
            ' (Bypass_All_Actions__c = true)'
        );
      }
      return;
    }

    // Get applicable actions
    List<Trigger_Action__mdt> actions = getApplicableActions(
      context,
      parentConfig
    );

    // Execute each action in order
    for (Trigger_Action__mdt action : actions) {
      executeAction(action, context);
    }
  }

  /**
   * @description Gets the parent configuration for an object
   * @param objectName The sObject API name
   * @return Trigger_Handler_Config__mdt or null if not found
   */
  private Trigger_Handler_Config__mdt getParentConfig(String objectName) {
    Map<String, Trigger_Handler_Config__mdt> allConfigs = Trigger_Handler_Config__mdt.getAll();

    for (Trigger_Handler_Config__mdt config : allConfigs.values()) {
      if (config.Object_API_Name__c == objectName) {
        return config;
      }
    }

    return null;
  }

  /**
   * @description Retrieves and filters applicable trigger actions from Custom Metadata
   * Uses SOQL query with ORDER BY for optimal performance (no Apex sorting needed)
   * Field list is maintained in TriggerHandlerConstants for easy updates
   * @param context The trigger context
   * @param parentConfig The parent configuration
   * @return List of applicable Trigger_Action__mdt records sorted by execution order
   */
  private List<Trigger_Action__mdt> getApplicableActions(
    TriggerContext context,
    Trigger_Handler_Config__mdt parentConfig
  ) {
    // Convert trigger context to event string
    String triggerEvent = getTriggerEventString(context);
    String currentUsername = UserInfo.getUserName();

    // Build query dynamically using constants class
    // This centralizes field list - if new fields are added to Trigger_Action__mdt,
    // just update TRIGGER_ACTION_FIELDS in TriggerHandlerConstants.cls
    String queryString = TriggerHandlerConstants.buildTriggerActionQuery(
      context.sObjectType,
      triggerEvent
    );

    // Execute query - results are already sorted by database
    // Custom Metadata queries are cached by the platform and don't count against limits
    List<Trigger_Action__mdt> allActions = Database.query(queryString);

    // Additional runtime filtering (bypass, recursion, username exclusions)
    List<Trigger_Action__mdt> applicableActions = new List<Trigger_Action__mdt>();

    for (Trigger_Action__mdt action : allActions) {
      // Check username exclusions
      if (
        String.isNotBlank(action.Usernames_to_Exclude__c) &&
        action.Usernames_to_Exclude__c.contains(currentUsername)
      ) {
        continue;
      }

      // Check bypass (runtime - not in query because it's dynamic)
      if (isBypassed(context.sObjectType, action.Apex_Class_Name__c)) {
        continue;
      }

      // Check recursion (runtime - not in query because it's dynamic)
      if (
        hasExceededMaxExecutions(context.sObjectType, action.Apex_Class_Name__c)
      ) {
        System.debug(
          TriggerHandlerConstants.formatMessage(
            TriggerHandlerConstants.HANDLER_SKIPPED_RECURSION,
            new List<String>{ action.Apex_Class_Name__c }
          )
        );
        continue;
      }

      applicableActions.add(action);
    }

    // Already sorted by database - no Apex sorting needed!
    return applicableActions;
  }

  /**
   * @description Converts trigger context to event string matching picklist values
   * @param context The trigger context
   * @return String like "Before Insert", "After Update", etc.
   */
  private String getTriggerEventString(TriggerContext context) {
    if (context.isBefore && context.isInsert)
      return 'Before Insert';
    if (context.isBefore && context.isUpdate)
      return 'Before Update';
    if (context.isBefore && context.isDelete)
      return 'Before Delete';
    if (context.isAfter && context.isInsert)
      return 'After Insert';
    if (context.isAfter && context.isUpdate)
      return 'After Update';
    if (context.isAfter && context.isDelete)
      return 'After Delete';
    if (context.isAfter && context.isUndelete)
      return 'After Undelete';
    return '';
  }

  /**
   * @description Executes a single trigger action
   * @param action The Trigger_Action__mdt record configuration
   * @param context The trigger context
   */
  private void executeAction(
    Trigger_Action__mdt action,
    TriggerContext context
  ) {
    String handlerKey = TriggerHandlerConstants.createHandlerKey(
      context.sObjectType,
      action.Apex_Class_Name__c
    );

    // Increment execution count
    Integer count = executionCounts.containsKey(handlerKey)
      ? executionCounts.get(handlerKey)
      : 0;
    executionCounts.put(handlerKey, count + 1);

    try {
      // Apply method-level bypasses from metadata configuration
      Set<String> configuredBypassedMethods = parseBypassedMethods(
        action.Bypassed_Methods__c,
        action.Apex_Class_Name__c
      );

      // Instantiate the handler class
      Type handlerType = Type.forName(action.Apex_Class_Name__c);

      if (handlerType == null) {
        throw new TriggerHandlerException(
          TriggerHandlerConstants.formatMessage(
            TriggerHandlerConstants.HANDLER_CLASS_NOT_FOUND,
            new List<String>{ action.Apex_Class_Name__c }
          )
        );
      }

      Object handlerInstance = handlerType.newInstance();

      // Execute synchronously or asynchronously
      if (
        action.Asynchronous__c &&
        System.isBatch() == false &&
        System.isFuture() == false
      ) {
        executeAsync(action.Apex_Class_Name__c, action.Method_Name__c, context);
      } else {
        // Check if it implements ITriggerHandler
        if (handlerInstance instanceof ITriggerHandler) {
          ITriggerHandler handler = (ITriggerHandler) handlerInstance;

          // Execute - either specific method or default execute()
          if (String.isNotBlank(action.Method_Name__c)) {
            // Method-based approach: call specific method
            handler.executeMethod(action.Method_Name__c, context);

            System.debug(
              LoggingLevel.INFO,
              'Executed: ' +
                action.Apex_Class_Name__c +
                '.' +
                action.Method_Name__c
            );
          } else {
            // Class-based approach: call default execute()
            handler.execute(context);

            System.debug(
              LoggingLevel.INFO,
              'Executed: ' + action.Apex_Class_Name__c + '.execute()'
            );
          }
        } else {
          throw new TriggerHandlerException(
            TriggerHandlerConstants.formatMessage(
              TriggerHandlerConstants.HANDLER_MISSING_INTERFACE,
              new List<String>{ action.Apex_Class_Name__c }
            )
          );
        }
      }
    } catch (Exception e) {
      // Log the error
      System.debug(
        LoggingLevel.ERROR,
        TriggerHandlerConstants.formatMessage(
          TriggerHandlerConstants.HANDLER_ERROR_LOG,
          new List<String>{ action.Apex_Class_Name__c, e.getMessage() }
        )
      );
      System.debug(LoggingLevel.ERROR, e.getStackTraceString());

      // Re-throw if user-managed (allows developers to see errors)
      if (action.User_Managed__c) {
        throw new TriggerHandlerException(
          TriggerHandlerConstants.formatMessage(
            TriggerHandlerConstants.HANDLER_EXECUTION_ERROR,
            new List<String>{ action.Apex_Class_Name__c, e.getMessage() }
          ),
          e
        );
      }
    } finally {
      // Clear method bypasses that were set from metadata configuration
      Set<String> configuredBypassedMethods = parseBypassedMethods(
        action.Bypassed_Methods__c,
        action.Apex_Class_Name__c
      );
      for (String methodKey : configuredBypassedMethods) {
        bypassedMethods.remove(methodKey);
      }
    }
  }

  /**
   * @description Parses the Bypassed_Methods__c field and applies method bypasses
   * @param bypassedMethodsConfig Comma or semicolon-separated method names
   * @param handlerName The handler class name
   * @return Set of method keys that were bypassed
   */
  private Set<String> parseBypassedMethods(
    String bypassedMethodsConfig,
    String handlerName
  ) {
    Set<String> methodKeys = new Set<String>();

    if (String.isBlank(bypassedMethodsConfig)) {
      return methodKeys;
    }

    // Split by comma or semicolon
    List<String> methodNames = bypassedMethodsConfig.split('[,;]');

    for (String methodName : methodNames) {
      String trimmedMethod = methodName.trim();
      if (String.isNotBlank(trimmedMethod)) {
        String methodKey = TriggerHandlerConstants.createMethodKey(
          handlerName,
          trimmedMethod
        );
        bypassedMethods.add(methodKey);
        methodKeys.add(methodKey);
      }
    }

    return methodKeys;
  }

  /**
   * @description Executes a handler asynchronously using Queueable
   * @param className The name of the handler class
   * @param methodName The method to execute (optional)
   * @param context The trigger context
   */
  private void executeAsync(
    String className,
    String methodName,
    TriggerContext context
  ) {
    System.enqueueJob(new AsyncTriggerHandler(className, methodName, context));
  }

  /**
   * @description Checks if a handler is bypassed
   * @param sObjectType The sObject type
   * @param handlerName The handler class name
   * @return True if bypassed, false otherwise
   */
  private Boolean isBypassed(String sObjectType, String handlerName) {
    if (bypassedHandlers.containsKey(sObjectType)) {
      return bypassedHandlers.get(sObjectType).contains(handlerName);
    }
    return false;
  }

  /**
   * @description Checks if a handler has exceeded max executions (recursion prevention)
   * @param sObjectType The sObject type
   * @param handlerName The handler class name
   * @return True if exceeded, false otherwise
   */
  private Boolean hasExceededMaxExecutions(
    String sObjectType,
    String handlerName
  ) {
    String key = TriggerHandlerConstants.createHandlerKey(
      sObjectType,
      handlerName
    );
    if (executionCounts.containsKey(key)) {
      return executionCounts.get(key) >=
        TriggerHandlerConstants.MAX_HANDLER_EXECUTIONS;
    }
    return false;
  }

  // ========== PUBLIC STATIC METHODS FOR BYPASS CONTROL ==========

  /**
   * @description Bypass a specific handler for an object
   * @param sObjectType The sObject type
   * @param handlerName The handler class name
   */
  public static void bypass(String sObjectType, String handlerName) {
    if (!bypassedHandlers.containsKey(sObjectType)) {
      bypassedHandlers.put(sObjectType, new Set<String>());
    }
    bypassedHandlers.get(sObjectType).add(handlerName);
  }

  /**
   * @description Clear bypass for a specific handler
   * @param sObjectType The sObject type
   * @param handlerName The handler class name
   */
  public static void clearBypass(String sObjectType, String handlerName) {
    if (bypassedHandlers.containsKey(sObjectType)) {
      bypassedHandlers.get(sObjectType).remove(handlerName);
    }
  }

  /**
   * @description Clear all bypasses for an object
   * @param sObjectType The sObject type
   */
  public static void clearAllBypasses(String sObjectType) {
    bypassedHandlers.remove(sObjectType);
  }

  /**
   * @description Clear all bypasses globally
   */
  public static void clearAllBypasses() {
    bypassedHandlers.clear();
  }

  /**
   * @description Check if a handler is currently bypassed
   * @param sObjectType The sObject type
   * @param handlerName The handler class name
   * @return True if bypassed, false otherwise
   */
  public static Boolean isHandlerBypassed(
    String sObjectType,
    String handlerName
  ) {
    if (bypassedHandlers.containsKey(sObjectType)) {
      return bypassedHandlers.get(sObjectType).contains(handlerName);
    }
    return false;
  }

  // ========== PUBLIC STATIC METHODS FOR METHOD-LEVEL BYPASS ==========

  /**
   * @description Bypass a specific method within a handler
   * @param handlerName The handler class name
   * @param methodName The method name to bypass
   * Example: TriggerHandler.bypassMethod('AccountTriggerHandler', 'validateAccounts');
   */
  public static void bypassMethod(String handlerName, String methodName) {
    String methodKey = TriggerHandlerConstants.createMethodKey(
      handlerName,
      methodName
    );
    bypassedMethods.add(methodKey);
  }

  /**
   * @description Clear bypass for a specific method
   * @param handlerName The handler class name
   * @param methodName The method name
   */
  public static void clearMethodBypass(String handlerName, String methodName) {
    String methodKey = TriggerHandlerConstants.createMethodKey(
      handlerName,
      methodName
    );
    bypassedMethods.remove(methodKey);
  }

  /**
   * @description Clear all method bypasses for a specific handler
   * @param handlerName The handler class name
   */
  public static void clearAllMethodBypasses(String handlerName) {
    Set<String> toRemove = new Set<String>();
    for (String methodKey : bypassedMethods) {
      if (
        methodKey.startsWith(
          handlerName + TriggerHandlerConstants.METHOD_KEY_SEPARATOR
        )
      ) {
        toRemove.add(methodKey);
      }
    }
    bypassedMethods.removeAll(toRemove);
  }

  /**
   * @description Clear all method bypasses globally
   */
  public static void clearAllMethodBypasses() {
    bypassedMethods.clear();
  }

  /**
   * @description Check if a specific method is currently bypassed
   * Use this in your handler methods to check if execution should be skipped
   * @param handlerName The handler class name (use this.getClass().getName())
   * @param methodName The method name
   * @return True if bypassed, false otherwise
   * Example: if (TriggerHandler.isMethodBypassed('AccountTriggerHandler', 'validateAccounts')) return;
   */
  public static Boolean isMethodBypassed(
    String handlerName,
    String methodName
  ) {
    String methodKey = TriggerHandlerConstants.createMethodKey(
      handlerName,
      methodName
    );
    return bypassedMethods.contains(methodKey);
  }

  // Custom exception class
  public class TriggerHandlerException extends Exception {
  }
}