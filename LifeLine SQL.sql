WITH yearly AS (
    SELECT year, SUM(suicides_no) AS total
    FROM suicide_data
    GROUP BY year
)
SELECT 
    year,
    total,
    LAG(total) OVER (ORDER BY year) AS prev_year,
    total - LAG(total) OVER (ORDER BY year) AS growth
FROM yearly;

WITH ranked AS (
    SELECT year, country,
           SUM(suicides_no) AS total,
           RANK() OVER (PARTITION BY year ORDER BY SUM(suicides_no) DESC) AS rnk
    FROM suicide_data
    GROUP BY year, country
)
SELECT * FROM ranked WHERE rnk = 1;

SELECT year,
       SUM(suicides_no) AS total,
       AVG(SUM(suicides_no)) OVER (
           ORDER BY year 
           ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
       ) AS moving_avg
FROM suicide_data
GROUP BY year;

SELECT country,
       SUM(suicides_no)*100000.0 / SUM(population) AS rate,
       DENSE_RANK() OVER (
           ORDER BY SUM(suicides_no)*100000.0 / SUM(population) DESC
       ) AS rank
FROM suicide_data
GROUP BY country;

SELECT country,
       SUM(CASE WHEN sex = 'male' THEN suicides_no ELSE 0 END) AS male,
       SUM(CASE WHEN sex = 'female' THEN suicides_no ELSE 0 END) AS female,
       CAST(SUM(CASE WHEN sex = 'male' THEN suicides_no ELSE 0 END) AS FLOAT) /
       NULLIF(SUM(CASE WHEN sex = 'female' THEN suicides_no ELSE 0 END), 0) AS ratio
FROM suicide_data
GROUP BY country;

WITH ranked AS (
    SELECT country, age,
           SUM(suicides_no) AS total,
           ROW_NUMBER() OVER (
               PARTITION BY country 
               ORDER BY SUM(suicides_no) DESC
           ) AS rn
    FROM suicide_data
    GROUP BY country, age
)
SELECT * FROM ranked WHERE rn = 1;

WITH trend AS (
    SELECT country, year,
           SUM(suicides_no) AS total,
           LAG(SUM(suicides_no)) OVER (PARTITION BY country ORDER BY year) AS prev
    FROM suicide_data
    GROUP BY country, year
)
SELECT country
FROM trend
WHERE total < prev
GROUP BY country;

SELECT 
    year,
    AVG(gdp_per_capita) AS avg_gdp,
    SUM(suicides_no)*100000.0 / SUM(population) AS rate
FROM suicide_data
GROUP BY year;

SELECT generation,
       SUM(suicides_no) AS total,
       100.0 * SUM(suicides_no) / SUM(SUM(suicides_no)) OVER () AS percentage
FROM suicide_data
GROUP BY generation;

WITH ranked AS (
    SELECT year, country,
           SUM(suicides_no) AS total,
           ROW_NUMBER() OVER (
               PARTITION BY year ORDER BY SUM(suicides_no) DESC
           ) AS rn
    FROM suicide_data
    GROUP BY year, country
)
SELECT * FROM ranked WHERE rn <= 3;

SELECT age,
       SUM(suicides_no) AS total,
       100.0 * SUM(suicides_no) / SUM(SUM(suicides_no)) OVER () AS percentage
FROM suicide_data
GROUP BY age;

SELECT year,
       SUM(suicides_no) AS total,
       SUM(SUM(suicides_no)) OVER (ORDER BY year) AS cumulative
FROM suicide_data
GROUP BY year;

WITH stats AS (
    SELECT country,
           SUM(suicides_no)*100000.0 / SUM(population) AS rate
    FROM suicide_data
    GROUP BY country
)
SELECT *
FROM stats
WHERE rate > (SELECT AVG(rate) + 2*STDEV(rate) FROM stats);

SELECT year,
       STDEV(suicides_no) AS std_dev
FROM suicide_data
GROUP BY year;

WITH ranked AS (
    SELECT year, country,
           SUM(suicides_no) AS total,
           RANK() OVER (PARTITION BY year ORDER BY SUM(suicides_no) DESC) AS rnk
    FROM suicide_data
    GROUP BY year, country
)
SELECT *,
       LAG(rnk) OVER (PARTITION BY country ORDER BY year) AS prev_rank
FROM ranked;

WITH ranked AS (
    SELECT year, country,
           SUM(suicides_no) AS total,
           ROW_NUMBER() OVER (
               PARTITION BY year ORDER BY SUM(suicides_no)
           ) AS rn
    FROM suicide_data
    GROUP BY year, country
)
SELECT * FROM ranked WHERE rn <= 5;

SELECT country,
       SUM(suicides_no * gdp_per_capita) / SUM(gdp_per_capita) AS weighted_rate
FROM suicide_data
GROUP BY country;

SELECT country,
       SUM(population) AS total_pop,
       SUM(suicides_no) AS total_suicides,
       SUM(suicides_no)*100000.0 / SUM(population) AS density
FROM suicide_data
GROUP BY country;

SELECT country,
       COUNT(*) AS missing_count
FROM suicide_data
WHERE HDI_for_year IS NULL
GROUP BY country
ORDER BY missing_count DESC;

WITH yearly AS (
    SELECT country, year,
           SUM(suicides_no) AS total,
           LAG(SUM(suicides_no)) OVER (PARTITION BY country ORDER BY year) AS prev
    FROM suicide_data
    GROUP BY country, year
)
SELECT TOP 1 country,
       SUM(total - prev) AS growth
FROM yearly
GROUP BY country
ORDER BY growth DESC;

SELECT country, year,
       SUM(suicides_no) AS total,
       AVG(SUM(suicides_no)) OVER (
           PARTITION BY country 
           ORDER BY year 
           ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
       ) AS rolling_avg
FROM suicide_data
GROUP BY country, year;
