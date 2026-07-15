/**
 * Class Name    : OrderItemService
 * Description  : Service class for Salesforce OrderItem processing.
 *
 * Handles:
 * - Fetching order line items
 * - Calculating order totals
 * - Product quantity analysis
 */
public with sharing class OrderItemService {


    /**
     * Get Order Items grouped by Order Id
     *
     * @param orderIds Set of Order Ids
     * @return Map<OrderId, List<OrderItem>>
     */
    public static Map<Id, List<OrderItem>> getItemsByOrders(
        Set<Id> orderIds
    ) {

        Map<Id, List<OrderItem>> orderItemMap =
            new Map<Id, List<OrderItem>>();


        if(orderIds == null || orderIds.isEmpty()) {
            return orderItemMap;
        }


        List<OrderItem> orderItems = [

            SELECT Id,
                   OrderId,
                   Product2Id,
                   Product2.Name,
                   Quantity,
                   UnitPrice,
                   TotalPrice

            FROM OrderItem

            WHERE OrderId IN :orderIds

        ];



        for(OrderItem item : orderItems) {


            if(!orderItemMap.containsKey(item.OrderId)) {

                orderItemMap.put(
                    item.OrderId,
                    new List<OrderItem>()
                );

            }


            orderItemMap.get(item.OrderId)
                        .add(item);

        }


        return orderItemMap;

    }




    /**
     * Calculate total amount of an order
     *
     * @param orderId Order Id
     * @return Total Amount
     */
    public static Decimal calculateOrderTotal(
        Id orderId
    ) {


        Decimal totalAmount = 0;


        if(orderId == null) {
            return totalAmount;
        }



        List<OrderItem> items = [

            SELECT TotalPrice

            FROM OrderItem

            WHERE OrderId = :orderId

        ];



        for(OrderItem item : items) {


            if(item.TotalPrice != null) {

                totalAmount += item.TotalPrice;

            }

        }


        return totalAmount;

    }





    /**
     * Calculate quantity sold per product
     *
     * @param orderIds Order Id collection
     *
     * @return ProductId and Quantity Map
     */
    public static Map<Id, Decimal> getProductQuantitySummary(
        Set<Id> orderIds
    ) {


        Map<Id, Decimal> quantityMap =
            new Map<Id, Decimal>();


        if(orderIds == null || orderIds.isEmpty()) {

            return quantityMap;

        }



        List<OrderItem> items = [

            SELECT Product2Id,
                   Quantity

            FROM OrderItem

            WHERE OrderId IN :orderIds

        ];



        for(OrderItem item : items) {


            Decimal existingQuantity =
                quantityMap.containsKey(item.Product2Id)
                ?
                quantityMap.get(item.Product2Id)
                :
                0;



            quantityMap.put(
                item.Product2Id,
                existingQuantity + item.Quantity
            );

        }



        return quantityMap;

    }


}