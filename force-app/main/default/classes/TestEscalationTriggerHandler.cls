@isTest
private class TestEscalationTriggerHandler {

    @isTest
    static void testScheduleEscalation() {
        // Create a new case with different scenarios
        Case lowPriorityCase = new Case(Status = 'Open', Priority = 'Low');
        Case mediumPriorityCase = new Case(Status = 'Open', Priority = 'Medium');
        Case highPriorityCase = new Case(Status = 'Open', Priority = 'High');
        Case closedCase = new Case(Status = 'Closed', Priority = 'Low');

        insert new List<Case>{lowPriorityCase, mediumPriorityCase, highPriorityCase, closedCase};

        Test.startTest();
        EscalationTriggerHandler.scheduleEscalation(new List<Case>{lowPriorityCase, mediumPriorityCase, highPriorityCase, closedCase});
        Test.stopTest();

        // Verify that escalation was scheduled for Low Priority Case
        List<CronTrigger> cronTriggers = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'Dynamic Case Escalation'];
        System.assertEquals(1, cronTriggers.size(),'low,high case');

        // Clean up
        delete new List<Case>{lowPriorityCase, mediumPriorityCase, highPriorityCase, closedCase};
    }

    @isTest
    static void testShouldScheduleEscalation() {
        Case lowPriorityCase = new Case(Status = 'Open', Priority = 'Low');
        Case mediumPriorityCase = new Case(Status = 'Open', Priority = 'Medium');
        Case highPriorityCase = new Case(Status = 'Open', Priority = 'High');
        Case closedCase = new Case(Status = 'Closed', Priority = 'Low');

        // Test shouldScheduleEscalation method
        System.assertEquals(true, EscalationTriggerHandler.shouldScheduleEscalation(lowPriorityCase),'Low priority case');
        System.assertEquals(true, EscalationTriggerHandler.shouldScheduleEscalation(mediumPriorityCase),'medium priorityc case');
        System.assertEquals(false, EscalationTriggerHandler.shouldScheduleEscalation(highPriorityCase),'high priority case');
        System.assertEquals(false, EscalationTriggerHandler.shouldScheduleEscalation(closedCase),'closed case');
    }

    @isTest
    static void testScheduleCaseEscalation() {
         // Create DynamicTimeValuesForEscalation__c custom setting with required field value
        DynamicTimeValuesForEscalation__c settings = new DynamicTimeValuesForEscalation__c(
            DynamicCaseEscalationTimeValue__c = '2:00'  // Example time value
        );
        insert settings;

        Test.startTest();
        // Create test cases within the test context
        Case lowPriorityCase = new Case(Status = 'Open', Priority = 'Low');
        Case mediumPriorityCase = new Case(Status = 'Open', Priority = 'Medium');
        Case highPriorityCase = new Case(Status = 'Open', Priority = 'High');
        Case closedCase = new Case(Status = 'Closed', Priority = 'Low');
        
        // Insert test cases
        insert new List<Case>{lowPriorityCase, mediumPriorityCase, highPriorityCase, closedCase};
        
        // Use Test.setCreatedDate with the test context sObjects
        Test.setCreatedDate(lowPriorityCase.Id, DateTime.now().addHours(-10));
        Test.setCreatedDate(mediumPriorityCase.Id, DateTime.now().addHours(-8));
        Test.setCreatedDate(highPriorityCase.Id, DateTime.now().addHours(-6));
        Test.setCreatedDate(closedCase.Id, DateTime.now().addHours(-4));

        // Call the method to be tested
        EscalationTriggerHandler.scheduleEscalation(new List<Case>{lowPriorityCase, mediumPriorityCase, highPriorityCase, closedCase});
        Test.stopTest();

        // Verify that escalation was scheduled for Low Priority Case
        List<CronTrigger> cronTriggers = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'Dynamic Case Escalation'];
        System.assertEquals(1, cronTriggers.size(),'cron trigeer');

        // Clean up
        delete settings;
        delete new List<Case>{lowPriorityCase, mediumPriorityCase, highPriorityCase, closedCase};
    }
}