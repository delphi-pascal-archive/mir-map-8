unit Maps;

interface
uses
//  Windows,Messages,Classes,Controls,ExtCtrls,Graphics,
//  MiConst;
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,DIBS, ExtCtrls,MiConst,geombs;
type
 TgameRead=class(Tthread) // описываем класс для потока игры
protected
  procedure Execute;override; // Запуск
  procedure Tic; // Один тик программы 
end;


 TZagolovok=record
   ImFile:S16;
   Dx,Dy:integer;
   SizeS1:integer;
   MaxH,MaxHT,HOkean:word;
   KVylk,KVylkT,MashM:byte;
   MassaH,MassaW,MassaHT,MassaWT:integer;
   SkrolX,SkrolY:integer;
   ZnPr1,ZnPr2,ZnPr3,ZnPr4:integer;
   LinOkeanT:integer;
   stopMaska,stopPotop,Pr2,Pr3,Pr1:boolean;
            end;
//Lava=255-жерло
//XGr>200 - песок иначе камень
 TPiksH=record
   H,Woda,led,sneg,Objekt:word;
   XGr,Xtr,Xles,Trav,Les,Lava,Wlaga,Pojar:byte;
   Vlaj,Temp,Cvet:byte;
        end;
 TMasPiksH=array[0..999999]of TPiksH;
 PMasPiksH=^TMasPiksH;

 TMaps=Class(TCustomControl)// Необходимо использовать собственную
  private                   // переменную Map:TMaps;
    MapS1:PMasPiksH;
//    KRes:byte;
    CiklT1:int64;
    PalM:array[0..255,0..3] of byte;
    procedure GetMemS1;
    procedure FreeMemS1;
    procedure GetRandMas;
    function H_OutMap(X,Y:integer):word;
    procedure H_ToMap(X,Y:integer;c:word);
    procedure MaskToMap(Xc,Yc:integer);
    function H_AddMap(Nm,dh:integer):word;
    function Lava_AddMap(Nm,dh:integer):word;
    function T_AddMap(Nm,dt:integer):word;
    function Woda_AddMap(Nm,dh:integer):word;
    function Vlaj_AddMap(Nm,dh:integer):word;
    function Led_AddMap(Nm,dh:integer):word;
    function Sneg_AddMap(Nm,dh:integer):word;
    function Wlaga_AddMap(Nm,dh:integer):word;
    procedure InitPalitra;
    function NomMap(Xm,Ym:integer):integer;
    procedure ColorMap(Nm:integer);
    function Povexnost(Nm:integer):Byte;
    procedure LookLava(Nm:integer);
    procedure LookWoda(Nm:integer);
    procedure Potop;
    procedure PrirodaT1;
    procedure PrirodaT2;
    procedure LavaDvijn(Nm:integer);
    procedure WodaDvijn(Nm:integer);
    procedure VozdyxDvijn(Nm:integer);
    procedure VozdyxT2(Nm:integer);
    procedure WodaT2(Nm:integer);
    procedure Sglajivanie;
  public
    Zag:TZagolovok;
    MiX,MiY:integer;
    perezagryzka:boolean;
    function LookH(X,Y:integer):integer;
    procedure DrawMask(Can:TCanvas);
    function colorRGB(N:byte):Cardinal;
    procedure MakeMap;
    function FSrHMapT:word;
    function FMaxHMapT:word;
    property H_VMap[X,Y:integer]:word read H_OutMap write H_ToMap;
    procedure H_Sredn;
    Function OUTcolor(X,Y:integer):byte;
    Function OUTcolorT(X,Y:integer;rej:byte):byte;
    function objekt(X,Y:integer):word;
    procedure NolMap(Dx,Dy,MaxH:integer);
    procedure Vylkan(X,Y:integer);
    procedure WodaOut(X,Y:integer);
    procedure NaDisk(imf:string);
    procedure SDiska(imf:string);
  protected
    procedure zagrMasok;
    procedure MaskiFree;
  published
    Constructor Create(AOwner:TComponent);override; //Owner
    destructor Destroy;override;
         end;
const
MImRes:array[0..14]of S3=('M1','M2','M3','M4','M5','M6','M7','M8','M9','M10','M11','M12','M13','M14','M15');
CGolyb:array[0..15]of byte=(96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111);
CWoda:array[0..15]of byte=(128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143);
CPochva:array[0..15]of byte=(144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159);
CLed:array[0..15]of byte=(160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175);
CSneg:array[0..15]of byte=(176,177,178,179,180,181,182,183,184,185,186,187,185,186,187,188);
CLava:array[0..15]of byte=(192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207);
CTeplo=208;
CSinii=48;
CJoltii=64;
pojar=0;lava=1;les=2;sneg=3;led=4;woda=5;pesok=6;pochva=7;kamen=8;
NolT=90;
var Map:TMaps;
nm:boolean;
    grTy:PMaxMas;//Градиент температуры по широте
    grTh:MasBB; //Градиент температуры по высоте Tn=grTy-grTh
    grVt:MasBB; //Влажность воздуха по температуре
    maski:TMasMasok;
    Veter:Shortint;
    PrSredn:boolean;
    PrPrirodaT1,PrPrirodaT2,StopT2,StopT1:boolean;
    RandP:PMaxIntMas;
    T2:TgameRead;
implementation
{$R Mask.res}
procedure TgameRead.execute;
begin
  PrPrirodaT2:=true;
  repeat
  synchronize(Tic);
  until Terminated or StopT2 or StopT1;
  PrPrirodaT2:=false;
end;
procedure TgameRead.Tic;
begin
  Map.PrirodaT2;
