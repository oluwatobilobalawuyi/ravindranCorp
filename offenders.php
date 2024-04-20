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

$roughians = [];
$whyAreYouRunning = [];
$lessDisciplined = [];

//Error handling to pull information from Roughians hyAreYouRunning and LessDisciplined tables
try {
    $pdo = new PDO($dsn, $user, $pass, $options);

    $selectedTeamPos = $_GET['teamPos'] ?? null;

    if ($selectedTeamPos!== false && $selectedTeamPos !== null) {
        $queryRoughians = "SELECT * FROM Roughians WHERE TeamPos = :teamPos ORDER BY TeamPos";
        $queryWhyAreYouRunning = "SELECT * FROM WhyAreYouRunning WHERE TeamPos = :teamPos ORDER BY TeamPos";
        $queryLessDisciplined = "SELECT * FROM LessDisciplined WHERE TeamPos = :teamPos ORDER BY TeamPos";

        $stmt = $pdo->prepare($queryRoughians);
        $stmt->execute(['teamPos' => $selectedTeamPos]);
        $roughians = $stmt->fetchAll();

        $stmt = $pdo->prepare($queryWhyAreYouRunning);
        $stmt->execute(['teamPos' => $selectedTeamPos]);
        $whyAreYouRunning = $stmt->fetchAll();

        $stmt = $pdo->prepare($queryLessDisciplined);
        $stmt->execute(['teamPos' => $selectedTeamPos]);
        $lessDisciplined = $stmt->fetchAll();
    }
    else {
        echo "Please enter a valid team position.";
    }

    $sql = "SELECT
                g.PlayerName AS Player,
                g.TeamName AS Team,
                COALESCE(SUM(g.Fouls), 0) AS TotalFouls,
                COALESCE(SUM(l.YellowCards), 0) AS TotalYellowCards
            FROM
                Roughians g
            LEFT JOIN
                LessDisciplined l ON g.PlayerName = l.PlayerName AND g.TeamName = l.TeamName
            GROUP BY
                g.PlayerName, g.TeamName
            ORDER BY
                TotalFouls DESC, TotalYellowCards ASC";
    
    $stmt = $pdo->query($sql);
    $combinedResults = $stmt->fetchAll();

} catch (PDOException $e) {
    error_log($e->getMessage());
    echo "An error occurred while connecting to the database: " . $e->getMessage();
    exit;
}
?>


<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Football Offenders Overview</title>
    <link rel="stylesheet" href="ravindran.css">
</head>
<body>
<div class="header">
    <h1>2023 Premier League Offenders Overview</h1>
</div>

<nav>
    <form action="" method="get">
        <button type="submit" formaction="index.php" class="nav-button">Home</button>
        <button type="submit" formaction="topPerformers.php" class="nav-button">Top Performers</button>
        <button type="submit" formaction="LastLiners.php" class="nav-button">Last Liners</button>
    </form>
</nav>

<form method="GET">
    <label for="teamPos">Enter Team Position:</label>
    <input type="number" id="teamPos" name="teamPos" value="<?= htmlspecialchars($_GET['teamPos'] ?? '') ?>">
    <button type="submit">Filter</button>
</form>

<?php if (!empty($teams)): ?>
    <table>
        <tr>
            <th>Player Name</th>
            <th>Team Name</th>
            <th>Team Position</th>
        </tr>
        <?php foreach ($teams as $team): ?>
        <tr>
            <td><?= htmlspecialchars($team['PlayerName']) ?></td>
            <td><?= htmlspecialchars($team['TeamName']) ?></td>
            <td><?= $team['TeamPos'] ?></td>
        </tr>
        <?php endforeach; ?>
    </table>
<?php endif; ?>

<section>
    <h2>Roughians</h2>
    <table>
        <tr>
            <th>Player Name</th>
            <th>Team Name</th>
            <th>Fouls</th>
            <th>Nationality</th>
            <th>Team Position</th>
        </tr>
        <?php foreach ($roughians as $player): ?>
        <tr>
            <td><?= htmlspecialchars($player['PlayerName']) ?></td>
            <td><?= htmlspecialchars($player['TeamName']) ?></td>
            <td><?= $player['Fouls'] ?></td>
            <td><?= htmlspecialchars($player['Nationality']) ?></td>
            <td><?= $player['TeamPos'] ?></td>
        </tr>
        <?php endforeach; ?>
    </table>
</section>

<section>
    <h2>Why Are You Running</h2>
    <table>
        <tr>
            <th>Player Name</th>
            <th>Team Name</th>
            <th>Offsides</th>
            <th>Nationality</th>
            <th>Team Position</th>
        </tr>
        <?php foreach ($whyAreYouRunning as $player): ?>
        <tr>
            <td><?= htmlspecialchars($player['PlayerName']) ?></td>
            <td><?= htmlspecialchars($player['TeamName']) ?></td>
            <td><?= $player['Offsides'] ?></td>
            <td><?= htmlspecialchars($player['Nationality']) ?></td>
            <td><?= $player['TeamPos'] ?></td>
        </tr>
        <?php endforeach; ?>
    </table>
</section>

<section>
    <h2>Less Disciplined</h2>
    <table>
        <tr>
            <th>Player Name</th>
            <th>Team Name</th>
            <th>Yellow Cards</th>
            <th>Nationality</th>
            <th>Team Position</th>
        </tr>
        <?php foreach ($lessDisciplined as $player): ?>
        <tr>
            <td><?= htmlspecialchars($player['PlayerName']) ?></td>
            <td><?= htmlspecialchars($player['TeamName']) ?></td>
            <td><?= $player['YellowCards'] ?></td>
            <td><?= htmlspecialchars($player['Nationality']) ?></td>
            <td><?= $player['TeamPos'] ?></td>
        </tr>
        <?php endforeach; ?>
    </table>
</section>

<section>
    <h2>Combined Offender Statistics</h2>
    <?php if (!empty($combinedResults)): ?>
        <table>
            <tr>
                <th>Player</th>
                <th>Team</th>
                <th>Total Fouls</th>
                <th>Total Yellow Cards</th>
            </tr>
            <?php foreach ($combinedResults as $result): ?>
            <tr>
                <td><?= htmlspecialchars($result['Player']) ?></td>
                <td><?= htmlspecialchars($result['Team']) ?></td>
                <td><?= $result['TotalFouls'] ?></td>
                <td><?= $result['TotalYellowCards'] ?></td>
            </tr>
            <?php endforeach; ?>
        </table>
    <?php else: ?>
        <p>No combined data found.</p>
    <?php endif; ?>
</section>

</body>
</html>
