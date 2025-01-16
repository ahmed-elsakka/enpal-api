create table if not exists  sales_managers (
    id serial primary key not null,
    name varchar(250) not null,
    languages varchar(100)[],
    products varchar(100)[],
    customer_ratings varchar(100)[]
);

create table if not exists slots (
    id serial primary key not null,
    start_date timestamptz not null,
    end_date timestamptz not null,
    booked boolean not null default false,
    sales_manager_id int not null references sales_managers(Id)
);

insert into sales_managers (name, languages, products, customer_ratings) values ('Seller 1', '{"German"}', '{"SolarPanels"}', '{"Bronze"}');
insert into sales_managers (name, languages, products, customer_ratings) values ('Seller 2', '{"German", "English"}', '{"SolarPanels", "Heatpumps"}', '{"Gold","Silver","Bronze"}');
insert into sales_managers (name, languages, products, customer_ratings) values ('Seller 3', '{"German", "English"}', '{"Heatpumps"}', '{"Gold","Silver","Bronze"}');

insert into slots (sales_manager_id, booked, start_date, end_date) values (1, false, '2024-05-03T10:30Z', '2024-05-03T11:30Z');
insert into slots (sales_manager_id, booked, start_date, end_date) values (1, true,  '2024-05-03T11:00Z', '2024-05-03T12:00Z');
insert into slots (sales_manager_id, booked, start_date, end_date) values (1, false, '2024-05-03T11:30Z', '2024-05-03T12:30Z');
insert into slots (sales_manager_id, booked, start_date, end_date) values (2, false, '2024-05-03T10:30Z', '2024-05-03T11:30Z');
insert into slots (sales_manager_id, booked, start_date, end_date) values (2, false, '2024-05-03T11:00Z', '2024-05-03T12:00Z');
insert into slots (sales_manager_id, booked, start_date, end_date) values (2, false, '2024-05-03T11:30Z', '2024-05-03T12:30Z');
insert into slots (sales_manager_id, booked, start_date, end_date) values (3, true,  '2024-05-03T10:30Z', '2024-05-03T11:30Z');
insert into slots (sales_manager_id, booked, start_date, end_date) values (3, false, '2024-05-03T11:00Z', '2024-05-03T12:00Z');
insert into slots (sales_manager_id, booked, start_date, end_date) values (3, false, '2024-05-03T11:30Z', '2024-05-03T12:30Z');
insert into slots (sales_manager_id, booked, start_date, end_date) values (1, false, '2024-05-04T10:30Z', '2024-05-04T11:30Z');
insert into slots (sales_manager_id, booked, start_date, end_date) values (1, false, '2024-05-04T11:00Z', '2024-05-04T12:00Z');
insert into slots (sales_manager_id, booked, start_date, end_date) values (1, true,  '2024-05-04T11:30Z', '2024-05-04T12:30Z');
insert into slots (sales_manager_id, booked, start_date, end_date) values (2, true,  '2024-05-04T10:30Z', '2024-05-04T11:30Z');
insert into slots (sales_manager_id, booked, start_date, end_date) values (2, false, '2024-05-04T11:00Z', '2024-05-04T12:00Z');
insert into slots (sales_manager_id, booked, start_date, end_date) values (2, true,  '2024-05-04T11:30Z', '2024-05-04T12:30Z');
insert into slots (sales_manager_id, booked, start_date, end_date) values (3, true,  '2024-05-04T10:30Z', '2024-05-04T11:30Z');
insert into slots (sales_manager_id, booked, start_date, end_date) values (3, false, '2024-05-04T11:00Z', '2024-05-04T12:00Z');
insert into slots (sales_manager_id, booked, start_date, end_date) values (3, false, '2024-05-04T11:30Z', '2024-05-04T12:30Z');

CREATE INDEX idx_sales_managers_languages ON sales_managers USING GIN (languages);
CREATE INDEX idx_sales_managers_products ON sales_managers USING GIN (products);
CREATE INDEX idx_sales_managers_ratings ON sales_managers USING GIN (customer_ratings);
CREATE INDEX idx_slots_start_date ON slots (start_date);
CREATE INDEX idx_slots_booked ON slots (booked);
CREATE INDEX idx_slots_manager_id ON slots (sales_manager_id);


CREATE VIEW available_slots AS
SELECT 
    s1.id AS slot_id,
    s1.sales_manager_id,
    s1.start_date,
    s1.end_date,
    s1.booked
FROM slots s1
WHERE s1.booked = FALSE
  AND NOT EXISTS (
    SELECT 1
    FROM slots s2
    WHERE s1.sales_manager_id = s2.sales_manager_id
      AND s2.booked = TRUE
      AND s1.id != s2.id
      AND s1.start_date < s2.end_date
      AND s1.end_date > s2.start_date
  );