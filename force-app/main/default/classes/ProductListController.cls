/*
* @author: Tumish TaK <tumish.tak@cognizant.com>
* @createdDate: 21-Sep-2021
* @lastModifiedBy: Tumish TaK <tumish.tak@cognizant.com>
* @lastModifiedDate: 23-Sep-2021
*/
public with sharing class ProductListController {

//Returning PricebookEntries List for the wire call from LWC - productList 
    @AuraEnabled(cacheable=true)
    public static List<PricebookEntry> getProductList(id orderIdparam, string orderStatusparam) {
    //variable declaration section *************************************  
        set<id> currntProductIdset = new set<id>();

        List<PricebookEntry> currntProdtPBElist = new List<PricebookEntry>();
        List<PricebookEntry> restProdtPBElist = new List<PricebookEntry>();
        List<PricebookEntry> finalsortedPBElist = new List<PricebookEntry>();
      
        Id pricebook2ID = [SELECT pricebook2Id FROM Order WHERE id=:orderIdparam AND Status=:orderStatusparam].pricebook2Id;
        
        //Map of existing order items
        Map<Id, OrderItem> orderItemMap = new Map<Id, OrderItem>([SELECT id, Product2Id 
                                                                  FROM OrderItem 
                                                                  WHERE OrderID=: orderIdparam]);
    // variable declaration ENDs here ********************************** 

    //adding exisitng orderItem's product ids in the set 
        if(!orderItemMap.isEmpty()){
            for(OrderItem ordItm : orderItemMap.values()){
            currntProductIdset.add(ordItm.Product2Id);
            }
        }

    //list of existing already product PBEs
        currntProdtPBElist = [SELECT Id,UnitPrice,Product2Id, Product2.Name
                              FROM PricebookEntry
                              WHERE Pricebook2Id=:pricebook2ID AND Product2Id IN :currntProductIdset 
                              WITH SECURITY_ENFORCED];
    //list of non-existing product PBEs
        restProdtPBElist = [SELECT Id,UnitPrice,Product2Id, Product2.Name
                            FROM PricebookEntry
                            WHERE Pricebook2Id=:pricebook2ID AND Product2Id NOT IN :currntProductIdset 
                            WITH SECURITY_ENFORCED];

    //compiling the final sorted PBE list 
        if(!currntProdtPBElist.isEmpty()){                   
        finalsortedPBElist.addAll(currntProdtPBElist);
        }

        if(!restProdtPBElist.isEmpty()){
        finalsortedPBElist.addAll(restProdtPBElist);  
        }
    
    //returing the sorted list having existing product items in front of the lsit
        return finalsortedPBElist;
    }
}
