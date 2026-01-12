*** Settings ***
Documentation     SauceDemo Product Comparison Suite
Library           SeleniumLibrary
Library           Collections

Suite Setup       Login To SauceDemo
Suite Teardown    Close Browser

*** Variables ***
${url}           https://www.saucedemo.com/
${user-name}     standard_user
${password}      secret_sauce

@{EXPECTED_PRODUCTS}
...    &{P1}
...    &{P2}
...    &{P3}
...    &{P4}
...    &{P5}
...    &{P6}

&{P1}
...    name=Sauce Labs Backpack
...    price=$29.99
...    description=carry.allTheThings() with the sleek, streamlined Sly Pack that melds uncompromising style with unequaled laptop and tablet protection.
...    image=https://www.saucedemo.com/static/media/sauce-backpack-1200x1500.0a0b85a385945026062b.jpg

&{P2}
...    name=Sauce Labs Bike Light
...    price=$9.99
...    description=A red light isn't the desired state in testing but it sure helps when riding your bike at night. Water-resistant with 3 lighting modes, 1 AAA battery included.
...    image=https://www.saucedemo.com/static/media/bike-light-1200x1500.37c843b09a7d77409d63.jpg

&{P3}
...    name=Sauce Labs Bolt T-Shirt
...    price=$15.99
...    description=Get your testing superhero on with the Sauce Labs bolt T-shirt. From American Apparel, 100% ringspun combed cotton, heather gray with red bolt.
...    image=https://www.saucedemo.com/static/media/bolt-shirt-1200x1500.c2599ac5f0a35ed5931e.jpg

&{P4}
...    name=Sauce Labs Fleece Jacket
...    price=$49.99
...    description=It's not every day that you come across a midweight quarter-zip fleece jacket capable of handling everything from a relaxing day outdoors to a busy day at the office.
...    image=https://www.saucedemo.com/static/media/sauce-pullover-1200x1500.51d7ffaf301e698772c8.jpg

&{P5}
...    name=Test.allTheThings() T-Shirt (Red)
...    price=$15.99
...    description=This classic Sauce Labs t-shirt is perfect to wear when cozying up to your keyboard to automate a few tests. Super-soft and comfy ringspun combed cotton.
...    image=https://www.saucedemo.com/static/media/red-tatt-1200x1500.30dadef477804e54fc7b.jpg

&{P6}
...    name=Sauce Labs Onesie
...    price=$7.99
...    description=Rib snap infant onesie for the junior automation engineer in development. Reinforced 3-snap bottom closure, two-needle hemmed sleeved and bottom won't unravel.
...    image=https://www.saucedemo.com/static/media/red-onesie-1200x1500.2ec615b271ef4c3bc430.jpg

*** Test Cases ***
Compare Product - Sauce Labs Backpack
    [Template]    Compare Single Product
    ${P1}

Compare Product - Sauce Labs Bike Light
    [Template]    Compare Single Product
    ${P2}

Compare Product - Sauce Labs Bolt T-Shirt
    [Template]    Compare Single Product
    ${P3}

Compare Product - Sauce Labs Fleece Jacket
    [Template]    Compare Single Product
    ${P4}

Compare Product - Test.allTheThings() T-Shirt (Red)
    [Template]    Compare Single Product
    ${P5}

Compare Product - Sauce Labs Onesie
    [Template]    Compare Single Product
    ${P6}

*** Keywords ***
Login To SauceDemo
    [Documentation]    Logs in once at the start of the suite
    Open Browser    ${url}    chrome
    Input Text      id:user-name    ${user-name}
    Input Text      id:password     ${password}
    Click Element   id:login-button
    Wait Until Element Is Visible    css:#inventory_container

Compare Single Product
    [Arguments]    ${expected}  # accept dictionary as scalar
    Log To Console    \n--- Comparing product: ${expected['name']} ---
    
    @{ui_products}=    Get Products List With Details

    # Build dictionary keyed by product name
    &{ui_dict}=    Create Dictionary
    FOR    ${p}    IN    @{ui_products}
        Set To Dictionary    ${ui_dict}    ${p['name']}    ${p}
    END

    ${name}=    Set Variable    ${expected['name']}
    ${ui_product}=    Get From Dictionary    ${ui_dict}    ${name}    default=None

    Should Not Be Empty    ${ui_product}    Product '${name}' NOT FOUND in UI

    # Compare all fields
    Should Be Equal    ${ui_product['price']}        ${expected['price']}
    Should Be Equal    ${ui_product['description']}  ${expected['description']}
    Should Be Equal    ${ui_product['image']}        ${expected['image']}

    Log To Console    ✔ Product '${name}' MATCHES

Get Products List With Details
    @{products}=    Create List

    Wait Until Page Contains Element    css=.inventory_item    timeout=10s

    @{names}=    Get WebElements    css=.inventory_item_name
    @{prices}=   Get WebElements    css=.inventory_item_price
    @{descs}=    Get WebElements    css=.inventory_item_desc
    @{images}=   Get WebElements    css=.inventory_item_img img

    ${count}=    Get Length    ${names}

    FOR    ${i}    IN RANGE    ${count}
        ${name}=    Get Text    ${names}[${i}]
        ${price}=   Get Text    ${prices}[${i}]
        ${desc}=    Get Text    ${descs}[${i}]
        ${img_url}=  Get Element Attribute    ${images}[${i}]    src

        &{product}=    Create Dictionary
        ...    name=${name}
        ...    price=${price}
        ...    description=${desc}
        ...    image=${img_url}

        Append To List    ${products}    ${product}
    END

    RETURN    ${products}
