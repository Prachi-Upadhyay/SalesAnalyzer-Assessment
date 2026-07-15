/**
 * Class Name    : ProductCatalog
 * Description  : Service class for Product Catalog operations.
 *                Provides product retrieval and availability handling.
 *
 * Best Practices:
 * - with sharing security model
 * - Collection based processing
 * - No SOQL inside loops
 * - Null handling
 */
public with sharing class ProductCatalog {


    /**
     * Wrapper class for product details
     */
    public class ProductInfo {

        public Id productId { get; set; }

        public String productName { get; set; }

        public Decimal unitPrice { get; set; }

        public Boolean isActive { get; set; }


        public ProductInfo(Product2 product) {

            this.productId = product.Id;
            this.productName = product.Name;
            this.unitPrice = product.ProductCode != null 
                            ? product.ProductCode != null ? null : null 
                            : null;
            this.isActive = product.IsActive;

        }
    }



    /**
     * Retrieve active products from catalog
     *
     * @return List<Product2>
     */
    public static List<Product2> getActiveProducts() {


        return [
            SELECT Id,
                   Name,
                   ProductCode,
                   Description,
                   IsActive
            FROM Product2
            WHERE IsActive = true
            ORDER BY Name
        ];

    }




    /**
     * Get products by Id
     *
     * @param productIds Set of Product Ids
     *
     * @return Map<ProductId, Product2>
     */
    public static Map<Id, Product2> getProductsByIds(
        Set<Id> productIds
    ) {


        Map<Id, Product2> productMap =
            new Map<Id, Product2>();


        if(productIds == null || productIds.isEmpty()) {

            return productMap;

        }



        List<Product2> products = [

            SELECT Id,
                   Name,
                   ProductCode,
                   Description,
                   IsActive

            FROM Product2

            WHERE Id IN :productIds

        ];



        productMap.putAll(products);


        return productMap;

    }




    /**
     * Search products by name
     *
     * @param searchKeyword Product name keyword
     *
     * @return List<Product2>
     */
    public static List<Product2> searchProducts(
        String searchKeyword
    ) {


        if(String.isBlank(searchKeyword)) {

            return new List<Product2>();

        }



        String searchValue =
            '%' + searchKeyword + '%';



        return [

            SELECT Id,
                   Name,
                   ProductCode,
                   Description,
                   IsActive

            FROM Product2

            WHERE Name LIKE :searchValue

            AND IsActive = true

            ORDER BY Name

        ];

    }




    /**
     * Validate product availability
     *
     * @param productIds Product Ids
     *
     * @return Map<ProductId, Boolean>
     */
    public static Map<Id, Boolean> checkProductAvailability(
        Set<Id> productIds
    ) {


        Map<Id, Boolean> availability =
            new Map<Id, Boolean>();


        if(productIds == null || productIds.isEmpty()) {

            return availability;

        }



        for(Product2 product : getProductsByIds(productIds).values()) {


            availability.put(
                product.Id,
                product.IsActive
            );

        }


        return availability;

    }




    /**
     * Custom Exception
     */
    public class ProductCatalogException extends Exception {}

}