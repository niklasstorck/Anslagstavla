{
Den h�r uniten ineh�ller kod f�r implementeringen
av �ndra medelande dialogen.
}

unit Chtxt;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, TabNotBk, Buttons, Menus, Dialogs, ComCtrls;

type
  TChngForm = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    ButtonDate: TButton;
    Memo1: TMemo;
    Timer1: TTimer;
    procedure FormActivate(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure Cut1Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure Paste1Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure ButtonDateClick(Sender: TObject);
    function CheckAvail(FN:String): Boolean;
    //procedure StoTime(S:String; var T : TDateTime);

    private
    EditStart: TDateTime;

    public
    TextColor,
    MemoColor : Tcolor;
    FN: String { Filnamn till infotexten}

  end;

var
  ChngForm: TChngForm;

implementation

//uses Start;

{$R *.DFM}

procedure TChngForm.FormActivate(Sender: TObject);
begin

  if CheckAvail(FN) = true then
    begin
    EditStart:=Now;
    Memo1.Modified:=FALSE;
    Memo1.Lines.LoadfromFile(FN)
    end
  else
end;

function TChngForm.CheckAvail(FN:string): Boolean;
var F : Textfile;
    S : string;
begin
  CheckAvail:=TRUE;
  try
    AssignFile(F,FN);
    Reset(F);
    Readln(F, S);
    CloseFile(F);
  except
    Application.MessageBox('Filen g�r inte att l�sa just nu, troligen n�tverksfel','Fel',IDOK);
    CheckAvail:=FALSE;
    Exit;
  end;

end;


procedure TChngForm.BitBtn1Click(Sender: TObject);
begin
  if Memo1.Modified and (FN<>'')
  then
    begin
     Memo1.Lines.SaveToFile(FN);
    end
end;

procedure TChngForm.Cut1Click(Sender: TObject);
begin
  Memo1.ClearSelection;
end;

procedure TChngForm.Copy1Click(Sender: TObject);
begin
  Memo1.CopyToClipBoard;
end;

procedure TChngForm.Paste1Click(Sender: TObject);
begin
  Memo1.PasteFromClipboard
end;

procedure TChngForm.BitBtn3Click(Sender: TObject);
begin
  {Aktivera Help}

end;



procedure TChngForm.ButtonDateClick(Sender: TObject);
begin
  Memo1.SetFocus;
  Memo1.Seltext:=FormatDateTime('dddd "den" d mmmm yyyy, "kl." hh:mm', Now);
  Memo1.SelLength:=0;
end;

end.
