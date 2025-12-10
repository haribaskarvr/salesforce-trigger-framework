/**
 * @description Test class for TriggerHandlerConstants
 * Tests constant utility methods and message formatting
 *
 * @author Haribaskar
 * @date 2025
 */
@isTest
private class TriggerHandlerConstantsTest {
  /**
   * @description Test formatMessage with single parameter
   */
  @isTest
  static void testFormatMessageSingleParam() {
    Test.startTest();

    String message = TriggerHandlerConstants.formatMessage(
      TriggerHandlerConstants.HANDLER_CLASS_NOT_FOUND,
      new List<String>{ 'TestHandler' }
    );

    Test.stopTest();

    System.assert(
      message.contains('TestHandler'),
      'Message should contain handler name'
    );
    System.assert(
      message.contains('not found'),
      'Message should contain "not found"'
    );
  }

  /**
   * @description Test formatMessage with multiple parameters
   */
  @isTest
  static void testFormatMessageMultipleParams() {
    Test.startTest();

    String message = TriggerHandlerConstants.formatMessage(
      TriggerHandlerConstants.HANDLER_EXECUTION_ERROR,
      new List<String>{ 'AccountHandler', 'Null pointer exception' }
    );

    Test.stopTest();

    System.assert(
      message.contains('AccountHandler'),
      'Message should contain handler name'
    );
    System.assert(
      message.contains('Null pointer exception'),
      'Message should contain error message'
    );
  }

  /**
   * @description Test formatMessage with no parameters
   */
  @isTest
  static void testFormatMessageNoParams() {
    Test.startTest();

    String message = TriggerHandlerConstants.formatMessage(
      TriggerHandlerConstants.MSG_BYPASS_ALL,
      null
    );

    Test.stopTest();

    System.assertEquals(
      TriggerHandlerConstants.MSG_BYPASS_ALL,
      message,
      'Message should remain unchanged'
    );
  }

  /**
   * @description Test formatMessage with empty parameter list
   */
  @isTest
  static void testFormatMessageEmptyParams() {
    Test.startTest();

    String message = TriggerHandlerConstants.formatMessage(
      'Test message',
      new List<String>()
    );

    Test.stopTest();

    System.assertEquals(
      'Test message',
      message,
      'Message should remain unchanged with empty params'
    );
  }

  /**
   * @description Test createHandlerKey method
   */
  @isTest
  static void testCreateHandlerKey() {
    Test.startTest();

    String handlerKey = TriggerHandlerConstants.createHandlerKey(
      'Account',
      'AccountTriggerHandler'
    );

    Test.stopTest();

    System.assertEquals(
      'Account_AccountTriggerHandler',
      handlerKey,
      'Handler key should be properly formatted'
    );
    System.assert(
      handlerKey.contains(TriggerHandlerConstants.HANDLER_KEY_SEPARATOR),
      'Handler key should contain separator'
    );
  }

  /**
   * @description Test createMethodKey method
   */
  @isTest
  static void testCreateMethodKey() {
    Test.startTest();

    String methodKey = TriggerHandlerConstants.createMethodKey(
      'AccountTriggerHandler',
      'validateAccounts'
    );

    Test.stopTest();

    System.assertEquals(
      'AccountTriggerHandler.validateAccounts',
      methodKey,
      'Method key should be properly formatted'
    );
    System.assert(
      methodKey.contains(TriggerHandlerConstants.METHOD_KEY_SEPARATOR),
      'Method key should contain separator'
    );
  }

  /**
   * @description Test getTriggerActionSelectClause method
   */
  @isTest
  static void testGetTriggerActionSelectClause() {
    Test.startTest();

    String selectClause = TriggerHandlerConstants.getTriggerActionSelectClause();

    Test.stopTest();

    System.assertNotEquals(
      null,
      selectClause,
      'Select clause should not be null'
    );
    System.assert(
      selectClause.contains('Id'),
      'Select clause should contain Id'
    );
    System.assert(
      selectClause.contains('Apex_Class_Name__c'),
      'Select clause should contain Apex_Class_Name__c'
    );
    System.assert(
      selectClause.contains('Active__c'),
      'Select clause should contain Active__c'
    );
  }

  /**
   * @description Test getTriggerConfigSelectClause method
   */
  @isTest
  static void testGetTriggerConfigSelectClause() {
    Test.startTest();

    String selectClause = TriggerHandlerConstants.getTriggerConfigSelectClause();

    Test.stopTest();

    System.assertNotEquals(
      null,
      selectClause,
      'Select clause should not be null'
    );
    System.assert(
      selectClause.contains('Id'),
      'Select clause should contain Id'
    );
    System.assert(
      selectClause.contains('Object_API_Name__c'),
      'Select clause should contain Object_API_Name__c'
    );
  }

