-- Create and select the database
CREATE DATABASE IF NOT EXISTS MovieDB;
USE MovieDB;
SELECT DATABASE() AS current_database;

-- Create the Movie table
CREATE TABLE Movie (
    id INT PRIMARY KEY,
    name VARCHAR(255),
    description TEXT,
    year YEAR,
    rating FLOAT,
    genre VARCHAR(100)
);

DESCRIBE Movie;

-- Create the Person table
CREATE TABLE Person (
    id INT PRIMARY KEY,
    name VARCHAR(255),
    role ENUM('Actor', 'Actress', 'Director'),
    birth_year YEAR
);

DESCRIBE Person;

-- Create the MoviePerson relationship table
CREATE TABLE MoviePerson (
    movie_id INT,
    person_id INT,
    FOREIGN KEY (movie_id) REFERENCES Movie(id),
    FOREIGN KEY (person_id) REFERENCES Person(id)
);

DESCRIBE MoviePerson;

SHOW TABLES;

-- Insert the 5 Movie records
INSERT INTO Movie VALUES
(1, 'Inception', 'A mind-bending sci-fi thriller', 2010, 8.8, 'Science Fiction'),
(2, 'The Dark Knight', 'Batman faces the Joker', 2008, 9.0, 'Action'),
(3, 'Interstellar', 'Space exploration drama', 2014, 8.6, 'Science Fiction'),
(4, 'Titanic', 'A love story on a doomed ship', 1997, 7.9, 'Romance'),
(5, 'The Shawshank Redemption', 'A tale of hope in a prison', 1994, 9.3, 'Drama');

SELECT * FROM Movie;

-- Insert the 9 Person records
INSERT INTO Person VALUES
(1, 'Christopher Nolan', 'Director', 1970),
(2, 'Leonardo DiCaprio', 'Actor', 1974),
(3, 'Christian Bale', 'Actor', 1974),
(4, 'Anne Hathaway', 'Actress', 1982),
(5, 'Morgan Freeman', 'Actor', 1937),
(6, 'Kate Winslet', 'Actress', 1975),
(7, 'James Cameron', 'Director', 1954),
(8, 'Tim Robbins', 'Actor', 1958),
(9, 'Matthew McConaughey', 'Actor', 1969);

SELECT * FROM Person;

-- Insert the 12 MoviePerson relationships
INSERT INTO MoviePerson VALUES
(1, 1), (1, 2), (1, 4),
(2, 1), (2, 3),
(3, 1), (3, 4), (3, 9),
(4, 6), (4, 7),
(5, 5), (5, 8);


-- q1: Retrieve all movies released after the year 2000.
SELECT * FROM Movie WHERE year > 2000;

-- q2: List all directors from the Person table.
SELECT * FROM Person WHERE role = 'Director';

-- q3: Find all movies with a rating greater than 8.0.
SELECT * FROM Movie WHERE rating > 8.0;

-- q4: Count the number of movies in the Movie table.
SELECT COUNT(*) AS total_movies FROM Movie;

-- q5: Find all movies along with their directors' names.
SELECT m.name AS movie_name, p.name AS director_name FROM Movie m JOIN MoviePerson mp ON m.id = mp.movie_id JOIN Person p ON mp.person_id = p.id WHERE p.role = 'Director';

-- q6: Count the number of movies for each actor or actress.
SELECT p.name AS actor_name, COUNT(mp.movie_id) AS movie_count FROM Person p JOIN MoviePerson mp ON p.id = mp.person_id WHERE p.role IN ('Actor', 'Actress')  GROUP BY p.id, p.name;

-- q7: List the top two highest-rated movies.
SELECT * FROM Movie ORDER BY rating DESC LIMIT 2;

-- q8: List actors/actresses born before 1975 and the movies they acted in.
SELECT p.name AS actor_name, p.birth_year, m.name AS movie_name FROM Person p JOIN MoviePerson mp ON p.id = mp.person_id JOIN Movie m ON mp.movie_id = m.id WHERE p.role IN ('Actor', 'Actress') AND p.birth_year < 1975;

-- q9: Calculate the average movie ratings grouped by genre.
SELECT genre, AVG(rating) AS average_rating FROM Movie GROUP BY genre;

-- q10: List actors/actresses who appeared in movies directed by Christopher Nolan.
SELECT DISTINCT p.name AS actor_name FROM Person p JOIN MoviePerson mp ON p.id = mp.person_id JOIN Movie m ON mp.movie_id = m.id JOIN MoviePerson mp2 ON m.id = mp2.movie_id JOIN Person d ON mp2.person_id = d.id WHERE p.role IN ('Actor', 'Actress') AND d.name = 'Christopher Nolan' AND d.role = 'Director';