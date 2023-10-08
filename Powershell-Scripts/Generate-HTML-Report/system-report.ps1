$webTemplate = "C:\Users\ingra\OneDrive\Documents\GitHub\powershell\System-Report\web-template.html"
$reportFile = "C:\Users\ingra\OneDrive\Documents\GitHub\powershell\System-Report\system-report-$(Get-Date -format "MM-dd-yyyy").html"

copy-item $webTemplate -destination $reportFile

$services = Get-Service | Sort-Object -Property DisplayName
$numRunningServices = Get-Service | Where-Object {$_.Status -eq "Running"}
$numStoppedServices = Get-Service | Where-Object {$_.Status -eq "Stopped"}

$processor = Get-ComputerInfo -Property CsProcessors
$memory = Get-ComputerInfo -Property CsTotalPhysicalMemory
[int64]$installedMemory = $memory.CsTotalPhysicalMemory

[int]$memoryInGigs = [int64]$installedMemory / 1024 / 1024 / 1024

$diskInfo = Get-Disk

$runningProccesses = Get-Process

$tableData = ""

$services | ForEach-Object {
    if($_.Status -eq "Stopped") {
        $tableData = $tableData + '<tr class="table-danger">'
        $tableData = $tableData + "<td>"
        $tableData = $tableData + $_.DisplayName
        $tableData = $tableData + "</td>"
        $tableData = $tableData + "<td>"
        $tableData = $tableData + $_.Status
        $tableData = $tableData + "</td>"
        $tableData = $tableData + "</tr>"
    } else {
        $tableData = $tableData + '<tr class="table-success">'
        $tableData = $tableData + "<td>"
        $tableData = $tableData + $_.DisplayName
        $tableData = $tableData + "</td>"
        $tableData = $tableData + "<td>"
        $tableData = $tableData + $_.Status
        $tableData = $tableData + "</td>"
        $tableData = $tableData + "</tr>"
    }
}

$diskData = ""

$diskInfo | ForEach-Object {

    $one_gb = 1024*1024*1024;
    $total_space = $_.AllocatedSize/$one_gb;
    $total_space = ([Math]::Round($total_space + 0.005, 0)) 
    $total_space = $total_space.ToString() + " GB"

    
    $diskData = $diskData + '<tr>'
    $diskData = $diskData + "<td>"
    $diskData = $diskData + $_.FriendlyName
    $diskData = $diskData + "</td>"
    $diskData = $diskData + "<td>"
    $diskData = $diskData + $_.HealthStatus
    $diskData = $diskData + "</td>"
    $diskData = $diskData + "<td>"
    $diskData = $diskData + $_.OperationalStatus
    $diskData = $diskData + "</td>"
    $diskData = $diskData + "<td>"
    $diskData = $diskData + $total_space
    $diskData = $diskData + "</td>"
    $diskData = $diskData + "</tr>"
}

(Get-Content -path $reportFile -Raw) | ForEach-Object {
    $_.replace( `
        '--date-ran--', "- $(Get-Date)").replace( `
        '--running-services--', $numRunningServices.Count).replace( `
        '--stopped-services--', $numStoppedServices.Count).replace( `
        '--num-cpu-cores--', $processor.CsProcessors.NumberOfCores).replace( `
        '--num-memory--', ([Math]::Round($memoryInGigs + 0.005, 0))).replace( `
        '--num-disks--', $diskInfo.Count).replace( `
        '--running-proccesses--', $runningProccesses.Count).replace( `
        '--table-data--', $tableData).replace( `
        '--disk-table-data--', $diskData `
    )
 } | Set-Content -Path $reportFile

# ((Get-Content -path $reportFile -Raw) -replace '--date-ran--', "- $(Get-Date)") | Set-Content -Path $reportFile

# ((Get-Content -path $reportFile -Raw) -replace '--running-services--', $numRunningServices.Count) | Set-Content -Path $reportFile
# ((Get-Content -path $reportFile -Raw) -replace '--stopped-services--', $numStoppedServices.Count) | Set-Content -Path $reportFile

# ((Get-Content -path $reportFile -Raw) -replace '--num-cpu-cores--', $processor.CsProcessors.NumberOfCores) | Set-Content -Path $reportFile

# ((Get-Content -path $reportFile -Raw) -replace '--num-memory--', ([Math]::Round($memoryInGigs + 0.005, 0))) | Set-Content -Path $reportFile

# ((Get-Content -path $reportFile -Raw) -replace '--num-disks--', $diskInfo.Count) | Set-Content -Path $reportFile

# ((Get-Content -path $reportFile -Raw) -replace '--running-proccesses--', $runningProccesses.Count) | Set-Content -Path $reportFile

# ((Get-Content -path $reportFile -Raw) -replace '--table-data--', $tableData) | Set-Content -Path $reportFile

# ((Get-Content -path $reportFile -Raw) -replace '--disk-table-data--', $diskData) | Set-Content -Path $reportFile

Write-Host "Reporte generated." -ForegroundColor Green