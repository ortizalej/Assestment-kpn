public  class OrderRest {
    public static Boolean sentOrderToExternalSystem(OrderRequest request){
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        
        System.debug('REQUEST'+JSON.serialize(request));
        req.setEndpoint('https://kpn-assestment.requestcatcher.com/test');
        req.setMethod('POST');
        req.setHeader('content-type', 'application/json');
        req.setBody(JSON.Serialize(request));
        try {
            res = http.send(req);
        } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            System.debug(res.toString());
        }
        if(res.getstatusCode() == 200) {
            return true;
        } else {
            return false;
        }
        
    }

    public class OrderRequest {
        public String accountNumber;
        public String orderNumber;
        public String type;
        public String status;
        public List<OrderItemRequest> orderProducts;
        public OrderRequest(){

        }
        
    }

    public class OrderItemRequest {
        public String name;
        public String code;
        public Decimal unitPrice;
        public Integer quantity;
        public OrderItemRequest(){

        }


    }
}
