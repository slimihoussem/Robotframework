*** Settings ***
Library    SeleniumLibrary
Library    Collections
Library    String

*** Variables ***
${LOGIN_URL}        https://www.saucedemo.com/
${PRODUCTS_URL}     https://www.saucedemo.com/inventory.html
${CART_URL}         https://www.saucedemo.com/cart.html
${USERNAME}         standard_user
${PASSWORD}         secret_sauce

# Product Names (exact as shown on website)
${BACKPACK}         Sauce Labs Backpack
${BIKE_LIGHT}       Sauce Labs Bike Light
${BOLT_T_SHIRT}     Sauce Labs Bolt T-Shirt
${FLEECE_JACKET}    Sauce Labs Fleece Jacket
${ONESIE}           Sauce Labs Onesie
${RED_TSHIRT}       Test.allTheThings() T-Shirt (Red)

# Locators
${USERNAME_FIELD}   id=user-name
${PASSWORD_FIELD}   id=password
${LOGIN_BUTTON}     id=login-button
${CART_ICON}        class=shopping_cart_link
${CART_BADGE}       class=shopping_cart_badge
${CONTINUE_SHOPPING}  id=continue-shopping
${CHECKOUT_BUTTON}  id=checkout
${INVENTORY_CONTAINER}  id=inventory_container

*** Keywords ***
Open SauceDemo
    [Documentation]    Opens the SauceDemo website
    Open Browser    ${LOGIN_URL}    chrome
    Maximize Browser Window
    Set Selenium Speed    0.5
    Set Selenium Timeout    15 seconds

Login To SauceDemo
    [Documentation]    Logs into SauceDemo with standard credentials
    Wait Until Element Is Visible    ${USERNAME_FIELD}
    Input Text    ${USERNAME_FIELD}    ${USERNAME}
    Input Password    ${PASSWORD_FIELD}    ${PASSWORD}
    Click Button    ${LOGIN_BUTTON}
    Wait Until Element Is Visible    ${INVENTORY_CONTAINER}
    Page Should Contain    Products

Add Product To Cart
    [Documentation]    Adds a specific product to cart
    [Arguments]    ${product_name}
    ${add_button}=    Set Variable    //div[text()='${product_name}']/ancestor::div[@class='inventory_item_description']//button[text()='Add to cart']
    Wait Until Element Is Visible    ${add_button}    timeout=15
    Click Button    ${add_button}
    Log    Added ${product_name} to cart
    Sleep    1  # Wait for cart to update

Remove Product From Cart On Product Page
    [Documentation]    Removes a specific product from cart while on products page
    [Arguments]    ${product_name}
    ${remove_button}=    Set Variable    //div[text()='${product_name}']/ancestor::div[@class='inventory_item_description']//button[text()='Remove']
    Wait Until Element Is Visible    ${remove_button}    timeout=15
    Click Button    ${remove_button}
    Log    Removed ${product_name} from cart on products page
    Sleep    1  # Wait for cart to update

Remove Product From Cart On Cart Page
    [Documentation]    Removes a specific product from cart while on cart page
    [Arguments]    ${product_name}
    ${remove_button}=    Set Variable    //div[text()='${product_name}']/ancestor::div[@class='cart_item']//button[text()='Remove']
    Wait Until Element Is Visible    ${remove_button}    timeout=15
    Click Button    ${remove_button}
    Log    Removed ${product_name} from cart on cart page
    Sleep    1  # Wait for cart to update

Go To Cart
    [Documentation]    Navigates to the cart page
    Wait Until Element Is Visible    ${CART_ICON}
    Click Element    ${CART_ICON}
    Wait Until Element Is Visible    css=.cart_list    timeout=15
    Page Should Contain    Your Cart

Get Cart Items Count
    [Documentation]    Returns the number of items in cart from the cart icon
    ${count}=    Get Element Count    ${CART_BADGE}
    IF    ${count} > 0
        ${cart_count}=    Get Text    ${CART_BADGE}
        RETURN    ${cart_count}
    ELSE
        RETURN    0
    END

Verify Product In Cart
    [Documentation]    Verifies a specific product is in the cart
    [Arguments]    ${product_name}
    ${item_locator}=    Set Variable    //div[@class='inventory_item_name' and text()='${product_name}']
    Wait Until Element Is Visible    ${item_locator}    timeout=15
    Page Should Contain Element    ${item_locator}

Verify Product Not In Cart
    [Documentation]    Verifies a specific product is NOT in the cart
    [Arguments]    ${product_name}
    ${item_locator}=    Set Variable    //div[@class='inventory_item_name' and text()='${product_name}']
    Page Should Not Contain Element    ${item_locator}

