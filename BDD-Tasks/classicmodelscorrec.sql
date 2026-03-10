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