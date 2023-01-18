/*employee(employee-name, street, city)
works(employee-name, company-name, salary)
company(company-name, city)
manages (employee-name, manager-name)*/ --

/*1. Give an SQL schema definition for the employee database of Figure 5. Choose an appropriateprimary key
 for each relation schema, and insert any other integrity constraints (for example,foreign keys) you find necessary.*/

create database db_Employee;
use db_Employee;


create table Tbl_employee 
(
	employee_name varchar(255)  Primary key,
	street varchar(255),
	city varchar(255)
);

create table Tbl_works
(
	employee_name varchar(255)  Primary key,
	salary int,
	company_name varchar(255)

);

create table Tbl_company
(
	company_name varchar(255)  Primary key,
	city varchar(255)
);

create table Tbl_manages
(
	employee_name varchar(255)  Primary key,
	manager_name varchar(255)
);

INSERT INTO Tbl_employee (employee_name, street, city) VALUES
 ("Jones", "808 Maple St", "Austin"),  -- for updating jones  city later in question
("Megan Harris", "1212 Birch St", "Jacksonville"), -- same city and street
("Emily Clark", "1010 Pine St", "Chicago"),
("Joshua Turner", "1111 Cedar St", "Columbus"),
("Ashley Phillips", "1212 Birch St", "Jacksonville"), -- same city and street
("Matthew Lewis", "1313 Holly St", "Detroit"),
("Amanda Lee", "1414 Olive St", "El Paso"),
("David Walker", "1515 Willow St", "Jacksonville"),-- same city only
("Catherine Hall", "1616 Maple St", "Baltimore"),
("Nicholas Allen", "1717 Oak St", "Chicago");


  
INSERT INTO Tbl_works (employee_name, company_name, salary) VALUES 
 ("Jones", "First Bank Corporation", 75000),
("Megan Harris", "JKL Enterprises", 80000),
("Emily Clark", "Small Bank Corporation", 85000),
("Joshua Turner", "PQR Co", 90000),
("Ashley Phillips", "Small Bank Corporation", 95000),
("Matthew Lewis", "STU Inc", 100000),
("Amanda Lee", "First Bank Corporation", 105000),
("David Walker", "1621 Enterprises", 110000),
("Catherine Hall", "First Bank Corporation", 115000),
("Nicholas Allen", "JKL Enterprises", 120000);

INSERT INTO Tbl_company (company_name, city) VALUES
("First Bank Corporation", "Chicago"),
("JKL Enterprises", "Houston"),
("Small Bank Corporation", "Jacksonville"),
("PQR Co", "Jacksonville"),
("STU Inc", "San Antonio");

INSERT INTO Tbl_manages (employee_name, manager_name) VALUES
("Brian Thompson", "Emily Clark"),
("Megan Harris", "Joshua Turner"),
("Emily Clark", "Ashley Phillips"),
("Joshua Turner", "Matthew Lewis"),
("Ashley Phillips", "Amanda Lee"),
("Matthew Lewis", "David Walker"),
("Amanda Lee", "Catherine Hall"),
("David Walker", "Nicholas Allen"),
("Catherine Hall", "John Smith"),
("Nicholas Allen", "Jane Doe");
  
-- Add foreign key 
ALTER TABLE Tbl_works ADD FOREIGN KEY (employee_name) REFERENCES Tbl_employee(employee_name);

ALTER TABLE Tbl_works Add FOREIGN KEY(company_name) REFERENCES Tbl_company(company_name);

ALTER TABLE Tbl_manages ADD FOREIGN KEY(employee_name) REFERENCES Tbl_employee(employee_name);

/* 2. Consider the employee database of Figure 5, where the primary keys are underlined. Give an expression in SQL for each of the following queries:*/

-- (a) Find the names of all employees who work for First Bank Corporation.

SELECT employee_name FROM Tbl_works WHERE company_name = 'First Bank Corporation'; 

-- (b) Find the names and cities of residence of all employees who work for First Bank Corporation.

-- using queries
SELECT employee_name, city FROM Tbl_employee WHERE employee_name IN (SELECT employee_name FROM Tbl_works WHERE company_name = 'First Bank Corporation'); 

-- using inner join
SELECT Tbl_employee.employee_name, Tbl_employee.city FROM Tbl_employee
INNER JOIN Tbl_works ON Tbl_employee.employee_name = Tbl_works.employee_name
WHERE Tbl_works.company_name = 'First Bank Corporation';

-- (c)  Find the names, street addresses, and cities of residence of all employees who work for First Bank Corporation and earn more than $10,000.

-- using queries
SELECT Tbl_employee.employee_name, Tbl_employee.street, Tbl_employee.city FROM Tbl_employee WHERE employee_name IN
(SELECT employee_name FROM Tbl_works WHERE company_name = 'First Bank Corporation' AND salary > 10000); 

-- using inner join
SELECT Tbl_employee.employee_name, Tbl_employee.street, Tbl_employee.city FROM Tbl_employee
INNER JOIN Tbl_works ON Tbl_employee.employee_name = Tbl_works.employee_name
WHERE Tbl_works.company_name = 'First Bank Corporation' AND Tbl_works.salary > 10000;

