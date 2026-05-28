$root = "c:\Users\intel\.gemini\antigravity\scratch\scholarship-finder"
$items = Get-ChildItem -Path $root -Recurse
foreach ($item in $items) {
    if ($item.Attributes -match "ReadOnly") {
        try {
            $item.Attributes = $item.Attributes -bxor [System.IO.FileAttributes]::ReadOnly
            Write-Output "Cleared: $($item.FullName)"
        } catch {
            Write-Warning "Failed: $($item.FullName)"
        }
    }
}
Write-Output "Done recursively clearing read-only attributes."
