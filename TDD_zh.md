# Technical Design Document (TDD)

## 1. Overview

### 文件目的
本文件旨在說明 **FriendsListInterview** 專案的技術設計與架構決策，  
重點在於展示：

- 清楚的分層架構設計
- 狀態驅動的 UI 呈現方式
- 可維護、可測試的 UIKit 專案結構

本文件定位為 **技術設計文件（Technical Design Document）**，  
供工程師、Reviewer 或面試官理解本專案的設計思路與取捨。

### 文件適用範圍
- 本文件僅對齊「最終提交版本」的實際程式碼
- 不包含討論階段中曾評估但未採用的方案
- 不提供產品規格或使用者需求文件（PRD）

### 對齊的實作版本
- UIKit + Auto Layout
- MVVM + Clean Architecture（簡化版）
- 狀態驅動 UI
- 無 Storyboard
- 無 Combine、無 SwiftUI、無 async/await

---

## 2. Project Scope & Non-Goals

### 專案目標
本專案為 iOS 面試作業，目標在於：

- 展示清楚的架構分層與責任劃分
- 示範狀態驅動 UI 的實作方式
- 確保專案具備可維護性與可測試性
- 提供可用於面試說明的 Demo App

### 功能範圍（Scope）
- 好友列表顯示
- 多情境狀態切換：
  - 無好友（Empty）
  - 僅好友
  - 好友 + 邀請
- 邀請卡片展開 / 收合
- 好友搜尋（含搜尋置頂與還原）
- 自訂 Header / ToolsBar
- 單元測試與 Code Coverage

### 非目標（Non-Goals）
以下項目**明確不在本專案範圍內**：

- 商業邏輯完整度
- 真實後端整合
- UI Test / E2E Test
- 效能最佳化
- SwiftUI / Combine / async-await
- 資料快取與持久化

---

## 3. High-Level Architecture

### 架構選型
本專案採用：

- UIKit
- MVVM
- Clean Architecture（Presentation / Domain / Data）

### 分層說明

#### Presentation Layer
- ViewController
- ViewModel（透過 Protocol）
- 負責 UI 呈現與使用者互動

#### Domain Layer
- 純商業邏輯
- Domain Model
- UseCase

#### Data Layer
- Repository（透過 Protocol）
- API Service（透過 Protocol）
- DTO → Domain Model 轉換

### 高階依賴方向

Presentation  
↓  
Domain  
↓  
Data

- 依賴只允許單向向下，禁止反向依賴。

### HLD UML 設計原則
- 上層僅依賴抽象（Protocol）
- 具體實作（DefaultXXX）位於最外層
- 狀態（State）不視為架構實體，因此不納入 HLD

---

## 4. State-Driven UI Design

### ViewModel 狀態定義
UI 顯示完全由 ViewModel 狀態驅動，例如：

- Loading
- Empty
- Content（含或不含邀請）

### 狀態與 UI 呈現關係
- ViewController 僅根據狀態切換 UI
- 不直接判斷資料內容來控制畫面

### 為何狀態不納入 HLD UML
- 狀態為 ViewModel 內部實作細節
- 不屬於系統層級的架構元件
- 納入 UML 會降低高階架構的可讀性

### 狀態驅動的優點與取捨
**優點**
- UI 行為可預測
- 狀態集中管理
- 易於測試

**取捨**
- ViewModel 責任較重
- 初期設計成本較高

---

## 5. Presentation Layer Design

### ViewController 職責劃分

#### ScenarioSelectorViewController
- Demo 專用入口
- 切換不同好友情境

#### FriendsContainerViewController
- 自訂 Header（取代 NavigationBar）
- 內容容器管理
- 底部 TabBar

#### FriendsListViewController
- 好友列表 UI
- 綁定 ViewModel 狀態
- 搜尋與捲動互動
- Empty / Content 切換

### ViewModel 與 Protocol 設計
- ViewController 僅持有 ViewModel Protocol
- 實際 ViewModel 注入於初始化階段

### View 與 ViewModel 綁定方式
- Callback / Closure
- 無使用 Reactive Framework

### Presentation Layer 設計約束
- 不包含商業邏輯
- 不直接呼叫 Repository 或 API
- 僅負責 UI 與互動

---

## 6. Domain Layer Design

### Domain Layer 設計原則
- 純 Swift
- 不依賴 UIKit
- 不知道資料來源

### Domain Model
- `Friend`
  - 核心業務模型
  - 提供 ViewModel 與 UseCase 使用

### UseCase 設計

#### MergeFriendsUseCase
- 合併好友與邀請資料
- 輸出統一 Domain Model

#### SearchFriendsUseCase
- 封裝搜尋邏輯
- 避免 UI 層自行實作搜尋規則

### 為何集中商業邏輯於 UseCase
- 降低 ViewModel 複雜度
- 提高可測試性
- 提供邏輯重用性

---

## 7. Data Layer Design

### Repository 抽象設計
- `FriendsRepository`（Protocol）
- `DefaultFriendsRepository`（實作）

**職責**
- 取得資料
- DTO → Domain Model 轉換
- 隱藏資料來源細節

### API Service 抽象設計
- `FriendsAPIService`（Protocol）
- `DefaultFriendsAPIService`（實作）

**職責**
- 網路請求
- DTO 解析

### DTO 與 Domain Model 轉換責任
- 轉換責任放在 Repository
- Domain Layer 不認識 DTO

---

## 8. Dependency Rules

### 合法依賴方向
- ViewController → ViewModel Protocol
- ViewModel → UseCase
- UseCase → Repository Protocol
- Repository → API Service Protocol

### 禁止的依賴方向
- ViewController → Repository / API
- UseCase → UI
- Repository → UI / ViewModel
- API → Domain / Presentation

### Dependency Inversion 實作方式
- 上層定義 Protocol
- 下層提供實作
- 透過初始化注入

### 為何以 Protocol 作為邊界
- 易於 Mock
- 易於測試
- 可替換實作

---

## 9. UI Implementation Notes

### UIKit + Auto Layout
- 全程使用 Auto Layout
- 無 Storyboard

### 自訂 Header / ToolsBar
- 取代系統 NavigationBar
- 提供更高的 UI 控制彈性

### 搜尋列互動
- 搜尋時 Header 收合
- 結束搜尋自動還原

### 邀請卡片設計
- CollectionView
- 支援展開 / 收合
- 高度由內容驅動

### Constraint Animation 原則
- 所有動畫以 Constraint 變化實作
- 保持畫面一致性

---

## 10. Testing Strategy

### Unit Test 範圍
- ViewModel 狀態轉換
- UseCase 行為
- Repository 資料轉換

### 測試責任劃分
- ViewModel：狀態邏輯
- UseCase：商業邏輯
- Repository：資料轉換正確性

### Code Coverage
- Xcode Scheme 已啟用
- 可於 Test Navigator → Coverage 查看

### 未納入 UI Test 的原因
- 面試作業範圍限制
- 重點在架構而非 UI 自動化

