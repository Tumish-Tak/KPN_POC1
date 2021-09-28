**Assignment Use Case:**

Customer would like to be able to add products to the Order while not leaving the order detail page.
Build 2 LWC components and put them on the OrderDetail Page:

    1.) "Available Products" - Display available products suitable for the Order based on Order's PriceBook

    2.) "Order Products" - Display products added to the current Order.

**Acceptance Criteria**:

1. The solution is available as a repository on GitHub/Bitbucket etc

    a. Code should be deployable using SFDX

    b. Use git readme for feedback and notes

    c. Try to commit while developing

2. The “Available Products” component displays orderable products in a 2-column list displaying Name and List Price

    a. Products that are already added to the order should appear on top

    b. Each product can only appear once in the list

    c. (Optional) Sort by column

    d. (Optional) Search by product name

3. The “Available Products” component has to provide the ability for the user to add a product from the list to the order

    a. When the same product is not yet added to the order it will be added with a quantity of 1

    b. When the product already exists the quantity of the existing order product should be increased by 1

4. “Order Products” component has to display the order products in a table displaying the Name, Unit Price, Quantity and Total Price

    a. When the user adds a new product or updates an existing product on the order (see point 3) the list is refreshed to display the newly added

    b. (Optional) Sort the list by column

5. “Order Products” component has an “Activate” button that sets the status of the order and order items to “Activated”

    a. When activated the end user will not be able to add new order items or confirm the order for a second time.

6. A test coverage of at least 80% for both APEX components is required.

7. We would like to see LWC, but Aura/Vlocity is ok as well.

8. Please use apex for queries, DMLs.

9. Create a Salesforce Developer login for this assignment and build it as a SFDX project.

**Solution Developed:**
    LWC Components and their Controller and Service classes:

    a. productList (Parent Component)
        >productList.html
        >productList.js
        >productList.js-meta.xml
        >ProductListController.cls
        >ProductListDataService.cls
        >TestProductListcontroller.cls

    b. orderProductList (Child Component)
        >orderProductList.html
        >orderProductList.js
        >orderProductList.js-meta.xml
        >OrderProductListController.cls
        >OrderProductListDataService.cls
        >TestOrderProductListController.cls

    c. Test DataFactory Class
        >TestDataFactory.cls

**Pre-requisites and Limitation:**

    1.) The Order should have PriceBook2Id populated so that the Available Products LWC is loaded properly.
    2.) For existing draft orders there should not be any existing multiple order line items having same Product2Id Otherwise the quantity increment logic will fail.
    3.) The provided solution doesn't covers the integration part which was mentioned in the original UseCase word doc shared earlier. This solution was developed only for the main acceptance criteria.

**Demo Video Link**: 

https://vimeo.com/616073668
