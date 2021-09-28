/*
* @author: Tumish TaK <tumish.tak@cognizant.com>
* @createdDate: 21-Sep-2021
* @lastModifiedBy: Tumish TaK <tumish.tak@cognizant.com>
* @lastModifiedDate: 23-Sep-2021
*/
public with sharing class ProductListController {

//Returning PricebookEntries List for the wire call from LWC - productList 
    @AuraEnabled(cacheable=true)
    public static List<PricebookEntry> getProductList(id orderIdparam, string orderStatusparam, String searchKey) {
    //variable declaration section *************************************  
        set<id> currntProductIdset = new set<id>();

        List<PricebookEntry> currntProdtPBElist = new List<PricebookEntry>();
        List<PricebookEntry> restProdtPBElist = new List<PricebookEntry>();
        List<PricebookEntry> finalsortedPBElist = new List<PricebookEntry>();
        List<Order> orderList = ProductListDataService.getOrderDetails(orderIDparam);
        Id pricebook2ID = orderList[0].pricebook2Id;        
    //Map of existing order items
        Map<Id, OrderItem> orderItemMap = ProductListDataService.getOrderItemDetails(orderIdparam);
    // variable declaration ENDs here ********************************** 
        if(String.isBlank(searchKey)){
            try{
                //adding exisitng orderItem's product ids in the set 
                    if(!orderItemMap.isEmpty()){
                        for(OrderItem ordItm : orderItemMap.values()){
                        currntProductIdset.add(ordItm.Product2Id);
                        }
                    }
                //Map of PriceBookEntries
                Map<id, PricebookEntry> priceBookEntryMap = ProductListDataService.getPriceBookEntries(pricebook2ID);

                for(PricebookEntry pbe: priceBookEntryMap.values()){
                    //list of existing already product PBEs
                    if(currntProductIdset.contains(pbe.Product2Id)){
                        currntProdtPBElist.add(pbe);
                    }
                    //list of non-existing product PBEs
                    else{
                        restProdtPBElist.add(pbe);
                    }
                }

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
            catch(Exception e){
                throw new AuraHandledException(e.getmessage());
            }
        }
        else{ // return the Search Key query result
            String key = '%' + searchKey + '%';
            try{
                List<PricebookEntry> pbeList = ProductListDataService.getSrchKeyPriceBookEntries(pricebook2ID, key);
                return pbeList;
            }
            catch(Exception e){
                throw new AuraHandledException(e.getmessage());
            }
        }
    }
}
