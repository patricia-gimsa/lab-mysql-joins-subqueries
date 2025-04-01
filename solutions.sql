USE sakila;

-- Exercise 1: How many copies of the film 'Hunchback Impossible' exist?
SELECT COUNT(*) AS 'Copies'  -- Count how many rows match in the inventory table
FROM inventory
WHERE film_id = (     -- Filter by film_id that matches the title
  SELECT film_id    -- Get the film_id
  FROM film
  WHERE title = 'Hunchback Impossible'  -- Find the film by title
);

-- Exercise 2: List all films whose length is longer than the average
SELECT title, length   -- Show title and length of the film
FROM film
WHERE length > (      -- Filter films with length greater than the average
  SELECT AVG(length)     -- Get the average film length
  FROM film
);

-- Get the average length of all films to check:
SELECT AVG(length) AS average_length
FROM film;


-- Exercise 3: Show all actors who appear in the film 'Alone Trip'
SELECT first_name, last_name      -- Show actor's first and last name
FROM actor
WHERE actor_id IN (   -- Filter only actors that appear in the film
  SELECT actor_id     -- Get actor IDs from film_actor table
  FROM film_actor
  WHERE film_id = (      -- Find the film_id of 'Alone Trip'
    SELECT film_id
    FROM film
    WHERE title = 'Alone Trip'
  )
);


-- Exercise 4: Identify all movies categorized as family films
SELECT title     -- Show the film title
FROM film
WHERE film_id IN (  -- Filter by film IDs that belong to the 'Family' category
  SELECT film_id
  FROM film_category
  WHERE category_id = (    -- Get the ID of the 'Family' category
    SELECT category_id
    FROM category
    WHERE name = 'Family'
  )
);


-- Exercise 5A: Get name and email from customers from Canada (using subquery)
SELECT first_name, last_name, email    -- Show customer name and email
FROM customer
WHERE address_id IN (     -- Filter by address_id from Canadian addresses
  SELECT address_id
  FROM address
  WHERE city_id IN (       -- Filter by city_id where country is Canada
    SELECT city_id
    FROM city
    WHERE country_id = (     -- Find country_id for 'Canada'
      SELECT country_id
      FROM country
      WHERE country = 'Canada'
    )
  )
);

-- Exercise 5B: Get name and email from customers from Canada (using joins)
SELECT customer.first_name, customer.last_name, customer.email   -- Show customer name and email
FROM customer
JOIN address ON customer.address_id = address.address_id    -- Join address to get city_id
JOIN city ON address.city_id = city.city_id    -- Join city to get country_id
JOIN country ON city.country_id = country.country_id   -- Join country to filter by name
WHERE country.country = 'Canada';    -- Filter only Canadian customers


-- Exercise 6: Which are films starred by the most prolific actor?
-- Step 1: Get the actor_id of the most prolific actor
SELECT actor_id
FROM film_actor
GROUP BY actor_id
ORDER BY COUNT(*) DESC
LIMIT 1;
-- Step 2: Show all films starred by the most prolific actor (actor_id = 107)
SELECT title   -- Show film title
FROM film
WHERE film_id IN (  -- Filter films that include actor_id 107
  SELECT film_id
  FROM film_actor
  WHERE actor_id = 107     -- Use known actor_id
);


-- Exercise 7: Films rented by most profitable customer
-- Step 1: Get the customer who spent the most (with name and total)
SELECT customer.customer_id, first_name, last_name, SUM(payment.amount) AS total_spent
FROM customer
JOIN payment ON customer.customer_id = payment.customer_id
GROUP BY customer.customer_id, first_name, last_name
ORDER BY total_spent DESC
LIMIT 1;
-- Step 2: List films rented by the most profitable customer (customer_id = 526)
SELECT DISTINCT film.title     -- Show unique film titles
FROM rental
JOIN inventory ON rental.inventory_id = inventory.inventory_id
JOIN film ON inventory.film_id = film.film_id
WHERE rental.customer_id = 526;     -- Use the most profitable customer's ID


-- Exercise 8: Get clients who spent more than the average total amount spent
SELECT customer_id, total_amount_spent  -- get each customer's total amount spent
FROM (
  SELECT customer_id, SUM(amount) AS total_amount_spent  -- Subquery: calculate total spent per customer
  FROM payment
  GROUP BY customer_id
) AS customer_totals
WHERE total_amount_spent > (   -- Filter only those customers whose total is greater than the average total
  SELECT AVG(total_by_customer)  -- Subquery: calculate the average total amount spent per customer
  FROM (
    SELECT customer_id, SUM(amount) AS total_by_customer
    FROM payment
    GROUP BY customer_id
  ) AS totals
);
