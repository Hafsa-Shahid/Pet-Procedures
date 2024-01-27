-- 1. List the names of all pet owners along with the names of their pets.

SELECT PO.OwnerID , PO.Name , Surname , P.Name as 'Pet Name' , PetID , StreetAddress , Kind , Gender
FROM petowners PO
INNER JOIN pets P                          
ON PO.OwnerID = P.OwnerID;                    

-- 2. List all pets and their owner names, including pets that don't have recorded owners.

SELECT P.Name as 'Pet Name' , PetID , Kind , P.OwnerID , PO.Name , Surname 
FROM pets P
LEFT JOIN petowners PO
ON P.OwnerID = PO.OwnerID;

-- 3. Combine the information of pets and their owners, including those pets without owners and owners without pets.

SELECT P.PetID , P.Name , PO.OwnerID , PO.Name , Kind , Gender , Age , StreetAddress
FROM pets P
JOIN petowners PO          
ON P.OwnerID = PO.OwnerID;

-- 4. Find the names of pets along with their owners' names and the details of the procedures they have undergone.

SELECT P.PetID , P.Name as 'Pet Name' , Kind ,Gender , Age , PO.OwnerID , PO.Name , ProcedureType
FROM pets P
INNER JOIN petowners PO
ON P.OwnerID = PO.OwnerID
INNER JOIN procedureshistory PH
ON P.PetID = PH.PetID;

-- 5. List all pet owners and the number of dogs they own.

SELECT PO.OwnerID  , PO.Name as 'Owner Name' , P.Kind , count(P.Kind) AS 'no. of dogs'
FROM petowners PO
LEFT JOIN pets P
ON PO.OwnerID = P.OwnerID
WHERE Kind = 'Dog'
GROUP BY PO.OwnerID , PO.Name;

-- 6. Identify pets that have not had any procedures.

SELECT P.PetID , Name , Kind , Gender , Age , OwnerID , ProcedureType , ProcedureSubCode
FROM pets P
LEFT JOIN procedureshistory PH
ON P.PetID = PH.PetID
WHERE ProcedureType IS NULL;

-- 7. Find the name of the oldest pet.

SELECT  PetID , Name , Kind , Age 
FROM pets
WHERE Age = (SELECT MAX(Age) FROM pets);

-- 8. List all pets who had procedures that cost more than the average cost of all procedures.

SELECT P.PetID , P.Name , PH.ProcedureType , avg(Price)              
FROM pets P
JOIN procedureshistory PH
ON P.PetID = PH.PetID
JOIN proceduresdetails PD
ON PH.ProcedureType = PD.ProcedureType 
WHERE Price >= (SELECT avg(PD.Price) FROM proceduresdetails)
GROUP BY P.PetID , P.Name , PH.ProcedureType ;

-- 9. Find the details of procedures performed on 'Cuddles'.

SELECT P.PetID , Name , PH.ProcedureType , PD.ProcedureSubCode , Description , Date , Price 
FROM pets P
LEFT JOIN procedureshistory PH
ON P.PetID = pH.PetID
LEFT JOIN proceduresdetails PD
ON PH.ProcedureSubCode = PD.ProcedureSubCode AND PH.ProcedureType = PD.ProcedureType
WHERE Name = 'Cuddles';

-- 10. Create a list of pet owners along with the total cost they have spent on procedures and display only those who have spent above the average spending.

SELECT PO.OwnerID , PO.Name , sum(PD.price) as 'total expense' 
FROM petowners PO
LEFT JOIN pets P
ON PO.OwnerID = P.OwnerID
LEFT JOIN procedureshistory PH
ON P.PetID = PH.PetID
LEFT JOIN proceduresdetails PD
ON PH.ProcedureType = PD.ProcedureType
WHERE (SELECT sum(Price) FROM procedureshistory PH JOIN proceduresdetails PD ) > (SELECT avg(Price) FROM procedureshistory PH JOIN proceduresdetails PD )
GROUP BY OwnerID, Name;

-- 11. List the pets who have undergone a procedure called 'VACCINATIONS'.

SELECT P.PetID , Name , ProcedureType , Date , ProcedureSubCode
FROM pets P
INNER JOIN procedureshistory PH
ON P.PetID = pH.PetID
WHERE ProcedureType = 'VACCINATIONS';

-- 12. Find the owners of pets who have had a procedure called 'EMERGENCY'.

SELECT *
FROM petowners PO
RIGHT JOIN pets P
ON PO.OwnerID = P.OwnerID
RIGHT JOIN procedureshistory PH
ON P.PetID = PH.PetID
RIGHT JOIN proceduresdetails PD
ON PH.ProcedureSubCode = PD.ProcedureSubCode AND PH.ProcedureType = PD.ProcedureType
WHERE Description = 'Emergency';

-- 13. Calculate the total cost spent by each pet owner on procedures.

