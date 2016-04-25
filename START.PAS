// ***************************************************************************
// Version 1.8.1
// Förbättrad felhantering klarar filer som inte är
// läsbara trots att dom går att se i filsystemet
//
// V 1.8.1.13
// Datumknappen lägger nu in datum på cursorns plats
//
// Version 1.8.2
// Ikon på system tray
// Programmet dolt när det minimeras.
// Uppdatering av eget Memo direkt när ny text skrivs
// Global inifil för systemansvarig.
// Färg och fonthantering i global.ini
//
// V 1.8.4 Avstängningsmöjlighet för "up-poppning"
//
// Version 1.8.5 Beta...
// Fillåsning på textfilen med Time out.
// Detta är en test som har vissa risker.

// 1.9.0 Omkompilering pga problemet med felmedelande vid nätverksproblem.
//
// ***************************************************************************
// Niklas Storck
// Hb Storckholmen 1994 - 2016
// ***************************************************************************

unit Start;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Menus, ExtCtrls, StdCtrls,
  registry,inifiles ,about, ChTxt, Grids;
(*
Const c_Version = '1.8';
      c_Year = '1998';
      c_Copyright = 'Niklas Storck';*)
type
  TStartForm = class(TForm)
    Memo1: TMemo;
    PopupMenu1: TPopupMenu;
    Avsluta1: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    Timer1: TTimer;
    ButtonKrymp: TButton;
    N1: TMenuItem;
    Om1: TMenuItem;
    ndraMedelande1: TMenuItem;
    Label1: TLabel;
    SPoppUpp1: TMenuItem;
    TrayIcon1: TTrayIcon;
    procedure FormActivate(Sender: TObject);
    procedure Avsluta1Click(Sender: TObject);
    procedure ppnanyfil1Click(Sender: TObject);
    procedure Sparasom1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure ButtonKrympClick(Sender: TObject);
    procedure Om1Click(Sender: TObject);
    procedure ndraMedelande1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TaskIcon1Click(Sender: TObject);
    procedure Ingenram1Click(Sender: TObject);
    procedure SPoppUpp1Click(Sender: TObject);
    //procedure Timer2Timer(Sender: TObject);

  private
    // Private declarations
    FN        : String;     // Aktuellt filnamn
    FDate     : TdateTime;  // Sparat datum och tid på infofil
    FileOK    : Boolean;    //
    UppdatSek : Integer;    // Antal sekunde mellan uppdatering av info
    PathEXE   : String;     // Path to exefile.
    MemoColor : TColor;     // Färg på memobakgrund
    function  FS(fn:String):Longint;
    Procedure Fel(FN, S:String); // generell flehanterare;
    procedure WriteSetup;
    procedure ReadSetup;
    procedure MemoResize;
    function my_Repaint:Boolean;
    procedure AppMinimize(Sender: TObject);
    function  GetNewDate(FNL:String):TDateTime;
    procedure OnScreen;
  public
    // Public declarations
  end;

var
  StartForm: TStartForm;

implementation

{$R *.DFM}

Procedure TStartForm.Fel(FN, S:String); // generell felhanterare;
var st: String;
begin
  if FileOk then // Om FileOK = TRUE så är det första gången felet uppträder
   begin
     FileOK:=FALSE;
     Timer1.Interval:=UppdatSek*500;  // Ändra uppdateringsintervallet -> *10
     st:='Nätverksfel! Filen "'+FN+'" går ej att hitta! Plats i programkod: '+S;
     //Application.Messagebox('Filen är inte tillgänglig just nu.','OBS!',IDOK);
     Label1.Caption:=st;
   end
  // Annars strunta i felet som sannolikt endast är följdfel.
end;

function TStartForm.FS(fn:String):Longint;
var f:File of byte;
begin
 try
  AssignFile(f, fn);
  Reset(f);
  FS := FileSize(f);
  CloseFile(f)
 except
  FS:= 0;
  Fel(FN,'122');
 end
end;

function TStartForm.GetNewDate(FNL:String):TDateTime;
var DT: TDateTime;
begin
  try
    FileAge(FNL,DT);
    GetNewDate:=DT;
  except
    GetNewdate:=0;
    Fel(FNL,'136');
  end
end;


procedure TStartForm.WriteSetup;
var
  Ini: TRegIniFile;
begin
  // Write to local configurationfile "info.ini"
  try
    Ini := TRegIniFile.Create('Anslagstavlan');
    Ini.WriteInteger('Configuration', 'Left',   Left);
    Ini.WriteInteger('Configuration', 'Top',    Top);
    Ini.WriteInteger('Configuration', 'Width',  Width);
    Ini.WriteInteger('Configuration', 'Height', Height);
    Ini.WriteBool('Configuration', 'Popup', SPoppupp1.checked );
    Ini.Free
  except
    Application.messagebox(
    'Systeminställningarna tillåter inte Anslagstavlan att spara fönstrets position. ',
        'OBS! Info.ini är låst!',
        MB_OK)
  end;
end;

