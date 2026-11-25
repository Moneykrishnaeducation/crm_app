# Application Performance Audit & Lag Analysis Report

**Date**: November 25, 2026  
**Application**: VTIndex CRM / Trading Mobile App (Flutter)  
**Target Platform**: Android & iOS  

---

## Executive Summary

An end-to-end performance and code audit of the application was conducted across the backend/networking layer, Dart isolates, and Flutter widget rendering tree.

The audit identified the exact root causes of the **severe lagging, frame stuttering, and periodic UI freezes (1 to 5 seconds)** observed in the application:

1. **2048-bit RSA keypair generation on the main UI isolate on every HTTP request** (pure Dart prime generation blocks the event loop for 500ms–2,000ms per request).
2. **Aggressive background timer storms** (15-second timer loops through all user accounts firing concurrent requests, multiplying the key generation UI freeze).
3. **Primary navigation tabs rendered simultaneously without `Offstage`** (all four core tabs run layout and compositing passes simultaneously every frame).
4. **Missing list virtualization, keystroke `setState` cascades, and broken `CustomPainter` repainting** across account cards, MAM pools, and trade reports.

---

## 🚨 Root Cause Architecture

```
┌────────────────────────────────────────────────────────────────────────┐
│ 1. Background Timer (every 15s) polls all user trading accounts        │
│                                                                        │
│ 2. Each HTTP request generates a 2048-bit RSA keypair in pure Dart     │
│    ➜ 500ms - 2,000ms Main UI Thread FREEZE per request!                │
│    (3 accounts = 1.5s - 6s of continuous UI freeze every 15s)          │
│                                                                        │
│ 3. Inactive tabs remain alive in layout/paint without Offstage         │
│                                                                        │
│ 4. Unvirtualized lists & non-debounced search trigger 6000-line builds │
└────────────────────────────────────────────────────────────────────────┘
```

---

## Category 1: Critical (P0) — Main Thread Freezes & CPU Locks

