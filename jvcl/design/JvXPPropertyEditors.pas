{-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JvXPPropertyEditors.PAS, released on 2004-01-01.

The Initial Developer of the Original Code is Marc Hoffman.
Portions created by Marc Hoffman are Copyright (C) 2002 APRIORI business solutions AG.
Portions created by APRIORI business solutions AG are Copyright (C) 2002 APRIORI business solutions AG
All Rights Reserved.

Contributor(s):

Last Modified: 2004-01-01

You may retrieve the latest version of this file at the Project JEDI's JVCL home page,
located at http://jvcl.sourceforge.net

Known Issues:
-----------------------------------------------------------------------------}

{$I JVCL.INC}

unit JvXPPropertyEditors;

interface

uses
  {$IFDEF COMPILER6_UP}
  DesignIntf, DesignEditors, VCLEditors,
  {$ELSE}
  Contnrs, DsgnIntf,
  {$ENDIF COMPILER6_UP}
  Classes, Windows, TypInfo, SysUtils, Forms, ImgList, ActnList, Graphics;

type
  {$IFDEF COMPILER6_UP}
  TDesignerSelectionList = IDesignerSelections;
  {$ELSE}
  //TDesignerSelectionList = TComponentList;
  {$ENDIF COMPILER6_UP}

  TJvXPCustomImageIndexPropertyEditor = class(TIntegerProperty
    {$IFDEF COMPILER6_UP}, ICustomPropertyListDrawing {$ENDIF})
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValues(Proc: TGetStrProc); override;
    function GetImageListAt(Index: Integer): TCustomImageList; virtual;

    // ICustomPropertyListDrawing
    procedure ListMeasureHeight(const Value: string; ACanvas: TCanvas;
      var AHeight: Integer); {$IFNDEF COMPILER6_UP} override; {$ENDIF}
    procedure ListMeasureWidth(const Value: string; ACanvas: TCanvas;
      var AWidth: Integer); {$IFNDEF COMPILER6_UP} override; {$ENDIF}
    procedure ListDrawValue(const Value: string; ACanvas: TCanvas;
      const ARect: TRect; ASelected: Boolean); {$IFNDEF COMPILER6_UP} override; {$ENDIF}
  end;

  TJvXPItemImageIndexPropertyEditor = class(TJvXPCustomImageIndexPropertyEditor)
  public
    function GetImageListAt(Index: Integer): TCustomImageList; override;
  end;

  TJvXPBarItemEditor = class(TDefaultEditor)
  protected
    {$IFDEF COMPILER6_UP}
    procedure RunPropertyEditor(const Prop: IProperty);
    {$ELSE}
    procedure RunPropertyEditor(Prop: TPropertyEditor);
    {$ENDIF COMPILER6_UP}
  public
    function GetVerbCount: Integer; override;
    function GetVerb(Index: Integer): string; override;
    procedure Edit; override;
    procedure ExecuteVerb(Index: Integer); override;
  end;

implementation
uses
  JvXPBar;

resourcestring
  RsItemEditorEllipsis = 'Item Editor...';
  RsDefaultColorItem = 'Restore Default Colors';
  RsDefaultFontsItem = 'Restore Default Fonts';

type
  TCustomWinXPBar = class(TJvXPCustomWinXPBar)
  public
    property HotTrackColor;
  end;

//=== TJvXPCustomImageIndexPropertyEditor ====================================

{-----------------------------------------------------------------------------
  Procedure: TJvXPCustomImageIndexPropertyEditor.GetAttributes
  Author:    mh
  Date:      28-Okt-2002
  Arguments: None
  Result:    TPropertyAttributes
-----------------------------------------------------------------------------}

function TJvXPCustomImageIndexPropertyEditor.GetAttributes: TPropertyAttributes;
begin
  Result := [paMultiSelect, paValueList, paRevertable];
end;

{-----------------------------------------------------------------------------
  Procedure: TJvXPCustomImageIndexPropertyEditor.GetImageListAt
  Author:    mh
  Date:      28-Okt-2002
  Arguments: Index: Integer
  Result:    TCustomImageList
-----------------------------------------------------------------------------}

function TJvXPCustomImageIndexPropertyEditor.GetImageListAt(Index: Integer): TCustomImageList;
begin
  Result := nil;
end;

{-----------------------------------------------------------------------------
  Procedure: TJvXPCustomImageIndexPropertyEditor.GetValues
  Author:    mh
  Date:      28-Okt-2002
  Arguments: Proc: TGetStrProc
  Result:    None
-----------------------------------------------------------------------------}

procedure TJvXPCustomImageIndexPropertyEditor.GetValues(Proc: TGetStrProc);
var
  ImgList: TCustomImageList;
  I: Integer;
begin
  ImgList := GetImageListAt(0);
  if Assigned(ImgList) then
    for I := 0 to ImgList.Count -1 do
      Proc(IntToStr(I));
end;

{-----------------------------------------------------------------------------
  Procedure: TJvXPCustomImageIndexPropertyEditor.ListDrawValue
  Author:    mh
  Date:      28-Okt-2002
  Arguments: const Value: string; ACanvas: TCanvas; const ARect: TRect;
    ASelected: Boolean
  Result:    None
-----------------------------------------------------------------------------}

procedure TJvXPCustomImageIndexPropertyEditor.ListDrawValue(const Value: string;
  ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean);
var
  ImgList: TCustomImageList;
  X: Integer;
begin
  ImgList := GetImageListAt(0);
  ACanvas.FillRect(ARect);
  X := ARect.Left + 2;
  if Assigned(ImgList) then
  begin
    ImgList.Draw(ACanvas, X, ARect.Top + 2, StrToInt(Value));
    Inc(X, ImgList.Width);
  end;
  ACanvas.TextOut(X + 3, ARect.Top + 1, Value);
