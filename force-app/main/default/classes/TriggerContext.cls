/**
 * @description Wrapper class that encapsulates all trigger context variables
 * Provides clean interface for trigger handlers without directly referencing Trigger.* variables.
 *
 * @author Haribaskar
 * @date 2025
 */
public class TriggerContext {
  public List<SObject> newList { get; private set; }
  public List<SObject> oldList { get; private set; }
  public Map<Id, SObject> newMap { get; private set; }
  public Map<Id, SObject> oldMap { get; private set; }

  public Boolean isExecuting { get; private set; }
  public Boolean isBefore { get; private set; }
  public Boolean isAfter { get; private set; }
  public Boolean isInsert { get; private set; }
  public Boolean isUpdate { get; private set; }
  public Boolean isDelete { get; private set; }
  public Boolean isUndelete { get; private set; }

  public Integer size { get; private set; }
  public String sObjectType { get; private set; }
  public String operationType { get; private set; }

  /**
   * @description Constructor that captures all trigger context variables
   */
  public TriggerContext() {
    this.newList = Trigger.new;
    this.oldList = Trigger.old;
    this.newMap = Trigger.newMap;
    this.oldMap = Trigger.oldMap;

    this.isExecuting = Trigger.isExecuting;
    this.isBefore = Trigger.isBefore;
    this.isAfter = Trigger.isAfter;
    this.isInsert = Trigger.isInsert;
    this.isUpdate = Trigger.isUpdate;
    this.isDelete = Trigger.isDelete;
    this.isUndelete = Trigger.isUndelete;

    this.size = Trigger.size;

    // Determine sObject type
    if (this.newList != null && !this.newList.isEmpty()) {
      this.sObjectType = String.valueOf(this.newList[0].getSObjectType());
    } else if (this.oldList != null && !this.oldList.isEmpty()) {
      this.sObjectType = String.valueOf(this.oldList[0].getSObjectType());
    }

    // Determine operation type
    this.operationType = getOperationType();
  }

  /**
   * @description Gets the current operation type as a string
   * @return String representation of the trigger operation (e.g., 'BeforeInsert')
   */
  private String getOperationType() {
    if (this.isBefore && this.isInsert)
      return 'BeforeInsert';
    if (this.isBefore && this.isUpdate)
      return 'BeforeUpdate';
    if (this.isBefore && this.isDelete)
      return 'BeforeDelete';
    if (this.isAfter && this.isInsert)
      return 'AfterInsert';
    if (this.isAfter && this.isUpdate)
      return 'AfterUpdate';
    if (this.isAfter && this.isDelete)
      return 'AfterDelete';
    if (this.isAfter && this.isUndelete)
      return 'AfterUndelete';
    return null;
  }

  /**
   * @description Helper method to get records where a specific field changed
   * @param fieldName The API name of the field to check
   * @return List of records where the field value changed
   */
  public List<SObject> getRecordsWithChangedField(String fieldName) {
    List<SObject> changedRecords = new List<SObject>();

    if (this.isUpdate && this.newList != null && this.oldMap != null) {
      for (SObject newRecord : this.newList) {
        SObject oldRecord = this.oldMap.get(newRecord.Id);
        if (
          oldRecord != null &&
          newRecord.get(fieldName) != oldRecord.get(fieldName)
        ) {
          changedRecords.add(newRecord);
        }
      }
    }

    return changedRecords;
  }

  /**
   * @description Helper method to check if a specific field changed for a record
   * @param recordId The Id of the record to check
   * @param fieldName The API name of the field to check
   * @return True if the field changed, false otherwise
   */
  public Boolean hasFieldChanged(Id recordId, String fieldName) {
    if (this.isUpdate && this.newMap != null && this.oldMap != null) {
      SObject newRecord = this.newMap.get(recordId);
      SObject oldRecord = this.oldMap.get(recordId);

      if (newRecord != null && oldRecord != null) {
        return newRecord.get(fieldName) != oldRecord.get(fieldName);
      }
    }
    return false;
  }
}