/**
 * This class assigns cases to different shift queues based on custom-defined shift times.
 * @description: This class assigns cases to different shift queues based on custom-defined shift times.
 * @Author: Surendranath Reddy, Subba Reddy Venkata, Sprutiraj Panda, Sravani Bandaru
 * @Last Modified By: Subba Reddy, Surendranath Reddy
 * @Last Modified On: 20/04/2023
 * @Modification Log:
 * Ver    Date          Author               LastModification
 * 1.0    26/04/2023    Surendranath Reddy    Initial Version
 *        Subba Reddy Venkata
 **/
public with sharing class AssignCasetoShiftQueue {
    
    /**
     * @description Method to parse time value from string format and convert it to a Time instance.
     * @param timeValue The time value in the string format "hh:mm".
     * @return The parsed Time instance with seconds and milliseconds set to zero.
     */
    @TestVisible
    private static Time parseTime(String timeValue) {
        if (String.isNotBlank(timeValue) && timeValue.contains(':')) {
            String[] strTimeSplit = timeValue.split(':');
            // Ensure that the timeValue is correctly split into hours and minutes.
          //  if (strTimeSplit.size() == 2) {
                    // Create a new Time instance using the hour and minute values parsed from the "strTimeSplit" array.
                    // The seconds and milliseconds are set to zero.
                    Time timeChange = Time.newInstance(Integer.valueOf(strTimeSplit[0]), Integer.valueOf(strTimeSplit[1]), 0, 0);
                    return timeChange;
           // }
        }
        // If the timeValue is invalid or there was an error parsing it, return null or set a default value as per your requirement.
        return null;
    }
    
    
     /**
     * @description Helper method to determine the queue owner ID based on the current time.
     *
     * @param shiftTimingInfo The object containing shift timings and the current time.
     * @return The ID of the queue owner based on the current time.
     */
    private static Id getQueueOwnerIdBasedOnTime(ShiftTimingInfo shiftTimingInfo) {
        Id morningShiftQueueId = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name ='Morning Shift'].Id;
        Id afternoonShiftQueueId = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name ='Afternoon Shift'].Id;
        Id nightShiftQueueId = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name ='Night Shift'].Id;

        Time currentTime = shiftTimingInfo.getCurrentTime();

        if (currentTime >= shiftTimingInfo.getShift1StartTime() && currentTime < shiftTimingInfo.getShift2StartTime()) {
            return morningShiftQueueId;
        } else if (currentTime >= shiftTimingInfo.getShift2StartTime() && currentTime < shiftTimingInfo.getShift3StartTime()) {
            return nightShiftQueueId;
        } else {
            return afternoonShiftQueueId;
        }
    }

   /**
     * @description Helper method to determine the shift name based on the current time.
     *
     * @param shiftTimingInfo The object containing shift timings and the current time.
     * @return The name of the shift based on the current time.
     */
    private static String getShiftNameBasedOnTime(ShiftTimingInfo shiftTimingInfo) {
        Time currentTime = shiftTimingInfo.getCurrentTime();
        if (currentTime >= shiftTimingInfo.getShift1StartTime() && currentTime < shiftTimingInfo.getShift2StartTime()) {
            return 'Morning Shift';
        } else if (currentTime >= shiftTimingInfo.getShift2StartTime() && currentTime < shiftTimingInfo.getShift3StartTime()) {
            return 'Night Shift';
        } else {
            return 'Afternoon Shift';
        }
    }

    /**
     * @description Helper method to get the assigning user ID based on the queue owner ID.
     * @param queueOwnerId The ID of the queue owner.
     * @return The ID of the user to whom the case will be assigned.
     */
    private static Id getAssigningUserId(Id queueOwnerId) {
        List<Id> userIds = new List<Id>();

        // Query GroupMember records to get the users belonging to the specified queue owner (queueOwnerId)
        List<GroupMember> groupMembers = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :queueOwnerId WITH SECURITY_ENFORCED];

        // Extract the User IDs from the GroupMember records
        for (GroupMember gm : groupMembers) {
            if (gm.UserOrGroupId != null && gm.UserOrGroupId.getSObjectType() == User.SObjectType) {
                userIds.add(gm.UserOrGroupId);
            }
        }

        if (userIds.isEmpty()) {
            // If there are no users in the queue, return null or any default user ID as per your requirement.
            return null;
        } else {
            // Get the index of the last assigned user from the list of user IDs
            Integer lastIndex = (Integer) Limits.getLimitQueries() - 1;
            if (lastIndex >= userIds.size()) {
                lastIndex = userIds.size() - 1;
            }

            // Return the ID of the user to whom the case will be assigned
            return userIds[lastIndex];
        }
    }

    /**
     * @description Assign cases to shift queues based on certain conditions.
     * @param caseList The list of cases to be assigned to shift queues.
     */
    public static void casetoshiftqueue(List<Case> caseList) {
       ShiftTime__c shiftTimes = ShiftTime__c.getInstance();
        Time shift1StartTime = parseTime(shiftTimes.Shift1StartTime__c);
        Time shift2StartTime = parseTime(shiftTimes.Shift2StartTime__c);
        Time shift3StartTime = parseTime(shiftTimes.Shift3StartTime__c);

        Time currentTime = Time.newInstance(
            Datetime.now().hour(),
            Datetime.now().minute(),
            Datetime.now().second(),
            0
        );

        Id queueOwnerId;
        String shiftName;

        if (currentTime >= shift1StartTime && currentTime < shift2StartTime) {
            queueOwnerId = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Morning Shift'].Id;
            shiftName = 'Morning Shift';
        } else if (currentTime >= shift2StartTime && currentTime < shift3StartTime) {
            queueOwnerId = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Afternoon Shift'].Id;
            shiftName = 'Afternoon Shift';
        } else {
            queueOwnerId = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Night Shift'].Id;
            shiftName = 'Night Shift';
        }

        Id assigningUserId = getAssigningUserId(queueOwnerId);

        for (Case c : caseList) {
            if ((c.Priority == 'Low' || c.Priority == 'Medium') && c.Skill_Name__c == null && c.Product__c == null) {
                c.Assigned_to__c = assigningUserId;
                c.OwnerId = queueOwnerId;
                c.Initial_Shift_Name__c = shiftName;
            }
        }
    }
}