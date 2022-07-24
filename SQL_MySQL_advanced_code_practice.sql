SELECT "Adar" Name, NOW() , sysdate(), CONCAT('Anamul',' ','Hoque') Full_name
FROM dual;

SELECT DISTINCT status
FROM orders
ORDER BY FIELD(status,
			   'Resolved',
               'Disputed',
               'In Process',
               'Shipped',
               'Cancelled',
               'On Hold');

SELECT DISTINCT status
FROM orders
ORDER BY status DESC;

SELECT * FROM employees;
SELECT CONCAT(man.firstName,' ',man.lastName) Manager,
       CONCAT(emp.firstName,' ',emp.lastName) Employee
FROM employees emp
INNER JOIN employees man ON man.employeeNumber =  emp.reportsTo;      

SELECT IFNULL(CONCAT(man.firstName,' ',man.lastName), 'Top Manager') Manager,
       CONCAT(emp.firstName,' ',emp.lastName) employee
FROM employees emp
LEFT JOIN employees man ON man.employeeNumber = emp.reportsTo;       


SELECT * FROM customers
ORDER BY city;

SELECT c1.city, c1.customerName, c2.customerName
FROM customers c1
INNER JOIN customers c2 ON c1.city = c2.city
AND c1.customerName > c2.customerName
ORDER BY city;

SELECT orderNumber, COUNT(productCode) countProduct, COUNT(quantityOrdered) countOrder, SUM(quantityOrdered * priceEach) Sale_Price
FROM orderdetails
GROUP BY orderNumber
HAVING Sale_Price > 10000;

CREATE TABLE sales
AS
SELECT productLine, YEAR(orderDate) orderYear, SUM(quantityOrdered * priceEach) orderValue
FROM orderdetails d
JOIN orders o USING(orderNumber)
JOIN products P USING(productCode)
GROUP BY productLine, orderYear;

SELECT * FROM sales;

SELECT SUM(orderValue) totalOrderValue
FROM sales;

SELECT productLine, SUM(orderValue) totalOrderValue
FROM sales
GROUP BY productLine
UNION ALL
SELECT null, SUM(orderValue) totalOrderValue
FROM sales;

SELECT productLine, SUM(orderValue) totalOrderValue
FROM sales
GROUP BY productLine WITH ROLLUP;

SELECT productLine, orderYear, SUM(orderValue) totalOrderValue
FROM sales
GROUP BY productLine,orderYear WITH ROLLUP;

SELECT productLine, orderYear, SUM(orderValue) totalOrderValue, GROUPING(productLine), GROUPING(orderYear)
FROM sales
GROUP BY productLine,orderYear WITH ROLLUP;

SELECT  IF(GROUPING(orderYear), 'All Years',orderYear) orderYear ,
        IF(GROUPING(productLine),'All Products Line',productLine),
        SUM(orderValue) totalOrderValue 
FROM sales
GROUP BY orderYear,productLine WITH ROLLUP;

SELECT  IF(GROUPING(o.orderNumber),'Total Order No',o.orderNumber) grpOrdNum, 
        IF(GROUPING(d.productCode),'Total Product',d.productCode) grpPrdCode,
        SUM(quantityOrdered * priceEach) orderValue
FROM orderdetails d
JOIN orders o USING(orderNumber)
JOIN products P USING(productCode)
GROUP BY o.orderNumber,d.productCode WITH ROLLUP;


SELECT 
        orderNumber, COUNT(orderNumber) AS items
    FROM
        orderdetails
    GROUP BY orderNumber;

SELECT * FROM products;

SELECT *
FROM products p1
WHERE p1.buyPrice > (SELECT AVG(buyPrice)
                     FROM products
                     WHERE productLine = p1.productLine);

SELECT *
FROM customers c
WHERE EXISTS (  SELECT orderNumber, SUM(quantityOrdered * priceEach) orderValue
				FROM orderdetails d
				JOIN orders USING(orderNumber)
                WHERE customerNumber = c.customerNumber
				GROUP BY orderNumber
				HAVING orderValue > 60000);

SELECT productLine, SUM(orderValue) orderValue
FROM
(SELECT d.productCode, SUM(quantityOrdered * priceEach) orderValue
FROM orderdetails d
JOIN orders USING(orderNumber)
WHERE YEAR(orderDate) = 2003
GROUP BY d.productCode) a
LEFT JOIN products p
USING(productCode)
GROUP BY productLine;

