# Modern Databases — SGA 2
## AWS EC2 → Amazon RDS MySQL: Setup, Execution, and Testing Guide

## 1. Architecture and prerequisites

```text
Local Linux computer
    |
    | SSH (TCP 22) / SCP
    v
Amazon EC2 instance (Amazon Linux)
    |
    | MySQL client connection (TCP 3306)
    v
Amazon RDS for MySQL
    |
    +-- MovieDB
         +-- Movie           (5 rows)
         +-- Person          (9 rows)
         +-- MoviePerson     (12 rows)
```

Prerequisites:

- An AWS account with an EC2 instance and an RDS **MySQL** DB instance already created.
- The EC2 SSH private key (`ssh_pair.pem` in this example), stored securely on the local computer.
- The EC2 instance's public DNS or address and its SSH username (here, `ec2-user`).
- The **RDS DB endpoint** (different from the EC2 public DNS), port (normally `3306`), MySQL username, and password.
- Network rules permitting SSH from your own IP address to EC2 and MySQL access from EC2 to RDS. Prefer an RDS security-group rule whose source is the **EC2 security group**, rather than opening port 3306 to the internet.
- `mysql.sql` on the local computer if using the all-in-one approach.


## 2. Connect from the local computer to EC2

Open a **local terminal**, in the folder containing the SSH key:

```bash
chmod 400 ssh_pair.pem
ssh -i "ssh_pair.pem" ec2-user@ec2-3-26-164-209.ap-southeast-2.compute.amazonaws.com
```

The public EC2 DNS above is the address used during this assignment; if the instance has changed, use its current address from the EC2 console. If prompted to trust the host on the first connection, verify the hostname/fingerprint before accepting.

If SSH succeeds, you will see an EC2/Linux shell prompt. Commands in sections 3 and 4 should be run **on EC2**, not on the local computer.

Check where you are and what Linux version is installed:

```bash
pwd
cat /etc/os-release
```

With the `ec2-user` account, the home directory is typically `/home/ec2-user`.

## 3. Install a MySQL-compatible client on EC2

**Amazon Linux 2023 (recommended for the AWS documentation workflow):**

```bash
sudo dnf update -y
sudo dnf install -y mariadb105
mysql --version
```

The `mariadb105` package supplies a MySQL-compatible command-line client for connecting to **RDS MySQL**. It does **not** mean that the assignment's database engine has changed to MariaDB; the database remains MySQL on RDS.


## 4. Connect from EC2 to the RDS MySQL server

On the **EC2 Linux shell**, run:

```bash
mysql -h YOUR_RDS_ENDPOINT -P 3306 -u YOUR_MYSQL_USERNAME -p
```

Replace the placeholders. Enter the password **when prompted**; do not put the password directly in the command or README.

After authentication, you should see a `mysql>` or `MySQL [(none)]>` prompt. Commands from this point onward are **SQL**, not Linux shell commands, unless the guide explicitly says otherwise.

## 5. Create and select the assignment database

Run in the **MySQL prompt**:

```sql
CREATE DATABASE IF NOT EXISTS MovieDB;
USE MovieDB;
SELECT DATABASE() AS current_database;
```

Expected selected database: `MovieDB`.

> `CREATE DATABASE IF NOT EXISTS` protects against a duplicate-database error, **but the table creation and data insertion statements below are not automatically repeatable**. If `MovieDB` already has the assignment tables/data, do not re-run the setup sections. Use the dedicated test procedure in section 10 instead.

## 6. Create the three tables and verify their structure

Run the parent tables first, followed by their relationship table.

### 6.1 Movie table

```sql
CREATE TABLE Movie (
    id INT PRIMARY KEY,
    name VARCHAR(255),
    description TEXT,
    year YEAR,
    rating FLOAT,
    genre VARCHAR(100)
);
DESCRIBE Movie;
```

### 6.2 Person table

```sql
CREATE TABLE Person (
    id INT PRIMARY KEY,
    name VARCHAR(255),
    role ENUM('Actor', 'Actress', 'Director'),
    birth_year YEAR
);
DESCRIBE Person;
```

### 6.3 MoviePerson relationship table

```sql
CREATE TABLE MoviePerson (
    movie_id INT,
    person_id INT,
    FOREIGN KEY (movie_id) REFERENCES Movie(id),
    FOREIGN KEY (person_id) REFERENCES Person(id)
);
DESCRIBE MoviePerson;
SHOW CREATE TABLE MoviePerson;
SHOW TABLES;
```

## 7. Insert the supplied assignment data

Insert into the two parent tables before inserting foreign-key references into `MoviePerson`.

### 7.1 Insert five movies

```sql
INSERT INTO Movie VALUES
(1, 'Inception', 'A mind-bending sci-fi thriller', 2010, 8.8, 'Science Fiction'),
(2, 'The Dark Knight', 'Batman faces the Joker', 2008, 9.0, 'Action'),
(3, 'Interstellar', 'Space exploration drama', 2014, 8.6, 'Science Fiction'),
(4, 'Titanic', 'A love story on a doomed ship', 1997, 7.9, 'Romance'),
(5, 'The Shawshank Redemption', 'A tale of hope in a prison', 1994, 9.3, 'Drama');
SELECT * FROM Movie;
```

### 7.2 Insert nine people

```sql
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
```

### 7.3 Insert twelve movie-person relationships

