unit MiConst;
interface
Uses Graphics;
Const
  MaxIndeksMas=999999999;
  MaxIntIndex=99999999;
  MaxWord=65535;
type
  s2=string[2];s3=string[3];
  s5=string[5];s12=string[12];s16=string[16];s24=string[24];s32=string[32];
  s48=string[48];s64=string[64];s128=string[128];s255=string[255];
  MaxMas=array[0..MaxIndeksMas]of byte;
  MaxIntMas=array[0..MaxIntIndex]of integer;
  PMaxIntMas=^MaxIntMas;
  PMaxMas=^MaxMas;
  MasBB=array[byte]of byte;
  PMasBB=^MasBB;

  TTochka2=record
    X,Y:integer;
           end;

  TZagolovokMasMasok=record
    K:integer;
    sizeW:integer;
    size:array[1..12]of integer;
    Storon:array[1..12]of TTochka2;
                     end;
  TMasMasok=record
    zag:TZagolovokMasMasok;
    Pm:PMaxMas;
            end;
  CvetBMP=array[0..3]of byte;
  PalitraBMP=array[0..255] of CvetBMP;
  ZagolovokBMP=record     //1078 байт   структуру нельзя писать и читать
    Char1,Char2:AnsiChar;//'B''M'      0   одним куском из за округления
    bfSize:Longint;             //     2   её размера компилятором
    bfReserved1_0,bfReserved2_0:word;//6
    bfOffBits:Longint;// 1078          10
    biSize40,biWidth,biHeight:Longint;//14
    biPlanes1,biBitCount8:word;//
    biCompress0,biSizeImage0,biXPerMetr,biYPerMetr,biClrUsed0,biClrImp0:Longint;
    Pal:PalitraBMP;
               end;
{  TMouseClick=procedure(Sender: TObject;X,Y:integer) of object;
  TMouseClickLR=procedure(Sender: TObject;X,Y:integer;LR:Char) of object;
  TTipSk = (od_od,od_dv,dv_od);
  TVidSk = (Front,Lst,Zad,Pst,Fdver,Zdver,Lper,Pper);
  FontText=record
ImFont:s24;
Height:integer;
Style:TFontStyles;
Color:TColor;
           end; }
Const
  DlStr0='0';
  DlStr3='123';
  DlStr5='12345';
  DlStr6='123456';
  DlStr12='123456789012';
  DlStr24='123456789012345678901234';
  DlStr32='12345678901234567890123456789012';
  DlStr48='123456789012345678901234567890123456789012345678';
  DlStr64='1234567890123456789012345678901234567890123456789012345678901234';
  ConstVid:array[0..7]of S24=('Спереди','Лев. стенка','Сзади','Прав. стенка','Передняя дверца','Задняя дверца',
             'Перегор. слева','Перегор. справа');
  ConstTip:array[0..2]of S24=('Одностор. однодвер','Двухстор. однодвер','Одностор. двухдверн');



implementation

end.
 