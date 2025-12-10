/**
 * @description Utility class for common trigger handler operations
 *
 * @author Haribaskar
 * @date 2025
 */
public class TriggerHandlerUtils {
  /**
   * @description Gets a set of record IDs from a list of SObjects
   * @param records List of SObject records
   * @return Set of record IDs
   */
  public static Set<Id> getRecordIds(List<SObject> records) {
    Set<Id> recordIds = new Set<Id>();
    if (records != null) {
      for (SObject record : records) {
        if (record.Id != null) {
          recordIds.add(record.Id);
        }
      }
    }
    return recordIds;
  }

  /**
   * @description Gets a set of values for a specific field from records
   * @param records List of SObject records
   * @param fieldName The field API name
   * @return Set of field values
   */
  public static Set<Object> getFieldValues(
    List<SObject> records,
    String fieldName
  ) {
    Set<Object> values = new Set<Object>();
    if (records != null && String.isNotBlank(fieldName)) {
      for (SObject record : records) {
        Object fieldValue = record.get(fieldName);
        if (fieldValue != null) {
          values.add(fieldValue);
        }
      }
    }
    return values;
  }

  /**
   * @description Gets a set of String values for a specific field
   * @param records List of SObject records
   * @param fieldName The field API name
   * @return Set of String field values
   */
  public static Set<String> getStringFieldValues(
    List<SObject> records,
    String fieldName
  ) {
    Set<String> values = new Set<String>();
    if (records != null && String.isNotBlank(fieldName)) {
      for (SObject record : records) {
        Object fieldValue = record.get(fieldName);
        if (fieldValue != null) {
          values.add(String.valueOf(fieldValue));
        }
      }
    }
    return values;
  }

  /**
   * @description Gets a set of Id values for a specific field (e.g., lookup fields)
   * @param records List of SObject records
   * @param fieldName The field API name
   * @return Set of Id field values
   */
  public static Set<Id> getIdFieldValues(
    List<SObject> records,
    String fieldName
  ) {
    Set<Id> values = new Set<Id>();
    if (records != null && String.isNotBlank(fieldName)) {
      for (SObject record : records) {
        Id fieldValue = (Id) record.get(fieldName);
        if (fieldValue != null) {
          values.add(fieldValue);
        }
      }
    }
    return values;
  }

  /**
   * @description Filters records where a specific field has changed
   * @param newRecords Map of new records
   * @param oldRecords Map of old records
   * @param fieldName The field to check
   * @return List of records where the field changed
   */
  public static List<SObject> filterByFieldChange(
    Map<Id, SObject> newRecords,
    Map<Id, SObject> oldRecords,
    String fieldName
  ) {
    List<SObject> changedRecords = new List<SObject>();

    if (
      newRecords != null &&
      oldRecords != null &&
      String.isNotBlank(fieldName)
    ) {
      for (Id recordId : newRecords.keySet()) {
        SObject newRecord = newRecords.get(recordId);
        SObject oldRecord = oldRecords.get(recordId);

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
   * @description Checks if any of the specified fields changed
   * @param newRecord The new version of the record
   * @param oldRecord The old version of the record
   * @param fieldNames Set of field names to check
   * @return True if any field changed
   */
  public static Boolean hasAnyFieldChanged(
    SObject newRecord,
    SObject oldRecord,
    Set<String> fieldNames
  ) {
    if (
      newRecord == null ||
      oldRecord == null ||
      fieldNames == null ||
      fieldNames.isEmpty()
    ) {
      return false;
    }

    for (String fieldName : fieldNames) {
      if (newRecord.get(fieldName) != oldRecord.get(fieldName)) {
        return true;
      }
    }

    return false;
  }

  /**
   * @description Groups records by a specific field value
   * @param records List of SObject records
   * @param fieldName The field to group by
   * @return Map of field value to list of records
   */
  public static Map<Object, List<SObject>> groupByField(
    List<SObject> records,
    String fieldName
  ) {
    Map<Object, List<SObject>> groupedRecords = new Map<Object, List<SObject>>();

    if (records != null && String.isNotBlank(fieldName)) {
      for (SObject record : records) {
        Object fieldValue = record.get(fieldName);

        if (!groupedRecords.containsKey(fieldValue)) {
          groupedRecords.put(fieldValue, new List<SObject>());
        }

        groupedRecords.get(fieldValue).add(record);
      }
    }

    return groupedRecords;
  }

  /**
   * @description Adds an error to records based on a condition
   * @param records List of records to validate
   * @param fieldName The field to add the error to (null for record-level error)
   * @param errorMessage The error message
   * @param condition The condition that triggers the error
   */
  public static void addErrorIf(
    List<SObject> records,
    String fieldName,
    String errorMessage,
    ICondition condition
  ) {
    if (
      records != null &&
      condition != null &&
      String.isNotBlank(errorMessage)
    ) {
      for (SObject record : records) {
        if (condition.evaluate(record)) {
          if (String.isNotBlank(fieldName)) {
            record.addError(fieldName, errorMessage);
          } else {
            record.addError(errorMessage);
          }
        }
      }
    }
  }

  /**
   * @description Interface for condition evaluation
   */
  public interface ICondition {
    Boolean evaluate(SObject record);
  }

  /**
   * @description Logs debug information about trigger context
   * @param context The trigger context
   * @param handlerName The name of the handler for identification
   */
  public static void logContext(TriggerContext context, String handlerName) {
    System.debug('========== ' + handlerName + ' ==========');
    System.debug('Operation: ' + context.operationType);
    System.debug('Object: ' + context.sObjectType);
    System.debug('Record Count: ' + context.size);
    System.debug('Is Before: ' + context.isBefore);
    System.debug('Is After: ' + context.isAfter);
    System.debug('=======================================');
  }

  /**
   * @description Creates a map from a field value to the record
   * @param records List of records
   * @param fieldName The field to use as the key
   * @return Map of field value to record
   */
  public static Map<String, SObject> createMapByStringField(
    List<SObject> records,
    String fieldName
  ) {
    Map<String, SObject> recordMap = new Map<String, SObject>();

    if (records != null && String.isNotBlank(fieldName)) {
      for (SObject record : records) {
        Object fieldValue = record.get(fieldName);
        if (fieldValue != null) {
          recordMap.put(String.valueOf(fieldValue), record);
        }
      }
    }

    return recordMap;
  }

  /**
   * @description Checks if the current user has a specific profile
   * @param profileName The profile name to check
   * @return True if user has the profile
   */
  public static Boolean hasProfile(String profileName) {
    return UserInfo.getProfileId() ==
      [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1]
      ?.Id;
  }

  /**
   * @description Checks if the current user has a specific permission set
   * @param permissionSetName The permission set API name
   * @return True if user has the permission set
   */
  public static Boolean hasPermissionSet(String permissionSetName) {
    Integer count = [
      SELECT COUNT()
      FROM PermissionSetAssignment
      WHERE
        AssigneeId = :UserInfo.getUserId()
        AND PermissionSet.Name = :permissionSetName
    ];
    return count > 0;
  }
}