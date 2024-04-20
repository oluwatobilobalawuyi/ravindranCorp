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

$goldenbootWinners = [];
$assistKings = [];
$premiumPlayers = [];
$noMinerals = [];

try {
    $pdo = new PDO($dsn, $user, $pass, $options);

    $selectedTeamPos = $_GET['teamPos'] ?? null;

    if ($selectedTeamPos) {
        // Fetch data from each table filtered by TeamPos
        $goldenbootWinners = $pdo->prepare("SELECT * FROM goldenboot_winners WHERE TeamPos = :teamPos ORDER BY GoalsScored DESC");
        $goldenbootWinners->execute(['teamPos' => $selectedTeamPos]);
        $goldenbootWinners = $goldenbootWinners->fetchAll();

        $assistKings = $pdo->prepare("SELECT * FROM assistKing WHERE TeamPos = :teamPos ORDER BY Assists DESC");
        $assistKings->execute(['teamPos' => $selectedTeamPos]);
        $assistKings = $assistKings->fetchAll();

        $noMinerals = $pdo->prepare("SELECT * FROM noMinerals WHERE TeamPos = :teamPos ORDER BY ChancesMissed DESC");
        $noMinerals->execute(['teamPos' => $selectedTeamPos]);
        $noMinerals = $noMinerals->fetchAll();
    }

//Premium players will show regardless and not specific data because it is a view
    $premiumPlayers = $pdo->query("SELECT * FROM premiumplayers ORDER BY Goals DESC, Assists DESC")->fetchAll();

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
    <title>Top Performers Overview</title>
    <link rel="stylesheet" href="ravindran.css">
</head>
<body>
<div class="header">
    <h1>Top Performers Overview</h1>
</div>

<nav>
    <form action="" method="get">
        <button type="submit" formaction="index.php" class="nav-button">Home</button>
        <button type="submit" formaction="offenders.php" class="nav-button">Offenders</button>
        <button type="submit" formaction="LastLiners.php" class="nav-button">Last Liners</button>
    </form>
</nav>

<form method="GET">
    <label for="teamPos">Enter Team Position:</label>
    <input type="number" id="teamPos" name="teamPos" value="<?= htmlspecialchars($_GET['teamPos'] ?? '') ?>">
    <button type="submit">Filter</button>
</form>

<!-- Premium Players Section -->
<section>
    <h2>Premium Players</h2>
    <table>
        <tr>
            <th>Player Name</th>
            <th>Team Name</th>
            <th>Goals</th>
            <th>Assists</th>
        </tr>
        <?php foreach ($premiumPlayers as $player): ?>
        <tr>
            <td><?= htmlspecialchars($player['PlayerName']) ?></td>
            <td><?= htmlspecialchars($player['TeamName']) ?></td>
            <td><?= $player['Goals'] ?></td>
            <td><?= $player['Assists'] ?></td>
        </tr>
        <?php endforeach; ?>
    </table>
</section>

<!-- Golden Boot Winners Section -->
<section>
    <h2>Golden Boot Winners</h2>
    <table>
        <tr>
            <th>Player Name</th>
            <th>Team Name</th>
            <th>Goals Scored</th>
            <th>Team Position</th>
        </tr>
        <?php foreach ($goldenbootWinners as $player): ?>
        <tr>
            <td><?= htmlspecialchars($player['PlayerName']) ?></td>
            <td><?= htmlspecialchars($player['TeamName']) ?></td>
            <td><?= $player['GoalsScored'] ?></td>
            <td><?= $player['TeamPos'] ?></td>
        </tr>
        <?php endforeach; ?>
    </table>
</section>

<!-- Assist Kings Section -->
<section>
    <h2>Assist Kings</h2>
    <table>
        <tr>
            <th>Player Name</th>
            <th>Team Name</th>
            <th>Assists</th>
            <th>Team Position</th>
        </tr>
        <?php foreach ($assistKings as $player): ?>
        <tr>
            <td><?= htmlspecialchars($player['PlayerName']) ?></td>
            <td><?= htmlspecialchars($player['TeamName']) ?></td>
            <td><?= $player['Assists'] ?></td>
            <td><?= $player['TeamPos'] ?></td>
        </tr>
        <?php endforeach; ?>
    </table>
</section>

<!-- No Minerals Section -->
<section>
    <h2>No Minerals</h2>
    <table>
        <tr>
            <th>Player Name</th>
            <th>Team Name</th>
            <th>Chances Missed</th>
            <th>Team Position</th>
        </tr>
        <?php foreach ($noMinerals as $player): ?>
        <tr>
            <td><?= htmlspecialchars($player['PlayerName']) ?></td>
            <td><?= htmlspecialchars($player['TeamName']) ?></td>
            <td><?= $player['ChancesMissed'] ?></td>
            <td><?= $player['TeamPos'] ?></td>
        </tr>
        <?php endforeach; ?>
    </table>
</section>

</body>
</html>
