/**
 * Class Name    : OrderService
 * Description  : Service class for Order related business operations.
 *
 * Handles:
 * - Order retrieval
 * - Order summaries
 * - Order total calculation
 * - Order status updates
 *
 * Best Practices:
 * - with sharing
 * - Bulk-safe
 * - Collection based processing
 * - No SOQL/DML inside loops
 */
public with sharing class OrderService {


    /**
     * Wrapper class for Order Summary
     */
    public class OrderSummary {


        public Id orderId { get; set; }

        public String orderStatus { get; set; }

        public Decimal orderAmount { get; set; }

        public Integer itemCount { get; set; }


        public OrderSummary() {

            orderAmount = 0;
            itemCount = 0;

        }

    }



    /**
     * Get Orders by Ids
     *
     * @param orderIds Order Id collection
     *
     * @return List<Order>
     */
    public static List<Order> getOrdersByIds(
        Set<Id> orderIds
    ) {


        if(orderIds == null || orderIds.isEmpty()) {

            return new List<Order>();

        }



        return [

            SELECT Id,
                   AccountId,
                   Status,
                   EffectiveDate,
                   TotalAmount

            FROM Order

            WHERE Id IN :orderIds

        ];

    }





    /**
     * Create Order Summary
     *
     * @param orderIds Order Id collection
     *
     * @return Map<OrderId, OrderSummary>
     */
    public static Map<Id, OrderSummary> getOrderSummary(
        Set<Id> orderIds
    ) {


        Map<Id, OrderSummary> summaryMap =
            new Map<Id, OrderSummary>();



        if(orderIds == null || orderIds.isEmpty()) {

            return summaryMap;

        }



        List<Order> orders =
            getOrdersByIds(orderIds);



        Map<Id,List<OrderItem>> orderItems =
            OrderItemService.getItemsByOrders(
                orderIds
            );



        for(Order orderRecord : orders) {


            OrderSummary summary =
                new OrderSummary();


            summary.orderId =
                orderRecord.Id;


            summary.orderStatus =
                orderRecord.Status;



            summary.orderAmount =
                orderRecord.TotalAmount;



            if(orderItems.containsKey(orderRecord.Id)) {


                summary.itemCount =
                    orderItems.get(orderRecord.Id).size();

            }



            summaryMap.put(
                orderRecord.Id,
                summary
            );

        }



        return summaryMap;

    }





    /**
     * Calculate total sales amount
     *
     * @param orders Orders
     *
     * @return Total Amount
     */
    public static Decimal calculateTotalSales(
        List<Order> orders
    ) {


        Decimal totalSales = 0;



        if(orders == null || orders.isEmpty()) {

            return totalSales;

        }



        for(Order orderRecord : orders) {


            if(orderRecord.TotalAmount != null) {


                totalSales +=
                    orderRecord.TotalAmount;

            }

        }



        return totalSales;

    }





    /**
     * Update Order Status in Bulk
     *
     * @param orderIds Order Ids
     * @param newStatus New Status
     */
    public static void updateOrderStatus(
        Set<Id> orderIds,
        String newStatus
    ) {



        if(orderIds == null ||
           orderIds.isEmpty() ||
           String.isBlank(newStatus)) {

            return;

        }



        List<Order> orders = [

            SELECT Id,
                   Status

            FROM Order

            WHERE Id IN :orderIds

        ];



        for(Order orderRecord : orders) {


            orderRecord.Status =
                newStatus;

        }



        update orders;

    }




    /**
     * Custom Exception
     */
    public class OrderServiceException extends Exception {}

}