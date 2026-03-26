/// <summary>
/// 唯讀 API：查詢庫存交易明細 (Item Ledger Entry)
/// Endpoint: GET /api/yourcompany/inventory/v1.0/companies({id})/inventoryTransactions
///           GET /api/yourcompany/inventory/v1.0/companies({id})/inventoryTransactions({entryNo})
/// 支援 OData 篩選: $filter, $orderby, $top, $skip, $expand
/// </summary>
page 50100 "API Inventory Transaction"
{
    PageType = API;
    APIPublisher = 'yourcompany';
    APIGroup = 'inventory';
    APIVersion = 'v1.0';
    EntityName = 'inventoryTransaction';
    EntitySetName = 'inventoryTransactions';

    SourceTable = "Item Ledger Entry";
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    ODataKeyFields = "Entry No.";

    layout
    {
        area(Content)
        {
            group(Group)
            {
                // ── 識別欄位 ──────────────────────────────────────────
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'entryNo';
                }
                field(entryType; Rec."Entry Type")
                {
                    Caption = 'entryType';
                    // 值: Purchase, Sale, Positive Adjmt., Negative Adjmt.,
                    //     Transfer, Consumption, Output, Assembly Consumption,
                    //     Assembly Output
                }
                field(documentNo; Rec."Document No.")
                {
                    Caption = 'documentNo';
                }
                field(documentType; Rec."Document Type")
                {
                    Caption = 'documentType';
                }
                field(documentLineNo; Rec."Document Line No.")
                {
                    Caption = 'documentLineNo';
                }
                field(postingDate; Rec."Posting Date")
                {
                    Caption = 'postingDate';
                }

                // ── 品項欄位 ──────────────────────────────────────────
                field(itemNo; Rec."Item No.")
                {
                    Caption = 'itemNo';
                }
                field(description; Rec.Description)
                {
                    Caption = 'description';
                }
                field(variantCode; Rec."Variant Code")
                {
                    Caption = 'variantCode';
                }
                field(unitOfMeasureCode; Rec."Unit of Measure Code")
                {
                    Caption = 'unitOfMeasureCode';
                }

                // ── 數量與成本 ────────────────────────────────────────
                field(quantity; Rec.Quantity)
                {
                    Caption = 'quantity';
                }
                field(remainingQuantity; Rec."Remaining Quantity")
                {
                    Caption = 'remainingQuantity';
                }
                field(invoicedQuantity; Rec."Invoiced Quantity")
                {
                    Caption = 'invoicedQuantity';
                }
                field(costAmount; Rec."Cost Amount (Actual)")
                {
                    Caption = 'costAmount';
                }
                field(costAmountExpected; Rec."Cost Amount (Expected)")
                {
                    Caption = 'costAmountExpected';
                }
                field(salesAmountActual; Rec."Sales Amount (Actual)")
                {
                    Caption = 'salesAmountActual';
                }

                // ── 倉儲欄位 ──────────────────────────────────────────
                field(locationCode; Rec."Location Code")
                {
                    Caption = 'locationCode';
                }
                field(serialNo; Rec."Serial No.")
                {
                    Caption = 'serialNo';
                }
                field(lotNo; Rec."Lot No.")
                {
                    Caption = 'lotNo';
                }
                field(packageNo; Rec."Package No.")
                {
                    Caption = 'packageNo';
                }
                field(expirationDate; Rec."Expiration Date")
                {
                    Caption = 'expirationDate';
                }

                // ── 來源欄位 ──────────────────────────────────────────
                field(sourceType; Rec."Source Type")
                {
                    Caption = 'sourceType';
                }
                field(sourceNo; Rec."Source No.")
                {
                    Caption = 'sourceNo';
                }
                field(jobNo; Rec."Job No.")
                {
                    Caption = 'jobNo';
                }
                field(jobTaskNo; Rec."Job Task No.")
                {
                    Caption = 'jobTaskNo';
                }

                // ── 旗標 ─────────────────────────────────────────────
                field(open; Rec.Open)
                {
                    Caption = 'open';
                }
                field(positive; Rec.Positive)
                {
                    Caption = 'positive';
                }
                field(completelyInvoiced; Rec."Completely Invoiced")
                {
                    Caption = 'completelyInvoiced';
                }
                field(appliedEntryToAdjust; Rec."Applied Entry to Adjust")
                {
                    Caption = 'appliedEntryToAdjust';
                }

                // ── 異動來源資訊 ──────────────────────────────────────
                field(transactionType; Rec."Transaction Type")
                {
                    Caption = 'transactionType';
                }
                field(globalDimension1Code; Rec."Global Dimension 1 Code")
                {
                    Caption = 'globalDimension1Code';
                }
                field(globalDimension2Code; Rec."Global Dimension 2 Code")
                {
                    Caption = 'globalDimension2Code';
                }
            }
        }
    }
}
