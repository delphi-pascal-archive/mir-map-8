unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,DIBS,maps,miconst, ComCtrls, ToolWin, ImgList, StdCtrls, ExtCtrls,
  geombs;

type
  TForm1 = class(TForm)
    ProgressBar1: TProgressBar;
    ToolBar1: TToolBar;
    ImageList1: TImageList;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    Timer1: TTimer;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Shape1: TShape;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    Shape2: TShape;
    Shape3: TShape;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    Shape4: TShape;
    Shape5: TShape;
    Shape6: TShape;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    UpDown1: TUpDown;
    ToolButton10: TToolButton;
    Label4: TLabel;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    Panel1: TPanel;
    Label5: TLabel;
    Label8: TLabel;
    ToolButton14: TToolButton;
    ToolButton15: TToolButton;
    Panel2: TPanel;
    ToolButton16: TToolButton;
    ToolButton17: TToolButton;
    ToolButton18: TToolButton;
    ToolButton19: TToolButton;
    ToolButton20: TToolButton;
    ToolButton21: TToolButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    ToolButton22: TToolButton;
    Panel3: TPanel;
    Label14: TLabel;
    Label15: TLabel;
    Button1: TButton;
    Button2: TButton;
    UpDown2: TUpDown;
    UpDown3: TUpDown;
    Label16: TLabel;
    Label17: TLabel;
    Label25: TLabel;
    Image11: TImage;
    Label9: TLabel;
    Image1: TImage;
    Label10: TLabel;
    Label13: TLabel;
    Image3: TImage;
    Label11: TLabel;
    Image2: TImage;
    Label12: TLabel;
    Image4: TImage;
    Image5: TImage;
    Label18: TLabel;
    Image6: TImage;
    Label19: TLabel;
    Image7: TImage;
    Label20: TLabel;
    Image8: TImage;
    Label21: TLabel;
    Image9: TImage;
    Label22: TLabel;
    Image10: TImage;
    Label23: TLabel;
    Label24: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Bevel1: TBevel;
    Label6: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure ToolButton7Click(Sender: TObject);
    procedure ToolButton9Click(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure UpDown1Click(Sender: TObject; Button: TUDBtnType);
    procedure ToolButton13Click(Sender: TObject);
    procedure ToolButton15Click(Sender: TObject);
    procedure ToolButton17Click(Sender: TObject);
    procedure ToolButton18Click(Sender: TObject);
    procedure ToolButton20Click(Sender: TObject);
    procedure ToolButton22Click(Sender: TObject);
    procedure UpDown2Click(Sender: TObject; Button: TUDBtnType);
    procedure UpDown3Click(Sender: TObject; Button: TUDBtnType);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    DIB:TDIB256;
    procedure InitMap;
    procedure DrawMap;
    procedure drawPlan;
    procedure VLine(x,y1,y2,c:integer);
  public
  end;

procedure potok(p:pointer);stdcall;

const
 Depth = 300;// Дальность горизонта
 Oknox=640; Oknoy=400;  // Размер окна по х и у
 SizeT=2047;
 Mxy=256;
 KatMap='Map';
var
  Form1: TForm1;
  CosT, SinT : Array [0..SizeT] of Integer;
  DComp : Array [1..Depth + 1] of Integer;
  MaiX,MaiY,Angle,MaiXmap,MaiYmap:integer;
  xxMax,yyMax,Cx,Cy:integer;
  PiMap,PhMap:PMaxMas;
  Ms:real;
  vzgliad:boolean;
  Tp:cardinal;
  stop1,potok1,moroz1:boolean;
  kt:integer=0;
  teplovizor:byte=0;
  Knopka:byte;
  Skr:integer;
  pyt:string;
  MOkna:integer=1;
implementation

{$R *.dfm}

procedure potok(p:pointer);stdcall;
  begin
    potok1:=true;
  repeat
 inc(Kt);if Kt>MaxIndeksMas then Kt:=0;
 Map.MakeMap;
 if(kt mod 255 = 1)and((not Map.Zag.stopMaska)or(not Map.Zag.stopPotop))then Map.H_Sredn;
  until stop1;
    potok1:=false;
  end;
procedure TForm1.VLine(x,y1,y2,c:integer);
 begin
  if y1<0 then y1:=0;
  if y2>=Oknoy then y2:=Oknoy-1;
  DIB.Line(x,y1,x,y2,c);
 end;
procedure TForm1.drawPlan;
var i,j,c,x,y:integer;
begin
  c:=0;
  for i:=0 to OknoX-1 do begin
    X:=trunc(I*Ms)div MOkna-Map.Zag.SkrolX;
    for j:=0 to OknoY-1 do begin
      Y:=trunc(J*Ms)div Mokna-Map.Zag.SkrolY;
      case teplovizor of
0: c:=Map.OUTcolor(x,y);
1..4: c:=Map.OUTcolorT(x,y,teplovizor);
                      end;
       DIB.SetPixel(i,j,c);
//       DIB.SetPixel(0,0,0);
                           end;
                         end;
  c:=76+random(6);
  x:=MaiXmap+Map.Zag.SkrolX;
  if x>=Map.Zag.Dx then x:=x-Map.Zag.Dx;
  if x<0 then x:=x+Map.Zag.Dx;
  x:=trunc(x/Ms)*MOkna;
  y:=MaiYmap+Map.Zag.SkrolY;
  if y>=Map.Zag.Dy then y:=y-Map.Zag.Dy;
  if y<0 then y:=y+Map.Zag.Dy;
  y:=trunc(y/Ms)*MOkna;
  dib.Ellipse(x-2,y-2,x+2,y+2,c);
end;
procedure TForm1.DrawMap;
 var
  hei:integer;
  a:word;
  px,py,c,i:integer;
  deltax,deltay:integer;
  miny:integer;
  d:integer;
  h,hm:int64;
  kMapX,kMapY:integer;
  y1:integer;
 begin
  hei:=Map.LookH(MaiXmap,MaiYmap)div 64;
  c:=0;
  for i:=0 to Oknox-1 do begin
   a:=angle+i+1730;//1888;
   while a>SizeT do a:=a-sizeT;
   deltax := CosT [a];
   deltay := SinT [a];
   px:=MaiX;
   py:=MaiY;
   minY := Oknoy;
   for d:=1 to Depth do begin
    inc (px, deltax);
    inc (py, deltay);
  if px>xxMax then px:=px-xxMax;
  if px<0 then px:=px+xxMax;
  if py>yyMax then py:=py-yyMax;
  if py<0 then py:=py+yyMax;
    kMapY:=py div Mxy; kMapX:=px div Mxy;
      case teplovizor of
0: c:=Map.OUTcolor(kMapX,kMapY);
1..4: c:=Map.OUTcolorT(kMapX,kMapY,teplovizor);
                      end;
    hm:=Map.LookH(kMapX,kMapY)div 64;
    h := hm-hei;
    y1 := DComp [d] - (h shl 5) div d;
    if y1 < minY then begin
     VLine (i, y1, minY,c);
     minY := y1;
     if miny=0 then break;
    end;
   end;
   if MinY>0 then VLine(i,0,minY,CGolyb[15]);
  end;
//  DIB.Line(maxx div 2,0,maxx div 2,maxy,0);
//  canvas.Draw(50,50,ImageList2.);
 end;
procedure TForm1.InitMap;
var
  DAC: Byte;
begin
  xxMax:=(Map.zag.dx-1)*Mxy;yyMax:=(Map.Zag.Dy-1)*Mxy;
  for DAC:=0 to 255 do DIB.Color[DAC]:=Map.colorRGB(DAC);
  DIB.UpdateColors;
end;
procedure TForm1.FormCreate(Sender: TObject);
 var
  a:integer;
  L:integer;
  Search:TSearchRec;
begin
  Pyt:=ExtractFilePath(Application.exename);
  if FindFirst(Pyt+KatMap,faDirectory,Search)<>0 then begin
    MkDir(Pyt+KatMap);
                                                      end;
  Map:=TMaps.Create(Owner);
  DIB:=TDIB256.Create(Self);
  DIB.Width:=Oknox;
  DIB.Height:=Oknoy;
  DIB.CreateDIB;
//Заполнение таблиц углов
  L:=Sizet div 2+1;
  for a := 0 to SizeT do begin// Кругозор разбит на SizeT частей
   CosT [a] := trunc(Cos (a * pi /L) * Mxy);//Mxy-Масштабирование до целого
   SinT [a] := trunc(Sin (a * pi /L) * Mxy);
  end;
//Заполнение таблицы дистанций
  for a := 1 to Depth + 1 do DComp [a] :=500 div a + Oknoy div 2;
//Место расположения игрока
  MaiX:=40000;
  MaiY:=40000;
  Angle := 0;
  MaiXmap:=MaiX div Mxy;
  MaiYmap:=MaiY div Mxy;
  InitMap;
  Label4.Caption:='7';
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  stopT1:=true;stop1:=true;
  while potok1 do;
  Map.Free;
  DIB.Free;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
 cx:=(ClientWidth-ProgressBar1.Width-OknoX)div 2+ProgressBar1.Width;
 cy:=(ClientHeight-toolbar1.Height-OknoY) div 2;
 Ms:=Map.Zag.Dy/OknoY;
 invalidate;

end;

procedure TForm1.FormPaint(Sender: TObject);
begin
 if Map.perezagryzka then begin
   if vzgliad then drawmap else drawplan;
   DIB.DrawXY(Canvas.Handle,cx,cy);
                          end;
 canvas.Pen.Width:=3;
 canvas.MoveTo(cx-2,cy+OknoY div 2-7);
 canvas.LineTo(cx-11,cy+OknoY div 2);
 canvas.LineTo(cx-2,cy+OknoY div 2+7);

 canvas.MoveTo(cx+OknoX+2,cy+OknoY div 2-7);
 canvas.LineTo(cx+OknoX+11,cy+OknoY div 2);
 canvas.LineTo(cx+OknoX+2,cy+OknoY div 2+7);

 canvas.MoveTo(cx+OknoX div 2-7,cy-2);
 canvas.LineTo(cx+OknoX div 2,cy-11);
 canvas.LineTo(cx+OknoX div 2+7,cy-2);

 canvas.MoveTo(cx+OknoX div 2-7,cy+OknoY+2);
 canvas.LineTo(cx+OknoX div 2,cy+OknoY+11);
 canvas.LineTo(cx+OknoX div 2+7,cy+OknoY+2);
end;

procedure TForm1.ToolButton2Click(Sender: TObject);
var threadid:cardinal;
begin
 if not potok1 then begin
   UpDown1.Enabled:=false;
   Label4.Font.Color:=clBlue;
   ToolButton17.Enabled:=false;
   stop1:=false;
   if Map.Zag.MaxH>Map.zag.MaxHT then Map.Zag.stopMaska:=false;
   Tp:=createthread(nil,0,@potok,nil,0,threadid);
   if Tp=0 then close;
              end else begin
   stop1:=true;Map.Zag.stopMaska:=true;
   UpDown1.Enabled:=true;
   Label4.Font.Color:=clBlack;
   ToolButton17.Enabled:=true;
                       end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if potok1 then shape1.Brush.Color:=clRed else shape1.Brush.Color:=clBlack;
  if(not potok1)or(Map.Zag.stopMaska)then shape2.Brush.Color:=clBlack else shape2.Brush.Color:=clOlive;
  if Map.Zag.stopPotop then shape3.Brush.Color:=clBlack else shape3.Brush.Color:=clAqua;
  if PrSredn then shape4.Brush.Color:=clYellow else shape4.Brush.Color:=clBlack;
  if PrPrirodaT1 then shape5.Brush.Color:=clYellow else shape5.Brush.Color:=clBlack;
  if PrPrirodaT2 then shape6.Brush.Color:=clYellow else shape6.Brush.Color:=clBlack;
  Label1.Caption:=inttostr(Kt);
  Label2.Caption:=inttostr(Map.FMaxHMapT);
  Label3.Caption:=inttostr(Map.Zag.LinOkeanT);
  ProgressBar1.Position:=Map.FMaxHMapT*100 div Map.Zag.MaxH;
  case Knopka of
5 : begin
  Map.Zag.SkrolX:=Map.Zag.SkrolX+Skr;
  if Map.Zag.SkrolX>=Map.Zag.Dx then Map.Zag.SkrolX:=Map.Zag.SkrolX-Map.Zag.Dx;
  if Map.Zag.SkrolX<0 then Map.Zag.SkrolX:=Map.Zag.Dx+Map.Zag.SkrolX;
     end;
6 : begin
  Map.Zag.SkrolY:=Map.Zag.SkrolY+Skr;
  if Map.Zag.SkrolY>=Map.Zag.Dy then Map.Zag.SkrolY:=Map.Zag.SkrolY-Map.Zag.Dy;
  if Map.Zag.SkrolY<0 then Map.Zag.SkrolY:=Map.Zag.Dy+Map.Zag.SkrolY;
     end;
              end;
//  Label1.Caption:=IntToStr(Map.Zag.SkrolX);
  paint;
end;

procedure TForm1.ToolButton7Click(Sender: TObject);
begin
  if vzgliad then vzgliad:=false else vzgliad:=true;
end;

procedure TForm1.ToolButton9Click(Sender: TObject);
  var r:integer;
begin
  inc(teplovizor);
  if teplovizor=4 then begin
    for r:=0 to 255 do DIB.Color[r]:=RGB(r,r,r);
    DIB.UpdateColors;
                       end;
  if teplovizor>4 then begin teplovizor:=0;
    for r:=0 to 255 do DIB.Color[r]:=Map.colorRGB(r);
    DIB.UpdateColors;
                       end;
  ToolButton9.ImageIndex:=teplovizor+2;
end;

procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if(Tochvrect(x,y,rect(cx,cy,cx+Oknox,cy+Oknoy)))and(not vzgliad)then begin
      MaiXmap:=trunc((X-cx)*Ms)div MOkna-Map.Zag.SkrolX;
      MaiX:=MaiXmap*Mxy;
      MaiYmap:=trunc((Y-cy)*Ms)div MOkna-Map.Zag.SkrolY;
      MaiY:=MaiYmap*Mxy;
                                                      end;
  if X>Cx+OknoX then begin Skr:=-10;knopka:=5 end;
  if X<Cx then begin Skr:=10;knopka:=5 end;
  if Y>Cy+OknoY then begin Skr:=-10;knopka:=6 end;
  if Y<Cy then begin Skr:=10;knopka:=6 end;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
const
 k=1;   // Скорость движения
 a=16;  //Скорость вращения
begin
    case key of
vk_up  :  Knopka:=1;
vk_Down:  Knopka:=2;
vk_left:  Knopka:=3;
vk_right: Knopka:=4;
             end;
  case Knopka of
1: begin
             inc (MaiX, k*CosT [Angle]div 2);
             inc (MaiY, k*SinT [Angle]div 2);
    end;
2: begin
             dec (MaiX, k*CosT [Angle]div 2);
             dec (MaiY, k*SinT [Angle]div 2);
    end;
3: begin
             Angle := (Angle + SizeT-a+1) and SizeT;
    end;
4:  begin
             Angle := (Angle + a) and SizeT;
    end;
5,6: begin
  Map.Zag.SkrolX:=Map.Zag.SkrolX+Skr;
  if Map.Zag.SkrolX>=Map.Zag.Dx then Map.Zag.SkrolX:=Map.Zag.SkrolX-Map.Zag.Dx;
  if Map.Zag.SkrolX<0 then Map.Zag.SkrolX:=Map.Zag.Dx+Map.Zag.SkrolX;
     end;
              end;
  if MaiX>xxMax then MaiX:=MaiX-xxMax;
  if MaiX<0 then MaiX:=MaiX+xxMax;
  if MaiY>yyMax then MaiY:=MaiY-yyMax;
  if MaiY<0 then MaiY:=MaiY+yyMax;
  MaiXmap:=MaiX div Mxy;
  MaiYmap:=MaiY div Mxy;

end;

procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  knopka:=0;
end;

procedure TForm1.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  knopka:=0;
end;

procedure TForm1.UpDown1Click(Sender: TObject; Button: TUDBtnType);
begin
  Label4.Caption:=IntToStr(UpDown1.Position);
  Map.Zag.MashM:=UpDown1.Position;
end;

procedure TForm1.ToolButton13Click(Sender: TObject);
begin
  if Panel1.Visible then Panel1.Visible:=false else Panel1.Visible:=true;
end;

procedure TForm1.ToolButton15Click(Sender: TObject);
begin
  if Panel2.Visible then Panel2.Visible:=false else Panel2.Visible:=true;
end;

procedure TForm1.ToolButton17Click(Sender: TObject);
begin
  if not Panel3.Visible then begin
  Panel3.Visible:=true;
  UpDown2.Position:=Map.Zag.Dx;
  UpDown3.Position:=Map.Zag.Dy;
  Label14.Caption:=IntToStr(UpDown2.Position);
  Label15.Caption:=IntToStr(UpDown3.Position);
                             end else Panel3.Visible:=false;
end;

procedure TForm1.ToolButton18Click(Sender: TObject);
var zag:ZagolovokBMP;
  r,size,sizestr,X,Y,f:integer;
  Pcv:PMaxMas;
  cvet:byte;
begin
  if teplovizor=4 then begin
    Savedialog1.DefaultExt:='bmp';
    Savedialog1.Filter:='Карта высот|*.bmp';
    Savedialog1.Title:='Запись BMP карты высот';
                       end else begin
    Savedialog1.DefaultExt:='map';
    Savedialog1.Filter:='Карта|*.map';
    Savedialog1.Title:='Сохранить как...';
                                end;
  saveDialog1.InitialDir:=pyt+KatMap;
  if SaveDialog1.Execute then begin
    if teplovizor=4 then begin
    sizestr:=Map.Zag.Dx+Map.Zag.Dx mod 4;
    size:=sizestr*map.Zag.Dy;
    zag.Char1:='B';
    zag.Char2:='M';
    zag.bfSize:=1078+size;
    zag.bfReserved1_0:=0;
    zag.bfReserved2_0:=0;
    zag.bfOffBits:=1078;
    zag.biSize40:=40;
    zag.biWidth:=Map.Zag.Dx;
    zag.biHeight:=map.Zag.Dy;
    zag.biPlanes1:=1;
    zag.biBitCount8:=8;
    zag.biCompress0:=0;
    zag.biSizeImage0:=0;
    zag.biXPerMetr:=0;
    zag.biYPerMetr:=0;
    zag.biClrUsed0:=0;
    zag.biClrImp0:=0;
    for r:=0 to 255 do begin
      zag.Pal[r,0]:=r;zag.Pal[r,1]:=r;zag.Pal[r,2]:=r;zag.Pal[r,3]:=0;
                       end;
    getmem(Pcv,size);
    for y:=0 to map.Zag.Dy-1 do begin
      for x:=0 to sizestr-1 do begin
        if x<Map.Zag.Dx then cvet:=Map.OUTcolorT(X,map.Zag.Dy-Y-1,4)else cvet:=0;
        Pcv[y*sizeStr+x]:=Cvet;
                               end;
                                end;
    f:=filecreate(SaveDialog1.FileName);
//    zag.bfReserved1_0
    if f>0 then begin
      filewrite(f,zag.Char1,1);
      filewrite(f,zag.Char2,1);
      filewrite(f,zag.bfSize,4);
      filewrite(f,zag.bfReserved1_0,2);
      filewrite(f,zag.bfReserved2_0,2);
      filewrite(f,zag.bfOffBits,4);
      filewrite(f,zag.biSize40,4);
      filewrite(f,zag.biWidth,4);
      filewrite(f,zag.biHeight,4);
      filewrite(f,zag.biPlanes1,2);
      filewrite(f,zag.biBitCount8,2);
      filewrite(f,zag.biCompress0,4);
      filewrite(f,zag.biSizeImage0,4);
      filewrite(f,zag.biXPerMetr,4);
      filewrite(f,zag.biYPerMetr,4);
      filewrite(f,zag.biClrUsed0,4);
      filewrite(f,zag.biClrImp0,4);
      filewrite(f,zag.Pal,1024);
      filewrite(f,Pcv^,size);
      fileclose(f);
                end;
    freemem(Pcv,size);
//    FindFirst(SaveDialog1.FileName,faAnyFile,Search);
//    showmessage(inttostr(search.Size))
                         end else begin
    Map.NaDisk(SaveDialog1.FileName);
                              end end;
end;

procedure TForm1.ToolButton20Click(Sender: TObject);
begin
  Opendialog1.InitialDir:=pyt+KatMap;
  if OpenDialog1.Execute then begin
    if FileExists(OpenDialog1.FileName)then Map.SDiska(OpenDialog1.FileName);
                              end;
end;

procedure TForm1.ToolButton22Click(Sender: TObject);
begin
  if ToolButton22.ImageIndex=15 then begin
       MOkna:=2;ToolButton22.ImageIndex:=14;
                                     end else begin
       MOkna:=1;ToolButton22.ImageIndex:=15;
                                              end;
  paint;
end;

procedure TForm1.UpDown2Click(Sender: TObject; Button: TUDBtnType);
begin
  Label14.Caption:=IntToStr(UpDown2.Position);
end;

procedure TForm1.UpDown3Click(Sender: TObject; Button: TUDBtnType);
begin
  Label15.Caption:=IntToStr(UpDown3.Position);
end;

procedure TForm1.Button1Click(Sender: TObject);
var dx,dy:integer;
begin
  Panel3.Visible:=false;
  dx:=UpDown2.Position;
  dy:=UpDown3.Position;
  Map.NolMap(dx,dy,64000);
//  tasyuu(RandP,Map.Zag.Dx*Map.Zag.Dy);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Panel3.Visible:=false;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  nm:=true;
end;

end.