end;
procedure TMaps.PrirodaT1;
var r,Nm:integer;
  begin
    PrPrirodaT1:=true;
    inc(CiklT1);
    if CiklT1>$FFFFFFF0 then CiklT1:=0;
    if(CiklT1 Mod 100 =1)and(not PrPrirodaT2)then begin//Запуск потока PrirodaT2
      StopT2:=false;
      T2:=TgameRead.Create(false); // Создаем поток
      T2.Priority:= tpIdle; // Ставим приоритет
                              end; 
    for r:=0 to zag.Dx*zag.Dy-1 do begin
      if StopT1 then begin PrPrirodaT1:=false;exit end;
      Nm:=RandP[r];
      if MapS1[Nm].Lava>0 then LavaDvijn(Nm);
      WodaDvijn(Nm);
      vozdyxDvijn(Nm);
      ColorMap(Nm);
                                   end;//for r
     PrPrirodaT1:=false;
  end;
procedure TMaps.MaskiFree;
  begin
    if assigned(maski.Pm)then freemem(maski.Pm,maski.zag.sizeW);
    maski.Pm:=nil;
  end;
procedure TMaps.zagrMasok;
var f:integer;
  begin
    if assigned(maski.Pm)then exit;
    f:=fileopen('M.map',0);
    if f>0 then begin
      fileread(f,maski.zag,sizeof(maski.zag));
      getmem(maski.Pm,maski.zag.sizeW);
      fileread(f,maski.pm^,maski.zag.sizeW);
      fileclose(f);
                end else begin maski.zag.K:=0;showmessage('Нет файла М.map')end;
  end;
procedure TMaps.NaDisk(imf:string);
var f:integer;
  begin
 f:=filecreate(imf);
 if f>0 then begin
//   fileseek(f,poz,0);
   filewrite(f,Zag,sizeof(zag));
   filewrite(f,MapS1^,zag.SizeS1);
   fileclose(f);
             end else showmessage('Не могу создать файл');
  end;
procedure TMaps.SDiska(imf:string);
var f:integer;
  begin
   f:=fileopen(imf,0);
   if f>0 then begin
     fileread(f,zag,sizeof(zag));
     if assigned(mapS1)then begin FreeMemS1;mapS1:=Nil end;
     GetMemS1;
     fileread(f,MapS1^,zag.SizeS1);
     fileclose(f);
               end else showmessage('Не могу открыть файл');
  end;
procedure TMaps.LavaDvijn(Nm:integer);
var v,Vniz,Lm,dh,Nv,w,pv,sym:integer;
  begin
     Vniz:=Nm;pv:=random(8);sym:=0;
     for v:=pv to pv+7 do begin //вектор скатывания
       Nv:=vokrygN(v,Nm,zag.Dx,zag.Dy);
       if MapS1[Nv].H<MapS1[Vniz].H then Vniz:=Nv;
       if MapS1[Nv].Lava>0 then inc(sym);
                          end;
     if Vniz<>Nm then begin //Растекание
       dh:=(MapS1[Nm].H-MapS1[Vniz].H)div 3;
       if MapS1[Vniz].Lava<255 then begin
         if MapS1[Nm].Lava<255 then begin
           if dh>0 then dh:=1;
                                    end;
         Lm:=MapS1[Nm].Lava;
         if Lm=255 then Lm:=254;
         MapS1[Vniz].Lava:=Lm;
                                    end;
       if dh>0 then begin //Перенос грунта
         H_ADDMap(Vniz,dh);H_ADDMap(Nm,-dh);
         if(MapS1[Nm].Lava=255)and(random(64)=0)then begin
             H_AddMap(Vniz,1);dec(zag.MassaH);
                                                     end;
                    end;
                      end;
     if MapS1[Nm].Lava=255 then begin
     if Vniz=Nm then begin //Подьем в жерле
          H_ADDMap(Nm,random(7)-2);
                     end;
                                end else begin // Остывание
        if MapS1[Nm].Woda>0 then begin
          w:=3;Woda_AddMap(Nm,-3);Vlaj_AddMap(Nm,3)end else w:=1;
        Lm:=Lava_ADDMap(Nm,(random(sym)-7)*w);
        if Lm=0 then begin H_ADDMap(Nm,1);dec(zag.MassaH);exit end;
                                         end;
        if MapS1[Nm].sneg>0 then begin
          Sneg_AddMap(Nm,-4);Vlaj_AddMap(Nm,4);
                                 end;
        if MapS1[Nm].led>0 then begin
          Led_AddMap(Nm,-3);Woda_AddMap(Nm,3);
                                end;
  end;
procedure TMaps.wodaOut(X,Y:integer);
var Nm:integer;
  begin
    Nm:=NomMap(X,Y);
    MapS1[Nm].woda:=255;
  end;
procedure TMaps.Vylkan(X,Y:integer);
var Nm:integer;
  begin
    Nm:=NomMap(X,Y);
    MapS1[Nm].Lava:=255;
  end;
procedure TMaps.VozdyxT2(Nm:integer);
var v,k,s,Nv,Hm,Hv:integer;
  begin
    v:=0;s:=0;
    if random(32)=0 then begin //Эррозия
      k:=random(8);Hm:=MapS1[Nm].H;
      for v:=k to v+k do begin
        Nv:=vokrygN(v,Nm,zag.Dx,zag.Dy);
        Hv:=MapS1[Nv].H;
        if Hv<Hm-36 then inc(s);
                         end;
      if s=8 then begin
        dec(MapS1[Hm].H);
        inc(zag.MassaHT);
                  end;
                         end;
    if random(MaxWord)<500 then begin//Изменение вектора ветра
      veter:=veter+random(3)-1;
      if veter<0 then veter:=7;
      if veter>7 then veter:=0;
                                end;
  end;
