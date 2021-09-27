@isTest
private class TestOrderProductListController{

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

	static testMethod void validateGetOrderProducts() {
		//Fetching the test data
		List<Order> ordList = [SELECT Id, Status 
							  FROM Order
							  WITH SECURITY_ENFORCED];
		List<OrderItem> ordItemsList = [SELECT Id, Quantity, Product2Id, Product2.Name, UnitPrice, TotalPrice, Order.Status 
										FROM OrderItem
										WHERE OrderId =:ordList[0].Id
										WITH SECURITY_ENFORCED];
		//Testing Scope starts************************************************
		test.startTest();
			List<OrderItem> returnedList = OrderProductListController.getOrderProducts(ordList[0].Id);
		test.stopTest();
		//Testing Scope ends************************************************
		
		//Assert Statements
		System.assertEquals(ordItemsList, returnedList);
	}

	static testMethod void validateUpsertOrderItem() {
		//Fetching the test data
		List<Order> ordList = [SELECT Id, Status 
							  FROM Order
							  WITH SECURITY_ENFORCED];
		List<OrderItem> ordItemList = [SELECT Id, Quantity, Product2Id, Product2.Name, UnitPrice, TotalPrice,PriceBookEntryId, Order.Status
										FROM OrderItem];
		List<Pricebook2> pbList = [SELECT id FROM Pricebook2 WHERE IsStandard=FALSE];													  
		List<PricebookEntry> pbeList = [SELECT Id,UnitPrice 
										FROM PricebookEntry
										WHERE Pricebook2Id = :pbList[0].Id];
		//Testing Scope starts************************************************
		test.startTest();
		    List<OrderItem> returnedList = OrderProductListController.upsertOrderItem(ordItemList[0].PriceBookEntryId, ordList[0].Id,(ordItemList[0].UnitPrice).doubleValue());
			List<OrderItem> returnedListNewItem = OrderProductListController.upsertOrderItem(pbeList[1].Id, ordList[0].Id,(pbeList[0].UnitPrice).doubleValue());
	    test.stopTest();
		//Testing Scope ends**************************************************

		//Assert Statements
		System.assertEquals(2, returnedList[0].Quantity); // Quantity increased by 1		
	}

	static testMethod void validateActivateOrder() {
		//Fetching the test data
		List<Order> ordList = [SELECT Id, Status 
							  FROM Order
							  WITH SECURITY_ENFORCED];
		//Testing scope starts here *****************************************
		test.startTest();
			OrderProductListController.activateOrder(ordList[0].Id);
		test.stopTest();
		//Testing Scope ends**************************************************

		//Assert Statements
		List<Order> updatedOrderList = [SELECT Id, Status 
										FROM Order
										WITH SECURITY_ENFORCED];
		System.assertEquals('Activated', updatedOrderList[0].Status);
	}
}