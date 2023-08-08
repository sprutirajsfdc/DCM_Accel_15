@isTest
public class SkillBasedCaseAssignerTest {
    
    @testSetup
    static void setupTestData() {
        Skill__c sk = new Skill__c();
        sk.Name='Java';
        insert sk;
       Profile p = [SELECT Id, Name FROM Profile Where Name='System Administrator'];
       
        
        User testUser1 = new User(
            LastName = 'Test User1',
            Email = 'testuser1@test.com',
            Alias = 'tuser1',
            Username='sfop34@gmail.com',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId =p.Id,
            LanguageLocaleKey = 'en_US'
        );
        
        User testUser2 = new User(
            LastName = 'Test User2',
            Email = 'testuser2@test.com',
            Alias = 'tuser2',
            TimeZoneSidKey = 'GMT',
            Username='port3@gmail.com',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
           ProfileId =p.Id,
            LanguageLocaleKey = 'en_US'
        );
        
        insert new List<User>{ testUser1, testUser2 };
            List<User_Skill__c> userSkills = new List<User_Skill__c>{
                new User_Skill__c(User__c = testUser1.Id, Skill_Name__c = sk.Id),
                    new User_Skill__c(User__c = testUser2.Id, Skill_Name__c = sk.Id)
                    };
                        insert userSkills;
        
        List<Case> cases = new List<Case>{
            new Case(Skill_Name__c = sk.Id, Priority = 'Low'),
                new Case(Skill_Name__c = sk.Id, Priority = 'High')
                };
                    insert cases;
    }
    
    @isTest
    static void testBuildSkillUserMap() {
        List<Case> testCases = [SELECT Id, Skill_Name__c FROM Case];
        Map<String, List<String>> skillUserMap = SkillBasedCaseAssigner.buildSkillUserMap(testCases);
        System.assertEquals(2, skillUserMap.size(),'Skill bAsed');
    }
    
    @isTest
    static void testGetLastAssignedSkillCase() {
        Case lastAssignedCase = SkillBasedCaseAssigner.getLastAssignedSkillCase();
        System.assertEquals(null, lastAssignedCase,'Skill bAsed case');
    }
    
    @isTest
    static void testGatherUserIds() {
        Map<String, List<String>> testSkillUserMap = new Map<String, List<String>>{
            'Java' => new List<String>{'User1'},
                'English' => new List<String>{'User2'}
        };
            Set<String> userIds = SkillBasedCaseAssigner.gatherUserIds(testSkillUserMap);
        System.assertEquals(2, userIds.size(),'based on pro');
    }
    
    @isTest
    static void testIsPriorityValid() {
        Case lowPriorityCase = new Case(Priority = 'Low');
        Case mediumPriorityCase = new Case(Priority = 'Medium');
        Case highPriorityCase = new Case(Priority = 'High');
        Case invalidPriorityCase = new Case(Priority = 'Invalid');
        
        System.assertEquals(true, SkillBasedCaseAssigner.isPriorityValid(lowPriorityCase),'low priority');
        System.assertEquals(true, SkillBasedCaseAssigner.isPriorityValid(mediumPriorityCase),'medium priority');
        System.assertEquals(true, SkillBasedCaseAssigner.isPriorityValid(highPriorityCase),'high priority');
        System.assertEquals(false, SkillBasedCaseAssigner.isPriorityValid(invalidPriorityCase),'invalid priority');
    }
    
    
    @isTest
    static void testAssignCaseToUser() {
        Skill__c sk = new Skill__c();
        sk.Name='Java';
        insert sk;
        SkillBasedCaseAssigner.AssignmentParameters params = new SkillBasedCaseAssigner.AssignmentParameters();
        params.newCase = new Case(Skill_Name__c = sk.Id);
        params.userIdList = new List<String>{'User1', 'User2'};
            params.userIds = new Set<String>{'User1', 'User2'};
                params.lastAssignedSkillCase = new Case(OwnerId = 'User1');
        Test.startTest();
        SkillBasedCaseAssigner.assignCaseToUser(params);
        Test.stopTest();
        System.assertNotEquals(null, params.newCase.OwnerId,'user not vaild');
    }
    
    @isTest
    static void testAssignCases() {
        Skill__c sk = new Skill__c();
        sk.Name='Java';
        insert sk;
        List<Case> testCases = [SELECT Id, Skill_Name__c, Priority, Product__c FROM Case];
        
        Test.startTest();
        SkillBasedCaseAssigner.assignCases(testCases);
        Test.stopTest();
        
        // Perform assertions based on your business logic
        for (Case testCase : testCases) {
            if (testCase.Skill_Name__c == sk.Id && testCase.Priority == 'Low' && testCase.Product__c == null) {
                System.assertNotEquals(null, testCase.OwnerId,'low case');
                // Add more specific assertions based on your business logic
            } else if (testCase.Skill_Name__c == sk.Id && testCase.Priority == 'High' && testCase.Product__c == null) {
                System.assertNotEquals(null, testCase.OwnerId,'high case');
                // Add more specific assertions based on your business logic
            } else {
                System.assertEquals(null, testCase.OwnerId,'Null case');
                // Add more specific assertions based on your business logic
            }
        }
    }
}