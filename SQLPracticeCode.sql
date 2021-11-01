-- What is the total Revenue of the company this year (FY21)?
Select SUM(r.Revenue) AS TotalRevenue21 from RevenueRawData r
where r.Month_ID in (select DISTINCT c.Month_ID 
from Calendar_lookup c
where c.Fiscal_Year = 'FY21')
-- group by Month_ID
-- ORDER BY Month_ID
select * from RevenueRawData
select * from Calendar_lookup

-- 2.What is the total Revenue Performance YoY? Comparing revenue 2021 to 2020

SELECT b.TotalRevenue20,a.TotalRevenue21 ,(a.TotalRevenue21-b.TotalRevenue20) AS Diff, (a.TotalRevenue21/cast(b.TotalRevenue20 as decimal))-1 AS Diff_percentage 
from
(
Select SUM(r.Revenue) AS TotalRevenue21 from RevenueRawData r
where r.Month_ID in (select DISTINCT c.Month_ID 
from Calendar_lookup c
where c.Fiscal_Year = 'FY21')) a,
(Select SUM(r.Revenue) AS TotalRevenue20 from RevenueRawData r
where r.Month_ID in (select DISTINCT top 6 c.Month_ID 
from Calendar_lookup c
where c.Fiscal_Year = 'FY20'
order by c.Month_ID)
) b

-- 3. What is the MoM Revenue Performance by year?


select a.Month_Name, min(Revenue21) as Revenue21, min(Revenue20) as Revenue20, min(Revenue21) - min(Revenue20) as diff,
(1.0*min(Revenue21)/min(Revenue20)) -1 as DiffPercent
from
(
select Month_Name, sum(Revenue) as Revenue21
from RevenueRawData r
join Calendar_lookup c
on r.Month_ID = c.Month_ID
where c.Fiscal_Year = 'FY21'
group by Month_Name
) a,
(
select top 6 r.Month_ID, Month_Name, sum(Revenue) as Revenue20
from RevenueRawData r
join Calendar_lookup c
on r.Month_ID = c.Month_ID
where c.Fiscal_Year = 'FY20'
group by r.Month_ID, Month_Name
order by r.Month_ID
) b
group by a.Month_Name
order by a.Month_Name

-- 3. What is the MoM Revenue Performance by year?
select a.RevenueThisMonth, b.RevenueLastMonth, a.RevenueThisMonth - b.RevenueLastMonth as Diff, (1.0*a.RevenueThisMonth/b.RevenueLastMonth)-1 as DiffPercent
from
(select sum(Revenue) as RevenueThisMonth from RevenueRawData where Month_ID = (
select max(Month_ID) from RevenueRawData)) a,
(select sum(Revenue) as RevenueLastMonth from RevenueRawData where Month_ID = (
select max(Month_ID)-1 from RevenueRawData)) b

-- 4. What is the total revenue vs target performance for the Year?
-- First solution by month
select a.Month_ID, min(a.TotalRevenue) as TotalRevenue , min(b.TotalTarget) as TotalTarget, min(b.TotalTarget) - min(a.TotalRevenue) as diff,
(1.0* min(a.TotalRevenue)/min(b.TotalTarget))-1 as DiffPercent
from 
(
select r.Month_ID, sum(Revenue) as  TotalRevenue from RevenueRawData r 
where r.Month_ID in (select c.Month_ID from Calendar_lookup c where c.Fiscal_Year = 'FY21')
group by r.Month_ID
) a,

(SELECT top 6 t.Month_ID, sum(t.Target) as TotalTarget  FROM TargetsRawData t 
where t.Month_ID in (select c.Month_ID from Calendar_lookup c where c.Fiscal_Year = 'FY21')
group by t.Month_ID
) b
group by a.Month_ID

-- By Year
select  sum(a.TotalRevenue) as TotalRevenue , sum(b.TotalTarget) as TotalTarget, sum(b.TotalTarget) - sum(a.TotalRevenue) as diff,
(1.0* sum(a.TotalRevenue)/sum(b.TotalTarget))-1 as DiffPercent
from 
(
select r.Month_ID, sum(Revenue) as  TotalRevenue from RevenueRawData r 
where r.Month_ID in (select c.Month_ID from Calendar_lookup c where c.Fiscal_Year = 'FY21')
group by r.Month_ID
) a,

(SELECT top 6 t.Month_ID, round(sum(t.Target),2) as TotalTarget  FROM TargetsRawData t 
where t.Month_ID in (select c.Month_ID from Calendar_lookup c where c.Fiscal_Year = 'FY21')
group by t.Month_ID
) b

select sum(MonthlyRevenue) as TotalRevenue, sum(MonthlyTarget) as TotalTarget, sum(MonthlyRevenue)-sum(MonthlyTarget) as diff,
(1.0*sum(MonthlyRevenue)/sum(MonthlyTarget))-1 as DiffPercent 
from
(SELECT Month_ID, sum(Revenue) as MonthlyRevenue FROM RevenueRawData
group by Month_ID) a
join
(
SELECT Month_ID, round(sum(Target),2) as MonthlyTarget FROM TargetsRawData
group by Month_ID) b 
on a.Month_ID = b.Month_ID
where a.Month_ID in (select distinct c.Month_ID from Calendar_lookup c where c.Fiscal_Year = 'FY21')

