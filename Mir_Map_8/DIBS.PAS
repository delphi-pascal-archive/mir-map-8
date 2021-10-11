unit DIBS;

{
 256 colors DIB (c)1999 by Paul TOTH
 <tothpaul@multimania.com>
 http://www.multimania.com/tothpaul
}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;
type
  TPAL256=packed record
   Version:word;
   Entries:word;
   Colors:array[0..255] of TColor;
  end;

 { Replace the TBitmapInfo for dib_pal_colors on StretchDiBits API }
  TPalBitmapInfo=record
   Header:TBitmapInfoHeader;
   Colors:Array[0..255] of Word;
  end;

  TDIB256 = class(TComponent)
  private
   fWidth:integer;
   fHeight:integer;
   fMaxY:integer;
   fLineSize:integer;
   fDIBSize:integer;
   fDIB:PChar;
   fPalette:TPAL256;
   fHPalette:THandle;
   fBitmapInfo:TPalBitmapInfo;
   procedure SetWidth(Value:integer);
   procedure SetHeight(Value:integer);
   function GetColor(index:integer):TColor;
   procedure SetColor(index:integer; AColor:TColor);
  protected
   procedure Loaded; override;
  public
   constructor Create(AOwner:TComponent); override;
   destructor Destroy; override;
   procedure CreateDIB;
   function GetPixel(x,y:integer):byte;
   procedure SetPixel(x,y:integer;color:byte);
   procedure PutPixel(x,y:integer;color:byte);
   procedure Line(x1,y1,x2,y2,color:integer);
   procedure Ellipse(x1,y1,x2,y2,color:integer);
   procedure Draw(DC:HDC);
   procedure DrawXY(DC:HDC;x,y:integer);
   procedure StretchDraw(DC:HDC;AWidth,AHeight:integer);
   procedure UpdateColors;
   property Color[index:integer]:TColor read GetColor write SetColor;
   property Pixel[x,y:integer]:byte read GetPixel write SetPixel;
   property HPalette:THandle read fHPalette;
  published
   property Width:integer read fWidth write SetWidth default 320;
   property Height:integer read fHeight write SetHeight default 200;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('MySoft', [TDIB256]);
end;

