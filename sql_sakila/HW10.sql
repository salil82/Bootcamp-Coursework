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

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

SELECT title
FROM film
WHERE language_id IN
(
  SELECT language_id
  FROM language
  WHERE name = 'English'
);

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

select first_name, last_name
from actor
where actor_id in
	(select actor_id
    from film_actor
    where film_id in
		(select film_id
        from film
        where title = 'ALONE TRIP'
        )
	);
    
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names
--  and email addresses of all Canadian customers. Use joins to retrieve this information.

select first_name, last_name
from customer
inner join address on address.address_id = customer.address_id
inner join city on city.city_id = address.city_id
inner join country on country.country_id = city.country_id
where country.country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.

select title
from film
inner join film_category on film_category.film_id = film.film_id
inner join category on category.category_id = film_category.category_id
where category.name = 'Family';

 -- 7e. Display the most frequently rented movies in descending order.

select * from film;
select * from inventory;
select * from rental;

select title, count(*)
from film
inner join inventory on inventory.film_id = film.film_id
inner join rental on rental.inventory_id = inventory.inventory_id
group by film.title order by count(*) desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.

select store.store_id, sum(amount) as gross
from payment
inner join rental on payment.rental_id = rental.rental_id
inner join inventory on inventory.inventory_id = rental.inventory_id
inner join store on store.store_id = inventory.store_id
group by store.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.

select store.store_id, city.city, country.country
from store
inner join address on address.address_id = store.address_id
inner join city on city.city_id = address.city_id
inner join country on country.country_id = city.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

select name, sum(amount) as gross
from category
inner join film_category on film_category.category_id = category.category_id
inner join inventory on inventory.film_id = film_category.film_id
inner join rental on rental.inventory_id = inventory.inventory_id
inner join payment on payment.rental_id = rental.rental_id
group by name order by gross desc limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

create view top_five_genres as
	select name, sum(amount) as gross
	from category
	inner join film_category on film_category.category_id = category.category_id
	inner join inventory on inventory.film_id = film_category.film_id
	inner join rental on rental.inventory_id = inventory.inventory_id
	inner join payment on payment.rental_id = rental.rental_id
	group by name order by gross desc limit 5;

-- 8b. How would you display the view that you created in 8a?

select * from top_five_genres;


-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

drop view if exists top_five_genres;