/**
 * /**
 * Represents the Case object to be escalated.
 * @description Represents the Case object to be escalated.
 * @description: After a case is escalated, schedule an Apex job to perform certain actions on the case after a delay of 9 hours.
 * @Author: Subba Reddy
 * @Last Modified By: Subba Reddy
 * @Last Modified On: 28/04/2023
 * @Modification Log:
 * Ver    Date            Author             Last Modification
 * 1.0    26/04/2023      Subba Reddy        Initial Version
 **/
public with Sharing class CaseEscalation implements System.Schedulable {
    /**
     * Represents the Case object to be escalated.
     * @description Represents the Case object to be escalated.
     **/
    private Case newListCase;
    /**
     * Represents the Id of the case to be escalated.
     * @description Represents the Id of the case to be escalated.
     **/
    private Id caseId;
    /**
     * @description Constructor for the CaseEscalation class.
     * @param newListCase The Case object to be escalated.
     * @param caseId The Id of the case to be escalated.
     **/
    public CaseEscalation(Case newListCase, Id caseId) {
        this.newListCase = newListCase;
        this.caseId = caseId;
    }
    
    /**
     * @description This method executes when the scheduled job is run.
     * It escalates the case to a specified queue if it's not already escalated.
     * @param sc The SchedulableContext object.
     **/
    public void execute(SchedulableContext sc) {
        // Check CRUD permissions before performing the SOQL and DML operations.
        if (!Schema.sObjectType.Case.isUpdateable()) {
            return;
        }
        
        // A SOQL query retrieves a single Case record based on the provided caseId.
        Case c = [SELECT Id, Status, OwnerId, CreatedDate FROM Case WHERE Id = :caseId AND Status != 'Escalated' WITH SECURITY_ENFORCED LIMIT 1];
        
        // If a case is found and it's not already escalated, the code proceeds to escalate the case.
        if (c == null) {
            return; // No case found to escalate.
        }
        
        // Get the queue Id for assigning new escalated cases.
        Group escalatedQueue = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Escalated or Urgent Case Team' WITH SECURITY_ENFORCED LIMIT 1];
        
        // If the escalated queue is not found, exit.
        if (escalatedQueue == null) {
            return;
        }
        
        // Update the case to escalate it.
        c.OwnerId = escalatedQueue.Id;
        c.IsEscalated = true;
        c.Status = 'Escalated';
        
        // Save the updated case if the user has the necessary permissions.
        if (Schema.sObjectType.Case.isUpdateable()) {
            update c;
        }
    }
}