unit matematikBS;

interface
Type
MInteger=^EInteger;
EInteger=record
 P:MInteger;
 I:Integer;
     end;
MWord=^EWord;
EWord=record
 P:MWord;
 I:Word;
     end;
  TWordSteck=class (TObject)
private
     Er:boolean;
     MI,DI:MWord;// MI должна всегда указывать на первый элемент стека
                    //DI - текущий элемент DSeek-номер текущего элемента
     ChInt,DSeek:integer;//ChInt - число элементов в стеке
public
     constructor create;virtual;
     procedure ADD(vs:word);//Добавление записи в конец списка
     procedure DEL;  // Удаление текущего елемента списка
     procedure ADD_N(n:integer;vs:word);//добавление новой записи в позицию N со смещением всех остальных
     procedure DEL_N(n:integer);// Удаление записи из позиции N
     procedure Cenge_N(n:integer;vs:word);
     function Int_N(n:integer):word;//вывод числа под номером n
     procedure seek_N(n:integer);// переход к записи с номером n
     function Int_Seek:word;// чтение текущего элемента списка и увеличение номера
       //для начала чтения необходимо выполнить протцедуру установки Seek_N
     procedure clear;          //стирание стека
     destructor destroy;override;
     function ChisloInt:integer;//Подсчет количества в стеке
     function ChiInt:integer;  //Число ChInt;
     procedure ToFile(imf:string);
     procedure OutFile(imf:string);
     procedure OutFile_N(Nom,Kol:integer;imf:string);
     function Err:boolean;
                end;
  TIntegerSteck=class (TObject)
private
     MI,DI:MInteger;// MI должна всегда указывать на первый элемент стека
                    //DI - текущий элемент DSeek-номер текущего элемента
     ChInt,DSeek:integer;//ChInt - число элементов в стеке.
public
     Er:boolean;
     constructor create;virtual;
     procedure ADD(vs:integer);//Добавление записи в конец списка
     procedure DEL;  // Удаление текущего елемента списка
     procedure ADD_N(n:integer;vs:integer);//добавление новой записи в позицию N со смещением всех остальных
     procedure DEL_N(n:integer);// Удаление записи из позиции N
     procedure Cenge_N(n:integer;vs:Integer);
     function Int_N(n:integer):Integer;//вывод числа под номером n
     procedure seek_N(n:integer);// переход к записи с номером n
     function Int_Seek:Integer;// чтение текущего элемента списка и увеличение номера
       //для начала чтения необходимо выполнить протцедуру установки Seek_N
     procedure clear;          //стирание стека
     destructor destroy;override;
     function ChisloInt:integer;//Подсчет количества в стеке
     function ChiInt:integer;  //Число ChInt;
     procedure ToFile(imf:string);
     procedure OutFile(imf:string);
     procedure OutFile_N(Nom,Kol:integer;imf:string);
     function Err:boolean;
                end;
 Function Vichislitel(S:String):real;
 Function ByteIzInteger(I:integer;n:byte):byte; //n - c 0
 Function BitIzWord(W,n:word):boolean;
 Procedure BitToWord(var W:word;const n:word;z:boolean);
implementation
 Procedure BitToWord(var W:word;const n:word;z:boolean);
var D:word;
begin
  D:=W;
  if z then begin
  asm
    MOV  AX,D  ;
    MOV  DX,N;
    BTS  AX,DX  ;
    MOV  D,AX  ;
  end;
            end else begin
  asm
    MOV  AX,D  ;
    MOV  DX,N;
    BTR  AX,DX  ;
    MOV  D,AX  ;
  end;
                     end;
    W:=D;
end;
 Function BitIzWord(W,n:word):boolean;
var r:word;
label En;
  begin
  R:=0;
asm
        MOV     AX,W ;
        MOV     DX,N ;
        BT      AX,DX;
        JAE     en   ;
        MOV     R,1  ;
En:
end;
        if R=0 then result:=false else result:=true;
   end;
 Function ByteIzInteger(I:integer;n:byte):byte; //n - c 0
var r,d:integer;
  b:byte;
begin
  r:=I shl((3-n)*8);
  d:=r shr 24;
  b:=byte(d);
  result:=b;
end;
 Function Vichislitel(S:String):real;
var r:integer;Skobka:integer;
    S0:string[255];
    Deistvie:Char;
    Razdel:byte;
begin
   s0:=s;Skobka:=0;Deistvie:='_';Razdel:=0;
   for r:=1 to length(s0)do begin//ищем * /
     case s0[r]of
'(':  inc(Skobka);
')':  dec(Skobka);
'*','/': if Skobka=0 then begin Deistvie:=s0[r];Razdel:=r;break end;
               end;
                            end;
   if razdel=0 then begin//Функция незакончена
                    end;
   result:=0;
end;
function TWordSteck.Err:boolean;
 begin
   result:=Er;Er:=false;
 end;
