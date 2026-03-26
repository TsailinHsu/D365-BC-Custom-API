/// <summary>
/// 讀寫 API：建立庫存異動 (Inventory Adjustment / Transfer)
///
/// Endpoint:
///   POST /api/yourcompany/inventory/v1.0/companies({id})/inventoryAdjustments
///        → 觸發 Item Journal 過帳，回傳結果
///
///   GET  /api/yourcompany/inventory/v1.0/companies({id})/inventoryAdjustments
///        → 查詢草稿 (尚未過帳的 Journal Line)
///
/// 設計說明:
///   SourceTable 使用暫存表 "Inv. Adj. API Buffer" (Buffer Table 50101)
///   收到 POST 後在 OnInsertRecord 觸發過帳 Codeunit，
///   過帳完成後將結果寫回 Buffer 供 Response 回傳。
///   此模式可避免直接操作 Journal 表造成的並發問題。
/// </summary>
page 50101 "API Inventory Adjustment"
{
    PageType = API;
    APIPublisher = 'yourcompany';
    APIGroup = 'inventory';
    APIVersion = 'v1.0';
    EntityName = 'inventoryAdjustment';
    EntitySetName = 'inventoryAdjustments';

    SourceTable = "Inv. Adj. API Buffer";
    InsertAllowed = true;
    ModifyAllowed = false;
    DeleteAllowed = false;
    DelayedInsert = true;
    ODataKeyFields = SystemId;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                // ── 必填欄位 ──────────────────────────────────────────
                field(id; Rec.SystemId)
                {
                    Caption = 'id';
                    Editable = false;
                }
                field(entryType; Rec."Entry Type")
                {
                    Caption = 'entryType';
                    // 接受值: "Positive Adjmt.", "Negative Adjmt.", "Transfer"
                }
                field(itemNo; Rec."Item No.")
                {
                    Caption = 'itemNo';
                }
                field(quantity; Rec.Quantity)
                {
                    Caption = 'quantity';
                    // 正值; 方向由 entryType 決定
                }
                field(postingDate; Rec."Posting Date")
                {
                    Caption = 'postingDate';
                }

                // ── 選填欄位 ──────────────────────────────────────────
                field(locationCode; Rec."Location Code")
                {
                    Caption = 'locationCode';
                }
                field(binCode; Rec."Bin Code")
                {
                    Caption = 'binCode';
                }
                field(variantCode; Rec."Variant Code")
                {
                    Caption = 'variantCode';
                }
                field(unitCost; Rec."Unit Cost")
                {
                    Caption = 'unitCost';
                }
                field(documentNo; Rec."Document No.")
                {
                    Caption = 'documentNo';
                    // 空白時系統自動產生
                }
                field(reasonCode; Rec."Reason Code")
                {
                    Caption = 'reasonCode';
                }
                field(serialNo; Rec."Serial No.")
                {
                    Caption = 'serialNo';
                }
                field(lotNo; Rec."Lot No.")
                {
                    Caption = 'lotNo';
                }
                field(globalDimension1Code; Rec."Global Dimension 1 Code")
                {
                    Caption = 'globalDimension1Code';
                }
                field(globalDimension2Code; Rec."Global Dimension 2 Code")
                {
                    Caption = 'globalDimension2Code';
                }

                // ── 回傳欄位 (過帳後填入) ─────────────────────────────
                field(status; Rec.Status)
                {
                    Caption = 'status';
                    Editable = false;
                    // "Draft" | "Posted" | "Error"
                }
                field(itemLedgerEntryNo; Rec."Item Ledger Entry No.")
                {
                    Caption = 'itemLedgerEntryNo';
                    Editable = false;
                }
                field(errorMessage; Rec."Error Message")
                {
                    Caption = 'errorMessage';
                    Editable = false;
                }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        InvHelper: Codeunit "Inv. Transaction Helper";
        PostedEntryNo: Integer;
    begin
        // 基本驗證
        ValidateRequest();

        // 呼叫過帳邏輯
        Rec.Status := Rec.Status::Posted;
        Rec."Error Message" := '';

        PostedEntryNo := InvHelper.PostInventoryAdjustment(
            Rec."Entry Type",
            Rec."Item No.",
            Rec."Location Code",
            Rec."Bin Code",
            Rec.Quantity,
            Rec."Unit Cost",
            Rec."Posting Date",
            Rec."Document No.",
            Rec."Variant Code",
            Rec."Serial No.",
            Rec."Lot No.",
            Rec."Reason Code",
            Rec."Global Dimension 1 Code",
            Rec."Global Dimension 2 Code"
        );

        Rec."Item Ledger Entry No." := PostedEntryNo;
        exit(true);
    end;

    local procedure ValidateRequest()
    begin
        if Rec."Item No." = '' then
            Error('itemNo is required.');

        if Rec.Quantity <= 0 then
            Error('quantity must be greater than zero.');

        if Rec."Posting Date" = 0D then
            Rec."Posting Date" := Today();
    end;
}