procedure TMaps.VozdyxDvijn(Nm:integer);
var Nv,d,Y,Hm,dT,kr:integer;
 begin
    Nv:=vokrygN(Veter+random(3)-1,Nm,zag.Dx,zag.Dy);
    d:=MapS1[Nm].Temp;                //Перенос
    MapS1[Nm].Temp:=MapS1[Nv].Temp;
    MapS1[Nv].Temp:=d;
    d:=MapS1[Nm].Vlaj;
    MapS1[Nm].Vlaj:=MapS1[Nv].Vlaj;
    MapS1[Nv].Vlaj:=d;

    Y:=Nm div Zag.Dx;               //Остывние Прогрев
    Hm:=MapS1[Nm].H;
    dT:=MapS1[Nm].Temp-(grTy[Y]-grTh[Hm div 256])-MapS1[Nm].Lava+MapS1[Nm].sneg shr 10;
    if dT<>0 then begin
      if dT<0 then kr:=1 else kr:=-1;
      dT:=(abs(dt div 16)+1)*kr;
      T_AddMap(Nm,dt);
                  end;
    d:=MapS1[Nm].Vlaj-grVt[MapS1[Nm].Temp];//Влага
    if d<>0 then begin
      if d>0 then begin
        if random(128)=0 then begin
        Vlaj_AddMap(Nm,-1);Wlaga_AddMap(Nm,1);//Дождь
                             end;
                    end else begin
        if MapS1[Nm].Woda>500 then begin
          Vlaj_AddMap(Nm,1);Woda_AddMap(Nm,-1);//Испарение
                                 end;
                             end end;
 end;
procedure TMaps.WodaT2(Nm:integer);
var v,k,Nv,Mvektor,Hm,H,Hv,dL:integer;
  begin
    Hm:=MapS1[Nm].H+MapS1[Nm].Woda+MapS1[Nm].led;dL:=0;
    k:=random(8);Mvektor:=Nm;H:=Hm;
    if random(64)=0 then begin     //Определение векторов
      for v:=k to k+7 do begin
        Nv:=vokrygN(v,Nm,zag.Dx,zag.Dy);
        Hv:=MapS1[Nv].H+MapS1[Nv].Woda+MapS1[Nv].led;
        if Hv<H then begin Mvektor:=Nv;H:=Hv;dL:=Hm-H end;
                         end;
      if(MapS1[Nm].led>0)and(Nm<>MVektor)then begin//Сползание льда
        if dL>MapS1[Nm].led then dL:=MapS1[Nm].led;
        Led_AddMap(Nm,-dL);Led_AddMap(MVektor,dL);
        if MapS1[MVektor].sneg>0 then begin
          Sneg_AddMap(MVektor,-1);Led_AddMap(MVektor,1);
                                      end;
        if MapS1[Nm].sneg>0 then begin
          Sneg_AddMap(Nm,-MapS1[Nm].sneg);Sneg_AddMap(MVektor,MapS1[Nm].sneg);
                                 end;
                                              end;
                         end;
  end;
procedure TMaps.WodaDvijn(Nm:integer);
var v1,k,hmw,hv,nv,sm,sv,Wm,dw,kw,vw,Mvektor,Bvektor:integer;
  v:shortint;
 begin
   Wm:=MapS1[Nm].Woda;
   hmw:=MapS1[Nm].H+Wm;
   k:=random(8);Mvektor:=Nm;
   kw:=hmw;Bvektor:=Nm;vw:=0;
   sm:=MaxWord-MapS1[Nm].H;v1:=k;
   for v:=k to k+7 do begin           //Набор векторов
     Nv:=vokrygN(v,Nm,zag.Dx,zag.Dy);
     hv:=MapS1[Nv].H+MapS1[Nv].Woda;
     if MapS1[Nv].Woda>0 then dec(hv);
     if hv<kw then begin Mvektor:=Nv;kw:=hv;v1:=v end;//Вектор воды
     if MapS1[Nv].Woda>0 then inc(vw);
     sv:=MapS1[Nv].H;
     if MapS1[Nv].Wlaga<255 then begin
       if sv<sm then begin BVektor:=Nv;sm:=sv end;    //Вектор влаги
                                 end;
                      end;//for i
   if(Wm>0)and(Mvektor<>Nm)then begin //Вода
     dw:=(hmw-kw)div 2;
     if dw>Wm then begin if wm>1 then dw:=Wm-1 else dw:=wm end;
     if(wm>dw)or(vw=0)or(MapS1[MVektor].Woda>0)then begin //Поток
       Wm:=Woda_AddMap(Nm,-dw);Woda_AddMap(Mvektor,dw);
       if(random(32)=0)and(vw=0)and(wm>0)then begin
         Woda_AddMap(Nm,-1);Vlaj_AddMap(Nm,1);
                                     end;
                                                    end end;
   if(MapS1[Nm].Wlaga>0)and(MapS1[BVektor].Wlaga<255)and(Bvektor<>Nm)then begin //Влага
     Wlaga_AddMap(Nm,-1);Wlaga_AddMap(BVektor,1);//Движение влаги
                             end;
   if MapS1[Nm].Wlaga>200 then begin
     Wlaga_AddMap(Nm,-1);Woda_AddMap(Nm,1);//Выделение воды
                               end;
{   if(Wm>10000)and(random(128)=0)and(MapS1[Nm].Wlaga<255)then begin
     Wlaga_AddMap(Nm,1);Woda_AddMap(Nm,-1);//Поглощение влаги
                                                             end; }
     if(wm<64)and(random(128)=0)then begin //Перемещение грунта
       v1:=v1+random(5)-2;
       k:=vokrygN(v1,Nm,zag.Dx,zag.Dy);
       if MapS1[Nm].H>MapS1[k].H then dw:=random(3) else dw:=random(2);
       if dw>0 then begin
         H_AddMap(Nm,-dw);H_AddMap(k,dw);
                    end;
                                    end;
    if MapS1[Nm].Temp>NolT+2 then begin   //Таяние
      if MapS1[Nm].led>0 then begin
        Led_AddMap(Nm,-1);Woda_AddMap(Nm,1);
                              end;
      if MapS1[Nm].sneg>0 then begin
        Sneg_AddMap(Nm,-1);Woda_AddMap(Nm,1);
        if MapS1[Nm].sneg>0 then begin
          Sneg_AddMap(Nm,-1);Led_AddMap(Nm,1);
                                 end;
                               end;
                                   end;
    if MapS1[Nm].Temp<NolT-2 then begin //Замерзание
      if MapS1[Nm].Woda>0 then begin
        Led_AddMap(Nm,1);Woda_AddMap(Nm,-1);
                               end;
      if MapS1[Nm].Vlaj>2 then begin
        Sneg_AddMap(Nm,3);Vlaj_AddMap(Nm,-3);
                               end;
                                   end;
    if(MapS1[Nm].Temp>=NolT-2)and(MapS1[Nm].Temp<=NolT+2)and(MapS1[Nm].sneg>0)then begin
      Led_AddMap(Nm,1);Sneg_AddMap(Nm,-1);
                                                                                   end;
 end;
