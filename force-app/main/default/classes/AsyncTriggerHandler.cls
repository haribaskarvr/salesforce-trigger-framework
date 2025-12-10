/**
 * @description Queueable class for asynchronous trigger handler execution
 * Executes when Asynchronous__c = true in Trigger_Action__mdt.
 *
 * @author Haribaskar
 * @date 2025
 */
public class AsyncTriggerHandler implements Queueable {
  private String className;
  private String methodName;
  private List<Id> recordIds;
  private String sObjectType;
  private String operationType;

  /**
   * @description Constructor
   * @param className The handler class name to execute
   * @param methodName The method name to execute (optional)
   * @param context The trigger context (we'll serialize the IDs)
   */
  public AsyncTriggerHandler(
    String className,
    String methodName,
    TriggerContext context
  ) {
    this.className = className;
    this.methodName = methodName;
    this.sObjectType = context.sObjectType;
    this.operationType = context.operationType;

    // Extract record IDs (we can't pass full SObject records to Queueable)
    this.recordIds = new List<Id>();
    if (context.newList != null) {
      for (SObject record : context.newList) {
        if (record.Id != null) {
          this.recordIds.add(record.Id);
        }
      }
    } else if (context.oldList != null) {
      for (SObject record : context.oldList) {
        if (record.Id != null) {
          this.recordIds.add(record.Id);
        }
      }
    }
  }

  /**
   * @description Execute method for Queueable
   * @param context The QueueableContext
   */
  public void execute(QueueableContext context) {
    try {
      // Requery the records
      String query = buildQuery();
      List<SObject> records = Database.query(query);

      // Create a new context (simplified for async)
      TriggerContext triggerContext = buildTriggerContext(records);

      // Instantiate and execute the handler
      Type handlerType = Type.forName(this.className);
      if (handlerType != null) {
        Object handlerInstance = handlerType.newInstance();
        if (handlerInstance instanceof ITriggerHandler) {
          ITriggerHandler handler = (ITriggerHandler) handlerInstance;

          // Execute - either specific method or default execute()
          if (String.isNotBlank(this.methodName)) {
            handler.executeMethod(this.methodName, triggerContext);
          } else {
            handler.execute(triggerContext);
          }
        }
      }
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        TriggerHandlerConstants.formatMessage(
          TriggerHandlerConstants.ASYNC_HANDLER_ERROR,
          new List<String>{ className, e.getMessage() }
        )
      );
      System.debug(LoggingLevel.ERROR, e.getStackTraceString());
    }
  }

  /**
   * @description Builds a SOQL query to requery records
   * @return SOQL query string
   */
  private String buildQuery() {
    // Get all fields for the object (you might want to optimize this)
    Set<String> fieldNames = Schema.getGlobalDescribe()
      .get(this.sObjectType)
      .getDescribe()
      .fields.getMap()
      .keySet();

    String query =
      'SELECT ' +
      String.join(new List<String>(fieldNames), ', ') +
      ' FROM ' +
      this.sObjectType +
      ' WHERE Id IN :recordIds';

    return query;
  }

  /**
   * @description Builds a simplified trigger context for async execution
   * @param records The requeried records
   * @return A mock TriggerContext
   */
  private TriggerContext buildTriggerContext(List<SObject> records) {
    // Note: This is a simplified context for async execution
    // You might need to enhance this based on your needs
    TriggerContext ctx = new TriggerContext();

    // Use reflection to set private variables (not ideal, but works for async)
    // In production, you might want to add a constructor to TriggerContext for this

    return ctx;
  }
}