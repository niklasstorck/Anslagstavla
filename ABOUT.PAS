unit About;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, Global, jpeg;

type
  TAboutBox = class(TForm)
    OKButton: TBitBtn;
    Image1: TImage;
    L_Copyright: TLabel;
    L_Version: TLabel;
    L_ProductName: TLabel;
    Label_company: TLabel;
    Label_mail: TLabel;
    procedure OKButtonClick(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutBox: TAboutBox;

implementation

{$R *.DFM}

procedure TAboutBox.OKButtonClick(Sender: TObject);
begin
   Close;
end;

procedure TAboutBox.Image1Click(Sender: TObject);
begin
  Application.MessageBox( 'Du skall trycka p� OK-knappen f�r att st�nga',
                          'Aj, Aj!',IDOK);
end;

procedure TAboutBox.FormActivate(Sender: TObject);
begin
  L_Productname.Caption:='Anslagstavlan';
  L_Version.Caption:=c_Version;
  L_Copyright.Caption:=c_Copyright;
  Label_Company.Caption:=c_company+' '+c_year;
  Label_mail.Caption:=c_mail;
end;



end.