function TMaps.objekt(X,Y:integer):word;
var Nm:integer;
  begin Nm:=NomMap(X,Y);result:=MapS1[Nm].Objekt end;
procedure TMaps.PrirodaT2;
var rr,Nm,rn,d:integer;
 Vl:boolean;
 re:real;
  begin
    PrPrirodaT2:=true;
//Вулканы---------------------------------------
    rn:=random(7)+1;
    if Zag.KVylk>Zag.KVylkT+rn then Vl:=true else Vl:=false;
    for rr:=0 to Zag.Dx*Zag.Dy-1 do begin
      if StopT1 then begin PrPrirodaT2:=false;exit end;
      Nm:=RandP[rr];
//Nm:=rr;
      //Образование жерла
      if(Vl)and(random(Zag.Dy)=0)and
      (MapS1[Nm].Lava<255)and(((MapS1[Nm].H>Zag.ZnPr3)and(MapS1[Nm].H<Zag.ZnPr4))or(MapS1[Nm].H<Zag.ZnPr1))then begin
        MapS1[Nm].H:=MapS1[Nm].H-5;
        MapS1[Nm].Lava:=255;Vl:=false;inc(Zag.KVylkT);
                 end;
      if MapS1[Nm].Lava=255 then begin//Погасание жерла
         re:=sqr(MapS1[Nm].H)/MaxWord+2;
         rn:=random(trunc(re))+2;
         if(random(rn)=10000)and(random(Zag.Dy)=0)then begin
           Lava_ADDMap(Nm,-1);dec(Zag.KVylkT);
                  end end;
      if(Zag.MassaWT<>0)and(MapS1[Nm].Woda>77)and(random(16)=0)then begin
        if Zag.MassaWT>0 then d:=1 else d:=-1;
        Woda_AddMap(Nm,d);Zag.MassaWT:=Zag.MassaWT-d;
                                                  end;
      if(Zag.MassaHT<>0)and(random(zag.Dy)=0)then begin
        if Zag.MassaHT>0 then begin
          if(MapS1[Nm].H<zag.HOkean+500)and(MapS1[Nm].H>zag.HOkean-500)then begin
            H_AddMap(Nm,1);Zag.MassaHT:=Zag.MassaHT-1;
                                                                            end;
                              end else begin
          if(MapS1[Nm].H>zag.HOkean+255)or(MapS1[Nm].H<zag.HOkean-255)then begin
            H_AddMap(Nm,-1);Zag.MassaHT:=Zag.MassaHT+1;
                                                                            end;
                                       end;
                                              end;
      vozdyxT2(Nm);
      wodaT2(Nm);
                                   end;//for r
  PrPrirodaT2:=false;
  StopT2:=true;
  end;

procedure TMaps.Potop;
var r,dwoda,w,dh:integer;
  begin
    dh:=Zag.HOkean div 6000+1;//abs(Zag.HOkean-LinOkeanT)div 1000+1;
    if Zag.LinOkeanT<Zag.HOkean then inc(Zag.LinOkeanT,dh);
    if Zag.LinOkeanT>Zag.HOkean then dec(Zag.LinOkeanT,dh);
    for r:=0 to Zag.Dx*Zag.Dy-1 do begin
      if StopT1 then exit;
      dwoda:=0;
      if MapS1[r].H+MapS1[r].Woda>Zag.LinOkeanT then begin
           if MapS1[r].Woda>0 then dwoda:=-1;
                                                       end;
      if MapS1[r].H+MapS1[r].Woda<Zag.LinOkeanT then begin
           if MapS1[r].Woda<MaxWord then dwoda:=2;
                                                       end;
      if dwoda<>0 then begin
        w:=MapS1[r].Woda+dwoda;
        MapS1[r].Woda:=w;
                       end;
      ColorMap(r);
                                   end;
  end;
procedure TMaps.LookWoda(Nm:integer);
var cv,Gl,k:integer;
  begin
       if(zag.stopMaska)or(random(36)=0)then begin
       Gl:=MapS1[Nm].Woda div 256;
       cv:=CWoda[Gl div 16];
       k:=MapS1[Nm].Woda mod 256;
       if k<50 then dec(cv);
       if k>205 then inc(cv);
       if cv<CWoda[0]then cv:=CWoda[0];
       if cv>CWoda[15]then cv:=CWoda[15];
       MapS1[Nm].Cvet:=cv;
                                       end;
  end;
procedure TMaps.LookLava(Nm:integer);
var cv,dc,dr,dd:integer;
  begin
       if(zag.stopMaska)or(random(16)=0)then begin
       if MapS1[Nm].Woda>0 then dr:=Csneg[0]else dr:=Clava[0];
       cv:=MapS1[Nm].Cvet;
       dd:=MapS1[Nm].Lava div 51;
       if cv<dr then cv:=dr+random(16);
       dc:=(cv-dr+7-random(8))div 4-dd+2;
       cv:=cv+random(6)-dc;
       if cv>dr+15 then cv:=dr+15;
       if cv<dr then cv:=dr;
       MapS1[Nm].Cvet:=cv;
                            end;
  end;
