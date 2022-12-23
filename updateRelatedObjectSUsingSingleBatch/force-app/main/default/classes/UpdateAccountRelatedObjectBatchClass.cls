public with sharing class UpdateAccountRelatedObjectBatchClass implements Database.Batchable<sObject>
{
    List<Id> accountUpdatedWithPhone = new List<Id>();
    List<Id> accountUpdatedWithAddress = new List<Id>();
    
    //Batch class constructor
    public UpdateAccountRelatedObjectBatchClass(List<Id> accountUpdatedWithPhone, List<Id> accountUpdatedWithAddress)
    {
        this.accountUpdatedWithPhone = accountUpdatedWithPhone.clone();  
        this.accountUpdatedWithAddress = accountUpdatedWithAddress.clone();
    }
    
    //batch class start that return all updated account
    public Database.QueryLocator start(Database.BatchableContext bC)
    {
        return Database.getQueryLocator([SELECT Id, BillingCity, Phone 
                                         FROM Account 
                                         WHERE Id IN :accountUpdatedWithAddress OR Id IN :accountUpdatedWithPhone ]);
    }
    
    //batch class execute
    public void execute(Database.BatchableContext bC, List<Account> accountList)
    {
        //Initializing the list that to be updated
        List<Contact> updateContact = new List<Contact>();
        List<Opportunity> updateOpportunity = new List<Opportunity>();
        List<Task> updateTask = new List<Task>();
        
        //Fetching related records
        List<Contact> relatedContacts = [SELECT Id, AccountId 
                                         FROM Contact 
                                         WHERE AccountId IN :accountUpdatedWithAddress];      
        List<Opportunity> relatedOpportunities =  [SELECT Id, AccountId 
                                                   FROM Opportunity 
                                                   WHERE AccountId IN :accountUpdatedWithPhone];
        List<Task> relatedTasks = [SELECT Id 
                                   FROM Task 
                                   WHERE whoId IN :relatedContacts];

        //Creating a map of accountId and account
        Map<Id, Account> updatedAccountMap = new Map<Id, Account>();
        for(Account account : accountList)
        {
            updatedAccountMap.put(account.Id, account);
        }

        //Inserting the all related contacts of Accounts in list with its updated value
        for(Contact tempContact : relatedContacts)
        {
            tempContact.OtherCity = updatedAccountMap.get(tempContact.AccountId).BillingCity;
            updateContact.add(tempContact);
        }
        
        //Inserting the all related Opportunity of Accounts in list with its updated value
        for(Opportunity tempOpportunity : relatedOpportunities)
        {
            tempOpportunity.phoneNumber__c = updatedAccountMap.get(tempOpportunity.AccountId).Phone;
            updateOpportunity.add(tempOpportunity);
        }
        
        //Inserting the all related Task of Contacts related to Updated address in Accounts in 
        //list with its updated value
        for(Task tempTask : relatedTasks)
        {
            tempTask.Status = 'Closed';
            updateTask.add(tempTask);
        }
        
        //updating all related object 
        UPDATE updateOpportunity;
        UPDATE updateContact;
        UPDATE updateTask;
    }
    
    public void finish(Database.BatchableContext bC)
    {
        System.debug('finish');
    }
    
}