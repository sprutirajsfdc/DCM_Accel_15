@isTest
private class AssignCasesToShiftQueueSchedulerTest {

    @isTest
    static void testAssignCasesToShifts() {
        // Create test data for ShiftTime__c custom settings
        ShiftTime__c shiftTimes = new ShiftTime__c();
        shiftTimes.Name = 'Test Shift Time';
        shiftTimes.Shift1StartTime__c = '08:00';
        shiftTimes.Shift2StartTime__c = '16:00';
        shiftTimes.Shift3StartTime__c = '00:00';
        insert shiftTimes;

        // Create test data for Shift Queue
        Group shiftQueueMorning = new Group();
        shiftQueueMorning.Name = 'Morning Shift Queue';
        shiftQueueMorning.Type = 'Queue';
        insert shiftQueueMorning;

        Group shiftQueueAfternoon = new Group();
        shiftQueueAfternoon.Name = 'Afternoon Shift Queue';
        shiftQueueAfternoon.Type = 'Queue';
        insert shiftQueueAfternoon;

        Group shiftQueueNight = new Group();
        shiftQueueNight.Name = 'Night Shift Queue';
        shiftQueueNight.Type = 'Queue';
        insert shiftQueueNight;

        // Create test data for Case with status 'New' and owner as shift queue
        Case testCaseMorning = new Case();
        testCaseMorning.Status = 'New';
        testCaseMorning.OwnerId = shiftQueueMorning.Id;
        insert testCaseMorning;

        Case testCaseAfternoon = new Case();
        testCaseAfternoon.Status = 'New';
        testCaseAfternoon.OwnerId = shiftQueueAfternoon.Id;
        insert testCaseAfternoon;

        Case testCaseNight = new Case();
        testCaseNight.Status = 'New';
        testCaseNight.OwnerId = shiftQueueNight.Id;
        insert testCaseNight;

        Test.startTest();

        // Schedule the job
        AssignCasesToShiftQueueScheduler scheduler = new AssignCasesToShiftQueueScheduler();
        String cronExp = '0 0 0 * * ?'; // Schedule the job to run daily at midnight
        System.schedule('Assign Cases To Shift Queue Job', cronExp, scheduler);

        Test.stopTest();

        // Query the updated cases
        Case updatedCaseMorning = [SELECT OwnerId FROM Case WHERE Id = :testCaseMorning.Id];
        Case updatedCaseAfternoon = [SELECT OwnerId FROM Case WHERE Id = :testCaseAfternoon.Id];
        Case updatedCaseNight = [SELECT OwnerId FROM Case WHERE Id = :testCaseNight.Id];

        // Verify that the cases were assigned to the appropriate shift queues
        System.assertEquals(shiftQueueMorning.Id, updatedCaseMorning.OwnerId, 'Case assigned to incorrect morning shift queue');
        System.assertEquals(shiftQueueAfternoon.Id, updatedCaseAfternoon.OwnerId, 'Case assigned to incorrect afternoon shift queue');
        System.assertEquals(shiftQueueNight.Id, updatedCaseNight.OwnerId, 'Case assigned to incorrect night shift queue');
    }

    @isTest
    static void testGetShiftCases() {
        // Create test data for Shift Queue
        Group shiftQueue = new Group();
        shiftQueue.Name = 'Test Shift Queue';
        shiftQueue.Type = 'Queue';
        insert shiftQueue;

        // Create test data for Case with status 'New' and owner as shift queue
        Case testCase1 = new Case();
        testCase1.Status = 'New';
        testCase1.OwnerId = shiftQueue.Id;
        insert testCase1;

        // Create test data for Case with status 'New' and owner as another user (not in shift queue)
        Case testCase2 = new Case();
        testCase2.Status = 'New';
        insert testCase2;

        Test.startTest();

        // Query shift cases
        AssignCasesToShiftQueueScheduler scheduler = new AssignCasesToShiftQueueScheduler();
        Set<Id> shiftQueueIds = new Set<Id>{shiftQueue.Id};
        List<Case> shiftCases = scheduler.getShiftCases(shiftQueueIds);

        Test.stopTest();

        // Verify that only the case with the correct status and owner in the shift queue is retrieved
        System.assertEquals(1, shiftCases.size(), 'Number of shift cases should be 1');
        System.assertEquals(testCase1.Id, shiftCases[0].Id, 'Incorrect shift case retrieved');
    }

    @isTest
    static void testNoShiftTimings() {
        Test.startTest();

        // Schedule the job without creating ShiftTime__c custom settings
        AssignCasesToShiftQueueScheduler scheduler = new AssignCasesToShiftQueueScheduler();
        String cronExp = '0 0 0 * * ?'; // Schedule the job to run daily at midnight
        System.schedule('Assign Cases To Shift Queue Job', cronExp, scheduler);

        Test.stopTest();

        // Verify that no cases were updated as shift timings are not available
        List<Case> updatedCases = [SELECT OwnerId FROM Case];
        System.assertEquals(0, updatedCases.size(), 'Cases should not be updated as shift timings are not available');
    }

    @isTest
    static void testNoShiftQueue() {
        // Create test data for ShiftTime__c custom settings
        ShiftTime__c shiftTimes = new ShiftTime__c();
        shiftTimes.Name = 'Test Shift Time';
        shiftTimes.Shift1StartTime__c = '08:00';
        shiftTimes.Shift2StartTime__c = '16:00';
        shiftTimes.Shift3StartTime__c = '00:00';
        insert shiftTimes;

        Test.startTest();

        // Schedule the job without creating Shift Queue
        AssignCasesToShiftQueueScheduler scheduler = new AssignCasesToShiftQueueScheduler();
        String cronExp = '0 0 0 * * ?'; // Schedule the job to run daily at midnight
        System.schedule('Assign Cases To Shift Queue Job', cronExp, scheduler);

        Test.stopTest();

        // Verify that no cases were updated as shift queues are not available
        List<Case> updatedCases = [SELECT OwnerId FROM Case];
        System.assertEquals(0, updatedCases.size(), 'Cases should not be updated as shift queues are not available');
    }
}