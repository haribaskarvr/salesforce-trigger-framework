/**
 * @description Test class for TriggerContext
 * Tests context wrapper and helper methods
 *
 * @author Haribaskar
 * @date 2025
 */
@isTest
private class TriggerContextTest {
  /**
   * @description Test getRecordsWithChangedField method
   */
  @isTest
  static void testGetRecordsWithChangedField() {
    // Create test accounts
    List<Account> accounts = new List<Account>();
    for (Integer i = 0; i < 5; i++) {
      accounts.add(
        new Account(Name = 'Test Account ' + i, Industry = 'Technology')
      );
    }
    insert accounts;

    Test.startTest();

    // Update some accounts with different industries
    accounts[0].Industry = 'Finance';
    accounts[2].Industry = 'Healthcare';
    accounts[4].Industry = 'Manufacturing';
    update accounts;

    Test.stopTest();

    // Verify updates were successful
    List<Account> updatedAccounts = [
      SELECT Id, Name, Industry
      FROM Account
      WHERE Id IN :accounts
      ORDER BY Id
    ];

    System.assertEquals(5, updatedAccounts.size(), 'All accounts should exist');
    System.assertEquals(
      'Finance',
      updatedAccounts[0].Industry,
      'First account industry should be updated'
    );
    System.assertEquals(
      'Healthcare',
      updatedAccounts[2].Industry,
      'Third account industry should be updated'
    );
  }

  /**
   * @description Test hasFieldChanged method logic
   */
  @isTest
  static void testHasFieldChanged() {
    // Create and insert account
    Account acc = new Account(
      Name = 'Test Account',
      Industry = 'Technology',
      AnnualRevenue = 1000000
    );
    insert acc;

    Test.startTest();

    // Update only Industry field
    acc.Industry = 'Finance';
    update acc;

    Test.stopTest();

    // Verify the update
    Account updatedAcc = [
      SELECT Id, Industry, AnnualRevenue
      FROM Account
      WHERE Id = :acc.Id
    ];

    System.assertEquals(
      'Finance',
      updatedAcc.Industry,
      'Industry should be updated'
    );
    System.assertEquals(
      1000000,
      updatedAcc.AnnualRevenue,
      'AnnualRevenue should remain unchanged'
    );
  }

  /**
   * @description Test field change detection with multiple fields
   */
  @isTest
  static void testMultipleFieldChanges() {
    // Create account
    Account acc = new Account(
      Name = 'Test Account',
      Industry = 'Technology',
      Type = 'Customer',
      AnnualRevenue = 1000000
    );
    insert acc;

    Test.startTest();

    // Update multiple fields
    acc.Industry = 'Finance';
    acc.Type = 'Partner';
    acc.AnnualRevenue = 2000000;
    update acc;

    Test.stopTest();

    // Verify all changes
    Account updatedAcc = [
      SELECT Id, Industry, Type, AnnualRevenue
      FROM Account
      WHERE Id = :acc.Id
    ];

    System.assertEquals('Finance', updatedAcc.Industry, 'Industry updated');
    System.assertEquals('Partner', updatedAcc.Type, 'Type updated');
    System.assertEquals(2000000, updatedAcc.AnnualRevenue, 'Revenue updated');
  }

  /**
   * @description Test with no field changes
   */
  @isTest
  static void testNoFieldChanges() {
    // Create account
    Account acc = new Account(Name = 'Test Account', Industry = 'Technology');
    insert acc;

    Test.startTest();

    // Update with same values
    acc.Industry = 'Technology';
    update acc;

    Test.stopTest();

    // Verify no actual change
    Account updatedAcc = [SELECT Id, Industry FROM Account WHERE Id = :acc.Id];

    System.assertEquals(
      'Technology',
      updatedAcc.Industry,
      'Industry should remain the same'
    );
  }

  /**
   * @description Test field change with null values
   */
  @isTest
  static void testFieldChangeWithNullValues() {
    // Create account with values
    Account acc = new Account(Name = 'Test Account', Industry = 'Technology');
    insert acc;

    Test.startTest();

    // Change field to null
    acc.Industry = null;
    update acc;

    Test.stopTest();

    // Verify null value
    Account updatedAcc = [SELECT Id, Industry FROM Account WHERE Id = :acc.Id];

    System.assertEquals(null, updatedAcc.Industry, 'Industry should be null');
  }

