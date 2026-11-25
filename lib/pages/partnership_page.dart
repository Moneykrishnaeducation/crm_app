import 'package:flutter/material.dart';

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
  bool _loading = true;
  bool _isIbApproved = false;
  String _ibStatus = ''; // 'pending', 'rejected', 'approved', ''
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
    setState(() => _loading = true);
    try {
      // 1. Fetch user's IB status first to avoid unauthorized 403 Forbidden queries
      Map<String, dynamic> statusRes = {};
      try {
        statusRes = await AuthApi.instance.getIbStatus();
      } catch (_) {}

      final isApproved = statusRes['approved'] == true ||
          statusRes['has_ib_status'] == true ||
          (statusRes['status'] != null &&
              statusRes['status'].toString().toLowerCase() == 'approved');
      final ibStatus = (statusRes['status'] ?? '').toString().toLowerCase();

      // If status explicitly says the user is not an approved IB, handle cleanly without calling 403 endpoints
      if (!isApproved && statusRes.isNotEmpty) {
        if (mounted) {
          setState(() {
            _isIbApproved = false;
            _ibStatus = ibStatus;
            _loading = false;
          });
        }
        return;
      }

      bool hit403 = false;
      final results = await Future.wait([
        AuthApi.instance.getIbStats().catchError((e) {
          if (e is AuthApiException && e.statusCode == 403) hit403 = true;
          return <String, dynamic>{};
        }),
        AuthApi.instance.getIbReferralLinks().catchError((e) {
          if (e is AuthApiException && e.statusCode == 403) hit403 = true;
          return <String, dynamic>{};
        }),
        AuthApi.instance.getIbCommissionTransactions().catchError((e) {
          if (e is AuthApiException && e.statusCode == 403) hit403 = true;
          return <String, dynamic>{};
        }),
        AuthApi.instance.getIbClientTree(page: 1, perPage: 1000).catchError((e) {
          if (e is AuthApiException && e.statusCode == 403) hit403 = true;
          return <String, dynamic>{};
        }),
      ]);

      if (hit403) {
        if (mounted) {
          setState(() {
            _isIbApproved = false;
            _ibStatus = ibStatus.isNotEmpty ? ibStatus : 'none';
            _loading = false;
          });
        }
        return;
      }

      final statsRes = results[0];
      final linksRes = results[1];
      final txnsRes = results[2];
      final treeRes = results[3];

      // Parse Dashboard Data
      final dbData = IbDashboardData.fromJson(statsRes);

      // Parse Referral Links
      final parsedLinks = <IbReferralLink>[];
      final rawLinks = linksRes['referral_links'] ??
          (linksRes['links'] is List ? linksRes['links'] : null);
      if (rawLinks is List && rawLinks.isNotEmpty) {
        for (var i = 0; i < rawLinks.length; i++) {
          if (rawLinks[i] is Map) {
            parsedLinks.add(
              IbReferralLink.fromJson(rawLinks[i].cast<String, dynamic>(), index: i),
            );
          }
        }
      } else {
        final legacyLink =
            linksRes['referral_link'] ?? linksRes['link'] ?? statsRes['referralLink'];
        if (legacyLink != null && legacyLink.toString().isNotEmpty) {
          parsedLinks.add(IbReferralLink(
            profileName: 'Default Profile',
            referralLink: legacyLink.toString(),
            referralCode: (linksRes['referral_code'] ?? '').toString(),
            isPrimary: true,
          ));
        }
      }

      // Parse Commission Transactions
      final parsedTxns = <IbCommissionTxn>[];
      final rawTxns = txnsRes['results'] ?? txnsRes['data'] ?? txnsRes['transactions'];
      if (rawTxns is List) {
        for (final item in rawTxns.whereType<Map>()) {
          parsedTxns.add(IbCommissionTxn.fromJson(item.cast<String, dynamic>()));
        }
      }

      // Parse Client Tree
      final parsedClients = <IbClient>[];
      final rawClients = treeRes['clients'] ?? treeRes['results'] ?? treeRes['data'];
      if (rawClients is List) {
        for (final item in rawClients.whereType<Map>()) {
          parsedClients.add(IbClient.fromJson(item.cast<String, dynamic>()));
        }
      }

      if (mounted) {
        setState(() {
          _isIbApproved = true;
          _ibStatus = 'approved';
          _dashboardData = dbData;
          _referralLinks = parsedLinks;
          _commissionTxns = parsedTxns;
          _clientTree = parsedClients;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
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

    if (_loading) {
      return Scaffold(
        backgroundColor: colors.canvas,
        body: PartnershipBackdrop(
          colors: colors,
          child: Center(
            child: CircularProgressIndicator(color: colors.blue),
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
      onBack: widget.onBack,
      onRefresh: _loadAllData,
      onExitDemoMode: _exitDemoPreviewMode,
      onIbChanged: () {
        if (mounted) _loadAllData();
      },
    );
  }
}