  /**
   * @description Test buildTriggerActionQuery method
   */
  @isTest
  static void testBuildTriggerActionQuery() {
    Test.startTest();

    String query = TriggerHandlerConstants.buildTriggerActionQuery(
      'Account',
      'Before Insert'
    );

    Test.stopTest();

    System.assertNotEquals(null, query, 'Query should not be null');
    System.assert(query.contains('SELECT'), 'Query should contain SELECT');
    System.assert(
      query.contains('FROM Trigger_Action__mdt'),
      'Query should contain FROM clause'
    );
    System.assert(query.contains('Account'), 'Query should contain Account');
    System.assert(
      query.contains('Before Insert'),
      'Query should contain trigger event'
    );
    System.assert(
      query.contains('Active__c = TRUE'),
      'Query should filter by active'
    );
    System.assert(
      query.contains('ORDER BY'),
      'Query should contain ORDER BY'
    );
  }

  /**
   * @description Test getAllFieldsForMetadataType method
   */
  @isTest
  static void testGetAllFieldsForMetadataType() {
    Test.startTest();

    List<String> fields = TriggerHandlerConstants.getAllFieldsForMetadataType(
      'Trigger_Action__mdt'
    );

    Test.stopTest();

    System.assertNotEquals(null, fields, 'Fields list should not be null');
    System.assert(fields.size() > 0, 'Should return at least some fields');
  }

  /**
   * @description Test getAllFieldsForMetadataType with invalid type
   */
  @isTest
  static void testGetAllFieldsForInvalidMetadataType() {
    Test.startTest();

    List<String> fields = TriggerHandlerConstants.getAllFieldsForMetadataType(
      'NonExistentType__mdt'
    );

    Test.stopTest();

    System.assertNotEquals(null, fields, 'Should return empty list, not null');
    System.assertEquals(
      0,
      fields.size(),
      'Should return empty list for invalid type'
    );
  }

  /**
   * @description Test constant values are properly defined
   */
  @isTest
  static void testConstantValues() {
    Test.startTest();

    // Verify configuration constants
    System.assertEquals(
      5,
      TriggerHandlerConstants.MAX_HANDLER_EXECUTIONS,
      'Max executions should be 5'
    );
    System.assertEquals(
      999999,
      TriggerHandlerConstants.DEFAULT_LOAD_ORDER,
      'Default load order should be 999999'
    );
    System.assertEquals(
      '_',
      TriggerHandlerConstants.HANDLER_KEY_SEPARATOR,
      'Handler key separator should be underscore'
    );
    System.assertEquals(
      '.',
      TriggerHandlerConstants.METHOD_KEY_SEPARATOR,
      'Method key separator should be dot'
    );

    // Verify message constants exist
    System.assertNotEquals(
      null,
      TriggerHandlerConstants.MSG_BYPASS_ALL,
      'Bypass all message should exist'
    );
    System.assertNotEquals(
      null,
      TriggerHandlerConstants.MSG_VALIDATION_REQUIRED_FIELD,
      'Required field message should exist'
    );
    System.assertNotEquals(
      null,
      TriggerHandlerConstants.HANDLER_CLASS_NOT_FOUND,
      'Handler not found message should exist'
    );

    Test.stopTest();
  }

  /**
   * @description Test field list constants
   */
  @isTest
  static void testFieldListConstants() {
    Test.startTest();

    // Verify TRIGGER_ACTION_FIELDS
    System.assertNotEquals(
      null,
      TriggerHandlerConstants.TRIGGER_ACTION_FIELDS,
      'Trigger action fields should be defined'
    );
    System.assert(
      TriggerHandlerConstants.TRIGGER_ACTION_FIELDS.size() > 0,
      'Should have at least one field'
    );
    System.assert(
      TriggerHandlerConstants.TRIGGER_ACTION_FIELDS.contains('Id'),
      'Should contain Id field'
    );

    // Verify TRIGGER_CONFIG_FIELDS
    System.assertNotEquals(
      null,
      TriggerHandlerConstants.TRIGGER_CONFIG_FIELDS,
      'Trigger config fields should be defined'
    );
    System.assert(
      TriggerHandlerConstants.TRIGGER_CONFIG_FIELDS.size() > 0,
      'Should have at least one field'
    );
    System.assert(
      TriggerHandlerConstants.TRIGGER_CONFIG_FIELDS.contains('Id'),
      'Should contain Id field'
    );

    Test.stopTest();
  }

  /**
   * @description Test formatMessage with null values in parameters
   */
  @isTest
  static void testFormatMessageWithNullParams() {
    Test.startTest();

    String message = TriggerHandlerConstants.formatMessage(
      'Handler {0} failed with error {1}',
      new List<String>{ 'TestHandler', null }
    );

    Test.stopTest();

    System.assert(
      message.contains('TestHandler'),
      'Should contain non-null parameter'
    );
    System.assert(
      !message.contains('null'),
      'Should handle null parameter gracefully'
    );
  }