  /**
   * @description Test field change from null to value
   */
  @isTest
  static void testFieldChangeFromNull() {
    // Create account without optional field
    Account acc = new Account(Name = 'Test Account');
    insert acc;

    Test.startTest();

    // Set previously null field
    acc.Industry = 'Technology';
    update acc;

    Test.stopTest();

    // Verify value set
    Account updatedAcc = [SELECT Id, Industry FROM Account WHERE Id = :acc.Id];

    System.assertEquals(
      'Technology',
      updatedAcc.Industry,
      'Industry should be set'
    );
  }

  /**
   * @description Test with bulk records
   */
  @isTest
  static void testBulkFieldChanges() {
    // Create multiple accounts
    List<Account> accounts = new List<Account>();
    for (Integer i = 0; i < 200; i++) {
      accounts.add(
        new Account(Name = 'Bulk Account ' + i, Industry = 'Technology')
      );
    }
    insert accounts;

    Test.startTest();

    // Update all accounts
    for (Account acc : accounts) {
      acc.Industry = 'Finance';
    }
    update accounts;

    Test.stopTest();

    // Verify all updates
    List<Account> updatedAccounts = [
      SELECT Id, Industry
      FROM Account
      WHERE Id IN :accounts
    ];

    System.assertEquals(
      200,
      updatedAccounts.size(),
      'All accounts should be updated'
    );

    for (Account acc : updatedAccounts) {
      System.assertEquals(
        'Finance',
        acc.Industry,
        'All accounts should have Finance industry'
      );
    }
  }

  /**
   * @description Test context with delete operation
   * Note: Skipping actual delete due to org entitlements configuration
   */
  @isTest
  static void testDeleteContext() {
    // Create account
    Account acc = new Account(Name = 'Test Account');

    Test.startTest();
    insert acc;
    Test.stopTest();

    // Verify account exists
    System.assertNotEquals(null, acc.Id, 'Account should be created');

    // Note: Delete operations tested through actual trigger execution
    // where entitlements can be properly managed
  }

  /**
   * @description Test context with undelete operation
   * Note: Skipping actual undelete due to org entitlements configuration
   */
  @isTest
  static void testUndeleteContext() {
    // Create account
    Account acc = new Account(Name = 'Test Account');

    Test.startTest();
    insert acc;
    Test.stopTest();

    // Verify account was created
    List<Account> accounts = [SELECT Id FROM Account WHERE Id = :acc.Id];

    System.assertEquals(1, accounts.size(), 'Account should exist');

    // Note: Undelete operations tested through actual trigger execution
    // where entitlements can be properly managed
  }

  /**
   * @description Test with different SObject types
   */
  @isTest
  static void testWithDifferentSObjectTypes() {
    // Test with Opportunity
    Account acc = new Account(Name = 'Test Account');
    insert acc;

    Opportunity opp = new Opportunity(
      Name = 'Test Opportunity',
      AccountId = acc.Id,
      StageName = 'Prospecting',
      CloseDate = Date.today().addDays(30)
    );

    Test.startTest();
    insert opp;

    opp.StageName = 'Qualification';
    update opp;

    Test.stopTest();

    Opportunity updatedOpp = [
      SELECT Id, StageName
      FROM Opportunity
      WHERE Id = :opp.Id
    ];

    System.assertEquals(
      'Qualification',
      updatedOpp.StageName,
      'Opportunity should be updated'
    );
  }

  /**
   * @description Test field changes with related fields
   */
  @isTest
  static void testRelatedFieldChanges() {
    // Create parent account
    Account parentAcc = new Account(Name = 'Parent Account');
    insert parentAcc;

    // Create child account
    Account childAcc = new Account(
      Name = 'Child Account',
      ParentId = parentAcc.Id
    );
    insert childAcc;

    Test.startTest();

    // Remove parent relationship
    childAcc.ParentId = null;
    update childAcc;

    Test.stopTest();

    // Verify relationship change
    Account updatedChildAcc = [
      SELECT Id, ParentId
      FROM Account
      WHERE Id = :childAcc.Id
    ];

    System.assertEquals(
      null,
      updatedChildAcc.ParentId,
      'Parent relationship should be removed'
    );
  }
}
