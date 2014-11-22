//
//       ������ΪRTXCMakeTemplate�Զ����� <%CURRENTDATETIME%>
//
unit RTXC<%PROJECTNAME%>ActiveXContainer;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Windows, ActiveX, Classes, Controls, Graphics, Menus, Forms, StdCtrls,
  ComServ, StdVCL, AXCtrls, RTXC<%PROJECTNAME%>ActiveXContainerLib_TLB, 
  Vcl.OleCtnrs, RTXCAPILib_TLB, RTXCModulEinterfaceLib_TLB;

type
  TTRXC<%PROJECTNAME%>ActiveXContainer = class(TActiveXControl, ITRXC<%PROJECTNAME%>ActiveXContainer, IRTXPluginTab)
  private
    { Private declarations }
    FDelphiControl: TOleContainer;
    procedure ActivateEvent(Sender: TObject);
    procedure DeactivateEvent(Sender: TObject);
    procedure KeyPressEvent(Sender: TObject; var Key: Char);
    procedure ResizeEvent(Sender: TObject);
  protected
    { Protected declarations }
    procedure InitializeControl; override;
	
	function InitCtrl(const RtxRoot: IDispatch): HResult; stdcall;
  public
    destructor Destroy; override;
  end;

implementation

uses ComObj, ufrmMainForm;

{ TTRXC<%PROJECTNAME%>ActiveXContainer }

procedure TTRXC<%PROJECTNAME%>ActiveXContainer.InitializeControl;
begin
  FDelphiControl := Control as TOleContainer;
  FDelphiControl.OnActivate := ActivateEvent;
  FDelphiControl.OnDeactivate := DeactivateEvent;
  FDelphiControl.OnKeyPress := KeyPressEvent;
  FDelphiControl.OnResize := ResizeEvent;

  { TODO 1 -oying32 -cInit : ���������VCL FORM��ʼ���Ĵ��� }
  frm_Main := Tfrm_Main.Create(nil);
  // ����ʹ��Windows.SetParent���������
  Windows.SetParent(frm_Main.Handle, FDelphiControl.Handle);
  frm_Main.Show;
end;

destructor TTRXC<%PROJECTNAME%>ActiveXContainer.Destroy;
begin
  { TODO 2 -oying32 -cUnInit : ���������VCL FORM�����ʼ���Ĵ��� }
  frm_Main.Free;
  inherited;
end;

function TTRXC<%PROJECTNAME%>ActiveXContainer.InitCtrl(const RtxRoot: IDispatch): HResult; stdcall;
begin
  { TODO 3 -oying32 -cUnInit : ���������ģ��ĳ�ʼ }
  Result := S_OK;
end;

procedure TTRXC<%PROJECTNAME%>ActiveXContainer.ActivateEvent(Sender: TObject);
begin
end;

procedure TTRXC<%PROJECTNAME%>ActiveXContainer.DeactivateEvent(Sender: TObject);
begin
end;

procedure TTRXC<%PROJECTNAME%>ActiveXContainer.KeyPressEvent(Sender: TObject; var Key: Char);
var
  TempKey: Smallint;
begin
  TempKey := Smallint(Key);
  Key := Char(TempKey);
end;

procedure TTRXC<%PROJECTNAME%>ActiveXContainer.ResizeEvent(Sender: TObject);
begin
  { TODO 2 -oying32 -conSize : ���������VCL FORM���ڴ�С�����ı�Ĵ��� }
  if Assigned(frm_Main) then
     frm_Main.SetBounds(0, 0, FDelphiControl.Width, FDelphiControl.Height);
end;


initialization
  TActiveXControlFactory.Create(
    ComServer,
    TTRXC<%PROJECTNAME%>ActiveXContainer,
    TOleContainer,
    CLASS_TRXC<%PROJECTNAME%>ActiveXContainer,
    0,
    '',
    0,
    tmApartment);
end.
