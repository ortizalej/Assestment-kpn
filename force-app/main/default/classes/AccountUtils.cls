public class AccountUtils {

    public static List<Account> accountsByState(String state) {
        return [SELECT id, name FROM Account WHERE BillingState =: state];
    }
}