/*
* @author: Tumish TaK <tumish.tak@cognizant.com>
* @createdDate: 21-Sep-2021
* @lastModifiedBy: Tumish TaK <tumish.tak@cognizant.com>
* @lastModifiedDate: 23-Sep-2021
*/
public with sharing class ProductListController {
    //Returning PricebookEntries List for the wire call from LWC - productList 
    @AuraEnabled(cacheable=true)
    public static List<PricebookEntry> getProductList(id orderid, string orderStatusparam) {
        Id pricebook2ID = [Select pricebook2Id from Order where id=:orderid AND Status=:orderStatusparam].pricebook2Id;
        return [SELECT Id,UnitPrice,Product2Id, Product2.Name
                FROM PricebookEntry
                WHERE Pricebook2Id=:pricebook2ID WITH SECURITY_ENFORCED];
    }
}
