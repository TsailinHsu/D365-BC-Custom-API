/// <summary>
/// 庫存異動過帳輔助 Codeunit
/// 封裝 Item Journal 過帳邏輯供 API Page 呼叫
/// </summary>
codeunit 50100 "Inv. Transaction Helper"
{
    // ── 公開方法 ─────────────────────────────────────────────────────────

    /// <summary>
    /// 過帳單筆庫存異動
    /// </summary>
    /// <param name="EntryType">異動類型 (Positive Adjmt. / Negative Adjmt. / Transfer ...)</param>
    /// <param name="ItemNo">品項編號</param>
    /// <param name="LocationCode">儲存地點</param>
    /// <param name="BinCode">儲位 (WMS 環境)</param>
    /// <param name="Qty">數量 (正數)</param>
    /// <param name="UnitCost">單位成本 (正調時填入)</param>
    /// <param name="PostingDate">過帳日期</param>
    /// <param name="DocumentNo">外部單號 (空白時自動產生)</param>
    /// <param name="VariantCode">變體代碼</param>
    /// <param name="SerialNo">序號</param>
    /// <param name="LotNo">批號</param>
    /// <param name="ReasonCode">原因碼</param>
    /// <param name="Dim1Code">維度1</param>
    /// <param name="Dim2Code">維度2</param>
    /// <returns>過帳後的 Item Ledger Entry No.</returns>
    procedure PostInventoryAdjustment(
        EntryType: Enum "Item Ledger Entry Type";
        ItemNo: Code[20];
        LocationCode: Code[10];
        BinCode: Code[20];
        Qty: Decimal;
        UnitCost: Decimal;
        PostingDate: Date;
        DocumentNo: Code[20];
        VariantCode: Code[10];
        SerialNo: Code[50];
        LotNo: Code[50];
        ReasonCode: Code[10];
        Dim1Code: Code[20];
        Dim2Code: Code[20]
    ): Integer
    var
        ItemJnlLine: Record "Item Journal Line";
        ItemJnlTemplate: Record "Item Journal Template";
        ItemJnlBatch: Record "Item Journal Batch";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        LastEntryNo: Integer;
    begin
        // 1. 取得或建立 Journal Template / Batch
        GetOrCreateJournalTemplateBatch(ItemJnlTemplate, ItemJnlBatch);

        // 2. 建立 Journal Line
        ItemJnlLine.Init();
        ItemJnlLine.Validate("Journal Template Name", ItemJnlTemplate.Name);
        ItemJnlLine.Validate("Journal Batch Name", ItemJnlBatch.Name);
        ItemJnlLine."Line No." := GetNextLineNo(ItemJnlTemplate.Name, ItemJnlBatch.Name);

        ItemJnlLine.Validate("Entry Type", EntryType);
        ItemJnlLine.Validate("Posting Date", PostingDate);
        ItemJnlLine.Validate("Item No.", ItemNo);
        ItemJnlLine.Validate("Location Code", LocationCode);

        if BinCode <> '' then
            ItemJnlLine.Validate("Bin Code", BinCode);

        if VariantCode <> '' then
            ItemJnlLine.Validate("Variant Code", VariantCode);

        ItemJnlLine.Validate(Quantity, Qty);

        if UnitCost <> 0 then
            ItemJnlLine.Validate("Unit Cost", UnitCost);

        // 單號：外部傳入或自動產生
        if DocumentNo <> '' then
            ItemJnlLine."Document No." := DocumentNo
        else
            ItemJnlLine."Document No." := GetNextDocumentNo(ItemJnlBatch);

        if ReasonCode <> '' then
            ItemJnlLine.Validate("Reason Code", ReasonCode);

        if Dim1Code <> '' then
            ItemJnlLine.Validate("Shortcut Dimension 1 Code", Dim1Code);

        if Dim2Code <> '' then
            ItemJnlLine.Validate("Shortcut Dimension 2 Code", Dim2Code);

        // 3. 序號 / 批號追蹤
        if (SerialNo <> '') or (LotNo <> '') then
            AssignItemTracking(ItemJnlLine, SerialNo, LotNo, Qty);

        // 4. 過帳
        ItemJnlLine.Insert(true);
        ItemJnlPostLine.RunWithCheck(ItemJnlLine);

        // 5. 回傳最新 ILE Entry No.
        LastEntryNo := GetLastItemLedgerEntryNo(ItemNo, PostingDate, ItemJnlLine."Document No.");
        exit(LastEntryNo);
    end;

    // ── 私有方法 ─────────────────────────────────────────────────────────

    local procedure GetOrCreateJournalTemplateBatch(
        var Template: Record "Item Journal Template";
        var Batch: Record "Item Journal Batch"
    )
    var
        TemplateName: Code[10];
        BatchName: Code[10];
    begin
        TemplateName := 'APIPOST';   // 可改為可設定參數
        BatchName := 'DEFAULT';

        if not Template.Get(TemplateName) then begin
            Template.Init();
            Template.Name := TemplateName;
            Template.Description := 'API Posting Template';
            Template.Type := Template.Type::Item;
            Template.Insert(true);
        end;

        if not Batch.Get(TemplateName, BatchName) then begin
            Batch.Init();
            Batch."Journal Template Name" := TemplateName;
            Batch.Name := BatchName;
            Batch.Description := 'API Default Batch';
            Batch.Insert(true);
        end;
    end;

    local procedure GetNextLineNo(TemplateName: Code[10]; BatchName: Code[10]): Integer
    var
        ItemJnlLine: Record "Item Journal Line";
    begin
        ItemJnlLine.SetRange("Journal Template Name", TemplateName);
        ItemJnlLine.SetRange("Journal Batch Name", BatchName);
        if ItemJnlLine.FindLast() then
            exit(ItemJnlLine."Line No." + 10000);
        exit(10000);
    end;

    local procedure GetNextDocumentNo(var Batch: Record "Item Journal Batch"): Code[20]
    var
        NoSeries: Codeunit "No. Series";
    begin
        if Batch."No. Series" <> '' then
            exit(NoSeries.GetNextNo(Batch."No. Series", Today()));
        exit(Format(CurrentDateTime(), 0, '<Year4><Month,2><Day,2><Hours24,2><Minutes,2><Seconds,2>'));
    end;

    local procedure AssignItemTracking(
        var ItemJnlLine: Record "Item Journal Line";
        SerialNo: Code[50];
        LotNo: Code[50];
        Qty: Decimal
    )
    var
        ReservEntry: Record "Reservation Entry";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
    begin
        // 序號追蹤：每筆數量必須為 1
        // BC 27: SerialNo/LotNo/PackageNo 透過 ReservEntry record 傳入
        ReservEntry."Serial No." := SerialNo;
        ReservEntry."Lot No." := LotNo;
        ReservEntry."Package No." := '';
        CreateReservEntry.CreateReservEntryFor(
            Database::"Item Journal Line",
            ItemJnlLine."Entry Type".AsInteger(),
            ItemJnlLine."Journal Template Name",
            ItemJnlLine."Journal Batch Name",
            0,
            ItemJnlLine."Line No.",
            ItemJnlLine."Qty. per Unit of Measure",
            Abs(Qty),
            Abs(Qty),
            ReservEntry);

        CreateReservEntry.CreateEntry(
            ItemJnlLine."Item No.",
            ItemJnlLine."Variant Code",
            ItemJnlLine."Location Code",
            ItemJnlLine.Description,
            0D, 0D, 0,
            ReservEntry."Reservation Status"::Prospect);
    end;

    local procedure GetLastItemLedgerEntryNo(
        ItemNo: Code[20];
        PostingDate: Date;
        DocumentNo: Code[20]
    ): Integer
    var
        ILE: Record "Item Ledger Entry";
    begin
        ILE.SetRange("Item No.", ItemNo);
        ILE.SetRange("Posting Date", PostingDate);
        ILE.SetRange("Document No.", DocumentNo);
        if ILE.FindLast() then
            exit(ILE."Entry No.");
        exit(0);
    end;
}