procedure TStartForm.ReadSetup;
var
  Ini: TRegIniFile;
  IniF: TIniFile;
begin
  // ***************************************************************************
  // Läs inställningar i den lokala inifilen.
  // Grundinställningar om det inte finns data första starten
  // ***************************************************************************
  Ini       := TRegIniFile.Create('Anslagstavlan');

  Left      := Ini.ReadInteger( 'Configuration', 'Left',   Screen.Width div 4);
  Top       := Ini.ReadInteger( 'Configuration', 'Top',    Screen.Height div 7);
  Width     := Ini.ReadInteger( 'Configuration', 'Width',  Screen.Width div 2);
  Height    := Ini.ReadInteger( 'Configuration', 'Height', Screen.Height div 3 * 2);
  SPoppUpp1.checked:= Ini.readbool('Configuration', 'Popup', TRUE);

  Ini.Free;

  // ***************************************************************************
  // Ta reda på vilket bibliotek exefilen startat från
  // ***************************************************************************
  pathEXE   := ExtractFilePath(Application.Exename);

  // ***************************************************************************
  // Och läs in data från GLOBAL.INI på detta bibliotek
  // Global.ini är inte en inifil som programmet gör utan en fil för gemensamma
  // inställningar
  // ***************************************************************************
  IniF       := TIniFile.Create( PathEXE+'global.ini');

  UppdatSek := IniF.ReadInteger( 'SystemConfiguration', 'UppdatSek',UppdatSek);
  if UppDatSek < 10 then UppDatSek:=10; // Minsta uppdateringsintervall
  FN        := IniF.ReadString(  'SystemConfiguration', 'Infofilename', PathEXE+'info.txt');
  Caption   := IniF.ReadString(  'SystemConfiguration', 'Caption', 'Kan inte läsa Global.ini!');

  MemoColor := IniF.ReadInteger( 'SystemConfiguration', 'MemoColor',clNavy);
  memo1.Color:=MemoColor;
  Memo1.Font.Name  := IniF.ReadString(  'SystemConfiguration', 'MemoFontName', 'Arial');
  Memo1.Font.Color := IniF.ReadInteger( 'SystemConfiguration', 'MemoFontColor',clWhite);
  Memo1.Font.Size  := IniF.ReadInteger( 'SystemConfiguration', 'MemoFontSize', 10);

  if IniF.ReadString('SystemConfiguration', 'MemoFontFet', 'Ja') = 'Ja' then
    Memo1.Font.Style:=Memo1.Font.Style+[fsBold]
  else
    Memo1.Font.Style:=Memo1.Font.Style-[fsBold];

  if IniF.ReadString('SystemConfiguration', 'MemoFontKursiv', 'Nej') = 'Ja' then
    Memo1.Font.Style:=Memo1.Font.Style+[fsItalic]
  else
    Memo1.Font.Style:=Memo1.Font.Style-[fsItalic];

  IniF.Free;

end;

procedure TStartForm.OnScreen;
begin
  // ***************************************************************************
  // Lite säkerhetsrutiner så att inte bilden hamnar utanför skärmen
  // ***************************************************************************
  (*
  if left < 0 then left:= 1;
  if top < 0 then top:=1;
  if width + left > Screen.Width then left:=Screen.Width-width;
  if height + top > Screen.height then top:=Screen.height-height;
  *)
end;


procedure TStartForm.MemoResize;
begin
  // ***************************************************************************
  // Justerar knappar och memo1 så att dom passar vid alla storlekar
  // ***************************************************************************
  Memo1.Left:=5;
  Memo1.Top:=5;
  Memo1.Width:=ClientWidth-10;
  Memo1.Height:=ClientHeight-ButtonKrymp.Height-15;
  ButtonKrymp.Left:=ClientWidth-10-ButtonKrymp.Width;
  ButtonKrymp.Top:=ClientHeight-ButtonKrymp.Height-5;
  Label1.Left:=15;
  Label1.Top:=ClientHeight-Label1.Height-5;
  if Memo1.Lines.Count*1.64 >  Memo1.Height /Memo1.Font.Size
   then  Memo1.Scrollbars:=ssVertical
   else  Memo1.Scrollbars:=ssNone;
  if not SPoppUpp1.Checked then
    Startform.Show;
end;

procedure TStartForm.AppMinimize(Sender: TObject);
begin
  //ShowWindow(Application.Handle, SW_HIDE);
end;


