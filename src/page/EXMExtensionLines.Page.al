page 83202 "EXM Extension Lines"
{
    Caption = ' Objects', Comment = 'ESP="Objetos"';
    PageType = ListPart;
    SourceTable = "EXM Extension Lines";
    //SourceTableView = sorting("Extension Code", "Object Type", "Object ID", "Source Object Type", "Source Object ID");
    DelayedInsert = true;
    AutoSplitKey = true;


    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                FreezeColumn = Name;
                field("Object Type"; "Object Type")
                {
                    ApplicationArea = All;
                }
                field("Object ID"; "Object ID")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    var
                        EXMExtMgt: Codeunit "EXM Extension Management";
                    begin
                        if (xRec."Object ID" <> "Object ID") then
                            EXMExtMgt.ChechManualObjectID(Rec);
                    end;
                }
                field(Name; "Name")
                {
                    ApplicationArea = All;
                }
                field("Source Object Type"; "Source Object Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Source Object ID"; "Source Object ID")
                {
                    ApplicationArea = All;
                    Editable = ("Source Object Type" = "Source Object Type"::Table) or ("Source Object Type" = "Source Object Type"::Page) or ("Source Object Type" = "Source Object Type"::Enum) or ("Source Object Type" = "Source Object Type"::Profile);
                }
                field("Source Name"; "Source Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Total Fields"; "Total Fields")
                {
                    ApplicationArea = All;
                    trigger OnAssistEdit()
                    begin
                        ViewRelatedFields();
                    end;
                }
                field(Obsolete; Obsolete)
                {
                    ApplicationArea = All;
                }
                field("Created by"; "Created by")
                {
                    ApplicationArea = All;
                }
                field("Creation Date"; "Creation Date")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(ViewField)
            {
                Caption = 'View detail', Comment = 'ESP="Ver detalle"';
                ApplicationArea = All;
                Image = ViewPage;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                ToolTip = 'View object detail.', Comment = 'ESP="Ver detalle objeto."';

                trigger OnAction()
                begin
                    ViewRelatedFields();
                end;
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        "Total Fields" := GetTotalFields();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Validate("Object Type", xRec."Object Type");
    end;

    local procedure ViewRelatedFields()
    var
        EXMTableFields: Record "EXM Table Fields";
        EXMEnumValues: Record "EXM Enum Values";
        EXMFieldList: Page "EXM Field List";
        EXMEnumVal: Page "EXM Enum Values";
    begin
        case "Object Type" of
            "Object Type"::"Table", "Object Type"::"TableExtension":
                begin
                    CurrPage.SaveRecord();
                    Commit();

                    if ("Object Type" = "Object Type"::Table) and ("Source Object ID" = 0) then begin
                        EXMTableFields.SetRange("Extension Code", "Extension Code");
                        EXMTableFields.SetRange("Source Line No.", "Line No.");
                        EXMTableFields.SetRange("Table Source Type", "Object Type");
                        EXMTableFields.SetRange("Table ID", "Object ID");
                        EXMTableFields.SetRange("Source Table ID", "Source Object ID");
                        if EXMTableFields.IsEmpty() then begin
                            EXMTableFields.Init();
                            EXMTableFields."Extension Code" := "Extension Code";
                            EXMTableFields."Source Line No." := "Line No.";
                            EXMTableFields."Table Source Type" := "Object Type";
                            EXMTableFields."Table ID" := "Object ID";
                            EXMTableFields."Source Table ID" := "Source Object ID";
                            EXMTableFields."Field ID" := 1;
                            EXMTableFields.IsPK := true;
                            EXMTableFields."Created by" := CopyStr(UserId(), 1, MaxStrLen(EXMTableFields."Created by"));
                            EXMTableFields."Creation Date" := CurrentDateTime();
                            EXMTableFields.Insert();
                            Commit();
                        end;
                    end;

                    EXMTableFields.SetRange("Extension Code", "Extension Code");
                    EXMTableFields.SetRange("Source Line No.", "Line No.");
                    EXMTableFields.SetRange("Table Source Type", "Object Type");
                    EXMTableFields.SetRange("Table ID", "Object ID");
                    EXMTableFields.SetRange("Source Table ID", "Source Object ID");
                    EXMFieldList.SetTableView(EXMTableFields);

                    EXMFieldList.Editable(true);
                    EXMFieldList.RunModal();
                end;

            "Object Type"::Enum, "Object Type"::EnumExtension:
                begin
                    CurrPage.SaveRecord();
                    Commit();

                    EXMEnumValues.SetRange("Extension Code", "Extension Code");
                    EXMEnumValues.SetRange("Source Line No.", "Line No.");
                    EXMEnumValues.SetRange("Source Type", "Object Type");
                    EXMEnumValues.SetRange("Enum ID", "Object ID");
                    EXMEnumValues.SetRange("Source Enum ID", "Source Object ID");

                    EXMEnumVal.SetTableView(EXMEnumValues);
                    EXMEnumVal.RunModal();
                end;
            else
                exit;
        end;
    end;
}