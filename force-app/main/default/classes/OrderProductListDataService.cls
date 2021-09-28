/*
* @author: Tumish TaK <tumish.tak@cognizant.com>
* @createdDate: 28-Sep-2021
* @lastModifiedBy: Tumish TaK <tumish.tak@cognizant.com>
* @lastModifiedDate: 28-Sep-2021
* @description: This class acts as a data provider for the controller class - OrderProductListController
*/
public with sharing class OrderProductListDataService {

    //fecthing data for the controller OrderProductListController class - getOrderProducts method
    public static List<OrderItem> getOrderProductDetails(id selectedOrderid){
        return [SELECT Id, Quantity, Product2Id, Product2.Name, UnitPrice, TotalPrice, Order.Status 
                FROM OrderItem
                WHERE OrderId =:selectedOrderid
                WITH SECURITY_ENFORCED];
    }

    //fetching existing order item for Quantity increment logic
    public static List<OrderItem> getExistingOrderProduct(id pbeIDparam,id orderIdparam,double listPriceparam){
        return [SELECT Id,Quantity 
                FROM OrderItem 
                WHERE OrderID =:orderIdparam 
                AND PriceBookEntryId =:pbeIDparam
                WITH SECURITY_ENFORCED 
                LIMIT 1];
    }

    //fecthing Order details for the provided OrderId
    public static List<Order> getOrderDetails(id orderIdparam){
        return [SELECT id,Status 
                FROM Order 
                WHERE id=:orderIdparam
                WITH SECURITY_ENFORCED];
    }

}
