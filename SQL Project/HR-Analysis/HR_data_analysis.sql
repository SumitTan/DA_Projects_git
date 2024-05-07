CREATE DATABASE project_hr;
USE  project_hr;

select * from hr;

-- data cleaning and processiong 

ALTER TABLE hr change column ï»¿id emp_id VARCHAR(20) NULL;

describe hr;

-- Set value of safe Update to FALSE
SET sql_safe_updates = 0;

Update hr 
SET birthdate = CASE
       WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
       WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
       ELSE  NULL
       END;

ALTER TABLE hr MODIFY COLUMN birthdate DATE;

-- change the date format and datatype of hire_date column

Update hr 
SET hire_date = CASE
       WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
       WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date,'%m-%d-%Y'),'%Y-%m-%d')
       ELSE  NULL
       END;

ALTER TABLE hr MODIFY COLUMN hire_date DATE;

-- change the date format and datatype of termdate column

UPDATE hr
SET termdate = date(str_to_date(termdate,'%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate !='';

UPDATE hr
SET termdate = NULL WHERE termdate = '';

-- create age column

ALTER TABLE hr
ADD column age INT;

UPDATE hr SET age = timestampdiff(YEAR,birthdate,curdate());

select min(age),max(age) from hr;

-- Q1. What is the gender breakdown of employees in the country
SELECT gender,count(*) gender_count from hr WHERE termdate IS NULL group by gender;

-- Q2. What is the race breakdown of employees in the country
SELECT race, count(*) count_race FROM hr WHERE termdate IS NULL group by race;

-- Q3. What is the age distribution of employees in the company
SELECT 
CASE 
     WHEN age>=18 AND age<=24 THEN '18-24'
     WHEN age>=25 AND age<=34 THEN '25-34'
     WHEN age>=35 AND age<=44 THEN '35-44'
     WHEN age>=45 AND age<=54 THEN '45-54'
     WHEN age>=55 AND age<=64 THEN '55-64'
     ELSE '65+'
END AS age_group,
COUNT(*) AS count
FROM hr
WHERE termdate IS NULL
GROUP BY age_group
ORDER BY age_group;     

-- Q4. How many employees work at HQ vs remote
SELECT location,COUNT(*) AS count
FROM hr
WHERE termdate IS NULL
GROUP BY location;

-- Q5. What is the average length of employement who have been terminated?
SELECT ROUND(AVG(year(termdate) - year(hire_date)),0) AS length_of_emp
FROM hr
WHERE termdate IS NOT NULL AND termdate <= curdate();

-- Q6. How does the gender distribution vary across department and job titles
SELECT * from hr;

SELECT department,jobtitle,gender,COUNT(gender) AS count
FROM hr
WHERE termdate IS NOT NULL
GROUP BY department,jobtitle,gender
ORDER BY department,jobtitle,gender;

SELECT department,gender,COUNT(gender) AS count
FROM hr
WHERE termdate IS NOT NULL
GROUP BY department,gender
ORDER BY department,gender;

-- Q7. What is the distribution of job title across company
SELECT jobtitle,COUNT(jobtitle) AS count
FROM hr
WHERE termdate IS NOT NULL
GROUP BY jobtitle;

-- Q8. Which department has the higher turnover/termination rate
SELECT department,
       COUNT(*) AS total_count,
       COUNT( CASE
                  WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1
                  END) AS terminated_count,
                  ROUND((COUNT(CASE
                  WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1
                  END)/COUNT(*))*100,2) AS termination_rate
	   FROM hr
       GROUP BY department
       ORDER BY termination_rate;
       
-- Q9. What is the distribution of employees across location_state
SELECT location_state,COUNT(*) AS count
FROM hr
WHERE termdate IS NULL
GROUP BY location_state;  

-- Q10. How has the company employee count changed over time based on hire and termination date
SELECT year,
       hires,
       terminations,
       hires-terminations AS net_change,
       ROUND((terminations/hires)*100,1) AS change_percent
   FROM(
          SELECT YEAR(hire_date) AS year,
		  Count(*) AS hires,
          SUM(CASE
                  WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1
			  END) AS terminations
		  FROM hr
          GROUP BY YEAR(hire_date)) AS subquery
  Group BY year
  ORDER BY year;
  
-- Q11. What is the tenure distribution for each department?
SELECT department, ROUND(AVG(datediff(termdate,hire_date)/365),0) AS avg_tenure
FROM hr
WHERE termdate IS NOT NULL AND termdate <= curdate()
GROUP BY department;
       
-- Q12. Find count of states
SELECT location_state,COUNT(location_state) count FROM hr GROUP BY location_state ORDER BY count DESC;   

-- Q13. Find total of jobtitles in each department
SELECT department,jobtitle,COUNT(department) as department_count FROM hr group by department,jobtitle ORDER BY department; 

-- Q14. Find termination and hire breakdown on basis of gender
SELECT 
gender,total_hires,total_terminations,ROUND((total_terminations/total_hires)*100,2) termiantion_rate
FROM (SELECT gender,
             COUNT(gender) total_hires,
             COUNT(CASE
                       WHEN termdate IS NOT NULL AND termdate <=curdate() THEN 1
                       END) total_terminations
                       FROM hr
                       GROUP BY gender) subquery
GROUP BY gender;

-- Q15. Find termination and hire breakdown on basis of age
SELECT 
age,total_hires,total_terminations,ROUND((total_terminations/total_hires)*100,2) termiantion_rate
FROM (SELECT age,
             COUNT(*) total_hires,
             COUNT(CASE
                       WHEN termdate IS NOT NULL AND termdate <=curdate() THEN 1
                       END) total_terminations
                       FROM hr
                       GROUP BY age) subquery
GROUP BY age
ORDER BY age;

-- Q16. Find termination and hire breakdown on basis of department
SELECT 
department,total_hires,total_terminations,ROUND((total_terminations/total_hires)*100,2) termiantion_rate
FROM (SELECT department,
             COUNT(department) total_hires,
             COUNT(CASE
                       WHEN termdate IS NOT NULL AND termdate <=curdate() THEN 1
                       END) total_terminations
                       FROM hr
                       GROUP BY department) subquery
GROUP BY department
ORDER BY department;

-- Q17. Find termination and hire breakdown on basis of race
SELECT 
race,total_hires,total_terminations,ROUND((total_terminations/total_hires)*100,2) termiantion_rate
FROM (SELECT race,
             COUNT(race) total_hires,
             COUNT(CASE
                       WHEN termdate IS NOT NULL AND termdate <=curdate() THEN 1
                       END) total_terminations
                       FROM hr
                       GROUP BY race) subquery
GROUP BY race
ORDER BY race;

-- Set value of safe update to TRUE
SET sql_safe_updates = 1;

-- Q18. Find termination and hire breakdown on basis of year
SELECT 
year,hires,terminations,ROUND((terminations/hires)*100,2) termiantion_rate
FROM (SELECT YEAR(hire_date) year,
             COUNT(*) hires,
              SUM(CASE
                  WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1
			  END) AS terminations
		  FROM hr
          GROUP BY YEAR(hire_date)) AS subquery
  Group BY year
  ORDER BY year;