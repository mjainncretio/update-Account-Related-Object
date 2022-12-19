trigger updateAccountRelatedObjects on Account (after update) 
{
    List<Id> accountUpdatedWithAddress = new List<Id>();
    List<Id> accountUpdatedWithPhone = new List<Id>();
    
    for(Account updatedAccount : Trigger.new)
    {
        Account oldAccount = Trigger.oldMap.get(updatedAccount.ID);
        if(oldAccount.phone != updatedAccount.phone)
        {
            accountUpdatedWithPhone.add(updatedAccount.Id);
        }
        if(oldAccount.BillingCity != updatedAccount.BillingCity)
        {
            accountUpdatedWithAddress.add(updatedAccount.Id);
        }
    }
    
    UpdateAccountRelatedObjectBatchClass updateRecords = new UpdateAccountRelatedObjectBatchClass(accountUpdatedWithPhone, accountUpdatedWithAddress);
    database.executeBatch(updateRecords);
    
}