*** Settings ***
Documentation       Build and order your robot

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.Tables
Library             RPA.HTTP
Library             RPA.PDF
Library             RPA.Archive
Library             RPA.Dialogs


*** Tasks ***
Build and order your robot
    download file csv
    Open Browser
    Exportar datos a pdf
    #[Teardown]    close browser


*** Keywords ***
download file csv
    Download    https://robotsparebinindustries.com/orders.csv    target_file=${OUTPUT_DIR}${/}    overwrite=true

Open Browser
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Constitucional rights
    Wait Until Page Contains Element    class:modal-content
    Click Button    OK

Fill in the form using the data from the csv file
    [Arguments]    ${row}
    Select From List By Value    head    ${row}[Head]
    Select Radio Button    body    ${row}[Body]
    Input Text    css:input[placeholder="Enter the part number for the legs"]    ${row}[Legs]
    Input Text    address    ${row}[Address]
    Click Button    Preview
    Wait Until Element Is Visible    id:robot-preview

Save each order HTML receipt as a PDF file
    [Arguments]    ${row}
    Fill in the form using the data from the csv file    ${row}
    Screenshot    id:robot-preview    ${OUTPUT_DIR}${/}robot-preview${row}[Order number].png
    Click Button    id:order
    Wait Until Page Contains Element    id:order-completion

Exportar datos a pdf
    ${table}=    Read table from CSV    ${OUTPUT_DIR}${/}orders.csv
    Log    Found columns: ${table.columns}
    FOR    ${element}    IN    @{table}
        Constitucional rights
        Save each order HTML receipt as a PDF file    ${element}
        ${results_html}=    Get Element Attribute    id:receipt    outerHTML
        Html To Pdf    ${results_html}    ${OUTPUT_DIR}${/}pdf/receipt${element}[Order number].pdf
        ${robot_PNG}=    Create List    ${OUTPUT_DIR}${/}robot-preview${element}[Order number].png
        Add Files To Pdf    ${robot_PNG}    ${OUTPUT_DIR}${/}pdf/receipt${element}[Order number].pdf    true
        Click Button    id:order-another
    END
    Archive Folder With Zip    ${OUTPUT_DIR}${/}pdf    ${OUTPUT_DIR}${/}myorders.zip

close browser
    Close Browser
