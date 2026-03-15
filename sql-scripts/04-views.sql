CREATE VIEW authors_v AS
SELECT
 author_id,
 author_name(last_name, first_name, middle_name) AS display_name
FROM authors;

CREATE VIEW catalog_v AS
SELECT
 book_id,
 book_name(book_id, title) AS display_name
FROM books;

CREATE VIEW operations_v AS
SELECT
 book_id,
 CASE WHEN qty_change > 0 THEN 'receipt' WHEN qty_change < 0 THEN 'purchase' ELSE 'NaN' END AS op_type,
 ABS(qty_change) AS qty_change,
 date_created 
FROM operations; 
