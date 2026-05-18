$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$iosOut = Join-Path $root "native-ios\Resources"
$androidOut = Join-Path $root "android\app\src\main\res\drawable-nodpi"
New-Item -ItemType Directory -Force -Path $iosOut, $androidOut | Out-Null

Add-Type -AssemblyName System.Drawing

function New-Brush($hex) {
  return New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml($hex))
}

function New-Pen($hex, $width) {
  $pen = New-Object System.Drawing.Pen([System.Drawing.ColorTranslator]::FromHtml($hex), $width)
  $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
  $pen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
  return $pen
}

function Fill-RoundRect($g, $brush, $x, $y, $w, $h, $r) {
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $path.AddArc($x, $y, $r, $r, 180, 90)
  $path.AddArc($x + $w - $r, $y, $r, $r, 270, 90)
  $path.AddArc($x + $w - $r, $y + $h - $r, $r, $r, 0, 90)
  $path.AddArc($x, $y + $h - $r, $r, $r, 90, 90)
  $path.CloseFigure()
  $g.FillPath($brush, $path)
  $path.Dispose()
}

function Draw-CenteredText($g, $text, $size, $color, $yOffset = 0) {
  $font = New-Object System.Drawing.Font("Segoe UI Symbol", $size, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
  $brush = New-Brush $color
  $format = New-Object System.Drawing.StringFormat
  $format.Alignment = [System.Drawing.StringAlignment]::Center
  $format.LineAlignment = [System.Drawing.StringAlignment]::Center
  $rect = New-Object System.Drawing.RectangleF(0, $yOffset, 256, 256)
  $g.DrawString($text, $font, $brush, $rect, $format)
  $format.Dispose()
  $brush.Dispose()
  $font.Dispose()
}

function Draw-Icon($name, $bg, $accent, $kind) {
  $bmp = New-Object System.Drawing.Bitmap(256, 256)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.Clear([System.Drawing.Color]::Transparent)
  Fill-RoundRect $g (New-Brush $bg) 10 10 236 236 46

  $white = "#FFFDF4"
  $soft = New-Brush "#FFFFFF"
  $pen = New-Pen $white 14
  $accentBrush = New-Brush $accent

  switch ($kind) {
    "milk" {
      Fill-RoundRect $g $soft 88 64 80 132 18
      $g.FillRectangle($accentBrush, 102, 48, 52, 34)
      Fill-RoundRect $g (New-Brush $accent) 108 116 40 52 10
      Draw-CenteredText $g "*" 38 $white 6
    }
    "bread" {
      $g.FillEllipse($soft, 58, 82, 140, 92)
      $g.FillEllipse($accentBrush, 78, 92, 102, 70)
      $g.DrawArc($pen, 82, 98, 92, 50, 195, 120)
    }
    "eggs" {
      $g.FillEllipse($soft, 62, 72, 64, 104)
      $g.FillEllipse($soft, 130, 72, 64, 104)
      $g.FillEllipse($accentBrush, 78, 110, 32, 44)
      $g.FillEllipse($accentBrush, 146, 110, 32, 44)
    }
    "tomato" {
      $g.FillEllipse($accentBrush, 58, 74, 140, 122)
      $g.DrawLine((New-Pen $white 10), 128, 78, 128, 48)
      $g.DrawLine((New-Pen $white 10), 128, 78, 100, 60)
      $g.DrawLine((New-Pen $white 10), 128, 78, 156, 60)
      $g.DrawEllipse($pen, 86, 98, 84, 72)
    }
    "banana" {
      $bananaPen = New-Pen $white 30
      $g.DrawArc($bananaPen, 54, 58, 150, 136, 36, 128)
      $g.DrawArc((New-Pen $accent 14), 72, 76, 120, 104, 36, 128)
    }
    "apple" {
      $g.FillEllipse($accentBrush, 66, 76, 124, 116)
      $g.DrawLine((New-Pen $white 10), 128, 82, 146, 54)
      $g.DrawArc($pen, 92, 104, 72, 58, 20, 220)
    }
    "detergent" {
      Fill-RoundRect $g $soft 76 76 104 120 20
      $g.FillRectangle($accentBrush, 96, 52, 64, 36)
      Fill-RoundRect $g (New-Brush $accent) 98 122 60 46 12
      $g.DrawEllipse($pen, 108, 96, 40, 28)
    }
    "paper" {
      $g.FillEllipse($soft, 70, 72, 116, 116)
      $g.FillEllipse($accentBrush, 100, 100, 56, 56)
      $g.FillRectangle($soft, 128, 126, 58, 70)
    }
    "oil" {
      Fill-RoundRect $g $soft 86 66 84 132 18
      $g.FillRectangle($accentBrush, 104, 42, 48, 38)
      $g.DrawEllipse($pen, 106, 110, 44, 54)
    }
    "basket" {
      $g.DrawArc($pen, 84, 52, 88, 78, 200, 140)
      Fill-RoundRect $g $accentBrush 58 98 140 84 20
      $g.DrawLine((New-Pen $white 10), 76, 116, 180, 116)
      $g.DrawLine((New-Pen $white 10), 90, 100, 104, 180)
      $g.DrawLine((New-Pen $white 10), 166, 100, 152, 180)
    }
    "breakfast" {
      $g.FillEllipse($accentBrush, 70, 116, 116, 52)
      $g.DrawLine($pen, 82, 170, 174, 170)
      $g.DrawArc($pen, 92, 72, 72, 58, 10, 160)
      $g.DrawLine($pen, 176, 92, 194, 62)
    }
    "cleaning" {
      Fill-RoundRect $g $soft 88 92 84 106 20
      $g.FillRectangle($accentBrush, 100, 66, 58, 42)
      $g.DrawLine((New-Pen $white 12), 132, 62, 184, 44)
      $g.DrawLine((New-Pen $white 9), 82, 112, 54, 102)
    }
    "dinner" {
      $g.FillEllipse($accentBrush, 62, 102, 132, 72)
      $g.DrawArc($pen, 82, 76, 92, 72, 200, 140)
      $g.DrawLine($pen, 64, 178, 192, 178)
      $g.FillEllipse($soft, 120, 58, 16, 16)
    }
    "group" {
      $g.FillEllipse($accentBrush, 104, 48, 48, 48)
      $g.FillEllipse($accentBrush, 58, 70, 42, 42)
      $g.FillEllipse($accentBrush, 156, 70, 42, 42)
      Fill-RoundRect $g $accentBrush 76 112 104 74 28
      Fill-RoundRect $g (New-Brush $white) 42 130 56 44 18
      Fill-RoundRect $g (New-Brush $white) 158 130 56 44 18
    }
    "cart" {
      $g.DrawLine($pen, 58, 70, 82, 70)
      $g.DrawLine($pen, 82, 70, 104, 154)
      $g.DrawLine($pen, 104, 154, 184, 154)
      $g.DrawLine($pen, 96, 98, 194, 98)
      $g.DrawLine($pen, 194, 98, 176, 138)
      $g.FillEllipse($accentBrush, 104, 174, 24, 24)
      $g.FillEllipse($accentBrush, 166, 174, 24, 24)
    }
    default {
      Draw-CenteredText $g "+" 120 $white -6
    }
  }

  $iosPath = Join-Path $iosOut "$name.png"
  $androidPath = Join-Path $androidOut "$name.png"
  $bmp.Save($iosPath, [System.Drawing.Imaging.ImageFormat]::Png)
  $bmp.Save($androidPath, [System.Drawing.Imaging.ImageFormat]::Png)
  $pen.Dispose()
  $soft.Dispose()
  $accentBrush.Dispose()
  $g.Dispose()
  $bmp.Dispose()
}

$assets = @(
  @("product_milk", "#4D92D9", "#2F70B9", "milk"),
  @("product_bread", "#F2A339", "#D87C25", "bread"),
  @("product_eggs", "#F4C542", "#DE9F22", "eggs"),
  @("product_tomato", "#F05A4A", "#D83A31", "tomato"),
  @("product_banana", "#F0C33C", "#D6A41E", "banana"),
  @("product_apple", "#95B74B", "#6F9636", "apple"),
  @("product_detergent", "#62BDA6", "#3E947F", "detergent"),
  @("product_paper", "#A386CF", "#7355A7", "paper"),
  @("product_oil", "#D7A72F", "#A97818", "oil"),
  @("product_default", "#324139", "#23C16B", "default"),
  @("preset_weekly", "#4C9440", "#2E6F2C", "basket"),
  @("preset_breakfast", "#F2BE3F", "#DA9825", "breakfast"),
  @("preset_cleaning", "#63C7AF", "#3A9D88", "cleaning"),
  @("preset_dinner", "#F26E55", "#D64C3C", "dinner"),
  @("app_group", "#337E2F", "#23C16B", "group"),
  @("app_cart", "#1F6B32", "#23C16B", "cart")
)

foreach ($asset in $assets) {
  Draw-Icon $asset[0] $asset[1] $asset[2] $asset[3]
}

Write-Host "Generated $($assets.Count) shared PNG assets."
