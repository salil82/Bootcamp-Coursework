use sakila;

-- 1a. Display the first and last names of all actors from the table actor. 
SELECT first_name, last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT CONCAT(first_name, " ", last_name) AS `Actor Name`
FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name FROM actor
WHERE first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT * FROM actor
WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT * FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name ASC, first_name ASC;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country
WHERE Country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
ALTER TABLE actor
add middle_name varchar(30) after first_name;
select * from actor;

-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.
ALTER TABLE actor
MODIFY COLUMN middle_name blob;

-- 3c. Now delete the middle_name column.
ALTER TABLE actor
DROP COLUMN middle_name;
SELECT * FROM actor

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name)
FROM actor
GROUP BY last_name

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name)
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) >=2;

-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
SET SQL_SAFE_UPDATES = 0

UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO'

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. 
-- It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. 
-- Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. 
-- BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)

update actor
set first_name =
case
	when first_name like 'HARPO' then replace(first_name, 'HARPO', 'GROUCHO')
    when first_name like 'GROUCHO' then replace(first_name, 'GROUCHO', 'MUCHO GROUCHO')
    end;

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?

CREATE TABLE address (
	address_id smallint(5) NOT NULL AUTO_INCREMENT,
    address VARCHAR(50),
    address2 VARCHAR(50),
    district VARCHAR(20),
    city_id smallint(5),
    postal_code VARCHAR(10),
    phone VARCHAR(20),
    location GEOMETRY,
    last_update TIMESTAMP
);

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:

SELECT * FROM staff;
SELECT * FROM address;

SELECT staff.first_name, staff.last_name, address.address
FROM staff
JOIN address
ON staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.

SELECT * FROM staff;
SELECT * FROM payment;

SELECT first_name, last_name, sum(amount)
FROM staff s
JOIN payment p
ON (s.staff_id = p.staff_id)
WHERE payment_date >='2005-08-01 00:00:00'
AND payment_date <'2005-09-01 00:00:00'
GROUP BY first_name, last_name;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

SELECT * FROM film_actor;
SELECT * FROM film;

SELECT COUNT(fa.actor_id), title
FROM film_actor fa
JOIN film f 
ON (fa.film_id = f.film_id)
GROUP BY title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT * FROM inventory;
SELECT * FROM film;

SELECT title , COUNT(i.film_id)
FROM film f
JOIN inventory i
ON (f.film_id = i.film_id)
WHERE title = 'Hunchback Impossible';

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:

SELECT * FROM payment;
SELECT * FROM customer;

SELECT p.customer_id, SUM(p.amount), c.last_name
FROM payment p
JOIN customer c
ON (p.customer_id = c.customer_id)
GROUP BY p.customer_id
ORDER BY last_name;

