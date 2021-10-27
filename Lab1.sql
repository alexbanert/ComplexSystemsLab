-- 7
SELECT tra.Name as 'Track name', art.Name, alb.Title
FROM Album alb
         JOIN Artist art ON alb.ArtistId = art.ArtistId
         JOIN Track tra ON tra.AlbumId = alb.AlbumId
where art.Name not like 'Queen';

-- 8 Print out all the audio files (both AAC and MPEG) that last between 275s and 400s

SELECT t.Name, t.Milliseconds
FROM Track t
WHERE t.Milliseconds BETWEEN 275000 AND 400000
  AND MediaTypeId in
      (
          SELECT MediaTypeId FROM MediaType WHERE Name LIKE 'MPEG audio file' OR Name LIKE 'AAC audio file');

-- 9 Select all non-audio tracks and their album titles.

SELECT t.Name
FROM Track t
         JOIN MediaType MT on t.MediaTypeId = MT.MediaTypeId
WHERE MT.Name LIKE 'Protected MPEG-4 video file';

-- 10 Select all tracks from each playlist that contains Classic substring in its name.
-- The resulting schema should contain only track titles, album names, band names
-- and the genre

SELECT T.Name, ALB.Title, ART.Name
FROM Track T
         JOIN Album ALB ON T.AlbumId = ALB.AlbumId
         JOIN Artist ART on ART.ArtistId = ALB.ArtistId
         JOIN PlaylistTrack PT on T.TrackId = PT.TrackId
         JOIN Playlist P on PT.PlaylistId = P.PlaylistId
WHERE P.Name LIKE '%classic%';

# 11. Select all the cities, from which came the clients in the database.
SELECT UNIQUE (City)
FROM Customer;

# 12. Check whether all American cities in the database have a state assigned.
SELECT *
FROM (
         SELECT City, State, Country
         FROM Customer
         UNION
         SELECT City, State, Country
         FROM Employee
     ) as Res
WHERE State IS NULL
  AND Country = 'USA';

# 13. List all the countries that do not have states assigned.
SELECT Country
FROM (
         SELECT State, Country
         FROM Customer
         UNION
         SELECT State, Country
         FROM Employee
     ) as Res
GROUP BY Country, State
HAVING COUNT(Country) = 1
   AND State IS NULL;

# 14. List all the domains of the clients’ e-mails.
SELECT UNIQUE SUBSTRING_INDEX(Email, '@', -1) as Domain
FROM Customer
ORDER BY Domain;

# 15. For each of the domains print out the number of clients using them. Count
# together the companies without distinction on their country suffix.
SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(Email, '@', -1), '.', 1) as Domain, Count(CustomerId) as IdCount
FROM Customer
GROUP BY Domain
ORDER BY IdCount DESC;

# 16. Find country from which clients ordered products with highest joint value.
SELECT Country, SUM(Totals) as Ttl
FROM Customer C
         JOIN
     (SELECT CustomerId, SUM(Total) as Totals
      FROM Invoice
      GROUP BY CustomerId) AS T
     ON C.CustomerId = T.CustomerId
GROUP BY Country
ORDER BY Ttl DESC
LIMIT 1;

# 17. For each country print out the average value of ordered goods.
SELECT Country, AVG(Totals) as Ttl
FROM Customer C
         JOIN
     (SELECT CustomerId, SUM(Total) as Totals
      FROM Invoice
      GROUP BY CustomerId) AS T
     ON C.CustomerId = T.CustomerId
GROUP BY Country;

# 18. Find the album of the highest value. The resulting scheme should contain the
# name of the artist, the title of the album, the number of the tracks and the total
# price.
SELECT ART.Name                                   AS 'Artist name',
       AL.Title                                   AS 'Album title',
       COUNT(DISTINCT T.TrackId)                  AS 'Tracks on album',
       IFNULL(SUM(IL.Quantity * IL.UnitPrice), 0) AS 'Total in sales'
