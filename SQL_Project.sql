
Create database AmazonSalesData;
SELECT * FROM Amazon;
SELECT COUNT(Invoice_ID) from Amazon;
SELECT * FROM Amazon;
-- 1.3 selecting columns with null values in them
select count(*) as count_of_null_values from Amazon where null;
-- feature engineering-------
-- Adding new columns timeofday, dayname, monthname by extracting values from existing time and date column.alter
SET SQL_SAFE_UPDATES = 0;
ALTER table Amazon add time_of_day VARCHAR(15) not null;
UPDATE amazon 
SET time_of_day = 
    CASE 
        WHEN HOUR(time) BETWEEN 06 AND 11 THEN 'Morning'
        WHEN HOUR(time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END;
ALTER table Amazon add day_name varchar(10) not null;
Update Amazon set day_name = (select dayname(date));
Alter table Amazon add month_name VARCHAR(20) NOT NULL;
Update Amazon set month_name = (select monthname(date));
-- Answering Questions
-- 1. What is the count of distinct cities in the dataset?
SELECT COUNT(DISTINCT(City)) from Amazon; # This indicates that there are only 3 unique cities in the dataset
-- 2.  For each branch, what is the corresponding city?
SELECT distinct city, branch from Amazon; #This indicates the corresponding branch for each of the city
-- 3. What is the count of distinct product lines in the dataset?
SELECT COUNT(DISTINCT(Product_line)) from Amazon; #There are six distinct product line in the dataset of Amazon sales
-- 4. Which payment method occurs most frequently?
SELECT Payment, COUNT(*) AS frequency 
FROM Amazon
GROUP BY Payment; # e-wallet is the most frequently opted payment method by the customers of Amazon while credit card is the least. but usually the three payment methods are E-Wallet, Cash, Credit Card
-- 5. Which product line has the highest sales?
select product_line, sum(quantity) as total_sales from amazon
group by product_line 
order by total_sales desc Limit 1; #Only electric accessories is the highest sold product in the Amazon
-- 6. How much revenue is generated each month?
SELECT month_name, SUM(total) as monthly_revenue from Amazon group by month_name; #This query shows the monthly revenue generated each month.
-- 7. In which month did the cost of goods sold reach its peak?
SELECT month_name, SUM(cogs) as cost_of_goods_at_peak from Amazon group by month_name order by cost_of_goods_at_peak desc limit 1; # In the month of January the cogs reached its peak
-- 8. Which product line generated the highest revenue?
Select Product_line, sum(Total) as product_with_highest_revenue from Amazon group by Product_line order by  product_with_highest_revenue desc Limit 1; #Foods and beverages product line yielded the highest revenue
-- 9. In which city was the highest revenue recorded?
select City, sum(Total) as highest_revenue FROM Amazon group by city order by highest_revenue desc Limit 1; # In the Naypyitaw city highest revenue was recorded
 -- 10. Which product line incurred the highest Value Added Tax?
 select Product_line, SUM(VAT) as VAT_with_highest_value from Amazon group by Product_line order by VAT_with_highest_value desc; # Food and beverage incurred the highest revenue tax
 -- 11. For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
 SELECT 
    Product_line,
    ROUND(AVG(total), 2) AS avg_sales,
CASE
        WHEN
            AVG(total) > (SELECT 
                    AVG(total)
                FROM
                    Amazon)
        THEN
            'Good'
        ELSE 'Bad'
    END AS Remarks
FROM
    Amazon
GROUP BY product_line
ORDER BY avg_sales
;


-- 12. Identify the branch that exceeded the average number of products sold
select Branch, SUM(quantity) from Amazon group by Branch HAVING SUM(quantity)> (select AVG(quantity) from Amazon); #Branch A exceeded the avergae number of products sold
-- 13. Which product line is most frequently associated with each gender?	
select Product_line, COUNT(Gender) AS frequent_Product_line,gender from Amazon group by Product_line, gender order by  frequent_Product_line desc; #
#14.Calculate the average rating for each product line
select Product_line, avg(Rating) as average_rate from Amazon group by Product_line order by average_rate desc;
#15. Count the sales occurrences for each time of day on every weekday.
select day_name, time_of_day, count(*) sales from amazon 
group by day_name, time_of_day
order by field(day_name, 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'), 
field(time_of_day, 'Morning', 'Afternoon', 'Evening');
#16. Identify the customer type contributing the highest revenue.
SELECT `Customer type`, SUM(total) AS highest_revenue 
FROM Amazon 
GROUP BY `Customer type` 
ORDER BY highest_revenue DESC;
#17. Determine the city with the highest VAT percentage.
select city, MAX(VAT) AS max_VAT from Amazon group by city having MAX(VAT)= (select max(VAT) from Amazon ); 
 #18.  Identify the customer type with the highest VAT payments.    
SELECT `Customer type`, SUM(VAT) AS highest_revenue 
FROM Amazon 
GROUP BY `Customer type` 
ORDER BY highest_revenue DESC limit 1;
# 19. What is the count of distinct customer types in the dataset?
SELECT 
    COUNT(DISTINCT `customer type`) AS unique_customer
FROM
    Amazon;

-- 20. What is the count of distinct payment methods in the dataset?	* Count of unique payment method
	SELECT 
    COUNT(DISTINCT `Payment`) AS unique_customer
FROM
    Amazon;
-- 21. Which customer type occurs most frequently?
select `Customer type`, count(*) as frequent_occur from Amazon group by `customer type` order by frequent_occur desc; #Customer belonging from member type has the most sales
-- 22. Identify the customer type with the highest purchase frequency.
select `Customer type`, count(Total) as frequency_of_purchase from Amazon group by  `customer type` order by  frequency_of_purchase desc limit 1; #member customer type have the highest purchase frequency 
-- 23. Determine the predominant gender among customers.
select gender, count(*) as predominant_gender from Amazon group by gender order by predominant_gender desc limit 1; #female is the predominant gender among customers
-- 24. Examine the distribution of genders within each branch.
select Branch, count(gender) as Distributed_Genders from Amazon group by Branch order by Distributed_Genders desc; #demonstrates distribution of gender among each branch
 -- 25. Determine the time of day with the highest customer ratings for each branch.
 With highest_rating as (select time_of_day,max(Rating) As most_rated,Customer from Amazon group by Rating) select * from highest_rating;  
 -- 26. Determine the time of day with the highest customer ratings for each branch
 WITH AvgRatings AS (
    SELECT Branch, time_of_day, AVG(Rating) AS avg_rating
    FROM Amazon
    GROUP BY Branch, time_of_day
),
MaxRatings AS (
    SELECT Branch, MAX(avg_rating) AS max_rating
    FROM AvgRatings
    GROUP BY Branch
)
SELECT A.Branch, A.time_of_day, A.avg_rating
FROM AvgRatings A
JOIN MaxRatings M ON A.Branch = M.Branch AND A.avg_rating = M.max_rating;
-- 27.  Identify the day of the week with the highest average ratings.
SELECT day_name, AVG(Rating) AS avg_rating
FROM Amazon
GROUP BY day_name
ORDER BY avg_rating DESC
LIMIT 1;
-- 28. Determine the day of the week with the highest average ratings for each branch.
WITH AvgRatings AS (
    SELECT Branch, day_name, AVG(Rating) AS avg_rating
    FROM Amazon
    GROUP BY Branch, day_name
),
MaxRatings AS (
    SELECT Branch, MAX(avg_rating) AS max_rating
    FROM AvgRatings
    GROUP BY Branch
)
SELECT A.Branch, A.day_name, A.avg_rating
FROM AvgRatings A
JOIN MaxRatings M ON A.Branch = M.Branch AND A.avg_rating = M.max_rating;
