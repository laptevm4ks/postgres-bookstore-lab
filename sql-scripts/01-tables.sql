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
 middle_name TEXT,
 CONSTRAINT unique_author_name UNIQUE NULLS NOT DISTINCT (last_name, first_name, middle_name)
);

CREATE TABLE authorship(
 book_id INT NOT NULL,
 author_id INT NOT NULL,
 seq_num INT NOT NULL,
 CONSTRAINT fk_authorship_book_id
	FOREIGN KEY (book_id) REFERENCES books(book_id),
 CONSTRAINT fk_authorship_author_id
	FOREIGN KEY (author_id) REFERENCES authors(author_id),
 CONSTRAINT unique_book_author UNIQUE(book_id, author_id)
);
