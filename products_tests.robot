*** Settings ***
Documentation     Test single product using external keywords
Resource          products_Keywords.robot

Suite Setup       Login To SauceDemo
Suite Teardown    Close Browser

*** Variables ***
${PRODUCT_NAME}  Sauce Labs Backpack  # Default, can be overridden

*** Test Cases ***
Verify Product Details
    [Documentation]    Verify product details match expected values
    
    Log    Testing product: ${PRODUCT_NAME}
    
    # Get expected product details
    ${expected_product}=    Get Product Details    ${PRODUCT_NAME}
    Log    Expected product: ${expected_product['name']} - ${expected_product['price']}
    
    # Get all products from page - FIXED: Store result in a scalar first
    ${products_result}=    Get All Products From Page
    @{ui_products}=    Create List    @{products_result}
    
    Log    Found ${ui_products.__len__()} products on page
    
    # Find the product in the list
    ${ui_product}=    Find Product In List    ${ui_products}    ${PRODUCT_NAME}
    
    # Verify product exists
    IF    ${ui_product} is ${None}
        Fail    Product '${PRODUCT_NAME}' not found on page!
    END
    
    # Validate details
    Validate Product Details    ${ui_product}    ${expected_product}
    
    Log    ✓ Product '${PRODUCT_NAME}' validation passed