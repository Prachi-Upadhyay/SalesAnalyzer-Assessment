/**
 * Class Name    : SalesAnalyzer
 * Description  : Performs sales calculations and analytics
 *                using Salesforce Order data.
 *
 * Best Practices:
 * - with sharing
 * - Bulk-safe methods
 * - Collection based processing
 * - No SOQL inside loops
 */
public with sharing class SalesAnalyzer {


    /**
     * Wrapper class for sales analysis response
     */
    public class SalesAnalysisResult {


        public Decimal totalRevenue { get; set; }

        public Integer totalOrders { get; set; }

        public Decimal averageOrderValue { get; set; }

        public Integer totalCustomers { get; set; }



        public SalesAnalysisResult() {

            totalRevenue = 0;
            totalOrders = 0;
            averageOrderValue = 0;
            totalCustomers = 0;

        }

    }




    /**
     * Analyze sales information
     *
     * @param orderIds Order Id collection
     *
     * @return SalesAnalysisResult
     */
    public static SalesAnalysisResult analyzeSales(
        Set<Id> orderIds
    ) {


        SalesAnalysisResult result =
            new SalesAnalysisResult();



        if(orderIds == null ||
           orderIds.isEmpty()) {

            return result;

        }



        List<Order> orders = [

            SELECT Id,
                   AccountId,
                   TotalAmount

            FROM Order

            WHERE Id IN :orderIds

        ];



        Decimal revenue = 0;

        Set<Id> customerIds =
            new Set<Id>();



        for(Order orderRecord : orders) {



            if(orderRecord.TotalAmount != null) {

                revenue +=
                    orderRecord.TotalAmount;

            }



            if(orderRecord.AccountId != null) {

                customerIds.add(
                    orderRecord.AccountId
                );

            }

        }



        result.totalOrders =
            orders.size();



        result.totalRevenue =
            revenue;



        result.totalCustomers =
            customerIds.size();



        if(result.totalOrders > 0) {


            result.averageOrderValue =
                result.totalRevenue /
                result.totalOrders;

        }



        return result;

    }





    /**
     * Calculate revenue by customer
     *
     * @param customerIds Account Ids
     *
     * @return Map<AccountId, Revenue>
     */
    public static Map<Id,Decimal> calculateCustomerRevenue(
        Set<Id> customerIds
    ) {


        Map<Id,Decimal> revenueMap =
            new Map<Id,Decimal>();



        if(customerIds == null ||
           customerIds.isEmpty()) {


            return revenueMap;

        }



        List<Order> orders = [

            SELECT AccountId,
                   TotalAmount

            FROM Order

            WHERE AccountId IN :customerIds

        ];



        for(Order orderRecord : orders) {


            Decimal existingRevenue =
                revenueMap.containsKey(
                    orderRecord.AccountId
                )
                ?
                revenueMap.get(
                    orderRecord.AccountId
                )
                :
                0;



            revenueMap.put(

                orderRecord.AccountId,

                existingRevenue +
                (
                    orderRecord.TotalAmount == null
                    ?
                    0
                    :
                    orderRecord.TotalAmount
                )

            );

        }



        return revenueMap;

    }





    /**
     * Get highest revenue customers
     *
     * @param customerRevenue Revenue map
     * @param limitSize Number of customers
     *
     * @return Customer Id list
     */
    public static List<Id> getTopCustomers(
        Map<Id,Decimal> customerRevenue,
        Integer limitSize
    ) {


        List<Id> result =
            new List<Id>();



        if(customerRevenue == null ||
           customerRevenue.isEmpty() ||
           limitSize == null ||
           limitSize <= 0) {


            return result;

        }



        List<Id> customerIds =
            new List<Id>();


        customerIds.addAll(
            customerRevenue.keySet()
        );



        // Sort customers by revenue descending

        for(Integer i = 0;
            i < customerIds.size();
            i++) {


            for(Integer j = i + 1;
                j < customerIds.size();
                j++) {



                if(
                    customerRevenue.get(
                        customerIds[j]
                    )
                    >
                    customerRevenue.get(
                        customerIds[i]
                    )
                ) {


                    Id temp =
                        customerIds[i];


                    customerIds[i] =
                        customerIds[j];


                    customerIds[j] =
                        temp;

                }

            }

        }



        Integer count = 0;



        for(Id customerId : customerIds) {


            result.add(customerId);


            count++;



            if(count >= limitSize) {

                break;

            }

        }



        return result;

    }
public static Decimal analyzeSales(Id orderId) {

        Order ord = [
            SELECT Id, TotalAmount
            FROM Order
            WHERE Id = :orderId
            LIMIT 1
        ];


        Decimal totalAmount = ord.TotalAmount;


        System.debug('Order Total Amount: ' + totalAmount);


        return totalAmount;
    }


}