
-- Exercise 4

UPDATE orders
SET status = 'Cancelled',
shippedDate = CURDATE(),
comments = 'Order cancelled due to delay'
WHERE orderDate = '2003-09-28';

--Exercise 5
SELECT * FROM products WHERE productLine = 'Trains';
UPDATE products
SET productName = CONCAT(productName, ' (code ', productCode, ')')
WHERE productLine = 'Trains';

--Exercise 6
UPDATE products
SET buyPrice = buyPrice * 1.0002,
MSRP = MSRP * 1.0002
WHERE quantityInStock > 500;

--Exercise 7
DELETE FROM payments
WHERE customerNumber IN (
    SELECT customerNumber
    FROM customers
    WHERE salesRepEmployeeNumber IN (
        SELECT employeeNumber
        FROM employees
        WHERE lastName = 'Patterson'
    )
);

--Exercise 8
DELETE FROM customers
WHERE city = 'Lisbon'
AND customerNumber NOT IN (
SELECT customerNumber
FROM payments
);

--Exercise 9

INSERT INTO employees (
    employeeNumber,
    lastName,
    firstName,
    extension,
    email,
    officeCode,
    reportsTo,
    jobTitle
)
SELECT 
    customerNumber + 2000,
    contactLastName,
    contactFirstName,
    'x0000',
    'new@company.com',
    '1',
    NULL,
    'Sales Rep'
FROM customers;

-- Exercise 10
-- I had a problem with the name Elizabeth (I have already corrected it manually) because it had a space.
UPDATE orders
SET status = 'Cancelled',
shippedDate = CURDATE(),
comments = 'Order cancelled by management'
WHERE customerNumber IN (
SELECT customerNumber
FROM customers
WHERE contactFirstName = 'Elizabeth'
AND contactLastName = 'Lincoln'
);
-- fix the space by adding the %.
UPDATE orders 
SET status = 'Cancelled', 
    shippedDate = CURDATE(), 
    comments = 'Order cancelled by management' 
WHERE customerNumber IN (
    SELECT customerNumber 
    FROM customers 
    WHERE contactFirstName LIKE 'Elizabeth%' 
    AND contactLastName LIKE 'Lincoln%'
);
