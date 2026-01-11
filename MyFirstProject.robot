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

&{P2}
...    name=Sauce Labs Bike Light
...    price=$9.99
...    description=A red light isn't the desired state in testing but it sure helps when riding your bike at night. Water-resistant with 3 lighting modes.

&{P3}
...    name=Sauce Labs Bolt T-Shirt
...    price=$15.99
...    description=Get your testing superhero on with the Sauce Labs bolt T-shirt. From American Apparel, 100% ringspun combed cotton.

&{P4}
...    name=Sauce Labs Fleece Jacket
...    price=$49.99
...    description=It's not every day that you come across a midweight quarter-zip fleece jacket capable of handling everything from casual to professional.

&{P5}
...    name=Sauce Labs Onesie
...    price=$7.99
...    description=Rib snap infant onesie for the junior automation engineer in development.

&{P6}
...    name=Test.allTheThings() T-Shirt (Red)
...    price=$15.99
...    description=This classic Sauce Labs t-shirt is perfect to wear when cozying up to your keyboard.

*** Keywords ***
Get Products List With Details
	log  products list
	@{products}=  Create List
	@{items}=  Get WebElements  css=.inventory_item
	
	FOR  ${item}  IN  @{items}
	   ${name}=  Get Text  css=.inventory_item_name  
	   ${price}=  Get Text  css=.inventory_item_price  
	   ${desc}=  Get Text  css=.inventory_item_desc  
	   
	   &{product}=  Create Dictionary
	   ...  name=${name}
	   ...  price=${price}
	   ...  description=${desc}
	   
	   Append To List  ${products}  ${product}
	END
	
	RETURN  ${products}

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
        Log To Console    Name: ${p['name']} | Price: ${p['price']} | Desc: ${p['description']}
    END
	
Compare Products With Expected List
    Log To Console    ===== START PRODUCT COMPARISON =====

    @{ui_products}=    Get Products List With Details
	
	${ui_count}=        Get Length    ${ui_products}
	${expected_count}=  Get Length    ${EXPECTED_PRODUCTS}

	Log To Console    UI products count: ${ui_count}
	Log To Console    Expected products count: ${expected_count}


	Should Be Equal As Integers    ${ui_count}    ${expected_count}
	
	${ui_count}=        Get Length    ${ui_products}
	
    FOR    ${index}    IN RANGE    ${ui_count}
		Log To Console    --- Comparing product index: ${index} ---

		${ui_product}=        Set Variable    ${ui_products}[${index}]
		${expected_product}=  Set Variable    ${EXPECTED_PRODUCTS}[${index}]

		Log To Console    UI -> Name: ${ui_product['name']} | Price: ${ui_product['price']} | Desc: ${ui_product['description']}
		Log To Console    EXPECTED -> Name: ${expected_product['name']} | Price: ${expected_product['price']} | Desc: ${expected_product['description']}

		Dictionaries Should Be Equal
		...    ${ui_product}
		...    ${expected_product}

		Log To Console    ✔ Product ${index} MATCHES
	END



    Log To Console    ===== PRODUCT COMPARISON PASSED =====

close browser
	Close Browser
