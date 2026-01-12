*** Settings ***
Documentation  Connect to saucedemo.com.
#Library  OperatingSystem
Library  SeleniumLibrary
Library  Collections

*** Variables ***
${url}  https://www.saucedemo.com/
${user-name}  standard_user
${password}  secret_sauce

*** Variables ***
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

*** Keywords ***
Get Products List With Details
    @{products}=    Create List

    Wait Until Page Contains Element    css=.inventory_item    timeout=10s

    @{names}=    Get WebElements    css=.inventory_item_name
    @{prices}=   Get WebElements    css=.inventory_item_price
    @{descs}=    Get WebElements    css=.inventory_item_desc
    @{images}=    Get WebElements    css=.inventory_item_img img

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

*** Test Cases ***
Connect to saucedemo.com and closer browser
    Log  login
    Open Browser  ${url}  chrome
	Input Text  user-name  ${user-name} 
	Input Text  password  ${password}
	Click Element  css=#login-button
	Wait Until Element Is visible  css=#inventory_container
	
Read All SauceDemo Products
	@{product_list}=    Get Products List With Details
    Log To Console    \n===== PRODUCT LIST =====
    FOR    ${p}    IN    @{product_list}
        Log To Console    Name: ${p['name']} | Price: ${p['price']} | Desc: ${p['description']} | Image URL: ${p['image']}
    END
	
Compare Products With Expected List
    Log To Console    ===== START PRODUCT COMPARISON =====

    @{ui_products}=        Get Products List With Details
    ${ui_count}=           Get Length    ${ui_products}
    ${expected_count}=     Get Length    ${EXPECTED_PRODUCTS}

    Log To Console    UI products count: ${ui_count}
    Log To Console    Expected products count: ${expected_count}

    Should Be Equal As Integers    ${ui_count}    ${expected_count}

    # Build a dictionary keyed by product name for easy matching
    &{ui_dict}=    Create Dictionary
    FOR    ${p}    IN    @{ui_products}
        Set To Dictionary    ${ui_dict}    ${p['name']}    ${p}
    END

    FOR    ${expected}    IN    @{EXPECTED_PRODUCTS}
        ${name}=    Set Variable    ${expected['name']}
        Log To Console    --- Comparing product: ${name} ---

        ${ui_product}=    Get From Dictionary    ${ui_dict}    ${name}
        Log To Console    UI -> Name: ${ui_product['name']} | Price: ${ui_product['price']} | Desc: ${ui_product['description']} | Image: ${ui_product['image']}
        Log To Console    EXPECTED -> Name: ${expected['name']} | Price: ${expected['price']} | Desc: ${expected['description']} | Image: ${expected['image']}

        # Compare all fields (name, price, description, image)
        Should Be Equal    ${ui_product['price']}        ${expected['price']}
        Should Be Equal    ${ui_product['description']}  ${expected['description']}
        Should Be Equal    ${ui_product['image']}        ${expected['image']}

        Log To Console    ✔ Product '${name}' MATCHES
    END

    Log To Console    ===== PRODUCT COMPARISON PASSED =====


close browser
	Close Browser
