DROP TABLE IF EXISTS BRANCH;

-- Create table "Branch"
CREATE TABLE branch
	(branch_id VARCHAR(20) PRIMARY KEY,
	manager_id VARCHAR(20),
	branch_address VARCHAR(50),
	contact_no VARCHAR(15)
);
SELECT * FROM branch;

-- Create table "Employees"
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
	(emp_id VARCHAR(10) PRIMARY KEY,
	emp_name VARCHAR(20),
	position VARCHAR(20),
	salary INT,
	branch_id VARCHAR(20)	
);
SELECT * FROM employees;

ALTER TABLE employees
ADD CONSTRAINT fk_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id);

SELECT * FROM employees;

-- Create table "Members"
DROP TABLE IF EXISTS members;
CREATE TABLE members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);
SELECT * FROM members;

-- Create table "Books"
DROP TABLE IF EXISTS books;
CREATE TABLE books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);
SELECT * FROM books;

-- Create table "IssueStatus"
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
(
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(30),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10),
            FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
            FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
            FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);
SELECT * FROM issued_status;

-- Create table "ReturnStatus"
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50)
);
SELECT * FROM return_status;

ALTER TABLE return_status
ADD CONSTRAINT fk_books
FOREIGN KEY (return_book_isbn)
REFERENCES books(isbn);

-- ### 2. CRUD Operations

-- Task 1. Create a New Book Record
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books(isbn,book_title,category ,rental_price ,status ,author,publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT *FROM books;

-- Task 2: Update an Existing Member's Address

UPDATE members
SET member_address='125 Oak St'
WHERE member_id='C103';

-- Task 3: Delete a Record from the Issued Status Table
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

DELETE FROM issued_status
WHERE issued_id ='IS121';

-- Task 4: Retrieve All Books Issued by a Specific Employee
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * FROM issued_status
WHERE issued_emp_id ='E101';

-- Task 5: List Members Who Have Issued More Than One Book
-- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT issued_emp_id ,
	COUNT(*)
FROM issued_status
GROUP BY 1
HAVING COUNT(*) > 1

-- ### 3. CTAS (Create Table As Select)

-- Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt
DROP TABLE  IF EXISTS book_issued_cnt;
CREATE TABLE book_issued_cnt AS
SELECT b.isbn, b.book_title, COUNT(ist.issued_id) AS issue_count
FROM books as b
JOIN issued_status as ist
ON b.isbn = ist.issued_book_isbn
GROUP BY b.isbn, b.book_title;

SELECT * FROM book_issued_cnt;

--If you want to include books that have never been issued, Use a LEFT JOIN instead of an INNER JOIN:
DROP TABLE  IF EXISTS book_issued_cntS;
CREATE TABLE book_issued_cntS AS
SELECT
    b.isbn,
    b.book_title,
    COUNT(ist.issued_id) AS issue_count
FROM books AS b
LEFT JOIN issued_status AS ist
    ON b.isbn = ist.issued_book_isbn
GROUP BY
    b.isbn,
    b.book_title;

SELECT * FROM book_issued_cntS;

-- ### 4. Data Analysis & Findings

-- Task 7. **Retrieve All Books in a Specific Category:

SELECT * FROM books
WHERE category = 'History';

--RETRIVE ALL THE UNIQUE BOOKS CATEGORY;
SELECT DISTINCT category
FROM books;

--COUNT THE NO OF BOOKS IN EACH CATEGORY;
SELECT category , COUNT(*) AS total_books
FROM books
GROUP BY category;

--RETRIVE ALL BOOKS GROUPED BY CATEGORIES;
SELECT
    category,
    book_title
FROM books
ORDER BY category;

-- Task 8: Find Total Rental Income and Total Books by Category:

SELECT category , SUM(rental_price)AS rental_income , COUNT(*)AS total_books
FROM books
GROUP BY category;

-- Task 9. **List Members Who Registered in the Last 180 Days**:

SELECT *FROM members
WHERE reg_date >=  DATE '2021-12-31' - INTERVAL '180 days';

-- Task 10: List Employees with Their Branch Manager's Name and their branch details**:

SELECT e.emp_id,e.branch_id, e.emp_name AS employee_name , 
	e.position , e.salary ,
	b.branch_id , b.manager_id , 
	m.emp_id AS branch_manager
FROM employees e
JOIN branch b
	ON e.branch_id = b.branch_id
JOIN employees AS m
	ON b.manager_id = m.emp_id;

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold

CREATE TABLE expensive_books AS
SELECT * FROM books
WHERE rental_price >7.00;

SELECT * FROM expensive_books;

-- Task 12: Retrieve the List of Books Not Yet Returned

SELECT* FROM issued_status AS ist
LEFT JOIN
return_status AS rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;
    
/*
### Advanced SQL Operations

Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's name, book title, issue date, and days overdue.


Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "available" when they are returned (based on entries in the return_status table).



Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.


Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 6 months.



Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.


Task 18: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.    


Task 19: Stored Procedure
Objective: Create a stored procedure to manage the status of books in a library system.
    Description: Write a stored procedure that updates the status of a book based on its issuance or return. Specifically:
    If a book is issued, the status should change to 'no'.
    If a book is returned, the status should change to 'yes'.

Task 20: Create Table As Select (CTAS)
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines
*/









