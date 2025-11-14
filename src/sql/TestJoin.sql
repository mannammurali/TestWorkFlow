WITH MonthlySales AS (
SELECT
CAST(FORMAT(SaleDate, 'YYYY-MM-01') AS DATE) AS SaleMonth,
Region,
ProductID,
SUM(SaleAmount) AS TotalSales
FROM SalesData
GROUP BY 1, 2, 3
),
RankedProducts AS (
SELECT
SaleMonth,
Region,
ProductID,
TotalSales,
RANK() OVER (PARTITION BY SaleMonth, Region ORDER BY TotalSales DESC) AS ProductRank
FROM MonthlySales
),

  
PreviousMonthSales AS (
SELECT
SaleMonth,
Region,
ProductID,
TotalSales AS CurrentMonthSales,
LAG(TotalSales, 1, 0) OVER (PARTITION BY Region, ProductID ORDER BY SaleMonth) AS PreviousMonthSales
FROM MonthlySales
)
SELECT rp.SaleMonth,        rp.Region,                   rp.ProductID,
rp.TotalSales,
rp.ProductRank,
(pms.CurrentMonthSales - pms.PreviousMonthSales) AS SalesDifferenceFromPreviousMonth
FROM RankedProducts rp
JOIN PreviousMonthSales pms
ON rp.SaleMonth = pms.SaleMonth
AND rp.Region = pms.Region
AND rp.ProductID = pms.ProductID
WHERE rp.ProductRank <= 5
ORDER BY rp.SaleMonth DESC, rp.Region, rp.ProductRank;
