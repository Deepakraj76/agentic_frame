
DROP PROCEDURE IF EXISTS RenameAndTransferTableEmployee;
DELIMITER //

CREATE PROCEDURE RenameAndTransferTableEmployee()
BEGIN
    DECLARE msg_message VARCHAR(100);

    -- Procedure for Employee
    IF EXISTS (SELECT * FROM information_schema.tables WHERE table_name = 'employee') THEN
        SET msg_message = 'employee exists, proceeding to load data.';
        SELECT msg_message AS Message;

        CREATE TABLE `_employee` LIKE `employee`;
        INSERT INTO `_employee` 
            (`id`, `name`, `position`, `salary`, 
            `added_by`, `date_added`, `modified_by`, `date_modified`)
        SELECT 
            `id`, `name`, `position`, `salary`, 
            COALESCE(`added_by`, 'SA') AS `added_by`, 
            COALESCE(`date_added`, NOW()) AS `date_added`, 
            COALESCE(`modified_by`, 'SA') AS `modified_by`, 
            COALESCE(`date_modified`, NOW()) AS `date_modified`
        FROM `employee`;
        
        IF EXISTS (SELECT * FROM information_schema.columns WHERE table_name = 'employee' AND column_name = 'rowguid') THEN
            ALTER TABLE `_employee` DROP COLUMN `rowguid`;
        END IF;

        RENAME TABLE `employee` TO `employee_old`, `_employee` TO `employee`;
    END IF;
END //

DELIMITER ;

-- Call the procedure
CALL RenameAndTransferTableEmployee();


Please note that the example provided seems to be for multiple tables (Employees, Products, Orders), but the task you've asked for is only for one table (`employee`). The script above is adjusted for the `employee` table as per your provided SQL table creation script and the objectives. If you need to perform this for multiple tables, similar blocks of code need to be created for each table with the appropriate table and column names.