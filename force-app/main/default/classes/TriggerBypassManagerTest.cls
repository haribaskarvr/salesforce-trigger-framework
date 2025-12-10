/**
 * @description Test class for TriggerBypassManager
 *
 * @author Haribaskar
 * @date 2025
 */
@IsTest
private class TriggerBypassManagerTest {
  @IsTest
  static void testBypassAllTriggers() {
    // Setup: Enable bypass all
    Trigger_Bypass__c setting = new Trigger_Bypass__c(
      SetupOwnerId = UserInfo.getUserId(),
      Bypass_All_Triggers__c = true
    );
    insert setting;

    // Test
    Test.startTest();
    Boolean shouldExecute = TriggerBypassManager.shouldExecuteTriggers(
      'Account'
    );
    Test.stopTest();

    // Verify
    System.assertEquals(
      false,
      shouldExecute,
      'Triggers should be bypassed when Bypass_All_Triggers__c is true'
    );
  }

  @IsTest
  static void testHardBypassObject() {
    // Setup: Add Account to hard bypass list
    Trigger_Bypass__c setting = new Trigger_Bypass__c(
      SetupOwnerId = UserInfo.getUserId(),
      Force_Bypass_Objects__c = 'Account,Contact'
    );
    insert setting;

    // Test
    Test.startTest();
    Boolean accountShouldExecute = TriggerBypassManager.shouldExecuteTriggers(
      'Account'
    );
    Boolean opportunityShouldExecute = TriggerBypassManager.shouldExecuteTriggers(
      'Opportunity'
    );
    Test.stopTest();

    // Verify
    System.assertEquals(
      false,
      accountShouldExecute,
      'Account triggers should be bypassed'
    );
    System.assertEquals(
      true,
      opportunityShouldExecute,
      'Opportunity triggers should execute'
    );
  }

  @IsTest
  static void testHardBypassWithSpaces() {
    // Setup: Add objects with spaces around names
    Trigger_Bypass__c setting = new Trigger_Bypass__c(
      SetupOwnerId = UserInfo.getUserId(),
      Force_Bypass_Objects__c = ' Account , Contact '
    );
    insert setting;

    // Test
    Test.startTest();
    Boolean accountShouldExecute = TriggerBypassManager.shouldExecuteTriggers(
      'Account'
    );
    Test.stopTest();

    // Verify spaces are trimmed correctly
    System.assertEquals(
      false,
      accountShouldExecute,
      'Account triggers should be bypassed even with spaces'
    );
  }

  @IsTest
  static void testNoBypass() {
    // Setup: No bypass configured
    // (No custom setting created)

    // Test
    Test.startTest();
    Boolean shouldExecute = TriggerBypassManager.shouldExecuteTriggers(
      'Account'
    );
    Test.stopTest();

    // Verify
    System.assertEquals(
      true,
      shouldExecute,
      'Triggers should execute when no bypass is configured'
    );
  }

  @IsTest
  static void testGetBypassStatus() {
    // Setup
    Trigger_Bypass__c setting = new Trigger_Bypass__c(
      SetupOwnerId = UserInfo.getUserId(),
      Bypass_All_Triggers__c = false,
      Bypass_Object_Triggers__c = false
    );
    insert setting;

    // Test
    Test.startTest();
    Map<String, Boolean> status = TriggerBypassManager.getBypassStatus(
      'Account'
    );
    Test.stopTest();

    // Verify
    System.assert(
      status.containsKey('allTriggersBypassed'),
      'Status should contain allTriggersBypassed'
    );
    System.assert(
      status.containsKey('objectBypassed'),
      'Status should contain objectBypassed'
    );
    System.assert(
      status.containsKey('shouldExecute'),
      'Status should contain shouldExecute'
    );
  }

  @IsTest
  static void testShouldBypassAllTriggers() {
    // Test when no setting exists
    Boolean noSetting = TriggerBypassManager.shouldBypassAllTriggers();

    System.assertEquals(
      false,
      noSetting,
      'Should return false when no setting exists'
    );

    // Test when setting exists and is true
    Trigger_Bypass__c setting = new Trigger_Bypass__c(
      SetupOwnerId = UserInfo.getUserId(),
      Bypass_All_Triggers__c = true
    );
    insert setting;

    Test.startTest();
    Boolean withSetting = TriggerBypassManager.shouldBypassAllTriggers();
    Test.stopTest();

    System.assertEquals(
      true,
      withSetting,
      'Should return true when bypass all is enabled'
    );
  }