function TMaps.Povexnost(Nm:integer):Byte;
 begin
   if MapS1[Nm].Pojar>0 then result:=pojar else begin
     if MapS1[Nm].Lava>0 then result:=lava else begin
       if MapS1[Nm].sneg>0 then result:=sneg else begin
         if MapS1[Nm].led>0 then result:=led else begin
           if MapS1[Nm].Woda>0 then result:=woda else begin
              result:=kamen;
              end;end;end;end;end;
 end;
Function TMaps.OUTcolorT(X,Y:integer;rej:byte):byte;
var
    Nm,Res:integer;
    mm:real;
 begin
      while X<0 do X:=X+Zag.Dx;
      while X>=Zag.Dx do X:=X-Zag.Dx;
      while Y<0 do Y:=Y+Zag.Dy;
      while Y>=Zag.Dy do Y:=Y-Zag.Dy;
      Nm:=NomMap(X,Y);
      case rej of
1:      Result:=MapS1[Nm].Temp div 16+CTeplo;
2:      Result:=MapS1[Nm].Vlaj div 16+CSinii;
3:      Result:=15-MapS1[Nm].Wlaga div 16+CJoltii;
4:      begin
          mm:=maxword/zag.HOkean;
          Res:=round((MapS1[Nm].H+MapS1[Nm].Woda-zag.HOkean)/510*mm);
          if Res>255 then Res:=255;
          if Res<0 then res:=0;
          Result:=Res;
        end;
else Result:=12;
               end;
 end;
Function TMaps.OUTcolor(X,Y:integer):byte;
var Pov:byte;
    Nm:integer;
  begin
      while X<0 do X:=X+Zag.Dx;
      while X>=Zag.Dx do X:=X-Zag.Dx;
      while Y<0 do Y:=Y+Zag.Dy;
      while Y>=Zag.Dy do Y:=Y-Zag.Dy;
      Nm:=NomMap(X,Y);
      Pov:=Povexnost(Nm);
case Pov of
lava: LookLava(Nm);
Woda: LookWoda(Nm);
         end;
    result:=MapS1[Nm].Cvet;
  end;
procedure TMaps.ColorMap(Nm:integer);
var
    h,cv:integer;
    Pov:byte;
 begin
    Pov:=Povexnost(Nm);
    case Pov of
lava: begin
        LookLava(Nm);
      end;
kamen: begin
       h:=MapS1[Nm].H div 256;
       cv:=CPochva[h div 16];
       MapS1[Nm].Cvet:=cv;
       end;
woda: begin
        LookWoda(Nm);
        end;
sneg: begin
        MapS1[Nm].Cvet:=Csneg[11];
      end;
Led:  begin
        MapS1[Nm].Cvet:=CLed[11];
      end;
             end;
 end;
function TMaps.NomMap(Xm,Ym:integer):integer;
 begin
   result:=Ym*Zag.Dx+Xm;
 end;
procedure TMaps.H_Sredn;
var r,k:integer;
 sym,symW,rez,KVk:int64;
 begin
   PrSredn:=true;
    if(not Zag.Pr2)and(zag.MaxHT>=Zag.ZnPr2)then Zag.Pr2:=true;
    if(not Zag.Pr3)and(zag.MaxHT>=Zag.ZnPr3)then Zag.Pr3:=true;
    if(not Zag.Pr1)and(zag.MaxHT>=Zag.ZnPr1)then Zag.Pr1:=true;
   if Zag.Pr2 then zag.stopPotop:=false;
   if Zag.stopMaska then zag.stopPotop:=true;
   sym:=0;kVk:=0;k:=Zag.Dx*Zag.Dy;symW:=0;
   for r:=0 to k-1 do begin
     if stopT1 then begin PrSredn:=false;exit end;
     Sym:=Sym+MapS1[r].H;
     SymW:=SymW+MapS1[r].Woda+MapS1[r].led+MapS1[r].sneg+MapS1[r].Wlaga+MapS1[r].Vlaj;
     if MapS1[r].Lava=255 then inc(kVk);
     VozdyxT2(r);
                      end;
     if kVk>255 then kVk:=255;
     Zag.KVylkT:=kVk;
     rez:=Sym div k;
     Zag.MassaH:=rez;
     rez:=SymW div k;
     zag.MassaW:=rez;
   PrSredn:=false;
 end;
function TMaps.FSrHMapT:word;
 begin result:=Zag.MassaHT end;
function TMaps.FMaxHMapT:word;
 begin result:=zag.MaxHT end;
procedure TMaps.MakeMap;
var Xc,Yc:integer;
  begin
    if not Zag.StopMaska then begin
      randomize;
      xC:=random(zag.dx*2)-zag.dx div 4;
      yC:=random(zag.dy*2)-zag.dy div 2;
      MaskToMap(Xc,Yc);
                              end;
    if not Zag.StopPotop  then Potop else begin
       if zag.Pr3 then prirodaT1;
                                          end;
    if((zag.MaxHT>=Zag.MaxH)and(zag.LinOkeanT>=zag.HOkean))then Zag.stopMaska:=true;
  end;
function TMaps.Led_AddMap(Nm,dh:integer):word;
var h:integer;
  begin
    h:=MapS1[nm].led+dh;
    if h<0 then begin
      zag.MassaWT:=zag.MassaWT+h;h:=0;
                end;
    if h>maxword then begin
      h:=h-maxword;zag.MassaWT:=zag.MassaWT+h;h:=maxword;
                  end;
    MapS1[nm].led:=h;
    Result:=h;
  end;
function TMaps.Sneg_AddMap(Nm,dh:integer):word;
var h:integer;
  begin
    h:=MapS1[nm].sneg+dh;
    if h<0 then begin
      zag.MassaWT:=zag.MassaWT+h;h:=0;
                end;
    if h>maxword then begin
      h:=h-maxword;zag.MassaWT:=zag.MassaWT+h;h:=maxword;
                  end;
    MapS1[nm].sneg:=h;
    Result:=h;
  end;
