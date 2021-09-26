/*
* @author: Tumish TaK <tumish.tak@cognizant.com>
* @createdDate: 26-Sep-2021
* @lastModifiedBy: Tumish TaK <tumish.tak@cognizant.com>
* @lastModifiedDate: 26-Sep-2021
* @description: This is a TEST DATA FACTORY class
*/
@isTest
public with sharing class TestDataFactory {
   
    //Test Data creation for Account Object
    public static List<Account> createAccounts(Integer numAcc){
    //Variable Declaration
        List<Account> accList = new List<Account>();
    
    //Accounts Insertion logic *************************************************            
        for(Integer i=0;i<numAcc;i++) {
            Account acc = new Account(Name='TestDataAccount' + i);
            accList.add(acc);
        }
        insert accList;
    //Accounts insertion logic ENDs here ****************************************

    return accList;
    }

    //Test data creation for Product Object
    public static List<Product2> createProducts(Integer numProdts){
    //Variable Declaration
        List<PriceBookEntry> standardPBEList = new List<PricebookEntry>();

    //Product Insertion logic ************************************************
        List<Product2> prdtsList = new List<Product2>();
            
        for(Integer i=0;i<numProdts;i++) {
            Product2 pdt = new Product2(Name='TestProduct' + i, IsActive=true);
            prdtsList.add(pdt);
        }
        insert prdtsList;
    //Product insertion logic ENDs here ****************************************
    
    //Adding Standard PriceBookEntry to the above inserted products*************
    Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
    update standardPricebook;
    PriceBook2 pb2Standard = [select Id from Pricebook2 where isStandard=true];
    Id standardPriceBookId = pb2Standard.Id;
        
        for(Product2 pdt: prdtsList){
            PricebookEntry pbe = new PricebookEntry();
            pbe.IsActive = true;
            pbe.Product2Id = pdt.id;
            pbe.Pricebook2Id = standardPriceBookId;
            pbe.UnitPrice = 100;
            standardPBEList.add(pbe);
        }
        insert standardPBEList;
    //Standard PriceBookentry addition logic ENDs here **************************

    return prdtsList;
    }

    //Test Data for PriceBook creation  
    public static List<Pricebook2> createPriceBooks(Integer numPriceBooks){
    //PriceBook Insertion logic **********************************************
        List<Pricebook2> pbList = new List<Pricebook2>();
            
        for(Integer i=0;i<numPriceBooks;i++) {
            Pricebook2 pb = new Pricebook2(Name='TestPriceBook' + i, IsActive=true);
            pbList.add(pb);
        }
        insert pbList;
    //PriceBook insertion logic ENDs here ************************************

    return pbList;
    }

    //Test Data for creation Order Object 
     public static Order createOrder(Account accId, Pricebook2 pb2Id){
    //Order Insertion logic **********************************************
        Order od = new Order();
        od.AccountId = accId.Id;
        od.EffectiveDate = Date.Today();
        od.Pricebook2Id = pb2Id.Id;
        od.Status = 'Draft';
        insert od;
    //Order insertion logic ENDs here ************************************

    return od;
    }
    
    //Test Data for creation OrderItem Object 
    public static OrderItem createOrderItem(Id odrId, id pbeID, Double lstPrice){
        //OrderItem Insertion logic **********************************************
            OrderItem insrtOrdItem = new OrderItem();
            insrtOrdItem.Quantity = 1;
            insrtOrdItem.PriceBookEntryId = pbeId;
            insrtOrdItem.OrderID = odrId;
            insrtOrdItem.UnitPrice = lstPrice;
            insert insrtOrdItem;
        //OrderItem insertion logic ENDs here ************************************
    
    return insrtOrdItem;
    }

    //Test Data for creation of PriceBookEntry Object
    public static PricebookEntry createPriceBookEntry(Product2 prdtObj, Pricebook2 pbObj){
        //PriceBookEntry Insertion logic **********************************************
        PricebookEntry insrtPBE = new PricebookEntry();
            insrtPBE.Pricebook2Id = pbObj.Id;
            insrtPBE.Product2Id = prdtObj.Id;
            insrtPBE.UnitPrice = 100;
            insrtPBE.isActive = true;
            insert insrtPBE;
        //PriceBookEntry insertion logic ENDs here ************************************
    
    return insrtPBE;
    }

}