SELECT PO.OwnerID , PO.Name , sum(PD.price) as 'total expense' 
FROM petowners PO
LEFT JOIN pets P
ON PO.OwnerID = P.OwnerID
LEFT JOIN procedureshistory PH
ON P.PetID = PH.PetID
LEFT JOIN proceduresdetails PD
ON PH.ProcedureType = PD.ProcedureType
GROUP BY OwnerID, Name;

-- 14. Count the number of pets of each kind.

SELECT Kind , count(*)
FROM pets
GROUP BY Kind;

-- 15. Group pets by their kind and gender and count the number of pets in each group.

SELECT Kind , Gender , count(*) AS 'no. of count'
FROM pets
GROUP BY Kind , Gender
ORDER BY Kind , Gender;

-- 16. Show the average age of pets for each kind, but only for kinds that have more than 5 pets.

SELECT Kind , round(avg(Age),0) as 'average age', count(*)          
FROM pets
GROUP BY Kind
HAVING count(*) > 5;

-- 17. Find the types of procedures that have an average cost greater than $50.

SELECT ProcedureType , round(avg(Price) , 2) as 'average price'
FROM proceduresdetails
GROUP BY ProcedureType
HAVING avg(Price) > 50;

-- 18. Classify pets as 'Young', 'Adult', or 'Senior' based on their age. Age less then 3 Young, Age between 3 and 8 Adult, else Senior.

SELECT *,
CASE
    WHEN Age < 3 THEN 'Young'
    WHEN 8 >= Age and Age >= 3 THEN 'Adult'
    WHEN Age > 8 THEN 'Senior'
END as 'Phase of Life'
FROM pets;

-- 19. Calculate the total spending of each pet owner on procedures, labeling them as 'Low Spender' for spending under $100, 'Moderate Spender' for spending between $100 and $500, and 'High Spender' for spending over $500.

SELECT PO.OwnerID , PO.Name , sum(PD.price) as 'total expense' ,
CASE
      WHEN sum(PD.price) < 100 THEN 'Low Spender'
      WHEN sum(PD.price) >= 100 AND sum(PD.price) <= 500 THEN 'Moderate Spender'
      WHEN sum(PD.price) > 500 THEN 'High Spender' 
END as 'Owner Expense Category'
FROM petowners PO
LEFT JOIN pets P
ON PO.OwnerID = P.OwnerID
LEFT JOIN procedureshistory PH
ON P.PetID = PH.PetID
LEFT JOIN proceduresdetails PD
ON PH.ProcedureType = PD.ProcedureType
GROUP BY OwnerID, Name;

-- 20. Show the gender of pets with a custom label ('Boy' for male, 'Girl' for female).

SELECT *,
CASE
    WHEN Gender LIKE  'Male' THEN 'Boy'
    WHEN Gender LIKE  'Female' THEN 'Girl'
    
END as 'Gender Category'
FROM pets;

-- 21. For each pet, display the pet's name, the number of procedures they've had, and a status label: 'Regular' for pets with 1 to 3 procedures, 'Frequent' for 4 to 7 procedures, and 'Super User' for more than 7 procedures.

SELECT PH.PetID , P.Name , COUNT(distinct(ProcedureType)),
CASE 
      WHEN COUNT(distinct(ProcedureType)) >= 1 AND COUNT(distinct(ProcedureType)) <= 3 THEN 'Regular'
      WHEN COUNT(distinct(ProcedureType)) >= 4 AND COUNT(distinct(ProcedureType)) <= 7 THEN 'Frequent'
      WHEN COUNT(distinct(ProcedureType)) > 7  THEN 'Super User'
END as 'Fancy'      
FROM procedureshistory PH 
LEFT JOIN pets P
ON PH.PetID = P.PetID
GROUP BY PetID , P.Name;

-- 22. Rank pets by age within each kind.

SELECT PetID , Kind , Age,                                      
RANK () OVER (ORDER BY Age desc) as 'Seniority Ranking'
FROM pets
GROUP BY Kind , Age , PetID;

-- 23. Assign a dense rank to pets based on their age, regardless of kind.

SELECT PetID , Age, 
DENSE_RANK () OVER (ORDER BY Age desc) as 'Seniority Ranking'
FROM pets
GROUP BY Age , PetID;

-- 24. For each pet, show the name of the next and previous pet in alphabetical order.

SELECT Name, 
LEAD(Name) OVER (ORDER BY Name) AS 'Next Pet',
LAG(Name) OVER (ORDER BY Name) AS 'Previous Pet'
FROM pets;

-- 25. Show the average age of pets, partitioned by their kind.

SELECT PetID , Name , Age , Kind ,           
avg(Age) OVER (PARTITION BY Kind) as 'Average Age'
FROM pets;

-- 26. Create a CTE that lists all pets, then select pets older than 5 years from the CTE.

WITH AllPets AS (SELECT PetID, Name, Age FROM pets)
SELECT PetID, Name, Age
FROM AllPets
WHERE age > 5;
