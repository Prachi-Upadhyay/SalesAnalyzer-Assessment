@isTest
public class SalesAnalyzerTest {


    @testSetup
    static void createTestData() {


        Account acc1 = new Account(
            Name = 'Customer One'
        );

        Account acc2 = new Account(
            Name = 'Customer Two'
        );


        insert new List<Account>{
            acc1,
            acc2
        };


        Order order1 = new Order(
            AccountId = acc1.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft'
        );


        Order order2 = new Order(
            AccountId = acc2.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft'
        );


        insert new List<Order>{
            order1,
            order2
        };

    }




    @isTest
    static void testAnalyzeSalesBySet() {


        List<Order> orders = [
            SELECT Id
            FROM Order
        ];


        Set<Id> orderIds =
            new Set<Id>();


        for(Order ord : orders){

            orderIds.add(ord.Id);

        }



        Test.startTest();


        SalesAnalyzer.SalesAnalysisResult result =
            SalesAnalyzer.analyzeSales(orderIds);



        Test.stopTest();



        System.assertEquals(
            2,
            result.totalOrders
        );


        System.assertNotEquals(
            null,
            result.totalRevenue
        );


        System.assertEquals(
            2,
            result.totalCustomers
        );

    }





    @isTest
    static void testAnalyzeSalesSingleOrder(){


        Order ord = [
            SELECT Id
            FROM Order
            LIMIT 1
        ];



        Test.startTest();


        Decimal amount =
            SalesAnalyzer.analyzeSales(
                ord.Id
            );


        Test.stopTest();



        System.assertEquals(
            0,
            amount
        );

    }





    @isTest
    static void testCustomerRevenue(){



        Account acc =
            [
                SELECT Id
                FROM Account
                LIMIT 1
            ];



        Set<Id> accountIds =
            new Set<Id>();


        accountIds.add(acc.Id);



        Test.startTest();


        Map<Id,Decimal> revenue =
            SalesAnalyzer.calculateCustomerRevenue(
                accountIds
            );


        Test.stopTest();



        System.assert(
            revenue.containsKey(acc.Id)
        );


    }





    @isTest
    static void testTopCustomers(){



        Account acc1 =
            [
                SELECT Id
                FROM Account
                LIMIT 1
            ];



        Account acc2 =
            [
                SELECT Id
                FROM Account
                LIMIT 1 OFFSET 1
            ];



        Map<Id,Decimal> revenueMap =
            new Map<Id,Decimal>();


        revenueMap.put(
            acc1.Id,
            5000
        );


        revenueMap.put(
            acc2.Id,
            10000
        );



        Test.startTest();


        List<Id> topCustomers =
            SalesAnalyzer.getTopCustomers(
                revenueMap,
                1
            );


        Test.stopTest();



        System.assertEquals(
            1,
            topCustomers.size()
        );


        System.assertEquals(
            acc2.Id,
            topCustomers[0]
        );


    }


}