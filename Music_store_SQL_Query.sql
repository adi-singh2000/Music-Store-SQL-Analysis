CREATE DATABASE MUSIC;
USE MUSIC;

-- --------------------- EASY LEVEL QUESTION -------------------

-- WHO IS THE SENIOR MOST EMPLOYEE BASED ON JOB TITLE?
select * from employee
order by levels desc
limit 1;

-- WHICH COUNTRIES HAVE THE MOST INVOICES?
select billing_country ,count(billing_country) as country from invoice
group by billing_country
order by country desc;

-- WHAT ARE TOP 3 VALUES OF TOTAL INVOICE?
select distinct(total) from invoice
order by total desc
limit 3;

/*  Which city has the best customers? We would like to throw a promotional Music
Festival in the city we made the most money. Write a query that returns one city that
has the highest sum of invoice totals. Return both the city name & sum of all invoice
totals */

select billing_city as city, sum(total) as invoice_total from invoice
group by city
order by invoice_total desc
limit 1;

/* . Who is the best customer? The customer who has spent the most money will be
declared the best customer. Write a query that returns the person who has spent the
most money */

select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as invoice_total
from customer
join invoice 
on customer.customer_id = invoice.customer_id
group by 1, 2, 3
order by invoice_total desc
LIMIT 1;


-- --------------------- MODERATE LEVEL QUESTION -------------------

/*Write query to return the email, first name, last name, & Genre of all Rock Music
listeners. Return your list ordered alphabetically by email starting with A */

select count(*) from customer; -- 59
select count(*) from invoice; -- 614
select count(*) from invoice_line; -- 4757
select count(*) from track; -- 362
select count(*) from genre; -- 25

select distinct d.email as mail, d.first_name, d.last_name
from invoice_line as a
join track as b on b.track_id = a.track_id
join invoice as c on c.invoice_id = a.invoice_id
join customer as d on d.customer_id = c.customer_id
join genre as e on e.genre_id = b.genre_id
where e.name like 'Rock'
order by mail;


/* Let's invite the artists who have written the most rock music in our dataset. Write a
query that returns the Artist name and total track count of the top 10 rock bands */

select count(*) from album2; -- 347
select count(*) from track; -- 362
select count(*) from genre; -- 25
select count(*) from artist; -- 275


SELECT ar.artist_id, ar.name, COUNT(ar.artist_id) AS num_tracks
FROM track AS t
LEFT JOIN genre AS g ON t.genre_id = g.genre_id
LEFT JOIN album2 AS al ON t.album_id = al.album_id
LEFT JOIN artist AS ar ON al.artist_id = ar.artist_id
WHERE g.name = 'Rock'
GROUP BY 1,2
ORDER BY num_tracks desc
limit 10;


/*  Return all the track names that have a song length longer than the average song length.
Return the Name and Milliseconds for each track. Order by the song length with the
longest songs listed first */

select name, milliseconds from track
where milliseconds > (
	select avg(milliseconds) as avg_track from track
)
order by milliseconds desc;


-- --------------------- ADVANCE LEVEL QUESTION -------------------

/* Find how much amount spent by each customer on artists? Write a query to return
customer name, artist name and total spent */

with best_selling_artist as (
	select ar.artist_id as artist_id, ar.name as artist_name,
    sum(il.unit_price * il.quantity) as total_sales
    from invoice_line as il
    join track as t on t.track_id = il.track_id
    join album2 as al on al.album_id = t.album_id
    join artist as ar on ar.artist_id = al.artist_id
    group by 1,2
    order by 3 desc
    limit 1
)
select c.customer_id, concat(c.first_name, ' ' , c.last_name) as name, bsa.artist_name,
sum(il.unit_price*il.quantity) as amount_spent
from invoice i
join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album2 al on al.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = al.artist_id
group by 1, 2, 3
order by 4 desc;


/* We want to find out the most popular music Genre for each country. We determine the
most popular genre as the genre with the highest amount of purchases. Write a query
that returns each country along with the top Genre. For countries where the maximum
number of purchases is shared return all Genres */

with popular_genre as 
(
    select count(il.quantity) AS purchases, c.country, g.name, g.genre_id, 
	row_number() over(partition by c.country order by count(il.quantity) desc) AS row_num 
    from invoice_line il 
	join invoice i on i.invoice_id = il.invoice_id
	join customer c on c.customer_id = i.customer_id
	join track t on t.track_id = il.track_id
	join genre g on g.genre_id = t.genre_id
	group by 2,3,4
	order by 2 asc, 1 desc
)
select * from popular_genre where row_num <= 1;


/* Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

with Customter_with_country as (
		select c.customer_id, concat(first_name, ' ' ,last_name) , billing_country, sum(total) as total_spending,
	    row_number() over(partition by billing_country order by SUM(total) desc) as RowNo 
		from invoice i
		join customer c on c.customer_id = i.customer_id
		group by 1,2,3
		order by 3 asc,4 desc)
select * from Customter_with_country where RowNo <= 1;
