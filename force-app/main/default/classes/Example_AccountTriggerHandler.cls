/**
 * @description Trigger handler for Account object
 * Demonstrates method-based approach where one handler class contains multiple methods,
 * each configured separately via Trigger_Action__mdt.
 *
 * @author Haribaskar
 * @date 2025
 */
public class Example_AccountTriggerHandler implements ITriggerHandler {
  /**
   * @description Default execute method (called when no method name specified)
   * This method delegates to specific methods based on trigger context
   */
  public void execute(TriggerContext context) {
    if (context.isBefore && context.isInsert) {
      if (
        !TriggerHandler.isMethodBypassed(
          'Example_AccountTriggerHandler',
          'validateAccounts'
        )
      ) {
        validateAccounts(context);
      }
    }
  }

  /**
   * @description Execute specific method by name
   * This enables the method-based approach where metadata specifies which method to call
   */
  public void executeMethod(String methodName, TriggerContext context) {
    // Check if method is bypassed
    if (
      TriggerHandler.isMethodBypassed('Example_AccountTriggerHandler', methodName)
    ) {
      System.debug('Method bypassed: Example_AccountTriggerHandler.' + methodName);
      return;
    }

    // Call the requested method using switch statement
    switch on methodName {
      when 'validateAccounts' {
        validateAccounts(context);
      }
      when else {
        throw new TriggerHandlerException(
          'Unknown method: ' + methodName + ' in Example_AccountTriggerHandler'
        );
      }
    }
  }

  // ========== PUBLIC METHODS (CONFIGURABLE VIA METADATA) ==========

  /**
   * @description Validates account data before insert/update
   *
   * Trigger Actions:
   * - Before Insert (Order: 1.0)
   * - Before Update (Order: 1.0)
   *
   * @param context The trigger context
   */
  public void validateAccounts(TriggerContext context) {
    System.debug('Example_AccountTriggerHandler.validateAccounts() started');

    for (Account acc : (List<Account>) context.newList) {
      // Validate required fields
      if (String.isBlank(acc.Name)) {
        acc.addError(
          'Name',
          TriggerHandlerConstants.MSG_VALIDATION_REQUIRED_FIELD
        );
      }
    }

    System.debug('Example_AccountTriggerHandler.validateAccounts() completed');
  }

  // ========== PRIVATE HELPER METHODS ==========

  /**
   * @description Checks if an account has significant changes
   * @param newAcc The new account record
   * @param oldMap Map of old account records
   * @return True if there are significant changes
   */
  private Boolean hasSignificantChange(
    Account newAcc,
    Map<Id, SObject> oldMap
  ) {
    Account oldAcc = (Account) oldMap.get(newAcc.Id);

    return newAcc.Name != oldAcc.Name ||
      newAcc.Type != oldAcc.Type ||
      newAcc.Industry != oldAcc.Industry ||
      newAcc.AnnualRevenue != oldAcc.AnnualRevenue;
  }

  // Custom exception class
  public class TriggerHandlerException extends Exception {
  }
}