function TMaps.Wlaga_AddMap(Nm,dh:integer):word;
var h:integer;
  begin
    h:=MapS1[nm].Wlaga+dh;
    if h<0 then begin
      zag.MassaWT:=zag.MassaWT+h;h:=0;
                end;
    if h>255 then begin
      h:=h-255;zag.MassaWT:=zag.MassaWT+h;h:=255;
                  end;
    MapS1[nm].Wlaga:=h;
    Result:=h;
  end;
function TMaps.T_AddMap(Nm,dt:integer):word;
var t:integer;
  begin
    t:=MapS1[nm].Temp+dt;
    if t<0 then t:=0;
    if t>255 then t:=255;
    MapS1[nm].Temp:=t;
    Result:=t;
  end;
function TMaps.Vlaj_AddMap(Nm,dh:integer):word;
var h:integer;
  begin
    h:=MapS1[nm].Vlaj+dh;
    if h<0 then begin
      zag.MassaWT:=zag.MassaWT+h;h:=0;
                end;
    if h>255 then begin
      h:=h-255;zag.MassaWT:=zag.MassaWT+h;h:=255;
                  end;
    MapS1[nm].Vlaj:=h;
    Result:=h;
  end;
function TMaps.H_AddMap(Nm,dh:integer):word;
var h:integer;
  begin
    h:=MapS1[nm].H+dh;
    if h<0 then begin
      zag.MassaHT:=zag.MassaHT+h;h:=0;
                end;
    if h>maxword then begin
      h:=h-maxword;zag.MassaHT:=zag.MassaHT+h;h:=maxword;
                  end;
    MapS1[nm].H:=h;
    Result:=h;
  end;
function TMaps.Woda_AddMap(Nm,dh:integer):word;
var h:integer;
  begin
    h:=MapS1[nm].Woda+dh;
    if h<0 then begin
      zag.MassaWT:=zag.MassaWT+h;h:=0;
                end;
    if h>maxword then begin
      h:=h-maxword;zag.MassaWT:=zag.MassaWT+h;h:=maxword;
                  end;
    MapS1[nm].Woda:=h;
    Result:=h;
  end;
function TMaps.Lava_AddMap(Nm,dh:integer):word;
var h:integer;
  begin
    h:=MapS1[Nm].Lava+dh;
    if h<0 then h:=0;
    if h>255 then h:=255;
    MapS1[nm].Lava:=h;
    Result:=h;
  end;
procedure TMaps.Sglajivanie;
const dh=255;
var r,n,h,hm:integer;
    v:shortint;
    re:real;
  begin
    for r:=0 to Zag.Dx*Zag.Dy-1 do begin
      hm:=MapS1[r].H;
      re:=0.5-hm/132000;
      if hm<FMaxHMapT div 5*4 then begin
      for v:=0 to 7 do begin
        n:=vokrygN(v,r,zag.Dx,zag.Dy);
        h:=round((hm-MapS1[n].H)*re);
        if abs(h)>dh then begin
          H_ADDMap(n,h);hm:=H_ADDMap(r,-h);
                             end
                       end;
                                   end end;
  end;
procedure TMaps.MaskToMap(Xc,Yc:integer);
var i,j,xm,ym,H,Nm,MdH,dh,z,rd,Hm,RMX,RMY:integer;
  kor:boolean;
  c:byte;
  MasM,dm:real;
  NomM:byte;
  TocM:integer;
  begin
    if(zag.MaxHT>=Zag.MaxH)and(random(160)>0)then exit;
    if zag.Pr3 then dm:=0.3 else dm:=0;
    NomM:=random(12)+1;
    rd:=7;kor:=false;
    MasM:=1.4+zag.MashM/15-dm+(zag.Dx*zag.Dy/32000-1)*0.1;
    RMX:=trunc(MasM*maski.zag.Storon[NomM].X);
    RMY:=trunc(MasM*maski.zag.Storon[NomM].Y);
    if(maski.zag.Storon[NomM].X>40)or(maski.zag.Storon[NomM].Y>40)then kor:=true;
    if(Zag.Pr2)or((Zag.Pr1)and(zag.MaxHT div 2<Zag.MassaHT))then begin
      if kor then begin MdH:=random(100)end else begin
                                 MdH:=random(400);
                                                 end;
                   end else begin
      if kor then MdH:=random(50)else MdH:=random(250);
                            end;
    z:=1;
    while Xc<0 do Xc:=Xc+Zag.Dx;
    while Xc>=Zag.Dx do Xc:=Xc-Zag.Dx;
    while Yc<0 do Yc:=Yc+Zag.Dy;
    while Yc>=Zag.Dy do Yc:=Yc-Zag.Dy;
    Hm:=MapS1[NomMap(Xc,Yc)].H; //Центр маски
    if Hm>zag.MaxHT div 5*4 then MasM:=MasM-0.4;
    if Hm<zag.MaxHT div 5*4 then begin if Zag.Pr3 then rd:=12 else rd:=9;MdH:=random(64)end;
    if Hm<zag.MaxHT div 5*3 then begin if Zag.Pr3 then MdH:=0 else begin rd:=10;MdH:=random(64)end end;
    if Hm<zag.MaxHT div 5*2 then begin if Zag.Pr2 then begin
      if Zag.Pr3 then rd:=20 else rd:=12 end else rd:=9;MdH:=random(64)end;
    if Hm<zag.MaxHT div 5 then   begin if Zag.Pr2 then rd:=9 else rd:=12;MdH:=random(127)end;

    if not Zag.Pr1 then begin inc(Mdh,zag.MaxHT div 50+20)end
                  else begin if not Zag.Pr3 then inc(Mdh,zag.MaxHT div 75+10)else inc(Mdh,zag.MaxHT div 100)end;
    if Mdh=0 then exit;
