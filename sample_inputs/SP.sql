-- 1-5: INNER JOINS
CREATE PROCEDURE GetOrdersWithProducts
AS
BEGIN
    SELECT Orders.OrderID, Products.ProductName
    FROM Orders
    INNER JOIN OrderDetails ON Orders.OrderID = OrderDetails.OrderID
    INNER JOIN Products ON OrderDetails.ProductID = Products.ProductID;
END;

CREATE PROCEDURE GetEmployeesWithDepartments
AS
BEGIN
    SELECT Employees.EmployeeID, Employees.EmployeeName, Departments.DepartmentName
    FROM Employees
    INNER JOIN Departments ON Employees.DepartmentID = Departments.DepartmentID;
END;

CREATE PROCEDURE GetCustomersWithOrders
AS
BEGIN
    SELECT Customers.CustomerID, Customers.CustomerName, COUNT(Orders.OrderID) AS OrderCount
    FROM Customers
    INNER JOIN Orders ON Customers.CustomerID = Orders.CustomerID
    GROUP BY Customers.CustomerID, Customers.CustomerName;
END;

CREATE PROCEDURE GetManagersWithTeamMembers
AS
BEGIN
    SELECT Managers.EmployeeID AS ManagerID, Managers.EmployeeName AS ManagerName, Employees.EmployeeID, Employees.EmployeeName
    FROM Employees Managers
    INNER JOIN Employees ON Managers.EmployeeID = Employees.ManagerID;
END;

CREATE PROCEDURE GetCategoriesWithProducts
AS
BEGIN
    SELECT Categories.CategoryID, Categories.CategoryName, Products.ProductName
    FROM Categories
    INNER JOIN Products ON Categories.CategoryID = Products.CategoryID;
END;

-- 6-10: LEFT JOINS
CREATE PROCEDURE GetProductsAndSuppliers
AS
BEGIN
    SELECT Products.ProductID, Products.ProductName, Suppliers.SupplierName
    FROM Products
    LEFT JOIN Suppliers ON Products.SupplierID = Suppliers.SupplierID;
END;

CREATE PROCEDURE GetEmployeesWithoutDepartment
AS
BEGIN
    SELECT Employees.EmployeeID, Employees.EmployeeName
    FROM Employees
    LEFT JOIN Departments ON Employees.DepartmentID = Departments.DepartmentID
    WHERE Departments.DepartmentID IS NULL;
END;

CREATE PROCEDURE GetCustomersWithOptionalOrders
AS
BEGIN
    SELECT Customers.CustomerID, Customers.CustomerName, Orders.OrderID
    FROM Customers
    LEFT JOIN Orders ON Customers.CustomerID = Orders.CustomerID;
END;

CREATE PROCEDURE GetManagersWithOptionalTeamMembers
AS
BEGIN
    SELECT Managers.EmployeeID AS ManagerID, Managers.EmployeeName AS ManagerName, Employees.EmployeeID, Employees.EmployeeName
    FROM Employees Managers
    LEFT JOIN Employees ON Managers.EmployeeID = Employees.ManagerID;
END;

CREATE PROCEDURE GetCategoriesWithOptionalProducts
AS
BEGIN
    SELECT Categories.CategoryID, Categories.CategoryName, Products.ProductName
    FROM Categories
    LEFT JOIN Products ON Categories.CategoryID = Products.CategoryID;
END;

-- 11-15: RIGHT JOINS
CREATE PROCEDURE GetProductsAndSuppliersRightJoin
AS
BEGIN
    SELECT Products.ProductID, Products.ProductName, Suppliers.SupplierName
    FROM Products
    RIGHT JOIN Suppliers ON Products.SupplierID = Suppliers.SupplierID;
END;

CREATE PROCEDURE GetEmployeesWithoutDepartmentRightJoin
AS
BEGIN
    SELECT Employees.EmployeeID, Employees.EmployeeName
    FROM Employees
    RIGHT JOIN Departments ON Employees.DepartmentID = Departments.DepartmentID
    WHERE Employees.DepartmentID IS NULL;
END;

CREATE PROCEDURE GetCustomersWithOptionalOrdersRightJoin
AS
BEGIN
    SELECT Customers.CustomerID, Customers.CustomerName, Orders.OrderID
    FROM Customers
    RIGHT JOIN Orders ON Customers.CustomerID = Orders.CustomerID;
END;

CREATE PROCEDURE GetManagersWithOptionalTeamMembersRightJoin
AS
BEGIN
    SELECT Managers.EmployeeID AS ManagerID, Managers.EmployeeName AS ManagerName, Employees.EmployeeID, Employees.EmployeeName
    FROM Employees Managers
    RIGHT JOIN Employees ON Managers.EmployeeID = Employees.ManagerID;
