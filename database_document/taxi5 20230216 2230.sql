﻿--
-- Script was generated by Devart dbForge Studio 2019 for MySQL, Version 8.1.22.0
-- Product home page: http://www.devart.com/dbforge/mysql/studio
-- Script date 2023.02.16. 22:30:01
-- Server version: 5.5.5-10.4.24-MariaDB
-- Client version: 4.1
--

-- 
-- Disable foreign keys
-- 
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;

-- 
-- Set SQL mode
-- 
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- 
-- Set character set the client will use to send SQL statements to the server
--
SET NAMES 'utf8';

DROP DATABASE IF EXISTS taxi5;

CREATE DATABASE IF NOT EXISTS taxi5
	CHARACTER SET utf8
	COLLATE utf8_hungarian_ci;

--
-- Set default database
--
USE taxi5;

DELIMITER $$

--
-- Create function `randomInteger`
--
CREATE DEFINER = 'root'@'localhost'
FUNCTION IF NOT EXISTS randomInteger(min int, max int)
  RETURNS int(11)
BEGIN

RETURN FLOOR(min + RAND()*(max-min+1));
END
$$

--
-- Create function `randomLicensPlate`
--
CREATE DEFINER = 'root'@'localhost'
FUNCTION IF NOT EXISTS randomLicensPlate(carName varchar(255))
  RETURNS varchar(255) CHARSET utf8 COLLATE utf8_hungarian_ci
BEGIN
set @word = concat(left(carName,1),left(carName,1),left(carName,1));
set @number = randomInteger(100,999);
set @rsz = concat(@word, '-', @number);

RETURN @rsz;
END
$$

--
-- Create function `randomCar`
--
CREATE DEFINER = 'root'@'localhost'
FUNCTION IF NOT EXISTS randomCar()
  RETURNS varchar(255) CHARSET utf8 COLLATE utf8_hungarian_ci
BEGIN

RETURN ELT(randomInteger(1,5),'Mercedesz','Fiat','BMW','Volvo','Toyota');
END
$$

DELIMITER ;

