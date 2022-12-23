@isTest
private with sharing class UpdateAccountRelatedObjectTestClass 
{ 
    //when account billing city is updated
    @isTest
    static void onUpdateBillingCityFieldInAccount()
    {
        Account accountFirst = new Account(Name = 'Muskan Jain');
        INSERT accountFirst;
        
        List<Contact> contactList = new List<Contact>();
        Integer count = 400;
        while(count != 0)
        {
            contactList.add(new Contact(FirstName = 'Navya' + count,
                                        LastName = 'Jain' + count, 
                                        AccountId = accountFirst.Id));
            count--;
        }
        INSERT contactList;
        
        Test.startTest();
        accountFirst.BillingCity = 'kota';
        UPDATE accountFirst;
        Test.stopTest();
        
        List<Contact> result = [SELECT Id , OtherCity FROM Contact WHERE AccountId = :accountFirst.Id];
        
        for(Contact contact : result)
        {
            //Is contact  city updated when account billing city updated
            System.assertEquals('kota', contact.OtherCity);
        }       
    }
    
    //when Account Phone field is updated
    @isTest
    static void onUpdatePhoneFieldInAccount()
    {
        Account accountFirst = new Account(Name = 'Muskan Jain');
        INSERT accountFirst;
        
        List<Opportunity> opportunityList = new List<Opportunity>();
        Integer count = 400;
        while(count != 0)
        {
            opportunityList.add(new Opportunity(Name = 'Navya' + count, 
                                                AccountId = accountFirst.Id, 
                                                StageName = 'Qualification', 
                                                CloseDate = date.newInstance(1990, 11, 21)));
            count--;
        }
        INSERT opportunityList;
        
        Test.startTest();
        accountFirst.Phone = '1234567890';
        UPDATE accountFirst;
        Test.stopTest();
        
        List<Opportunity> result = [SELECT Id, phoneNumber__c FROM Opportunity WHERE AccountId = :accountFirst.Id];
        
        for(Opportunity opportunity : result)
        {
            //Is opportunity  phoneNumber updated when account Phone updated
            System.assertEquals('1234567890', opportunity.phoneNumber__c);
        }        
    }
    
    //when task is assigned to contact and the contact's account billing city is updating
    @isTest
    static void updateTask()
    {
        Account accountFirst = new Account(Name = 'Muskan Jain');
        INSERT accountFirst;
        
        List<Contact> contactList = new List<Contact>();
        
        Contact contactFirst = new Contact(FirstName = 'Navya', LastName = 'Jain', AccountId = accountFirst.Id);
        Contact contactSecond = new Contact(FirstName = 'Harshita', LastName = 'Jain', AccountId = accountFirst.Id);
        Contact contactThird = new Contact(FirstName = 'Yash', LastName = 'Agarwal', AccountId = accountFirst.Id);
        Contact contactFour = new Contact(FirstName = 'Mukund', LastName = 'Sharma', AccountId = accountFirst.Id);
        
        contactList.add(contactFirst);
        contactList.add(contactSecond);
        contactList.add(contactThird);
        contactList.add(contactFour);
        INSERT contactList;
        
        Task TaskFirst = new Task(ReminderDateTime = System.now() + 1, WhoId = contactSecond.Id);             
        INSERT TaskFirst;
        
        Task TaskSecond = new Task(ReminderDateTime = System.now() + 1, WhoId = contactSecond.Id);             
        INSERT TaskSecond;
        
        Test.startTest();
        accountFirst.BillingCity = 'kota';
        UPDATE accountFirst;
        Test.stopTest();
        
        List<Contact> relatedContactAfterAccountsUpdate = [SELECT Id, OtherCity 
                                                           FROM Contact 
                                                           WHERE AccountId = :accountFirst.Id];
        
        for(Contact contact : relatedContactAfterAccountsUpdate)
        {
            //Is contact  city updated when account BillingCity updated
            System.assertEquals('kota', contact.OtherCity);
        }
        
        List<Task> result = [SELECT Id, Status FROM Task WHERE WhoId = :contactSecond.Id];
        
        for(Task task : result)
        {
            //Is task  status updated to close when account BillingCity updated and the associated contact 
            //has task assign to it
            System.assertEquals('Closed', task.Status);
        }
        
    }
    
    //when account billing city and phone updated simultaneously
    @isTest
    static void updateOpportunityContactTaskRelatedToAccountAfterAccountUpdate()
    {
        Account accountFirst = new Account(Name = 'Muskan Jain');
        INSERT accountFirst;
        
        List<Contact> contactList = new List<Contact>();
        
        Contact contactFirst = new Contact(FirstName = 'Navya', LastName = 'Jain', AccountId = accountFirst.Id);
        Contact contactSecond = new Contact(FirstName = 'Harshita', LastName = 'Jain', AccountId = accountFirst.Id);
        Contact contactThird = new Contact(FirstName = 'Yash', LastName = 'Agarwal', AccountId = accountFirst.Id);
        Contact contactFour = new Contact(FirstName = 'Mukund', LastName = 'Sharma', AccountId = accountFirst.Id);
        
        contactList.add(contactFirst);
        contactList.add(contactSecond);
        contactList.add(contactThird);
        contactList.add(contactFour);
        INSERT contactList;
        
        Task TaskFirst = new Task(ReminderDateTime = System.now() + 1, WhoId = contactSecond.Id);             
        INSERT TaskFirst;
        
        Task TaskSecond = new Task(ReminderDateTime = System.now() + 1, WhoId = contactSecond.Id);             
        INSERT TaskSecond;
        
        List<opportunity> opportunityList = new List<opportunity>();
        opportunity opportunityFirst = new opportunity(Name = 'Manav',  
                                                       AccountId = accountFirst.Id,
                                                       StageName = 'Qualification', 
                                                       CloseDate = date.newInstance(1790, 11, 9));
        opportunity opportunitySecond = new opportunity(Name = 'Honey',  
                                                        AccountId = accountFirst.Id, 
                                                        StageName = 'Qualification', 
                                                        CloseDate = date.newInstance(1980, 11, 21));
        opportunity opportunityThird = new opportunity(Name = 'Vedansh',  
                                                       AccountId = accountFirst.Id, 
                                                       StageName = 'Qualification', 
                                                       CloseDate = date.newInstance(1990, 01, 61));
        opportunity opportunityFour = new opportunity(Name = 'Karishma',  
                                                      AccountId = accountFirst.Id, 
                                                      StageName = 'Qualification', 
                                                      CloseDate = date.newInstance(2000, 06, 21));
        
        opportunityList.add(opportunityFirst);
        opportunityList.add(opportunitySecond);
        opportunityList.add(opportunityThird);
        opportunityList.add(opportunityFour);
        
        INSERT opportunityList;
        
        Test.startTest();
        accountFirst.BillingCity = 'kota';
        accountFirst.Phone = '1234567890';
        UPDATE accountFirst;
        Test.stopTest();
        
        List<Contact> updatedContact = [SELECT Id, OtherCity FROM Contact WHERE AccountId = :accountFirst.Id];
        
        for(Contact contact : updatedContact)
        {
             //Is contact  city updated when account billing city updated
            System.assertEquals('kota', contact.OtherCity);
        }
        
        List<Task> updatedTask = [SELECT Id, Status FROM Task WHERE WhoId = :contactSecond.Id];
        
        for(Task task : updatedTask)
        {
            //Is task status updated to closed when account billing city updated and its related contacts 
            //have task assigned
            System.assertEquals('Closed', task.Status);
        }
        
        List<Opportunity> updatedOpportunity = [SELECT Id, phoneNumber__c 
                                                FROM Opportunity 
                                                WHERE AccountId = :accountFirst.Id];
        
        for(Opportunity opportunity : updatedOpportunity)
        {
            //Is opportunity  phoneNumber updated when account phone updated
            System.assertEquals('1234567890', opportunity.phoneNumber__c);
        }
    }
    
    //when more than one account is updated
    @isTest
    static void bulkUpdationOfRelatedObject()
    {
        Account accountFirst = new Account(Name = 'Muskan Jain');
        INSERT accountFirst;
        
        Account accountSecond = new Account(Name = 'Rakesh Jain');
        INSERT accountSecond;
        
        List<Contact> contactList = new List<Contact>();
        
        Contact contactFirst = new Contact(FirstName = 'Navya', LastName = 'Jain', AccountId = accountFirst.Id);
        Contact contactSecond = new Contact(FirstName = 'Harshita', LastName = 'Jain', AccountId = accountFirst.Id);
        Contact contactThird = new Contact(FirstName = 'Yash', LastName = 'Agarwal', AccountId = accountSecond.Id);
        Contact contactFour = new Contact(FirstName = 'Mukund', LastName = 'Sharma', AccountId = accountSecond.Id);
        
        contactList.add(contactFirst);
        contactList.add(contactSecond);
        contactList.add(contactThird);
        contactList.add(contactFour);
        INSERT contactList;
        
        Task TaskFirst = new Task(ReminderDateTime = System.now() + 1, WhoId = contactSecond.Id);             
        INSERT TaskFirst;
        
        Task TaskSecond = new Task(ReminderDateTime = System.now() + 1, WhoId = contactSecond.Id);             
        INSERT TaskSecond;
        
        List<opportunity> opportunityList = new List<opportunity>();
        opportunity opportunityFirst = new opportunity(Name = 'Manav',  
                                                       AccountId = accountFirst.Id, 
                                                       StageName = 'Qualification', 
                                                       CloseDate = date.newInstance(1790, 11, 9));
        opportunity opportunitySecond = new opportunity(Name = 'Honey',  
                                                        AccountId = accountFirst.Id, 
                                                        StageName = 'Qualification', 
                                                        CloseDate = date.newInstance(1980, 11, 21));
        opportunity opportunityThird = new opportunity(Name = 'Vedansh',  
                                                       AccountId = accountSecond.Id, 
                                                       StageName = 'Qualification', 
                                                       CloseDate = date.newInstance(1990, 01, 61));
        opportunity opportunityFour = new opportunity(Name = 'Karishma ',  
                                                      AccountId = accountSecond.Id, 
                                                      StageName = 'Qualification', 
                                                      CloseDate = date.newInstance(2000, 06, 21));
        
        opportunityList.add(opportunityFirst);
        opportunityList.add(opportunitySecond);
        opportunityList.add(opportunityThird);
        opportunityList.add(opportunityFour);
        
        INSERT opportunityList;
        
        List<Account> accountListToUpdate = new List<Account>();
        accountFirst.BillingCity = 'kota';
        accountFirst.Phone = '1234567890';
        accountSecond.BillingCity = 'Ajmer';
        accountSecond.Phone = '9414558035';
        accountListToUpdate.add(accountFirst);
        accountListToUpdate.add(accountSecond);
        
        Test.startTest();
        UPDATE accountListToUpdate;
        Test.stopTest();
        
        List<Contact> updatedContactList = [SELECT Id, OtherCity FROM Contact WHERE AccountId = :accountFirst.Id];
        for(Contact contact : updatedContactList)
        {
            //Is contact  city updated when account billing city updated
            System.assertEquals('kota', contact.OtherCity);
        }
        
        updatedContactList = [SELECT Id, OtherCity FROM Contact WHERE AccountId = :accountSecond.Id];
        
        for(Contact contact : updatedContactList)
        {
            //Is contact  city updated when account billing city updated
            System.assertEquals('Ajmer', contact.OtherCity);
        }
        
        List<Task> updatedTaskList = [SELECT Id, Status FROM Task WHERE WhoId = :contactSecond.Id];
        
        for(Task task : updatedTaskList)
        {
            //Is task status updated to closed when account billing city updated and its related contacts 
            //have task assigned
            System.assertEquals('Closed', task.Status);
        }
        
        List<Opportunity> updatedOpportunityList = [SELECT Id, phoneNumber__c 
                                                    FROM Opportunity 
                                                    WHERE AccountId = :accountFirst.Id];
        for(Opportunity opportunity : updatedOpportunityList)
        {
            //Is opportunity  phoneNumber updated when account phone updated
            System.assertEquals('1234567890', opportunity.phoneNumber__c);
        }
        updatedOpportunityList = [SELECT Id, phoneNumber__c FROM Opportunity WHERE AccountId = :accountSecond.Id];
        
        for(Opportunity opportunity : updatedOpportunityList)
        {
            //Is opportunity  phoneNumber updated when account phone updated
            System.assertEquals('9414558035', opportunity.phoneNumber__c);
        }
    }
}
