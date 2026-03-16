CREATE OR REPLACE FUNCTION author_name(IN i_last_name TEXT, IN i_first_name TEXT, IN i_middle_name TEXT) 
RETURNS TEXT IMMUTABLE
LANGUAGE sql
RETURN CONCAT(i_last_name, ' ', i_first_name, ' ', COALESCE(i_middle_name, '')); 

CREATE OR REPLACE FUNCTION book_name(IN i_book_id INT, IN i_title TEXT)
RETURNS TEXT STABLE
LANGUAGE plpgsql
AS $$
DECLARE
 full_str TEXT;
 limit_len INT := 45;
BEGIN
 SELECT i_title || '(Authors: ' || STRING_AGG(author_name(a.last_name, a.first_name, a.middle_name), ', ' ORDER BY ash.seq_num) || ')'
 INTO full_str
 FROM authorship ash
 JOIN authors a USING (author_id)
 WHERE ash.book_id = i_book_id;

IF length(full_str) <= limit_len THEN
        RETURN full_str;
    END IF;

    RETURN regexp_replace(LEFT(full_str, limit_len), ' [^ ]*$', '') || '...';
END;
$$;

CREATE OR REPLACE FUNCTION onhand_qty(IN i_book books)
RETURNS INT STABLE
LANGUAGE sql
BEGIN ATOMIC
 SELECT COALESCE(SUM(qty_change), 0)::int
 FROM operations
 WHERE book_id = i_book.book_id;
END; 

CREATE OR REPLACE FUNCTION add_author(IN i_last_name TEXT, IN i_first_name TEXT, IN i_middle_name TEXT)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
 l_author_id INT;
BEGIN
 INSERT INTO authors(last_name, first_name, middle_name)
 VALUES (i_last_name, i_first_name, i_middle_name)
 RETURNING author_id INTO l_author_id;
 
 RETURN l_author_id;
END;
$$;
