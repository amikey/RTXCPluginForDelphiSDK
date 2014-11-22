unit uFrmManagerView;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, RTXC.Plugin,
  RTXCAPILib_TLB, RTXCModulEinterfaceLib_TLB, Vcl.StdCtrls, Vcl.ComCtrls;

type
  Tfrm_ManagerView = class(TForm)
    btn1: TButton;
    edt1: TEdit;
    tv1: TTreeView;
    btn2: TButton;
    btn3: TButton;
    lbl1: TLabel;
    lbl2: TLabel;
    edt2: TEdit;
    lbl3: TLabel;
    edt3: TEdit;
    mmo1: TMemo;
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure tv1Click(Sender: TObject);
    procedure btn3Click(Sender: TObject);
    procedure tv1AdvancedCustomDrawItem(Sender: TCustomTreeView;
      Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage;
      var PaintImages, DefaultDraw: Boolean);
  private
    FPlugin: TRTXCPlugin;
  public
    procedure Init(APlugin: TRTXCPlugin);

    procedure GetUserInfo(const AUserName: string);
  end;

var
  frm_ManagerView: Tfrm_ManagerView;

implementation

{$R *.dfm}

uses
  RTXC.Consts,
  RTXC.Funcs;

{ Tfrm_ManagerView }

procedure Tfrm_ManagerView.btn1Click(Sender: TObject);
begin
  if Length(edt3.Text) = 0 then
  begin
    FPlugin.SendMessage(FPlugin.RTXRoot.Account, edt1.Text, edt2.Text);
  end else FPlugin.SendMessage(Trim(edt3.Text), edt1.Text, edt2.Text);
end;

procedure Tfrm_ManagerView.btn2Click(Sender: TObject);


  procedure GetDeptUser(DeptId: Integer; RootNode: TTreeNode);
  var
    MyBuddy: IRTXCRTXGroupManager;
    MyRtxBuddy: IRTXCRTXGroup;
    I: Integer;
  begin
    try
      MyBuddy := FPlugin.RTXRoot.RTXGroupManager;
      MyRtxBuddy := MyBuddy.Group[DeptId];
      for I := 1 to MyRtxBuddy.Buddies.Count do
      begin
        Application.ProcessMessages;
        tv1.Items.AddChild(RootNode, MyRtxBuddy.Buddies.Item[I].Account).Data := Pointer(2);
      end;
    except
    end;
  end;

  procedure GetBuddyList(DeptId: Integer; RootNode: TTreeNode);
  var
    MyBuddy: IRTXCRTXGroupManager;
    MyRtxBuddy: IRTXCRTXGroup;
    I: Integer;
    Item: TTreeNode;
  begin
    try
      MyBuddy := FPlugin.RTXRoot.RTXGroupManager;
      MyRtxBuddy := MyBuddy.Group[DeptId];
      for I := 1 to MyRtxBuddy.Groups.Count do
      begin
        Item := tv1.Items.AddChild(RootNode, MyRtxBuddy.Groups.Item[I].Name);
        GetDeptUser(MyRtxBuddy.Groups.Item[I].Id, Item);
        GetBuddyList(MyRtxBuddy.Groups.Item[I].Id, Item);
        Item.Expanded := True;
      end;
    except
    end;
  end;
var
  Item: TTreeNode;
begin
  tv1.Items.Clear;
  tv1.Items.BeginUpdate;
  Item := tv1.Items.AddChildFirst(nil, '��֯�ܹ�');
  GetBuddyList(10000001, Item);
  Item.Expanded := True;
  tv1.Items.EndUpdate;
end;

procedure Tfrm_ManagerView.btn3Click(Sender: TObject);
begin
  if Length(edt3.Text) <> 0 then
    (FPlugin.RTXRoot.RTXIM as IRTXIM).SendIMEx(edt3.Text, edt2.Text, '');
end;

procedure Tfrm_ManagerView.GetUserInfo(const AUserName: string);
var
  API_Helper: IAPI_Helper;
  strDept: WideString;
  Buddy: IRTXCRTXBuddy;
begin
  mmo1.Clear;
  //API_Helper := FPlugin.GetModuleObject<IAPI_Helper>(OBJECT_HELPER);
  //if Assigned(API_Helper) then
  //begin
    //FPlugin.RTXRoot.
   // API_Helper.GetBuddyDept(AUserName, strDept);
    //if strDept <> '' then
   // begin
    try
      Buddy := FPlugin.RTXRoot.RTXBuddyManager.Buddy[AUserName];
      mmo1.Lines.Add('��   ��: ' + Buddy.Account);
      mmo1.Lines.Add('�칫�绰: ' + Buddy.Telephone);
      mmo1.Lines.Add('�����ַ: ' + Buddy.Email);
      case Buddy.Gender of
        RTX_GENDER_UNKNOWN: mmo1.Lines.Add('��   ��: δ֪');
        RTX_GENDER_MALE: mmo1.Lines.Add('��   ��: ��');
        RTX_GENDER_FEMALE: mmo1.Lines.Add('��   ��: Ů');
      end;
      mmo1.Lines.Add('��   ��: ' + Buddy.Name);
      mmo1.Lines.Add('�ƶ��绰: ' + Buddy.Mobile);
    except
    end;
    //end;
  //end;
end;

procedure Tfrm_ManagerView.Init(APlugin: TRTXCPlugin);
begin
  FPlugin := APlugin;
end;

procedure Tfrm_ManagerView.tv1AdvancedCustomDrawItem(Sender: TCustomTreeView;
  Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage;
  var PaintImages, DefaultDraw: Boolean);
begin
 if Integer(Node.Data) = 2 then
   Sender.Canvas.Font.Color := clRed
 else Sender.Canvas.Font.Color := clBlack;
end;

procedure Tfrm_ManagerView.tv1Click(Sender: TObject);
var
  Item: TTreeNode;
begin
  Item := tv1.Selected;
  if Assigned(Item) then
  begin
    if Integer(Item.Data) = 2 then
    begin
      edt3.Text := Item.Text;
      GetUserInfo(Item.Text);
    end;
  end;
end;

end.