//    if(Zag.pr3)and(Hm>zag.HOkean-255)and(Hm<zag.HOkean+255)then begin rd:=5;Mdh:=1 end;
    if random(rd)>7 then z:=-1;
    for i:=0 to RMY-1 do begin
      Ym:=Yc-RMY div 2+i;
      while Ym<0 do Ym:=Ym+Zag.Dy;
      while Ym>=Zag.Dy do Ym:=Ym-Zag.Dy;
      for j:=0 to RMX-1 do begin
        if stopT1 then exit;
        TocM:=trunc(i/MasM)*maski.zag.Storon[NomM].X+trunc(j/MasM);
        c:=maski.Pm[maski.zag.size[NomM]+TocM];
        if c=0 then continue;
        Xm:=Xc-RMX div 2+J;
        while Xm<0 do Xm:=Xm+Zag.Dx;
        while Xm>=Zag.Dx do Xm:=Xm-Zag.Dx;
        Nm:=NomMap(Xm,Ym);
        H:=MapS1[Nm].H;
        if(kor)and(z=-1)and(H>zag.MaxHT Div 3*2)then continue;
        case c of
1:    begin dh:=1*MdH end;
2:    begin dh:=2*MdH end;
3:    begin dh:=3*MdH end;
4:    begin dh:=4*MdH end;
5:    begin dh:=5*MdH end;
6:    begin dh:=6*MdH end;
7:    begin dh:=7*MdH end;
else dh:=0;
               end;
        dh:=dh*z+random(15)-7;
        H:=H_AddMap(Nm,dh);
        if H>Zag.MaxH Div 65 then begin
            if MapS1[Nm].Lava<255 then Lava_ADDMap(Nm,-16);
                              end else MapS1[Nm].Lava:=254;
        if zag.MaxHT<H then zag.MaxHT:=H;
        ColorMap(Nm);
                                       end;
                                      end;
        if((not Zag.Pr2)or(Zag.Pr3))and(random(150)=0)then sglajivanie;
  end;
function TMaps.colorRGB(N:byte):Cardinal;
var r,g,b:byte;
  begin
    r:=palM[N,0];
    g:=palM[N,1];
    b:=palM[N,2];
    result:=RGB(r,g,b);
  end;
procedure TMaps.InitPalitra;
var i:word;
  begin
  for i := 0 to 15 do begin  //Серый  0 - 15
    palM[i,0]:=i*17;
    palM[i,1]:=i*17;
    palM[i,2]:=i*17;
    palM[i,3]:=0;
                       end ;
  for i := 0 to 15 do begin //Красный  16 - 31
    palM[i+16,0]:=(i+1)*16-1;
    palM[i+16,1]:=0;
    palM[i+16,2]:=0;
    palM[i+16,3]:=0;
                       end ;
  for i := 0 to 15 do begin  //Зеленый  32 - 47
    palM[i+32,0]:=0;
    palM[i+32,1]:=(i+1)*16-1;
    palM[i+32,2]:=0;
    palM[i+32,3]:=0;
                       end ;
  for i := 0 to 15 do begin //Синий     48 - 63
    palM[i+48,0]:=0;
    palM[i+48,1]:=0;
    palM[i+48,2]:=(i+1)*16-1;
    palM[i+48,3]:=0;
                       end ;
  for i := 0 to 15 do begin //Желтый    64 - 79
    palM[i+64,0]:=(i+2)*15;
    palM[i+64,1]:=(i+1)*16-1;
    palM[i+64,2]:=(i+1)*2;
    palM[i+64,3]:=0;
                       end ;
  for i := 0 to 15 do begin //Фиолетовый 80 - 95
    palM[i+80,0]:=(i+1)*16-1;
    palM[i+80,1]:=0;
    palM[i+80,2]:=(i+1)*16-1;
    palM[i+80,3]:=0;
                      end ;
  for i := 0 to 15 do begin//Голубой     96 - 111
    palM[i+96,0]:=0;
    palM[i+96,1]:=(i+1)*16-1;
    palM[i+96,2]:=(i+1)*16-1;
    palM[i+96,3]:=0;
                       end ;
  for i := 0 to 15 do begin//Хаки       112 - 127
    palM[i+112,0]:=(i+1)*15-1;
    palM[i+112,1]:=(i+1)*12-1;
    palM[i+112,2]:=(i+1)*2-1;
    palM[i+112,3]:=0;
                       end ;
  for i := 0 to 15 do begin//Moре       128 - 143
    palM[i+128,0]:=0;
    palM[i+128,1]:=255-((i+1)*16-1);
    palM[i+128,2]:=255-i*12;
    palM[i+128,3]:=0;
                       end ;
  for i := 0 to 15 do begin//Почва      144 - 159
    palM[i+144,0]:=(i+1)*16-1;
    palM[i+144,1]:=(i+1)*12+7;
    palM[i+144,2]:=(i+1)*8-1;
    palM[i+144,3]:=0;
  end ;
  for i := 0 to 15 do begin//Лед        160 - 175
    palM[i+160,0]:=i*2+150;
    palM[i+160,1]:=i*2+220;
    palM[i+160,2]:=i*2+225;
    palM[i+160,3]:=0;
  end ;
  for i := 0 to 15 do begin//Снег       176 - 191
    palM[i+176,0]:=i*2+225;
    palM[i+176,1]:=i*2+225;
    palM[i+176,2]:=i*2+225;
    palM[i+176,3]:=0;
  end ;
  for i := 1 to 15 do begin//Лава       192 - 207
    palM[i+192,0]:=i*4+195;
    palM[i+192,1]:=i*i;
    palM[i+192,2]:=i*2;
    palM[i+192,3]:=0;
  end ;
  for i := 0 to 15 do begin//Тепло      208 - 223
    palM[i+208,0]:=i*17;
    palM[i+208,1]:=0;
    palM[i+208,2]:=255-i*17;
    palM[i+208,3]:=0;
  end ;
  for i := 0 to 15 do begin//           224 - 239
    palM[i+224,0]:=0;
    palM[i+224,1]:=0;
    palM[i+224,2]:=0;
    palM[i+224,3]:=0;
  end ;
  for i := 0 to 15 do begin//           240 - 255
    palM[i+240,0]:=0;
    palM[i+240,1]:=0;
    palM[i+240,2]:=0;
    palM[i+240,3]:=0;
  end ;
  end;
