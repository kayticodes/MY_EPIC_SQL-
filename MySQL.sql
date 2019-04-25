
-- 1a. Display First and Last Names 
SELECT first_name, last_name FROM actor;

-- 1b. Create a New Column called Actor_Name and store all the actor’s first and last names (all caps) 
ALTER TABLE actor
ADD COLUMN Actor_Name VARCHAR(55) AFTER last_name;
SELECT CONCAT(first_name, ' ', last_name) AS Actor_Name FROM actor;

-- 2a  Find the ID number with only first name ‘Joe’ 
SELECT 
actor_id, first_name, last_name
FROM actor
WHERE first_name = 'JOE';

-- 2b. Find all the actors with last names containing the letters ‘GEN’ 
SELECT first_name, last_name
FROM actor
WHERE last_name LIKE '%G%E%N%';

-- 2c. Find all actors with the last names with the letters LI, order by last name and then first name 
SELECT last_name, first_name
FROM actor
WHERE last_name LIKE '%L%I%'; 

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country 
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Create a column in the table actor named description and use the data type BLOB
ALTER TABLE actor
ADD COLUMN description BLOB AFTER Actor_Name;

-- 3b Delete the description column.
ALTER TABLE actor 
DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(*)  
FROM actor 
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(*)
FROM actor
GROUP BY last_name
HAVING COUNT(*) > 1;

--  4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
--  Find all the actor’s who have the name ‘GROUCHO’ and display the ID#
SELECT * 
FROM actor 
WHERE first_name LIKE 'GROUCHO';
-- Change GROUCHO WILLIAMS to HARPO WILLIAMS
UPDATE actor
SET first_name = 'HARPO' 
WHERE actor_id = 172; 
-- Query all the actor’s with the last name ‘WILLIAMS’ to make sure that GROUCHO WILLIAMS was changed to HARPO WILLIAMS.
SELECT first_name, last_name, actor_id 
FROM actor 
WHERE last_name = 'WILLIAMS';

-- 4d. In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO
UPDATE actor SET 
first_name = 'GROUCHO' 
WHERE first_name = 'HARPO';
-- 5a You cannot locate the schema of the address table. Which query would you use to re-create it?
CREATE TABLE sakila.address(
	address_id SMALLINT(5) AUTO_INCREMENT NOT NULL,
    address VARCHAR(50) NOT NULL,
    address2 VARCHAR(50),
    district VARCHAR(20),
    city_id smallint(5) NOT NULL,
    postal_code VARCHAR(10),
    phone VARCHAR(20),
    location GEOMETRY,
    last_update TIMESTAMP,
    PRIMARY KEY (address_id)
);

--  6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT first_name, last_name, address 
FROM staff JOIN address ON (staff.address_id = address.address_id);

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT first_name, last_name, SUM(amount) as total_collections
FROM staff JOIN payment ON (staff.staff_id = payment.staff_id) 
WHERE payment_date LIKE '2005-08%'
GROUP BY staff.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT title, film.film_id, COUNT(*) AS number_of_actors 
FROM film_actor INNER JOIN film ON (film_actor.film_id = film.film_id) 
GROUP BY film.film_id;

--  6d.How many copies of the film Hunchback Impossible exist in the inventory system?
--   Query the film id of HUNCHBACK IMPOSSIBLE. It turns out the id is 439.
SELECT film_id, title 
FROM film 
WHERE title = 'HUNCHBACK IMPOSSIBLE'; 
--  Count how many times the HUNCHBACK IMPOSSIBLE's id shows up in the inventory system 
SELECT film_id, COUNT(*) AS number_of_copies
FROM inventory 
WHERE film_id = 439;

--  6eUsing the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name:
SELECT last_name, first_name, SUM(amount) as total_paid
FROM payment JOIN customer ON (payment.customer_id = customer.customer_id) 
GROUP BY customer.customer_id
ORDER BY last_name ASC;

-- 7a Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title
FROM film 
WHERE title LIKE 'Q%'OR title LIKE 'K%' 
AND language_id = (SELECT language_id FROM language WHERE name = 'ENGLISH'); 

--  7b.Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name 
FROM actor JOIN film_actor ON (actor.actor_id= film_actor.actor_id) 
WHERE film_id = (SELECT film_id FROM film WHERE title = 'ALONE TRIP');

--  7c. Use joins to retrieve the names and email addresses of all Canadian customers.
SELECT first_name, last_name, email
FROM customer 
JOIN address ON (customer.address_id = address.address_id)
JOIN city ON (city.city_id = address.city_id)
JOIN country ON (country.country_id = country.country_id)
WHERE country.country = "Canada";

--  7d. Identify all movies categorized as family films.
SELECT title, rating , category_id
FROM film JOIN film_category ON (film.film_id= film_category.film_id) 
WHERE category_id = (SELECT category_id FROM category WHERE name = 'Family');

-- 7e. Display the most frequently rented movies in descending order.
SELECT film.title, COUNT(rental.rental_id) AS 'times_rented'
FROM film 
JOIN inventory ON (inventory.film_id = film.film_id)
JOIN rental ON (rental.inventory_id = inventory.inventory_id)
GROUP BY film.title
ORDER BY COUNT(rental.rental_id) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store.store_id, SUM(payment.amount)
FROM store 
JOIN staff ON (store.store_id = staff.store_id)
 JOIN sakila.payment ON (payment.staff_id =staff.staff_id)
GROUP BY store.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store.store_id, city.city, country.country
FROM store 
	JOIN address  ON (address.address_id = store.address_id)
    JOIN city ON (city.city_id = address.city_id)
    JOIN country ON (country.country_id = city.country_id);

--  7h. List the top five genres in gross revenue in descending order.
SELECT category.name, SUM(payment.amount)
FROM sakila.payment
JOIN sakila.rental ON (rental.rental_id = payment.rental_id)
    JOIN sakila.inventory ON (inventory.inventory_id = rental.inventory_id)
    JOIN sakila.film_category ON (film_category.film_id = inventory.film_id)
    JOIN sakila.category ON (category.category_id = film_category.category_id)
GROUP BY category.name
ORDER BY SUM(payment.amount) DESC LIMIT 5;

-- 8a. Use the solution from the problem above to create a view of the top 5 genres 
CREATE VIEW sakila.top_five AS
	SELECT category.name, SUM(payment.amount)
	FROM payment
		JOIN rental ON (rental.rental_id = payment.rental_id)
		JOIN inventory ON (inventory.inventory_id = rental.inventory_id)
		JOIN film_category ON(film_category.film_id = inventory.film_id)
		JOIN category ON(category.category_id = film_category.category_id)
	GROUP BY category.name
	ORDER BY SUM(payment.amount) DESC limit 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five;

-- 8c. Write a query to delete the top 5 view.
DROP VIEW sakila.top_five;
