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
    $stmt = $pdo->query('SELECT * FROM PremierLeague23 ORDER BY TeamPosition');
    $teams = $stmt->fetchAll();
} catch (PDOException $e) {
    error_log($e->getMessage());
    echo "An error occurred while connecting to the database: " . $e->getMessage();
    exit;
}

?>

<!DOCTYPE html>
<html lang="en">
<head>
    <link href="https://fonts.googleapis.com/css2?family=Libre+Baskerville:wght@400;700&display=swap" rel="ravindran.css">

    <meta charset="UTF-8">
    <title>Ravindran Corp - Football Facts</title>
    <link rel="stylesheet" href="ravindran.css">
</head>
<body>
<div class="header">
    <img src="prem.png" alt="Best League in the World" class="image">
    <h1>2023 Premier League Season Overview</h1>
</div>

<!-- Navigation Bar -->
<nav>
    <form action="" method="get">
        <button type="submit" formaction="offenders.php" class="nav-button">Offenders</button>
        <button type="submit" formaction="topPerformers.php" class="nav-button">Top Performers</button>
        <button type="submit" formaction="LastLiners.php" class="nav-button">Last Liners</button>
    </form>
</nav>

<!-- Premier League Teams Display -->
<div class="team-grid">
    <?php foreach ($teams as $team): ?>
        <div class="team">
            <a href="team_detail.php?team=<?= urlencode($team['TeamName']) ?>">
            <img src="images/<?= urlencode(strtolower($team['TeamName'])) ?>.jpg" alt="<?= htmlspecialchars($team['TeamName']) ?>">
            </a>
        </div>
    <?php endforeach; ?>
</div>

</body>
</html>