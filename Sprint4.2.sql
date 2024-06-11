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


SELECT products.id AS id, products.product_name AS Nombre_Producto, COUNT(transactions.id) AS Unidades_Vendidas
FROM products
LEFT JOIN transactions ON FIND_IN_SET(products.id, transactions.product_ids)
GROUP BY id, Nombre_Producto
;




