@isTest
public class AccountTriggerTest {

    @isTest static void BillingAndShippingStateSameValue(){
		List<Account> accs = new List<Account>();
        for(Integer i = 0; i < 200; i++) {
            Account acc = new Account(
                Name = 'test',
                BillingState = 'CA'
            );
            accs.add(acc);
        }
        insert accs;
        System.assertEquals(200, [SELECT id FROM Account WHERE ShippingState = 'CA' ].size());
    }
}