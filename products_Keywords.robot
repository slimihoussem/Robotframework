*** Settings ***
Documentation    Common keywords for SauceDemo tests
Library          SeleniumLibrary
Library          Collections

*** Variables ***
${url}           https://www.saucedemo.com/
${user-name}     standard_user
${password}      secret_sauce

*** Keywords ***
Login To SauceDemo
    [Documentation]    Logs in to SauceDemo
    Open Browser    ${url}    chrome
    Maximize Browser Window
    Input Text      id:user-name    ${user-name}
    Input Text      id:password     ${password}
    Click Element   id:login-button
    Wait Until Element Is Visible    css:#inventory_container
    Page Should Contain    Products
    Log    Successfully logged in to SauceDemo

Get All Products From Page
    [Documentation]    Extracts all product details from the page
    [Return]    List of product dictionaries
    
    @{products}=    Create List
    Wait Until Page Contains Element    css:.inventory_item    timeout=10s
    
    # Get all product elements
    ${item_count}=    Get Element Count    css:.inventory_item
    Log    Found ${item_count} product items on page
    
    FOR    ${index}    IN RANGE    0    ${item_count}
        ${index_plus_one}=    Evaluate    ${index} + 1
        
        # Build locators for each element
        ${name}=    Get Text    css:.inventory_item:nth-child(${index_plus_one}) .inventory_item_name
        ${price}=   Get Text    css:.inventory_item:nth-child(${index_plus_one}) .inventory_item_price
        ${desc}=    Get Text    css:.inventory_item:nth-child(${index_plus_one}) .inventory_item_desc
        ${img_url}=    Get Element Attribute    css:.inventory_item:nth-child(${index_plus_one}) img    src
        
        &{product}=    Create Dictionary
        ...    name=${name}
        ...    price=${price}
        ...    description=${desc}
        ...    image=${img_url}
        
        Append To List    ${products}    ${product}
        Log    Found product: ${name} - ${price}
    END
    
    Log    Extracted ${products.__len__()} products from page
    RETURN    ${products}

Get Product Database
    [Documentation]    Returns the product database dictionary
    [Return]    Product database
    
    &{PRODUCT_DATABASE}=    Create Dictionary
    
    # Add all products to database
    &{BACKPACK}=    Create Dictionary
    ...    name=Sauce Labs Backpack
    ...    price=$29.99
    ...    description=carry.allTheThings() with the sleek, streamlined Sly Pack that melds uncompromising style with unequaled laptop and tablet protection.
    ...    image=https://www.saucedemo.com/static/media/sauce-backpack-1200x1500.0a0b85a385945026062b.jpg
    Set To Dictionary    ${PRODUCT_DATABASE}    ${BACKPACK['name']}    ${BACKPACK}
    
    &{BIKE_LIGHT}=    Create Dictionary
    ...    name=Sauce Labs Bike Light
    ...    price=$9.99
    ...    description=A red light isn't the desired state in testing but it sure helps when riding your bike at night. Water-resistant with 3 lighting modes, 1 AAA battery included.
    ...    image=https://www.saucedemo.com/static/media/bike-light-1200x1500.37c843b09a7d77409d63.jpg
    Set To Dictionary    ${PRODUCT_DATABASE}    ${BIKE_LIGHT['name']}    ${BIKE_LIGHT}
    
    &{BOLT_TSHIRT}=    Create Dictionary
    ...    name=Sauce Labs Bolt T-Shirt
    ...    price=$15.99
    ...    description=Get your testing superhero on with the Sauce Labs bolt T-shirt. From American Apparel, 100% ringspun combed cotton, heather gray with red bolt.
    ...    image=https://www.saucedemo.com/static/media/bolt-shirt-1200x1500.c2599ac5f0a35ed5931e.jpg
    Set To Dictionary    ${PRODUCT_DATABASE}    ${BOLT_TSHIRT['name']}    ${BOLT_TSHIRT}
    
    &{FLEECE_JACKET}=    Create Dictionary
    ...    name=Sauce Labs Fleece Jacket
    ...    price=$49.99
    ...    description=It's not every day that you come across a midweight quarter-zip fleece jacket capable of handling everything from a relaxing day outdoors to a busy day at the office.
    ...    image=https://www.saucedemo.com/static/media/sauce-pullover-1200x1500.51d7ffaf301e698772c8.jpg
    Set To Dictionary    ${PRODUCT_DATABASE}    ${FLEECE_JACKET['name']}    ${FLEECE_JACKET}
    
    &{RED_TSHIRT}=    Create Dictionary
    ...    name=Test.allTheThings() T-Shirt (Red)
    ...    price=$15.99
    ...    description=This classic Sauce Labs t-shirt is perfect to wear when cozying up to your keyboard to automate a few tests. Super-soft and comfy ringspun combed cotton.
    ...    image=https://www.saucedemo.com/static/media/red-tatt-1200x1500.30dadef477804e54fc7b.jpg
    Set To Dictionary    ${PRODUCT_DATABASE}    ${RED_TSHIRT['name']}    ${RED_TSHIRT}
    
    &{ONESIE}=    Create Dictionary
    ...    name=Sauce Labs Onesie
    ...    price=$7.99
    ...    description=Rib snap infant onesie for the junior automation engineer in development. Reinforced 3-snap bottom closure, two-needle hemmed sleeved and bottom won't unravel.
    ...    image=https://www.saucedemo.com/static/media/red-onesie-1200x1500.2ec615b271ef4c3bc430.jpg
    Set To Dictionary    ${PRODUCT_DATABASE}    ${ONESIE['name']}    ${ONESIE}
    
    Log    Created product database with ${PRODUCT_DATABASE.__len__()} items
    RETURN    ${PRODUCT_DATABASE}

Get Product Details
    [Arguments]    ${product_name}
    [Documentation]    Get product details by name
    [Return]    Product dictionary
    
    ${database}=    Get Product Database
    
    ${exists}=    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${database}    ${product_name}
    
    IF    not ${exists}
        ${available_products}=    Get Dictionary Keys    ${database}
        Fail    Product '${product_name}' not found. Available products: ${available_products}
    END
    
    ${product}=    Get From Dictionary    ${database}    ${product_name}
    RETURN    ${product}

Find Product In List
    [Arguments]    ${products_list}    ${product_name}
    [Documentation]    Find a product by name in a list
    [Return]    Product dictionary or None
    
    FOR    ${product}    IN    @{products_list}
        ${name}=    Get From Dictionary    ${product}    name
        IF    '${name}' == '${product_name}'
            RETURN    ${product}
        END
    END
    
    RETURN    ${None}

Validate Product Details
    [Arguments]    ${ui_product}    ${expected_product}
    [Documentation]    Validate all product details match
    
    ${expected_name}=    Get From Dictionary    ${expected_product}    name
    Log    Validating product: ${expected_name}
    
    ${ui_price}=    Get From Dictionary    ${ui_product}    price
    ${expected_price}=    Get From Dictionary    ${expected_product}    price
    Should Be Equal    ${ui_price}    ${expected_price}
    Log    ✓ Price matches: ${ui_price}
    
    ${ui_desc}=    Get From Dictionary    ${ui_product}    description
    ${expected_desc}=    Get From Dictionary    ${expected_product}    description
    Should Be Equal    ${ui_desc}    ${expected_desc}
    Log    ✓ Description matches
    
    ${ui_image}=    Get From Dictionary    ${ui_product}    image
    ${expected_image}=    Get From Dictionary    ${expected_product}    image
    Should Be Equal    ${ui_image}    ${expected_image}
    Log    ✓ Image URL matches
    
    Log    ✔ All validations passed for ${expected_name}