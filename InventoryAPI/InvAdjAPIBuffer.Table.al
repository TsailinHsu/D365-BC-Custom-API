/// <summary>
/// API Buffer Table：承接 POST Request 的暫存資料
/// 過帳完成後記錄結果，供 API Response 回傳
/// 若不需要保留歷史，可改為 Temporary Table 並在 Page 加 SourceTableTemporary = true
/// </summary>
table 50101 "Inv. Adj. API Buffer"
{
    Caption = 'Inventory Adjustment API Buffer';
    DataClassification = CustomerContent;

    fields
    {
        // ── 主鍵 ─────────────────────────────────────────────────────────
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            DataClassification = SystemMetadata;
        }

        // ── 輸入欄位 ─────────────────────────────────────────────────────
        field(10; "Entry Type"; Enum "Item Ledger Entry Type")
        {
            Caption = 'Entry Type';
        }
        field(11; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(12; Quantity; Decimal)
        {
            Caption = 'Quantity';
            MinValue = 0;
        }
        field(13; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(14; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(15; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
        }
        field(16; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
        }
        field(17; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
        }
        field(18; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(19; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(20; "Serial No."; Code[50])
        {
            Caption = 'Serial No.';
        }
        field(21; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
        }
        field(22; "Global Dimension 1 Code"; Code[20])
        {
            Caption = 'Global Dimension 1 Code';
            CaptionClass = '1,1,1';
        }
        field(23; "Global Dimension 2 Code"; Code[20])
        {
            Caption = 'Global Dimension 2 Code';
            CaptionClass = '1,1,2';
        }

        // ── 結果欄位 ─────────────────────────────────────────────────────
        field(50; Status; Enum "Inv. Adj. API Status")
        {
            Caption = 'Status';
        }
        field(51; "Item Ledger Entry No."; Integer)
        {
            Caption = 'Item Ledger Entry No.';
        }
        field(52; "Error Message"; Text[2048])
        {
            Caption = 'Error Message';
        }

        // ── 稽核欄位 ─────────────────────────────────────────────────────
        field(60; "Created At"; DateTime)
        {
            Caption = 'Created At';
        }
        field(61; "Created By"; Code[50])
        {
            Caption = 'Created By';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(ByItemDate; "Item No.", "Posting Date") { }
        key(ByStatus; Status) { }
    }

    trigger OnInsert()
    begin
        Rec."Created At" := CurrentDateTime();
        Rec."Created By" := CopyStr(UserId(), 1, MaxStrLen(Rec."Created By"));
        if Rec."Posting Date" = 0D then
            Rec."Posting Date" := Today();
    end;
}
