# 技術設計文件（TDD）

## 1. 文件目的（Overview）

本文件說明 **FriendsListInterview** 專案的技術設計與架構決策。

此專案為 iOS 面試作業，重點不在功能完整度，而在於：

- 架構清晰度  
- 職責分離  
- 狀態驅動 UI  
- 可維護的 UIKit 實作  
- 可測試的 ViewModel 與商業邏輯  

專案採用 **UIKit + MVVM**，並遵循 **Clean Architecture** 的分層概念。

---

## 2. 專案範圍與非目標（Scope & Non-Goals）

### 專案涵蓋範圍（In Scope）

- 好友列表多情境顯示  
  - 無好友（Empty）  
  - 僅好友列表  
  - 好友列表 + 邀請卡片  
- 可展開 / 收合的好友邀請卡（CollectionView）  
- 好友搜尋功能（支援搜尋置頂 / 還原）  
- 自訂 Header 與 ToolsBar（取代系統 NavigationBar）  
- 以 ViewModel 狀態驅動 UI 呈現  
- 單元測試與 Code Coverage 設定  

### 明確不在範圍內（Out of Scope）

以下項目刻意不實作，以保持架構展示的聚焦：

- Production 等級的網路錯誤處理  
- 快取 / 本地儲存  
- 分頁（Pagination）  
- Combine / SwiftUI  
- 商業級 UI 錯誤提示  

---

## 3. 高階架構設計（High-Level Architecture）

### 對應文件
- docs/HLDUML.drawio.png

本專案採用三層式架構：
```
Presentation（表現層）
└─ ViewController
└─ ViewModel（透過 Protocol）

Domain（領域層）
└─ UseCases
└─ Domain Models

Data（資料層）
└─ Repository（透過 Protocol）
└─ API Service（透過 Protocol）
```

### 核心設計原則

- 上層只依賴抽象（Protocol）  
- UIKit 不得滲透進 Domain  
- 資料來源細節對上層完全隱藏  
- 狀態由 ViewModel 單一來源管理  

> 內部 UI 狀態（如 `empty / content`）屬於 ViewModel 的實作細節，不視為架構實體，因此不納入 HLD UML。

---

## 4. 狀態驅動 UI 設計（State-Driven UI）

UI 完全由 `FriendsListState` 驅動：

```swift
enum FriendsListState {
    case loading
    case empty
    case content(
        invitations: [Friend],
        friends: [Friend]
    )
}
```
## 狀態與 UI 對應關係

| 狀態 | UI 行為 |
|---|---|
| loading | 顯示 loading indicator |
| empty | 顯示 EmptyStateView |
| content | 顯示好友列表與邀請卡 |

ViewController 只負責 render 狀態，不自行推論 UI 條件。

---

## 5. Presentation Layer（表現層）

### ViewControllers

#### ScenarioSelectorViewController
- Demo 入口頁
- 用於切換不同好友情境（面試展示用途）

#### FriendsContainerViewController
負責整體畫面容器：
- 自訂 Header（ToolsBar + UserInfo）
- 取代系統 NavigationBar
- 內嵌內容 ViewController
- 底部 TabBar
- Header 收合 / 展開動畫

#### FriendsListViewController
主要列表畫面，負責：
- 綁定 ViewModel 狀態
- Empty / Content UI 切換
- 搜尋與捲動互動
- 邀請列表與 Segment 顯示控制

### ViewModel

#### FriendsListViewModel
- 遵循 FriendsListViewModelProtocol

主要職責：
- 載入資料
- DTO → Domain Model 轉換
- 管理 FriendsListState
- 透過 callback 通知 ViewController 更新 UI

ViewController 僅依賴 Protocol，有助於：
- 單元測試
- Mock 注入
- 降低耦合
  
---

## 6. Domain Layer（領域層）

Domain 層僅包含純商業邏輯，不依賴 UIKit 或資料來源。

### Domain Model

#### Friend
- 核心業務模型
- 供 UseCase 與 ViewModel 使用
- 不包含 API 或 UI 相關資訊

### 對應檔案
- Domain/Models/Friend.swift

### UseCases

#### MergeFriendsUseCase
- 合併好友與邀請資料
- 輸出統一的 Domain Model 結構

#### SearchFriendsUseCase
- 封裝好友搜尋邏輯
- 避免搜尋規則散落在 UI 層
  
---

## 7. Data Layer（資料層）

### Repository
- FriendsRepository（Protocol）
- DefaultFriendsRepository（實作）

職責：
- 透過 API Service 取得資料
- 將 DTO 轉換為 Domain Model
- 對上層隱藏資料來源細節

Repository 僅依賴抽象的 API Service Protocol。

### API Service
- FriendsAPIService（Protocol）
- DefaultFriendsAPIService（實作）

職責：
- 發送網路請求
- 解析 API 回傳資料為 DTO

具體實作透過 Protocol 隔離，以利測試與替換。

---

## 8. 依賴規則（Dependency Rules）

### 允許的依賴方向

```
ViewController
 → ViewModel
 → UseCase
 → Repository
 → API Service
```

### 明確禁止的依賴
- ViewController → Repository
- UseCase → UIKit
- Repository → ViewController
- API Service → Domain / UI

此規則確保 Dependency Inversion 與層級清晰。

---

## 9. UI 實作重點（UI Implementation Notes）

- 純 UIKit + Auto Layout（無 Storyboard）
- 自訂 ToolsBar 取代 NavigationBar
- Empty State 使用 tableView.backgroundView
- 搜尋列支援置頂與還原
- 所有版面變化皆透過 Constraint 動畫實作

### 對應檔案
- Presentation/Views/FriendsHeaderView.swift
- Presentation/Views/ToolsBarView.swift
- Presentation/Views/FriendsSearchHeaderView.swift
- Presentation/Views/InvitationCollectionView.swift
- Presentation/Views/FriendCell.swift
- Presentation/Views/EmptyStateView.swift

---

## 10. 測試策略（Testing Strategy）

已建立 Unit Tests

### 對應檔案
- FriendsListInterviewTests/DefaultFriendsAPIServiceTests.swift
- FriendsListInterviewTests/DefaultFriendsRepositoryTests.swift
- FriendsListInterviewTests/MergeFriendsUseCaseTests.swift
- FriendsListInterviewTests/FriendsListViewModelTests.swift
  
測試範圍包含：
- ViewModel 邏輯
- UseCase 行為
- Repository 資料轉換

Xcode Scheme 已開啟 Code Coverage

Coverage 可於以下位置查看：

```
Xcode → Test Navigator → Coverage
```

本專案未包含 UI Test。

---

## 11. 設計取捨與決策說明（Trade-offs）

### 為何選擇 UIKit？
- 對複雜 Layout 與動畫掌控度高
- 貼近多數現有 production codebase

### 為何不使用 Combine / async 架構？
- 降低面試作業的認知負擔
- 聚焦在架構與責任分離

### 為何使用 State Enum？
- 避免多個 boolean value 組合錯誤
- UI 狀態明確、可測試

---

## 總結

本專案的設計重點在於：
- 清楚的架構邊界
- 狀態驅動 UI
- 可測試、可維護的 UIKit 架構
- 明確的依賴方向與責任分離

而非商業功能的完整實作。



