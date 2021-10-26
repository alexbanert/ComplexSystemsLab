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

SELECT T.Name, ALB.Title, ART.Name FROM Track T JOIN Album ALB ON T.AlbumId = ALB.AlbumId JOIN Artist ART on ART.ArtistId = ALB.ArtistId JOIN PlaylistTrack PT on T.TrackId = PT.TrackId JOIN Playlist P on PT.PlaylistId = P.PlaylistId
WHERE P.Name LIKE '%classic%';