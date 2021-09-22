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
            System.debug(response);
            return JSON.serialize(response);
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static String activateOrder(String orderId){
        try {
            Order order = [SELECT id, Status FROM Order WHERE id =: orderId];        

            order.Status = 'Activated';
            System.debug(order);
            RepsonseActivated resp = new RepsonseActivated();
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