end;

{-----------------------------------------------------------------------------
  Procedure: TJvXPCustomImageIndexPropertyEditor.ListMeasureHeight
  Author:    mh
  Date:      28-Okt-2002
  Arguments: const Value: string; ACanvas: TCanvas; var AHeight: Integer
  Result:    None
-----------------------------------------------------------------------------}

procedure TJvXPCustomImageIndexPropertyEditor.ListMeasureHeight(const Value: string;
  ACanvas: TCanvas; var AHeight: Integer);
var
  ImgList: TCustomImageList;
begin
  ImgList := GetImageListAt(0);
  AHeight := ACanvas.TextHeight(Value) + 2;
  if Assigned(ImgList) and (ImgList.Height + 4 > AHeight) then
    AHeight := ImgList.Height + 4;
end;

{-----------------------------------------------------------------------------
  Procedure: TJvXPCustomImageIndexPropertyEditor.ListMeasureWidth
  Author:    mh
  Date:      28-Okt-2002
  Arguments: const Value: string; ACanvas: TCanvas; var AWidth: Integer
  Result:    None
-----------------------------------------------------------------------------}

procedure TJvXPCustomImageIndexPropertyEditor.ListMeasureWidth(const Value: string;
  ACanvas: TCanvas; var AWidth: Integer);
var
  ImgList: TCustomImageList;
begin
  ImgList := GetImageListAt(0);
  AWidth := ACanvas.TextWidth(Value) + 4;
  if Assigned(ImgList) then
    Inc(AWidth, ImgList.Width);
end;

//=== TJvXPItemImageIndexPropertyEditor ======================================

{-----------------------------------------------------------------------------
  Procedure: TJvXPItemImageIndexPropertyEditor.GetImageListAt
  Author:    mh
  Date:      29-Okt-2002
  Arguments: Index: Integer
  Result:    TCustomImageList
-----------------------------------------------------------------------------}

function TJvXPItemImageIndexPropertyEditor.GetImageListAt(Index: Integer):
  TCustomImageList;
var
  Item: TPersistent;
begin
  Result := nil;
  Item := GetComponent(Index);
  if Item is TJvXPBarItem then
    Result := TJvXPBarItem(Item).Images;
end;

//=== TJvXPBarItemEditor =====================================================

{-----------------------------------------------------------------------------
  Procedure: TJvXPBarItemEditor.Edit
  Author:    mh
  Date:      30-Okt-2002
  Arguments: None
  Result:    None
-----------------------------------------------------------------------------}

procedure TJvXPBarItemEditor.Edit;
var
  Components: TDesignerSelectionList;
begin
  {$IFDEF COMPILER6_UP}
  Components := CreateSelectionList;
  {$ELSE}
  Components := TDesignerSelectionList.Create;
  {$ENDIF COMPILER6_UP}
  Components.Add(Component);
  GetComponentProperties(Components, [tkClass], Designer, RunPropertyEditor);
end;

{-----------------------------------------------------------------------------
  Procedure: TJvXPBarItemEditor.ExecuteVerb
  Author:    mh
  Date:      30-Okt-2002
  Arguments: Index: Integer
  Result:    None
-----------------------------------------------------------------------------}

procedure TJvXPBarItemEditor.ExecuteVerb(Index: Integer);
const
 cFontColor = $00E75100;
 cHotTrackColor = $00FF7C35;
begin
  case Index of
    0: // 'Item Editor...'
      Edit;
    1: // 'Restore Default Colors'
      with TCustomWinXPBar(Component) do
      begin
        Font.Color := cFontColor;
        HeaderFont.Color := cFontColor;
        HotTrackColor := cHotTrackColor;
        if csDesigning in ComponentState then
          TCustomForm(Owner).Designer.Modified;
      end;
    2: // 'Restore Default Fonts'
      with TCustomWinXPBar(Component) do
      begin
        ParentFont := True;
        if csDesigning in ComponentState then
          TCustomForm(Owner).Designer.Modified;
      end;
  end;
end;

{-----------------------------------------------------------------------------
  Procedure: TJvXPBarItemEditor.GetVerb
  Author:    mh
  Date:      30-Okt-2002
  Arguments: Index: Integer
  Result:    string
-----------------------------------------------------------------------------}

function TJvXPBarItemEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0:
      Result := RsItemEditorEllipsis;
    1:
      Result := RsDefaultColorItem;
    2:
      Result := RsDefaultFontsItem;
  end;
end;

{-----------------------------------------------------------------------------
  Procedure: TJvXPBarItemEditor.GetVerbCount
  Author:    mh
  Date:      30-Okt-2002
  Arguments: None
  Result:    Integer
-----------------------------------------------------------------------------}

function TJvXPBarItemEditor.GetVerbCount: Integer;
begin
  Result := 3;
end;

{-----------------------------------------------------------------------------
  Procedure: TJvXPBarItemEditor.RunPropertyEditor
  Author:    mh
  Date:      30-Okt-2002
  Arguments: const Prop: IProperty
  Result:    None
-----------------------------------------------------------------------------}

{$IFDEF COMPILER6_UP}
procedure TJvXPBarItemEditor.RunPropertyEditor(const Prop: IProperty);
{$ELSE}
procedure TJvXPBarItemEditor.RunPropertyEditor(Prop: TPropertyEditor);
{$ENDIF COMPILER6_UP}
begin
  if UpperCase(Prop.GetName) = 'ITEMS' then
    Prop.Edit;
end;

end.

