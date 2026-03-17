CREATE  OR REPLACE FUNCTION catalog_onhand_update_trg()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
 difference INT;
 current_qty INT;
BEGIN
 PERFORM 1 FROM books WHERE book_id = NEW.book_id FOR UPDATE;

 SELECT COALESCE(SUM(qty_change), 0)::int INTO current_qty 
 FROM operations
 WHERE book_id = NEW.book_id;

 difference := NEW.onhand - current_qty;

 IF difference = 0 THEN
	RETURN NEW;
 END IF;

 IF  (current_qty + difference) < 0 THEN
	RAISE EXCEPTION 'No books in the stock';
 END IF;

 INSERT INTO operations(book_id, qty_change)
 VALUES (NEW.book_id, difference);

 RETURN NEW;
END;
$$;

CREATE TRIGGER trg_catalog_v_update
INSTEAD OF UPDATE ON catalog_v
FOR EACH ROW
EXECUTE FUNCTION catalog_onhand_update_trg();
