import 'dart:async';

import 'package:crm_app/app_haptics.dart';
import 'package:crm_app/pages/pamm/models/pamm_models.dart';
import 'package:crm_app/pages/pamm/widgets/pamm_detail_views.dart';
import 'package:crm_app/pages/pamm/widgets/pamm_dialogs.dart';
import 'package:crm_app/pages/pamm/widgets/pamm_shared_widgets.dart';
import 'package:crm_app/pages/pamm/widgets/pamm_tab_views.dart';
import 'package:crm_app/services/auth_api.dart';
import 'package:crm_app/widgets/pool_trades_modal.dart';
import 'package:flutter/material.dart';

class PammPage extends StatefulWidget {
  const PammPage({super.key, this.onBack, this.onSelectPage});

  final VoidCallback? onBack;
  final ValueChanged<String>? onSelectPage;

  @override
  State<PammPage> createState() => PammPageState();
}

class PammPageState extends State<PammPage> {
  int _tab = 0;
  String _query = '';
  String _selectedFilter = 'All Pools';
  PammPool? _selectedManagedPool;
  PammPool? _selectedAvailablePool;
  PammPool? _connectedInvestorPool;
  List<PammInvestment> _connectedInvestors = [];
  bool _loadingConnectedInvestors = false;
  String? _connectedInvestorsError;
  final _search = TextEditingController();
  final List<PammPool> _managed = [];
  final List<PammPool> _available = [];
  final List<PammInvestment> _investments = [];
  bool _loadingPammLists = true;
  bool _hasLoadedInitialTabs = false;
  String? _pammListError;
  String? _togglingPammId;
  String? _syncingPammId;
  final Map<int, int> _listLoadSeq = <int, int>{};
  int _listsLoadSeq = 0;
  int _connectedInvestorsSeq = 0;

  bool get hasActiveSubView =>
      _connectedInvestorPool != null ||
      _selectedManagedPool != null ||
      _selectedAvailablePool != null;

