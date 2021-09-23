public class OrderProductController {
    @AuraEnabled
    public static String getOrderItem(String orderId) {
        try {
            List<OrderItem> orderItems = [SELECT id, PricebookEntry.Name, UnitPrice, TotalPrice,Quantity FROM OrderItem WHERE orderId =: orderId];
            List<ResponseOrderItem> response = new List<ResponseOrderItem>();

            for(OrderItem item : orderItems){
                response.add(new ResponseOrderItem(
                        item.PricebookEntry.Name,
                        item.UnitPrice,
                        item.TotalPrice,
                        Integer.valueof(item.Quantity)
                    )
                );
            }
            return JSON.serialize(response);
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static String activateOrder(String orderId){
        try {
            Order order = [
                SELECT id, Status, AccountId,Account.AccountNumber, OrderNumber, Type,
                 (SELECT id, UnitPrice, Quantity, Product2.Name, Product2.ProductCode FROM OrderItems) 
                FROM Order 
                WHERE id =: orderId
            ];        

            RepsonseActivated resp = new RepsonseActivated();
            List<OrderRest.OrderItemRequest> orderItems = new List<OrderRest.OrderItemRequest>();
            OrderRest.OrderRequest orderRequest = new OrderRest.OrderRequest();
            for(OrderItem item : Order.OrderItems){
                OrderRest.OrderItemRequest  itemRequest = new OrderRest.OrderItemRequest();
                itemRequest.name = item.Product2.Name;
                itemRequest.code = item.Product2.ProductCode;
                itemRequest.unitPrice = item.UnitPrice;
                itemRequest.quantity = Integer.Valueof(item.Quantity);
                orderItems.add(itemRequest); 
            }

            orderRequest.accountNumber = order.Account.AccountNumber;
            orderRequest.orderNumber = order.OrderNumber;
            orderRequest.type = order.Type;
            orderRequest.Status = order.status;
            orderRequest.orderProducts = orderItems;
            Boolean success = OrderRest.sentOrderToExternalSystem(orderRequest);

            if(success) {
                order.Status = 'Activated';

                Database.UpsertResult result = Database.upsert(order);

                if(result.isSuccess()) {
                    resp.message = 'Success';
                    resp.hasError = false;
                    return JSON.Serialize(resp);

                } else {
                    resp.message = result.getErrors()[0].getMessage();
                    resp.hasError = true;
                    return JSON.Serialize(resp);
                }
            } else {
                resp.message = 'Error';
                resp.hasError = true;
                return JSON.Serialize(resp);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }



    public class RepsonseActivated {
        public String message;
        public Boolean hasError;
    }

    public class ResponseOrderItem {
        public String Name;
        public Decimal UnitPrice;
        public Decimal TotalPrice;
        public Integer Quantity;
        public ResponseOrderItem(String Name, Decimal UnitPrice, Decimal TotalPrice, Integer Quantity) {
            this.Name = Name;
            this.UnitPrice = UnitPrice;
            this.TotalPrice = TotalPrice;
            this.Quantity = Quantity;
        }
    }
}
