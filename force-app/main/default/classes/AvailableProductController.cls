public class AvailableProductController {
    @AuraEnabled
    public static List<PricebookEntry> getProducts(String orderId){
        Set<String> pricebookEntryIds = new Set<String>(); 
        Order order = [SELECT id, Pricebook2Id FROM Order WHERE Id =: orderId];
        List<OrderItem> prodsInOrder = [
            SELECT id, PricebookEntry.Name, PricebookEntryId 
            FROM OrderItem 
            WHERE orderId =: orderId
        ];

        for(OrderItem ord : prodsInOrder) {
            pricebookEntryIds.add(ord.pricebookEntryId);
        }

        Map<Id,PricebookEntry> productsInOrder = new Map<Id,PricebookEntry>(
            [
                SELECT id, UnitPrice,Name 
                FROM PricebookEntry 
                WHERE Id IN: pricebookEntryIds
                AND Pricebook2Id =: order.Pricebook2Id
            ]
        ); 
        Map<Id,PricebookEntry> productsNotInOrder = new Map<Id,PricebookEntry>(
            [
                SELECT id, UnitPrice,Name 
                FROM PricebookEntry 
                WHERE Id NOT IN: pricebookEntryIds
                AND Pricebook2Id =: order.Pricebook2Id
            ]
        ); 

        for(PricebookEntry entry : productsNotInOrder.values()){
            if(!productsInOrder.containsKey(entry.id)){
                productsInOrder.put(entry.id,entry);
            }
        }
        
        return productsInOrder.values();
    }

    @AuraEnabled
    public static String upsertOrderLineItem(String priceBookEntryId, String orderId){
        try {
            PricebookEntry entry = [SELECT id, Name, UnitPrice FROM priceBookEntry WHERE id =: priceBookEntryId]; 
            List<OrderItem> item = [SELECT id, quantity FROM OrderItem WHERE pricebookEntryId =: pricebookEntryId];
            if(item.isEmpty()){
                OrderItem orderItem = new OrderItem(
                    PricebookEntryId = entry.Id,
                    quantity = 1,
                    OrderId = orderId,
                    UnitPrice = entry.UnitPrice
                );
                item.add(orderItem);
            } else{
              item[0].quantity ++;  
            }
            Response resp = new Response();
            Database.UpsertResult[] result = Database.upsert(item);
            if(result[0].isSuccess()) {
                resp.message = 'Success';
                resp.hasError = false;
                resp.isCreated = result[0].isCreated();
                return JSON.Serialize(resp);
            } else {
                resp.message = result[0].getErrors()[0].getMessage();
                resp.hasError = true;
                resp.isCreated = result[0].isCreated();
                return JSON.Serialize(resp);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public class Response {
        public String message;
        public Boolean hasError;
        public Boolean isCreated;
    }
}

