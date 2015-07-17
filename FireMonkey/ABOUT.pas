unit About;

interface

//** Converted with Mida BASIC 277     http://www.midaconverter.com



Uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.IniFiles,
  Data.DB,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Dialogs,
  FMX.Objects,
  FMX.Menus,
  FMX.Grid,
  FMX.ExtCtrls,
  FMX.ListBox,
  FMX.TreeView,
  FMX.Memo,
  FMX.TabControl,
  FMX.Layouts,
  FMX.Edit,
  FMX.Platform,
  FMX.Bind.DBEngExt,
  FMX.Bind.Editors,
  FMX.Bind.DBLinks,
  FMX.Bind.Navigator,
  Data.Bind.EngExt,
  Data.Bind.Components,
  Data.Bind.DBScope,
  Data.Bind.DBLinks,
  Datasnap.DBClient,
  Fmx.Bind.Grid,
  System.Rtti,
  System.Bindings.Outputs,
  Data.Bind.Grid,
  Fmx.StdCtrls,
  FMX.Header,
  FMX.Graphics,

  Global;



//**   Original VCL Uses section : 


//** WINTYPES, WINPROCS, CLASSES, GRAPHICS, FORMS, CONTROLS, STDCTRLS,
//**   Buttons, ExtCtrls, Global, jpeg;


type
  TAboutBox = class(TForm)
    OKButton: TButton;
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

{$R *.FMX}

procedure TAboutBox.OKButtonClick(Sender: TObject);
begin
   Close;
end;

procedure TAboutBox.Image1Click(Sender: TObject);
begin
  //Application.MessageBox( 'Du skall trycka på OK-knappen för att stänga',
   //                       'Aj, Aj!',IDOK);
end;

procedure TAboutBox.FormActivate(Sender: TObject);
begin
  (*
  L_Productname.Caption:='Anslagstavlan';
  L_Version.Caption:=c_Version;
  L_Copyright.Caption:=c_Copyright;
  Label_Company.Caption:=c_company+' '+c_year;
  Label_mail.Caption:=c_mail;
  *)
end;



end.

