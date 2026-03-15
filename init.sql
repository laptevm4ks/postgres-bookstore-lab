CREATE SCHEMA IF NOT EXISTS bookstore;

ALTER DATABASE bookstore SET search_path TO bookstore, public;
SET search_path TO bookstore, public;

CREATE TABLE books(
 book_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 title TEXT NOT NULL
);

CREATE TABLE operations(
 operation_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 book_id INT NOT NULL,
 qty_change INT NOT NULL,
 date_created DATE NOT NULL DEFAULT CURRENT_DATE,
 CONSTRAINT fk_operations_book_id
	FOREIGN KEY (book_id) REFERENCES books(book_id)
);

CREATE TABLE authors(
 author_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 last_name TEXT NOT NULL,
 first_name TEXT NOT NULL,
 middle_name TEXT
);

CREATE TABLE authorship(
 book_id INT NOT NULL,
 author_id INT NOT NULL,
 seq_num INT NOT NULL,
 CONSTRAINT fk_authorship_book_id
	FOREIGN KEY (book_id) REFERENCES books(book_id),
 CONSTRAINT fk_authorship_author_id
	FOREIGN KEY (author_id) REFERENCES authors(author_id)
);

INSERT INTO authors (last_name, first_name, middle_name) VALUES
    ('Пушкин', 'Александр', 'Сергеевич'),
    ('Толстой', 'Лев', 'Николаевич'),
    ('Достоевский', 'Фёдор', 'Михайлович'),
    ('Пелевин', 'Виктор', 'Олегович'),
    ('Акунин', 'Борис', NULL);

INSERT INTO books (title) VALUES
    ('Евгений Онегин'),
    ('Война и мир'),
    ('Преступление и наказание'),
    ('Generation "П"'),
    ('Азазель');

INSERT INTO authorship (book_id, author_id, seq_num) VALUES
    (1, 1, 1),
    (2, 2, 1),
    (3, 3, 1),
    (4, 4, 1),
    (5, 5, 1);

INSERT INTO operations (book_id, qty_change, date_created) VALUES
    (1, 10, '2024-03-01'),
    (2, 5, '2024-03-01'),
    (3, 7, '2024-03-02'),
    (4, 3, '2024-03-02'),
    (5, 4, '2024-03-03'),
    (1, -2, '2024-03-05'),
    (2, -1, '2024-03-05'),
    (3, -3, '2024-03-06'),
    (1, -1, '2024-03-07'),
    (5, -2, '2024-03-07');

CREATE VIEW authors_v AS
SELECT
 author_id,
 CONCAT(last_name, ' ', first_name, ' ', COALESCE(middle_name, '')) AS display_name
FROM authors;

CREATE VIEW catalog_v AS
SELECT
 book_id,
 title AS display_name
FROM books;

CREATE VIEW operations_v AS
SELECT
 book_id,
 CASE WHEN qty_change > 0 THEN 'receipt' WHEN qty_change < 0 THEN 'purchase' ELSE 'NaN' END AS op_type,
 ABS(qty_change) AS qty_change,
 date_created 
FROM operations; 
