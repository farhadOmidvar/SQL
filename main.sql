
-- •1a. Display the first and last names of all actors from the table  actor .
USE sakila;
SELECT 
    first_name, last_name
FROM
    actor;

-- •1b. Display the first and last name of each actor in a single column in upper case letters. Name the column  Actor Name .
SELECT 
    CONCAT_WS(' ', first_name, last_name) AS Actor_Name
FROM
    actor;

-- •2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."
 -- What is one query would you use to obtain this information?
SELECT 
    actor_id, first_name, last_name
FROM
    actor
WHERE
    first_name = 'Joe';

-- •2b. Find all actors whose last name contain the letters  GEN :
SELECT 
    actor_id, first_name, last_name
FROM
    actor
WHERE
    last_name LIKE '%GEN%';


-- •2c. Find all actors whose last names contain the letters  LI . This time, order the rows by last name and first name, in that order:
SELECT 
    first_name, last_name
FROM
    actor
WHERE
    last_name LIKE '%LI%'
ORDER BY last_name , first_name;

-- •2d. Using  IN , display the  country_id  and  country  columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT 
    country_id, country
FROM
    country
WHERE
    country IN ('Afghanistan' , 'Bangladesh', 'China');

-- •3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- so create a column in the table  actor  named  description  and use the data type  BLOB  
-- (Make sure to research the type  BLOB , as the difference between it and  VARCHAR  are significant).
ALTER TABLE actor ADD COLUMN description BLOB;
describe actor;

-- •3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the  description  column.
ALTER TABLE actor drop column description;

-- •4a. List the last names of actors, as well as how many actors have that last name.
SELECT 
    last_name, COUNT(*) AS num_actor
FROM
    actor
GROUP BY last_name;

-- •4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT 
    last_name, COUNT(*) AS num_actor
FROM
    actor
GROUP BY last_name
HAVING num_actor > 1;

-- •4c. The actor  HARPO WILLIAMS  was accidentally entered in the  actor  table as  GROUCHO WILLIAMS . Write a query to fix the record.
UPDATE actor 
SET 
    first_name = 'HARPO'
WHERE
    first_name = 'GROUCHO'
        AND last_name = 'WILLIAMS';

-- •4d. Perhaps we were too hasty in changing  GROUCHO  to  HARPO . 
-- It turns out that  GROUCHO  was the correct name after all! In a single query, if the first name of the actor is currently  HARPO , change it to  GROUCHO .
UPDATE actor 
SET 
    first_name = REPLACE(first_name, 'HARPO', 'GROUCHO');

-- •5a. You cannot locate the schema of the  address  table. Which query would you use to re-create it?
-- ◦Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
SHOW CREATE TABLE address;

-- •6a. Use  JOIN  to display the first and last names, as well as the address, of each staff member. Use the tables  staff  and  address :

-- without using JOIN
SELECT 
    first_name, last_name, address
FROM
    staff s,
    address a
WHERE
    s.address_id = a.address_id;

-- With Using JOIN
SELECT 
    s.first_name, s.last_name, a.address
FROM
    staff s
        JOIN
    address a USING (address_id);

-- •6b. Use  JOIN  to display the total amount rung up by each staff member in August of 2005. Use tables  staff  and  payment .

-- Total in August 2005
SELECT 
    SUM(p.amount) AS total_amount
FROM
    staff s
        JOIN
    payment p USING (staff_id)
WHERE
    YEAR(p.payment_date) = 2005
        AND MONTH(p.payment_date) = 08;

-- Total for each staff in August 2005
SELECT 
    s.first_name,
    s.last_name,
    p.staff_id,
    SUM(amount) AS total_amount
FROM
    staff s
        JOIN
    payment p USING (staff_id)
WHERE
    YEAR(p.payment_date) = 2005
        AND MONTH(p.payment_date) = 08
GROUP BY p.staff_id;

-- •6c. List each film and the number of actors who are listed for that film. Use tables  film_actor  and  film . Use inner join.

-- Using JOIN
SELECT 
    f.title, COUNT(fa.actor_id) AS number_of_actor
FROM
    film f
        JOIN
    film_actor fa USING (film_id)
GROUP BY f.title;

-- Using Subquery
SELECT 
    f.title,
    (SELECT 
            COUNT(*)
        FROM
            film_actor fa
        WHERE
            f.film_id = fa.film_id) AS number_of_actor
FROM
    film f;

-- •6d. How many copies of the film  Hunchback Impossible  exist in the inventory system?

SELECT 
    f.title,
    (SELECT 
            COUNT(*)
        FROM
            inventory i
        WHERE
            f.film_id = i.film_id) AS number_of_copies
FROM
    film f
WHERE
    f.title = 'Hunchback Impossible';

