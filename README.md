# Custom Inventory API for D365 Business Central

自訂 AL API 擴充套件，補足 BC API v2.0 對庫存交易支援的缺口。

## API 端點

| 方法 | 路徑 | 說明 |
|------|------|------|
| `GET` | `.../inventoryTransactions` | 查詢 Item Ledger Entry |
| `GET` | `.../inventoryTransactions({entryNo})` | 查詢單筆 ILE |
| `POST` | `.../inventoryAdjustments` | 建立庫存異動並過帳 |

Base URL 格式：
```
https://<server>/api/yourcompany/inventory/v1.0/companies(<companyId>)/
```

---

## 環境設定

### 1. 更換目標環境

開啟 `.vscode/launch.json`（已加入 `.gitignore`，各人自行維護）：

**Docker / On-Premises**
```json
{
  "name": "Docker bc-demo",
  "type": "al",
  "request": "launch",
  "environmentType": "OnPrem",
  "server": "http://<hostname>",
  "serverInstance": "<instance>",
  "tenant": "default",
  "authentication": "UserPassword"
}
```

**Business Central Online (SaaS)**
```json
{
  "name": "Production",
  "type": "al",
  "request": "launch",
  "environmentType": "Production",
  "environmentName": "<environment-name>",
  "authentication": "AAD"
}
```

**Sandbox (SaaS)**
```json
{
  "name": "Sandbox",
  "type": "al",
  "request": "launch",
  "environmentType": "Sandbox",
  "environmentName": "<sandbox-name>",
  "authentication": "AAD"
}
```

### 2. 版本對應（app.json）

| BC 版本 | platform | application | runtime |
|---------|----------|-------------|---------|
| BC 25 (W2 2024) | 25.0.0.0 | 25.x.0.0 | 14.0 |
| BC 26 (W1 2025) | 26.0.0.0 | 26.x.0.0 | 15.0 |
| BC 27 (W2 2025) | 27.0.0.0 | 27.x.0.0 | 16.0 |

---

## 部署

### 開發環境（F5 發佈）

1. 開啟 VS Code，確認 `.vscode/launch.json` 已指向正確環境
2. 下載 Symbols：`Ctrl+Shift+P` → **AL: Download Symbols**
3. 發佈：`F5`（含偵錯）或 `Ctrl+F5`（不含偵錯）

### 正式環境（.app 封裝上傳）

1. 在 VS Code 執行 `Ctrl+Shift+P` → **AL: Package**，產生 `.app` 檔案
2. 登入 BC 管理中心 → **Extension Management**
3. 點選 **Upload Extension** 上傳 `.app`
4. 或使用 PowerShell（On-Premises）：
   ```powershell
   Publish-NAVApp -ServerInstance BC -Path ".\YourCompany_Custom Inventory API_1.0.0.0.app"
   Install-NAVApp  -ServerInstance BC -Name "Custom Inventory API" -Tenant default
   ```

---

## POST 範例

```http
POST /api/yourcompany/inventory/v1.0/companies(<id>)/inventoryAdjustments
Content-Type: application/json

{
  "entryType": "Positive Adjmt.",
  "itemNo": "ITEM-001",
  "quantity": 10,
  "postingDate": "2026-03-26",
  "locationCode": "MAIN",
  "unitCost": 150.00,
  "lotNo": "LOT-2026-001"
}
```

成功回應（HTTP 201）：
```json
{
  "id": "...",
  "status": "Posted",
  "itemLedgerEntryNo": 12345,
  "errorMessage": ""
}
```

---

## 專案結構

```
D365 BC/
├── .vscode/
│   └── launch.json          # 環境連線設定（不進版控）
├── InventoryAPI/
│   ├── app.json             # 擴充套件定義
│   ├── API_InventoryTransaction.Page.al   # GET：查詢 ILE
│   ├── API_InventoryAdjustment.Page.al    # POST：建立庫存異動
│   ├── InvAdjAPIBuffer.Table.al           # Buffer Table
│   ├── InvAdjAPIStatus.Enum.al            # 狀態列舉
│   └── InvTransactionHelper.Codeunit.al   # 過帳邏輯
├── .gitignore
└── README.md
```

---

## ID Range

本套件使用 Object ID `50100–50199`，部署前請確認與其他擴充套件無衝突。
