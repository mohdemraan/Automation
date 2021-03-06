[cmdletbinding()]
Param
(
[Parameter(Mandatory=$true, HelpMessage = "Path needs to be with trailing slash at the end of location." )]
[string]$SourceFilesPath
)

$7zip = "C:\Program Files\7-Zip\7z.exe"
$FilePath = ""

foreach ( $filename in $(Get-ChildItem $SourceFilesPath -Force -Recurse | where {$_.LastWriteTime -lt (get-date).AddDays(-1).ToShortDateString()}))
{
    $FilePath = Get-ItemProperty $filename.FullName
    $ZipFilePath = $filename.Directory.ToString() + "\ZippedFiles" + "\Archive_" + $filename.LastWriteTime.ToString("MMddyyyy") + ".7z"
    
    $tempPath = ("-w"+"C:\Temp")
    $OutputData = &$7zip a $tempPath -t7z $ZipFilePath $FilePath
    $OutputData
    if ($OutputData -contains "Everything is OK")
    {
        Remove-Item $FilePath -Force
        Write-Output "File removed $FilePath"
    }
    Get-Item $ZipFilePath | ForEach-Object {$_.LastWriteTime = $filename.LastWriteTime}
}