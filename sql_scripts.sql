use chinook;
-- OBJECTIVE QUESTIONS

-- Q1. Does any table have missing values or duplicates? If yes how would you handle it ?

select * from album;
select distinct * from album; -- No duplicates

SELECT * FROM artist;
SELECT distinct * FROM artist; -- No duplicates

SELECT * from customer;
SELECT distinct * FROM customer; -- No duplicates
SELECT COUNT(*) FROM customer;
-- WHERE fax is NULL; ( count = 47)
-- WHERE state is NULL;(count = 29)
-- WHERE company is NULL; (count = 49)
-- 47 fax, 29 state and 49 company values are null in the customer table

SELECT * from employee; -- 1 reports_to value is null for employee_id = 1
SELECT distinct * FROM employee; -- No duplicates

SELECT * FROM genre;
SELECT distinct * FROM genre; -- No duplicates

SELECT * FROM invoice;
SELECT distinct * FROM invoice; -- No duplicates

SELECT * FROM invoice_line;
SELECT distinct * FROM invoice_line; -- No duplicates

SELECT * FROM media_type;
SELECT distinct * FROM media_type; -- No duplicates

SELECT * FROM playlist;
SELECT distinct * FROM playlist; -- No duplicates

SELECT * FROM playlist_track;
SELECT distinct * FROM playlist_track;

SELECT * FROM track;
SELECT distinct * FROM track; -- No duplicates

SELECT COUNT(*) FROM track 
WHERE composer is NULL; -- 978 composers are not assigned any value/are null in the track table

/*
The data provided possess 0 duplicates although there are missing values in 3 tables
which could be handled by using the coalesce function
*/



-- Q2. Find the top-selling tracks and top artist in the USA and identify their most famous genres.

select count(distinct unit_price) from track; -- two distinct prices for tracks (0.99 and 1.99) therefore, finding the top selling track and its artist by quantity of records sold
select * from invoice_line;

-- finding top selling track and artist in USA
select Highest_Selling_Track, Highest_selling_Artist, Genre FROM 
(
select t.name as Highest_Selling_Track,ar.name as Highest_selling_Artist, g.name as Genre
from track t
left join invoice_line il on il.track_id = t.track_id
left join invoice i on i.invoice_id = il.invoice_id
left join album al on al.album_id = t.album_id
left join artist ar on ar.artist_id = al.artist_id
left join genre g on t.genre_id = g.genre_id
where i.billing_country = 'USA'
group by t.name,ar.name,g.name
order by sum(il.quantity) desc
limit 10
) sub_table;

-- finding top selling genre in USA
select Top_Genre from 
(
select g.name as Top_Genre
from track t
left join invoice_line il on il.track_id = t.track_id
left join invoice i on i.invoice_id = il.invoice_id
left join genre g on t.genre_id = g.genre_id
where i.billing_country = 'USA'
group by g.name
order by sum(il.quantity) desc
limit 10
) sub_table;



-- Q3. What is the customer demographic breakdown (age, gender, location) of Chinook's customer base?

select count(distinct country) from customer; -- 24 countries

select country, count( email) as customer_count from customer
group by country
order by customer_count desc; -- USA:13, Canada:8, Brazil:5, France:5, Germany:4 (country:no of customer)

/*
 The customer base of Chinook music store is spread across 24 countries. USA is the country with most number of customers accounting to 13.
*/

-- Q4. Calculate the total revenue and number of invoices for each country, state, and city

select billing_country, billing_state, billing_city, COUNT(invoice_id) as count_of_invoices, SUM(total) as total_revenue
from invoice
group by billing_city,billing_state,billing_country
order by count(invoice_id) desc, sum(total) desc;


-- Q5. Find the top 5 customers by total revenue in each country

select count(customer_id) from invoice; -- 614
select count(distinct customer_id) from invoice; -- 59

