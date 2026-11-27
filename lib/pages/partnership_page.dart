import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../services/auth_api.dart';
import 'partnership/models/partnership_models.dart';
import 'partnership/widgets/partnership_application_view.dart';
import 'partnership/widgets/partnership_dashboard_view.dart';
import 'partnership/widgets/partnership_theme.dart';

export 'partnership/pages/broker_client_tree_page.dart';
export 'partnership/pages/broker_commission_ledger_page.dart';
export 'partnership/pages/broker_commission_withdrawal_page.dart';
export 'partnership/pages/broker_referral_studio_page.dart';

// ============================================================================
// MAIN PARTNERSHIP PAGE: BROKERPARTNERSHIPPAGE
// ============================================================================

class BrokerPartnershipPage extends StatefulWidget {
  const BrokerPartnershipPage({
    super.key,
    this.onBack,
    this.onSelectPage,
  });

  final VoidCallback? onBack;
  final ValueChanged<String>? onSelectPage;

  @override
  State<BrokerPartnershipPage> createState() => _BrokerPartnershipPageState();
}

class _BrokerPartnershipPageState extends State<BrokerPartnershipPage> {
  bool _initialLoading = true;
  bool _loading = true;
  bool _loadingInFlight = false;
  int _loadGeneration = 0;
  bool _isIbApproved = false;
  String _ibStatus = ''; // 'pending', 'rejected', 'approved', ''
  String? _statusError;
  String? _dataError;
  bool _demoPreviewMode = false;

  IbDashboardData _dashboardData = IbDashboardData();
  List<IbReferralLink> _referralLinks = [];
  List<IbClient> _clientTree = [];
  List<IbCommissionTxn> _commissionTxns = [];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    if (_loadingInFlight) return;
    _loadingInFlight = true;
    final gen = ++_loadGeneration;

    if (mounted) {
      setState(() {
        _loading = true;
        _statusError = null;
      });
    }