(SELECT o.customerNumber, SUM(quantityOrdered * priceEach) orderValue,
(CASE WHEN SUM(quantityOrdered * priceEach) > 100000 THEN 'Platinum'
      WHEN SUM(quantityOrdered * priceEach) BETWEEN 10000 AND 100000 THEN 'Gold'
      WHEN SUM(quantityOrdered * priceEach) < 10000 THEN 'Silver'
END) cus_group
FROM orderdetails d
JOIN orders o USING(orderNumber)
WHERE YEAR(orderDate) = 2003
GROUP BY o.customerNumber);

SELECT cus_group, COUNT(cus_group) no_of_group_cus
FROM 
(SELECT o.customerNumber, SUM(quantityOrdered * priceEach) orderValue,
(CASE WHEN SUM(quantityOrdered * priceEach) > 100000 THEN 'Platinum'
      WHEN SUM(quantityOrdered * priceEach) BETWEEN 10000 AND 100000 THEN 'Gold'
      WHEN SUM(quantityOrdered * priceEach) < 10000 THEN 'Silver'
END) cus_group
FROM orderdetails d
JOIN orders o USING(orderNumber)
WHERE YEAR(orderDate) = 2003
GROUP BY o.customerNumber) a
GROUP BY cus_group;

/*  Using CET common table expresion*/
WITH custInUSA AS
(SELECT customerName, state
FROM customers
WHERE country = 'USA')
SELECT customerName, state
FROM custInUSA 
WHERE state = 'CA';

WITH topSales2003 AS
(SELECT c.salesRepEmployeeNumber employeeNumber,
 SUM(quantityOrdered * priceEach) sales
 FROM orders o 
 JOIN orderdetails d USING(orderNumber)
 JOIN customers c ON o.customerNumber = c.customerNumber
 WHERE YEAR(o.orderDate) = 2003
 AND   o.status = 'Shipped'
 GROUP BY employeeNumber
 ORDER BY sales DESC
 )
SELECT t.employeeNumber, CONCAT(e.firstName,' ',e.lastName) name,e.jobTitle, t.sales
FROM topSales2003 t
JOIN employees e USING(employeeNumber);

WITH salesRep AS
(SELECT employeeNumber, CONCAT(firstName,' ',lastName) SalesRepName
FROM employees
WHERE jobTitle = 'Sales Rep'),
custSalesRep AS
(SELECT c.customerName, s.SalesRepName
 FROM customers c
 JOIN salesRep s ON c.salesRepEmployeeNumber = s.employeeNumber)
 SELECT * FROM custSalesRep;

WITH salesRep AS
(SELECT employeeNumber, CONCAT(firstName,' ',lastName) SalesRepName
FROM employees
WHERE jobTitle = 'Sales Rep'),
custSalesRep AS
(SELECT c.customerNumber,customerName, s.SalesRepName
 FROM customers c
 JOIN salesRep s ON c.salesRepEmployeeNumber = s.employeeNumber),
 TotalSales AS
 (SELECT o.customerNumber,  SUM(quantityOrdered * priceEach) sales
  FROM orders o
  JOIN orderdetails d USING(orderNumber)
  JOIN custSalesRep c ON c.customerNumber = o.customerNumber
  GROUP BY o.customerNumber)
  SELECT * FROM TotalSales;

/* Recursive CTE */

SELECT * FROM employees
WHERE ReportsTO IS NULL;

SELECT 
    employeeNumber, 
    reportsTo managerNumber, 
    officeCode
FROM
    employees
WHERE
    reportsTo IS NULL;


CREATE TABLE test
(id INT PRIMARY KEY AUTO_INCREMENT,
 message VARCHAR(10) NOT NULL);

INSERT INTO test(message)
VALUE('Error'),('Error This Message');

SELECT * FROM test;

INSERT IGNORE INTO test(message)
VALUE('Error'),('Error This Message');


SELECT rand();

WITH RECURSIVE employee_paths AS
  ( SELECT employeeNumber,
           reportsTo managerNumber,
           officeCode-- , 
          -- 1 lvl
   FROM employees
   WHERE reportsTo IS NULL
     UNION ALL
     SELECT e.employeeNumber,
            e.reportsTo,
            e.officeCode-- ,
            -- lvl+1
     FROM employees e
     INNER JOIN employee_paths ep ON ep.employeeNumber = e.reportsTo )
SELECT employeeNumber,
       managerNumber,
       -- lvl,
       city
FROM employee_paths ep
INNER JOIN offices o USING (officeCode)
ORDER BY  city;