with cte as(
select customer_id, sum(total) as total_revenue
from invoice
group by customer_id),
cte2 as(
select concat(c.first_name,' ',c.last_name) as full_name, c.country,
dense_rank() over(partition by c.country order by cte.total_revenue desc) as ranking
from customer c
right join cte on cte.customer_id = c.customer_id)
select full_name, country,ranking from cte2 where ranking <=5;



-- Q6. Identify the top-selling track for each customer


select concat(c.first_name,' ',c.last_name) as Full_name, t.name as Track_name, SUM(quantity) as Total_quantity
from customer c
left join track t on t.track_id = il.track_id
left join invoice i on i.customer_id = c.customer_id
left join invoice_line il on il.invoice_id = i.invoice_id
group by concat(c.first_name,' ',c.last_name),t.name
ORDER BY SUM(quantity) DESC;


-- Q7. Are there any patterns or trends in customer purchasing behavior (e.g., frequency of purchases, preferred payment methods, average order value)?

select customer_id, avg(total) as avg_order_value, count(invoice_id)as num_of_orders
from invoice
group by customer_id
order by count(invoice_id),avg(total);


select count(invoice_id) as daily_invoice_count, extract(YEAR_MONTH from invoice_date), avg(total) as monthly_avg_total, sum(total) as monthly_sum_total
from invoice
group by extract(YEAR_MONTH from invoice_date)
order by extract(YEAR_MONTH from invoice_date);


-- Q8. What is the customer churn rate?

select count(distinct customer_id) as customer_count from invoice
where invoice_date between '2018-01-01' and '2018-12-31' and customer_id not in
(select distinct customer_id from invoice
where invoice_date between '2017-01-01' and '2017-12-31');
-- customers churned in 2018

select count(distinct customer_id) as customer_count from invoice
where invoice_date between '2019-01-01' and '2019-12-31' and customer_id not in
(select distinct customer_id from invoice
where invoice_date between '2018-01-01' and '2018-12-31');
-- customers churned in 2019

select count(distinct customer_id) as customer_count from invoice
where invoice_date between '2020-01-01' and '2020-12-31' and customer_id not in
(select distinct customer_id from invoice
where invoice_date between '2019-01-01' and '2019-12-31');
-- customers churned in 2020

select count(distinct customer_id) from invoice
where invoice_date between '2017-01-01' and '2017-12-31';
-- customers at the starting of 2018


select count(distinct customer_id) from invoice
where invoice_date between '2018-01-01' and '2018-12-31';
-- customers at the starting of 2019


select count(distinct customer_id) from invoice
where invoice_date between '2019-01-01' and '2019-12-31';
-- customers at the starting of 2020

/*
with Q1_cte1 as(
select count(distinct customer_id) as churn_count from invoice
where invoice_date between '2018-01-01' and '2018-03-31' and customer_id not in
(select distinct customer_id from invoice
where invoice_date between '2017-10-01' and '2017-12-31')
),
Q1_cte2 as(
select count(distinct customer_id) as churn_count from invoice
where invoice_date between '2019-01-01' and '2019-03-31' and customer_id not in
(select distinct customer_id from invoice
where invoice_date between '2018-10-01' and '2018-12-31')
),
Q1_cte3 as(
select count(distinct customer_id) as churn_count from invoice
where invoice_date between '2020-01-01' and '2020-03-31' and customer_id not in
(select distinct customer_id from invoice
where invoice_date between '2019-10-01' and '2019-12-31')
),
Q1_cte4 as(
select count(distinct customer_id) as customer_count from invoice
where invoice_date between '2017-01-01' and '2017-03-31'),
Q1_cte5 as(
select count(distinct customer_id) as customer_count from invoice
where invoice_date between '2018-01-01' and '2018-03-31'),
Q1_cte6 as(
select count(distinct customer_id) as customer_count from invoice
where invoice_date between '2019-01-01' and '2019-03-31'),
Q1_cte7 as(
select count(distinct customer_id) as customer_count from invoice
where invoice_date between '2020-01-01' and '2020-03-31')
select (c1.churn_count+c2.churn_count+c3.churn_count)*100/((c4.customer_count+c5.customer_count+c6.customer_count+c7.customer_count)/4) as Q1_Churn
from Q1_cte1 as c1,Q1_cte2 as c2,Q1_cte3 as c3,Q1_cte4 as c4, Q1_cte5 as c5,Q1_cte6 as c6, Q1_cte7 as c7;

*/

