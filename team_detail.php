<?php
$host = 'localhost';
$db = 'ravindrancorp';
$user = 'root';
$pass = '';
$charset = 'utf8mb4';
$dsn = "mysql:host=$host;dbname=$db;charset=$charset";

$options = [
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES => false,
];

try {
    $pdo = new PDO($dsn, $user, $pass, $options);
} catch (PDOException $e) {
    error_log($e->getMessage());
    die("An error occurred while connecting to the database.");
}

if (!isset($_GET['team']) || empty($_GET['team'])) {
    die("Team not specified.");
}

$teamName = htmlspecialchars($_GET['team']);
$stmt = $pdo->prepare("SELECT * FROM PremierLeague23 WHERE TeamName = :teamName");
$stmt->execute(['teamName' => $teamName]);
$teamDetails = $stmt->fetch();

if (!$teamDetails) {
    die("Team not found.");
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Team Details - <?= $teamName ?></title>
    <link rel="stylesheet" href="ravindran.css">
</head>
<body>
<div class="header">
    <img src="prem.png" alt="Best League in the World" class="image">
    <h1>Information for <?= $teamName ?></h1>
</div>

<table>
    <tr>
        <th>Position</th>
        <td><?= $teamDetails['TeamPosition'] ?></td>
    </tr>
    <tr>
        <th>Team Name</th>
        <td><?= $teamDetails['TeamName'] ?></td>
    </tr>
    <tr>
        <th>Matches Played</th>
        <td><?= $teamDetails['MatchesPlayed'] ?></td>
    </tr>
    <tr>
        <th>Wins</th>
        <td><?= $teamDetails['Wins'] ?></td>
    </tr>
    <tr>
        <th>Draws</th>
        <td><?= $teamDetails['Draws'] ?></td>
    </tr>
    <tr>
        <th>Losses</th>
        <td><?= $teamDetails['Losses'] ?></td>
    </tr>
    <tr>
        <th>Goals Scored</th>
        <td><?= $teamDetails['GoalsScored'] ?></td>
    </tr>
    <tr>
        <th>Goals Conceded</th>
        <td><?= $teamDetails['GoalsConceded'] ?></td>
    </tr>
    <tr>
        <th>Goal Difference</th>
        <td><?= $teamDetails['GoalsTally'] ?></td>
    </tr>
    <tr>
        <th>Points</th>
        <td><?= $teamDetails['PointsTally'] ?></td>
    </tr>
</table>

<a href="index.php" style="color: white; text-align: center; display: block;">Back to Team List</a>

</body>
</html>
