# Configure directory for template file and report file
$webTemplate = "C:\temp\powershell\System-Report\web-template.html"
$reportFile = "C:\temp\powershell\System-Report\system-report-$(Get-Date -format "MM-dd-yyyy").html"

# Create report file.
copy-item $webTemplate -destination $reportFile

# Get services information
$services = Get-Service | Sort-Object -Property DisplayName
$numRunningServices = Get-Service | Where-Object {$_.Status -eq "Running"}
$numStoppedServices = Get-Service | Where-Object {$_.Status -eq "Stopped"}

# Get processor and memory information
$processor = Get-ComputerInfo -Property CsProcessors
$memory = Get-ComputerInfo -Property CsTotalPhysicalMemory
[int64]$installedMemory = $memory.CsTotalPhysicalMemory
[int]$memoryInGigs = [int64]$installedMemory / 1024 / 1024 / 1024

# Get disk information
$diskInfo = Get-Disk

# Get running processes information
$runningProccesses = Get-Process

# Create HTML table rows for services.
$tableData = ""
$services | ForEach-Object {
    if($_.Status -eq "Stopped") {
        $tableData += '<tr class="table-danger">'
        $tableData += "<td>"
        $tableData += $_.DisplayName
        $tableData += "</td>"
        $tableData += "<td>"
        $tableData += $_.Status
        $tableData += "</td>"
        $tableData += "</tr>"
    } else {
        $tableData += '<tr class="table-success">'
        $tableData += "<td>"
        $tableData += $_.DisplayName
        $tableData += "</td>"
        $tableData += "<td>"
        $tableData += $_.Status
        $tableData += "</td>"
        $tableData += "</tr>"
    }
}

# Create HTML table rows for disk data.
$diskData = ""

$diskInfo | ForEach-Object {

    $one_gb = 1024*1024*1024;
    $total_space = $_.AllocatedSize/$one_gb;
    $total_space = ([Math]::Round($total_space + 0.005, 0)) 
    $total_space = $total_space.ToString() + " GB"

    
    $diskData += '<tr>'
    $diskData += "<td>"
    $diskData += $_.FriendlyName
    $diskData += "</td>"
    $diskData += "<td>"
    $diskData += $_.HealthStatus
    $diskData += "</td>"
    $diskData += "<td>"
    $diskData += $_.OperationalStatus
    $diskData += "</td>"
    $diskData += "<td>"
    $diskData += $total_space
    $diskData += "</td>"
    $diskData += "</tr>"
}

# Write data to template file.
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

 # Notify that the report is ready.
Write-Host "Reporte generated." -ForegroundColor Green