# Recursive Brand and Domain Replacement Script for Scholar Slop
# Uses native .NET APIs to avoid PowerShell provider dependencies and safely handle UTF-8 encodings.

$rootPath = "C:\Users\intel\.gemini\antigravity\scratch\scholarship-finder"
Write-Output "Starting brand replacement in $rootPath..."

$files = [System.IO.Directory]::GetFiles($rootPath, "*.html", [System.IO.SearchOption]::AllDirectories)
$count = 0

foreach ($file in $files) {
    # Skip the root index.html if it's already updated, or process it safely
    try {
        $content = [System.IO.File]::ReadAllText($file, [System.Text.Encoding]::UTF8)
        
        $newContent = $content
        # Replace case-sensitive and case-insensitive variations
        $newContent = $newContent.Replace("Scholarship Finder", "Scholar Slop")
        $newContent = $newContent.Replace("scholarship finder", "scholar slop")
        $newContent = $newContent.Replace("scholarshipfinder.org", "scholarslop.org")
        
        if ($content -ne $newContent) {
            # Clear read-only if set
            [System.IO.File]::SetAttributes($file, [System.IO.FileAttributes]::Normal)
            [System.IO.File]::WriteAllText($file, $newContent, [System.Text.Encoding]::UTF8)
            Write-Output "Successfully updated: $file"
            $count++
        }
    } catch {
        Write-Warning "Could not process file: $file. Error: $_"
    }
}

Write-Output "Completed brand replacement! Updated $count files."
