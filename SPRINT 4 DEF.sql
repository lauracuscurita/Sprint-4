CREATE DATABASE IF NOT EXISTS sprint4;

CREATE TABLE IF NOT EXISTS companies (
	company_id VARCHAR(100) PRIMARY KEY,
    company_name VARCHAR(100),
    phone VARCHAR(100),
    email VARCHAR(100),
    country VARCHAR(100),
    website VARCHAR(100),
 );

SHOW VARIABLES LIKE 'secure_file_priv' ;
set global local_infile = 'ON' ;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/companies.csv'
INTO TABLE companies
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY'\n'
IGNORE 1 ROWS;

alter table transactions
modify column id varchar(100);


alter table products
modify column id varchar(100);

alter table user
modify column id varchar(100);

alter table companies
modify column company_id varchar(100);

alter table credit_cards
modify column id varchar(100);

alter table transactions
modify column card_id varchar(100);

alter table transactions
modify column business_id varchar(100);

alter table transactions
modify column product_ids varchar(100);

alter table transactions
modify column user_id varchar(100);

select * 
from transactions;


alter table transactions
add primary key (id);

alter table companies
add primary key (company_id);

alter table transactions
add constraint fk_card
foreign key (card_id)
references credit_cards(id);

alter table transactions
add constraint fk_company
foreign key (business_id)
references companies(company_id);

alter table transactions
add constraint fk_user
foreign key (user_id)
references user(id);
select *
from transactions;

alter table transactions
modify column timestamp timestamp,
modify column amount decimal(10,2),
modify column declined tinyint(1),
modify column lat float,
modify column longitude float;


alter table companies
modify column phone VARCHAR(15),
modify column company_name VARCHAR(100),
modify column email VARCHAR(100),
modify column country VARCHAR(100);

alter table credit_cards
modify column iban VARCHAR(50),
modify column pin VARCHAR(4),
modify column cvv INT,
modify column expiring_date VARCHAR(10);

alter table credit_cards
modify column cvv VARCHAR(4);


select *
from credit_cards;

alter table user
modify column name VARCHAR(100),
modify column surname VARCHAR(100),
modify column phone VARCHAR(100),
modify column email VARCHAR(100),
modify column birth_date VARCHAR(100),
modify column country VARCHAR(100),
modify column city VARCHAR(100),
modify column postal_code VARCHAR(100),
modify column address VARCHAR(100);

alter table credit_cards
modify column pan VARCHAR(50);



select u.id, name, surname
from user u
where id IN(
			select user_id
            from transactions
            group by user_id
            having count(id) > 30
            )
;

select *
from companies;

select round(avg(amount),2) , iban , company_name
from transactions t
join credit_Cards as c  on c.id = t.card_id
join companies as co  on co.company_id = t.business_id
where company_name= 'Donec Ltd'  and declined = 0
group by iban
order by iban desc;

CREATE TABLE card_status AS
SELECT
    card_id,
    CASE
        WHEN COUNT(*) < 3 THEN 'Activa'
        WHEN SUM(declined) = 3 THEN 'Inactiva'
        ELSE 'Activa'
    END AS Status
FROM (
    SELECT
        card_id,
        declined,
        ROW_NUMBER() OVER(PARTITION BY card_id ORDER BY timestamp DESC) AS Rank_Transaccion
    FROM transactions
) AS Transacciones_Ordenadas
WHERE Rank_Transaccion <= 3
GROUP BY card_id;

select *
from card_status;

select count(*) from card_status
where status = 'Activa';

ALTER TABLE products
ADD PRIMARY KEY (id);


DESCRIBE products; ## como me da error al crear la tabla y establecer las PK y FK verifico que id sea INT

ALTER TABLE products MODIFY COLUMN id INT; #como era VAR(100) cambio a INT el id para q no me de error 

CREATE TABLE product_transaction AS
SELECT 
    t.id AS order_id, 
    CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(t.product_ids, ',', numbers.n), ',', -1) AS UNSIGNED) AS product_id
FROM 
    transactions t
JOIN (
    SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 
    UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
) numbers
ON CHAR_LENGTH(t.product_ids) - CHAR_LENGTH(REPLACE(t.product_ids, ',', '')) >= numbers.n - 1
ORDER BY order_id, product_id;   #utilizo la funcion cast para descomponer los numeros separados por comas, y luego hago la seleccion de estos mediante el join, y asignandoles a cada uno un orden en concreto ( del 1 al 10 para evitar posibles errores)


select *
from product_transaction;


ALTER TABLE product_transaction
MODIFY COLUMN product_id INT,
ADD PRIMARY KEY (order_id, product_id),
ADD FOREIGN KEY (order_id) REFERENCES transactions(id),
ADD FOREIGN KEY (product_id) REFERENCES products(id);


SELECT 
    products.id AS id, 
    products.product_name AS product_name, 
    COUNT(product_transaction.product_id) AS units_sold
FROM 
    products
LEFT JOIN 
    product_transaction ON products.id = product_transaction.product_id
GROUP BY 
    products.id, products.product_name
ORDER BY 
    units_sold DESC, product_name;