procedure TWordSteck.OutFile_N(Nom,Kol:integer;imf:string);
var f:File of Word;
  Int:Word;
  r:integer;
 begin
     assignFile(f,imf);
     Reset(f);r:=0;
     While(not eof(f))and(r<Nom+Kol)do begin
       Read(f,int);
       if r>=Nom then ADD(Int);
       inc(r)
                        end;
     closefile(f);
 end;
function TWordSteck.ChiInt:integer;  //Число ChStr;
 begin Result:=ChInt end;
procedure TWordSteck.OutFile(imf:string);
var f:File of Word;
  Int:Word;
 begin
   clear;
     assignFile(f,imf);
     Reset(f);
     While not eof(f)do begin
       Read(f,Int);
       ADD(Int);
                        end;
     closefile(f);
 end;
procedure TWordSteck.ToFile(imf:string);
var f:File of Word;
  Int:Word;
 begin
   seek_n(1);
   AssignFile(f,imf);
   ReWrite(f);
   while DSeek>0 do begin
     Int:=Int_Seek;
     Write(f,int);
                    end;
   CloseFile(f);
 end;
procedure TWordSteck.clear;
var W:MWord;
 begin
   while MI<>nil do begin
     w:=mI.p;freemem(MI);MI:=w;DI:=nil;DSeek:=0;
                   end;
   ChInt:=0;
 end;
function TWordSteck.Int_Seek:Word;
var W:MWord;
 begin
 Er:=false;
 if DI<>nil then begin
   result:=DI.I;w:=DI;DI:=W.P;dec(DSeek);
                 end else begin Er:=true;result:=0 end;
 end;
procedure TWordSteck.seek_N(n:integer);
var W,Q:MWord;
  n0:integer;
 begin
   n0:=1;Q:=MI;Er:=false;
   if n<2 then begin DI:=MI;Dseek:=ChInt;exit end;
   while Q<>nil do begin
     if(n0=n)or(n0=ChInt)then begin
       DI:=Q;Dseek:=ChInt-n0+1;exit;
                  end;
     w:=Q.p;Q:=w;inc(n0);
                   end;
 end;
function TWordSteck.Int_N(n:integer):Word;
var W,Q:MWord;
  n0:integer;
 begin
   Er:=false;
   if(n<1)or(n>ChInt)then begin Er:=true;result:=0;exit end;
   n0:=1;Q:=MI;
   while Q<>nil do begin
     if n0=n then begin
       result:=Q.I;
       exit;
                  end;
     w:=Q.p;Q:=w;inc(n0);
                   end;
 end;
procedure TWordSteck.Cenge_N(n:integer;vs:Word);
var W,Q:MWord;
  n0:integer;
 begin
   if(n<1)or(n>ChInt)then exit;
   n0:=1;Q:=MI;
   if n=1 then DI.I:=vs;
   while Q<>nil do begin
     if n0=n then begin
       Q.I:=vs;
       exit;
                  end;
     w:=Q.p;Q:=w;inc(n0);
                   end;
 end;
procedure TWordSteck.DEL_N(n:integer);
var W,Q,E:MWord;
  n0:integer;
 begin
   if(n<1)or(n>ChInt)then exit;
   n0:=1;Q:=MI;E:=Q;
   if n=1 then begin del;exit end;
   while Q<>nil do begin
     if n0=n then begin
       E.P:=Q.P;freemem(Q);dec(ChInt);
       exit;
                  end;
     E:=Q;w:=Q.p;Q:=w;inc(n0);
                   end;
 end;
procedure TWordSteck.ADD_N(n:integer;vs:Word);
var W,Q,E:MWord;
  n0:integer;
 begin
   if(n<0)or(n>ChInt)then exit;
   if n=0 then begin
     add(vs);exit
               end;
   n0:=1;Q:=MI;
   while Q<>nil do begin
     if n0=n then begin
       new(E);inc(ChInt);W:=Q.P;Q.P:=E;E.P:=w;
       E.I:=vs;exit;
                  end;
     w:=Q.p;Q:=w;inc(n0);
                   end;
 end;
procedure TWordSteck.DEL;
var W:MWord;
 begin
   if MI<>nil then begin
     w:=MI.p;
     freemem(MI);MI:=w;dec(ChInt);
                   end;
 end;
function TWordSteck.ChisloInt:integer;
var W,Q:MWord;
 begin
   ChInt:=0;Q:=MI;
   while Q<>nil do begin
     w:=Q.p;Q:=w;inc(ChInt);
                   end;
   Result:=ChInt;
 end;
destructor TWordSteck.destroy;
 begin
   clear;
   inherited destroy;
 end;
constructor TWordSteck.create;
 begin
   inherited create;
   mI:=nil;ChInt:=0;DSeek:=0;
 end;
procedure TWordSteck.ADD(vs:Word);
var W:MWord;
 begin
   New(W);inc(ChInt);W.I:=vs;
   W.p:=MI;MI:=W;
 end;
//--------------------------------------------------------------
function TIntegerSteck.Err:boolean;
 begin
   result:=Er;Er:=false;
 end;
