unit geombs;
interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls,MiConst,matematikBS;
Const
 RadToGrad=57.2956;
 GradToRad=0.0174;
 Verx=1;Pravo=2;Niz=4;Levo=8;
 Vektor4:array[0..3]of byte=(Verx,Pravo,Niz,Levo);
 vekt:array[0..9]of shortint=(0,1,1,1,0,-1,-1,-1,0,1);
 Skaner:array[0..7]of shortint=(0,-1,1,-2,2,-3,3,-4);//Вместе с vokryg
 MNm4:array[0..6]of shortint=(0,1,0,-1,0,1,0);//Y- со смещением 3 от X
Type
  kvadr=record
    x,y,dx,dy:integer;
        end;
  kvadrM=record
    x,y:Word;
    dx,dy:byte;
         end;
  ekrkoord=record
   x,y:byte;
           end;
  max2byte=array[word]of ekrkoord;
  Pmax2byte=^max2byte;
  maxwbyte=array[word]of byte;
  maxbbyte=array[byte]of byte;
  maxwordmas=array[word]of word;
  Pmaxwordmas=^maxwordmas;
  Pmaxbbyte=^maxbbyte;

  function Tochvrect(x,y:integer;Rk:trect):boolean;{Попадание точки внутрь обводки квадрата}
  function kv_rect(kv:kvadr):Trect;
  function rect_kv(r:TRect):kvadr;
  procedure Vokryg(v:shortint;var dx,dy:shortint);//8-центральная точка. Обзор по кругу
  function VokrygN(v:shortint;Nm,maxX,maxY:integer):integer;//Nm - № в массиве Dx,Dy - размер карты
  function PlusVektor(Vk0,Vk1:Byte):byte;//Складывает 8ричн. вектора
  procedure obmen(var a,b:integer);
  procedure tasyuu(P:PMaxIntMas;razm:integer);//razm - число элементов массива
  function proverka(P:pointer;Mx,My:byte):boolean;//проверка наличия всех чисел в массиве
  function napravlenie(dx,dy:integer):byte;//Ближайший вектор при известных отклонениях
  procedure Ylitka(Faza:word;var dx,dy:integer);//Раскручивает квадр улитку по фазе
  Function RectVRect(R1:TRect;var R2:TRect):boolean;//Выдает то что принадлежит обоим
  function KvadrMvRect(K:KvadrM):TRect;
  function MovRect(R:TRect;dx,dy:integer):TRect;//Сдвиг Rect
  function SizeRect(R:TRect;dx,dy:integer):TRect;//Изм размера
  procedure RandomVekt(var Vekt,dx,dy:shortint);//Неуправляемое движение
  function SinAB(sinA,sinB,cosA,cosB:real):real;//Синус суммы углов
  function CosAB(sinA,sinB,cosA,cosB:real):real;//Косинус суммы углов
  function Vokryg4N(v:shortint;Nm,maxX,maxY:integer):integer;//Цикл 0-3 в вектор Nm - № в массиве Dx,Dy - размер карты
  function Vekt4ToV(Vekt:byte):byte;//Преобразует вектор в долю цикла 0-3
  function NotVekt4(Vekt:byte):byte;//Поворачивает вектор в обратную сторону
implementation
function NotVekt4(Vekt:byte):byte;
var W:word;
  begin
    w:=Vekt;
    w:=W shl 2;
    BitToWord(W,0,BitIzWord(W,4));
    BitToWord(W,1,BitIzWord(W,5));
    BitToWord(W,4,false);
    BitToWord(W,5,false);
    result:=byte(W);
  end;
function Vekt4ToV(Vekt:byte):byte;
  begin
    Vekt:=Vekt shr 1;
    if Vekt>3 then Result:=3 else Result:=Vekt;
  end;
function Vokryg4N(v:shortint;Nm,maxX,maxY:integer):integer;//Nm - № в массиве Dx,Dy - размер карты
var X,Y:integer;
  begin
    X:=Nm mod maxX+MNm4[v];
    Y:=Nm div maxX+MNm4[v+3];
    if X<0 then X:=MaxX+X;
    if X>=MaxX then X:=X-MaxX;
    if Y<0 then Y:=MaxY+Y;
    if Y>=MaxY then Y:=Y-MaxY;
    result:=Y*MaxX+X;
  end;
function SinAB(sinA,sinB,cosA,cosB:real):real;//Синус суммы углов
 begin
   result:=sinA*cosB+sinB*cosA;
 end;
function CosAB(sinA,sinB,cosA,cosB:real):real;//Косинус суммы углов
 begin
   result:=cosA*cosB-sinA*sinB;
 end;
procedure RandomVekt(var Vekt,dx,dy:shortint);//Неуправляемое движение
 begin
   if vekt=8 then begin
     if random(12)<3 then vekt:=random(9);
                  end else begin
   if random(12)<2 then dec(Vekt);
   if random(12)>9 then inc(Vekt);
   if vekt<0 then vekt:=0;
   if vekt>8 then vekt:=8;
                           end;
   Vokryg(vekt,dx,dy);
 end;
function SizeRect(R:TRect;dx,dy:integer):TRect;
var rec:TRect;
 begin
   Rec.Left:=R.Left-dx;Rec.Right:=R.Right+dx;
   Rec.Top:=R.Top-dy;Rec.Bottom:=R.Bottom+dy;
   result:=rec;
 end;
function MovRect(R:TRect;dx,dy:integer):TRect;
var rec:TRect;
 begin
   rec.Left:=R.Left+dx;rec.Right:=R.Right+dx;
   rec.Top:=R.Top+dy;rec.Bottom:=R.Bottom+dy;
   result:=rec;
 end;