-- (d) Find all employees in the database who live in the same cities as the companies for which they work.

-- using  queries
SELECT Tbl_employee.employee_name, Tbl_employee.city FROM Tbl_employee  WHERE Tbl_employee.city = 
(SELECT city FROM Tbl_company  WHERE Tbl_company.company_name = 
(SELECT company_name FROM Tbl_works WHERE Tbl_works.employee_name = Tbl_employee.employee_name));

-- using inner join
SELECT Tbl_employee.employee_name, Tbl_employee.city FROM Tbl_employee
INNER JOIN Tbl_works ON Tbl_employee.employee_name = Tbl_works.employee_name
INNER JOIN Tbl_company ON Tbl_works.company_name = Tbl_company.company_name
WHERE Tbl_company.city = Tbl_employee.city;

-- (e) Find all employees in the database who live in the same cities and on the same streets as do their managers.
-- using self join as couldn't find other solutions
SELECT e1.employee_name, e1.city, e1.street
FROM Tbl_employee e1
JOIN Tbl_manages m ON e1.employee_name = m.employee_name
JOIN Tbl_employee e2 ON m.manager_name = e2.employee_name
WHERE e1.city = e2.city AND e1.street = e2.street;




-- (f) Find all employees in the database who do not work for First Bank Corporation.
SELECT employee_name from Tbl_works WHERE company_name != 'First Bank Corporation';

-- (g) Find all employees in the database who earn more than each employee of Small Bank Corporation.
SELECT e.employee_name
FROM employee e
INNER JOIN works w ON e.employee_name = w.employee_name
WHERE w.salary > ALL (
  SELECT w1.salary
  FROM works w1
  INNER JOIN employee e1 ON w1.employee_name = e1.employee_name
  INNER JOIN company c ON w1.company_name = c.company_name
  WHERE c.company_name = 'Small Bank Corporation'
);

-- (h) Assume that the companies may be located in several cities. Find all companies located in every city in which Small Bank Corporation is located.
SELECT * FROM Tbl_company
WHERE Tbl_company.city = (SELECT Tbl_company.city FROM Tbl_company WHERE Tbl_company.company_name = 'Small Bank Corporation');

-- (i) Find all employees who earn more than the average salary of all employees of their company.
SELECT tbl_works.employee_name, tbl_works.company_name FROM
(SELECT company_name, AVG(salary) AS average_salary
FROM tbl_works GROUP BY company_name) AS average
JOIN tbl_works ON average.company_name = tbl_works.company_name
WHERE tbl_works.salary > average.average_salary;

-- (j) Find the company that has the most employees.
SELECT company_name, employee_count FROM
(SELECT company_name, COUNT(employee_name) AS employee_count
FROM tbl_works GROUP BY company_name) as C1
ORDER BY employee_count DESC;


-- (k) Find the company that has the smallest payroll.
SELECT company_name, payroll FROM
(SELECT company_name, SUM(salary) AS payroll
 FROM tbl_works GROUP BY company_name) AS total_payroll
ORDER BY payroll ASC;

-- (l) Find those companies whose employees earn a higher salary, on average, than the average salary at First Bank Corporation
select c.company_name
from tbl_company c join tbl_works w
on c.company_name = w.company_name
group by c.company_name
having avg(w.salary) > (select avg(w2.salary)
                        from tbl_company c2 join
                             tbl_works w2
                             on c2.company_name = w2.company_name
                        where c2.company_name = 'First Bank Corporation'
                       );

/* 3. Consider the relational database of Figure 5. Give an expression in SQL for each of the following queries:*/

-- (a) Modify the database so that Jones now lives in Newtown.
select * from tbl_employee where employee_name='Jones';
UPDATE Tbl_employee
SET city='Newtown'
Where employee_name='Jones'; 

-- (b) Give all employees of First Bank Corporation a 10 percent raise.
select * from tbl_works where company_name='First Bank Corporation';
UPDATE Tbl_works
SET salary=salary *1.10
Where company_name='First Bank Corporation';

-- (c) Give all managers of First Bank Corporation a 10 percent raise.
UPDATE tbl_works 
SET salary = salary * 1.10
WHERE employee_name = ANY (SELECT DISTINCT manager_name  FROM tbl_manages) AND company_name = 'Acme Inc';



-- (d) Give all managers of First Bank Corporation a 10 percent raise unless the salary becomes greater than $100,000; in such cases, give only a 3 percent raise.
Select * from tbl_works where company_name='First Bank Corporation';
-- using query
UPDATE Tbl_works 
SET salary = IF(salary < 100000,salary * 1.10,salary * 1.03)
WHERE employee_name = ANY (SELECT DISTINCT manager_name FROM Tbl_manages);

-- inner join
UPDATE Tbl_works INNER JOIN Tbl_manages ON 
Tbl_manages.manager_name = Tbl_works.employee_name 
SET  salary = IF(salary < 100000,salary * 1.10,salary * 1.03);