Constructor TDIB256.Create(AOwner:TComponent);
 var
  i:integer;
 begin
  inherited Create(AOwner);
  fPalette.Version:=$300;
  fPalette.Entries:=256;
  GetSystemPaletteEntries(GetDC(0),0,256,fPalette.Colors);
  fHPalette:=CreatePalette(PLogPalette(@fPalette)^);
  fWidth:=320;
  fHeight:=200;
  fMaxY:=199;
  With fBitmapInfo do begin
   With Header do begin
    bisize:=SizeOf(TBitmapInfoHeader);
    biWidth:=fWidth;
    biHeight:=fHeight;
    biplanes:=1;
    bibitcount:=8; { for 256 colors only }
    bicompression:=BI_RGB;
    bisizeimage:=0;
    bixpelspermeter:=0;
    biypelspermeter:=0;
    biclrused:=256;
    biclrimportant:=0;
   end;
   For i:=0 to 255 do Colors[i]:=i; { cause we're using a dib_pal_colors }
  end;
  fDIB:=nil;
 end;

Destructor TDIB256.Destroy;
 begin
  DeleteObject(fHPalette);
  if fDIB<>nil then FreeMem(fDIB);
  inherited Destroy;
 end;

Procedure TDIB256.Loaded;
 begin
  inherited Loaded;
  CreateDIB;
 end;

Procedure TDIB256.CreateDIB;
 begin
  if fDIB<>nil then FreeMem(fDIB);
  if (fWidth=0)or(fHeight=0) then
   fDIB:=nil
  else begin
   fLineSize:=(fWidth+3) and $FFFC;
   fDIBSize:=fHeight*fLineSize;
   GetMem(fDIB,fDIBSize);
   FillChar(fDIB^,fDIBSize,0);
  end;
 end;

Procedure TDIB256.SetWidth(Value:integer);
 begin
  if Value<>fWidth then begin
   fWidth:=Value;
   fBitmapInfo.Header.biWidth:=fWidth;
   if not (csLoading in componentState) then CreateDIB;
  end;
 end;

Procedure TDIB256.SetHeight(Value:integer);
 begin
  if Value<>fHeight then begin
   fHeight:=Value;
   fMaxY:=fHeight-1;
   fBitmapInfo.Header.biHeight:=fHeight;
   if not (csLoading in componentState) then CreateDIB;
  end;
 end;

Function TDIB256.GetColor(Index:integer):TColor;
 begin
  Result:=fPalette.Colors[Index];
 end;

Procedure TDIB256.SetColor(Index:integer; AColor:TColor);
 begin
  fPalette.Colors[index]:=(AColor and $FFFFFF) or PC_NOCOLLAPSE;
 end;

Procedure TDIB256.UpdateColors;
 begin
  SetPaletteEntries(HPalette,0,256,fPalette.Colors);
 end;

procedure TDIB256.SetPixel(x,y:integer;color:byte);
 begin
  if (y>=0)and(y<fHeight)and(x>=0)and(x<fWidth) then
   fDIB[(fMaxY-y)*fWidth+x]:=chr(color);
 end;

procedure TDIB256.PutPixel(x,y:integer;color:byte);
 begin
  fDIB[(fMaxY-y)*fWidth+x]:=chr(color);
 end;

function TDIB256.GetPixel(x,y:integer):byte;
 begin
  if (y>=0)and(y<fHeight)and(x>=0)and(x<fWidth) then
   result:=ord(fDIB[(fMaxY-y)*fWidth+x])
  else
   result:=255;
 end;

procedure TDIB256.Line(x1,y1,x2,y2,color:integer);
 var
  dx,dy,iy:integer;
  f1,f2,f3:integer;
  i:integer;
 begin
  dx:=x2-x1;
  dy:=y2-y1;
  if dx<0 then begin
   dx:=-dx;
   dy:=-dy;
   x1:=x2;
   y1:=y2;
  end;
  if dy<0 then begin dy:=-dy; iy:=-1 end else iy:=+1;
  if dx>dy then begin
   f1:=2*dy;
   f2:=f1-dx;
   f3:=f2-dx;
   for i:=0 to dx do begin
    SetPixel(x1,y1,color);
    inc(x1);
    if f2<f1 then inc(f2,f1) else begin
     inc(f2,f3);
     inc(y1,iy);
    end;
   end;
  end else begin
   f1:=2*dx;
   f2:=f1-dy;
   f3:=f2-dy;
   for i:=0 to dy do begin
    SetPixel(x1,y1,color);
    inc(y1,iy);
    if f2<f1 then inc(f2,f1) else begin
     inc(f2,f3);
     inc(x1);
    end;
   end;
  end;
 end;

procedure TDIB256.Ellipse(x1,y1,x2,y2,color:integer);
 var
  r1,r2,cx,cy:integer;
  a:integer;
  lx,ly:integer;
  ax,ay:integer;
 begin
  r1:=(x2-x1) div 2; cx:=x1+r1;
  r2:=(y2-y1) div 2; cy:=y1+r2;
  lx:=r1;
  ly:=0;
  for a:=1 to 8 do begin { 90° }
   ax:=round(r1*cos(a*PI/16));
   ay:=round(r2*sin(a*PI/16));
   line(cx+lx,cy+ly,cx+ax,cy+ay,color);
   line(cx-lx,cy+ly,cx-ax,cy+ay,color);
   line(cx+lx,cy-ly,cx+ax,cy-ay,color);
   line(cx-lx,cy-ly,cx-ax,cy-ay,color);
   lx:=ax;
   ly:=ay;
  end;

 end;

procedure TDIB256.Draw(DC:HDC);
 begin
  SelectPalette(DC,fHPalette,FALSE);
  RealizePalette(DC);
  SetDiBitsToDevice(DC,0,0,fWidth,fHeight,0,0,0,fHeight,fDIB,PBitmapInfo(@fBitmapInfo)^,dib_pal_colors)
 end;

procedure TDIB256.DrawXY(DC:HDC;x,y:integer);
 begin
  SelectPalette(DC,fHPalette,FALSE);
  RealizePalette(DC);
  SetDiBitsToDevice(DC,x,y,fWidth,fHeight,0,0,0,fHeight,fDIB,PBitmapInfo(@fBitmapInfo)^,dib_pal_colors)
 end;

procedure TDIB256.StretchDraw(DC:HDC;AWidth,AHeight:integer);
 begin
  SelectPalette(DC,fHPalette,FALSE);
  RealizePalette(DC);
  StretchDIBits(DC,0,0,AWidth,AHeight,0,0,fWidth,fHeight,fDIB,PBitmapInfo(@fBitmapInfo)^,dib_pal_colors,SRCCOPY);
 end;

end.
