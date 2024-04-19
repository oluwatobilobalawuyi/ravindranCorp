# Ravindran Corp - Premier League Database Overview

## About
The Ravindran Corp project is designed to provide comprehensive statistics from the Premier League, focusing on player performance, team standings, and detailed football metrics. This repository contains all the necessary files to deploy and manage a dynamic database and web interface that caters to football enthusiasts, analysts, and anyone interested in in-depth football data.

## Authors
- **Oluwatobiloba Lawuyi** - Project Manager, Programmer and Researcher
- **Kelechi Onyewuenyi** - Database Programmer
- **Wali Siddiqui** - Database Programmer
- **Christian Earle** - Database Researcher
- **London Thompson** - Technical Writer

## Creation Date
- **2024**

## Repository Structure
### Files
- **index.php** - Home page of the web application.
- **offenders.php** - Displays detailed statistics about players with disciplinary records.
- **topPerformers.php** - Showcases top performers in various categories.
- **team_detail.php** - Provides a detailed view of each Premier League team.
- **lastliners.php** - Focuses on defensive statistics including saves and clearances.
- **ravindran.css** - Stylesheet for the web application, ensuring a consistent and visually appealing design.
- **ravindrancorp.sql** - Contains all SQL queries for creating and managing the database tables and relationships.

### Additional Documents
- **RAVINDRAN_CORP.pdf** - Detailed documentation of the database architecture, implementation methods, and system functionality.
- **Ravindran Corp Final.pptx** - Presentation slides providing an overview of the project, its goals, and functionality.

## System Overview
- The database consists of tables designed to capture a wide array of data ranging from player performances to detailed team analytics.
- Each table connects through a common foreign key, `TeamPos`, ensuring integrated data retrieval across the database.

## Installation
To set up the Ravindran Corp database and web interface:
1. Clone the repository to your local machine or server.
2. Import the `ravindrancorp.sql` file into your MySQL database to set up the schema and initial data.
3. Configure the database connection settings in each PHP file to match your database credentials.
4. Deploy the PHP files to your server.

## Usage
Navigate to `index.php` on your deployed server to interact with the system. Utilize the navigation links to explore different data views such as Top Performers, Offenders, and Last Liners.

## Acknowledgments
This project was developed as part of the Database Management course at Prairie View A&M University, under the guidance of Dr. Mary Kim.

## Contact
For more information contact lawuyioluwatobiloba@gmail.com
