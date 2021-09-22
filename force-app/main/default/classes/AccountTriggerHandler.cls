public class AccountTriggerHandler {

    public static void CreateAccounts(List<Account> accounts) {
        for(Account account : accounts){
            account.ShippingState = account.BillingState;
        }
    }
}