procedure TStartForm.FormActivate(Sender: TObject);
begin
  // ***************************************************************************
  // Initiering av huvudfönster
  // ***************************************************************************
  Application.OnMinimize:=AppMinimize;
  //Application.Minimize;
  AppMinimize(@Self);
  Memo1.Clear;
  FileOK:=TRUE;
  ReadSetup;
  Timer1.Interval:=UppdatSek*1000; // Sekunder --> millisekunder
  FDate:=0;

  // ***************************************************************************
  // Om programmet startar med en parameter läser programmet in
  // den filen i stället
  // ***************************************************************************
  if paramcount > 0 then
  begin
    FN:=Paramstr(1);
  end;

  // ***************************************************************************
  // Läs in filen FN och initiera FDATE med filens datumstämpel
  // ***************************************************************************
  if fileExists(FN) then
   begin

    try
      FileOK:=TRUE;
      Memo1.Lines.LoadFromFile(FN);
      FDate:=GetNewDate(FN);
    except
      Fel(FN,'286' )
    end;

    if FDate > 0 then
      Label1.Caption:=FormatDateTime('"Ändrad senast" dddd "den" d mmmm yyyy, ' +
        '"kl." hh:mm', FDate)
    else
      Label1.Caption:='Fel på filens datum';

   end
  else
   begin
     Fel(FN,'296');
   end;

  if Memo1.Lines.Count > Height /12
   then  Memo1.Scrollbars:=ssVertical
   else  Memo1.Scrollbars:=ssNone;

  if Memo1.Lines[0]='OBS!'
  then  Memo1.Color:=clRed
  else Memo1.Color:=MemoColor;

  MemoResize;
  //CoolTrayIcon1.Enabled:=TRUE;
end;

procedure TStartForm.Avsluta1Click(Sender: TObject);
begin
  WriteSetup;
  Close;
end;

procedure TStartForm.ppnanyfil1Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    FN:=OpenDialog1.Filename;
    if fileexists(FN) and (FS(FN) <32000) then
     begin
       Memo1.lines.LoadFromFile(FN);
       FDate:=GetNewDate(FN);
       FileOK:=TRUE;
       Timer1.Enabled:=TRUE
     end
    else
     begin
      Memo1.lines[0]:='Det går inte att läsa filen : '+FN;
      Memo1.lines[1]:='Filstorlek '+IntToStr(FS(FN))+' bytes.';
      Timer1.Enabled:=FALSE;
     end;
    WriteSetup;
    MemoResize;
  end

end;

procedure TStartForm.Sparasom1Click(Sender: TObject);
begin
   while SaveDialog1.Execute do
   begin
     Memo1.Lines.SavetoFile(Savedialog1.Filename)
   end;
end;

function TStartForm.my_Repaint:Boolean;
var Date : TDateTime;
begin
  my_Repaint:=TRUE;
   try
      Date:=GetNewDate(FN);
      if Date > 0 then
       begin
        Timer1.Interval:=UppdatSek*1000; // Återställ timern till normalt
        Label1.Caption:=FormatDateTime('"Ändrad senast" dddd "den" d mmmm yyyy, ' +
         '"kl." hh:mm', FDate)
       end;
      if FDate  <  Date then    // Kolla om Tiden när filen sparades har ändrats
                                // Läs i så fall in den nya filen.
       begin
         Memo1.lines.LoadFromFile(FN);

         FDate:=Date;
         //if Memo1.Lines[0]='OBS!'
         //then  Memo1.Color:=clRed
         //else Memo1.Color:=clNavy;


         Onscreen;
         Label1.Caption:=FormatDateTime('"Ändrad senast" dddd "den" d mmmm yyyy, ' +
         '"kl." hh:mm', FDate);
         WindowState := wsNormal;
         StartForm.BringToFront;
         MemoResize;
        end;
   except  { DVS. Om det inte går att läsa filen}
     my_Repaint:=FALSE;
     Fel(FN,'381');
   end;
   Onscreen;
end;


procedure TStartForm.Timer1Timer(Sender: TObject);

begin
   FILEOK:=my_Repaint;

   //OnScreen;
end;

procedure TStartForm.ButtonKrympClick(Sender: TObject);
begin
   //WindowState := wsMinimized;
   //Startform.Hide;
  Startform.Hide
end;


procedure TStartForm.Om1Click(Sender: TObject);
begin
  AboutBox.Show;
end;


procedure TStartForm.ndraMedelande1Click(Sender: TObject);
begin
  if FileExists(FN) then
    begin
      ChngForm.FN:=FN;
      ChngForm.ShowModal;
      my_Repaint
    end
  else
    begin
      Application.Messagebox('Filen är inte tillgänglig just nu, försök lite senare.','OBS!',IDOK);
      Fel(FN,'420');
    end;

end;

procedure TStartForm.FormResize(Sender: TObject);
begin
  MemoResize;
  OnScreen;
  {WriteSetup;}
end;

procedure TStartForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   WriteSetup;
   //DCMinTray.;
   Application.Terminate;
end;



procedure TStartForm.TaskIcon1Click(Sender: TObject);
begin
  //Startform.Show;
  //CoolTrayIcon1.ShowMainForm;
  Startform.Show
end;

procedure TStartForm.Ingenram1Click(Sender: TObject);
begin
(*
  StartForm.Hide;
  StartForm.BorderStyle:=bsNone;
  StartForm.Visible:=true;
  *)
end;

procedure TStartForm.SPoppUpp1Click(Sender: TObject);
begin
  if SPoppUpp1.Checked then
     SPoppUpp1.Checked:=FALSE
  else SPoppUpp1.Checked:=TRUE;
end;



end.