Get All Cart Items
    [Documentation]    Returns a list of all product names in the cart
    ${items}=    Create List
    ${elements}=    Get WebElements    class=inventory_item_name
    FOR    ${element}    IN    @{elements}
        ${item_name}=    Get Text    ${element}
        Append To List    ${items}    ${item_name}
    END
    RETURN    ${items}

Verify Cart Contains Exactly
    [Documentation]    Verifies cart contains exactly the specified products (order doesn't matter)
    [Arguments]    @{expected_products}
    ${cart_items}=    Get All Cart Items
    Sort List    ${cart_items}
    ${expected_sorted}=    Copy List    ${expected_products}
    Sort List    ${expected_sorted}
    Lists Should Be Equal    ${cart_items}    ${expected_sorted}

Verify Cart Item Count
    [Documentation]    Verifies the cart contains specific number of items
    [Arguments]    ${expected_count}
    ${actual_count}=    Get Cart Items Count
    Should Be Equal As Numbers    ${actual_count}    ${expected_count}

Add Multiple Products To Cart
    [Documentation]    Adds multiple products to cart
    [Arguments]    @{products}
    FOR    ${product}    IN    @{products}
        Add Product To Cart    ${product}
    END

Remove Multiple Products From Cart
    [Documentation]    Removes multiple products from cart while on cart page
    [Arguments]    @{products}
    FOR    ${product}    IN    @{products}
        Remove Product From Cart On Cart Page    ${product}
    END

Clear Cart Completely
    [Documentation]    Completely clears the cart with robust error handling
    ${cart_count}=    Get Cart Items Count
    Log    Current cart count before clearing: ${cart_count}
    
    IF    ${cart_count} > 0
        # Go to cart
        Click Element    ${CART_ICON}
        Wait Until Element Is Visible    css=.cart_list    timeout=15
        
        # Remove all items
        ${max_attempts}=    Set Variable    10
        FOR    ${attempt}    IN RANGE    ${max_attempts}
            ${remove_buttons}=    Get WebElements    xpath=//button[text()='Remove']
            ${button_count}=    Get Length    ${remove_buttons}
            Exit For Loop If    ${button_count} == 0
            
            FOR    ${button}    IN    @{remove_buttons}
                Click Button    ${button}
                Sleep    1
            END
            
            # Check if cart is now empty
            ${current_count}=    Get Cart Items Count
            Exit For Loop If    ${current_count} == 0
            
            Sleep    1
        END
        
        # Go back to products
        Click Button    ${CONTINUE_SHOPPING}
        Wait Until Element Is Visible    ${INVENTORY_CONTAINER}    timeout=15
        
        # Final verification
        ${final_count}=    Get Cart Items Count
        Should Be Equal As Numbers    ${final_count}    0
    ELSE
        Log    Cart is already empty
    END

Back To Products
    [Documentation]    Navigates back to products page
    Click Button    ${CONTINUE_SHOPPING}
    Wait Until Element Is Visible    ${INVENTORY_CONTAINER}    timeout=15
    Page Should Contain    Products

Ensure Clean Cart
    [Documentation]    Ensures cart is completely clean before test
    Log    Ensuring clean cart before test...
    
    # Navigate to products page first
    Go To    ${PRODUCTS_URL}
    Wait Until Element Is Visible    ${INVENTORY_CONTAINER}    timeout=15
    
    # Clear cart
    Clear Cart Completely
    
    # Verify cart is empty
    ${cart_count}=    Get Cart Items Count
    IF    ${cart_count} != 0
        Log    Warning: Cart count is ${cart_count}, attempting additional cleanup
        Clear Cart Completely  # Try one more time
        ${final_count}=    Get Cart Items Count
        IF    ${final_count} != 0
            Log    Cart still not empty after second attempt. Count: ${final_count}
        END
    END
    
    Log    Cart cleanup completed

Wait For Cart To Update
    [Documentation]    Waits for cart to update to expected count
    [Arguments]    ${expected_count}
    Wait Until Keyword Succeeds    10s    1s
    ...    Verify Cart Item Count    ${expected_count}

Is Cart Empty
    [Documentation]    Checks if cart is empty
    ${cart_count}=    Get Cart Items Count
    ${is_empty}=    Evaluate    int(${cart_count}) == 0
    RETURN    ${is_empty}

Refresh And Wait
    [Documentation]    Refreshes page and waits for elements
    Reload Page
    Wait Until Element Is Visible    ${INVENTORY_CONTAINER}    timeout=15