    try {
      // 1. Fetch user's IB status first to avoid unauthorized 403 Forbidden queries.
      final Map<String, dynamic> statusRes;
      try {
        statusRes = await AuthApi.instance.getIbStatus();
      } on AuthApiException catch (e) {
        if (!mounted || gen != _loadGeneration) return;
        setState(() {
          if (_isIbApproved) {
            _dataError = e.message;
          } else {
            _statusError = e.message;
          }
          _loading = false;
          _initialLoading = false;
        });
        return;
      } catch (_) {
        if (!mounted || gen != _loadGeneration) return;
        const msg = 'Unable to verify Introducing Broker status. Please try again.';
        setState(() {
          if (_isIbApproved) {
            _dataError = msg;
          } else {
            _statusError = msg;
          }
          _loading = false;
          _initialLoading = false;
        });
        return;
      }

      if (!mounted || gen != _loadGeneration) return;

      final ibStatus = (statusRes['status'] ?? '').toString().trim().toLowerCase();
      final isApproved = statusRes['approved'] == true || ibStatus == 'approved';

      // Never fall through to 403-protected IB endpoints when not explicitly approved.
      if (!isApproved || statusRes.isEmpty) {
        setState(() {
          _isIbApproved = false;
          _ibStatus = ibStatus;
          _statusError = null;
          _dataError = null;
          _loading = false;
          _initialLoading = false;
        });
        return;
      }

      bool hit403 = false;
      final failedEndpoints = <String>[];
      String? firstEndpointError;

      Future<Map<String, dynamic>> fetchEndpoint(
        String label,
        Future<Map<String, dynamic>> Function() request,
      ) async {
        try {
          return await request();
        } on AuthApiException catch (e) {
          if (e.statusCode == 403) {
            hit403 = true;
          } else {
            failedEndpoints.add(label);
            firstEndpointError ??= e.message;
          }
          return <String, dynamic>{};
        } catch (_) {
          failedEndpoints.add(label);
          return <String, dynamic>{};
        }
      }

      final results = await Future.wait([
        fetchEndpoint('stats', AuthApi.instance.getIbStats),
        fetchEndpoint('referral links', AuthApi.instance.getIbReferralLinks),
        fetchEndpoint(
          'commission ledger',
          AuthApi.instance.getIbCommissionTransactions,
        ),
        fetchEndpoint(
          'client tree',
          () => AuthApi.instance.getIbClientTree(page: 1, perPage: 1000),
        ),
      ]);

      if (!mounted || gen != _loadGeneration) return;

      if (hit403) {
        setState(() {
          _isIbApproved = false;
          _ibStatus = ibStatus.isNotEmpty ? ibStatus : 'none';
          _statusError = null;
          _dataError = null;
          _loading = false;
          _initialLoading = false;
        });
        return;
      }

      final statsRes = results[0];
      final linksRes = results[1];
      final txnsRes = results[2];
      final treeRes = results[3];

      final dbData = IbDashboardData.fromJson(statsRes);
      final parsedLinks = IbReferralLink.listFromResponse(
        linksRes,
        statsResponse: statsRes,
      );
      final parsedTxns = extractPartnershipList(
        txnsRes,
        keys: const ['results', 'transactions', 'data'],
      ).map(IbCommissionTxn.fromJson).toList();
      final parsedClients = extractPartnershipList(
        treeRes,
        keys: const ['clients', 'results', 'data'],
      ).map(IbClient.fromJson).toList();

      String? dataError;
      if (failedEndpoints.isNotEmpty) {
        dataError = failedEndpoints.length == 4
            ? (firstEndpointError ??
                'Unable to load partnership metrics. Please tap Retry.')
            : 'Some partnership data failed to load (${failedEndpoints.join(', ')}). Tap Retry to refresh.';
      }

      setState(() {
        _isIbApproved = true;
        _ibStatus = 'approved';
        _statusError = null;
        _dataError = dataError;
        _dashboardData = dbData;
        _referralLinks = parsedLinks;
        _commissionTxns = parsedTxns;
        _clientTree = parsedClients;
        _loading = false;
        _initialLoading = false;
      });
    } catch (_) {
      if (!mounted || gen != _loadGeneration) return;
      setState(() {
        _loading = false;
        _initialLoading = false;
        if (!_isIbApproved) {
          _statusError ??=
              'Unable to load partnership details. Please try again.';
        } else {
          _dataError ??= 'Unable to refresh partnership metrics. Tap Retry.';
        }
      });
    } finally {
      if (gen == _loadGeneration) {
        _loadingInFlight = false;
      }
    }
  }

  void _enterDemoPreviewMode() {
    setState(() {
      _demoPreviewMode = true;
      if (_dashboardData.isEmpty) _dashboardData = IbDashboardData.demo();
      if (_referralLinks.isEmpty) _referralLinks = IbReferralLink.demoList();
      if (_clientTree.isEmpty) _clientTree = IbClient.demoTree();
    });
  }

  void _exitDemoPreviewMode() {
    setState(() {
      _demoPreviewMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = PartnershipColors.of(context);

    if (_initialLoading) {
      return PartnershipSkeletonizer(
        colors: colors,
        enabled: true,
        child: PartnershipDashboardView(
          dashboardData: IbDashboardData.demo(),
          referralLinks: IbReferralLink.demoList(),
          clientTree: IbClient.demoTree(),
          commissionTxns: const [],
          loading: true,
          demoPreviewMode: false,
          onBack: widget.onBack,
          onRefresh: _loadAllData,
          onExitDemoMode: _exitDemoPreviewMode,
          onIbChanged: () {},
        ),
      );
    }

    if (!_isIbApproved && !_demoPreviewMode && _statusError != null) {
      return Scaffold(
        backgroundColor: colors.canvas,
        appBar: widget.onBack != null || Navigator.canPop(context)
            ? AppBar(
                backgroundColor: colors.appBarBg,
                foregroundColor: colors.text,
                elevation: 0,
                leading: IconButton(
                  tooltip: 'Back',
                  onPressed: widget.onBack ?? () => Navigator.pop(context),
                  icon: Icon(LucideIcons.arrowLeft, color: colors.text),
                ),
                title: const Text(
                  'Introducing Broker (IB)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              )
            : null,
        body: PartnershipBackdrop(
          colors: colors,
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.triangleAlert, size: 46, color: colors.red),
                    const SizedBox(height: 14),
                    Text(
                      'Unable to Load Partnership Status',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.text,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _statusError!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.muted,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: _loading ? null : _loadAllData,
                      style: FilledButton.styleFrom(
                        backgroundColor: colors.blue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(LucideIcons.refreshCw, size: 15),
                      label: const Text(
                        'Retry',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (!_isIbApproved && !_demoPreviewMode) {
      return PartnershipApplicationView(
        ibStatus: _ibStatus,
        onBack: widget.onBack,
        onRefresh: _loadAllData,
        onEnterDemoMode: _enterDemoPreviewMode,
        onApplicationSubmitted: () {
          if (mounted) setState(() => _ibStatus = 'pending');
        },
      );
    }

    return PartnershipDashboardView(
      dashboardData: _dashboardData,
      referralLinks: _referralLinks,
      clientTree: _clientTree,
      commissionTxns: _commissionTxns,
      loading: _loading,
      demoPreviewMode: _demoPreviewMode,
      errorMessage: _dataError,
      onBack: widget.onBack,
      onRefresh: _loadAllData,
      onExitDemoMode: _exitDemoPreviewMode,
      onIbChanged: () {
        if (mounted) _loadAllData();
      },
    );
  }
}
