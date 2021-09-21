public with sharing class ProductListController {
    @AuraEnabled(cacheable=true)
    public static List<PricebookEntry> getProductList(id orderid) {
        Id pricebook2ID = [Select pricebook2Id from Order where id=:orderid].pricebook2Id;
        return [Select Id,UnitPrice,Product2Id, Product2.Name
                from PricebookEntry
                where Pricebook2Id=:pricebook2ID WITH SECURITY_ENFORCED];
    }
}
