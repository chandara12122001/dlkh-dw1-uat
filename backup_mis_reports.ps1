Add-Type -AssemblyName "System.IO.Compression.Filesystem"

Get-Content ".env" | ForEach-Object {
    if ($_ -match "^\s*([^#][^=]*)\s*=\s*(.*)\s*$") {
        [System.Environment]::SetEnvironmentVariable($matches[1], $matches[2])
    }
}

$dataSource = $env:SQLSERVER_URL
$user = $env:SQLSERVER_USER
$pass = $env:SQLSERVER_PWD
$database = $env:REPORT_DB
$connectionString = "Server=$dataSource;uid=$user; pwd=$pass;Database=$database;Integrated Security=False;"

$tempfolder = "$env:TEMP\Reports"
$zipfile = $PSScriptRoot + '\reports.zip'

$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString

$connection.Open()

$allreports = $connection.CreateCommand()
$allreports.CommandText = "SELECT ItemID, Path, CASE WHEN Type = 2 THEN '.rdl' ELSE '.rds' END AS Ext FROM Catalog WHERE Type IN(2,5)"

$result = $allreports.ExecuteReader()

$reportable = new-object "System.Data.DataTable"
$reportable.Load($result)
[int]$objects = $reportable.Rows.Count
foreach ($report in $reportable) {
    $cmd = $connection.CreateCommand()
    $cmd.CommandText = "SELECT CAST(CAST(Content AS VARBINARY(MAX)) AS XML) FROM Catalog WHERE ItemID = '" + $report[0] + "'"
    $xmldata = [string]$cmd.ExecuteScalar()
    $filename = $tempfolder + $report["Path"].Replace('/', '\') + $report["Ext"]
    New-Item $filename -Force | Out-Null
    Set-Content -Path ($filename) -Value $xmldata -Force
    Write-Host "$($objects.ToString()).$($report["Path"])"
    $objects -= 1
}

Write-Host "Compressing to zip file..."
if (Test-Path $zipfile) {
    Remove-Item $zipfile
}
[IO.Compression.Zipfile]::CreateFromDirectory($tempfolder, $zipfile) 

Write-Host "Removing temporarly data"
Remove-Item -LiteralPath $tempfolder -Force -Recurse

Invoke-Item $zipfile