-- 5. What is the Revenue vs Target Performance per Month?
select a.Month_ID, c.Fiscal_Month MonthlyRevenue, MonthlyTarget, MonthlyRevenue-MonthlyTarget as diff,
(1.0*MonthlyRevenue/MonthlyTarget)-1 as DiffPercent 
from
(
SELECT Month_ID, sum(Revenue) as MonthlyRevenue FROM RevenueRawData
where Month_ID in (select distinct c.Month_ID from Calendar_lookup c where c.Fiscal_Year = 'FY21')
group by Month_ID
) a
join
(
SELECT Month_ID, round(sum(Target),2) as MonthlyTarget FROM TargetsRawData
where Month_ID in (select distinct c.Month_ID from Calendar_lookup c where c.Fiscal_Year = 'FY21')
group by Month_ID
) b 
on a.Month_ID = b.Month_ID
inner join 
(select distinct Month_ID, Fiscal_Month from Calendar_lookup) c
on a.Month_ID = c.Month_ID

-- 6. What is the best performing product in terms of revenue this year?
select top 1 a.Product_Category, a.TotalRevenue from (
select Product_Category, Sum(Revenue) as TotalRevenue from RevenueRawData
where Month_ID in (select distinct c.Month_ID from Calendar_lookup c where c.Fiscal_Year = 'FY21')
group by Product_Category) a


-- 7. What is the product performance vs Target for the month?

select Month_ID, Product_Category, round(sum(Target),2) as Target from TargetsRawData
where Month_ID in (select max(Month_ID) from RevenueRawData)
group by Month_ID, Product_Category 

select a.Month_ID, a.Product_Category, Revenue, b.Target, Revenue - Target as diff, Revenue/Target -1 as diffpercent
from(
select Month_ID, Product_Category, sum(Revenue) as Revenue from RevenueRawData
where Month_ID in (select max(Month_ID) from RevenueRawData)
group by Month_ID, Product_Category
) a
join
(
select Month_ID, Product_Category, round(sum(Target),2) as Target from TargetsRawData
where Month_ID in (select max(Month_ID) from RevenueRawData)
group by Month_ID, Product_Category
) b
on a.Product_Category = b.Product_Category
-- 8. Which account is performing the best in terms of revenue?

select New_Account_Name, SUM(Revenue) as TotalRevenue 
from RevenueRawData r
join Account_lookup a
on r.Account_No = a.New_Account_No
group by New_Account_Name
order by TotalRevenue DESC

select New_Account_Name, SUM (Revenue) as TotalRevenue
from RevenueRawData r
join account_lookup a
on r.Account_No = a.New_Account_No
where Month_ID in (select distinct Month_ID from Calendar_lookup where Fiscal_Year = 'FY21')
group by New_Account_Name
order by TotalRevenue DESC

select * from account_lookup

-- 9. Which account is performing the best in terms of revenue vs target?
select * from TargetsRawData


select New_Account_Name, TotalRevenue, TotalTarget, TotalRevenue/TotalTarget - 1 as DiffPercent
from
     (
     select ISNULL(a.Account_No, b.Account_No) as Account_No,TotalRevenue,TotalTarget 
     from
          (
          select Account_No, sum(Revenue) as TotalRevenue from RevenueRawData
          where Month_ID in (select distinct Month_ID from Calendar_lookup where Fiscal_Year = 'FY21')
          group by Account_No
          ) a
          full join
          (
          select Account_No, round(sum(Target),2) as TotalTarget from TargetsRawData
          where Month_ID in (select distinct Month_ID from Calendar_lookup where Fiscal_Year = 'FY21')
          group by Account_No 
          ) b
          on a.Account_No = b.Account_No) d
     left join
     account_lookup c
     on d.Account_No = c.New_Account_No
group by New_Account_Name, TotalRevenue, TotalTarget
order by DiffPercent DESC

-- 10. Which account is performing the worst in terms of meeting target for the year?
select New_Account_Name, TotalRevenue, TotalTarget, ISNULL(TotalRevenue-TotalTarget,0) as Diff
from
     (
     select ISNULL(a.Account_No, b.Account_No) as Account_No,TotalRevenue,TotalTarget 
     from
          (
          select Account_No, sum(Revenue) as TotalRevenue from RevenueRawData
          where Month_ID in (select distinct Month_ID from Calendar_lookup where Fiscal_Year = 'FY21')
          group by Account_No
          ) a
          full join
          (
          select Account_No, round(sum(Target),2) as TotalTarget from TargetsRawData
          where Month_ID in (select distinct Month_ID from Calendar_lookup where Fiscal_Year = 'FY21')
          group by Account_No 
          ) b
          on a.Account_No = b.Account_No) d
     left join
     account_lookup c
     on d.Account_No = c.New_Account_No
group by New_Account_Name, TotalRevenue, TotalTarget
order by Diff


-- 11. Which opportunity has the highest potential and what are the details?
select * from Opportunities_Data

select Est_Completion_Month_ID, Opportunity_ID, New_Opportunity_Name, Est_Opportunity_Value 
from Opportunities_Data
where Est_Completion_Month_ID in (select distinct Month_ID from Calendar_lookup where Fiscal_Year='FY21')
ORDER BY Est_Opportunity_Value DESC

-- 12. Which account generates the most revenue per marketing spending for this month?
select ISNULL(a.Account_No, b.Account_No) as Account_No, Revenue, Marketing_Spend, ISNULL(1.0*Revenue/Marketing_Spend,0) as RevenuePerMarketing
from 
(
     select Account_No, sum(Revenue) as Revenue from RevenueRawData
     where Month_ID in (select max(Month_ID) from RevenueRawData)
     group by Account_No, Month_ID
) a
FULL JOIN
(
     select Account_No, sum(Marketing_Spend) as Marketing_Spend from MarketingRawData
     where Month_ID in (select max(Month_ID) from RevenueRawData)
     group by Account_No, Month_ID
) b
on a.Account_No=b.Account_No
ORDER BY RevenuePerMarketing desc