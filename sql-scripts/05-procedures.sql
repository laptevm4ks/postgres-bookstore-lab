CREATE OR REPLACE PROCEDURE delete_dublicates_authors()
LANGUAGE sql
BEGIN ATOMIC
 DELETE FROM authors a
 USING authors b
 WHERE a.first_name IS NOT DISTINCT FROM b.first_name
      AND a.last_name IS NOT DISTINCT FROM b.last_name
      AND a.middle_name IS NOT DISTINCT FROM b.middle_name
      AND a.ctid > b.ctid;
END;
