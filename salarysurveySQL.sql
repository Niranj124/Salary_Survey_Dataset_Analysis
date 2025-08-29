create database Salary_Survey_dataset;

use Salary_Survey_dataset;

CREATE TABLE Salary_Clean_Data (
    Age_Range VARCHAR(20),
    Industry VARCHAR(100),
    Job_Title VARCHAR(100),
    Annual_Salary INT,
    USD_Salary INT,
    Additional_Monetary_Compensation INT,
    USD_Additional_Monetary_Compensation INT,
    Currency VARCHAR(10),
    Income_Clarification VARCHAR(100),
    Country VARCHAR(100),
    State VARCHAR(100),
    City VARCHAR(100),
    Years_of_Professional_Experience_Overall VARCHAR(100),
    Years_of_Professional_Experience_in_Field VARCHAR(100),
    Highest_Level_of_Education_Completed VARCHAR(100),
    Gender VARCHAR(50)
);


SHOW DATABASES;

USE Milestone;

SELECT COUNT(*) FROM salary_clean_data;

SELECT * FROM salary_clean_data;

-- 1.Average Salary by Industry and Gender

SELECT 
    Industry,
    Gender,
    AVG(USD_Salary) AS Average_Salary
FROM 
salary_clean_data
GROUP BY 
    Industry, Gender
ORDER BY 
    Industry, Gender;
    
-- 2. Total Salary Compensation by Job Title

SELECT 
    Job_Title,
    SUM(USD_Salary + IFNULL(USD_Additional_Monetary_Compensation, 0)) AS Total_Compensation
FROM 
    Salary_Clean_Data
GROUP BY 
    Job_Title
ORDER BY 
    Total_Compensation DESC;
    
-- 3. Salary Distribution by Education Level

SELECT 
    Highest_Level_of_Education_Completed AS Education_Level,
    AVG(USD_Salary) AS Average_Salary,
    MIN(USD_Salary) AS Minimum_Salary,
    MAX(USD_Salary) AS Maximum_Salary
FROM 
    Salary_Clean_Data
GROUP BY 
    Highest_Level_of_Education_Completed
ORDER BY 
    Average_Salary DESC;

-- Number of Employees by Industry and Years of Experience   

SELECT 
    Industry,
    Years_of_Professional_Experience_Overall AS Experience_Level,
    COUNT(*) AS Number_of_Employees
FROM 
    salary_clean_data
GROUP BY 
    Industry, Years_of_Professional_Experience_Overall
ORDER BY 
    Industry, Experience_Level;
    
    
-- 5. Median Salary by Age Range and Gender

WITH RankedSalaries AS (
  SELECT
    Age_Range,
    Gender,
    USD_Salary,
    ROW_NUMBER() OVER (PARTITION BY Age_Range, Gender ORDER BY USD_Salary) AS rn,
    COUNT(*) OVER (PARTITION BY Age_Range, Gender) AS total_count
  FROM
    salary_clean_data
  WHERE
    USD_Salary IS NOT NULL
),
MedianSalaries AS (
  SELECT
    Age_Range,
    Gender,
    USD_Salary,
    rn,
    total_count
  FROM
    RankedSalaries
  WHERE
    rn = FLOOR((total_count + 1) / 2) -- For odd counts
    OR rn = FLOOR((total_count + 2) / 2) -- For even counts (2 middle values)
)
SELECT
  Age_Range,
  Gender,
  ROUND(AVG(USD_Salary), 2) AS Median_Salary
FROM
  MedianSalaries
GROUP BY
  Age_Range, Gender
ORDER BY
  Age_Range, Gender;


-- 6. Job Titles with the Highest Salary in Each Country

WITH MaxSalaries AS (
    SELECT 
        Country,
        MAX(USD_Salary) AS Max_Salary
    FROM 
        salary_clean_data
    WHERE 
        USD_Salary IS NOT NULL
    GROUP BY 
        Country
)
SELECT 
    s.Country,
    s.Job_Title,
    s.USD_Salary AS Highest_Salary
FROM 
    salary_clean_data s
JOIN 
    MaxSalaries m 
    ON s.Country = m.Country AND s.USD_Salary = m.Max_Salary
ORDER BY 
    s.Country;


-- 7. Average Salary by City and Industry

SELECT 
    City,
    Industry,
    ROUND(AVG(USD_Salary), 2) AS Average_Salary
FROM 
    salary_clean_data
WHERE 
    USD_Salary IS NOT NULL
GROUP BY 
    City, Industry
ORDER BY 
    Industry, Average_Salary DESC;

-- 8. Percentage of Employees with Additional Monetary Compensation by Gender

SELECT 
    Gender,
    ROUND(
        100.0 * SUM(CASE 
            WHEN USD_Additional_Monetary_Compensation > 0 THEN 1 
            ELSE 0 
        END) / COUNT(*), 
        2
    ) AS Percentage_With_Additional_Compensation
FROM 
    salary_clean_data
WHERE 
    Gender IS NOT NULL
GROUP BY 
    Gender
ORDER BY 
    Percentage_With_Additional_Compensation DESC;

-- 9. Total Compensation by Job Title and Years of Experience

SELECT 
    Job_Title,
    Years_of_Professional_Experience_Overall AS Experience_Level,
    SUM(IFNULL(USD_Salary, 0) + IFNULL(USD_Additional_Monetary_Compensation, 0)) AS Total_Compensation
FROM 
    salary_clean_data
WHERE 
    Job_Title IS NOT NULL 
    AND Years_of_Professional_Experience_Overall IS NOT NULL
GROUP BY 
    Job_Title, Experience_Level
ORDER BY 
    Job_Title, Experience_Level;

-- 10. Average Salary by Industry, Gender, and Education Level

SELECT 
    Industry,
    Gender,
    Highest_Level_of_Education_Completed AS Education_Level,
    ROUND(AVG(USD_Salary), 2) AS Average_Salary
FROM 
    salary_clean_data
WHERE 
    USD_Salary IS NOT NULL
    AND Industry IS NOT NULL
    AND Gender IS NOT NULL
    AND Highest_Level_of_Education_Completed IS NOT NULL
GROUP BY 
    Industry, Gender, Education_Level
ORDER BY 
    Industry, Gender, Education_Level;




