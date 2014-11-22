//***************************************************************************
//
//       ���ƣ�RTXC.Funcs.pas
//       ���ߣ�RAD Studio XE6
//       ���ڣ�2014/11/11 15:51:21
//       ���ߣ�ying32
//       QQ  ��396506155
//       MSN ��ying_32@live.cn
//       E-mail��yuanfen3287@vip.qq.com
//       Website��http://www.ying32.com
//
//---------------------------------------------------------------------------
//
//       ��ע�� һЩ���õĺ�����װ
//
//
//***************************************************************************
unit RTXC.Funcs;

interface

uses
  Variants,
  RTXCAPILib_TLB;


type
  TRTXCFuncs = record
  public
    class function GetSelectUserName(Parameter: OleVariant): string; static;
//    class procedure SendMessage(); static;
    class function NewGUID: string; static;
  end;

implementation

uses
  RTXC.Consts;

{ TRTXCFuncs }

class function TRTXCFuncs.GetSelectUserName(Parameter: OleVariant): string;
var
  LReceivers: IRTXCDataCollection;
  LRtxData: IRTXCData;
begin
  Result := '';
  case VarType(Parameter) of
    varDispatch:
      begin
        LReceivers := IRTXCDataCollection(TVarData(VarAsType(Parameter, varDispatch)).VDispatch);
        if LReceivers.Count > 0 then
        begin
          LRtxData := LReceivers.Item[1];
          if LRtxData.GetLong(RDK_TYPE) = OBJECT_RTX_BUDDY then
            Result := LRtxData.GetString(RDK_VALUE);
        end;
      end;
    varOleStr:
        Result := VarToStr(Parameter);
  end;
end;

class function TRTXCFuncs.NewGUID: string;
begin
 // Result := TGUID.Emptyto
end;

end.