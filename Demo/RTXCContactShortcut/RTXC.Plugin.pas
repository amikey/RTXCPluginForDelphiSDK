//***************************************************************************
//
//       ���ƣ�RTXC.Plugin.pas
//       ���ߣ�RAD Studio XE6
//       ���ڣ�2014/11/8 15:11:21
//       ���ߣ�ying32
//       QQ  ��396506155
//       MSN ��ying_32@live.cn
//       E-mail��yuanfen3287@vip.qq.com
//       Website��http://www.ying32.com
//
//---------------------------------------------------------------------------
//
//       ��ע��RTX�ͻ��˲����
//       ������ΪRTXCMakeTemplate�Զ����� 2015/01/29 14:44:32
//
//
//***************************************************************************
unit RTXC.Plugin;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Windows,
  ComObj,
  Comserv,
  Variants,
  SysUtils,
  ShortLink,
  RTXCContactShortcutPluginLib_TLB,
  RTXCAPILib_TLB,
  CLIENTOBJECTSLib_TLB,
  RTXCModulEinterfaceLib_TLB,
  RTXC.Event,
  StdVcl;

type
  TRTXCContactShortcutPlugin = class sealed(TAutoObject, IRTXCModule, IRTXCPlugin)
  private
    FRTXRoot: IRTXCRoot;
    FRTXModuleSite: IRTXCModuleSite;
    FClientObjectsModule: IClientObjectsModule;
    FMenuSink: TRTXCUICommand;
    function getClassNoT: string; inline;
    function GetClientObjsModule: IClientObjectsModule;
  protected
    /// <remarks>
    ///   �ӿڲ���ʵ��
    /// </remarks>
    function  Get_Identifier: WideString; safecall;
    function  Get_ModuleSite: IDispatch; safecall;
    function  Get_Name: WideString; safecall;
    function  OnInvoke(Receiver, Parameter, Extra: OleVariant): OleVariant; safecall;
    procedure OnAccountChange; safecall;
    procedure OnLoad(const RTXCModuleSite: IDispatch); safecall;
    procedure OnUnload(Reason: RTXC_MODULE_UNLOAD_REASON); safecall;
    function  Get_Info(Field: RTXC_PLUGIN_INFO_FIELD): WideString; safecall;
  public
    function GetModuleObject<T>(const Identifier: string): T;
    procedure SendMessage(const Receiver, ATitle, AMsg: string);

    // �˵���ص������¼�
    procedure MenuOnInvoke(UIType: RTXC_UI_TYPE; Id: Integer; Parameter: OleVariant);
    // MenuOnQueryState������Text�Ĳ���һ��Ҫ��var, �Զ����ɵĽӿ��ļ���Ϊout,������ֱ��
    // ��ɲ˵���Ӻ󲻻���ʾ����, Դ��out��var�ؼ��ֵ�����
    procedure MenuOnQueryState(UIType: RTXC_UI_TYPE; Id: Integer; Parameter: OleVariant;
      var Text: WideString; var State: RTXC_UI_ITEM_STATE);
  public
    property RTXRoot: IRTXCRoot read FRTXRoot;
    property RTXModuleSite: IRTXCModuleSite read FRTXModuleSite;
    property ClientObjectsModule: IClientObjectsModule read FClientObjectsModule;
  end;


implementation

uses
  RTXC.Consts, RTXC.Funcs;

const
  MENU_SEND_SHOURTCUT_INDEX = 10210;
  MENU_SHORTCUT_STRING = '���������ݷ�ʽ(&C)';

{ TRTXCContactShortcutPlugin }

function TRTXCContactShortcutPlugin.Get_Identifier: WideString;
begin
  Result := getClassNoT;
end;

function TRTXCContactShortcutPlugin.Get_Info(Field: RTXC_PLUGIN_INFO_FIELD): WideString;
begin
  Result := '����ϵ�˷��͵������ݷ�ʽ��';
end;

function TRTXCContactShortcutPlugin.Get_ModuleSite: IDispatch;
begin
  Result := FRTXModuleSite;
end;

function TRTXCContactShortcutPlugin.Get_Name: WideString;
begin
  Result := '��ϵ�������ݷ�ʽ';;
end;

procedure TRTXCContactShortcutPlugin.MenuOnInvoke(UIType: RTXC_UI_TYPE;
  Id: Integer; Parameter: OleVariant);
var
  S: string;
begin
  case Id of
    MENU_SEND_SHOURTCUT_INDEX :
      begin
        S := TRTXCFuncs.GetSelectUserName(Parameter);
        if S <> '' then
          CreateDesktopLink(S, TRTXCFuncs.GetModulePath + 'Shortcut.exe', S, '"' + S + '"');
      end;
  end;
end;

procedure TRTXCContactShortcutPlugin.MenuOnQueryState(UIType: RTXC_UI_TYPE;
  Id: Integer; Parameter: OleVariant; var Text: WideString;
  var State: RTXC_UI_ITEM_STATE);
begin
end;

procedure TRTXCContactShortcutPlugin.OnAccountChange;
begin

end;

function TRTXCContactShortcutPlugin.OnInvoke(Receiver, Parameter,
  Extra: OleVariant): OleVariant;
begin
  Result := null;;
end;

procedure TRTXCContactShortcutPlugin.OnLoad(const RTXCModuleSite: IDispatch);
var
  LMenu: IRTXCMenu;