END;

CREATE PROCEDURE GetCategoriesWithOptionalProductsRightJoin
AS
BEGIN
    SELECT Categories.CategoryID, Categories.CategoryName, Products.ProductName
    FROM Categories
    RIGHT JOIN Products ON Categories.CategoryID = Products.CategoryID;
END;

-- 16-20: FULL OUTER JOINS
CREATE PROCEDURE GetProductsAndSuppliersFullOuterJoin
AS
BEGIN
    SELECT Products.ProductID, Products.ProductName, Suppliers.SupplierName
    FROM Products
    FULL OUTER JOIN Suppliers ON Products.SupplierID = Suppliers.SupplierID;
END;

CREATE PROCEDURE GetEmployeesWithoutDepartmentFullOuterJoin
AS
BEGIN
    SELECT Employees.EmployeeID, Employees.EmployeeName
    FROM Employees
    FULL OUTER JOIN Departments ON Employees.DepartmentID = Departments.DepartmentID
    WHERE Employees.DepartmentID IS NULL OR Departments.DepartmentID IS NULL;
END;

CREATE PROCEDURE GetCustomersWithOptionalOrdersFullOuterJoin
AS
BEGIN
    SELECT Customers.CustomerID, Customers.CustomerName, Orders.OrderID
    FROM Customers
    FULL OUTER JOIN Orders ON Customers.CustomerID = Orders.CustomerID;
END;

CREATE PROCEDURE GetManagersWithOptionalTeamMembersFullOuterJoin
AS
BEGIN
    SELECT Managers.EmployeeID AS ManagerID, Managers.EmployeeName AS ManagerName, Employees.EmployeeID, Employees.EmployeeName
    FROM Employees Managers
    FULL OUTER JOIN Employees ON Managers.EmployeeID = Employees.ManagerID;
END;

CREATE PROCEDURE GetCategoriesWithOptionalProductsFullOuterJoin
AS
BEGIN
    SELECT Categories.CategoryID, Categories.CategoryName, Products.ProductName
    FROM Categories
    FULL OUTER JOIN Products ON Categories.CategoryID = Products.CategoryID;
END;

-- 21-25: CROSS JOINS
CREATE PROCEDURE GetProductsAndCategoriesCrossJoin
AS
BEGIN
    SELECT Products.ProductID, Products.ProductName, Categories.CategoryID, Categories.CategoryName
    FROM Products
    CROSS JOIN Categories;
END;

CREATE PROCEDURE GetEmployeesAndDepartmentsCrossJoin
AS
BEGIN
    SELECT Employees.EmployeeID, Employees.EmployeeName, Departments.DepartmentID, Departments.DepartmentName
    FROM Employees
    CROSS JOIN Departments;
END;

CREATE PROCEDURE GetAllOrdersWithOrderDetailsCrossJoin
AS
BEGIN
    SELECT Orders.OrderID, OrderDetails.ProductID, OrderDetails.Quantity
    FROM Orders
    CROSS JOIN OrderDetails;
END;

CREATE PROCEDURE GetAllCustomersAndOrdersCrossJoin
AS
BEGIN
    SELECT Customers.CustomerID, Customers.CustomerName, Orders.OrderID
    FROM Customers
    CROSS JOIN Orders;
END;

CREATE PROCEDURE GetAllManagersAndTeamMembersCrossJoin
AS
BEGIN
    SELECT Managers.EmployeeID AS ManagerID, Managers.EmployeeName AS ManagerName, Employees.EmployeeID, Employees.EmployeeName
    FROM Employees Managers
    CROSS JOIN Employees;
END;

-- 26-30: SELF JOINS AND COMPLEX JOINS
CREATE PROCEDURE GetEmployeeSubordinates
AS
BEGIN
    WITH EmployeeHierarchy AS (
        SELECT E.EmployeeID, E.EmployeeName, M.EmployeeID AS ManagerID, M.EmployeeName AS ManagerName
        FROM Employees E
        LEFT JOIN Employees M ON E.ManagerID = M.EmployeeID
    )
    SELECT *
    FROM EmployeeHierarchy;
END;

CREATE PROCEDURE GetHighValueCustomersWithOrders
AS
BEGIN
    SELECT Customers.CustomerID, Customers.CustomerName, Orders.OrderID
    FROM Customers
    INNER JOIN Orders ON Customers.CustomerID = Orders.CustomerID
    WHERE Orders.TotalAmount > 1000;
END;

CREATE PROCEDURE GetProductsInLowStock
AS
BEGIN
    SELECT Products.ProductID, Products.ProductName, Products.StockQuantity
    FROM Products
    INNER JOIN Suppliers ON Products.SupplierID = Suppliers.SupplierID
    WHERE Products.StockQuantity < Suppliers.MinimumStockLevel;