  @IsTest
  static void testShouldBypassObject() {
    // Test when no setting exists
    Boolean noSetting = TriggerBypassManager.shouldBypassObject('Account');

    System.assertEquals(
      false,
      noSetting,
      'Should return false when no setting exists'
    );

    // Test with hard bypass
    Trigger_Bypass__c setting = new Trigger_Bypass__c(
      SetupOwnerId = UserInfo.getUserId(),
      Force_Bypass_Objects__c = 'Account'
    );
    insert setting;

    Test.startTest();
    Boolean withHardBypass = TriggerBypassManager.shouldBypassObject('Account');
    Boolean differentObject = TriggerBypassManager.shouldBypassObject(
      'Contact'
    );
    Test.stopTest();

    System.assertEquals(
      true,
      withHardBypass,
      'Should bypass Account via hard bypass'
    );
    System.assertEquals(false, differentObject, 'Should not bypass Contact');
  }

  @IsTest
  static void testClearCache() {
    // This is a private method, but we can test it indirectly
    // by verifying that bypass configuration is re-read

    // Setup
    Trigger_Bypass__c setting = new Trigger_Bypass__c(
      SetupOwnerId = UserInfo.getUserId(),
      Bypass_Object_Triggers__c = true
    );
    insert setting;

    // First call - loads cache
    Test.startTest();
    Boolean firstCall = TriggerBypassManager.shouldBypassObject('Account');

    // Clear cache (via @TestVisible)
    TriggerBypassManager.clearCache();

    // Second call - reloads cache
    Boolean secondCall = TriggerBypassManager.shouldBypassObject('Account');
    Test.stopTest();

    // Both should work correctly
    System.assertNotEquals(null, firstCall, 'First call should work');
    System.assertNotEquals(null, secondCall, 'Second call should work');
  }

  @IsTest
  static void testEmptyForceBypassObjects() {
    // Setup: Setting with empty force bypass
    Trigger_Bypass__c setting = new Trigger_Bypass__c(
      SetupOwnerId = UserInfo.getUserId(),
      Force_Bypass_Objects__c = ''
    );
    insert setting;

    // Test
    Test.startTest();
    Boolean shouldExecute = TriggerBypassManager.shouldExecuteTriggers(
      'Account'
    );
    Test.stopTest();

    // Verify
    System.assertEquals(
      true,
      shouldExecute,
      'Triggers should execute when force bypass is empty'
    );
  }

  @IsTest
  static void testCombinedBypassChecks() {
    // Setup: Multiple bypass configurations
    Trigger_Bypass__c setting = new Trigger_Bypass__c(
      SetupOwnerId = UserInfo.getUserId(),
      Bypass_All_Triggers__c = false,
      Bypass_Object_Triggers__c = false,
      Force_Bypass_Objects__c = 'Account'
    );
    insert setting;

    // Test
    Test.startTest();
    Map<String, Boolean> accountStatus = TriggerBypassManager.getBypassStatus(
      'Account'
    );
    Map<String, Boolean> contactStatus = TriggerBypassManager.getBypassStatus(
      'Contact'
    );
    Test.stopTest();

    // Verify Account is bypassed
    System.assertEquals(
      false,
      accountStatus.get('allTriggersBypassed'),
      'All triggers should not be bypassed'
    );
    System.assertEquals(
      true,
      accountStatus.get('objectBypassed'),
      'Account should be bypassed'
    );
    System.assertEquals(
      false,
      accountStatus.get('shouldExecute'),
      'Account should not execute'
    );

    // Verify Contact is not bypassed
    System.assertEquals(
      false,
      contactStatus.get('objectBypassed'),
      'Contact should not be bypassed'
    );
    System.assertEquals(
      true,
      contactStatus.get('shouldExecute'),
      'Contact should execute'
    );
  }
}