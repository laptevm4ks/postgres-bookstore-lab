CREATE OR REPLACE FUNCTION author_name(IN i_last_name TEXT, IN i_first_name TEXT, IN i_middle_name TEXT) 
RETURNS TEXT IMMUTABLE
LANGUAGE sql
RETURN CONCAT(i_last_name, ' ', i_first_name, ' ', COALESCE(i_middle_name, '')); 

CREATE OR REPLACE FUNCTION book_name(IN i_book_id INT, IN i_title TEXT)
RETURNS TEXT STABLE
LANGUAGE plpgsql
AS $$
DECLARE
 r RECORD;
 authors_str TEXT := '';
 counter INT := 0;
BEGIN
 FOR r IN (
        SELECT author_name(a.last_name, a.first_name, a.middle_name) as name
        FROM authorship ash
        JOIN authors a USING (author_id)
        WHERE ash.book_id = i_book_id
        ORDER BY ash.seq_num
        LIMIT 3
    ) LOOP
        counter := counter + 1;

        IF counter = 1 THEN
            authors_str := r.name;
        ELSIF counter = 2 THEN
            authors_str := authors_str || ', ' || r.name;
        ELSIF counter = 3 THEN
            authors_str := authors_str || ' и др.';
	EXIT;
        END IF;
    END LOOP;

 RETURN i_title || ' (Авторы: ' || authors_str || ')';
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

CREATE OR REPLACE FUNCTION buy_book(IN i_book_id INT)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
 INSERT INTO operations(book_id, qty_change)
 VALUES (i_book_id, -1);
END;
$$;

CREATE OR REPLACE FUNCTION get_catalog(In i_book_name TEXT, IN i_author_name TEXT, IN i_in_stock BOOLEAN)
RETURNS TABLE(display_name TEXT, onhand INT)
LANGUAGE plpgsql
AS $$
DECLARE
 cmd TEXT := 'SELECT display_name, onhand FROM catalog_v WHERE TRUE';
BEGIN
 IF i_book_name IS NOT NULL THEN
        cmd := cmd || format(' AND display_name ILIKE %L', '%' || i_book_name || '%');
 END IF;

 IF i_author_name IS NOT NULL THEN
	cmd := cmd || format(' AND display_name ILIKE %L', '%' || i_author_name || '%');
 END IF;

 IF i_in_stock THEN
	cmd := cmd || format(' AND onhand > 0');
 ELSE
	cmd := cmd || format(' AND onhand = 0');
 END IF;

 RETURN QUERY EXECUTE cmd;
END;
$$;

CREATE OR REPLACE FUNCTION add_book(IN i_title TEXT, IN i_authors_array INT[])
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
 counter INT := 0;
 x INT;
 l_book_id INT;
BEGIN 
 INSERT INTO books(title) VALUES (i_title) RETURNING book_id INTO l_book_id;

 FOREACH x IN ARRAY i_authors_array LOOP
	counter := counter + 1;
	INSERT INTO authorship(book_id, author_id, seq_num) VALUES (l_book_id, x, counter);
 END LOOP;

 RETURN l_book_id;
END;
$$;
