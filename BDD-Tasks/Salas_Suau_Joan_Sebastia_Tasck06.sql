use classicmodels;

-- EXERCISE 1
DELIMITER //

CREATE TRIGGER check_sales_manager
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    DECLARE manager_count INT;

    -- Count how many Sales Managers exist in the same office
    SELECT COUNT(*) INTO manager_count
    FROM employees
    WHERE jobTitle = 'Sales Manager'
    AND officeCode = NEW.officeCode;

    -- If one already exists, raise an error
    IF manager_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Only one Sales Manager is allowed per office';
    END IF;
END;
//

DELIMITER ;


-- EXERCISE 2
DELIMITER //

CREATE TRIGGER check_active_orders
BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
    DECLARE active_orders INT;

    -- Count active orders for the customer
    SELECT COUNT(*) INTO active_orders
    FROM orders
    WHERE customerNumber = NEW.customerNumber
    AND status IN ('In Process','On Hold','Shipped');

    -- If customer already has 3 active orders, raise error
    IF active_orders >= 3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Customer cannot have more than 3 active orders';
    END IF;
END;
//

DELIMITER ;


-- EXERCISE 3
DELIMITER //

CREATE TRIGGER check_product_stock
BEFORE INSERT ON orderdetails
FOR EACH ROW
BEGIN
    DECLARE available_stock INT;

    -- Get product stock
    SELECT quantityInStock INTO available_stock
    FROM products
    WHERE productCode = NEW.productCode;

    -- Check if stock is zero
    IF available_stock = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Product is out of stock';
    END IF;

    -- Check if requested quantity exceeds stock
    IF NEW.quantityOrdered > available_stock THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Requested quantity exceeds available stock';
    END IF;
END;
//

DELIMITER ;


-- EXERCISE 4
DELIMITER //

CREATE PROCEDURE delete_employee(IN emp_id INT)
BEGIN
    DECLARE supervisor_id INT;

    -- Get the supervisor of the employee
    SELECT reportsTo INTO supervisor_id
    FROM employees
    WHERE employeeNumber = emp_id;

    -- Check if employee has a supervisor
    IF supervisor_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Employee cannot be deleted (no supervisor assigned)';
    END IF;

    -- Reassign customers to supervisor
    UPDATE customers
    SET salesRepEmployeeNumber = supervisor_id
    WHERE salesRepEmployeeNumber = emp_id;

    -- Reassign subordinates to supervisor
    UPDATE employees
    SET reportsTo = supervisor_id
    WHERE reportsTo = emp_id;

    -- Delete the employee
    DELETE FROM employees
    WHERE employeeNumber = emp_id;
END;
//

DELIMITER ;


-- EXERCISE 5
DELIMITER //

CREATE PROCEDURE customers_sales_report(
    IN office_name VARCHAR(50),
    IN year_param INT
)
BEGIN
    SELECT 
        CONCAT(e.firstName, ' ', e.lastName) AS employee_name,
        c.customerName AS customer_name,
        SUM(od.quantityOrdered * od.priceEach) AS total_sales
    FROM employees e
    JOIN offices o ON e.officeCode = o.officeCode
    JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
    JOIN orders ord ON c.customerNumber = ord.customerNumber
    JOIN orderdetails od ON ord.orderNumber = od.orderNumber
    WHERE o.city = office_name
    AND YEAR(ord.orderDate) = year_param
    GROUP BY e.employeeNumber, c.customerNumber;
END;
//

DELIMITER ;


-- EXERCISE 6
DELIMITER //

CREATE PROCEDURE customers_sales_report(
    IN office_name VARCHAR(50),
    IN year_param INT
)
BEGIN
    SELECT 
        CONCAT(e.firstName, ' ', e.lastName) AS employee_name,
        c.customerName AS customer_name,
        SUM(od.quantityOrdered * od.priceEach) AS total_sales
    FROM employees e
    JOIN offices o ON e.officeCode = o.officeCode
    JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
    JOIN orders ord ON c.customerNumber = ord.customerNumber
    JOIN orderdetails od ON ord.orderNumber = od.orderNumber
    WHERE o.city = office_name
    AND YEAR(ord.orderDate) = year_param
    GROUP BY e.employeeNumber, c.customerNumber;
END;
//

DELIMITER ;