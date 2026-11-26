# Deterministic bitmap-font atlases and lime stat icons for the minimal face.
# Original club media is never modified. Font files retain their OFL license.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.IO;
using System.Text;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Text;
public static class MinimalAssets {
 public static void FontAtlas(string fontFile,string folder,string name,int em,bool outline,string chars) {
  using(var fonts=new PrivateFontCollection()) {
   fonts.AddFontFile(fontFile); var family=fonts.Families[0];
   using(var all=new GraphicsPath()) {
    all.AddString(chars,family,0,em,new PointF(0,0),StringFormat.GenericTypographic);
    var bounds=all.GetBounds(); int pad=Math.Max(2,(int)Math.Ceiling(em/70.0));
    int h=(int)Math.Ceiling(bounds.Height)+2*pad, maxW=0;
    foreach(char c in chars) {if(c==' ')continue;using(var path=new GraphicsPath()){path.AddString(c.ToString(),family,0,em,new PointF(),StringFormat.GenericTypographic);maxW=Math.Max(maxW,(int)Math.Ceiling(path.GetBounds().Width));}}
    int cell=maxW+2*pad+2, cols=16, rows=(chars.Length+cols-1)/cols;
    using(var bmp=new Bitmap(cell*cols,h*rows)) using(var g=Graphics.FromImage(bmp)) {
     g.Clear(Color.Transparent);g.SmoothingMode=SmoothingMode.None;g.PixelOffsetMode=PixelOffsetMode.Half;
     var f=new StringBuilder();
     f.AppendLine("info face=\"Barlow Condensed\" size="+em+" bold=1 italic=0 charset=\"\" unicode=1 stretchH=100 smooth=0 aa=1 padding=0,0,0,0 spacing=0,0");
     f.AppendLine("common lineHeight="+h+" base="+(h-pad)+" scaleW="+bmp.Width+" scaleH="+bmp.Height+" pages=1 packed=0");
     f.AppendLine("page id=0 file=\""+name+".png\"");f.AppendLine("chars count="+chars.Length);
     for(int i=0;i<chars.Length;i++) {
      char c=chars[i];int x=(i%cols)*cell,y=(i/cols)*h,advance;
      using(var path=new GraphicsPath()) {
       if(c!=' ')path.AddString(c.ToString(),family,0,em,new PointF(),StringFormat.GenericTypographic);
       var b=path.GetBounds();advance=c==' '?Math.Max(3,em/5):(int)Math.Ceiling(b.Width)+2*pad;
       if(name.StartsWith("Time") && c!=':')advance=cell-2;
       if(!name.StartsWith("Time") && c!=' ')advance=(int)Math.Ceiling(b.Width)+Math.Max(1,(int)Math.Round(em/18.0));
       if(c!=' ') {
        using(var m=new Matrix()) {m.Translate(x+pad-b.X+(advance-2*pad-b.Width)/2,y+pad-bounds.Y);path.Transform(m);}
        if(outline) {using(var pen=new Pen(Color.White,Math.Max(1.5f,em/48f))){pen.LineJoin=LineJoin.Round;g.DrawPath(pen,path);}}
        else g.FillPath(Brushes.White,path);
       }
       f.AppendLine("char id="+(int)c+" x="+x+" y="+y+" width="+advance+" height="+h+" xoffset=0 yoffset=0 xadvance="+advance+" page=0 chnl=15");
      }
     }
     Directory.CreateDirectory(folder);bmp.Save(Path.Combine(folder,name+".png"),System.Drawing.Imaging.ImageFormat.Png);
     File.WriteAllText(Path.Combine(folder,name+".fnt"),f.ToString(),new UTF8Encoding(false));
    }
   }
  }
 }
 public static void Icon(string file,int size,string kind) {
  var lime=Color.FromArgb(204,255,0);
  using(var bmp=new Bitmap(size,size))using(var g=Graphics.FromImage(bmp))using(var b=new SolidBrush(lime))using(var p=new Pen(lime,3.4f)) {
   g.Clear(Color.Transparent);g.ScaleTransform(size/32f,size/32f);g.SmoothingMode=SmoothingMode.None;
   p.StartCap=LineCap.Round;p.EndCap=LineCap.Round;p.LineJoin=LineJoin.Round;
   if(kind=="heart") {
    using(var path=new GraphicsPath()){path.AddBezier(16,29,4,20,0,13,5,6);path.AddBezier(5,6,9,2,13,4,16,9);path.AddBezier(16,9,19,4,23,2,27,6);path.AddBezier(27,6,32,13,28,20,16,29);g.FillPath(b,path);}
   } else if(kind=="flame") {
    using(var path=new GraphicsPath()){path.AddBezier(16,1,19,9,27,12,26,21);path.AddBezier(26,21,26,27,21,31,16,31);path.AddBezier(16,31,11,31,6,27,6,21);path.AddBezier(6,21,6,16,10,14,12,9);path.AddBezier(12,9,14,12,14,15,16,16);path.AddBezier(16,16,18,11,17,6,16,1);g.FillPath(b,path);}
   } else if(kind=="temp") {
    using(var w=new Pen(lime,6f)){w.StartCap=LineCap.Round;w.EndCap=LineCap.Round;g.DrawLine(w,16,5,16,20);}
    g.FillEllipse(b,9,17,14,14);
   } else if(kind=="run") {
    g.FillEllipse(b,18,1,7,7);
    g.DrawLine(p,19,11,14,19);
    g.DrawLines(p,new[]{new PointF(14,19),new PointF(9,24),new PointF(4,24)});
    g.DrawLines(p,new[]{new PointF(14,19),new PointF(20,24),new PointF(18,30)});
    g.DrawLines(p,new[]{new PointF(18,12),new PointF(23,16),new PointF(28,13)});
    g.DrawLines(p,new[]{new PointF(18,11),new PointF(12,12),new PointF(8,17)});
   } else {
    g.FillEllipse(b,4,3,9,15);g.FillEllipse(b,5,19,7,6);
    g.FillEllipse(b,19,8,9,15);g.FillEllipse(b,20,24,7,6);
   }
   bmp.Save(file,System.Drawing.Imaging.ImageFormat.Png);
  }
 }
}
'@
$root = Split-Path $PSScriptRoot -Parent
$uiCharacters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .:-/%K' + [char]0xB0
$uiCharacters = -join ($uiCharacters.ToCharArray() | Select-Object -Unique)
# The 970 shares the 965's 454-pixel resources.
foreach ($target in @(@{Id='fr55';Size=208},@{Id='fr165';Size=390},@{Id='fr255';Size=260},@{Id='fr255sm';Size=218},@{Id='fr265';Size=416},@{Id='fr965';Size=454})) {
    $folder = Join-Path $root ('resources-' + $target.Id)
    $fonts = Join-Path $folder 'fonts'
    $drawables = Join-Path $folder 'drawables'
    New-Item -ItemType Directory -Force -Path $fonts,$drawables | Out-Null
    $scale = $target.Size/454.0
    foreach ($spec in @(
        @{Name='TimeFilled';Weight='ExtraBold';Em=120;Outline=$false;Chars='0123456789:'},
        @{Name='TimeCompact';Weight='ExtraBold';Em=88;Outline=$false;Chars='0123456789:'},
        @{Name='TimeSeconds';Weight='Bold';Em=44;Outline=$false;Chars='0123456789'},
        @{Name='SleepTime';Weight='Bold';Em=40;Outline=$false;Chars='0123456789:'},
        @{Name='SleepDate';Weight='Medium';Em=26;Outline=$false;Chars=$uiCharacters},
        @{Name='UiSemiBold';Weight='SemiBold';Em=26;Outline=$false;Chars=$uiCharacters},
        @{Name='UiBold';Weight='Bold';Em=34;Outline=$false;Chars=$uiCharacters},
        @{Name='UiLabel';Weight='Medium';Em=19;Outline=$false;Chars=$uiCharacters}
    )) {
        [MinimalAssets]::FontAtlas((Join-Path $root ('media\fonts\BarlowCondensed-'+$spec.Weight+'.ttf')),$fonts,$spec.Name,[int][Math]::Round($spec.Em*$scale),$spec.Outline,$spec.Chars)
    }
    $fontXml = '<fonts>' + ((@('TimeFilled','TimeCompact','TimeSeconds','SleepTime','SleepDate','UiSemiBold','UiBold','UiLabel') | ForEach-Object { '<font id="'+$_+'" filename="'+$_+'.fnt"/>' }) -join '') + '</fonts>'
    [System.IO.File]::WriteAllText((Join-Path $fonts 'fonts.xml'),$fontXml,(New-Object System.Text.UTF8Encoding $false))
    foreach ($kind in @('heart','flame','temp','run','steps')) {
        [MinimalAssets]::Icon((Join-Path $drawables ('icon-'+$kind+'.png')),[Math]::Max(12,[int][Math]::Round(24*$scale)),$kind)
    }
    $icons = (@('heart','flame','temp','run','steps') | ForEach-Object { '    <bitmap id="Icon'+(Get-Culture).TextInfo.ToTitleCase($_)+'" filename="icon-'+$_+'.png"/>' }) -join "`n"
    $launcher = if (Test-Path -LiteralPath (Join-Path $drawables 'launcher.png')) { "    <bitmap id=`"LauncherIcon`" filename=`"launcher.png`"/>`n" } else { '' }
    [System.IO.File]::WriteAllText((Join-Path $drawables 'drawables.xml'),"<drawables>`n"+$launcher+$icons+"`n</drawables>`n",(New-Object System.Text.UTF8Encoding $false))
    Write-Output ('Generated design resources for '+$target.Id)
}
