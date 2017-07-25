#region Archive Files using 7zip

[cmdletbinding()]
Param
(
    [Parameter(Mandatory = $true, HelpMessage = 'Path needs to be with trailing slash at the end of location.' )]
    [string]$SourceFilesPath
)
Import-Module "D:\Isango\Scripts\Invoke-Parallel.ps1" # Download from PSGallery

$7zip = 'C:\Program Files\7-Zip\7z.exe'

$fileToArchive = Get-ChildItem $SourceFilesPath -Force | Where-Object -FilterScript {
        $_.LastWriteTime -lt (Get-Date).AddDays(-1).ToShortDateString()
}
$counter = 0
$groupSize = 2000 # Will group items by 2,000 increments
$groups = $fileToArchive | Group-Object -Property {
    [math]::Floor($counter++ / $groupSize) 
}
$groups

# This will spawn multiple instances of 7zip - depending on how many groups of 2,000 files exist
$groups.Group | Invoke-Parallel -ScriptBlock {
    $FilePath = $null
    $fileName = $_
    $FilePath = Get-ItemProperty -Path $fileName.FullName
    $ZipFilePath = $fileName.Directory.ToString() + '\ZippedFiles' + '\Archive_' + $fileName.LastWriteTime.ToString('MMddyyyy') + '.7z'

    $tempPath = ('-w'+'C:\Temp')
    $OutputData = &$Using:7zip a $tempPath -t7z $ZipFilePath $FilePath
    $OutputData
    if ($OutputData -contains 'Everything is OK')
    {
        #Remove-Item $FilePath -Force
        Write-Output -InputObject "File removed $FilePath"
    }
    Get-Item $ZipFilePath | ForEach-Object -Process {
        $_.LastWriteTime = $fileName.LastWriteTime
    }
}