/*
with first_three_months as 
(
select count(customer_id) as customer_count from invoice
where invoice_date between '2017-01-01' and '2017-03-31'
),
last_three_months as
(
select count(customer_id) as customer_count from invoice
where invoice_date between '2017-10-01' and '2017-12-31' 
) 
select ((first3.customer_count)-(last3.customer_count))/(first3.customer_count) * 100 as churn_rate
from first_three_months as first3,last_three_months as last3;

-- churn rate of 40.8163% in 2017

with first_three_months as 
(
select count(customer_id) as customer_count from invoice
where invoice_date between '2018-01-01' and '2018-03-31'
),
last_three_months as
(
select count(customer_id) as customer_count from invoice
where invoice_date between '2018-10-01' and '2018-12-31' 
) 
select ((first3.customer_count)-(last3.customer_count))/(first3.customer_count) * 100 as churn_rate
from first_three_months as first3,last_three_months as last3;

-- churn rate of 53.4483% in 2018

with first_three_months as 
(
select count(customer_id) as customer_count from invoice
where invoice_date between '2019-01-01' and '2019-03-31'
),
last_three_months as
(
select count(customer_id) as customer_count from invoice
where invoice_date between '2019-10-01' and '2019-12-31' 
) 
select ((first3.customer_count)-(last3.customer_count))/(first3.customer_count) * 100 as churn_rate
from first_three_months as first3,last_three_months as last3;

-- churn rate of 6.4516% in 2019

with first_three_months as 
(
select count(customer_id) as customer_count from invoice
where invoice_date between '2020-01-01' and '2020-03-31'
),
last_three_months as
(
select count(customer_id) as customer_count from invoice
where invoice_date between '2020-10-01' and '2020-12-31' 
) 
select ((first3.customer_count)-(last3.customer_count))/(first3.customer_count) * 100 as churn_rate
from first_three_months as first3,last_three_months as last3;

-- churn rate of -56.6667% in 2020 showing increase in customer count.
*/
-- Q9. Calculate the percentage of total sales contributed by each genre in the USA and identify the best-selling genres and artists.
WITH cte as
(
select sum(total) as total_USA_revenue from invoice
where billing_country = 'USA'
),
cte2 as
(
select g.name as genre_name, sum(t.unit_price * il.quantity) as total_genre_revenue
from genre g
right join track t on g.genre_id = t.genre_id
left join invoice_line il on il.track_id = t.track_id
left join invoice i on i.invoice_id = il.invoice_id
where billing_country = 'USA'
group by g.name 
order by total_genre_revenue DESC
),
cte_rank as
(
select genre_name, round(total_genre_revenue * 100/(select total_USA_revenue from cte),2) perc_contri,
DENSE_RANK() over(order by round(total_genre_revenue * 100/(select total_USA_revenue from cte),2) desc) ranking
from cte2
)
select cte_rank.genre_name, perc_contri, ranking from cte_rank;

/*
Rock	53.38
Alternative & Punk	12.37
Metal	11.80
R&B/Soul	5.04
Blues	3.43
Alternative	3.33
Latin	2.09
Pop	2.09
Hip Hop/Rap	1.90
Jazz	1.33
Easy Listening	1.24
Reggae	0.57
Electronica/Dance	0.48
Classical	0.38
Heavy Metal	0.29
TV Shows	0.19
Soundtrack	0.19
*/

-- Q10. Find customers who have purchased tracks from at least 3 different genres