END;

CREATE PROCEDURE GetEmployeeSalesPerformance
AS
BEGIN
    SELECT Employees.EmployeeID, Employees.EmployeeName, SUM(Orders.TotalAmount) AS TotalSales
    FROM Employees
    INNER JOIN Orders ON Employees.EmployeeID = Orders.EmployeeID
    GROUP BY Employees.EmployeeID, Employees.EmployeeName;
END;

CREATE PROCEDURE GetCustomersWithMultipleOrders
AS
BEGIN
    SELECT Customers.CustomerID, Customers.CustomerName, COUNT(Orders.OrderID) AS OrderCount
    FROM Customers
    INNER JOIN Orders ON Customers.CustomerID = Orders.CustomerID
    GROUP BY Customers.CustomerID, Customers.CustomerName
    HAVING COUNT(Orders.OrderID) > 1;
END;

CREATE PROCEDURE GetSupplierPurchaseOrders
@SupplierID INT
AS
BEGIN
    SELECT PO.*, P.Name AS ProductName, POD.OrderQuantity, POD.UnitPrice
    FROM Purchasing.PurchaseOrderHeader PO
    JOIN Purchasing.PurchaseOrderDetail POD ON PO.PurchaseOrderID = POD.PurchaseOrderID
    JOIN Production.Product P ON POD.ProductID = P.ProductID
    WHERE PO.VendorID = @SupplierID;
END

CREATE PROCEDURE GetProductSalesByCategory
@CategoryID INT
AS
BEGIN
    SELECT P.ProductID, P.Name AS ProductName, PS.SalesAmount, PS.SalesQuantity
    FROM Production.Product P
    JOIN Sales.ProductSales PS ON P.ProductID = PS.ProductID
    WHERE P.CategoryID = @CategoryID;
END

CREATE PROCEDURE GetEmployeePerformanceRatings
@EmployeeID INT
AS
BEGIN
    SELECT ER.*, R.ReviewerName
    FROM HumanResources.EmployeeReview ER
    JOIN HumanResources.Employee E ON ER.BusinessEntityID = E.BusinessEntityID
    JOIN HumanResources.Employee R ON ER.ReviewerID = R.BusinessEntityID
    WHERE E.BusinessEntityID = @EmployeeID;
END

CREATE PROCEDURE GetProductInventoryDetails
@ProductID INT
AS
BEGIN
    SELECT I.*, S.SupplierName
    FROM Production.ProductInventory I
    JOIN Purchasing.ProductVendor PV ON I.ProductID = PV.ProductID
    JOIN Purchasing.Vendor S ON PV.BusinessEntityID = S.BusinessEntityID
    WHERE I.ProductID = @ProductID;
END

CREATE PROCEDURE GetEmployeeProjectAssignments
@EmployeeID INT
AS
BEGIN
    SELECT E.FirstName + ' ' + E.LastName AS EmployeeName, P.ProjectName, PA.StartDate, PA.EndDate
    FROM HumanResources.Employee E
    JOIN HumanResources.EmployeeProject PA ON E.BusinessEntityID = PA.BusinessEntityID
    JOIN ProjectManagement.Project P ON PA.ProjectID = P.ProjectID;
END

CREATE PROCEDURE GetCustomerOrders
@CustomerID INT
AS
BEGIN
    SELECT O.*, P.Name AS ProductName, S.ShipperName
    FROM Sales.SalesOrderHeader O
    JOIN Sales.SalesOrderDetail OD ON O.SalesOrderID = OD.SalesOrderID
    JOIN Production.Product P ON OD.ProductID = P.ProductID
    LEFT JOIN Purchasing.Shipper S ON O.ShipperID = S.ShipperID
    WHERE O.CustomerID = @CustomerID;
END

CREATE PROCEDURE GetEmployeeTrainingHistory
@EmployeeID INT
AS
BEGIN
    SELECT E.*, T.TrainingName, I.FirstName + ' ' + I.LastName AS InstructorName
    FROM HumanResources.Employee E
    JOIN HumanResources.EmployeeTraining ET ON E.BusinessEntityID = ET.BusinessEntityID
    JOIN HumanResources.Training T ON ET.TrainingID = T.TrainingID
    JOIN HumanResources.Instructor I ON T.InstructorID = I.InstructorID;
END

CREATE PROCEDURE GetEmployeeSalesPerformance
@EmployeeID INT
AS
BEGIN
    SELECT S.*, E.FirstName + ' ' + E.LastName AS EmployeeName, P.Name AS ProductName, C.FirstName + ' ' + C.LastName AS CustomerName
    FROM Sales.SalesOrderHeader S
    JOIN HumanResources.Employee E ON S.SalesPersonID = E.BusinessEntityID
    JOIN Sales.SalesOrderDetail SD ON S.SalesOrderID = SD.SalesOrderID
    JOIN Production.Product P ON SD.ProductID = P.ProductID
    JOIN Sales.Customer C ON S.CustomerID = C.CustomerID
    WHERE E.BusinessEntityID = @EmployeeID;
