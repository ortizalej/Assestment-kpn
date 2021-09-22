public with sharing class ExcelImportController { 

    public virtual class BulkEmployeeException extends Exception {}     
    /*
    * @param base64Data : Content of the File in JSON format 
    * @param fileName : File Name 
    * @param contentType : Type of the File (Excel)
    */
    @AuraEnabled
    public static void parseFile(String base64Data, String fileName) {
     System.debug('In ParseFile');
     try {
      System.debug('JSONfromJS::'+base64Data);
      System.debug('fileNamefromJS::'+fileName);
      
      Blob blobData = Blob.valueOf(base64Data);
      System.debug('blobData::'+blobData);
    
      createEmployeeBatchRecords(blobData);
    
     }catch(BulkEmployeeException e){
      System.debug('BulkEmployeeException::::'+e.getMessage());
      
     }catch (Exception e) {
      System.debug('Exception::::'+e);
     }
    }
    /**
    * @description: This method is used to create the Claim Batch Stage records based on the CSV Data as Input
    * @param blobData: Content of the File Uploaded by the User in Blob format 
    */
    public static void createEmployeeBatchRecords(Blob blobData)
    {
     String csvAsString;
     String[] csvFileLines;
     System.debug('blobData:::'+blobData);
     csvAsString = blobData.toString();
     system.debug('Before JSON Formator csvAsString::' + csvAsString);
     
     String csvAsString1 = jsonFormator(csvAsString);
     
     System.debug('After JSON Formator csvAsString1::'+csvAsString1);
    
     List<JSON2ApexController> objList = JSON2ApexController.parse(csvAsString1);
     System.debug('After JSON deserialize objList::'+objList);
     System.debug('objList[0]::'+objList[0]);
     
     List<Invoice__c> invoiceToInsert = new List<Invoice__c>();
     
     for(JSON2ApexController item: objList) {
      
        if(String.isBlank(item.SHIP_TO_NAME)){continue;}

      Invoice__c invoice = new Invoice__c();
      invoice.SHIP_TO_NAME__c = item.SHIP_TO_NAME;
      invoice.SALES_ORDER__c = item.SALES_ORDER;
      invoice.SALES_REP__c = item.SALES_REP;
      invoice.PROD__c = item.PROD;
      invoice.description__c = item.description;
      invoice.ORDER_QUAN__c = item.ORDER_QUAN;
      invoice.SHIP_QUAN__c = item.SHIP_QUAN;
      invoice.REASON_CODE__c = item.REASON_CODE;
      invoice.SPECIAL_ORDER__c = item.SPECIAL_ORDER;
      invoice.BUYER__c = item.BUYER;
      invoice.PROCUREMENT_NOTES__c = item.PROCUREMENT_NOTES;
      
      invoiceToInsert.add(invoice);
        
     }
     
     try{
      database.insert(invoiceToInsert);
     } catch(Exception e) {
      System.debug('Insert Exception::::'+e.getMessage());
     }        
    }
    
    public static List<JSON2ApexController> parse(String jsonString) {
     return (List<JSON2ApexController>) System.JSON.deserialize(jsonString, List<JSON2ApexController>.class);
    } 
    
    public class JSON2ApexController {
     
        public String SHIP_TO_NAME;
        public String SALES_ORDER;
        public String SALES_REP;
        public String ORDER_QUAN;
        public String SHIP_QUAN;
        public String REASON_CODE;
        public String SPECIAL_ORDER;
        public String BUYER;
        public String PROCUREMENT_NOTES;
        public String Prod;
        public String Description;
     
    }
    
    public static String jsonFormator(String jsonString) {
        String target = 'SHIP-TO NAME';
        String replacement = 'SHIP_TO_NAME';
        String jsonString1 = jsonString.replace(target, replacement);
        target = 'SALES ORDER';
        replacement = 'SALES_ORDER';
        jsonString1 = jsonString1.replace(target, replacement);
        target = 'SALES REP';
        replacement = 'SALES_REP';
        jsonString1 = jsonString1.replace(target, replacement);
        target = 'ORDER QUAN';
        replacement = 'ORDER_QUAN';
        jsonString1 = jsonString1.replace(target, replacement);
        target = 'SHIP QUAN';
        replacement = 'SHIP_QUAN';
        jsonString1 = jsonString1.replace(target, replacement);
        target = 'REASON CODE';
        replacement = 'REASON_CODE';
        jsonString1 = jsonString1.replace(target, replacement);
        target = 'SPECIAL ORDER';
        replacement = 'SPECIAL_ORDER';
        jsonString1 = jsonString1.replace(target, replacement);
        target = 'PROCUREMENT NOTES';
        replacement = 'PROCUREMENT_NOTES';
        jsonString1 = jsonString1.replace(target, replacement);
     
     return jsonString1;
    }
    
    }