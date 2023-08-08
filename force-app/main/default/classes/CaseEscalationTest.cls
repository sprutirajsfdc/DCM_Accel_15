@isTest
public class CaseEscalationTest {

    @isTest
    public static void testCaseEscalation() {
        // Create a test Case
        Case testCase = new Case(Status = 'New', Subject = 'Test Case', Description = 'Test Description');
        insert testCase;

        // Create an escalated queue for testing
        Group escalatedQueue = new Group(Name = 'Escalated or Urgent Case Team', Type = 'Queue');
        insert escalatedQueue;

        // Schedule the job to escalate the test Case
        Test.startTest();
        CaseEscalation escJob = new CaseEscalation(testCase, testCase.Id);
        System.schedule('Test Case Escalation', '0 0 9 * * ?', escJob);
        Test.stopTest();

        // Wait for the job to execute (using System.schedule, the job executes synchronously)
        Case escalatedCase = [SELECT Id, OwnerId, Status, IsEscalated FROM Case WHERE Id = :testCase.Id];

        // Assert that the case is escalated and assigned to the escalated queue
        System.assertEquals(true, escalatedCase.IsEscalated, 'Case should be escalated.');
        System.assertEquals('Escalated', escalatedCase.Status, 'Case status should be Escalated.');
        System.assertEquals(escalatedQueue.Id, escalatedCase.OwnerId, 'Case should be assigned to the escalated queue.');
    }
}