begin
  FMenuSink := TRTXCUICommand.Create;
  FMenuSink.OnInvoke_ := MenuOnInvoke;
  FMenuSink.OnQueryState_ := MenuOnQueryState;

  if RTXCModuleSite = nil then
  begin
    FRTXRoot := nil;
    FRTXModuleSite := nil;
    Exit;
  end;
  FRTXModuleSite := RTXCModuleSite as IRTXCModuleSite;
  FRTXRoot := FRTXModuleSite.RTXCRoot;
  FClientObjectsModule := GetClientObjsModule;


  // ��ӳ�����ϵ���Ҽ��˵� RTXC_UI_TYPE_MYCONTACTS_USERDEFINEDGROUP_USERΪ������ϵ��
  LMenu := GetModuleObject<IRTXCMenu>(RTX_CLIENT_OBJECTS_IDENTIFIER_MENU);
  LMenu.AddItem(False, -1, RTXC_UI_TYPE_MYCONTACTS_USERDEFINEDGROUP_USER, MENU_SEND_SHOURTCUT_INDEX,
    FMenuSink, MENU_SHORTCUT_STRING, '', RTXC_MENU_ITEM_SEPARATOR_ABOVE_AND_BELOW, 6, False);

  // ��֯�ܹ���Ա�Ҽ��˵� RTXC_UI_TYPE_ORG_STRUCT_USERΪ��֯�ܹ���Ա
  LMenu.AddItem(False, -1, RTXC_UI_TYPE_ORG_STRUCT_USER, MENU_SEND_SHOURTCUT_INDEX,
    FMenuSink, MENU_SHORTCUT_STRING, '', RTXC_MENU_ITEM_SEPARATOR_ABOVE_AND_BELOW, 6, False);

  // �����ϵ�� RTXC_UI_TYPE_RECENTCONTACTS_SESSIONS_USER
  LMenu.AddItem(False, -1, RTXC_UI_TYPE_RECENTCONTACTS_SESSIONS_USER, MENU_SEND_SHOURTCUT_INDEX,
    FMenuSink, MENU_SHORTCUT_STRING, '', RTXC_MENU_ITEM_SEPARATOR_ABOVE_AND_BELOW, 6, False);

  // ����"�˵� RTXC_UI_TYPE_MAINFRAME_ACTION
  LMenu.AddItem(False, -1, RTXC_UI_TYPE_MAINFRAME_ACTION, MENU_SEND_SHOURTCUT_INDEX,
    FMenuSink, MENU_SHORTCUT_STRING, '', RTXC_MENU_ITEM_SEPARATOR_ABOVE_AND_BELOW, 6, False);

//  // ��IM ������ӵ������˵�
//  LMenu.AddItem(False, -1, RTXC_UI_TYPE_IM_THIRDPARTY, MENU_SEND_SHOURTCUT_INDEX,
//    FMenuSink, MENU_SHORTCUT_STRING, '', RTXC_MENU_ITEM_SEPARATOR_ABOVE_AND_BELOW, 6, False);
end;

procedure TRTXCContactShortcutPlugin.OnUnload(Reason: RTXC_MODULE_UNLOAD_REASON);
var
  LMenu: IRTXCMenu;
begin
  LMenu := GetModuleObject<IRTXCMenu>(RTX_CLIENT_OBJECTS_IDENTIFIER_MENU);
  LMenu.DelItem(RTXC_UI_TYPE_MYCONTACTS_USERDEFINEDGROUP_USER, MENU_SEND_SHOURTCUT_INDEX, FMenuSink);
  LMenu.DelItem(RTXC_UI_TYPE_ORG_STRUCT_USER, MENU_SEND_SHOURTCUT_INDEX, FMenuSink);
  LMenu.DelItem(RTXC_UI_TYPE_RECENTCONTACTS_SESSIONS_USER, MENU_SEND_SHOURTCUT_INDEX, FMenuSink);
  LMenu.DelItem(RTXC_UI_TYPE_MAINFRAME_ACTION, MENU_SEND_SHOURTCUT_INDEX, FMenuSink);
//  LMenu.DelItem(RTXC_UI_TYPE_IM_THIRDPARTY, MENU_SEND_SHOURTCUT_INDEX, FMenuSink);
  FMenuSink.Free;
end;

function TRTXCContactShortcutPlugin.getClassNoT: string;
begin
  Result := ToString;
  Delete(Result, 1, 1);
end;

function TRTXCContactShortcutPlugin.GetModuleObject<T>(const Identifier: string): T;
type
  PT = ^T;
var
  Obj: Cardinal;
begin
  Obj := Cardinal(Pointer(FClientObjectsModule.Object_[Identifier]));
  Result := PT(@Obj)^;
end;

function TRTXCContactShortcutPlugin.GetClientObjsModule: IClientObjectsModule;
begin
  Result := FRTXRoot.Module[RTX_MODULE_IDENTIFIER_CLIENT_OBJS] as IClientObjectsModule;
end;

procedure TRTXCContactShortcutPlugin.SendMessage(const Receiver, ATitle, AMsg: string);
var
  LData: IRTXCData;
begin
  try
    LData := FRTXRoot.CreateRTXCData;
    LData.SetString(RDK_KEY, GUIDToString(TGuid.NewGuid));
    LData.SetString(RDK_TITLE, ATitle);
    LData.SetString(RDK_MSG_CONTENT, AMsg);
    RTXModuleSite.SendData(Receiver, LData, RTXC_SEND_DATA_FLAG_FILTERING_IS_FORBIDDEN);
  except
  end;
end;


initialization
  TAutoObjectFactory.Create(ComServer, TRTXCContactShortcutPlugin, CLASS_RTXCContactShortcutPlugin,
    ciMultiInstance, tmApartment);

end.
