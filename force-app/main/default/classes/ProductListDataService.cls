/*
* @author: Tumish TaK <tumish.tak@cognizant.com>
* @createdDate: 28-Sep-2021
* @lastModifiedBy: Tumish TaK <tumish.tak@cognizant.com>
* @lastModifiedDate: 28-Sep-2021
* @description: This class acts as a data provider for the controller class - ProductListController
*/
public with sharing class ProductListDataService {
   
    //fetching existing OrderItemDetails if any
    public static Map<Id,OrderItem> getOrderItemDetails(id orderIDparam){
        Map<Id,OrderItem> orderItemMap = new Map<Id, OrderItem>([SELECT id, Product2Id,Order.PriceBook2Id 
                                                                FROM OrderItem 
                                                                WHERE OrderID=: orderIdparam]);
    return orderItemMap;
    }

    //fecthing Order Details
    public static List<Order> getOrderDetails(id orderIDparam){
        List<Order> orderList = [SELECT Id,Pricebook2Id 
                                 FROM Order 
                                 WHERE Id=:orderIdparam];
    return orderList;
    }

    //fecthing List of already added product PriceBookEntries
    public static Map<id,PriceBookEntry> getPriceBookEntries(id priceBook2IDparam){
        Map<id,PriceBookEntry> priceBookEntryMap = new Map<id, PriceBookEntry>([SELECT Id,UnitPrice,Product2Id, Product2.Name
                                                                                FROM PricebookEntry
                                                                                WHERE Pricebook2Id=:priceBook2IDparam 
                                                                                WITH SECURITY_ENFORCED]);
        
    return priceBookEntryMap;
    }

    //fetch result on basis of Serach Keyword
    public static List<PriceBookEntry> getSrchKeyPriceBookEntries(ID priceBook2IDparam, String key){
        return [SELECT Id,UnitPrice,Product2Id, Product2.Name
                FROM PricebookEntry
                WHERE Pricebook2Id=:priceBook2IDparam AND Product2.Name LIKE :key 
                WITH SECURITY_ENFORCED];
    }
}