procedure TIntegerSteck.OutFile_N(Nom,Kol:integer;imf:string);
var f:File of integer;
  Int:Integer;
  r:integer;
 begin
     assignFile(f,imf);
     Reset(f);r:=0;
     While(not eof(f))and(r<Nom+Kol)do begin
       Read(f,int);
       if r>=Nom then ADD(Int);
       inc(r)
                        end;
     closefile(f);
 end;
function TIntegerSteck.ChiInt:integer;  //Число ChStr;
 begin Result:=ChInt end;
procedure TIntegerSteck.OutFile(imf:string);
var f:File of integer;
  Int:Integer;
 begin
   clear;
     assignFile(f,imf);
     Reset(f);
     While not eof(f)do begin
       Read(f,Int);
       ADD(Int);
                        end;
     closefile(f);
 end;
procedure TIntegerSteck.ToFile(imf:string);
var f:File of integer;
  Int:integer;
 begin
   seek_n(1);
   AssignFile(f,imf);
   ReWrite(f);
   while DSeek>0 do begin
     Int:=Int_Seek;
     Write(f,int);
                    end;
   CloseFile(f);
 end;
procedure TIntegerSteck.clear;
var W:MInteger;
 begin
   while MI<>nil do begin
     w:=mI.p;freemem(MI);MI:=w;DI:=nil;DSeek:=0;
                   end;
   ChInt:=0;
 end;
function TIntegerSteck.Int_Seek:integer;
var W:MInteger;
 begin
 Er:=false;
 if DI<>nil then begin
   result:=DI.I;w:=DI;DI:=W.P;dec(DSeek);
                 end else begin Er:=true;result:=0 end;
 end;
procedure TIntegerSteck.seek_N(n:integer);
var W,Q:MInteger;
  n0:integer;
 begin
   n0:=1;Q:=MI;Er:=false;
   if n<2 then begin DI:=MI;Dseek:=ChInt;exit end;
   while Q<>nil do begin
     if(n0=n)or(n0=ChInt)then begin
       DI:=Q;Dseek:=ChInt-n0+1;exit;
                  end;
     w:=Q.p;Q:=w;inc(n0);
                   end;
 end;
function TIntegerSteck.Int_N(n:integer):Integer;
var W,Q:MInteger;
  n0:integer;
 begin
   Er:=false;
   if(n<1)or(n>ChInt)then begin Er:=true;result:=0;exit end;
   n0:=1;Q:=MI;
   while Q<>nil do begin
     if n0=n then begin
       result:=Q.I;
       exit;
                  end;
     w:=Q.p;Q:=w;inc(n0);
                   end;
 end;
procedure TIntegerSteck.Cenge_N(n:integer;vs:integer);
var W,Q:MInteger;
  n0:integer;
 begin
   if(n<1)or(n>ChInt)then exit;
   n0:=1;Q:=MI;
   if n=1 then DI.I:=vs;
   while Q<>nil do begin
     if n0=n then begin
       Q.I:=vs;
       exit;
                  end;
     w:=Q.p;Q:=w;inc(n0);
                   end;
 end;
procedure TIntegerSteck.DEL_N(n:integer);
var W,Q,E:MInteger;
  n0:integer;
 begin
   if(n<1)or(n>ChInt)then exit;
   n0:=1;Q:=MI;E:=Q;
   if n=1 then begin del;exit end;
   while Q<>nil do begin
     if n0=n then begin
       E.P:=Q.P;freemem(Q);dec(ChInt);
       exit;
                  end;
     E:=Q;w:=Q.p;Q:=w;inc(n0);
                   end;
 end;
procedure TIntegerSteck.ADD_N(n:integer;vs:integer);
var W,Q,E:MInteger;
  n0:integer;
 begin
   if(n<0)or(n>ChInt)then exit;
   if n=0 then begin
     add(vs);exit
               end;
   n0:=1;Q:=MI;
   while Q<>nil do begin
     if n0=n then begin
       new(E);inc(ChInt);W:=Q.P;Q.P:=E;E.P:=w;
       E.I:=vs;exit;
                  end;
     w:=Q.p;Q:=w;inc(n0);
                   end;
 end;
procedure TIntegerSteck.DEL;
var W:MInteger;
 begin
   if MI<>nil then begin
     w:=MI.p;
     freemem(MI);MI:=w;dec(ChInt);
                   end;
 end;
function TIntegerSteck.ChisloInt:integer;
var W,Q:MInteger;
 begin
   ChInt:=0;Q:=MI;
   while Q<>nil do begin
     w:=Q.p;Q:=w;inc(ChInt);
                   end;
   Result:=ChInt;
 end;
destructor TIntegerSteck.destroy;
 begin
   clear;
   inherited destroy;
 end;
constructor TIntegerSteck.create;
 begin
   inherited create;
   mI:=nil;ChInt:=0;DSeek:=0;
 end;
procedure TIntegerSteck.ADD(vs:integer);
var W:MInteger;
 begin
   New(W);inc(ChInt);W.I:=vs;
   W.p:=MI;MI:=W;
 end;

end.
