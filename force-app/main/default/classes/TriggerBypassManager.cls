/**
 * @description Manages trigger bypass logic using Custom Settings and Custom Metadata
 * Provides hierarchical bypass control at Org, Profile, and User levels.
 *
 * @author Haribaskar
 * @date 2025
 */
public class TriggerBypassManager {
  // Cache for Custom Metadata to avoid repeated queries
  private static Map<String, Trigger_Handler_Config__mdt> bypassConfigCache;

  /**
   * @description Check if ALL triggers should be bypassed for current user
   * Uses Hierarchy Custom Setting to check Org/Profile/User level
   * @return True if all triggers should be bypassed
   */
  public static Boolean shouldBypassAllTriggers() {
    Trigger_Bypass__c setting = Trigger_Bypass__c.getInstance();

    if (setting == null) {
      return false;
    }

    return setting.Bypass_All_Triggers__c == true;
  }

  /**
   * @description Check if a specific object's triggers should be bypassed
   * Checks three levels: hard bypass, object-specific bypass via metadata
   * @param objectName The API name of the object (e.g., 'Account')
   * @return True if object triggers should be bypassed
   */
  public static Boolean shouldBypassObject(String objectName) {
    // Check Custom Setting first
    Trigger_Bypass__c setting = Trigger_Bypass__c.getInstance();

    if (setting == null) {
      return false;
    }

    // Check hard bypass (emergency comma-separated list)
    if (isHardBypassEnabled(objectName, setting)) {
      System.debug(
        LoggingLevel.WARN,
        TriggerHandlerConstants.formatMessage(
          TriggerHandlerConstants.MSG_BYPASS_HARD,
          new List<String>{ objectName }
        )
      );
      return true;
    }

    // Check if object-specific bypass is enabled
    if (setting.Bypass_Object_Triggers__c == true) {
      return isObjectBypassEnabled(objectName);
    }

    return false;
  }

  /**
   * @description Check if object is in the hard bypass list
   * Hard bypass is for emergency use - comma-separated list in Custom Setting
   * @param objectName The API name of the object
   * @param setting The Trigger_Bypass__c custom setting instance
   * @return True if object is in hard bypass list
   */
  private static Boolean isHardBypassEnabled(
    String objectName,
    Trigger_Bypass__c setting
  ) {
    if (String.isBlank(setting.Force_Bypass_Objects__c)) {
      return false;
    }

    // Parse comma-separated list
    Set<String> bypassedObjects = new Set<String>();
    List<String> objectList = setting.Force_Bypass_Objects__c.split(',');

    for (String obj : objectList) {
      bypassedObjects.add(obj.trim());
    }

    return bypassedObjects.contains(objectName);
  }

  /**
   * @description Check if object bypass is enabled via Custom Metadata
   * Uses Trigger_Handler_Config__mdt.Bypass_All_Actions__c field
   * This consolidates bypass logic into the main handler configuration
   * @param objectName The API name of the object
   * @return True if object bypass is enabled
   */
  private static Boolean isObjectBypassEnabled(String objectName) {
    // Initialize cache if needed
    if (bypassConfigCache == null) {
      bypassConfigCache = Trigger_Handler_Config__mdt.getAll();
    }

    // Look for matching configuration
    for (Trigger_Handler_Config__mdt config : bypassConfigCache.values()) {
      if (
        config.Object_API_Name__c == objectName &&
        config.Bypass_All_Actions__c == true
      ) {
        System.debug(
          LoggingLevel.WARN,
          TriggerHandlerConstants.formatMessage(
            TriggerHandlerConstants.MSG_BYPASS_OBJECT,
            new List<String>{ objectName }
          )
        );
        return true;
      }
    }

    return false;
  }

  /**
   * @description Check if triggers should execute (combines all bypass checks)
   * This is the main entry point for trigger bypass checking
   * @param objectName The API name of the object
   * @return True if triggers should execute, false if bypassed
   */
  public static Boolean shouldExecuteTriggers(String objectName) {
    // Check global bypass first (highest priority)
    if (shouldBypassAllTriggers()) {
      System.debug(LoggingLevel.WARN, TriggerHandlerConstants.MSG_BYPASS_ALL);
      return false;
    }

    // Check object-specific bypass
    if (shouldBypassObject(objectName)) {
      return false;
    }

    return true;
  }

  /**
   * @description Get current bypass status for debugging
   * Useful for troubleshooting bypass configuration issues
   * @param objectName The API name of the object
   * @return Map of bypass status information
   */
  public static Map<String, Boolean> getBypassStatus(String objectName) {
    Map<String, Boolean> status = new Map<String, Boolean>();

    status.put('allTriggersBypassed', shouldBypassAllTriggers());
    status.put('objectBypassed', shouldBypassObject(objectName));
    status.put('shouldExecute', shouldExecuteTriggers(objectName));

    return status;
  }

  /**
   * @description Clear Custom Metadata cache (useful for testing)
   * Allows tests to reload metadata configuration
   */
  @TestVisible
  private static void clearCache() {
    bypassConfigCache = null;
  }
}