--
-- Create table `users`
--
CREATE TABLE IF NOT EXISTS users (
  id INT(11) NOT NULL AUTO_INCREMENT,
  firstName VARCHAR(50) DEFAULT NULL,
  lastName VARCHAR(50) DEFAULT NULL,
  gender VARCHAR(10) DEFAULT NULL,
  userName VARCHAR(50) DEFAULT NULL,
  email VARCHAR(255) DEFAULT NULL,
  password VARCHAR(100) DEFAULT NULL,
  number INT(11) DEFAULT NULL,
  PRIMARY KEY (id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 14,
AVG_ROW_LENGTH = 5461,
CHARACTER SET utf8,
COLLATE utf8_hungarian_ci;

--
-- Create index `UK_users_email` on table `users`
--
ALTER TABLE users 
  ADD UNIQUE INDEX UK_users_email(email);

--
-- Create index `UK_users_userName` on table `users`
--
ALTER TABLE users 
  ADD UNIQUE INDEX UK_users_userName(userName);

--
-- Create table `cars`
--
CREATE TABLE IF NOT EXISTS cars (
  id INT(11) NOT NULL AUTO_INCREMENT,
  name VARCHAR(50) NOT NULL,
  licenceNumber VARCHAR(255) DEFAULT NULL,
  hourlyRate INT(11) DEFAULT NULL,
  PRIMARY KEY (id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 604,
AVG_ROW_LENGTH = 5461,
CHARACTER SET utf8,
COLLATE utf8_hungarian_ci;

--
-- Create table `trips`
--
CREATE TABLE IF NOT EXISTS trips (
  id INT(11) NOT NULL AUTO_INCREMENT,
  numberOfMinits INT(11) DEFAULT NULL,
  date DATETIME DEFAULT NULL,
  carId INT(11) DEFAULT NULL,
  PRIMARY KEY (id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 3033,
AVG_ROW_LENGTH = 2048,
CHARACTER SET utf8,
COLLATE utf8_hungarian_ci;

--
-- Create foreign key
--
ALTER TABLE trips 
  ADD CONSTRAINT FK_trips_cars_id FOREIGN KEY (carId)
    REFERENCES cars(id) ON DELETE CASCADE;

DELIMITER $$

--
-- Create procedure `tesztAdatgeneratorStaikus`
--
CREATE DEFINER = 'root'@'localhost'
PROCEDURE tesztAdatgeneratorStaikus()
BEGIN

DELETE
  FROM trips;
DELETE
  FROM cars;
DELETE
  FROM users;


INSERT cars (id, name, licenceNumber, hourlyRate)
  VALUES (1, 'Mercedes', 'MM-111', 2500), (2, 'BMW', 'BB-111', 2700), (3, 'Fiat', 'FF-111', 2200);

INSERT trips (numberOfMinits, date, carId)
  VALUES (25, '2022.11.12 12:22:00', 1), (15, '2022.11.12 13:30:00', 1), (35, '2022.11.12 15:30:00', 1),
  (22, '2022.11.12 12:12:00', 2), (32, '2022.11.12 12:50:00', 2),
  (33, '2022.11.12 12:22:00', 3), (12, '2022.11.12 13:45:00', 3), (45, '2022.11.12 15:22:00', 3);

INSERT users (id, email, password)
  VALUES (1, 'geza@gmail.com', 'gezajelszo'), (2, 'jozsi@gmail.com', 'jozsijelszo'), (3, 'feri@gmail.com', 'ferijelszo');

SELECT
  *
FROM cars;
SELECT
  *
FROM trips;
SELECT
  *
FROM users;

END
$$

--
-- Create procedure `tesztAdatgeneratorDinamikus`
--
CREATE DEFINER = 'root'@'localhost'
PROCEDURE tesztAdatgeneratorDinamikus(carCount int, dateValue varchar(255), tripCountMin int, tripCountMax int)
BEGIN

DELETE
  FROM trips;
DELETE
  FROM cars;
DELETE
  FROM users;
set @a = 1;

simple_loop: LOOP         
    
    #véletlen autó
    set @car = randomCar();

INSERT cars (id, name, licenceNumber, hourlyRate)
  VALUES (@a, @car, randomLicensPlate(@car), randomInteger(2000, 3000));

    #trips-ek
    set @t = 1;
    set @deltaMinits = 0;
    set @tripsCount =  randomInteger(tripCountMin, tripCountMax);
    trips_loop: LOOP 
       
       set @numberOfMinits =  randomInteger(15, 60);
 #eddig tart egy fuvar
       set @pauseMinits = randomInteger(0, 60);
 #várakozási idő a következő fuvarig
       set @deltaMinits =  @deltaMinits + @numberOfMinits + @pauseMinits;
#TIMESTAMPADD(MINUTE, @deltaMInits), dateValue)

#trips készítése

INSERT trips (numberOfMinits, date, carId)
  VALUES (@numberOfMinits, TIMESTAMPADD(MINUTE, @deltaMinits, dateValue), @a);

       SET @t=@t+1;
       IF @t>@tripsCount THEN
          LEAVE trips_loop;
       END IF;
    END LOOP trips_loop;


   SET @a=@a+1;
   IF @a>carCount THEN
      LEAVE simple_loop;
   END IF;
END LOOP simple_loop;

# users generálás
INSERT users (id, email, password)
  VALUES (1, 'geza@gmail.com', 'gezajelszo'), (2, 'jozsi@gmail.com', 'jozsijelszo'), (3, 'feri@gmail.com', 'ferijelszo');

SELECT
  *
FROM cars;
SELECT
  *
FROM trips;
SELECT
  *
FROM users;

END
$$

DELIMITER ;

--
-- Create table `registration`
--
CREATE TABLE IF NOT EXISTS registration (
  id INT(11) NOT NULL AUTO_INCREMENT,
  firstName VARCHAR(255) DEFAULT NULL,
  lastName VARCHAR(255) DEFAULT NULL,
  gender VARCHAR(255) DEFAULT NULL,
  email VARCHAR(50) DEFAULT NULL,
  password VARCHAR(255) DEFAULT NULL,
  number INT(11) DEFAULT NULL,
  PRIMARY KEY (id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 6,
AVG_ROW_LENGTH = 3276,
CHARACTER SET utf8,
COLLATE utf8_hungarian_ci;

-- 
-- Dumping data for table cars
--
INSERT INTO cars VALUES
(1, 'Toyota', 'TTT-767', 2807),
(2, 'Fiat', 'FFF-878', 2133),
(3, 'Fiat', 'FFF-441', 2026),
(4, 'Volvo', 'VVV-472', 2139),
(5, 'Toyota', 'TTT-526', 2532),
(6, 'Toyota', 'TTT-862', 2441),
(7, 'Toyota', 'TTT-853', 2268),
(8, 'Fiat', 'FFF-297', 2130),
(9, 'Mercedesz', 'MMM-349', 2242),
(10, 'Toyota3', 'TTT-767', 2807),
(598, 'Mercedes', 'MM-111', 2500),
(599, 'Toyota2', 'TTT-767', 2807),
(600, 'Toyota2', 'TTT-767', 2807),
(601, 'Toyota2 <scrip>alert(''betörtem'')</sript>', 'TTT-767', 2807),
(602, 'Mercedes', 'MM-111', 2500),
(603, 'X Mercedes ', 'MM-111 ', 2500);

-- 
-- Dumping data for table users
--
INSERT INTO users VALUES
(11, 'Béla', 'Fehér', 'férfi', 'bela', 'feher.bela@gmail.com', '$2b$10$o2d1sKE9k8XQLwq82UyNDePXVhL/p06k72bKtoA8o0lf4ejCA2yLa', 33333333),
(13, 'Géza', 'Fehér', 'férfi', 'geza', 'feher.geza@gmail.com', '$2b$10$OcubaoAyB7zgW4g0Fwoc.eJHHEUI8CKOHe39FzSntgIS1z/Q54UvS', 33333333);

-- 
-- Dumping data for table trips
--
INSERT INTO trips VALUES
(2984, 32, '2022-11-12 15:05:00', 1),
(2985, 24, '2022-11-12 16:17:00', 1),
(2986, 30, '2022-11-12 17:06:00', 1),
(2987, 42, '2022-11-12 17:50:00', 1),
(2988, 58, '2022-11-12 13:32:00', 2),
(2989, 58, '2022-11-12 14:31:00', 2),
(2990, 56, '2022-11-12 13:27:00', 3),
(2991, 54, '2022-11-12 15:08:00', 3),
(2992, 28, '2022-11-12 15:46:00', 3),
(2993, 59, '2022-11-12 17:06:00', 3),
(2994, 52, '2022-11-12 18:02:00', 3),
(2995, 56, '2022-11-12 19:14:00', 3),
(2996, 54, '2022-11-12 13:48:00', 4),
(2997, 57, '2022-11-12 15:41:00', 4),
(2998, 53, '2022-11-12 16:59:00', 4),
(2999, 42, '2022-11-12 18:26:00', 4),
(3000, 42, '2022-11-12 12:57:00', 5),
(3001, 36, '2022-11-12 14:11:00', 5),
(3002, 46, '2022-11-12 15:33:00', 5),
(3003, 60, '2022-11-12 14:00:00', 6),
(3004, 59, '2022-11-12 15:53:00', 6),
(3005, 38, '2022-11-12 17:28:00', 6),
(3006, 20, '2022-11-12 18:37:00', 6),
(3007, 46, '2022-11-12 19:23:00', 6),
(3008, 30, '2022-11-12 12:43:00', 7),
(3009, 18, '2022-11-12 13:44:00', 7),
(3010, 29, '2022-11-12 14:38:00', 7),
(3011, 23, '2022-11-12 15:42:00', 7),
(3012, 51, '2022-11-12 17:33:00', 7),
(3013, 40, '2022-11-12 19:01:00', 7),
(3014, 41, '2022-11-12 13:35:00', 8),
(3015, 49, '2022-11-12 14:29:00', 8),
(3016, 22, '2022-11-12 15:23:00', 8),
(3017, 23, '2022-11-12 16:05:00', 8),
(3018, 16, '2022-11-12 16:35:00', 8),
(3019, 18, '2022-11-12 17:32:00', 8),
(3020, 23, '2022-11-12 13:09:00', 9),
(3021, 28, '2022-11-12 13:49:00', 9),
(3022, 18, '2022-11-12 14:57:00', 9),
(3023, 38, '2022-11-12 13:25:00', 10),
(3024, 30, '2022-11-12 14:16:00', 10),
(3025, 50, '2022-11-12 15:52:00', 10),
(3026, 40, '2022-11-12 16:58:00', 10),
(3027, 39, '2022-11-12 18:00:00', 10),
(3028, 27, '2022-11-12 18:41:00', 10),
(3029, 32, '2022-11-12 12:05:00', 1),
(3030, 25, '2022-11-12 12:22:00', 1),
(3032, 56, '2022-10-13 01:36:00', 3);

-- 
-- Dumping data for table registration
--
INSERT INTO registration VALUES
(1, 'Béla', 'Fehér', 'férfi', 'feher.bela@gmail.com', '$2b$10$NlhIzssHRhxASN4dGLUlHOpg6EdT64agu30uBC2jxTu2qBYYGnBeO', 33333333),
(2, 'Béla', 'Fehér', 'férfi', 'feher.bela@gmail.com', '$2b$10$9NLns2/pmz05FtFdMx5OReq6cDUMqH7roxwQT7yOK4fn30ZMtL3iG', 33333333),
(3, 'Béla', 'Fehér', 'férfi', 'feher.bela@gmail.com', '$2b$10$jcWC2PcHcHJx89C3ocpaieVvBG8ibfM6wqwiwnrqiV4pP.OJJFqUG', 33333333),
(4, 'Béla', 'Fehér', 'férfi', 'feher.bela@gmail.com', '$2b$10$CImzr8okYeq7Y.guMbZ93uOZ9O7pBb7pNn25MuieOvVwSAZJ.6fiW', 33333333),
(5, 'Béla', 'Fehér', 'férfi', 'feher.bela@gmail.com', '$2b$10$8cM4AsB17NTlJ0tN7VCX7epw/46w4z5XifphIOpiqrW6MFhMxOWSu', 33333333);

-- 
-- Restore previous SQL mode
-- 
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;

-- 
-- Enable foreign keys
-- 
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;