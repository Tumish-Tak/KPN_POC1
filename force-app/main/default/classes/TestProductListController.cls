/*
* @author: Tumish TaK <tumish.tak@cognizant.com>
* @createdDate: 26-Sep-2021
* @lastModifiedBy: Tumish TaK <tumish.tak@cognizant.com>
* @lastModifiedDate: 26-Sep-2021
* @description: This is a test class for ProductListController apex classs
*/
@isTest
private class TestProductListController{

	@testSetup static void setup(){
		//Test Data setup for Account, Products, PriceBooks, PriceBookEntrys, Order, OrderItems
		Account accObj = (TestDataFactory.createAccounts(1))[0];
		List<Product2> prdtList = TestDataFactory.createProducts(3);
		List<Pricebook2> pbList = TestDataFactory.createPriceBooks(1);
		List<PricebookEntry> pbeList = new List<PricebookEntry>();
		for(Product2 prdt: prdtList){
			PricebookEntry pbe = new PricebookEntry();
			pbe = TestDataFactory.createPriceBookEntry(prdt, pbList[0]);
			pbeList.add(pbe);
		}
		Order odrObj = TestDataFactory.createOrder(accObj, pbList[0]);
		OrderItem ordItem = TestDataFactory.createOrderItem(odrObj.id, pbeList[0].Id, 100);
		 
	}
		static testMethod void validategetProductList(){
		//Fetching the test data	
		List<Order> ordList = [SELECT Id, Status 
							  FROM Order
							  WITH SECURITY_ENFORCED];
		List<Pricebook2> pbList = [SELECT Id 
								  FROM PriceBook2 
								  WHERE Name = 'TestPriceBook0' 
								  WITH SECURITY_ENFORCED];
		List<PricebookEntry> currentPbeList = [SELECT Id,UnitPrice,Product2Id, Product2.Name
											  FROM PricebookEntry
											  WHERE Pricebook2Id=:pbList[0].Id
											  WITH SECURITY_ENFORCED];
		String nullSearchKey = null;
		String searchKey = [SELECT ID,Name from Product2 LIMIT 1].Name;
		List<PricebookEntry> pbeListwithKey = [SELECT Id,UnitPrice,Product2Id, Product2.Name
											  FROM PricebookEntry
										      WHERE Pricebook2Id=:pbList[0].Id AND Product2.Name LIKE :searchKey 
											  WITH SECURITY_ENFORCED];									  	
		//Testing Scope starts************************************************
		test.startTest();
			List<PricebookEntry> returnedPBEList = ProductListController.getProductList(ordList[0].Id, ordList[0].Status, nullSearchKey);
			List<PricebookEntry> returnedSerchPBEList = ProductListController.getProductList(ordList[0].Id, ordList[0].Status, searchKey);
		test.stopTest();
		//Testing Scope ends**************************************************
		
		//Assert Statement
		System.assertEquals(currentPbeList, returnedPBEList);
		System.assertEquals(pbeListwithKey, returnedSerchPBEList);

	}
}