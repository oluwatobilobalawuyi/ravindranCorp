-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 17, 2024 at 11:30 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `ravindrancorp`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `CountMatches` (IN `teamName` VARCHAR(40), OUT `matchCount` INT)   BEGIN
    SELECT COUNT(*) INTO matchCount FROM PremierLeague23 WHERE TeamName = teamName;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GKUnion` ()   BEGIN
    DECLARE v_PlayerName VARCHAR(100);
    DECLARE v_TeamName VARCHAR(100);
    DECLARE v_Saves INT;
    DECLARE v_CleanSheets INT;
    DECLARE done INT DEFAULT FALSE;

    DECLARE cur_goalkeeperPerformance CURSOR FOR
        SELECT 
            s.PlayerName, 
            s.TeamName, 
            COALESCE(s.Saves, 0) AS Saves,
            COALESCE(cw.CleanSheets, 0) AS CleanSheets
        FROM Saves s
        JOIN CleanSheetWarriors cw ON s.PlayerName = cw.PlayerName AND s.TeamName = cw.TeamName;

    -- Handler for no more rows
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur_goalkeeperPerformance;

    performance_loop:LOOP
        FETCH cur_goalkeeperPerformance INTO v_PlayerName, v_TeamName, v_Saves, v_CleanSheets;
        IF done THEN
            LEAVE performance_loop;
        END IF;

        SELECT v_PlayerName, v_TeamName, v_Saves, v_CleanSheets;
    END LOOP;

    CLOSE cur_goalkeeperPerformance;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `NoNonsensers` ()   BEGIN
    DECLARE v_PlayerName VARCHAR(100);
    DECLARE v_TeamName VARCHAR(100);
    DECLARE v_Clearances INT;
    DECLARE v_YellowCards INT;
    DECLARE v_Fouls INT;
    DECLARE done INT DEFAULT FALSE;

    DECLARE DeyPlayers CURSOR FOR
        SELECT 
            go.PlayerName, 
            go.TeamName, 
            COALESCE(go.Clearances, 0) AS Clearances,
            COALESCE(ld.YellowCards, 0) AS YellowCards,
            COALESCE(ro.Fouls, 0) AS Fouls
        FROM GetOuttaHere go
        LEFT JOIN LessDisciplined ld ON go.PlayerName = ld.PlayerName AND go.TeamName = ld.TeamName
        LEFT JOIN Roughians ro ON go.PlayerName = ro.PlayerName AND go.TeamName = ro.TeamName;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN DeyPlayers;

    performance_loop:LOOP
        FETCH DeyPlayers INTO v_PlayerName, v_TeamName, v_Clearances, v_YellowCards, v_Fouls;
        IF done THEN
            LEAVE performance_loop;
        END IF;

        SELECT v_PlayerName, v_TeamName, v_Clearances, v_YellowCards, v_Fouls;
    END LOOP;

    CLOSE DeyPlayers;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `PlayerDisciplineReport` ()   BEGIN
    DECLARE v_PlayerName VARCHAR(100);
    DECLARE v_TeamName VARCHAR(100);
    DECLARE v_YellowCards INT;
    DECLARE v_Fouls INT;
    DECLARE done INT DEFAULT FALSE;
    
    DECLARE discipline_cursor CURSOR FOR
        SELECT 
            ld.PlayerName,
            ld.TeamName,
            ld.YellowCards,
            ro.Fouls
        FROM LessDisciplined ld
        INNER JOIN Roughians ro ON ld.PlayerName = ro.PlayerName AND ld.TeamName = ro.TeamName;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN discipline_cursor;

    discipline_loop:LOOP
        FETCH discipline_cursor INTO v_PlayerName, v_TeamName, v_YellowCards, v_Fouls;
        IF done THEN
            LEAVE discipline_loop;
        END IF;

        SELECT v_PlayerName, v_TeamName, v_YellowCards, v_Fouls;
    END LOOP;

    CLOSE discipline_cursor;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `PlayerStatistics` ()   BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_playerName VARCHAR(255);
    DECLARE v_teamName VARCHAR(255);
    DECLARE v_goals INT;
    DECLARE v_assists INT;
    DECLARE v_yellowCards INT;
    DECLARE cur CURSOR FOR
        SELECT 
            gb.PlayerName,
            gb.TeamName,
            COALESCE(gb.GoalsScored, 0) AS Goals,
            COALESCE(ak.Assists, 0) AS Assists,
            COALESCE(ld.YellowCards, 0) AS YellowCards
        FROM
            goldenboot_winners gb
        LEFT JOIN AssistKing ak ON gb.PlayerName = ak.PlayerName AND gb.TeamName = ak.TeamName
        LEFT JOIN LessDisciplined ld ON gb.PlayerName = ld.PlayerName AND gb.TeamName = ld.TeamName
        WHERE
            gb.TeamName = 'Manchester United';  -- Example team, change as needed
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    fetch_loop: LOOP
        FETCH cur INTO v_playerName, v_teamName, v_goals, v_assists, v_yellowCards;
        IF done THEN
            LEAVE fetch_loop;
        END IF;

        -- Output the fetched data. In practice, you might be inserting this into a report table or performing further calculations.
        SELECT v_playerName, v_teamName, v_goals, v_assists, v_yellowCards;
    END LOOP;

    CLOSE cur;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `assistking`
--

CREATE TABLE `assistking` (
  `Rank` int(11) NOT NULL,
  `PlayerName` varchar(40) NOT NULL,
  `Nickname` varchar(30) DEFAULT NULL,
  `TeamName` varchar(40) NOT NULL,
  `MatchesPlayed` char(2) NOT NULL,
  `Assists` int(11) NOT NULL CHECK (`Assists` >= 0),
  `Nationality` varchar(20) DEFAULT NULL,
  `TeamPos` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `assistking`
--

INSERT INTO `assistking` (`Rank`, `PlayerName`, `Nickname`, `TeamName`, `MatchesPlayed`, `Assists`, `Nationality`, `TeamPos`) VALUES
(1, 'Kevin De Bruyne', 'KDB', 'Manchester City', '32', 16, 'Belgium', 1),
(2, 'Mohamed Salah', 'Egyptian King', 'Liverpool', '38', 12, 'Egypt', 5),
(3, 'Leandro Trossard', 'The Racoon', 'Brighton/Arsenal', '36', 12, 'Belgium', 2),
(4, 'Michael Olise', NULL, 'Crystal Palace', '37', 11, 'France', 11),
(5, 'Bukayo Saka', 'Star Boy', 'Arsenal', '38', 11, 'England', 2),
(6, 'Riyad Mahrez', 'Little Rooster', 'Manchester City', '30', 10, 'Algeria', 1),
(7, 'Trent Alexander-Arnold', NULL, 'Liverpool', '37', 9, 'England', 5),
(8, 'James Maddison', 'Darts Boy', 'Leicester City', '30', 9, 'England', 18),
(9, 'Bruno Fernandes', 'Magnifico', 'Manchester United', '37', 8, 'Portugal', 3),
(10, 'Christian Eriksen', 'Golazo', 'Manchester United', '28', 8, 'Denmark', 3),
(11, 'Morgan Gibbs-White', NULL, 'Nottingham Forest', '35', 8, 'England', 16),
(12, 'Pascal Groß', NULL, 'Brighton & Hove Albion', '37', 8, 'Germany', 6),
(13, 'Erling Haaland', 'The Terminator', 'Manchester City', '35', 8, 'Norway', 1),
(14, 'Bryan Mbeumo', 'LeBron', 'Brentford', '38', 8, 'Cameroon', 9),
(15, 'Ivan Perisic', 'Koka', 'Tottenham Hotspur', '34', 8, 'Croatia', 8),
(16, 'Andy Robertson', 'ShitHouse', 'Liverpool', '34', 8, 'Scotland', 5),
(17, 'Jack Grealish', NULL, 'Manchester City', '28', 7, 'England', 1),
(18, 'Jack Harrison', NULL, 'Leeds United', '36', 7, 'England', 19),
(19, 'Alex Iwobi', 'Naija Boy', 'Everton', '38', 7, 'Nigeria', 17),
(20, 'Dejan Kulusevski', NULL, 'Tottenham Hotspur', '30', 7, 'Sweden', 8);

-- --------------------------------------------------------

--
-- Table structure for table `cleansheetwarriors`
--

CREATE TABLE `cleansheetwarriors` (
  `Rank` int(11) NOT NULL,
  `PlayerName` varchar(40) NOT NULL,
  `Nickname` varchar(30) DEFAULT NULL,
  `TeamName` varchar(40) NOT NULL,
  `Nationality` varchar(20) DEFAULT NULL,
  `CleanSheets` int(11) NOT NULL CHECK (`CleanSheets` >= 0),
  `MatchesPlayed` int(11) NOT NULL CHECK (`MatchesPlayed` >= 0),
  `TeamPos` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `cleansheetwarriors`
--

INSERT INTO `cleansheetwarriors` (`Rank`, `PlayerName`, `Nickname`, `TeamName`, `Nationality`, `CleanSheets`, `MatchesPlayed`, `TeamPos`) VALUES
(1, 'David de Gea', NULL, 'Manchester United', 'Spain', 17, 38, 3),
(2, 'Aaron Ramsdale', NULL, 'Arsenal', 'England', 14, 38, 2),
(3, 'David Raya', NULL, 'Brentford', 'Spain', 12, 38, 9),
(4, 'Alisson Becker', NULL, 'Liverpool', 'Brazil', 14, 37, 5),
(5, 'Jordan Pickford', NULL, 'Everton', 'England', 8, 37, 17),
(6, 'Nick Pope', NULL, 'Newcastle United', 'England', 14, 37, 4),
(7, 'Lukasz Fabianski', NULL, 'West Ham United', 'Poland', 9, 36, 8),
(8, 'Bernd Leno', NULL, 'Fulham', 'Germany', 8, 36, 10),
(9, 'Jose Sa', NULL, 'Wolverhampton Wanderers', 'Portugal', 11, 36, 13),
(10, 'Emiliano Martinez', NULL, 'Aston Villa', 'Argentina', 11, 36, 7),
(11, 'Ederson', NULL, 'Manchester City', 'Brazil', 11, 35, 1),
(12, 'Illan Meslier', NULL, 'Leeds United', 'France', 5, 34, 19),
(13, 'Gavin Bazunu', NULL, 'Southampton', 'Ireland', 4, 32, 20),
(14, 'Kepa Arrizabalaga', NULL, 'Chelsea', 'Spain', 9, 29, 12),
(15, 'Vicente Guaita', NULL, 'Crystal Palace', 'Spain', 6, 27, 11),
(16, 'Neto', NULL, 'Bournemouth', 'Brazil', 6, 27, 14),
(17, 'Danny Ward', NULL, 'Leicester City', 'Wales', 6, 26, 18),
(18, 'Hugo Lloris', NULL, 'Tottenham Hotspur', 'France', 7, 25, 8),
(19, 'Robert Sanchez', NULL, 'Brighton & Hove Albion', 'Spain', 6, 23, 6),
(20, 'Dean Henderson', NULL, 'Nottingham Forest', 'England', 6, 18, 16);

-- --------------------------------------------------------

--
-- Table structure for table `errorlog`
--

CREATE TABLE `errorlog` (
  `errormessage` varchar(60) NOT NULL,
  `errorid` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `errorlog`
--

INSERT INTO `errorlog` (`errormessage`, `errorid`) VALUES
('Inserted rank with negative quantity in goldenboot_winners', 1234);

-- --------------------------------------------------------

--
-- Table structure for table `getouttahere`
--

CREATE TABLE `getouttahere` (
  `Rank` int(11) NOT NULL,
  `PlayerName` varchar(40) NOT NULL,
  `TeamName` varchar(40) NOT NULL,
  `MatchesPlayed` int(11) NOT NULL,
  `Clearances` int(11) NOT NULL CHECK (`Clearances` >= 0),
  `Nationality` varchar(20) DEFAULT NULL,
  `TeamPos` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `getouttahere`
--

INSERT INTO `getouttahere` (`Rank`, `PlayerName`, `TeamName`, `MatchesPlayed`, `Clearances`, `Nationality`, `TeamPos`) VALUES
(1, 'Ethan Pinnock', 'Brentford', 30, 214, 'Jamaica', 9),
(2, 'James Tarkowski', 'Everton', 38, 196, 'England', 17),
(3, 'Joachim Andersen', 'Crystal Palace', 32, 187, 'Denmark', 11),
(4, 'Maximilian Kilman', 'Wolverhampton Wanderers', 37, 163, 'England', 13),
(5, 'Tyrone Mings', 'Aston Villa', 35, 158, 'England', 7),
(6, 'Robin Koch', 'Leeds United', 36, 147, 'Germany', 19),
(7, 'Chris Mepham', 'Bournemouth', 26, 146, 'Wales', 15),
(8, 'Marcos Senesi', 'Bournemouth', 31, 140, 'Argentina', 15),
(9, 'Tosin Adarabioyo', 'Fulham', 25, 138, 'England', 10),
(10, 'Fabian Schar', 'Newcastle United', 36, 137, 'Switzerland', 4),
(11, 'Virgil Van Dijk', 'Liverpool', 32, 135, 'Netherlands', 5),
(12, 'Marc Guehi', 'Crystal Palace', 37, 132, 'England', 11),
(13, 'Sven Botman', 'Newcastle United', 36, 120, 'Netherlands', 4),
(14, 'Gabriel Magalhaes', 'Arsenal', 38, 120, 'Brazil', 2),
(15, 'Mohammed Salisu', 'Southampton', 34, 119, 'Ghana', 20),
(16, 'Kurt Zouma', 'West Ham United', 25, 118, 'France', 8),
(17, 'Ben Mee', 'Brentford', 37, 116, 'England', 9),
(18, 'Ezri Konsa', 'Aston Villa', 38, 114, 'England', 7);

-- --------------------------------------------------------

--
-- Table structure for table `goldenboot_winners`
--

CREATE TABLE `goldenboot_winners` (
  `Rank` int(11) NOT NULL,
  `PlayerName` varchar(40) NOT NULL,
  `Nickname` varchar(30) DEFAULT NULL,
  `TeamName` varchar(40) DEFAULT NULL,
  `MatchesPlayed` char(2) NOT NULL,
  `GoalsScored` int(11) NOT NULL,
  `Nationality` varchar(20) DEFAULT NULL,
  `TeamPos` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `goldenboot_winners`
--

INSERT INTO `goldenboot_winners` (`Rank`, `PlayerName`, `Nickname`, `TeamName`, `MatchesPlayed`, `GoalsScored`, `Nationality`, `TeamPos`) VALUES
(1, 'Erling Haaland', 'The Terminator', 'Manchester City', '35', 36, 'Norway', 1),
(2, 'Harry Kane', 'The HurriKane', 'Tottenham', '38', 30, 'England', 8),
(3, 'Ivan Toney', NULL, 'Brentford', '33', 20, 'England', 9),
(4, 'Mohamed Salah', 'Egyptian King', 'Liverpool', '38', 19, 'Egypt', 5),
(5, 'Callum Wilson', NULL, 'Newcastle United', '31', 18, 'England', 4),
(6, 'Marcus Rashford', 'Rashy', 'Manchester United', '35', 17, 'England', 3),
(7, 'Gabriel Martinelli', NULL, 'Arsenal', '36', 15, 'Brazil', 2),
(8, 'Ollie Watkins', NULL, 'Aston Villa', '37', 15, 'England', 7),
(9, 'Martin Ødegaard', 'Hair Flicks', 'Arsenal', '37', 15, 'Norway', 2),
(10, 'Aleksandar Mitrovic', NULL, 'Fulham', '24', 14, 'Serbia', 10),
(11, 'Bukayo Saka', 'StarBoy', 'Arsenal', '38', 14, 'England', 2),
(12, 'Harvey Barnes', NULL, 'Leicester City', '34', 13, 'England', 18),
(13, 'Rodrigo', NULL, 'Leeds United', '36', 31, 'Spain', 19),
(14, 'Miguel Almiron', NULL, 'Newcastle United', '34', 11, 'Paraguay', 4),
(15, 'Roberto Firmino', 'Bobby', 'Liverpool', '25', 11, 'Brazil', 5),
(16, 'Gabriel Jesus', NULL, 'Arsenal', '26', 11, 'Brazil', 2),
(17, 'Phil Foden', NULL, 'Manchester City', '32', 11, 'England', 1),
(18, 'Taiwo Awoniyi', NULL, 'Nottingham Forest', '27', 10, 'Nigeria', 16),
(19, 'Eberechi Eze', 'Drunken Master', 'Crystal Palace', '38', 10, 'England', 11),
(20, 'Alexander Isak', 'Baby Ibra', 'Newcastle United', '22', 10, 'Sweden', 4),
(22, '', 'Fopes Odogwu', NULL, '10', 50, 'Nigeria', 9);

--
-- Triggers `goldenboot_winners`
--
DELIMITER $$
CREATE TRIGGER `error_handling_trigger_playerN` BEFORE INSERT ON `goldenboot_winners` FOR EACH ROW BEGIN
  IF NEW.`PlayerName` IS NULL THEN
  INSERT INTO errorlog (errormessage, errorid)
   VALUES ('Inserted NULL name into goldenboot_winners', 2903);
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `error_handling_trigger_rank` BEFORE INSERT ON `goldenboot_winners` FOR EACH ROW BEGIN
    IF NEW.`Rank` < 0 THEN
    INSERT INTO errorlog (errormessage, errorid)
    VALUES ('Inserted rank with negative quantity in goldenboot_winners',
 	  1234);
END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `insert_team_nonickname` AFTER INSERT ON `goldenboot_winners` FOR EACH ROW BEGIN 
 IF NEW.nickname IS NULL THEN 
  INSERT INTO nonickname (name, teamname) 
  VALUES (NEW.PlayerName, NEW.TeamName); 
 END IF; 
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `history`
--

CREATE TABLE `history` (
  `TeamName` varchar(30) NOT NULL,
  `TeamCaptain` varchar(40) NOT NULL,
  `LeagueStatus` varchar(40) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `history`
--

INSERT INTO `history` (`TeamName`, `TeamCaptain`, `LeagueStatus`) VALUES
('Manchester City', 'Ilkay Gundogan', 'Champions');

-- --------------------------------------------------------

--
-- Table structure for table `lessdisciplined`
--

CREATE TABLE `lessdisciplined` (
  `Rank` int(11) NOT NULL,
  `PlayerName` varchar(40) NOT NULL,
  `TeamName` varchar(40) NOT NULL,
  `MatchesPlayed` int(11) NOT NULL,
  `YellowCards` int(11) NOT NULL CHECK (`YellowCards` >= 0),
  `Nationality` varchar(20) DEFAULT NULL,
  `TeamPos` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `lessdisciplined`
--

INSERT INTO `lessdisciplined` (`Rank`, `PlayerName`, `TeamName`, `MatchesPlayed`, `YellowCards`, `Nationality`, `TeamPos`) VALUES
(1, 'João Palhinha', 'Fulham', 27, 14, 'Portugal', 10),
(2, 'Joelinton', 'Newcastle United', 32, 12, 'Brazil', 4),
(3, 'Ruben Neves', 'Wolverhampton Wanderers', 35, 12, 'Portugal', 13),
(4, 'Nelson Semedo', 'Wolverhampton Wanderers', 36, 11, 'Portugal', 13),
(5, 'Adam Smith', 'Bournemouth', 37, 11, 'England', 15),
(6, 'Fabinho', 'Liverpool', 36, 11, 'Brazil', 5),
(7, 'Moises Caicedo', 'Brighton & Hove Albion', 37, 10, 'Ecuador', 6),
(8, 'Bruno Guimaraes', 'Newcastle United', 32, 9, 'Brazil', 4),
(9, 'Conor Gallagher', 'Chelsea', 35, 9, 'England', 12),
(10, 'Romeo Lavia', 'Southampton', 29, 9, 'Belgium', 20),
(11, 'Amadou Onana', 'Everton', 29, 9, 'Belgium', 17),
(12, 'BouBakary Soumare', 'Leicester City', 26, 9, 'France', 18),
(13, 'Ivan Toney', 'Brentford', 33, 9, 'England', 9),
(14, 'Joachim Andersen', 'Crystal Palace', 32, 8, 'Denmark', 11),
(15, 'Rodrigo Bentancur', 'Tottenham Hotspur', 18, 8, 'Uruguay', 8),
(16, 'Bobby De Cordova-Reid', 'Fulham', 36, 8, 'Jamaica', 10),
(17, 'Marc Guéhi', 'Crystal Palace', 37, 8, 'England', 11),
(18, 'Andreas Pereira', 'Fulham', 33, 8, 'Brazil', 10),
(19, 'Mateo Kovacic', 'Chelsea', 27, 8, 'Croatia', 12);

-- --------------------------------------------------------

--
-- Table structure for table `nominerals`
--

CREATE TABLE `nominerals` (
  `Rank` int(11) NOT NULL,
  `PlayerName` varchar(40) NOT NULL,
  `Nickname` varchar(30) DEFAULT NULL,
  `TeamName` varchar(40) NOT NULL,
  `ChancesMissed` int(11) NOT NULL CHECK (`ChancesMissed` >= 0),
  `Nationality` varchar(20) DEFAULT NULL,
  `TeamPos` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `nominerals`
--

INSERT INTO `nominerals` (`Rank`, `PlayerName`, `Nickname`, `TeamName`, `ChancesMissed`, `Nationality`, `TeamPos`) VALUES
(1, 'Erling Haaland', NULL, 'Manchester City', 28, 'Norway', 1),
(2, 'Marcus Rashford', NULL, 'Manchester United', 22, 'England', 3),
(3, 'Darwin Nunez', NULL, 'Liverpool', 20, 'Uruguay', 5),
(4, 'Mohamed Salah', NULL, 'Liverpool', 20, 'Egypt', 5),
(5, 'Ollie Watkins', NULL, 'Aston Villa', 20, 'England', 7),
(6, 'Gabriel Jesus', NULL, 'Arsenal', 16, 'Brazil', 2),
(7, 'Ivan Toney', NULL, 'Brentford', 16, 'England', 9),
(8, 'Callum Wilson', NULL, 'Newcastle United', 16, 'England', 4),
(9, 'Kai Havertz', NULL, 'Chelsea', 14, 'Germany', 12),
(10, 'Patrick Bamford', NULL, 'Leeds United', 13, 'England', 19),
(11, 'Aleksandar Mitrovic', NULL, 'Fulham', 13, 'Serbia', 10),
(12, 'Harry Kane', NULL, 'Tottenham Hotspur', 12, 'England', 8),
(13, 'Kaoru Mitoma', NULL, 'Brighton & Hove Albion', 12, 'Japan', 6),
(14, 'Che Adams', NULL, 'Southampton', 11, 'Scotland', 20),
(15, 'Solly March', NULL, 'Brighton & Hove Albion', 11, 'England', 6),
(16, 'Bryan Mbeumo', NULL, 'Brentford', 11, 'Cameroon', 9),
(17, 'Eddie Nketiah', NULL, 'Arsenal', 11, 'England', 2),
(18, 'Diogo Jota', NULL, 'Liverpool', 10, 'Portugal', 5),
(19, 'Jamie Vardy', NULL, 'Leicester City', 10, 'England', 18),
(20, 'Danny Welbeck', NULL, 'Brighton & Hove Albion', 10, 'England', 6);

-- --------------------------------------------------------

--
-- Table structure for table `nonickname`
--

CREATE TABLE `nonickname` (
  `name` varchar(30) NOT NULL,
  `teamname` varchar(40) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `nonickname`
--

INSERT INTO `nonickname` (`name`, `teamname`) VALUES
('Kylian Mbappe', 'Paris Saint-Germain');

-- --------------------------------------------------------

--
-- Table structure for table `premierleague23`
--

CREATE TABLE `premierleague23` (
  `TeamPosition` int(11) NOT NULL,
  `TeamName` varchar(30) NOT NULL,
  `TeamCaptain` varchar(30) DEFAULT NULL,
  `MatchesPlayed` int(11) NOT NULL,
  `Wins` int(11) NOT NULL,
  `Draws` int(11) NOT NULL,
  `Losses` int(11) NOT NULL,
  `GoalsScored` int(11) NOT NULL,
  `GoalsConceded` int(11) NOT NULL,
  `GoalsTally` int(11) NOT NULL,
  `PointsTally` int(11) NOT NULL,
  `LeagueStatus` varchar(60) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `premierleague23`
--

INSERT INTO `premierleague23` (`TeamPosition`, `TeamName`, `TeamCaptain`, `MatchesPlayed`, `Wins`, `Draws`, `Losses`, `GoalsScored`, `GoalsConceded`, `GoalsTally`, `PointsTally`, `LeagueStatus`) VALUES
(1, 'Cheating Boys', 'Mehnn one German dude', 38, 28, 5, 5, 94, 33, 61, 89, '115 Charges'),
(2, 'Arsenal', 'Martin Odegaard', 38, 26, 6, 6, 88, 43, 45, 84, 'Champions League Qualification'),
(3, 'Manchester United', 'Bruno Fernandes', 38, 23, 6, 9, 58, 43, 15, 75, 'Champions League Qualification'),
(4, 'Newcastle United', 'Jamal Lascelles', 38, 19, 14, 5, 68, 33, 35, 71, 'Champions League Qualification'),
(5, 'Liverpool', 'Jordan Henderson', 38, 19, 10, 9, 75, 47, 28, 67, 'Europa League Qualification'),
(6, 'Brighton & Hove Albion', 'Lewis Dunk', 38, 18, 8, 12, 72, 53, 19, 62, 'Europa League Qualification'),
(7, 'Aston Villa', 'John McGinn', 38, 18, 7, 13, 51, 46, 5, 61, 'Conference League Play-Off Qualification'),
(8, 'Tottenham Hotspur', 'Hugo Lloris', 38, 18, 6, 14, 70, 63, 7, 60, NULL),
(9, 'Brentford', 'Pontus Jansson', 38, 15, 14, 9, 58, 46, 12, 59, NULL),
(10, 'Fulham', 'Tom Cairney', 38, 15, 7, 16, 55, 53, 2, 52, NULL),
(11, 'Crystal Palace', 'Luka Milivojevic', 38, 11, 12, 15, 40, 49, -9, 45, NULL),
(12, 'Chelsea', 'Cesar Azpilicueta', 38, 11, 11, 16, 38, 47, -9, 44, NULL),
(13, 'Wolverhampton Wanderers', 'Ruben Neves', 38, 11, 8, 19, 31, 58, -27, 41, NULL),
(14, 'West Ham United', 'Declan Rice', 38, 11, 7, 20, 42, 55, -13, 40, 'Europa League Qualification'),
(15, 'Bournemouth', 'Ron Vlaar', 38, 11, 6, 21, 37, 71, -34, 39, NULL),
(16, 'Nottingham Forest', 'Joe Worrall', 38, 9, 11, 18, 38, 68, -30, 38, NULL),
(17, 'Everton', 'Seamus Coleman', 38, 8, 12, 18, 34, 57, -23, 36, NULL),
(18, 'Leicester City', 'Jonny Evans', 38, 9, 7, 22, 51, 68, -17, 34, 'Relegated to Championship'),
(19, 'Leeds United', 'Liam Cooper', 38, 7, 10, 21, 48, 78, -30, 31, 'Relegated to Championship'),
(20, 'Southampton', 'James Ward-Prowse', 38, 6, 7, 25, 36, 73, -37, 25, 'Relegated to Championship');

--
-- Triggers `premierleague23`
--
DELIMITER $$
CREATE TRIGGER `savetmp` BEFORE UPDATE ON `premierleague23` FOR EACH ROW BEGIN
    INSERT INTO History (TeamName, TeamCaptain, LeagueStatus) 
    VALUES (OLD.TeamName, OLD.TeamCaptain, OLD.LeagueStatus);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `premiumplayers`
-- (See below for the actual view)
--
CREATE TABLE `premiumplayers` (
`PlayerName` varchar(40)
,`TeamName` varchar(40)
,`Goals` int(11)
,`Assists` int(11)
);

-- --------------------------------------------------------

--
-- Table structure for table `roughians`
--

CREATE TABLE `roughians` (
  `Rank` int(11) NOT NULL,
  `PlayerName` varchar(40) NOT NULL,
  `Nickname` varchar(30) DEFAULT NULL,
  `TeamName` varchar(40) NOT NULL,
  `Fouls` int(11) NOT NULL CHECK (`Fouls` >= 0),
  `Nationality` varchar(20) DEFAULT NULL,
  `TeamPos` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `roughians`
--

INSERT INTO `roughians` (`Rank`, `PlayerName`, `Nickname`, `TeamName`, `Fouls`, `Nationality`, `TeamPos`) VALUES
(1, 'Joelinton', NULL, 'Newcastle United', 65, 'Brazil', 4),
(2, 'Moises Caicedo', NULL, 'Brighton & Hove Albion', 65, 'Ecuador', 6),
(3, 'Kai Havertz', NULL, 'Chelsea', 60, 'Germany', 3),
(4, 'Fabinho', NULL, 'Liverpool', 53, 'Brazil', 5),
(5, 'Ivan Toney', NULL, 'Brentford', 52, 'England', 9),
(6, 'Jeffrey Schlupp', NULL, 'Crystal Palace', 51, 'Ghana', 11),
(7, 'Tomas Soucek', NULL, 'West Ham United', 50, 'Czech Republic', 8),
(8, 'Lucas Paqueta', NULL, 'West Ham United', 50, 'Brazil', 8),
(9, 'Ryan Yates', NULL, 'Nottingham Forest', 50, 'England', 16),
(10, 'Jordan Ayew', NULL, 'Crystal Palace', 48, 'Ghana', 11),
(11, 'Casemiro', NULL, 'Manchester United', 48, 'Brazil', 3),
(12, 'Joao Palhinha', NULL, 'Fulham', 48, 'Portugal', 10);

-- --------------------------------------------------------

--
-- Table structure for table `saves`
--

CREATE TABLE `saves` (
  `Rank` int(11) NOT NULL,
  `PlayerName` varchar(40) NOT NULL,
  `Nickname` varchar(30) DEFAULT NULL,
  `TeamName` varchar(40) NOT NULL,
  `Nationality` varchar(20) DEFAULT NULL,
  `Saves` int(11) NOT NULL CHECK (`Saves` >= 0),
  `MatchesPlayed` int(11) NOT NULL CHECK (`MatchesPlayed` >= 0),
  `TeamPos` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `saves`
--

INSERT INTO `saves` (`Rank`, `PlayerName`, `Nickname`, `TeamName`, `Nationality`, `Saves`, `MatchesPlayed`, `TeamPos`) VALUES
(1, 'David Raya', NULL, 'Brentford', 'Spain', 154, 38, 9),
(2, 'Bernd Leno', NULL, 'Fulham', 'Germany', 144, 36, 10),
(3, 'Jordan Pickford', NULL, 'Everton', 'England', 124, 37, 17),
(4, 'Alisson Becker', NULL, 'Liverpool', 'Brazil', 108, 37, 5),
(5, 'Lukasz Fabianski', NULL, 'West Ham United', 'Poland', 108, 36, 8),
(6, 'Jos├® S├í', NULL, 'Wolverhampton Wanderers', 'Portugal', 108, 36, 13),
(7, 'David de Gea', NULL, 'Manchester United', 'Spain', 101, 38, 3),
(8, 'Neto', NULL, 'Bournemouth', 'Brazil', 100, 27, 14),
(9, 'Emiliano Mart├¡nez', NULL, 'Aston Villa', 'Argentina', 98, 36, 7),
(10, 'Aaron Ramsdale', NULL, 'Arsenal', 'England', 95, 38, 2),
(11, 'Illan Meslier', NULL, 'Leeds United', 'France', 94, 34, 19),
(12, 'Kepa Arrizabalaga', NULL, 'Chelsea', 'Spain', 91, 29, 12),
(13, 'Nick Pope', NULL, 'Newcastle United', 'England', 87, 37, 4),
(14, 'Vicente Guaita', NULL, 'Crystal Palace', 'Spain', 85, 27, 11),
(15, 'Hugo Lloris', NULL, 'Tottenham Hotspur', 'France', 79, 25, 8),
(16, 'Danny Ward', NULL, 'Leicester City', 'Wales', 78, 26, 18),
(17, 'Gavin Bazunu', NULL, 'Southampton', 'Ireland', 69, 32, 20),
(18, 'Dean Henderson', NULL, 'Nottingham Forest', 'England', 55, 18, 16),
(19, 'Keylor Navas', NULL, 'Nottingham Forest', 'Costa Rica', 51, 17, 16),
(20, 'Robert S├ínchez', NULL, 'Brighton & Hove Albion', 'Spain', 48, 23, 6);

-- --------------------------------------------------------

--
-- Table structure for table `whyareyourunning`
--

CREATE TABLE `whyareyourunning` (
  `Rank` int(11) NOT NULL,
  `PlayerName` varchar(40) NOT NULL,
  `Nickname` varchar(30) DEFAULT NULL,
  `TeamName` varchar(40) NOT NULL,
  `Nationality` varchar(20) DEFAULT NULL,
  `MatchesPlayed` int(11) NOT NULL CHECK (`MatchesPlayed` <= 38),
  `Offsides` int(11) NOT NULL CHECK (`Offsides` > 1),
  `TeamPos` int(11) DEFAULT NULL CHECK (`TeamPos` <= 20)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `whyareyourunning`
--

INSERT INTO `whyareyourunning` (`Rank`, `PlayerName`, `Nickname`, `TeamName`, `Nationality`, `MatchesPlayed`, `Offsides`, `TeamPos`) VALUES
(1, 'Jamie Vardy', NULL, 'Leicester City', 'England', 37, 29, 18),
(2, 'Kai Havertz', NULL, 'Chelsea', 'Germany', 35, 28, 12),
(3, 'Ivan Toney', NULL, 'Brentford', 'England', 33, 27, 9),
(4, 'Mohammed Salah', NULL, 'Liverpool', 'Egypt', 38, 22, 5),
(5, 'Dominic Calvert-Lewin', NULL, 'Everton', 'England', 17, 19, 17),
(6, 'Yoane Wissa', NULL, 'Brentford', 'DR Congo', 38, 19, 9),
(7, 'Patrick Bamford', NULL, 'Leeds United', 'England', 28, 18, 19),
(8, 'Brennan Johnson', NULL, 'Nottingham Forest', 'Wales', 38, 18, 16),
(9, 'Son Heung-Min', NULL, 'Tottenham Hotspur', 'South Korea', 36, 18, 8),
(10, 'Ollie Watkins', NULL, 'Aston Villa', 'England', 37, 18, 7),
(11, 'Darwin Nunez', NULL, 'Liverpool', 'Uruguay', 29, 17, 5),
(12, 'Diego Costa', NULL, 'Wolverhampton Wanderers', 'Spain', 23, 16, 13),
(13, 'Gabriel Jesus', NULL, 'Arsenal', 'Brazil', 26, 16, 2),
(14, 'Harry Kane', NULL, 'Tottenham Hotspur', 'England', 38, 16, 8),
(15, 'Taiwo Awoniyi', NULL, 'Nottingham Forest', 'Nigeria', 27, 15, 16),
(16, 'Bruno Fernandes', NULL, 'Manchester United', 'Portugal', 37, 15, 3),
(17, 'Marcus Rashford', NULL, 'Manchester United', 'England', 35, 15, 3),
(18, 'Theo Walcott', NULL, 'Southampton', 'England', 20, 15, 20),
(19, 'Callum Wilson', NULL, 'Newcastle United', 'England', 31, 15, 4),
(20, 'Che Adams', NULL, 'Southampton', 'Scotland', 28, 14, 20);

-- --------------------------------------------------------

--
-- Structure for view `premiumplayers`
--
DROP TABLE IF EXISTS `premiumplayers`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `premiumplayers`  AS SELECT `g`.`PlayerName` AS `PlayerName`, `g`.`TeamName` AS `TeamName`, `g`.`GoalsScored` AS `Goals`, `a`.`Assists` AS `Assists` FROM (`goldenboot_winners` `g` join `assistking` `a` on(`g`.`PlayerName` = `a`.`PlayerName` and `g`.`TeamName` = `a`.`TeamName`)) WHERE `g`.`GoalsScored` > 9 OR `a`.`Assists` > 9 ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `assistking`
--
ALTER TABLE `assistking`
  ADD PRIMARY KEY (`Rank`),
  ADD KEY `TeamPos` (`TeamPos`);

--
-- Indexes for table `cleansheetwarriors`
--
ALTER TABLE `cleansheetwarriors`
  ADD PRIMARY KEY (`Rank`),
  ADD UNIQUE KEY `Nickname` (`Nickname`),
  ADD KEY `TeamPos` (`TeamPos`);

--
-- Indexes for table `getouttahere`
--
ALTER TABLE `getouttahere`
  ADD PRIMARY KEY (`Rank`),
  ADD KEY `TeamPos` (`TeamPos`);

--
-- Indexes for table `goldenboot_winners`
--
ALTER TABLE `goldenboot_winners`
  ADD PRIMARY KEY (`Rank`),
  ADD KEY `TeamPos` (`TeamPos`);

--
-- Indexes for table `lessdisciplined`
--
ALTER TABLE `lessdisciplined`
  ADD PRIMARY KEY (`Rank`),
  ADD KEY `TeamPos` (`TeamPos`);

--
-- Indexes for table `nominerals`
--
ALTER TABLE `nominerals`
  ADD PRIMARY KEY (`Rank`),
  ADD UNIQUE KEY `Nickname` (`Nickname`),
  ADD KEY `TeamPos` (`TeamPos`);

--
-- Indexes for table `premierleague23`
--
ALTER TABLE `premierleague23`
  ADD PRIMARY KEY (`TeamPosition`),
  ADD UNIQUE KEY `TeamPosition` (`TeamPosition`);

--
-- Indexes for table `roughians`
--
ALTER TABLE `roughians`
  ADD PRIMARY KEY (`Rank`),
  ADD UNIQUE KEY `Nickname` (`Nickname`),
  ADD KEY `TeamPos` (`TeamPos`);

--
-- Indexes for table `saves`
--
ALTER TABLE `saves`
  ADD PRIMARY KEY (`Rank`),
  ADD UNIQUE KEY `Nickname` (`Nickname`),
  ADD KEY `TeamPos` (`TeamPos`);

--
-- Indexes for table `whyareyourunning`
--
ALTER TABLE `whyareyourunning`
  ADD PRIMARY KEY (`Rank`),
  ADD UNIQUE KEY `Nickname` (`Nickname`),
  ADD KEY `TeamPos` (`TeamPos`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `assistking`
--
ALTER TABLE `assistking`
  MODIFY `Rank` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `cleansheetwarriors`
--
ALTER TABLE `cleansheetwarriors`
  MODIFY `Rank` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `getouttahere`
--
ALTER TABLE `getouttahere`
  MODIFY `Rank` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `goldenboot_winners`
--
ALTER TABLE `goldenboot_winners`
  MODIFY `Rank` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `lessdisciplined`
--
ALTER TABLE `lessdisciplined`
  MODIFY `Rank` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `nominerals`
--
ALTER TABLE `nominerals`
  MODIFY `Rank` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- AUTO_INCREMENT for table `roughians`
--
ALTER TABLE `roughians`
  MODIFY `Rank` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `saves`
--
ALTER TABLE `saves`
  MODIFY `Rank` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `whyareyourunning`
--
ALTER TABLE `whyareyourunning`
  MODIFY `Rank` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `assistking`
--
ALTER TABLE `assistking`
  ADD CONSTRAINT `assistking_ibfk_1` FOREIGN KEY (`TeamPos`) REFERENCES `premierleague23` (`TeamPosition`);

--
-- Constraints for table `cleansheetwarriors`
--
ALTER TABLE `cleansheetwarriors`
  ADD CONSTRAINT `cleansheetwarriors_ibfk_1` FOREIGN KEY (`TeamPos`) REFERENCES `premierleague23` (`TeamPosition`);

--
-- Constraints for table `getouttahere`
--
ALTER TABLE `getouttahere`
  ADD CONSTRAINT `getouttahere_ibfk_1` FOREIGN KEY (`TeamPos`) REFERENCES `premierleague23` (`TeamPosition`);

--
-- Constraints for table `goldenboot_winners`
--
ALTER TABLE `goldenboot_winners`
  ADD CONSTRAINT `goldenboot_winners_ibfk_1` FOREIGN KEY (`TeamPos`) REFERENCES `premierleague23` (`TeamPosition`);

--
-- Constraints for table `lessdisciplined`
--
ALTER TABLE `lessdisciplined`
  ADD CONSTRAINT `lessdisciplined_ibfk_1` FOREIGN KEY (`TeamPos`) REFERENCES `premierleague23` (`TeamPosition`);

--
-- Constraints for table `nominerals`
--
ALTER TABLE `nominerals`
  ADD CONSTRAINT `nominerals_ibfk_1` FOREIGN KEY (`TeamPos`) REFERENCES `premierleague23` (`TeamPosition`);

--
-- Constraints for table `roughians`
--
ALTER TABLE `roughians`
  ADD CONSTRAINT `roughians_ibfk_1` FOREIGN KEY (`TeamPos`) REFERENCES `premierleague23` (`TeamPosition`);

--
-- Constraints for table `saves`
--
ALTER TABLE `saves`
  ADD CONSTRAINT `saves_ibfk_1` FOREIGN KEY (`TeamPos`) REFERENCES `premierleague23` (`TeamPosition`);

--
-- Constraints for table `whyareyourunning`
--
ALTER TABLE `whyareyourunning`
  ADD CONSTRAINT `whyareyourunning_ibfk_1` FOREIGN KEY (`TeamPos`) REFERENCES `premierleague23` (`TeamPosition`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
