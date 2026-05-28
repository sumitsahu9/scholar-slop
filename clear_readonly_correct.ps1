$root = "c:\Users\intel\.gemini\antigravity\scratch\scholarship-finder"
$items = Get-ChildItem -Path $root -Recurse -File
foreach ($item in $items) {
    if ($item.IsReadOnly) {
        try {
            $item.IsReadOnly = $false
            Write-Output "Cleared ReadOnly: $($item.FullName)"
        } catch {
            Write-Warning "Failed clearing ReadOnly: $($item.FullName)"
        }
    }
}
Write-Output "Done clearing read-only flags."
