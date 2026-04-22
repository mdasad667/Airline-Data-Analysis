use cleaned_airline_data;
-- 1. Rank airlines based on total revenue.6
SELECT Airline,
       SUM(Ticket_Price) AS Revenue,
       RANK() OVER (ORDER BY SUM(Ticket_Price) DESC) AS Revenue_Rank
FROM cleaned_airline_data
WHERE Distance_km != 0
GROUP BY Airline;

-- 2. Find most used aircraft type per airline.
SELECT *
FROM (
    SELECT Airline,
           Aircraft_Type,
           COUNT(*) AS Flights,
           ROW_NUMBER() OVER (
               PARTITION BY Airline
               ORDER BY COUNT(*) DESC
           ) AS rn
    FROM cleaned_airline_data
    GROUP BY Airline, Aircraft_Type
) t
WHERE rn = 1;

-- 3. Calculate cumulative revenue over time.
SELECT Date,
       SUM(Ticket_Price) AS Daily_Revenue,
       SUM(SUM(Ticket_Price)) OVER (
           ORDER BY Date
       ) AS Running_Revenue
FROM cleaned_airline_data
WHERE Distance_km != 0
GROUP BY Date
ORDER BY Date;

-- 4. Show each flight price and compare with airline average.
SELECT Airline,
       Ticket_Price,
       AVG(Ticket_Price) OVER (PARTITION BY Airline) AS Avg_Price
FROM cleaned_airline_data;

-- 5. Calculate profit using structured query.
WITH revenue AS (
    SELECT Airline,
           SUM(CASE WHEN Distance_km != 0 THEN Ticket_Price ELSE 0 END) AS main_rev,
           SUM(CASE WHEN Distance_km = 0 THEN Ticket_Price * 0.1 ELSE 0 END) AS cancel_rev
    FROM cleaned_airline_data
    GROUP BY Airline
),
fuel AS (
    SELECT Airline,
           SUM(Fuel_Cost) AS fuel_cost
    FROM cleaned_airline_data
    GROUP BY Airline
)
SELECT r.Airline,
       (r.main_rev + r.cancel_rev - f.fuel_cost) AS Profit
FROM revenue r
JOIN fuel f ON r.Airline = f.Airline;

-- 6. Find monthly revenue and rank months.
SELECT Month,
       Revenue,
       RANK() OVER (ORDER BY Revenue DESC) AS Rank_Month
FROM (
    SELECT EXTRACT(MONTH FROM Date) AS Month,
           SUM(Ticket_Price) AS Revenue
    FROM cleaned_airline_data
    WHERE Distance_km != 0
    GROUP BY Month
) t;

-- 7. Compare each flight price with previous flight.
SELECT Airline,
       Date,
       Ticket_Price,
       LAG(Ticket_Price) OVER (
           PARTITION BY Airline
           ORDER BY Date
       ) AS Prev_Price
FROM cleaned_airline_data;

-- 8. Find % contribution of each airline to total revenue.
SELECT Airline,
       SUM(Ticket_Price) AS Revenue,
       ROUND(
           SUM(Ticket_Price) * 100.0 /
           SUM(SUM(Ticket_Price)) OVER (),
           2
       ) AS Contribution_Percentage
FROM cleaned_airline_data
WHERE Distance_km != 0
GROUP BY Airline;

-- 9. Compare flights from same origin.
SELECT a.Origin,
       a.Flight_Number AS Flight1,
       b.Flight_Number AS Flight2
FROM cleaned_airline_data a
JOIN cleaned_airline_data b
ON a.Origin = b.Origin
AND a.Flight_Number <> b.Flight_Number;