-- •6e. Using the tables  payment  and  customer  and the  JOIN  command, list the total paid by each customer. List the customers alphabetically by last name:
-- 	![Total amount paid](Images/total_payment.png)

-- Using Subquery
SELECT 
    c.first_name,
    c.last_name,
    (SELECT 
            SUM(p.amount)
        FROM
            payment p
        WHERE
            c.customer_id = p.customer_id) AS total_amount_paid
FROM
    customer c
ORDER BY c.last_name;

-- Using JOIN
SELECT 
    c.first_name,
    c.last_name,
    SUM(p.amount) AS total_amount_paid
FROM
    customer c
        JOIN
    payment p USING (customer_id)
GROUP BY customer_id
ORDER BY c.last_name;


-- •7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters  K  and  Q  have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters  K  and  Q  whose language is English.
SELECT 
    f.title
FROM
    film f
WHERE
    f.language_id = (SELECT 
            l.language_id
        FROM
            language l
        WHERE
            l.name = 'English')
        AND f.title LIKE 'k%'
        OR f.title LIKE 'Q%';

-- •7b. Use subqueries to display all actors who appear in the film  Alone Trip .
SELECT 
    a.first_name, a.last_name
FROM
    actor a
WHERE
    a.actor_id IN (SELECT 
            fa.actor_id
        FROM
            film_actor fa
        WHERE
            fa.film_id = (SELECT 
                    f.film_id
                FROM
                    film f
                WHERE
                    f.title = 'Alone Trip'));

-- •7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers.
 -- Use joins to retrieve this information.
SELECT 
    c.first_name, c.last_name, c.email
FROM
    customer c
        JOIN
    address a ON (c.address_id = a.address_id)
        JOIN
    city ci ON (a.city_id = ci.city_id)
        JOIN
    country co ON (ci.country_id = co.country_id)
WHERE
    co.country = 'CANADA';


-- •7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.

-- Using JOIN
SELECT 
    f.title, c.name AS movie_category
FROM
    film f
        JOIN
    film_category fc ON (f.film_id = fc.film_id)
        JOIN
    category c ON (fc.category_id = c.category_id)
WHERE
    c.name = 'Family';

-- Using Subquery
SELECT 
    f.title, c.name AS movie_category
FROM
    film f,
    film_category fc,
    category c
WHERE
    f.film_id = fc.film_id
	AND fc.category_id = c.category_id
	AND c.name = 'Family';

-- •7e. Display the most frequently rented movies in descending order.
SELECT 
    f.title, COUNT(*) AS number_rented
FROM
    rental r,
    inventory i,
    film f
WHERE
    f.film_id = i.film_id
    AND i.inventory_id = r.inventory_id
GROUP BY f.title
ORDER BY number_rented DESC;

-- •7f. Write a query to display how much business, in dollars, each store brought in.
SELECT 
    s.store_id,
    CONCAT('$', FORMAT(SUM(p.amount), 2)) AS money_made
FROM
    store s,
    inventory i,
    payment p,
    rental r
WHERE
    s.store_id = i.store_id
	AND i.inventory_id = r.inventory_id
	AND r.rental_id = p.rental_id
GROUP BY s.store_id;

-- •7g. Write a query to display for each store its store ID, city, and country.
SELECT 
    s.store_id, ci.city, co.country
FROM
    store s,
    address a,
    city ci,
    country co
WHERE
    s.address_id = a.address_id
	AND a.city_id = ci.city_id
	AND ci.country_id = co.country_id
GROUP BY s.store_id;


-- •7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT 
    c.name AS film_genre,
    CONCAT('$', FORMAT(SUM(p.amount), 2)) AS gross_revenue
FROM
    category c,
    film_category fc,
    inventory i,
    rental r,
    payment p
WHERE
    c.category_id = fc.category_id
	AND fc.film_id = i.film_id
	AND i.inventory_id = r.inventory_id
	AND r.rental_id = p.rental_id
GROUP BY c.name
ORDER BY gross_revenue DESC
LIMIT 5;

-- •8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five_genres AS
    SELECT 
        c.name AS film_genre,
        CONCAT('$', FORMAT(SUM(p.amount), 2)) AS gross_revenue
    FROM
        category c,
        film_category fc,
        inventory i,
        rental r,
        payment p
    WHERE
        c.category_id = fc.category_id
		AND fc.film_id = i.film_id
		AND i.inventory_id = r.inventory_id
		AND r.rental_id = p.rental_id
    GROUP BY c.name
    ORDER BY gross_revenue DESC
    LIMIT 5;

-- •8b. How would you display the view that you created in 8a?
SELECT *
FROM top_five_genres;

-- •8c. You find that you no longer need the view  top_five_genres . Write a query to delete it.
DROP VIEW top_five_genres;