with cte as(
select concat(c.first_name, ' ', c.last_name) as customer_name, count(distinct t.genre_id) as no_of_genres FROM customer c 
left join invoice i on i.customer_id = c.customer_id
left join invoice_line il on il.invoice_id = i.invoice_id
left join track t on t.track_id = il.track_id
group by concat(c.first_name, ' ', c.last_name) having count(distinct t.genre_id) >= 3
order by count(distinct t.genre_id) desc
)
select customer_name, no_of_genres from cte;
/*
All customers have bought records from atleast 3 different genres
*/

-- Q11. Rank genres based on their sales performance in the USA

with cte as
(
select t.genre_id, g.name,  sum(il.quantity*t.unit_price) as total_sales from track t
left join genre g on g.genre_id = t.genre_id
left join invoice_line il on il.track_id = t.track_id
left join invoice i on i.invoice_id = il.invoice_id

where billing_country = 'USA'
group by t.genre_id, g.name
)
select DENSE_RANK() over(order by total_sales desc) as ranking,name, total_sales
from cte;

-- Q12. Identify customers who have not made a purchase in the last 3 months

select first_name, last_name from customer c
left join (
select * 
from invoice
where invoice_date > (select max(invoice_date) from invoice) - interval 3 month) prev_3_months
on prev_3_months.customer_id = c.customer_id
where invoice_id is null;

/*
Luís	Gonçalves
François	Tremblay
Bjørn	Hansen
Astrid	Gruber
Daan	Peeters
Kara	Nielsen
Eduardo	Martins
Alexandre	Rocha
Jack	Smith
Michelle	Brooks
Tim	Goyer
Hannah	Schneider
Fynn	Zimmermann
Niklas	Schröder
Camille	Bernard
Isabelle	Mercier
Johannes	Van der Berg
Enrique	Muñoz
Steve	Murray
Diego	Gutiérrez
Luis	Rojas
Manoj	Pareek
*/

========================================================================================================
========================================================================================================

-- Subjective Questions

-- Q1. Recommend the three albums from the new record label that should be prioritised 
-- for advertising and promotion in the USA based on genre sales analysis.

select * from track order by album_id,genre_id; -- an album have songs with same/single genre
select genre_id from genre where name = 'Rock'; -- genre_id = 1 for Rock

with cte as(
select sum(i.total) as total_revenue, t.album_id
from invoice i left join invoice_line il on il.invoice_id = i.invoice_id
left join track t on t.track_id = il.track_id
where i.billing_country = 'USA' and t.genre_id = 1
group by t.album_id
order by total_revenue desc
)
select a.title, a.album_id from album a
left join cte on cte.album_id = a.album_id
order by cte.total_revenue desc limit 3;

/*
Following albums should be prioritised for advertisement and promotion:
From The Muddy Banks Of The Wishkah [live]	163
Are You Experienced?	120
The Best Of Van Halen, Vol. I	243
*/

-- Q2. Determine the top-selling genres in countries 
-- other than the USA and identify any commonalities or differences.

SELECT Top_Genre FROM 
(
select g.name as Top_Genre
from track t
left join invoice_line il on il.track_id = t.track_id
left join invoice i on i.invoice_id = il.invoice_id
left join genre g on t.genre_id = g.genre_id
where i.billing_country != 'USA'
group by g.name
order by sum(il.quantity) desc
limit 10
) sub_table;



-- Q3. Customer Purchasing Behavior Analysis: How do the purchasing habits (frequency, basket size, spending amount)
-- of long-term customers differ from those of new customers?
-- What insights can these patterns provide about customer loyalty and retention strategies?
 
