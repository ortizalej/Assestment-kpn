@isTest
public  class OrderRestTest {
    @isTest static void sentOrderAndOrderItems() {
        Test.setMock(HttpCalloutMock.class, new OrderRestMock());

        String requestString = '{' +
            '"accountNumber": "",' +
            '"orderNumber": "",' +
            '"type": "order type",' +
            '"status": "order status",' +
            '"orderProducts": [{' +
                '"name": "product name",' +
                '"code": "product code",' +
                '"unitPrice": 10.00,' +
                '"quantity": 1' +
            '}]' +
        '}';
        OrderRest.OrderRequest req = (OrderRest.OrderRequest) JSON.deserialize(
                                        requestString, OrderRest.OrderRequest.class); 
        Test.startTest();
           Boolean response = OrderRest.sentOrderToExternalSystem(req);
        Test.stopTest();
        System.assertEquals(true,response);

    }
}