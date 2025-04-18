<#
.SYNOPSIS
    Resize every PNG in a folder to 512×512 *in place* (with a temp‑file swap).

.EXAMPLE
    .\Resize-Pngs.ps1 -Path "C:\Images" -Recurse
#>

param(
    [string]$Path   = ".",
    [int]   $Size   = 512,
    [switch]$Recurse
)

Add-Type -AssemblyName System.Drawing

$opts = @{}
if ($Recurse) { $opts.Recurse = $true }

Get-ChildItem -Path $Path -Filter *.png -File @opts | ForEach-Object {
    $file = $_.FullName
    try {
        # Load and immediately clone to release the source lock
        $src = [System.Drawing.Image]::FromFile($file)
        $img = New-Object System.Drawing.Bitmap $src
        $src.Dispose()

        if ($img.Width -eq $Size -and $img.Height -eq $Size) {
            $img.Dispose()
            return
        }

        $bmp      = New-Object System.Drawing.Bitmap $Size, $Size
        $graphics = [System.Drawing.Graphics]::FromImage($bmp)

        $graphics.InterpolationMode  = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $graphics.SmoothingMode      = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality

        $graphics.DrawImage($img, 0, 0, $Size, $Size)
        $graphics.Dispose()
        $img.Dispose()

        # Save to a temp file first
        $tmp = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(),
                                         [System.IO.Path]::GetRandomFileName() + ".png")
        $bmp.Save($tmp, [System.Drawing.Imaging.ImageFormat]::Png)
        $bmp.Dispose()

        # Preserve LastWriteTime & handle read‑only
        $stamp = (Get-Item $file).LastWriteTime
        if ($_.IsReadOnly) { $_.IsReadOnly = $false }

        [System.IO.File]::Copy($tmp, $file, $true)
        Remove-Item $tmp -Force
        (Get-Item $file).LastWriteTime = $stamp

        Write-Host "Resized  $($_.Name)"
    }
    catch {
        Write-Warning "Failed to process $($_.Name): $_"
    }
}