FROM InvoiceLine IL
         RIGHT JOIN Track T on T.TrackId = IL.TrackId
         JOIN Album AL on T.AlbumId = AL.AlbumId
         JOIN Artist ART on AL.ArtistId = ART.ArtistId
GROUP BY AL.AlbumId;

# 19. Find the artist with the second highest number of tracks.
SELECT ART.Name, COUNT(DISTINCT TrackId) as TracksTotal
FROM Artist ART
         JOIN Album A on ART.ArtistId = A.ArtistId
         JOIN Track T on A.AlbumId = T.AlbumId
GROUP BY ART.ArtistId
ORDER BY TracksTotal DESC
LIMIT 1,1;

# 20. Using customer and employee tables, list the employees who are not currently
# responsible for customer service.
SELECT EmployeeId, FirstName, LastName, Title
FROM Employee
WHERE EmployeeId
          NOT IN
      (SELECT SupportRepId FROM Customer);

# 21. List all employees who do not serve any customer from their own city.
SELECT EmployeeId, FirstName, LastName
FROM Employee
WHERE EmployeeId NOT IN (
    SELECT E.EmployeeId
    FROM Employee E
             JOIN Customer C on E.EmployeeId = C.SupportRepId
    WHERE E.City = C.City);

# 22. List all offered products belonging to Sci Fi Fantasy or Science Fiction. The
# schema should include the titles and their price.
SELECT T.Name, T.UnitPrice
FROM Track T
         JOIN Genre G on G.GenreId = T.GenreId
WHERE G.Name IN ('Sci Fi & Fantasy', 'Science Fiction');

# 23. Find out which artist has the most Metal and Heavy Metal songs (combined).
# Display the band name and track count. Order the result by the number of
# tracks in a descending manner.
SELECT ART.ArtistId, ART.Name, COUNT(T.TrackId) AS Cnt
FROM Artist ART
         JOIN Album A on ART.ArtistId = A.ArtistId
         JOIN Track T on A.AlbumId = T.AlbumId
         JOIN Genre G on T.GenreId = G.GenreId
WHERE G.Name IN ('Heavy Metal', 'Metal')
GROUP BY ART.ArtistId
ORDER BY Cnt DESC;

# 24. Find the employee that was the youngest when first hired.
SELECT FirstName, LastName
FROM Employee
WHERE DATEDIFF(HireDate, BirthDate) =
      (
          SELECT MIN(DATEDIFF(HireDate, BirthDate))
          FROM Employee
      );

# 25. Select all episodes of Battlestar Galactica on offer, include all seasons. Order the
# results by the title.
SELECT T.Name
FROM Track T
         JOIN Album A on A.AlbumId = T.AlbumId
WHERE A.Title LIKE '%Battlestar Galactica%'
ORDER BY T.Name;

# 26. Select artist names and album titles in cases where the same title is used by two
# different bands. (Note: If (X, Y, A) is selected, the result should not include
# (Y, X, A)).
SELECT SEL1.Name, SEL2.Name, SEL1.Title
FROM (SELECT AR.ArtistId, AR.Name, AL.Title
      FROM Album AL
               JOIN Artist AR on AR.ArtistId = AL.ArtistId)
         AS SEL1
         JOIN
     (SELECT AR.ArtistId, AR.Name, AL.Title
      FROM Album AL
               JOIN Artist AR on AR.ArtistId = AL.ArtistId)
         AS SEL2
WHERE SEL1.Title = SEL2.Title
  AND SEL1.ArtistId < SEL2.ArtistId;

# 27. Select all the songs by Santana, regardless of who was featuring the record.
SELECT T.Name, AR.Name
FROM Track T
         JOIN Album AL on AL.AlbumId = T.AlbumId
         JOIN Artist AR on AR.ArtistId = AL.ArtistId
WHERE AR.Name LIKE '%Santana%';

# 28. Print out all the records composed by a person named John, ensure that none of
# the records are repeated. Order the results alphabetically in terms of the track
# title.
SELECT DISTINCT T.Name, T.Composer
FROM Track T
WHERE T.Composer LIKE '%John %'
ORDER BY T.Name;

