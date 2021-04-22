DROP TABLE IF EXISTS cisatracurium_first;
CREATE TABLE cisatracurium_first AS
(
SELECT *
FROM cisatracurium
WHERE first_med = 'true'
);