  bool popSubView() {
    if (_connectedInvestorPool != null) {
      setState(() {
        _connectedInvestorPool = null;
        _connectedInvestorsSeq++;
        _loadingConnectedInvestors = false;
      });
      return true;
    }
    if (_selectedManagedPool != null) {
      setState(() => _selectedManagedPool = null);
      return true;
    }
    if (_selectedAvailablePool != null) {
      setState(() => _selectedAvailablePool = null);
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _loadPammLists(lists: const [0]);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  PammPool? _findPoolMatch(List<PammPool> pools, PammPool target) {
    for (final item in pools) {
      if ((target.id.isNotEmpty && item.id == target.id) ||
          (target.login.isNotEmpty && item.login == target.login)) {
        return item;
      }
    }
    return null;
  }

  Future<void> _loadPammLists({List<int>? lists}) async {
    final requestedLists = (lists ?? [_tab]).toSet().toList();
    final expectedSeq = <int, int>{};
    for (final index in requestedLists) {
      expectedSeq[index] = (_listLoadSeq[index] = (_listLoadSeq[index] ?? 0) + 1);
    }
    final overallSeq = ++_listsLoadSeq;
    if (mounted) {
      setState(() {
        _loadingPammLists = true;
        _pammListError = null;
      });
    }
    final errors = <Object>[];
    Future<Map<String, dynamic>?> load(
      Future<Map<String, dynamic>> request,
    ) async {
      try {
        return await request;
      } catch (error) {
        errors.add(error);
        return null;
      }
    }

    final requests = <int, Future<Map<String, dynamic>> Function()>{
      0: AuthApi.instance.getPammManaged,
      1: AuthApi.instance.getPammAvailable,
      2: AuthApi.instance.getPammInvestments,
    };
    final responses = await Future.wait<Map<String, dynamic>?>(
      requestedLists.map((index) => load(requests[index]!())),
    );
    if (!mounted) return;
    setState(() {
      for (var i = 0; i < requestedLists.length; i++) {
        final index = requestedLists[i];
        if (expectedSeq[index] != _listLoadSeq[index]) continue;
        final response = responses[i];
        if (response == null) continue;
        final rows = extractPammRows(response);
        switch (index) {
          case 0:
            _managed
              ..clear()
              ..addAll(rows.map(pammPoolFromMap));
            if (_selectedManagedPool != null) {
              final refreshed = _findPoolMatch(_managed, _selectedManagedPool!);
              if (refreshed != null) {
                _selectedManagedPool = refreshed;
              }
            }
            break;
          case 1:
            _available
              ..clear()
              ..addAll(rows.map(pammPoolFromMap));
            if (_selectedAvailablePool != null) {
              final refreshed =
                  _findPoolMatch(_available, _selectedAvailablePool!);
              if (refreshed != null) {
                _selectedAvailablePool = refreshed;
              }
            }
            break;
          case 2:
            _investments
              ..clear()
              ..addAll(rows.map(pammInvestmentFromMap));
            if (_selectedAvailablePool != null &&
                !_selectedAvailablePool!.hasPoolDetails) {
              final refreshedInv = _investmentFor(_selectedAvailablePool!);
              if (refreshedInv != null) {
                _selectedAvailablePool = PammPool(
                  refreshedInv.name,
                  refreshedInv.login,
                  _selectedAvailablePool!.leverage,
                  refreshedInv.value,
                  _selectedAvailablePool!.share,
                  id: refreshedInv.pammId.isNotEmpty
                      ? refreshedInv.pammId
                      : _selectedAvailablePool!.id,
                  pnl: refreshedInv.pnl,
                  manager: refreshedInv.manager,
                  server: _selectedAvailablePool!.server,
                  status: _selectedAvailablePool!.status,
                  hasPoolDetails: false,
                );
              }
            }
            break;
        }
      }
      if (overallSeq == _listsLoadSeq) {
        _loadingPammLists = false;
        _hasLoadedInitialTabs = true;
        if (errors.isNotEmpty) {
          _pammListError = responses.every((response) => response == null)
              ? 'PAMM accounts could not be loaded.'
              : 'Some PAMM account data could not be refreshed.';
        }
      }
    });
  }

  Future<void> _loadConnectedInvestors(PammPool pool) async {
    final seq = ++_connectedInvestorsSeq;
    final pammId = int.tryParse(pool.id);
    setState(() {
      _connectedInvestorPool = pool;
      _connectedInvestors = [];
      _connectedInvestorsError = null;
      _loadingConnectedInvestors = pammId != null;
    });
    if (pammId == null) {
      setState(
        () => _connectedInvestorsError =
            'This pool is missing its account identifier. Refresh and try again.',
      );
      return;
    }
    try {
      final response = await AuthApi.instance.getPammInvestors(pammId);
      if (!mounted ||
          seq != _connectedInvestorsSeq ||
          _connectedInvestorPool?.id != pool.id) {
        return;
      }
      setState(() {
        _connectedInvestors =
            extractPammRows(response).map(pammInvestmentFromMap).toList();
        _loadingConnectedInvestors = false;
      });
    } catch (error) {
      if (!mounted ||
          seq != _connectedInvestorsSeq ||
          _connectedInvestorPool?.id != pool.id) {
        return;
      }
      setState(() {
        _loadingConnectedInvestors = false;
        _connectedInvestorsError = error is AuthApiException
            ? error.message
            : 'Unable to load connected investors. Please try again.';
      });
    }
  }

  PammInvestment? _investmentFor(PammPool pool) {
    for (final investment in _investments) {
      if ((pool.id.isNotEmpty && investment.pammId == pool.id) ||
          (pool.login.isNotEmpty && investment.login == pool.login)) {
        return investment;
      }
    }
    return null;
  }

  String _resolveInvestmentPammId(PammInvestment item) {
    if (item.pammId.isNotEmpty) return item.pammId;
    if (_selectedAvailablePool != null &&
        _selectedAvailablePool!.id.isNotEmpty &&
        _selectedAvailablePool!.login == item.login) {
      return _selectedAvailablePool!.id;
    }
    for (final pool in [..._available, ..._managed]) {
      if (pool.id.isNotEmpty &&
          item.login.isNotEmpty &&
          pool.login == item.login) {
        return pool.id;
      }
    }
    return '';
  }

  void _openPoolTrades([PammPool? pool]) {
    final targetPool = pool ?? _selectedManagedPool ?? _selectedAvailablePool;
    final login = targetPool?.login.trim() ?? '';
    if (login.isEmpty) {
      showPammMessage(
        context,
        'This pool is missing its MT5 login. Refresh the list and try again.',
        isError: true,
      );
      return;
    }
    final name = targetPool?.name ?? 'PAMM Pool';
    PoolTradesModal.show(
      context,
      poolLogin: login,
      poolName: name,
      isManager: targetPool == _selectedManagedPool,
    );
  }

  Future<void> _syncPammEquity(PammPool pool) async {
    if (_syncingPammId != null) return;
    final pammId = int.tryParse(pool.id);
    if (pammId == null) {
      showPammMessage(
        context,
        'This pool is missing its account identifier. Refresh the list and try again.',
        isError: true,
      );
      return;
    }
    setState(() => _syncingPammId = pool.id);
    AppHaptics.mediumImpact();
    try {
      await AuthApi.instance.syncPammEquity(pammId);
      await _loadPammLists(lists: const [0]);
      if (!mounted || _selectedManagedPool == null) return;
      if (_selectedManagedPool!.id == pool.id) {
        final refreshedPool = _findPoolMatch(_managed, pool);
        if (refreshedPool != null) {
          setState(() => _selectedManagedPool = refreshedPool);
        }
      }
      showPammMessage(context, 'PAMM balance synchronized from MT5.');
    } catch (error) {
      if (mounted) {
        showPammMessage(
          context,
          error is AuthApiException
              ? error.message
              : 'MT5 synchronization failed. Please try again.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _syncingPammId = null);
    }
  }

  Future<void> _toggleManagedPool(PammPool pool) async {
    final nextEnabled = pool.status != 'Open';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          nextEnabled ? 'Open investment pool?' : 'Close investment pool?',
        ),
        content: Text(
          nextEnabled
              ? 'Open ${pool.name} to allow new investors to join?'
              : 'Investors will no longer be able to join ${pool.name}.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              AppHaptics.selectionClick();
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              AppHaptics.mediumImpact();
              Navigator.pop(dialogContext, true);
            },
            child: Text(nextEnabled ? 'Open pool' : 'Close pool'),
          ),
        ],
      ),
    );
    final pammId = int.tryParse(pool.id);
    if (confirm != true || !mounted) return;
    if (pammId == null) {
      showPammMessage(
        context,
        'This pool is missing its account identifier. Refresh the list and try again.',
      );
      return;
    }
    setState(() => _togglingPammId = pool.id);
    try {
      await AuthApi.instance.setPammPoolEnabled(
        pammId: pammId,
        enabled: nextEnabled,
      );
      if (!mounted) return;
      setState(() => pool.status = nextEnabled ? 'Open' : 'Closed');
      await _loadPammLists(lists: const [0]);
      if (mounted) {
        showPammMessage(
          context,
          nextEnabled
              ? '${pool.name} is open for investors.'
              : '${pool.name} is closed.',
        );
      }
    } catch (error) {
      if (mounted) {
        showPammMessage(
          context,
          error is AuthApiException
              ? error.message
              : 'Unable to update pool status. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _togglingPammId = null);
    }
  }

  void _openManagedDetails(PammPool pool) {
    setState(() {
      _selectedManagedPool = pool;
      _selectedAvailablePool = null;
    });
  }

  void _openInvestmentDetails(PammInvestment investment) {
    PammPool? pool;
    for (final account in [..._available, ..._managed]) {
      if ((investment.pammId.isNotEmpty && account.id == investment.pammId) ||
          (investment.login.isNotEmpty && account.login == investment.login)) {
        pool = account;
        break;
      }
    }
    final selectedPool = pool ??
        PammPool(
          investment.name,
          investment.login,
          '—',
          investment.value,
          0,
          id: investment.pammId,
          pnl: investment.pnl,
          manager: investment.manager,
          server: '—',
          hasPoolDetails: false,
        );
    setState(() {
      _selectedAvailablePool = selectedPool;
      _selectedManagedPool = null;
    });
  }

  void _openDeposit({
    required String accountName,
    required String pammId,
    required bool isManager,
  }) {
    showPammDepositDialog(
      context,
      accountName: accountName,
      pammId: pammId,
      isManager: isManager,
      onSuccess: () => _loadPammLists(lists: [isManager ? 0 : 2]),
    );
  }

  void _openWithdraw({
    required String accountName,
    required String pammId,
    required bool isManager,
    required double availableBalance,
  }) {
    showPammWithdrawDialog(
      context,
      accountName: accountName,
      pammId: pammId,
      isManager: isManager,
      availableBalance: availableBalance,
      onSuccess: () => _loadPammLists(lists: [isManager ? 0 : 2]),
    );
  }

  void _openJoinPool(PammPool pool) {
    showJoinPammInvestmentDialog(
      context,
      pool: pool,
      onJoined: () async {
        await _loadPammLists(lists: const [2]);
        if (!mounted) return;
        setState(() {
          _selectedAvailablePool = null;
          _tab = 2;
          _query = '';
          _search.clear();
          _selectedFilter = 'All Investments';
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isListMode = _selectedManagedPool == null &&
        _selectedAvailablePool == null &&
        _connectedInvestorPool == null;

    return PopScope(
      canPop: !hasActiveSubView,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        popSubView();
      },
      child: Scaffold(
      backgroundColor: PammColors.bg(context),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 84),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isListMode ? 900 : 1280),
              child: _connectedInvestorPool != null
                  ? PammConnectedPortfolioView(
                      pool: _connectedInvestorPool!,
                      investors: _connectedInvestors,
                      loading: _loadingConnectedInvestors,
                      error: _connectedInvestorsError,
                      onClose: popSubView,
                      onRetry: () =>
                          _loadConnectedInvestors(_connectedInvestorPool!),
                    )
                  : _selectedManagedPool != null
                      ? PammManagedDetailView(
                          pool: _selectedManagedPool!,
                          togglingPammId: _togglingPammId,
                          syncingPammId: _syncingPammId,
                          onBack: popSubView,
                          onLoadConnectedInvestors: () =>
                              _loadConnectedInvestors(_selectedManagedPool!),
                          onTogglePool: () =>
                              _toggleManagedPool(_selectedManagedPool!),
                          onDeposit: () => _openDeposit(
                            accountName: _selectedManagedPool!.name,
                            pammId: _selectedManagedPool!.id,
                            isManager: true,
                          ),
                          onWithdraw: () => _openWithdraw(
                            accountName: _selectedManagedPool!.name,
                            pammId: _selectedManagedPool!.id,
                            isManager: true,
                            availableBalance:
                                _selectedManagedPool!.managerBalance,
                          ),
                          onSyncEquity: () =>
                              _syncPammEquity(_selectedManagedPool!),
                          onOpenPoolTrades: () =>
                              _openPoolTrades(_selectedManagedPool),
                        )
                      : _selectedAvailablePool != null
                          ? PammAvailableDetailView(
                              pool: _selectedAvailablePool!,
                              investment:
                                  _investmentFor(_selectedAvailablePool!),
                              onBack: popSubView,
                              onJoin: () =>
                                  _openJoinPool(_selectedAvailablePool!),
                              onDeposit: (inv) => _openDeposit(
                                accountName: inv.name,
                                pammId: _resolveInvestmentPammId(inv),
                                isManager: false,
                              ),
                              onWithdraw: (inv) => _openWithdraw(
                                accountName: inv.name,
                                pammId: _resolveInvestmentPammId(inv),
                                isManager: false,
                                availableBalance: inv.value,
                              ),
                              onOpenPoolTrades: () =>
                                  _openPoolTrades(_selectedAvailablePool),
                            )
                          : Column(
                              children: [
                                PammTopBar(
                                  tab: _tab,
                                  managedCount: _managed.length,
                                  availableCount: _available.length,
                                  investmentsCount: _investments.length,
                                  loading: _loadingPammLists,
                                  shimmerTabs: _loadingPammLists &&
                                      !_hasLoadedInitialTabs,
                                  error: _pammListError,
                                  onSelectTab: (i) {
                                    setState(() {
                                      _tab = i;
                                      _query = '';
                                      _search.clear();
                                      _selectedFilter = i == 2
                                          ? 'All Investments'
                                          : 'All Pools';
                                    });
                                    _loadPammLists(lists: [i]);
                                  },
                                  onRetry: _loadPammLists,
                                ),
                                Expanded(
                                  child: IndexedStack(
                                    index: _tab,
                                    children: [
                                      PammManagedTabView(
                                        managed: _managed,
                                        loading: _loadingPammLists,
                                        onRefresh: () =>
                                            _loadPammLists(lists: const [0]),
                                        query: _query,
                                        selectedFilter: _selectedFilter,
                                        searchController: _search,
                                        onQueryChanged: (v) =>
                                            setState(() => _query = v),
                                        onClearQuery: () {
                                          _search.clear();
                                          setState(() => _query = '');
                                        },
                                        onSelectFilter: (f) =>
                                            setState(() => _selectedFilter = f),
                                        onCreatePool: () =>
                                            showCreatePammPoolDialog(
                                          context,
                                          onPoolCreated: () => _loadPammLists(
                                            lists: const [0],
                                          ),
                                        ),
                                        onOpenDetails: _openManagedDetails,
                                        onDeposit: (pool) => _openDeposit(
                                          accountName: pool.name,
                                          pammId: pool.id,
                                          isManager: true,
                                        ),
                                      ),
                                      PammAvailableTabView(
                                        available: _available,
                                        loading: _loadingPammLists,
                                        onRefresh: () =>
                                            _loadPammLists(lists: const [1]),
                                        query: _query,
                                        selectedFilter: _selectedFilter,
                                        searchController: _search,
                                        onQueryChanged: (v) =>
                                            setState(() => _query = v),
                                        onClearQuery: () {
                                          _search.clear();
                                          setState(() => _query = '');
                                        },
                                        onSelectFilter: (f) =>
                                            setState(() => _selectedFilter = f),
                                        onInvest: _openJoinPool,
                                      ),
                                      PammInvestmentsTabView(
                                        investments: _investments,
                                        loading: _loadingPammLists,
                                        onRefresh: () =>
                                            _loadPammLists(lists: const [2]),
                                        query: _query,
                                        selectedFilter: _selectedFilter,
                                        searchController: _search,
                                        onQueryChanged: (v) =>
                                            setState(() => _query = v),
                                        onClearQuery: () {
                                          _search.clear();
                                          setState(() => _query = '');
                                        },
                                        onSelectFilter: (f) =>
                                            setState(() => _selectedFilter = f),
                                        onOpenDetails: _openInvestmentDetails,
                                        onDeposit: (item) => _openDeposit(
                                          accountName: item.name,
                                          pammId: _resolveInvestmentPammId(item),
                                          isManager: false,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}