# 29. Sort all the artists in descending order of the average duration of their rock
# song. Do not include artists who have recorded less than 7 for songs in the Rock
# category.

SELECT Name
FROM (
         SELECT ART.Name, AVG(T.Milliseconds) AS Duration
         FROM Artist ART
                  JOIN Album AL on ART.ArtistId = AL.ArtistId
                  JOIN Track T on AL.AlbumId = T.AlbumId
                  JOIN Genre G on T.GenreId = G.GenreId
         WHERE G.Name = 'Rock'
         GROUP BY ART.ArtistId
         HAVING COUNT(ART.ArtistId) > 7
         ORDER BY Duration DESC) AS Res;

# 30. Enter a new customer into the customer table, do not create any invoices for
# them.
INSERT INTO Customer (CustomerId, FirstName, LastName, Company, Address, City, State, Country, PostalCode, Phone, Fax,
                      Email, SupportRepId)
VALUES ((SELECT IFNULL(MAX(C2.CustomerId) + 1, 1) FROM Customer C2), 'Alex', 'Banert', 'Pwr', 'Ulica ulica', 'Wroclaw',
        NULL, 'Poland', '123', '123456789', NULL, 'alex@mail.pl', NULL);

# 31. Add a FavGenre column (as a last one) to the customer table. Set it,
# initially, to NULL for all clients.
ALTER TABLE Customer
    ADD COLUMN FavGenre int(11) AFTER SupportRepId;

# 32. For each customer, set the FavGenre value to genre ID of the genre he bought
# the most tracks of.
UPDATE Customer C1
SET C1.FavGenre=(
    SELECT Res.GenreId
    FROM (
             SELECT C2.CustomerId, G.GenreId, COUNT(T.TrackId) AS Cnt
             FROM Customer C2
                      JOIN Invoice I on C2.CustomerId = I.CustomerId
                      JOIN InvoiceLine IL on I.InvoiceId = IL.InvoiceId
                      JOIN Track T on T.TrackId = IL.TrackId
                      JOIN Genre G on G.GenreId = T.GenreId
             GROUP BY C2.CustomerId, G.GenreId
             ORDER BY Cnt
         ) AS Res
    WHERE C1.CustomerId = Res.CustomerId

    LIMIT 1
);


# 33. Remove the Fax column from the customer table.
ALTER TABLE Customer
    DROP COLUMN Fax;

# 34. Delete from the invoice table all the invoices issued before 2010.
DELETE
FROM InvoiceLine
WHERE InvoiceId IN
      (SELECT InvoiceId FROM Invoice WHERE YEAR(InvoiceDate) < 2010);
DELETE
FROM Invoice
WHERE YEAR(InvoiceDate) < 2010;

# 35. Remove from the database information about customers who are not related to
# any transaction.
DELETE
FROM Customer
WHERE CustomerId NOT IN (
    SELECT UNIQUE CustomerId
    FROM Invoice
);


# 36. Add information about tracks from albums The Unforgiving and Gigaton to the
# track table, update the information in the other tables so that the database is
# consistent (i.e. add information about previously non-existent bands, albums,
# etc., and enter the correct ID for the existing ones). Try to automate this process.
SELECT * FROM Track T JOIN Album A on T.AlbumId = A.AlbumId
WHERE A.Title LIKE '%Gigaton%'

INSERT INTO Album (AlbumId, Title, ArtistId) VALUES
((SELECT IFNULL(MAX(A.AlbumId) + 1, 1) FROM Album A), 'Gigaton', (SELECT ArtistId FROM Artist WHERE Name='Pearl Jam'));
INSERT INTO Track (TrackId, Name, AlbumId, MediaTypeId, GenreId, Composer, Milliseconds, Bytes, UnitPrice) VALUES

SET @genreid = SELECT GenreId FROM Genre WHERE Name = ''