```sql
INSERT INTO MoviePerson VALUES
(1, 1), (1, 2), (1, 4),
(2, 1), (2, 3),
(3, 1), (3, 4), (3, 9),
(4, 6), (4, 7),
(5, 5), (5, 8);
SELECT * FROM MoviePerson;
```
Expected: `Movie = 5`, `Person = 9`, and `MoviePerson = 12`.

## 8. Run each of the 10 assignment queries

Execute these statements **after** `USE MovieDB;` and after loading the sample data. These are the same queries contained in `mysql.sql`, with descriptions corresponding to the assignment.

### Question 1: Retrieve all movies released after the year 2000.

```sql
SELECT * FROM Movie WHERE year > 2000;
```

**Expected:** 3 movies: Inception, The Dark Knight, Interstellar.

### Question 2: List all directors from the Person table.

```sql
SELECT * FROM Person WHERE role = 'Director';
```

**Expected:** 2 directors: Christopher Nolan and James Cameron.

### Question 3: Find all movies with a rating greater than 8.0.

```sql
SELECT * FROM Movie WHERE rating > 8.0;
```

**Expected:** 4 movies; Titanic (7.9) is excluded.

### Question 4: Count the number of movies in the Movie table.

```sql
SELECT COUNT(*) AS total_movies FROM Movie;
```

**Expected:** One row: `total_movies = 5`.

### Question 5: Find all movies along with their directors' names.

```sql
SELECT m.name AS movie_name, p.name AS director_name FROM Movie m JOIN MoviePerson mp ON m.id = mp.movie_id JOIN Person p ON mp.person_id = p.id WHERE p.role = 'Director';
```

**Expected:** 4 movie-director pairs; *The Shawshank Redemption* has no director association in the supplied dataset.

### Question 6: Count the number of movies for each actor or actress.

```sql
SELECT p.name AS actor_name, COUNT(mp.movie_id) AS movie_count FROM Person p JOIN MoviePerson mp ON p.id = mp.person_id WHERE p.role IN ('Actor', 'Actress')  GROUP BY p.id, p.name;
```

**Expected:** 7 actors/actresses; Anne Hathaway has 2 movies and each other listed performer has 1.

### Question 7: List the top two highest-rated movies.

```sql
SELECT * FROM Movie ORDER BY rating DESC LIMIT 2;
```

**Expected:** 2 movies: The Shawshank Redemption (9.3), then The Dark Knight (9.0).

### Question 8: List actors/actresses born before 1975 and the movies they acted in.

```sql
SELECT p.name AS actor_name, p.birth_year, m.name AS movie_name FROM Person p JOIN MoviePerson mp ON p.id = mp.person_id JOIN Movie m ON mp.movie_id = m.id WHERE p.role IN ('Actor', 'Actress') AND p.birth_year < 1975;
```

**Expected:** 5 rows: Leonardo DiCaprio, Christian Bale, Morgan Freeman, Tim Robbins, and Matthew McConaughey with their movies.

### Question 9: Calculate the average movie ratings grouped by genre.

```sql
SELECT genre, AVG(rating) AS average_rating FROM Movie GROUP BY genre;
```

**Expected:** 4 genre averages: Science Fiction ~8.7, Action ~9.0, Romance ~7.9, Drama ~9.3. Raw FLOAT averages may show extra decimals.

### Question 10: List actors/actresses who appeared in movies directed by Christopher Nolan.

```sql
SELECT DISTINCT p.name AS actor_name FROM Person p JOIN MoviePerson mp ON p.id = mp.person_id JOIN Movie m ON mp.movie_id = m.id JOIN MoviePerson mp2 ON m.id = mp2.movie_id JOIN Person d ON mp2.person_id = d.id WHERE p.role IN ('Actor', 'Actress') AND d.name = 'Christopher Nolan' AND d.role = 'Director';
```

**Expected:** 4 distinct people: Leonardo DiCaprio, Anne Hathaway, Christian Bale, Matthew McConaughey.

> SQL result row ordering is not guaranteed unless `ORDER BY` is specified; comparisons should focus on the returned rows and values, not their arbitrary presentation order.

## 9. Transfer the complete SQL file from the local computer to EC2

If `mysql.sql` is on your **local computer**, open a **local terminal** in the folder containing the file and the `.pem` key:

```bash
scp -i "ssh_pair.pem" ./mysql.sql \
  ec2-user@ec2-3-26-164-209.ap-southeast-2.compute.amazonaws.com:~/
```

**The trailing `:~/` is essential:** it denotes the *remote user's home directory*. Without the colon, an `scp` command may treat the target as a local path.

Verify on the EC2 Linux shell:

```bash
ls -lh /home/ec2-user/mysql.sql
```

Expected file location: `/home/ec2-user/mysql.sql`.

## 10. Safely test the entire SQL script without modifying MovieDB

The `mysql.sql` file creates `MovieDB` and then inserts records. **Do not execute it against the existing populated `MovieDB`.** 


### Option A: Execute from an already-connected MySQL prompt

Connect from EC2 to RDS using the command in section 4, then run:

```sql
SOURCE /home/ec2-user/mysql_test.sql;
```

The MySQL client will execute the script and display statements' outputs. `SOURCE` is a **MySQL client command**, not a standard SQL statement; it reads the file from **EC2**, where the MySQL client is running.


### Confirm test data inside RDS

At the MySQL prompt:

```sql
USE MovieDB_Test;
SELECT DATABASE();
SELECT COUNT(*) AS movies FROM Movie;
SELECT COUNT(*) AS people FROM Person;
SELECT COUNT(*) AS links FROM MoviePerson;
SHOW CREATE TABLE MoviePerson;
```
