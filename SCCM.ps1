# Script written by Saeid Esmaili on 11-02-2023
# SCCM Connection Parameters
$SCCMServer = "Must write SCCM server name"  # SCCM-server
$SCCMDB = "Must write database name"  # SCCM-databas

# Skapa en SQL-fråga för att hämta RAM och datorns modellinformation
$SQLQuery = @"
SELECT
    v_R_System.Name0 as ComputerName,
    v_GS_X86_PC_MEMORY.TotalPhysicalMemory0 as TotalRAM,
    v_GS_COMPUTER_SYSTEM.Model0 as ComputerModel,
    v_GS_OPERATING_SYSTEM.Caption0 as OperatingSystem,
    v_GS_OPERATING_SYSTEM.Version0 as OSVersion
FROM
    v_R_System
    INNER JOIN v_GS_X86_PC_MEMORY ON v_R_System.ResourceID = v_GS_X86_PC_MEMORY.ResourceID
    INNER JOIN v_GS_COMPUTER_SYSTEM ON v_R_System.ResourceID = v_GS_COMPUTER_SYSTEM.ResourceID
    INNER JOIN v_GS_OPERATING_SYSTEM ON v_R_System.ResourceID = v_GS_OPERATING_SYSTEM.ResourceID
"@

try {
    # Kör SQL-frågan mot SCCM:s databas
    $SqlConnection = New-Object System.Data.SqlClient.SqlConnection
    $SqlConnection.ConnectionString = "Server=$SCCMServer;Database=$SCCMDB;Integrated Security=True"
    $SqlConnection.Open()
    $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
    $SqlCmd.CommandText = $SQLQuery
    $SqlCmd.Connection = $SqlConnection
    $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
    $SqlAdapter.SelectCommand = $SqlCmd
    $DataSet = New-Object System.Data.DataSet
    $SqlAdapter.Fill($DataSet)
    $DataSet.Tables[0] | Format-Table -AutoSize

    # Formatera datan i en läsbar tabell
    $formattedData = $DataSet.Tables[0] | Format-Table -AutoSize | Out-String

    # Exportera formaterad data till en textfil
    $formattedData | Out-File -FilePath "C:\din_sokvag\SCCM_Data.txt"      # Update this path
} catch {
    Write-Host "Ett fel inträffade: $_"
} finally {
    if ($SqlConnection.State -eq 'Open') {
        $SqlConnection.Close()
    }
}