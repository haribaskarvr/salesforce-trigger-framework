/**
 * @description Test class for TriggerHandler framework
 * Tests bypass and utility functions. Custom Metadata Types cannot be inserted in tests.
 *
 * @author Haribaskar
 * @date 2025
 */
@isTest
private class TriggerHandlerTest {
  /**
   * @description Test handler bypass functionality
   */
  @isTest
  static void testHandlerBypass() {
    Test.startTest();

    // Bypass the handler
    TriggerHandler.bypass('Account', 'TestAccountHandler');

    // Verify bypass is active
    System.assertEquals(
      true,
      TriggerHandler.isHandlerBypassed('Account', 'TestAccountHandler'),
      'Handler should be bypassed'
    );

    // Insert account (handler should not execute if configured)
    Account acc = new Account(Name = 'Test Account');
    insert acc;

    // Clear bypass
    TriggerHandler.clearBypass('Account', 'TestAccountHandler');

    // Verify bypass is cleared
    System.assertEquals(
      false,
      TriggerHandler.isHandlerBypassed('Account', 'TestAccountHandler'),
      'Handler should not be bypassed'
    );

    Test.stopTest();
  }

  /**
   * @description Test handler execution with DML
   * Note: Actual handler execution depends on Custom Metadata records in your org
   */
  @isTest
  static void testHandlerExecution() {
    Test.startTest();
    Account acc = new Account(Name = 'Test Account');
    insert acc;
    Test.stopTest();

    // Verify account was inserted successfully
    System.assertNotEquals(null, acc.Id, 'Account should be inserted');
  }

  /**
   * @description Test trigger context helper methods
   */
  @isTest
  static void testTriggerContext() {
    // This test validates TriggerContext utility methods
    // Note: TriggerContext can only be properly tested within an actual trigger

    Account acc = new Account(Name = 'Test Account', Industry = 'Technology');
    insert acc;

    Test.startTest();
    acc.Industry = 'Finance';
    update acc;
    Test.stopTest();

    // Context would show field change in actual trigger
    acc = [SELECT Id, Industry FROM Account WHERE Id = :acc.Id];
    System.assertEquals('Finance', acc.Industry, 'Industry should be updated');
  }

  /**
   * @description Test clear all bypasses
   */
  @isTest
  static void testClearAllBypasses() {
    // Bypass multiple handlers
    TriggerHandler.bypass('Account', 'Handler1');
    TriggerHandler.bypass('Account', 'Handler2');
    TriggerHandler.bypass('Contact', 'Handler3');

    // Verify bypasses are active
    System.assertEquals(
      true,
      TriggerHandler.isHandlerBypassed('Account', 'Handler1'),
      'Handler1 should be bypassed'
    );
    System.assertEquals(
      true,
      TriggerHandler.isHandlerBypassed('Contact', 'Handler3'),
      'Handler3 should be bypassed'
    );

    // Clear all bypasses
    TriggerHandler.clearAllBypasses();

    // Verify all bypasses are cleared
    System.assertEquals(
      false,
      TriggerHandler.isHandlerBypassed('Account', 'Handler1'),
      'Handler1 should not be bypassed'
    );
    System.assertEquals(
      false,
      TriggerHandler.isHandlerBypassed('Account', 'Handler2'),
      'Handler2 should not be bypassed'
    );
    System.assertEquals(
      false,
      TriggerHandler.isHandlerBypassed('Contact', 'Handler3'),
      'Handler3 should not be bypassed'
    );
  }

  /**
   * @description Test clear object-specific bypasses
   */
  @isTest
  static void testClearObjectBypasses() {
    // Bypass handlers
    TriggerHandler.bypass('Account', 'Handler1');
    TriggerHandler.bypass('Account', 'Handler2');
    TriggerHandler.bypass('Contact', 'Handler3');

    // Clear only Account bypasses
    TriggerHandler.clearAllBypasses('Account');

    // Verify Account bypasses are cleared but Contact remains
    System.assertEquals(
      false,
      TriggerHandler.isHandlerBypassed('Account', 'Handler1'),
      'Account Handler1 should not be bypassed'
    );
    System.assertEquals(
      false,
      TriggerHandler.isHandlerBypassed('Account', 'Handler2'),
      'Account Handler2 should not be bypassed'
    );
    System.assertEquals(
      true,
      TriggerHandler.isHandlerBypassed('Contact', 'Handler3'),
      'Contact Handler3 should still be bypassed'
    );
  }

  /**
   * @description Test bypass check for non-bypassed handler
   */
  @isTest
  static void testNonBypassedHandler() {
    // Test handler that is not bypassed
    Boolean isBypassed = TriggerHandler.isHandlerBypassed(
      'Account',
      'SomeHandler'
    );
    System.assertEquals(
      false,
      isBypassed,
      'Handler should not be bypassed initially'
    );
  }

  /**
   * @description Test bulk DML operations
   */
  @isTest
  static void testBulkOperation() {
    List<Account> accounts = new List<Account>();
    for (Integer i = 0; i < 200; i++) {
      accounts.add(new Account(Name = 'Test Account ' + i));
    }

    Test.startTest();
    insert accounts;
    Test.stopTest();

    // Verify all accounts were inserted
    System.assertEquals(
      200,
      accounts.size(),
      'All accounts should be inserted'
    );
    for (Account acc : accounts) {
      System.assertNotEquals(null, acc.Id, 'Account should have an Id');
    }
  }