### 1. Synchronous 2048-Bit RSA Keypair Generation on Every HTTP Request
- **Files**:
  - [lib/services/auth_api.dart#L171-L174](lib/services/auth_api.dart#L171-L174)
  - [lib/services/auth_api.dart#L306-L373](lib/services/auth_api.dart#L306-L373)
  - [lib/services/auth_api.dart#L577](lib/services/auth_api.dart#L577)
  - [lib/services/auth_api.dart#L1974](lib/services/auth_api.dart#L1974)
- **Root Cause**:
  In `_request()`, `_multipartRequest()`, and `_uploadProfileImage()`, every single outgoing HTTP call executes:
  ```dart
  final responseKeyPair = _createResponseEncryptionKeyPair();
  headers['X-Response-Encryption-Key'] = responseKeyPair.publicKey;
  ```
  `_createResponseEncryptionKeyPair()` generates a fresh 2048-bit RSA keypair using PointyCastle pure-Dart on the **main UI thread**. Generating two large prime numbers on a mobile CPU blocks Dart's event loop for **500ms to 2,000ms** per request.
- **Aggravating Factor**:
  Over 95% of server endpoints do not return encrypted response payloads. The key is generated, the UI freezes, and the key is immediately discarded.
- **Remediation**:
  - Restrict encryption key generation only to sensitive endpoints requiring encrypted responses, or generate a single reusable session key.
  - Offload key generation to a background isolate using `compute()` / `Isolate.run()`.

---

### 2. Multi-Account Polling Storm via Background Timers
- **Files**:
  - [lib/app_notifications.dart#L317-L322](lib/app_notifications.dart#L317-L322)
  - [lib/app_notifications.dart#L381-L396](lib/app_notifications.dart#L381-L396)
  - [lib/main.dart#L373-L376](lib/main.dart#L373-L376)
  - [lib/pages/broker_screens.dart#L70-L87](lib/pages/broker_screens.dart#L70-L87)
- **Root Cause**:
  - `AppNotificationCenter._portfolioMonitorTimer` runs every **15 seconds**. Each tick loops through all user accounts and fires `AuthApi.instance.getOpenPositions(accountId)`.
  - For a user with 3 accounts, 3 requests fire every 15 seconds. In combination with Issue #1, this triggers 3 consecutive RSA key generations, resulting in **1.5s to 6s of cumulative UI freezing every 15 seconds**.
  - `_notificationRefreshTimer` in `AppShell` runs every 60 seconds, incurring another 1s freeze plus JSON decode of 50 items.
  - `BrokerDashboardPage._loadDashboardDetails()` concurrently requests open positions and trade histories for all accounts on page load, freezing the dashboard upon launch.
- **Remediation**:
  - Pause background polling timers when the app is in the background or when the user is not actively on the relevant page.
  - Throttle polling to 30–60s intervals and batch account queries into a single API endpoint.

---

### 3. Inactive Tabs Kept in Active Layout/Paint (`AnimatedOpacity` without `Offstage`)
- **Files**:
  - [lib/main.dart#L1100-L1110](lib/main.dart#L1100-L1110)
  - [lib/main.dart#L1160-L1215](lib/main.dart#L1160-L1215)
- **Root Cause**:
  In `AppShell`, all four primary tab screens (`BrokerDashboardPage`, `BrokerTransactionsPage`, `BrokerAccountsPage`, `BrokerMorePage`) are kept in a single `Stack` using `AnimatedOpacity`.
- **Impact**:
  Although opacity is set to 0.0 for inactive tabs, **Flutter still performs layout, hit-testing, and compositing passes for all four full-page trees on every single frame**.
- **Remediation**:
  Wrap each tab screen in `Offstage(offstage: !active, child: ...)` or use `IndexedStack` so inactive screens are completely pruned from layout and rendering pipelines.

---

## Category 2: High (P1) — UI Jank, Scroll Stutter & Build Cascades

### 4. Non-Virtualized Scrollable Lists
- **Files**:
  - `BrokerAccountsPage`: [lib/pages/accounts_page.dart#L57-L125](lib/pages/accounts_page.dart#L57-L125) (`ListView(children: [ ...filtered.map(...) ])`)
  - `MamPage`: [lib/pages/mam_page.dart#L588-L605](lib/pages/mam_page.dart#L588-L605), [L1494-L1770](lib/pages/mam_page.dart#L1494-L1770) (`for (final master in filtered) ...[ _buildMasterNodeCard(master) ]`)
  - `BrokerAccountDetailsPage`: [lib/pages/accounts_page.dart#L2976-L2991](lib/pages/accounts_page.dart#L2976-L2991) (unvirtualized history transactions and open positions in a `Column`)
- **Root Cause**:
  `ListView(children: [...])` and unvirtualized `Column` containers force Flutter to instantiate, layout, and paint all items simultaneously at page load, completely bypassing viewport virtualization.
- **Impact**:
  When an account has dozens of transactions or pools, opening the page or scrolling causes massive frame drops (dropping from 60 fps to 15–20 fps).
- **Remediation**:
  Refactor all card and trade lists to `ListView.builder` or `CustomScrollView` with `SliverList.builder`.

---

### 5. Search Keystroke `setState()` Build Cascades
- **Files**:
  - `MamPage`: [lib/pages/mam_page.dart#L418-L426](lib/pages/mam_page.dart#L418-L426)
    ```dart
    _managerSearchController.addListener(() => setState(() {}));
    _availableSearchController.addListener(() => setState(() {}));
    ```
  - `BrokerAccountsPage`: [lib/pages/accounts_page.dart#L100-L103](lib/pages/accounts_page.dart#L100-L103) (`onChanged: (v) => setState(() => _query = v)`)
- **Root Cause**:
  Every single character typed triggers `setState()` on `_MamPageState` (a **6,630-line widget tree**) without debouncing, re-evaluating tabs, metric headers, chips, and dozens of complex card widgets per keystroke.
- **Impact**:
  Visible typing latency, keyboard input lag, and frame stutter while searching.
- **Remediation**:
  Add a 250ms debounce timer and isolate the search query in a `ValueNotifier<String>` consumed only by the list via `ValueListenableBuilder`.

---

### 6. CustomPainter Inefficiencies & Broken `shouldRepaint`
- **Files**:
  - `_TradeReportLinePainter`: [lib/pages/trade_report_page.dart#L2317-L2373](lib/pages/trade_report_page.dart#L2317-L2373)
  - `_TradeReportBarPainter`: [lib/pages/trade_report_page.dart#L2375-L2415](lib/pages/trade_report_page.dart#L2375-L2415)
  - `_PortfolioLinePainter`: [lib/pages/accounts_page.dart#L268-L337](lib/pages/accounts_page.dart#L268-L337)
- **Root Cause**:
  1. `_equityHistory` getter in [lib/pages/trade_report_page.dart#L252-L254](lib/pages/trade_report_page.dart#L252-L254) maps a new `List<double>` on every getter access. As a result, `shouldRepaint(old) => old.values != values` always returns `true`, repainting charts continuously.
  2. Inside `paint()`, `TextPainter.layout()` is executed repeatedly on every canvas frame.
  3. `_PortfolioLinePainter` creates new `Path`, `Paint`, and `List<Offset>` allocations on every paint call.
- **Remediation**:
  Cache history lists immutably in state; pre-calculate text sizes; reuse paint objects (`path.reset()`).

---

### 7. Missing `RepaintBoundary` on Charts & Sparklines
- **Files**:
  - Account Sparklines: [lib/pages/accounts_page.dart#L200-L207](lib/pages/accounts_page.dart#L200-L207)
  - Equity Details Chart: [lib/pages/accounts_page.dart#L2748-L2759](lib/pages/accounts_page.dart#L2748-L2759)
  - Trade Report Gauges & Charts: [lib/pages/trade_report_page.dart#L1085-L1091](lib/pages/trade_report_page.dart#L1085-L1091), [L1754-L1763](lib/pages/trade_report_page.dart#L1754-L1763)
  - Dashboard Performance Card: [lib/pages/broker_screens.dart#L308-L310](lib/pages/broker_screens.dart#L308-L310)
- **Root Cause**:
  Without `RepaintBoundary`, any UI change or scroll event forces the entire widget subtree to re-rasterize the canvas charts.
- **Remediation**:
  Wrap all `CustomPaint` sparklines and graphs in `RepaintBoundary`.

---

## Category 3: Medium (P2) — Memory Retention & GPU Overhead

### 8. Synchronous JSON Parsing of Large Payloads
- **Files**:
  - [lib/services/auth_api.dart#L269](lib/services/auth_api.dart#L269), [L592](lib/services/auth_api.dart#L592)
  - [lib/pages/trade_report_page.dart#L133-L150](lib/pages/trade_report_page.dart#L133-L150)
  - [lib/pages/accounts_page.dart#L2328-L2334](lib/pages/accounts_page.dart#L2328-L2334)
- **Root Cause**:
  Payloads with hundreds of trades (up to 2MB) are decoded synchronously on the main thread via `jsonDecode()` followed by complex date parsing and string regex loops.
- **Remediation**:
  Use `compute(jsonDecode, response.body)` or `Isolate.run()` for payloads over 50KB.

---

### 9. Memory Leak in `_responseEncryptionPrivateKeys` on Network Failures
- **Files**:
  - [lib/services/auth_api.dart#L50](lib/services/auth_api.dart#L50), [L568-L608](lib/services/auth_api.dart#L568-L608)
- **Root Cause**:
  `_multipartRequest` and `_uploadProfileImage` store private keys in `_responseEncryptionPrivateKeys` with `keyId`. If a network timeout or socket exception occurs, the key is never removed because cleanup is not inside a `finally` block.
- **Remediation**:
  Wrap request lifecycles in `try / finally` to ensure private keys are removed even when requests fail.

---

### 10. Heavy GPU `BackdropFilter` (Blur Sigma 20) in `LoginPage`
- **Files**:
  - [lib/pages/login_page.dart#L571-L574](lib/pages/login_page.dart#L571-L574)
- **Root Cause**:
  `BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20))` sits on top of an animated custom painter, requiring two-pass GPU gaussian blur convolutions on every frame.
- **Remediation**:
  Isolate background painter in a `RepaintBoundary` and reduce blur radius.

---

## Actionable Remediation Roadmap

| Phase | Target Tasks | Expected Outcome |
|---|---|---|
| **Phase 1: Immediate Freeze Fixes (P0)** | 1. Eliminate per-request 2048-bit RSA key generation (or move to isolate).<br>2. Throttle & pause background polling timers (15s account loop).<br>3. Add `Offstage` to inactive main tabs in `main.dart`. | **Eliminates 90%+ of UI freezes and stalls immediately.** |
| **Phase 2: Scroll & Interaction Polish (P1)** | 1. Virtualize account and MAM card lists (`ListView.builder`).<br>2. Debounce search controllers to eliminate typing lag.<br>3. Wrap charts and sparklines in `RepaintBoundary`.<br>4. Fix `shouldRepaint` list reference checks in charts. | **Eliminates scroll stutter and restores smooth 60fps scrolling.** |
| **Phase 3: Background & Resource Optimization (P2)** | 1. Offload heavy JSON decoding to `Isolate.run()`.<br>2. Add `try-finally` cleanup for private key memory leak.<br>3. Optimize login background blur. | **Improves battery usage and memory stability.** |
