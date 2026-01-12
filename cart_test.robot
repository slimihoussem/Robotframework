*** Settings ***
Resource    cart_keywords.robot
Suite Setup     Run Keywords    Open SauceDemo    AND    Login To SauceDemo
Suite Teardown  Close All Browsers
Test Setup      Run Keyword And Ignore Error    Ensure Clean Cart
Test Teardown   Run Keyword If Test Failed    Capture Page Screenshot

*** Test Cases ***
Test Add Single Product To Cart
    [Documentation]    Test adding a single product to cart
    [Tags]    smoke
    # Add product
    Add Product To Cart    ${BACKPACK}
    
    # Verify cart count
    Verify Cart Item Count    1
    
    # Verify product in cart
    Go To Cart
    Verify Product In Cart    ${BACKPACK}

Test Remove Product From Cart
    [Documentation]    Test removing a product from cart
    [Tags]    smoke
    # Setup: Add product first
    Add Product To Cart    ${BIKE_LIGHT}
    Verify Cart Item Count    1
    
    # Go to cart and remove product
    Go To Cart
    Remove Product From Cart On Cart Page    ${BIKE_LIGHT}
    
    # Verify removal
    Verify Cart Item Count    0
    
    # Verify cart is empty
    ${items}=    Get All Cart Items
    Should Be Empty    ${items}

Test Add Multiple Products To Cart
    [Documentation]    Test adding multiple products to cart
    [Tags]    regression
    # Add multiple products
    Add Multiple Products To Cart    ${BACKPACK}    ${BIKE_LIGHT}    ${BOLT_T_SHIRT}
    
    # Verify cart count
    Verify Cart Item Count    3
    
    # Verify all products are in cart
    Go To Cart
    Verify Product In Cart    ${BACKPACK}
    Verify Product In Cart    ${BIKE_LIGHT}
    Verify Product In Cart    ${BOLT_T_SHIRT}

Test Remove Multiple Products From Cart
    [Documentation]    Test removing multiple products from cart
    [Tags]    regression
    # Setup: Add multiple products
    Add Multiple Products To Cart    ${BACKPACK}    ${BIKE_LIGHT}    ${BOLT_T_SHIRT}
    Verify Cart Item Count    3
    
    # Go to cart and remove some products
    Go To Cart
    Remove Multiple Products From Cart    ${BACKPACK}    ${BIKE_LIGHT}
    
    # Verify remaining product
    Verify Cart Item Count    1
    Verify Product In Cart    ${BOLT_T_SHIRT}
    Verify Product Not In Cart    ${BACKPACK}
    Verify Product Not In Cart    ${BIKE_LIGHT}

Test Add And Remove From Products Page
    [Documentation]    Test adding and removing items directly from products page
    [Tags]    smoke
    # Start with clean page
    Refresh And Wait
    
    # Add items
    Add Product To Cart    ${BACKPACK}
    Verify Cart Item Count    1
    
    Add Product To Cart    ${BIKE_LIGHT}
    Wait For Cart To Update    2
    
    # Verify both items are in cart
    Go To Cart
    Verify Product In Cart    ${BACKPACK}
    Verify Product In Cart    ${BIKE_LIGHT}
    
    # Go back to products
    Back To Products
    
    # Remove one item from products page
    Remove Product From Cart On Product Page    ${BACKPACK}
    Wait For Cart To Update    1
    
    # Verify only one item remains in cart
    Go To Cart
    Verify Product In Cart    ${BIKE_LIGHT}
    Verify Product Not In Cart    ${BACKPACK}

Test Cart Operations Flow
    [Documentation]    Comprehensive test of add/remove operations
    [Tags]    regression
    # Phase 1: Add items
    Add Product To Cart    ${BACKPACK}
    Add Product To Cart    ${BIKE_LIGHT}
    Wait For Cart To Update    2
    
    # Phase 2: Remove one item from cart page
    Go To Cart
    Remove Product From Cart On Cart Page    ${BACKPACK}
    Wait For Cart To Update    1
    Verify Product In Cart    ${BIKE_LIGHT}
    
    # Phase 3: Add more items
    Back To Products
    Add Product To Cart    ${BOLT_T_SHIRT}
    Add Product To Cart    ${FLEECE_JACKET}
    Wait For Cart To Update    3
    
    # Phase 4: Verify final cart contents
    Go To Cart
    ${cart_items}=    Get All Cart Items
    Log    Final cart items: ${cart_items}
    Should Contain    ${cart_items}    ${BIKE_LIGHT}
    Should Contain    ${cart_items}    ${BOLT_T_SHIRT}
    Should Contain    ${cart_items}    ${FLEECE_JACKET}
    List Should Not Contain Value    ${cart_items}    ${BACKPACK}

Test Empty Cart Verification
    [Documentation]    Test that empty cart shows correct state
    [Tags]    smoke
    # Start with empty cart (ensured by Test Setup)
    ${is_empty}=    Is Cart Empty
    Should Be True    ${is_empty}
    
    # Go to cart page
    Go To Cart
    
    # Verify empty cart state
    Page Should Contain    Your Cart
    ${items}=    Get All Cart Items
    Should Be Empty    ${items}
    
    # Verify cart list is present but empty
    Page Should Contain Element    class=cart_list
    ${item_count}=    Get Element Count    class=cart_item
    Should Be Equal As Numbers    ${item_count}    0
    
    # Verify checkout button exists
    Page Should Contain Button    ${CHECKOUT_BUTTON}
    
    # Go back to products
    Back To Products
    Wait Until Element Is Visible    ${INVENTORY_CONTAINER}