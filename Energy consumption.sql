CREATE DATABASE ENERGYDB2;
USE ENERGYDB2;
-- 1. country table
CREATE TABLE country (
CID VARCHAR(10) PRIMARY KEY,
Country VARCHAR(100) UNIQUE
);
SELECT * FROM COUNTRY;
-- 2. emission_3 table
CREATE TABLE emission_3 (
country VARCHAR(100),
energy_type VARCHAR(50),
year INT,
emission INT,
per_capita_emission DOUBLE,
FOREIGN KEY (country) REFERENCES country(Country)
);
SELECT * FROM EMISSION_3;
-- 3. population table
CREATE TABLE population (
countries VARCHAR(100),
year INT,
Value DOUBLE,
FOREIGN KEY (countries) REFERENCES country(Country)
);
SELECT * FROM POPULATION;
-- 4. production table
CREATE TABLE production (
country VARCHAR(100),
energy VARCHAR(50),
year INT,
production INT,
FOREIGN KEY (country) REFERENCES country(Country)
);
SELECT * FROM PRODUCTION;
-- 5. gdp_3 table
CREATE TABLE gdp_3 (
Country VARCHAR(100),
year INT,
Value DOUBLE,
FOREIGN KEY (Country) REFERENCES country(Country)
);
SELECT * FROM GDP_3;
-- 6. consumption table
CREATE TABLE consumption (
country VARCHAR(100),
energy VARCHAR(50),
year INT,
consumption INT,
FOREIGN KEY (country) REFERENCES country(Country)
);

SELECT * FROM CONSUMPTION;

-- Data Analysis Questions
-- General & Comparative Analysis
-- 1.What is the total emission per country for the most recent year available?
SELECT
    country,
    SUM(emission) AS total_emission
FROM emission_3
WHERE year = (
    SELECT MAX(year)
    FROM emission_3
)
GROUP BY country
ORDER BY total_emission DESC;
-- 2.What are the top 5 countries by GDP in the most recent year?
select country, value as GDP
from gdp_3 
where year = (select Max(year) from gdp_3)
order by gdp desc
limit 5;
-- 3.Compare energy production and consumption by country and year.

select p.country,p.year,sum(p.production) as total_production,
sum(c.consumption) as total_consumption
from production p
join consumption c 
on p.country = c.country and p.year = c.year
group by p.country, p.year;


-- 4.Which energy types contribute most to emissions across all countries?
select energy_type,sum(emission) from emission_3
group by energy_type
order by sum(emission) desc;

-- Trend Analysis Over Time
-- 5.How have global emissions changed year over year?
select year, sum(emission) from emission_3
group by year
order by sum(emission) desc;
-- 6.What is the trend in GDP for each country over the given years?
select * from gdp_3
order by country,year;
-- 7.How has population growth affected total emissions in each country?
select e.country, e.year,
sum(e.emission) as total_emission,
p.value as population
from emission_3 e
join population p 
on e.country = p.countries and e.year = p.year
GROUP BY e.country, e.year, p.value
ORDER BY e.country, e.year;

-- 8.Has energy consumption increased or decreased over the years for major economies?
select country, year,
sum(consumption) as total_consumption
from consumption
group by country, year
order by country, year;
-- 9.What is the average yearly change in emissions per capita for each country?
select country,year,avg(per_capita_emission) from emission_3
group by country,year
order by country,year;
-- Ratio & Per Capita Analysis
-- 10.What is the emission-to-GDP ratio for each country by year?
select e.country, e.year,
sum(e.emission) / sum(g.value) as emission_gdp_ratio
from emission_3 e
join gdp_3 g 
on e.country = g.country and e.year = g.year
group by e.country, e.year;
-- 11.What is the energy consumption per capita for each country over the last decade?
select c.country,c.year,
sum(c.consumption) / sum(p.value) as consumption_per_capita
from consumption c
join population p 
on c.country = p.countries and c.year = p.year
group by c.country, c.year
order by c.country, c.year;
-- 12.How does energy production per capita vary across countries?
select pr.country,pr.year,
sum(pr.production) /sum(p.value) as Production_per_capita
from production pr
join population p 
on pr.country = p.countries and pr.year = p.year
group by pr.country, pr.year
order by c.country, c.year;
-- 13.Which countries have the highest energy consumption relative to GDP?
select c.country,c.year,
sum(c.consumption) / sum(g.Value) as consumption_gdp_ratio
from consumption c
join gdp_3 g 
on c.country = g.Country and c.year = g.year
group by c.country, c.year
order by consumption_gdp_ratio desc;
-- 14.What is the correlation between GDP growth and energy production growth?
select g.Country,g.year,
sum(g.Value) as total_gdp,
sum(p.production) as total_production
from gdp_3 g
join production p 
on g.Country = p.country and g.year = p.year
group by g.Country, g.year
order by g.Country, g.year;

-- Global Comparisons
-- 15 What are the top 10 countries by population and how do their emissions compare?
select p.countries as country,
sum(p.Value) as population,
sum(e.emission) as total_emission
from population p
join emission_3 e 
on p.countries = e.country and p.year = e.year
group by p.countries
order by population desc
limit 10;

-- 16 Which countries have improved (reduced) their per capita emissions the most over the last decade?
select country, max(per_capita_emission) - min(per_capita_emission) AS emission_reduction
from emission_3
group by country
order by emission_reduction desc;

-- 17 What is the global share (%) of emissions by country?
select country,
sum(emission) * 100.0 / (select sum(emission) from emission_3) as emission_share_percent
from emission_3
group by country
order by emission_share_percent desc;

-- 18 What is the global average GDP, emission, and population by year?
select e.year, avg(g.value) as avg_gdp,
avg(e.emission) as avg_emission,
avg(p.Value) as avg_population
from emission_3 e
join gdp_3 g 
on e.country = g.Country and e.year = g.year
join population p 
on e.country = p.countries and e.year = p.year
group by e.year
order by e.year;