  /**
   * @description Test formatMessage with special characters
   */
  @isTest
  static void testFormatMessageWithSpecialCharacters() {
    Test.startTest();

    String message = TriggerHandlerConstants.formatMessage(
      'Handler {0} with message: {1}',
      new List<String>{ 'Test\'Handler', 'Error: "Invalid data"' }
    );

    Test.stopTest();

    System.assert(
      message.contains('Test\'Handler'),
      'Should handle single quotes'
    );
    System.assert(
      message.contains('Error: "Invalid data"'),
      'Should handle double quotes'
    );
  }

  /**
   * @description Test createHandlerKey with edge cases
   */
  @isTest
  static void testCreateHandlerKeyEdgeCases() {
    Test.startTest();

    // Test with namespace prefix
    String key1 = TriggerHandlerConstants.createHandlerKey(
      'MyNamespace__Account__c',
      'MyNamespace.AccountHandler'
    );

    // Test with underscores in names
    String key2 = TriggerHandlerConstants.createHandlerKey(
      'Custom_Object__c',
      'Custom_Handler_Class'
    );

    Test.stopTest();

    System.assert(
      key1.contains('MyNamespace__Account__c'),
      'Should handle namespace prefix'
    );
    System.assert(
      key2.contains('Custom_Object__c'),
      'Should handle underscores in object name'
    );
  }

  /**
   * @description Test buildTriggerActionQuery with special characters
   */
  @isTest
  static void testBuildTriggerActionQueryWithSpecialChars() {
    Test.startTest();

    // Test with object name containing special characters
    String query = TriggerHandlerConstants.buildTriggerActionQuery(
      'Custom_Object__c',
      'After Update'
    );

    Test.stopTest();

    System.assert(
      query.contains('Custom_Object__c'),
      'Query should contain custom object name'
    );
    System.assert(
      query.contains('After Update'),
      'Query should contain trigger event'
    );
  }

  /**
   * @description Test message constants for completeness
   */
  @isTest
  static void testAllMessageConstants() {
    Test.startTest();

    // Test that all message constants are non-null and non-empty
    System.assert(
      String.isNotBlank(TriggerHandlerConstants.MSG_BYPASS_ALL),
      'MSG_BYPASS_ALL should not be blank'
    );
    System.assert(
      String.isNotBlank(TriggerHandlerConstants.MSG_BYPASS_OBJECT),
      'MSG_BYPASS_OBJECT should not be blank'
    );
    System.assert(
      String.isNotBlank(TriggerHandlerConstants.MSG_BYPASS_HARD),
      'MSG_BYPASS_HARD should not be blank'
    );
    System.assert(
      String.isNotBlank(TriggerHandlerConstants.MSG_VALIDATION_REQUIRED_FIELD),
      'MSG_VALIDATION_REQUIRED_FIELD should not be blank'
    );
    System.assert(
      String.isNotBlank(TriggerHandlerConstants.HANDLER_CLASS_NOT_FOUND),
      'HANDLER_CLASS_NOT_FOUND should not be blank'
    );
    System.assert(
      String.isNotBlank(TriggerHandlerConstants.HANDLER_MISSING_INTERFACE),
      'HANDLER_MISSING_INTERFACE should not be blank'
    );
    System.assert(
      String.isNotBlank(TriggerHandlerConstants.HANDLER_EXECUTION_ERROR),
      'HANDLER_EXECUTION_ERROR should not be blank'
    );
    System.assert(
      String.isNotBlank(TriggerHandlerConstants.ASYNC_HANDLER_ERROR),
      'ASYNC_HANDLER_ERROR should not be blank'
    );

    Test.stopTest();
  }

  /**
   * @description Test formatMessage with more parameters than placeholders
   */
  @isTest
  static void testFormatMessageExtraParams() {
    Test.startTest();

    String message = TriggerHandlerConstants.formatMessage(
      'Handler {0} failed',
      new List<String>{ 'Handler1', 'ExtraParam', 'AnotherExtra' }
    );

    Test.stopTest();

    System.assert(
      message.contains('Handler1'),
      'Should use first parameter'
    );
    System.assert(
      !message.contains('ExtraParam'),
      'Should ignore extra parameters'
    );
  }

  /**
   * @description Test formatMessage with fewer parameters than placeholders
   */
  @isTest
  static void testFormatMessageFewerParams() {
    Test.startTest();

    String message = TriggerHandlerConstants.formatMessage(
      'Handler {0} failed with {1} and {2}',
      new List<String>{ 'Handler1' }
    );

    Test.stopTest();

    System.assert(
      message.contains('Handler1'),
      'Should use provided parameter'
    );
    System.assert(
      message.contains('{1}'),
      'Should keep unreplaced placeholder'
    );
  }
}

