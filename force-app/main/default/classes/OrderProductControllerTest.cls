@isTest
public class OrderProductControllerTest {
    @TestSetup
    static void initData(){

        Account acc = new Account (
            Name = 'Test Account'
        );
        insert acc;

        Id pricebookId = Test.getStandardPricebookId();
        Product2 prod = new Product2(
            Name = 'Test'
            
        );
        insert prod;

        PricebookEntry entry = new PricebookEntry(
            Product2Id = prod.id,
            Pricebook2Id = pricebookId,
            UnitPrice = 123
        );
        insert entry;

        Order ord = new Order(
            Status = 'Draft',
            Pricebook2Id = pricebookId,
            AccountId = acc.id,
            EffectiveDate = Date.today()
        );
        insert ord;
        OrderItem item = new OrderItem(
            OrderId = ord.id,
            PricebookEntryId = entry.id,
            UnitPrice = 123,
            Quantity = 1
        );
        insert item;
        
    }
    @isTest static void getOrderItems() { 
        List<Order> order = [SELECT id FROM Order];
        Test.startTest();
            OrderProductController.getOrderItem(order[0].id);
        Test.stopTest();
        List<OrderItem> items = [SELECT id FROM OrderItem WHERE OrderId =: order[0].id];
        System.assertEquals(1, items.size());

    }
    @isTest static void activateOrder() { 
        Test.setMock(HttpCalloutMock.class, new OrderRestMock());

        List<Order> order = [SELECT id FROM Order];
        Test.startTest();
            OrderProductController.activateOrder(order[0].id);
        Test.stopTest();
        List<OrderItem> items = [SELECT id FROM OrderItem WHERE OrderId =: order[0].id];
        System.assertEquals(1, items.size());

    }
}