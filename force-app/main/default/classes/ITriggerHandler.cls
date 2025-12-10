/**
 * @description Interface for trigger handler classes
 * All trigger handler classes must implement this interface.
 * Supports both class-based and method-based execution patterns.
 *
 * @author Haribaskar
 * @date 2025
 */
public interface ITriggerHandler {
  /**
   * @description Main execution method called by the dispatcher
   * Called when no method name is specified in Trigger_Action__mdt
   * @param context The trigger context containing old/new records and maps
   */
  void execute(TriggerContext context);

  /**
   * @description Execute a specific method by name
   * Called when Method_Name__c is populated in Trigger_Action__mdt
   * Enables method-based approach: one handler class with multiple methods
   * @param methodName The name of the method to execute
   * @param context The trigger context containing old/new records and maps
   */
  void executeMethod(String methodName, TriggerContext context);
}