/**
 * @description Constants class for Trigger Handler Framework
 * Centralizes error messages, debug messages, and configuration values.
 *
 * @author Haribaskar
 * @date 2025
 */
public class TriggerHandlerConstants {
  // ========== FRAMEWORK CONFIGURATION ==========

  /**
   * @description Maximum number of times a handler can execute per transaction
   * Prevents infinite recursion loops
   */
  public static final Integer MAX_HANDLER_EXECUTIONS = 5;

  /**
   * @description Default load order for handlers without explicit order
   */
  public static final Integer DEFAULT_LOAD_ORDER = 999999;

  /**
   * @description Separator used in handler keys
   */
  public static final String HANDLER_KEY_SEPARATOR = '_';

  /**
   * @description Separator used in method keys for method-level bypass
   */
  public static final String METHOD_KEY_SEPARATOR = '.';

  // ========== TRIGGER ACTION QUERY FIELDS ==========

  /**
   * @description Standard fields to query from Trigger_Action__mdt
   * Maintains list in one place for easy updates when new fields are added
   */
  public static final List<String> TRIGGER_ACTION_FIELDS = new List<String>{
    'Id',
    'Label',
    'Apex_Class_Name__c',
    'Method_Name__c',
    'Trigger_Event__c',
    'Execution_Order__c',
    'Active__c',
    'Asynchronous__c',
    'User_Managed__c',
    'Description__c',
    'Bypassed_Methods__c',
    'Usernames_to_Exclude__c',
    'Trigger_Handler_Config__r.Object_API_Name__c'
  };

  /**
   * @description Standard fields to query from Trigger_Handler_Config__mdt
   */
  public static final List<String> TRIGGER_CONFIG_FIELDS = new List<String>{
    'Id',
    'Label',
    'DeveloperName',
    'Object_API_Name__c',
    'Active__c',
    'Bypass_All_Actions__c',
    'Description__c'
  };

  // ========== CUSTOM SETTINGS BYPASS MESSAGES ==========

  /**
   * @description Message when all triggers are bypassed via Custom Setting
   */
  public static final String MSG_BYPASS_ALL = 'All triggers bypassed via Custom Setting';

  /**
   * @description Message template when triggers are bypassed for a specific object
   * Use with: formatMessage(MSG_BYPASS_OBJECT, new List<String>{'ObjectName'})
   */
  public static final String MSG_BYPASS_OBJECT = 'Triggers bypassed for object: {0}';

  /**
   * @description Message template when hard bypass is enabled for an object
   * Use with: formatMessage(MSG_BYPASS_HARD, new List<String>{'ObjectName'})
   */
  public static final String MSG_BYPASS_HARD = 'Hard bypass enabled for object: {0}';

  // ========== VALIDATION MESSAGES ==========

  /**
   * @description Validation message for required fields
   */
  public static final String MSG_VALIDATION_REQUIRED_FIELD = 'This field is required';

  // ========== ERROR MESSAGES ==========

  /**
   * @description Error message when handler class is not found
   * Use with: String.format(HANDLER_CLASS_NOT_FOUND, new String[]{className})
   */
  public static final String HANDLER_CLASS_NOT_FOUND = 'Handler class not found: {0}';

  /**
   * @description Error message when handler doesn't implement ITriggerHandler
   * Use with: String.format(HANDLER_MISSING_INTERFACE, new String[]{className})
   */
  public static final String HANDLER_MISSING_INTERFACE = 'Handler class must implement ITriggerHandler: {0}';

  /**
   * @description Error message when handler execution fails
   * Use with: String.format(HANDLER_EXECUTION_ERROR, new String[]{className, errorMessage})
   */
  public static final String HANDLER_EXECUTION_ERROR = 'Error in handler {0}: {1}';

  // ========== DEBUG MESSAGES ==========

  /**
   * @description Debug message when handler is skipped due to recursion
   * Use with: String.format(HANDLER_SKIPPED_RECURSION, new String[]{className})
   */
  public static final String HANDLER_SKIPPED_RECURSION = 'Skipping {0} due to recursion limit';

  /**
   * @description Debug message when logging handler execution errors
   * Use with: String.format(HANDLER_ERROR_LOG, new String[]{className, errorMessage})
   */
  public static final String HANDLER_ERROR_LOG = 'Error executing handler {0}: {1}';

  /**
   * @description Debug message when handler executes successfully
   * Use with: String.format(HANDLER_EXECUTED, new String[]{className, operationType})
   */
  public static final String HANDLER_EXECUTED = 'Handler {0} executed successfully for {1}';

  /**
   * @description Debug message for handler execution context
   * Use with: String.format(HANDLER_CONTEXT_LOG, new String[]{className, operation, recordCount})
   */
  public static final String HANDLER_CONTEXT_LOG = 'Executing handler {0} for {1} with {2} records';

  // ========== ASYNC HANDLER MESSAGES ==========

  /**
   * @description Error message when async handler fails
   * Use with: String.format(ASYNC_HANDLER_ERROR, new String[]{className, errorMessage})
   */
  public static final String ASYNC_HANDLER_ERROR = 'Error in async handler {0}: {1}';

