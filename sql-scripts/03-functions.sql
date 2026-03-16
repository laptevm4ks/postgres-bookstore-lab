CREATE OR REPLACE FUNCTION author_name(IN i_last_name TEXT, IN i_first_name TEXT, IN i_middle_name TEXT) 
RETURNS TEXT IMMUTABLE
LANGUAGE sql
RETURN CONCAT(i_last_name, ' ', i_first_name, ' ', COALESCE(i_middle_name, '')); 

CREATE OR REPLACE FUNCTION book_name(IN i_book_id INT, IN i_title TEXT)
RETURNS TEXT STABLE
LANGUAGE sql
BEGIN ATOMIC 
 SELECT i_title || '(Authors: ' || STRING_AGG(author_name(a.last_name, a.first_name, a.middle_name), ', ' ORDER BY ash.seq_num) || ')'
 FROM authorship ash
 JOIN authors a USING (author_id)
 WHERE ash.book_id = i_book_id;
END;

CREATE OR REPLACE FUNCTION onhand_qty(IN i_book books)
RETURNS INT
LANGUAGE sql STABLE
BEGIN ATOMIC
 SELECT COALESCE(SUM(qty_change), 0)::int
 FROM operations
 WHERE book_id = i_book.book_id;
END; 