function TMaps.LookH(X,Y:integer):integer;
var Nm:integer;
  begin
      while X<0 do X:=X+Zag.Dx;
      while X>=Zag.Dx do X:=X-Zag.Dx;
      while Y<0 do Y:=Y+Zag.Dy;
      while Y>=Zag.Dy do Y:=Y-Zag.Dy;
      Nm:=NomMap(X,Y);
      result:=MapS1[Nm].H+MapS1[Nm].Woda+MapS1[Nm].led+MapS1[Nm].sneg;
  end;
function TMaps.H_OutMap(X,Y:integer):word;
  begin
      while X<0 do X:=X+Zag.Dx;
      while X>=Zag.Dx do X:=X-Zag.Dx;
      while Y<0 do Y:=Y+Zag.Dy;
      while Y>=Zag.Dy do Y:=Y-Zag.Dy;
    result:=MapS1[NomMap(X,Y)].H;
  end;
procedure TMaps.H_ToMap(X,Y:integer;c:word);
  begin
      while X<0 do X:=X+Zag.Dx;
      while X>=Zag.Dx do X:=X-Zag.Dx;
      while Y<0 do Y:=Y+Zag.Dy;
      while Y>=Zag.Dy do Y:=Y-Zag.Dy;
    MapS1[NomMap(X,Y)].H:=c;
  end;
procedure TMaps.DrawMask(Can:TCanvas);
{var r,x,y,dx,dy,dl:integer;
   c:TColor;
   b:byte; }
  begin
{  dx:=maski.zag.Storon[1].X;
  dy:=maski.zag.Storon[1].Y;
  dl:=dx*dy;
z1:=dl;
z2:=dy;
  for r:=0 to dl-1 do begin
    x:=r mod maski.zag.Storon[1].X;
    y:=r div maski.zag.Storon[1].X;
    b:=maski.pm[0+r];
    case b of
1: c:=clBlack;
2: c:=clRed;
3: c:=clYellow;
4: c:=clBlue;
else c:=clWhite;
           end;
    can.Pixels[x+50,y+50]:=c;
                                     end; }
  end;
procedure TMaps.FreeMemS1;
  begin
    if assigned(mapS1)then begin
      FreeMem(MapS1,Zag.SizeS1);
      MapS1:=Nil;
                           end;
  end;
procedure TMaps.GetMemS1;
  begin
 if not assigned(mapS1)then begin
 Zag.SizeS1:=sizeof(TPiksH)*Zag.Dx*Zag.Dy;
 getmem(mapS1,Zag.SizeS1);
 fillchar(mapS1^,Zag.SizeS1,0);
                            end;
  end;
procedure TMaps.nolMap(Dx,Dy,MaxH:integer);
var r:integer;
  begin
    perezagryzka:=false;
    if assigned(RandP)then freemem(RandP);
    if assigned(mapS1)then FreeMemS1;
    Zag.Dx:=Dx;Zag.Dy:=Dy;Zag.StopPotop:=true;
    zag.MassaH:=20000;
    Zag.MaxH:=MaxH;
    Zag.KVylk:=7;
    Zag.HOkean:=23000;
    Zag.MassaHT:=0;zag.MaxHT:=0;
    zag.LinOkeanT:=0;
    zag.stopMaska:=true;
    zag.stopPotop:=true;
    zag.Pr1:=false;
    zag.Pr2:=false;
    zag.Pr3:=false;
    CiklT1:=0;
    GetMemS1;
    GetRandMas;
    for r:=0 to Zag.Dx*zag.Dy-1 do begin
      MapS1[r].Wlaga:=0;
      MapS1[r].Vlaj:=0;
      MapS1[r].Temp:=150;
                                   end;
    for r:=0 to Zag.Dx*Zag.Dy-1 do begin
      mapS1[r].Lava:=254;
      ColorMap(r);
                                   end;
    perezagryzka:=true;
  end;
procedure TMaps.GetRandMas;
var size,r:integer;
  begin
    size:=zag.Dx*zag.Dy;
    getmem(RandP,size*sizeof(integer));
      for r:=0 to size-1 do begin
        RandP[r]:=r;
                            end;
      tasyuu(RandP,size);
  end;
Constructor TMaps.Create(AOwner:TComponent);
var r:integer;
  re:real;
  begin
    inherited Create(AOwner);mapS1:=Nil;
    nolMap(800,400,64000);
//    KRes:=Sizeof(MImRes)div sizeof(S3);
    randomize;
    InitPalitra;
    getmem(grTy,Zag.Dy);
    for r:=0 to Zag.Dy do begin //Градиент температур по широте
      re:=sin(r*180/zag.Dy*GradToRad)*32*(400/zag.Dy);
      grTy[r]:=157+trunc(re);
                          end;
    for r:=0 to 255 do begin
      re:=sqr(r)/500;
      grTh[r]:=trunc(re);    //Градиент температур по высоте
      grVt[r]:=grTh[r];      //Градиент влажности по температуре
                       end;
    Zag.ZnPr1:=Zag.MaxH div 6;
    Zag.ZnPr2:=Zag.MaxH div 3;
    Zag.ZnPr3:=Zag.MaxH div 3*2;
    zag.ZnPr4:=(zag.MaxH div 6)*5;
    CiklT1:=0;
    zagrMasok;
    zag.ImFile:='Sel';
    getRandMas;
    veter:=random(8);
    zag.stopMaska:=true;
    zag.MashM:=7;
  end;
Destructor TMaps.Destroy;
  begin
     freemem(RandP);
     maskiFree;
     FreeMem(grTy);
     FreeMemS1;
    inherited Destroy;
  end;

end.