  /**
   * @description Debug message when async handler starts
   * Use with: String.format(ASYNC_HANDLER_START, new String[]{className})
   */
  public static final String ASYNC_HANDLER_START = 'Starting async execution of handler {0}';

  // ========== EXAMPLE VALIDATION MESSAGES ==========
  // These are examples for the ExampleAccountTriggerHandler class
  // Copy this pattern for your own handlers

  /**
   * @description Example validation message for required phone field
   */
  public static final String EXAMPLE_PHONE_REQUIRED = 'Phone is required for active accounts';

  /**
   * @description Example validation message template
   * Use with: formatMessage(EXAMPLE_FIELD_REQUIRED, new List<String>{'Phone'})
   */
  public static final String EXAMPLE_FIELD_REQUIRED = '{0} is required for this record type';

  // ========== UTILITY METHODS ==========

  /**
   * @description Formats a message with parameters
   * @param message The message template with {0}, {1}, etc. placeholders
   * @param params The parameters to replace in the message
   * @return Formatted message string
   */
  public static String formatMessage(String message, List<String> params) {
    if (params == null || params.isEmpty()) {
      return message;
    }

    String result = message;
    for (Integer i = 0; i < params.size(); i++) {
      result = result.replace('{' + i + '}', params[i] ?? '');
    }
    return result;
  }

  /**
   * @description Creates a handler key for bypass/recursion tracking
   * @param sObjectType The sObject type
   * @param handlerName The handler class name
   * @return Handler key in format: sObjectType_handlerName
   */
  public static String createHandlerKey(
    String sObjectType,
    String handlerName
  ) {
    return sObjectType + HANDLER_KEY_SEPARATOR + handlerName;
  }

  /**
   * @description Creates a method key for method-level bypass tracking
   * @param handlerName The handler class name
   * @param methodName The method name
   * @return Method key in format: handlerName.methodName
   * Example: 'AccountTriggerHandler.updateContact'
   */
  public static String createMethodKey(String handlerName, String methodName) {
    return handlerName + METHOD_KEY_SEPARATOR + methodName;
  }

  /**
   * @description Builds the SELECT clause for Trigger_Action__mdt queries
   * Centralizes field list management - add new fields to TRIGGER_ACTION_FIELDS constant
   * @return SELECT clause string (without 'SELECT' keyword)
   * Example: 'Id, Label, Apex_Class_Name__c, ...'
   */
  public static String getTriggerActionSelectClause() {
    return String.join(TRIGGER_ACTION_FIELDS, ', ');
  }

  /**
   * @description Builds the SELECT clause for Trigger_Handler_Config__mdt queries
   * @return SELECT clause string (without 'SELECT' keyword)
   */
  public static String getTriggerConfigSelectClause() {
    return String.join(TRIGGER_CONFIG_FIELDS, ', ');
  }

  /**
   * @description Dynamically discovers all fields for a Custom Metadata Type
   * Use this if you want to query ALL fields without maintaining a field list
   * Note: This uses Schema describe calls (not counted against limits)
   * @param metadataTypeName The API name of the Custom Metadata Type
   * @return List of field API names
   */
  public static List<String> getAllFieldsForMetadataType(
    String metadataTypeName
  ) {
    List<String> fieldList = new List<String>();

    try {
      // Get the SObject type
      Schema.SObjectType sObjType = Schema.getGlobalDescribe()
        .get(metadataTypeName);

      if (sObjType == null) {
        System.debug(
          LoggingLevel.ERROR,
          'Metadata type not found: ' + metadataTypeName
        );
        return fieldList;
      }

      // Get all fields for the type
      Map<String, Schema.SObjectField> fieldMap = sObjType.getDescribe()
        .fields.getMap();

      // Add all field names
      fieldList.addAll(fieldMap.keySet());

      // Note: Relationship fields like 'Trigger_Handler_Config__r.Object_API_Name__c'
      // need to be added manually as they're not in the field map
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Error getting fields for ' + metadataTypeName + ': ' + e.getMessage()
      );
    }

    return fieldList;
  }

  /**
   * @description Builds a complete SOQL query for Trigger_Action__mdt
   * Uses field list from constants - maintains DRY principle
   * @param objectName The object API name to filter by
   * @param triggerEvent The trigger event to filter by (e.g., 'Before Insert')
   * @return Complete SOQL query string
   */
  public static String buildTriggerActionQuery(
    String objectName,
    String triggerEvent
  ) {
    String selectClause = getTriggerActionSelectClause();
    String whereClause =
      'Trigger_Handler_Config__r.Object_API_Name__c = \'' +
      String.escapeSingleQuotes(objectName) +
      '\' ' +
      'AND Trigger_Event__c = \'' +
      String.escapeSingleQuotes(triggerEvent) +
      '\' ' +
      'AND Active__c = TRUE';
    String orderByClause = 'Execution_Order__c ASC NULLS LAST, Label ASC';

    return 'SELECT ' +
      selectClause +
      ' FROM Trigger_Action__mdt ' +
      'WHERE ' +
      whereClause +
      ' ORDER BY ' +
      orderByClause;
  }
}