  /**
   * @description Test method-level bypass functionality
   */
  @isTest
  static void testMethodBypass() {
    Test.startTest();

    // Bypass specific method
    TriggerHandler.bypassMethod('Example_AccountTriggerHandler', 'validateAccounts');

    // Verify method bypass is active
    System.assertEquals(
      true,
      TriggerHandler.isMethodBypassed(
        'Example_AccountTriggerHandler',
        'validateAccounts'
      ),
      'Method should be bypassed'
    );

    // Insert account (method should not execute if configured)
    Account acc = new Account(Name = 'Test Account');
    insert acc;

    // Clear method bypass
    TriggerHandler.clearMethodBypass(
      'Example_AccountTriggerHandler',
      'validateAccounts'
    );

    // Verify method bypass is cleared
    System.assertEquals(
      false,
      TriggerHandler.isMethodBypassed(
        'Example_AccountTriggerHandler',
        'validateAccounts'
      ),
      'Method should not be bypassed'
    );

    Test.stopTest();
  }

  /**
   * @description Test clearing all method bypasses
   */
  @isTest
  static void testClearAllMethodBypasses() {
    // Bypass multiple methods
    TriggerHandler.bypassMethod('Example_AccountTriggerHandler', 'validateAccounts');
    TriggerHandler.bypassMethod('Example_AccountTriggerHandler', 'enrichAccounts');
    TriggerHandler.bypassMethod('ContactTriggerHandler', 'processContacts');

    // Verify bypasses are active
    System.assertEquals(
      true,
      TriggerHandler.isMethodBypassed(
        'Example_AccountTriggerHandler',
        'validateAccounts'
      ),
      'validateAccounts should be bypassed'
    );
    System.assertEquals(
      true,
      TriggerHandler.isMethodBypassed(
        'ContactTriggerHandler',
        'processContacts'
      ),
      'processContacts should be bypassed'
    );

    // Clear all method bypasses
    TriggerHandler.clearAllMethodBypasses();

    // Verify all method bypasses are cleared
    System.assertEquals(
      false,
      TriggerHandler.isMethodBypassed(
        'Example_AccountTriggerHandler',
        'validateAccounts'
      ),
      'validateAccounts should not be bypassed'
    );
    System.assertEquals(
      false,
      TriggerHandler.isMethodBypassed(
        'Example_AccountTriggerHandler',
        'enrichAccounts'
      ),
      'enrichAccounts should not be bypassed'
    );
    System.assertEquals(
      false,
      TriggerHandler.isMethodBypassed(
        'ContactTriggerHandler',
        'processContacts'
      ),
      'processContacts should not be bypassed'
    );
  }

  /**
   * @description Test clearing handler-specific method bypasses
   */
  @isTest
  static void testClearHandlerMethodBypasses() {
    // Bypass methods on different handlers
    TriggerHandler.bypassMethod('Example_AccountTriggerHandler', 'validateAccounts');
    TriggerHandler.bypassMethod('Example_AccountTriggerHandler', 'enrichAccounts');
    TriggerHandler.bypassMethod('ContactTriggerHandler', 'processContacts');

    // Clear only Example_AccountTriggerHandler method bypasses
    TriggerHandler.clearAllMethodBypasses('Example_AccountTriggerHandler');

    // Verify Account method bypasses are cleared but Contact remains
    System.assertEquals(
      false,
      TriggerHandler.isMethodBypassed(
        'Example_AccountTriggerHandler',
        'validateAccounts'
      ),
      'Example_AccountTriggerHandler.validateAccounts should not be bypassed'
    );
    System.assertEquals(
      false,
      TriggerHandler.isMethodBypassed(
        'Example_AccountTriggerHandler',
        'enrichAccounts'
      ),
      'Example_AccountTriggerHandler.enrichAccounts should not be bypassed'
    );
    System.assertEquals(
      true,
      TriggerHandler.isMethodBypassed(
        'ContactTriggerHandler',
        'processContacts'
      ),
      'ContactTriggerHandler.processContacts should still be bypassed'
    );
  }

  // ========== TEST HELPER CLASS ==========

  /**
   * @description Mock handler for testing
   *
   * To use this in your org, create metadata records:
   *
   * 1. Parent Config (Trigger_Handler_Config__mdt):
   *    - Label: Test Account Configuration
   *    - Object_API_Name__c: Account
   *    - Active__c: true
   *
   * 2. Child Action (Trigger_Action__mdt):
   *    - Label: Test Account Handler
   *    - Trigger_Handler_Config__c: Test Account Configuration
   *    - Apex_Class_Name__c: TriggerHandlerTest.TestAccountHandler
   *    - Method_Name__c: (blank for default execute)
   *    - Trigger_Event__c: Before Insert
   *    - Active__c: true
   *    - Execution_Order__c: 1
   */
  public class TestAccountHandler implements ITriggerHandler {
    /**
     * @description Default execute method
     */
    public void execute(TriggerContext context) {
      // Mock implementation for testing
      System.debug('TestAccountHandler.execute() called');
      System.debug('Operation: ' + context.operationType);
      System.debug('Record count: ' + context.size);
    }

    /**
     * @description Execute specific method by name
     */
    public void executeMethod(String methodName, TriggerContext context) {
      System.debug('TestAccountHandler.executeMethod() called');
      System.debug('Method: ' + methodName);
      System.debug('Operation: ' + context.operationType);

      // Implement method routing if needed
      switch on methodName {
        when 'testValidation' {
          testValidation(context);
        }
        when 'testProcessing' {
          testProcessing(context);
        }
        when else {
          execute(context);
        }
      }
    }

    /**
     * @description Test validation method
     */
    private void testValidation(TriggerContext context) {
      System.debug('TestAccountHandler.testValidation() called');
    }

    /**
     * @description Test processing method
     */
    private void testProcessing(TriggerContext context) {
      System.debug('TestAccountHandler.testProcessing() called');
    }
  }
}