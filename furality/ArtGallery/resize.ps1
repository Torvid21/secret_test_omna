<#
.SYNOPSIS
    Down‑scale PNG images so the longest side is ≤ 512 pixels (aspect‑ratio kept).

.PARAMETER Path
    Folder containing PNGs.  Default = current directory.

.PARAMETER MaxSize
    Maximum width or height in pixels.  Default = 512.

.PARAMETER Recurse
    Process sub‑folders as well.

.NOTES
    • Requires Windows PowerShell 5 / PowerShell 7 with System.Drawing.Common  
    • Works in place: saves via temp file, then atomically replaces original.
#>

param(
    [string]$Path   = ".",
    [int]   $MaxSize = 512,
    [switch]$Recurse
)

Add-Type -AssemblyName System.Drawing

$opts = @{}
if ($Recurse) { $opts.Recurse = $true }

Get-ChildItem -Path $Path -Filter *.png -File @opts | ForEach-Object {
    $file = $_.FullName
    try {
        # Load, then clone immediately to free the source lock
        $src = [System.Drawing.Image]::FromFile($file)
        $img = New-Object System.Drawing.Bitmap $src
        $src.Dispose()

        # Skip if already within the size limit
        $longest = [Math]::Max($img.Width, $img.Height)
        if ($longest -le $MaxSize) {
            $img.Dispose()
            return
        }

        # Calculate new dimensions while preserving aspect ratio
        $scale      = $MaxSize / $longest
        $newWidth   = [int][Math]::Round($img.Width  * $scale)
        $newHeight  = [int][Math]::Round($img.Height * $scale)

        $bmp = New-Object System.Drawing.Bitmap $newWidth, $newHeight
        $g   = [System.Drawing.Graphics]::FromImage($bmp)

        $g.InterpolationMode  = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $g.SmoothingMode      = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality

        $g.DrawImage($img, 0, 0, $newWidth, $newHeight)

        # Clean up originals
        $g.Dispose()
        $img.Dispose()

        # Save to temp file first
        $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName() + ".png")
        $bmp.Save($tmp, [System.Drawing.Imaging.ImageFormat]::Png)
        $bmp.Dispose()

        # Preserve timestamps & handle read‑only
        $stamp = (Get-Item $file).LastWriteTime
        if ($_.IsReadOnly) { $_.IsReadOnly = $false }

        [System.IO.File]::Copy($tmp, $file, $true)
        Remove-Item $tmp -Force
        (Get-Item $file).LastWriteTime = $stamp

        Write-Host "Resized $($_.Name) → ${newWidth}×${newHeight}"
    }
    catch {
        Write-Warning "Failed to process $($_.Name): $_"
    }
}