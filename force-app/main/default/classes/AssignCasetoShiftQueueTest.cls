@isTest
public class AssignCasetoShiftQueueTest {

    @isTest
    static void testQueueAssignmentBasedOnTime() {
        // Create and insert Morning, Afternoon, and Night Shift queues
        Group morningShiftQueue = new Group(Type = 'Queue', Name = 'Morning Shift');
        Group afternoonShiftQueue = new Group(Type = 'Queue', Name = 'Afternoon Shift');
        Group nightShiftQueue = new Group(Type = 'Queue', Name = 'Night Shift');
        insert new List<Group>{ morningShiftQueue, afternoonShiftQueue, nightShiftQueue };

        // Create and insert ShiftTime__c record
        ShiftTime__c shiftTimes = new ShiftTime__c(
            Shift1StartTime__c = '08:00',
            Shift2StartTime__c = '16:00',
            Shift3StartTime__c = '00:00'
        );
        insert shiftTimes;

        // Mock the current time for Morning Shift
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('/apex/SomePage'));
        Test.setCurrentPage(DateTime.newInstanceGmt(2023, 8, 8, 10, 0, 0)); // Set the time to simulate Morning Shift
        List<Case> caseList = new List<Case>{
            new Case(Priority = 'Low'),
            new Case(Priority = 'Medium')
        };
        AssignCasetoShiftQueue.casetoshiftqueue(caseList);
        Test.stopTest();

        List<Case> morningCases = [SELECT Id, Initial_Shift_Name__c FROM Case WHERE Initial_Shift_Name__c = 'Morning Shift'];
        System.assertEquals(2, morningCases.size(),'morning shift');

        // Mock the current time for Afternoon Shift
        Test.startTest();
        Test.setCurrentPage(DateTime.newInstanceGmt(2023, 8, 8, 18, 0, 0)); // Set the time to simulate Afternoon Shift
        caseList.clear();
        caseList.addAll(new List<Case>{
            new Case(Priority = 'Low'),
            new Case(Priority = 'Medium')
        });
        AssignCasetoShiftQueue.casetoshiftqueue(caseList);
        Test.stopTest();

        List<Case> afternoonCases = [SELECT Id, Initial_Shift_Name__c FROM Case WHERE Initial_Shift_Name__c = 'Afternoon Shift'];
        System.assertEquals(2, afternoonCases.size(),'some page ref');

        // Mock the current time for Night Shift
        Test.startTest();
        Test.setCurrentPage(DateTime.newInstanceGmt(2023, 8, 9, 2, 0, 0)); // Set the time to simulate Night Shift
        caseList.clear();
        caseList.addAll(new List<Case>{
            new Case(Priority = 'Low'),
            new Case(Priority = 'Medium')
        });
        AssignCasetoShiftQueue.casetoshiftqueue(caseList);
        Test.stopTest();

        List<Case> nightCases = [SELECT Id, Initial_Shift_Name__c FROM Case WHERE Initial_Shift_Name__c = 'Night Shift'];
        System.assertEquals(2, nightCases.size(),'inittal shift Time');
    }

    @isTest
    static void testAssigningToMorningShift() {
        // Create and insert Morning Shift queue
        Group morningShiftQueue = new Group(Type = 'Queue', Name = 'Morning Shift');
        insert morningShiftQueue;

        // Create a case that should be assigned to Morning Shift
        Case c = new Case(Priority = 'Low');
        insert c;

        // Set the current time to simulate Morning Shift
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('/apex/SomePage'));
        Test.setCurrentPage(DateTime.newInstanceGmt(2023, 8, 8, 9, 0, 0)); // Set the time to simulate Morning Shift

        AssignCasetoShiftQueue.casetoshiftqueue(new List<Case>{c});
        Test.stopTest();

        c = [SELECT Id, OwnerId FROM Case WHERE Id = :c.Id];
        System.assertEquals(morningShiftQueue.Id, c.OwnerId, 'Case was not assigned to the Morning Shift queue.');
        System.assertEquals('Morning Shift', c.Initial_Shift_Name__c,c.OwnerId); // Line 58
    }

    @isTest
    static void testAssigningToAfternoonShift() {
        // Create and insert Afternoon Shift queue
        Group afternoonShiftQueue = new Group(Type = 'Queue', Name = 'Afternoon Shift');
        insert afternoonShiftQueue;

        // Create a case that should be assigned to Afternoon Shift
        Case c = new Case(Priority = 'Low');
        insert c;

        // Set the current time to simulate Afternoon Shift
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('/apex/SomePage'));
        Test.setCurrentPage(DateTime.newInstanceGmt(2023, 8, 8, 14, 0, 0)); // Set the time to simulate Afternoon Shift

        AssignCasetoShiftQueue.casetoshiftqueue(new List<Case>{c});
        Test.stopTest();

        c = [SELECT Id, OwnerId FROM Case WHERE Id = :c.Id];
        System.assertEquals(afternoonShiftQueue.Id, c.OwnerId, 'Case was not assigned to the Afternoon Shift queue.');
        System.assertEquals('Afternoon Shift', c.Initial_Shift_Name__c,c.OwnerId); // Line 70
    }

    @isTest
    static void testAssigningToNightShift() {
        // Create and insert Night Shift queue
        Group nightShiftQueue = new Group(Type = 'Queue', Name = 'Night Shift');
        insert nightShiftQueue;

        // Create a case that should be assigned to Night Shift
        Case c = new Case(Priority = 'Low');
        insert c;

        // Set the current time to simulate Night Shift
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('/apex/SomePage'));
        Test.setCurrentPage(DateTime.newInstanceGmt(2023, 8, 8, 22, 0, 0)); // Set the time to simulate Night Shift

        AssignCasetoShiftQueue.casetoshiftqueue(new List<Case>{c});
        Test.stopTest();

        c = [SELECT Id, OwnerId FROM Case WHERE Id = :c.Id];
        System.assertEquals(nightShiftQueue.Id, c.OwnerId, 'Case was not assigned to the Night Shift queue.');
        System.assertEquals('Night Shift', c.Initial_Shift_Name__c,c.OwnerId); // Line 82
    }
}