function KvadrMvRect(K:KvadrM):TRect;
 begin
   Result.Left:=k.x;Result.Right:=k.x+k.dx;
   Result.Top:=k.y;Result.Bottom:=k.y+k.dy;
 end;
Function RectVRect(R1:Trect;var R2:TRect):boolean;
 begin
   if R2.Left<R1.Left then R2.Left:=R1.Left;
   if R2.Right>R1.Right then R2.Right:=R1.Right;
   if R2.Top<R1.Top then R2.Top:=R1.Top;
   if R2.Bottom>R1.Bottom then R2.Bottom:=R1.Bottom;
   if(R2.Right-R2.Left<=0)or(R2.Bottom-R2.Top<=0)then result:=false else result:=true;
 end;
procedure Ylitka(Faza:word;var dx,dy:integer);
 var
   s,s0,r:integer;
   dF,F:real;
 begin
   if Faza=0 then begin dx:=0;dy:=0;exit end;
   r:=0;s:=0;
   repeat
   s0:=s;inc(r);s:=s0+r;
   until s*8>=Faza;
   dF:=Pi/(r*4);
   F:=(Faza-s0)*dF;
   dx:=trunc((r+1)*cos(F));
   dy:=trunc((r+1)*sin(F));
 end;
function proverka(P:pointer;Mx,My:byte):boolean;//проверка наличия всех чисел в массиве
 var w:Pmax2byte;
  b:maxwbyte;
  j:word;
 begin w:=p;fillchar(b,sizeof(b),0);
   for j:=0 to my*mx do begin
     if(w[j].x>mx)or(w[j].y>my)then begin result:=false;exit end;
     if b[w[j].y*mx+w[j].x]=0 then b[w[j].y*mx+w[j].x]:=1 else begin result:=false;exit end;
                        end;
   result:=true;
 end;
function rect_kv(r:TRect):kvadr;
 var k:kvadr;
   i:integer;
 begin
   i:=r.Right-r.Left;
   if i<0 then k.x:=r.Right else k.x:=r.Left;
   k.dx:=abs(i);
   i:=r.Bottom-r.Top;
   if i<0 then k.y:=r.Bottom else k.y:=r.Top;
   k.dy:=abs(i);
   result:=k;
 end;
function kv_rect(kv:kvadr):Trect;
 var r:TRect;
 begin
   r.Left:=kv.x;r.Top:=kv.y;r.Right:=kv.x+kv.dx;r.Bottom:=kv.y+kv.dy;
   result:=r;
 end;
function napravlenie(dx,dy:integer):byte;
var r:real;
  nv:byte;
begin
  if dy=0 then begin if dx<0 then result:=4 else result:=0;exit end;
  if dy>0 then begin if dx<0 then nv:=2 else nv:=0 end
    else begin if dx<0 then nv:=4 else nv:=6 end;
  r:=dx/dy;
  if r>0.41 then inc(nv);
  if r>2.41 then inc(nv);
  result:=nv;
end;
  procedure tasyuu(P:PMaxIntMas;razm:integer);
   var
     r:integer;
   begin
     for r:=0 to razm-1 do obmen(p[r],p[random(razm)])
   end;
  procedure obmen(var a,b:integer);
   var c:integer;
   begin
     c:=a;a:=b;b:=c;
   end;
  function PlusVektor(Vk0,Vk1:Byte):byte;
   label 0;
   var V0,V1,S0,S1:integer;
     yg:byte;
     pz:real;
   begin
     V0:=Vk0 mod 8;s0:=vk0 shr 3;
     v1:=vk1 mod 8;s1:=vk1 shr 3;
     if s1=0 then goto 0;
     if s0=0 then begin s0:=s1;v0:=v1;goto 0 end;
     if abs(v0-v1)>4 then yg:=8-abs(v0-v1)else yg:=abs(v0-v1);
     if s0-s1<0 then begin obmen(s0,s1);obmen(v0,v1)end;
     case yg of
     0: begin s0:=s0+s1 end;
     1: begin pz:=s1/s0;
          s0:=s0+round(pz*s1);
          end;
     2: begin pz:=s1/s0;
          if pz>0.75 then v0:=v0-1;
          s0:=s0+round(pz*s1);
          end;
     3: begin pz:=s1/s0;
          if pz>0.6 then v0:=v0-1;
          s0:=s0-round(pz*s1);
          end;
     4: begin s0:=s0-s1 end;
             end;
     if s0>31 then s0:=31;
     if v0<0 then v0:=7;
0:   Result:=s0 shl 3+v0
   end;
function VokrygN(v:shortint;Nm,MaxX,MaxY:integer):integer;
var x,y:integer;
  mx,my:shortint;
  begin
     if v<0 then v:=8+v;if v>8 then v:=v-9;
     if v=8 then begin result:=Nm;exit end;
     Vokryg(v,mx,my);
     x:=Nm mod MaxX+mx;
     y:=Nm div MaxX+my;
     if x<0 then x:=MaxX-1;
     if x=MaxX then x:=0;
     if y<0 then y:=MaxY-1;
     if y=MaxY then y:=0;
     result:=y*MaxX+x;
  end;
procedure Vokryg(v:shortint;var dx,dy:shortint);
   begin
     if v<0 then v:=8+v;if v>8 then v:=v-9;
     if v=8 then begin dy:=0;dx:=0;exit end;
       dy:=vekt[v];dx:=vekt[v+2]
   end;
  function Tochvrect(x,y:integer;Rk:trect):boolean;
   begin
     if(x>=rk.left)and(x<=rk.right)and(y>=rk.top)and(y<=rk.Bottom)then
       result:=true else result:=false;
   end;
end.