END

CREATE PROCEDURE GetVendorDetails
@VendorID INT
AS
BEGIN
    SELECT V.*, VC.FirstName + ' ' + VC.LastName AS ContactName, PO.*
    FROM Purchasing.Vendor V
    JOIN Purchasing.VendorContact VC ON V.BusinessEntityID = VC.BusinessEntityID
    LEFT JOIN Purchasing.PurchaseOrderHeader PO ON V.VendorID = PO.VendorID
    WHERE V.VendorID = @VendorID;
END

CREATE PROCEDURE GetProductSales
AS
BEGIN
    SELECT S.*, P.Name AS ProductName, PC.Name AS CategoryName, PSC.Name AS SubcategoryName
    FROM Sales.SalesOrderDetail S
    JOIN Production.Product P ON S.ProductID = P.ProductID
    JOIN Production.ProductSubcategory PSC ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
    JOIN Production.ProductCategory PC ON PSC.ProductCategoryID = PC.ProductCategoryID;
END

CREATE PROCEDURE GetEmployeeDetails
@EmployeeID INT
AS
BEGIN
    SELECT E.*, D.Name AS DepartmentName, M.FirstName + ' ' + M.LastName AS ManagerName
    FROM HumanResources.Employee E
    JOIN HumanResources.EmployeeDepartmentHistory EDH ON E.BusinessEntityID = EDH.BusinessEntityID
    JOIN HumanResources.Department D ON EDH.DepartmentID = D.DepartmentID
    LEFT JOIN HumanResources.EmployeeManagerHistory EMH ON E.BusinessEntityID = EMH.BusinessEntityID AND EMH.EndDate IS NULL
    LEFT JOIN HumanResources.Employee M ON EMH.ManagerID = M.BusinessEntityID
    WHERE E.BusinessEntityID = @EmployeeID;
END

CREATE PROCEDURE InsertJobCandidate
@BusinessEntityID INT,
@Resume XML
AS
BEGIN
    INSERT INTO HumanResources.JobCandidate (BusinessEntityID, Resume)
    VALUES (@BusinessEntityID, @Resume);
END

CREATE PROCEDURE GetJobCandidates
AS
BEGIN
    SELECT *
    FROM HumanResources.JobCandidate;
END

CREATE PROCEDURE UpdateEmployeeInfo
@EmployeeID INT,
@JobTitle NVARCHAR(50),
@SalariedFlag INT,
@VacationHours SMALLINT,
@SickLeaveHours SMALLINT,
@CurrentFlag INT
AS
BEGIN
    UPDATE HumanResources.Employee
    SET JobTitle = @JobTitle,
        SalariedFlag = @SalariedFlag,
        VacationHours = @VacationHours,
        SickLeaveHours = @SickLeaveHours,
        CurrentFlag = @CurrentFlag
    WHERE BusinessEntityID = @EmployeeID;
END

CREATE PROCEDURE InsertEmployee
@NationalIDNumber NVARCHAR(15),
@LoginID NVARCHAR(256),
@JobTitle NVARCHAR(50),
@BirthDate DATE,
@MaritalStatus NCHAR(1),
@Gender NCHAR(1),
@HireDate DATE,
@SalariedFlag INT,
@VacationHours SMALLINT,
@SickLeaveHours SMALLINT,
@CurrentFlag INT
AS
BEGIN
    INSERT INTO HumanResources.Employee (NationalIDNumber, LoginID, JobTitle, BirthDate, MaritalStatus, Gender, HireDate, SalariedFlag, VacationHours, SickLeaveHours, CurrentFlag)
    VALUES (@NationalIDNumber, @LoginID, @JobTitle, @BirthDate, @MaritalStatus, @Gender, @HireDate, @SalariedFlag, @VacationHours, @SickLeaveHours, @CurrentFlag);
END

CREATE PROCEDURE GetDepartmentEmployees
@DepartmentID SMALLINT
AS
BEGIN
    SELECT E.*
    FROM HumanResources.Employee E
    JOIN HumanResources.EmployeeDepartmentHistory EDH ON E.BusinessEntityID = EDH.BusinessEntityID
    WHERE EDH.DepartmentID = @DepartmentID AND EDH.EndDate IS NULL;
END

CREATE PROCEDURE GetEmployeeInfo
@EmployeeID INT
AS
BEGIN
    SELECT *
    FROM HumanResources.Employee
    WHERE BusinessEntityID = @EmployeeID;
END

