@IsTest
public class ShiftWiseCasesChangeJobSchedulerTest {
    @IsTest
    static void testScheduleJobMethod() {
        // Create test data
        ShiftWiseChangeScheduleJobTimeValues__c scheduleJobTimeValues = ShiftWiseChangeScheduleJobTimeValues__c.getOrgDefaults();

        //Execute the scheduled job
        Test.startTest();
        ShiftWiseCasesChangeJobScheduler.scheduleJobMethod();
        Test.stopTest();

        // Verify the scheduled job has been created
        List<CronTrigger> cronTriggers = [SELECT Id, State, NextFireTime,CronJobDetail.Name, CronExpression FROM CronTrigger WHERE CronJobDetail.Name = 'ShiftWise Change Cases Shift Schedule Job'];
        System.assertEquals(1, cronTriggers.size(), 'One cron trigger should be created for the scheduled job');

        // Verify the job schedule details
        CronTrigger cronTrigger = cronTriggers[0];
        System.assertEquals('ShiftWise Change Cases Shift Schedule Job', cronTrigger.CronJobDetail.Name, 'Cron job name should match');
        System.assertEquals(scheduleJobTimeValues.ScheduleTimeForMinutes__c + ' ' + scheduleJobTimeValues.ScheduleTimeForHours__c + ' * * ?', cronTrigger.CronExpression, 'Cron expression should match');
    }
}