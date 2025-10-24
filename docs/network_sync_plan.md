# 區域網路電池狀態同步方案

## 需求分析

- **分享資料**: 電池狀態資料
- **使用情境**: 家庭內部使用
- **分享方向**: 雙向同步
- **安全等級**: 中等安全

## 技術架構選擇

採用 **mDNS/Bonjour 服務發現 + WebSocket** 的混合架構:

### 1. 服務發現層 (mDNS)

- 使用 `nsd` package 實現零配置服務發現
- 自動探測同一區網內的其他裝置
- 無需手動輸入 IP 位址

### 2. 通訊層 (WebSocket)

- 使用 `web_socket_channel` 建立雙向即時通訊
- 每台裝置既是 server 也是 client
- 支援即時電池狀態推送

### 3. 安全層 (中等安全)

- 使用裝置配對碼 (6位數PIN)
- TLS 自簽憑證加密傳輸
- 裝置白名單機制
- 首次配對需要手動確認

## 資料結構設計

```dart
// Device information
class DeviceInfo {
  String deviceId;        // UUID
  String deviceName;      // User-defined device name
  DateTime lastSeen;      // Last online timestamp
}

// Battery synchronization data
class BatterySync {
  DeviceInfo device;
  int batteryLevel;
  BatteryState state;
  bool isPluggedIn;
  DateTime timestamp;
}
```

## 實作步驟

### 1. 添加依賴套件

- `nsd`: mDNS service discovery
- `web_socket_channel`: WebSocket communication
- `uuid`: Generate device ID
- `shared_preferences`: Store pairing information

### 2. 建立核心服務

- `NetworkDiscoveryService`: Handle service discovery and broadcasting
- `DeviceSyncService`: Manage device connections and data synchronization
- `PairingService`: Handle device pairing process

### 3. UI 功能

#### BatteryScreen 改版設計

主要保持現有佈局，新增其他裝置的簡卡顯示區域：

**收合狀態：**

```text
┌─────────────────────────────────┐
│ [裝置1] [裝置2] [裝置3] [+2]     │  ← 可點擊整個區域
│  icon    icon    icon           │     根據寬度自動調整顯示數量
│  75%     60%     45%            │     超出顯示 +n
│                                 │
│     🔋  85%                      │
│    當前裝置電量 (主要資訊區)      │
│                                 │
│  [設定] [其他功能]               │
└─────────────────────────────────┘
```

**展開狀態（詳細列表）：**

- 當前裝置資訊（裝置名稱、電量、充電狀態、最後同步時間）
- 已配對裝置列表（按加入順序排序）
- 連線狀態標示（在線/離線，離線裝置變灰）
- 新增裝置按鈕

#### 額外頁面

- **配對頁面**: 輸入 PIN 碼配對新裝置
- **設定頁面**: 裝置名稱、啟用/停用同步、管理已配對裝置

### 4. 整合現有程式碼

- 擴充 `BatteryService` 加入同步功能
- 改版 `BatteryScreen` 上方新增其他裝置簡卡區域
- 新增展開詳細列表的功能

## 安全機制

- **配對流程**: 兩台裝置顯示相同 PIN 碼才能配對
- **自簽憑證**: 防止明文傳輸
- **白名單**: 只接受已配對裝置的連線
- **逾時機制**: 長時間未回應自動斷線

## 優點

✓ 零配置,自動發現裝置
✓ 即時同步,延遲低
✓ 中等安全性,適合家庭使用
✓ 離線時不影響本地功能
✓ 支援多裝置同時連線

## 跨平台支援性調查結果

### 套件比較表

| 套件名稱 | Android | iOS | Windows | macOS | Linux | 服務註冊 | 服務發現 |
|---------|---------|-----|---------|-------|-------|---------|---------|
| **bonsoir** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **nsd** | ✅ (API 21+) | ✅ (12.0+) | ✅ (10 v1903+) | ✅ (10.11+) | ❌ | ✅ | ✅ |
| **flutter_nsd** | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ✅ |
| **multicast_dns** | ✅ | ✅ | ✅ | ✅ | ✅ | ❓ | ✅ |

### 推薦方案: **Bonsoir**

#### 選擇理由

1. **完整跨平台支援**: 唯一支援所有五個平台的套件 (Android, iOS, Windows, macOS, Linux)
2. **功能完整**: 同時支援服務發現與服務註冊
3. **積極維護**: 最後更新 2 個月前 (2025年初)
4. **基於原生 API**: 使用 Apple Bonjour 和 Android NSD 原生框架
5. **模組化設計**: 各平台有獨立實作,透過統一介面整合

#### 已知限制

- 文件中未提及特定限制,需實際測試各平台表現

### 備選方案: **NSD**

如果不需要 Linux 支援,`nsd` 套件也是不錯的選擇:

- 支援 4 大主流平台
- 提供 IP 位址自動解析功能
- 文件較為完整

**Windows 限制**: 無法偵測同一台機器上用此套件註冊的服務類型

### WebSocket 支援性

| 套件 | 跨平台 | 客戶端 | 伺服器 | 推薦度 |
|-----|--------|--------|--------|-------|
| **web_socket_channel** | ✅ | ✅ | ✅ | ⭐⭐⭐⭐⭐ |
| **ws** | ✅ | ✅ | ❓ | ⭐⭐⭐ |

**推薦**: 使用官方的 `web_socket_channel` 套件

- Dart 團隊官方維護
- 完整跨平台支援 (Mobile, Desktop, Web)
- 同時支援 `dart:io` 和 `dart:html`
- 穩定可靠

### 各平台權限需求

#### Android

```xml
<!-- AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CHANGE_WIFI_MULTICAST_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
```

#### iOS / macOS

```xml
<!-- Info.plist -->
<key>NSLocalNetworkUsageDescription</key>
<string>需要區域網路權限以發現和連接其他裝置</string>
<key>NSBonjourServices</key>
<array>
    <string>_battery-sync._tcp</string>
</array>
```

#### Windows

- 需要在首次執行時取得防火牆權限
- 可能需要管理員權限開啟特定 port

#### Linux

- 通常不需要特殊權限
- 某些發行版可能需要安裝 `avahi-daemon`

### 最終技術棧建議

```yaml
dependencies:
  # Service discovery
  bonsoir: ^6.0.1

  # WebSocket communication
  web_socket_channel: ^3.0.0

  # Device identification
  uuid: ^4.0.0

  # Local storage
  shared_preferences: ^2.3.0

  # Encryption (optional, for enhanced security)
  encrypt: ^5.0.3
```

## 待確認事項

- [x] 跨平台支援性調查 (Android, iOS, Windows, macOS, Linux)
- [x] 各平台的權限需求
- [ ] 效能測試與電池消耗評估
- [ ] 實際配對流程的 UX 設計
- [ ] 各平台實機測試
- [ ] 網路斷線重連機制設計