WITH cte as
(
select i.customer_id, max(invoice_date) as last_purchase_date, min(invoice_date) as first_purchase_date,
 sum(total) as total_spent, sum(quantity) as items_bought, count(i.customer_id) as frequency,
 abs(timestampdiff(day, max(invoice_date), min(invoice_date))) as customer_since_days
from invoice i
left join invoice_line il on il.invoice_id = i.invoice_id
left join customer c on c.customer_id = i.customer_id
group by i.customer_id
),
long_short_term as
(
SELECT total_spent, items_bought, frequency,
case
when customer_since_days>(select avg(customer_since_days) as average_days from cte) then 'Long Term'
else 'Short Term' end term
from cte
)
select term, sum(total_spent),sum(items_bought),count(frequency) as number_of_customers from long_short_term group by term;

/*
Revenue from Long term customers is greater than those of short term therefore, they are crucial for the business.
Customer loyalty plays a very important role in any business and the same is prominent in the case of chinook. 
Therefore, the company should work towards keeping the customers happy which will bring in the revenue for a longer term. 
This could be achieved by offering deals and discounts to the customers. Also the user experience is also important and should be dealt with utmost care.
*/

 -- Q4. Product Affinity Analysis: Which music genres, artists, or albums are frequently purchased 
 -- together by customers? How can this information guide product recommendations and cross-selling initiatives?
select * from invoice_line;


select il.invoice_id,g.name
from invoice_line il
left join track t on t.track_id = il.track_id
left join genre g on  g.genre_id = t.genre_id
group by il.invoice_id,g.name;
-- different genres purchased over an invoice

select il.invoice_id, al.title
from invoice_line il
left join track t on t.track_id = il.track_id
left join album al on  al.album_id = t.album_id
group by il.invoice_id, al.title;
-- different albums purchased over an invoice

select il.invoice_id,a.name 
from invoice_line il 
left join track t on t.track_id = il.track_id
left join album al on  al.album_id = t.album_id
left join artist a on a.artist_id = al.artist_id
group by il.invoice_id,a.name ;
-- different artists prefered in a single invoice



-- Q5. Regional Market Analysis: Do customer purchasing behaviors and churn rates vary across different geographic regions or store locations?
-- How might these correlate with local demographic or economic factors?


with first_six_months as
(
select billing_country, COUNT(customer_id) counter from invoice
where invoice_date between '2017-01-01' and '2017-06-30'
group by billing_country
),
last_six_months as
(
select billing_country, COUNT(customer_id) counter from invoice
where invoice_date between '2020-07-01' and '2020-12-31' 
group by billing_country
)
select f6.billing_country, (f6.counter - coalesce(l6.counter,0))/f6.counter * 100 churn_rate from first_six_months f6
left join  last_six_months l6 on f6.billing_country = l6.billing_country;

-- Q6.Customer Risk Profiling: Based on customer profiles (age, gender, location, purchase history),
-- which customer segments are more likely to churn or pose a higher risk of reduced spending? What factors contribute to this risk?

select count(distinct customer_id) as Customer_count from invoice; -- count of all the customers
select count(distinct customer_id) as Customer_count_in_2020 from invoice where extract(year from invoice_date) = '2020'; -- 58 customers

-- Q7.Customer Lifetime Value Modelling: How can you leverage customer data (tenure, purchase history, engagement)
-- to predict the lifetime value of different customer segments? This could inform targeted marketing and loyalty program strategies.
-- Can you observe any common characteristics or purchase patterns among customers who have stopped purchasing?

with cte as(select inv.customer_id,inv.billing_country,inv.invoice_date, concat(c.first_name,' ',c.last_name) as customer_name,inv.total as invoice_total
from invoice inv
left join customer c on c.customer_id = inv.customer_id
group by customer_id,2,3,inv.total
order by customer_name),
cte2 as(
select customer_id, sum(total) as LTV
from invoice
group by customer_id)
select cte.customer_id, cte.billing_country, cte.invoice_date, cte.customer_name,cte.invoice_total, cte2.LTV
from cte left join cte2 on cte.customer_id = cte2.customer_id
order by cte2.LTV desc,cte.customer_name, cte.invoice_date;


