/**
 * @description: This class handles the scheduling of Apex jobs to perform certain actions on cases after a delay of 9 hours
 * @Author: Subba Reddy
 * @Last Modified By: Subba Reddy, Surendranath Reddy
 * @Last Modified On: 28/04/2023
 * @Modification Log:
 * Ver Date       Author             Last Modification
 * 1.0 26/04/2023 Subba Reddy        Initial Version
 *     Surendranath Reddy
 **/
public class EscalationTriggerHandler { 

    /**
     * @description This method schedules escalation jobs for cases based on their status and priority.
     * @param newCases List of cases to process.
     */
    public static void scheduleEscalation(List<Case> newCases) {
        for (Case c : newCases) {
            // Check if escalation should be scheduled for this case
            if (shouldScheduleEscalation(c)) {
                scheduleCaseEscalation(c);
            }
        }
    }

    /**
     * @description Helper method to check if escalation should be scheduled for a case.
     * @param c Case record to check.
     * @return True if escalation should be scheduled, False otherwise.
     */
    @TestVisible
    private static Boolean shouldScheduleEscalation(Case c) {
        // Escalation should be scheduled for non-escalated Low/Medium Priority cases without SLA_Escalation_Time__c value
        return (c.Status != 'Escalated' && c.Status != 'Closed' && (c.Priority != 'High') && (c.SLA_Escalation_Time__c == null || c.SLA_Escalation_Time__c == ''));
    }

    /**
     * @description Helper method to get the field API name for scheduling case escalation.
     * @param c Case record to check priority and SLA_Escalation_Time__c value.
     * @return The API name of the field containing the escalation time value.
     */
    private static String getFieldApiName(Case c) {
        if (c.Priority == 'High') {
            return 'CaseEscalationforHighPriority__c';
        } else if (c.SLA_Escalation_Time__c != null && c.SLA_Escalation_Time__c != '') {
            return 'SLA_Escalation_Time__c';
        } else {
            return 'DynamicCaseEscalationTimeValue__c';
        }
        
    }

    /**
     *@description  Helper method to schedule case escalation based on the case and field API name.
     * @param c Case record to schedule escalation for.
     */
   
    private static void scheduleCaseEscalation(Case c) {
         String fieldApiName = getFieldApiName(c);
        DynamicTimeValuesForEscalation__c dynamicCaseEscalationMentionedTimeValue = DynamicTimeValuesForEscalation__c.getInstance();
        
        // Check if the custom settings instance exists and has the required field value
        if (dynamicCaseEscalationMentionedTimeValue != null && dynamicCaseEscalationMentionedTimeValue.get(fieldApiName) != null) {
            String timeString = (String) dynamicCaseEscalationMentionedTimeValue.get(fieldApiName);
            List<String> timeComponents = timeString.split(':');
            
            Integer hours = Integer.valueOf(timeComponents[0]);
            Integer minutes = Integer.valueOf(timeComponents[1]);
            
            DateTime createdDateTime = c.CreatedDate;
            Integer createdHour = createdDateTime.hour();
            Integer createdDay = createdDateTime.day();
            Integer createdMonth = createdDateTime.month();
            Integer createdYear = createdDateTime.year();
            Integer createdMinute = createdDateTime.minute();
            
            Integer escalatedHour = createdHour + hours + Math.mod((createdMinute + minutes), 60);
            Integer escalatedDay = createdDay + (escalatedHour / 24);
            
            // Handle months with 30 days
            Integer daysInMonth = Date.daysInMonth(createdYear, createdMonth);
            if (escalatedDay > daysInMonth) {
                escalatedDay = escalatedDay - daysInMonth;
                createdMonth++; // Increment the month
            }
            
            String scheduledHour = String.valueOf(Math.mod(escalatedHour, 24));
            String scheduledDay = String.valueOf(escalatedDay);
            String scheduledMinute = String.valueOf(Math.mod((createdMinute + minutes), 60));
            String scheduledMonth = String.valueOf(createdMonth);
            String scheduledYear = String.valueOf(createdYear);
            
            // String cronExpression = '0 ' + scheduledMinute + ' ' + scheduledHour + ' ' + scheduledDay + ' ' + scheduledMonth + ' ? ' + scheduledYear;
            // The above line is commented out as the 'cronExpression' variable is not used in this version of the code.
            // If you need to use the 'cronExpression' variable, uncomment the above line.
            
            System.schedule('Dynamic Case Escalation for ' + fieldApiName + ' Schedule Date and Time -- ' + c.Id, '0 ' + scheduledMinute + ' ' + scheduledHour + ' ' + scheduledDay + ' ' + scheduledMonth + ' ? ' + scheduledYear, new CaseEscalation(c, c.Id));
        } 
    }
}