# Clears read-only attribute from all HTML, XML, and TXT files in the project
$root = "c:\Users\intel\.gemini\antigravity\scratch\scholarship-finder"
$files = Get-ChildItem -Path $root -Recurse -Include "*.html","*.xml","*.txt"
foreach ($f in $files) {
    if ($f.IsReadOnly) {
        $f.IsReadOnly = $false
        Write-Output "Cleared: $($f.FullName)"
    }
}
Write-Output "Done. $($files.Count) files checked."
