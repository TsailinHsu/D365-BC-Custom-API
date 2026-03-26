/// <summary>
/// API 過帳狀態列舉
/// </summary>
enum 50100 "Inv. Adj. API Status"
{
    Extensible = true;

    value(0; Draft)
    {
        Caption = 'Draft';
    }
    value(1; Posted)
    {
        Caption = 'Posted';
    }
    value(2; Error)
    {
        Caption = 'Error';
    }
}
