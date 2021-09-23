@isTest
public  class AvailableProductControllerTest {

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
        
    }

    @isTest static void getProductsWithoutAddedOrderItem() {
        List<Order> ord = [SELECT id FROM Order];
        List<PricebookEntry> entries = AvailableProductController.getProducts(ord[0].id); 
        System.assertEquals(1, entries.size());

    }
    @isTest static void getProductsWithAddedOrderItem() {
        List<Order> ord = [SELECT id FROM Order];
        List<PricebookEntry> entry = [SELECT id FROM PricebookEntry];
        OrderItem item = new OrderItem(
            OrderId = ord[0].id,
            PricebookEntryId = entry[0].id,
            UnitPrice = 123,
            Quantity = 1
        );
        insert item;
        List<PricebookEntry> entries = AvailableProductController.getProducts(ord[0].id); 
        System.assertEquals(1, entries.size());

    }

    @isTest static void upsertOrderItemWithSuccess() {
        List<Order> ord = [SELECT id FROM Order];
        List<PricebookEntry> entry = [SELECT id FROM PricebookEntry];
        String result = AvailableProductController.upsertOrderLineItem(entry[0].id,ord[0].id);
        AvailableProductController.Response resp = (AvailableProductController.Response) JSON.deserialize(
                                                        result,AvailableProductController.Response.class);
        System.assertEquals('Success',resp.message);
        System.assertEquals(false,resp.hasError);
        System.assertEquals(true,resp.isCreated);


    }
}