-- Q8. If data on promotional campaigns (discounts, events, email marketing) is available,
-- how could you measure their impact on customer acquisition, retention, and overall sales?


select count(*) from track; -- counting total tracks available

select t.name
from track t
where t.track_id not in ( select il.track_id
from invoice_line il
left join invoice i on i.invoice_id = il.invoice_id
where i.invoice_date>='2020-07-01' and i.invoice_date<='2020-12-31');
-- Identifying songs that were not sold in previous 6 months.
-- So promotions campaigns could be applied over them to promote their sales.

select concat(c.first_name,' ',c.last_name) as full_name
from customer c
where c.customer_id not in (select distinct(customer_id)
from invoice
where invoice_date>='2020-07-01' and invoice_date<='2020-12-31');
-- Identifying customer that have not made any purchase in previous 6 months.



-- Q9. How would you approach this problem, if the objective and subjective questions weren't given?

select * from album;
select distinct * from album; -- No duplicates

SELECT * FROM artist;
SELECT distinct * FROM artist; -- No duplicates

SELECT * from customer;
SELECT distinct * FROM customer; -- No duplicates
SELECT COUNT(*) FROM customer;
-- WHERE fax is NULL; ( count = 47)
-- WHERE state is NULL;(count = 29)
-- WHERE company is NULL; (count = 49)
-- 47 fax, 29 state and 49 company values are null in the customer table

SELECT * from employee; -- 1 reports_to value is null for employee_id = 1
SELECT distinct * FROM employee; -- No duplicates

SELECT * FROM genre;
SELECT distinct * FROM genre; -- No duplicates

SELECT * FROM invoice;
SELECT distinct * FROM invoice; -- No duplicates

SELECT * FROM invoice_line;
SELECT distinct * FROM invoice_line; -- No duplicates

SELECT * FROM media_type;
SELECT distinct * FROM media_type; -- No duplicates

SELECT * FROM playlist;
SELECT distinct * FROM playlist; -- No duplicates

SELECT * FROM playlist_track;
SELECT distinct * FROM playlist_track;

SELECT * FROM track;
SELECT distinct * FROM track; -- No duplicates


select sum(total) as yearly_revenue, extract(year from invoice_date)
from invoice
group by extract(year from invoice_date);
-- 1201.86	2017
-- 1147.41	2018
-- 1221.66	2019
-- 1138.50	2020

select customer_id, sum(total) as life_time_value from invoice
group by customer_id
order by life_time_value desc;

select billing_country, sum(total) as total_revenue from invoice
group by billing_country
order by total_revenue desc;



-- Q10. How can you alter the "Albums" table to add a new column named "ReleaseYear" of type INTEGER to store the release year of each album?

Alter table Album add ReleaseYear int;


-- Q11. Chinook is interested in understanding the purchasing behavior of customers based on their 
-- geographical location. They want to know the average total amount spent by customers from each country, 
-- along with the number of customers and the average number of tracks purchased per customer. 
-- Write an SQL query to provide this information.
with cte as(
select avg(total) Avg_total_amount_spent,
count(distinct customer_id) num_of_cust,
billing_country
from invoice i
left join invoice_line il on il.invoice_id = i.invoice_id
group by billing_country
),
cte2 as(
SELECT i.customer_id, sum(quantity) as quantity_purchased from invoice i
left join invoice_line il on il.invoice_id = i.invoice_id
group by i.customer_id
),
cte3 as(
select billing_country, avg(quantity_purchased) as avg_tracks_per_country
from invoice i
left join cte2 on cte2.customer_id = i.customer_id
group by billing_country
)
select * from cte
left join cte3 on cte3.billing_country = cte.billing_country


/*
The average total amount spent per customer seems to be in the range of 8 to 12 approximately with an outlier of 5.158 in Denmark.
Also, the number of customers are very few (single digits) in most of the countries.
USA is the country with highest number of customers.
*/