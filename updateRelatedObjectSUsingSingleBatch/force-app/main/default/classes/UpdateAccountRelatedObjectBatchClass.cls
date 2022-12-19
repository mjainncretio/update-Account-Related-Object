public with sharing class UpdateAccountRelatedObjectBatchClass implements Database.Batchable<sObject>
{
    List<Id> accountUpdatedWithPhone = new List<Id>();
    List<Id> accountUpdatedWithAddress = new List<Id>();
    
    public UpdateAccountRelatedObjectBatchClass(List<Id> accountUpdatedWithPhone, List<Id> accountUpdatedWithAddress)
    {
        this.accountUpdatedWithPhone = accountUpdatedWithPhone.clone();  
        this.accountUpdatedWithAddress = accountUpdatedWithAddress.clone();
    }
    
    public Database.QueryLocator start(Database.BatchableContext bC)
    {
        return Database.getQueryLocator([SELECT Id, BillingCity, Phone FROM Account WHERE Id IN: accountUpdatedWithAddress OR Id IN: accountUpdatedWithPhone ]);
    }
    
    public void execute(Database.BatchableContext bC, List<Account> accountList)
    {
        List<Contact> updateContact = new List<Contact>();
        List<Opportunity> updateOpportunity = new List<Opportunity>();
        List<Task> updateTask = new List<Task>();
        
        List<Contact> relatedContacts = [SELECT Id, AccountId FROM Contact WHERE AccountId IN: accountUpdatedWithAddress];      
        List<Opportunity> relatedOpportunities =  [SELECT Id, AccountId FROM Opportunity WHERE AccountId IN: accountUpdatedWithPhone];
        List<Task> relatedTasks = [SELECT Id FROM Task WHERE whoId IN: relatedContacts];
        
        for(Account account : accountList)
        {
            for(Contact tempContact : relatedContacts)
            {
                if(tempContact.AccountId == account.Id)
                {
                    tempContact.OtherCity = account.BillingCity;
                    updateContact.add(tempContact);
                }
            }
            for(Opportunity tempOpportunity : relatedOpportunities)
            {
                if(tempOpportunity.AccountId == account.Id)
                {
                    tempOpportunity.phoneNumber__c = account.Phone;
                    updateOpportunity.add(tempOpportunity);
                }
            }
        }
        
        for(Task tempTask : relatedTasks)
        {
            tempTask.Status = 'Closed';
            updateTask.add(tempTask);
        }
        
        UPDATE updateOpportunity;
        UPDATE updateContact;
        UPDATE updateTask;
    }
    
    public void finish(Database.BatchableContext bC)
    {
        System.debug('finish');
    }
    
}
