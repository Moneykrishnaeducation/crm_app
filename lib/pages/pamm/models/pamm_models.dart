import 'dart:math' as math;

import 'package:crm_app/app_notifications.dart';
import 'package:crm_app/services/auth_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class PammPool {
  PammPool(
    this.name,
    this.login,
    this.leverage,
    this.equity,
    this.share, {
    this.id = '',
    this.managerBalance = 0,
    this.pnl = 0,
    this.server = 'VTIndex-Live',
    this.status = 'Open',
    this.manager = 'PAMM Manager',
    this.hasPoolDetails = true,
  });

  final String id;
  final String name;
  final String login;
  final String leverage;
  final double equity;
  final double share;
  final double managerBalance;
  final double pnl;
  final String server;
  final String manager;
  final bool hasPoolDetails;
  String status;

  /// Placeholder items used by [PammSkeletonizer] while lists load.
  static List<PammPool> skeletonSamples() => [
        PammPool(
          'Alpha Quant Growth Pool',
          '8402190',
          '1:500',
          125400.00,
          20,
          id: 'skel-1',
          managerBalance: 15000.00,
          pnl: 4280.50,
          manager: 'Alexander Mercer',
        ),
        PammPool(
          'Steady FX Institutional',
          '8402245',
          '1:200',
          89200.00,
          25,
          id: 'skel-2',
          managerBalance: 10000.00,
          pnl: 1940.00,
          manager: 'Elena Rostova',
        ),
      ];
}

class PammInvestment {
  PammInvestment(
    this.login,
    this.name,
    this.manager,
    this.value,
    this.pnl,
    this.deposit,
    this.share, {
    this.id = '',
    this.pammId = '',
    this.managerProfitShare = 0,
    this.joinedOn = '',
  });

  final String login;
  final String name;
  final String manager;
  final String id;
  final String pammId;
  final double value;
  final double pnl;
  final double deposit;
  final double share;
  final double managerProfitShare;
  final String joinedOn;

  /// Placeholder items used by [PammSkeletonizer] while investments load.
  static List<PammInvestment> skeletonSamples() => [
        PammInvestment(
          '8402190',
          'Alpha Quant Growth Pool',
          'Alexander Mercer',
          12450.00,
          2450.00,
          10000.00,
          14.50,
          id: 'skel-inv-1',
          pammId: 'skel-1',
          managerProfitShare: 490.00,
        ),
        PammInvestment(
          '8402245',
          'Steady FX Institutional',
          'Elena Rostova',
          6820.00,
          820.00,
          6000.00,
          8.25,
          id: 'skel-inv-2',
          pammId: 'skel-2',
          managerProfitShare: 164.00,
        ),
      ];
}

abstract final class PammColors {
  static const blue = Color(0xFF2563EB);
  static const deepBlue = Color(0xFF1D4ED8);
  static const navy = Color(0xFF0B1E47);
  static const gold = Color(0xFFD4AF37);
  static const green = Color(0xFF10B981);
  static const greenText = Color(0xFF16A34A);
  static const rose = Color(0xFFEF4444);
  static const closedRose = Color(0xFFDC3152);

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color bg(BuildContext context) =>
      isDark(context) ? const Color(0xFF020617) : const Color(0xFFF8FAFC);

  static Color card(BuildContext context) =>
      isDark(context) ? const Color(0xFF0F172A) : Colors.white;

  static Color surface(BuildContext context) =>
      isDark(context) ? const Color(0xFF0B1222) : const Color(0xFFF1F5F9);

  static Color subtle(BuildContext context) =>
      isDark(context) ? const Color(0xFF162036) : const Color(0xFFF8FAFC);

  static Color border(BuildContext context) =>
      isDark(context) ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

  static Color text(BuildContext context) =>
      isDark(context) ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);

  static Color muted(BuildContext context) =>
      isDark(context) ? const Color(0xFF94A3B8) : const Color(0xFF475569);

  static Color positive(BuildContext context) =>
      isDark(context) ? const Color(0xFF22C55E) : greenText;

  static Color negative(BuildContext context) =>
      isDark(context) ? const Color(0xFFF87171) : const Color(0xFFDC2626);
}

/// Institutional fintech typography tokens (IBM Plex Sans + tabular numerals).
abstract final class PammType {
  static TextStyle heading(
    BuildContext context, {
    double size = 18,
    FontWeight weight = FontWeight.w700,
    Color? color,
    double? letterSpacing,
  }) =>
      GoogleFonts.ibmPlexSans(
        color: color ?? PammColors.text(context),
        fontSize: size,
        fontWeight: weight,
        letterSpacing: letterSpacing ?? -0.3,
      );

  static TextStyle body(
    BuildContext context, {
    double size = 13,
    FontWeight weight = FontWeight.w500,
    Color? color,
    double? height,
  }) =>
      GoogleFonts.ibmPlexSans(
        color: color ?? PammColors.text(context),
        fontSize: size,
        fontWeight: weight,
        height: height,
      );

  static TextStyle label(
    BuildContext context, {
    double size = 10.5,
    FontWeight weight = FontWeight.w700,
    Color? color,
    double letterSpacing = 0.5,
  }) =>
      GoogleFonts.ibmPlexSans(
        color: color ?? PammColors.muted(context),
        fontSize: size,
        fontWeight: weight,
        letterSpacing: letterSpacing,
      );

  static TextStyle figure(
    BuildContext context, {
    double size = 15,
    FontWeight weight = FontWeight.w700,
    Color? color,
  }) =>
      GoogleFonts.ibmPlexSans(
        color: color ?? PammColors.text(context),
        fontSize: size,
        fontWeight: weight,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}

/// Shared card & input decoration helpers for consistent PAMM styling.
abstract final class PammDecorations {
  static BoxDecoration card(
    BuildContext context, {
    double radius = 18,
    Color? color,
    Color? borderColor,
  }) {
    final dark = PammColors.isDark(context);
    return BoxDecoration(
      color: color ?? PammColors.card(context),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor ?? PammColors.border(context)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: dark ? 0.28 : 0.04),
          blurRadius: dark ? 16 : 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static InputDecoration input(
    BuildContext context, {
    required String hint,
    String? label,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    final border = PammColors.border(context);
    final muted = PammColors.muted(context);
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: PammType.body(context, size: 12.5, color: muted),
      hintStyle: PammType.body(
        context,
        size: 13,
        weight: FontWeight.w400,
        color: muted.withValues(alpha: 0.75),
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: PammColors.subtle(context),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: PammColors.blue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: PammColors.rose),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: PammColors.rose, width: 1.5),
      ),
    );
  }
}

List<Map<String, dynamic>> extractPammRows(Map<String, dynamic> response) {
  dynamic value = response;
  for (var depth = 0; depth < 5; depth++) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map((row) => row.cast<String, dynamic>())
          .toList(growable: false);
    }
    if (value is! Map) return const [];
    final map = value.cast<String, dynamic>();
    final rows = map['results'] ??
        map['accounts'] ??
        map['documents'] ??
        map['pamm'] ??
        map['data'];
    if (rows == null) return const [];
    value = rows;
  }
  return const [];
}

Map<String, dynamic> unwrapPammApiMap(Map<String, dynamic> response) {
  dynamic value = response;
  for (var depth = 0; depth < 5 && value is Map; depth++) {
    final map = value.cast<String, dynamic>();
    final nested = map['data'] ?? map['profile'] ?? map['result'];
    if (nested is Map) {
      value = nested;
    } else {
      return map;
    }
  }
  return value is Map ? value.cast<String, dynamic>() : <String, dynamic>{};
}

dynamic pammFirstValue(Map<String, dynamic> row, List<String> keys) {
  for (final key in keys) {
    final value = row[key];
    if (value != null && value.toString().trim().isNotEmpty) return value;
  }
  return null;
}

String pammStringValue(
  Map<String, dynamic> row,
  List<String> keys, {
  String fallback = '',
}) =>
    pammFirstValue(row, keys)?.toString() ?? fallback;

double? parsePammDouble(String raw) {
  final cleaned = raw.trim().replaceAll(',', '');
  if (cleaned.isEmpty) return null;
  final parsed = double.tryParse(cleaned);
  if (parsed == null || !parsed.isFinite) return null;
  return parsed;
}

double pammNumberValue(Map<String, dynamic> row, List<String> keys) {
  final value = pammFirstValue(row, keys);
  if (value is num) return value.toDouble();
  return parsePammDouble(value?.toString() ?? '') ?? 0;
}

bool _isClosedPammStatus(Map<String, dynamic> row) {
  if (row['is_active'] == false ||
      row['enabled'] == false ||
      row['is_accepting_investors'] == false) {
    return true;
  }
  final statusValue = pammStringValue(row, const ['status']).trim().toLowerCase();
  return statusValue.contains('clos') ||
      statusValue.contains('disab') ||
      statusValue.contains('inact');
}

PammPool pammPoolFromMap(Map<String, dynamic> row) {
  final id = pammStringValue(row, const ['id', 'pamm_id', 'pamm_internal_id']);
  final login = pammStringValue(
    row,
    const ['mt5_account_id', 'pamm_mt5_account_id', 'login'],
    fallback: id,
  );
  final leverageValue =
      pammStringValue(row, const ['leverage'], fallback: '500');
  final leverage =
      leverageValue.startsWith('1:') ? leverageValue : '1:$leverageValue';
  final status = _isClosedPammStatus(row) ? 'Closed' : 'Open';
  return PammPool(
    pammStringValue(
      row,
      const ['name', 'pam_account_name'],
      fallback: 'PAMM Pool',
    ),
    login,
    leverage,
    pammNumberValue(row, const ['total_equity', 'equity', 'manager_balance']),
    pammNumberValue(row, const ['profit_share', 'pamm_profit_share']),
    id: id,
    managerBalance: pammNumberValue(row, const ['manager_balance']),
    pnl: pammNumberValue(row, const ['total_profit', 'profit_loss', 'pnl']),
    server: pammStringValue(
      row,
      const ['server', 'mt5_server'],
      fallback: 'VTIndex-Live',
    ),
    status: status,
    manager: pammStringValue(
      row,
      const ['manager_name', 'manager'],
      fallback: 'PAMM Manager',
    ),
  );
}

PammInvestment pammInvestmentFromMap(Map<String, dynamic> row) {
  final rawPamm = row['pamm'] ?? row['pool'];
  final nestedPamm = rawPamm is Map ? rawPamm.cast<String, dynamic>() : null;

  final totalDeposited =
      pammNumberValue(row, const ['total_deposited', 'amount']);
  final totalWithdrawn = pammNumberValue(row, const ['total_withdrawn']);

  final poolNameKeys = const [
    'pam_account_name',
    'pamm_name',
    'pool_name',
    'name',
  ];
  var resolvedName = pammStringValue(row, poolNameKeys);
  if (resolvedName.isEmpty && nestedPamm != null) {
    resolvedName = pammStringValue(nestedPamm, poolNameKeys);
  }
  if (resolvedName.isEmpty) {
    resolvedName = pammStringValue(
      row,
      const ['user_name', 'investor_name', 'user_email'],
      fallback: 'PAMM Investment',
    );
  }

  var login = pammStringValue(
    row,
    const ['pamm_mt5_account_id', 'mt5_account_id', 'login', 'account_id'],
  );
  if (login.isEmpty && nestedPamm != null) {
    login = pammStringValue(
      nestedPamm,
      const ['mt5_account_id', 'pamm_mt5_account_id', 'login'],
    );
  }

  var manager = pammStringValue(row, const ['manager_name', 'manager']);
  if (manager.isEmpty && nestedPamm != null) {
    manager = pammStringValue(nestedPamm, const ['manager_name', 'manager']);
  }
  if (manager.isEmpty) {
    manager = 'PAMM Manager';
  }

  final directPammId = pammStringValue(
    row,
    const ['pamm_id', 'pool_id', 'pamm_internal_id'],
  );
  final nestedPammId = nestedPamm != null
      ? pammStringValue(nestedPamm, const ['id', 'pamm_id', 'pamm_internal_id'])
      : (rawPamm is num || rawPamm is String) &&
              rawPamm.toString().trim().isNotEmpty
          ? rawPamm.toString().trim()
          : '';
  final pammId = directPammId.isNotEmpty ? directPammId : nestedPammId;

  return PammInvestment(
    login,
    resolvedName,
    manager,
    pammNumberValue(
      row,
      const [
        'net_current_amount',
        'current_amount',
        'current_balance',
        'balance',
        'amount',
      ],
    ),
    pammNumberValue(row, const ['profit_loss', 'net_profit', 'pnl']),
    (totalDeposited - totalWithdrawn).clamp(0, double.infinity).toDouble(),
    pammNumberValue(row, const ['share_percentage', 'allocation_percentage']),
    id: pammStringValue(row, const ['id']),
    pammId: pammId,
    managerProfitShare: pammNumberValue(
      row,
      const ['manager_profit_share_accrued', 'pamm_profit_share'],
    ),
    joinedOn: pammStringValue(
      row,
      const ['joined_on', 'created_at', 'date_joined'],
    ),
  );
}

String pammRequestError(Object error, String fallback) {
  if (error is! AuthApiException) return fallback;
  final details = error.data?['details'];
  if (details is Map) {
    final fields = details.entries.map((entry) {
      final value = entry.value is List
          ? (entry.value as List).join(', ')
          : entry.value.toString();
      return '${entry.key}: $value';
    }).join(' · ');
    if (fields.isNotEmpty) return '${error.message}: $fields';
  }
  if (details is String &&
      details.trim().isNotEmpty &&
      details != error.message) {
    return '${error.message}: ${details.trim()}';
  }
  return error.message;
}

String generatePammPassword() {
  final random = math.Random.secure();
  const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  const lowercase = 'abcdefghijklmnopqrstuvwxyz';
  const digits = '0123456789';
  String pick(String characters) =>
      characters[random.nextInt(characters.length)];
  return '${pick(uppercase)}${List.generate(3, (_) => pick(lowercase)).join()}_${List.generate(3, (_) => pick(digits)).join()}';
}

String formatPammMoney(double value) {
  if (!value.isFinite) return r'$0.00';
  final formatted = value.abs().toStringAsFixed(2);
  return value < 0 && formatted != '0.00' ? '-\$$formatted' : '\$$formatted';
}

Future<void> copyPammValue(BuildContext context, String value) async {
  AppHaptics.lightImpact();
  await Clipboard.setData(ClipboardData(text: value));
  if (context.mounted) {
    showPammMessage(context, 'Copied to clipboard');
  }
}

OverlayEntry? _activePammOverlayEntry;

void _showPammOverlayBanner(
  OverlayState overlay,
  String message, {
  bool isError = false,
}) {
  _activePammOverlayEntry?.remove();
  _activePammOverlayEntry = null;
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (overlayContext) => _PammOverlayToast(
      message: message,
      isError: isError,
      onDismiss: () {
        if (_activePammOverlayEntry == entry) {
          _activePammOverlayEntry = null;
        }
        if (entry.mounted) {
          entry.remove();
        }
      },
    ),
  );
  _activePammOverlayEntry = entry;
  overlay.insert(entry);
}

class _PammOverlayToast extends StatefulWidget {
  const _PammOverlayToast({
    required this.message,
    required this.isError,
    required this.onDismiss,
  });

  final String message;
  final bool isError;
  final VoidCallback onDismiss;

  @override
  State<_PammOverlayToast> createState() => _PammOverlayToastState();
}

class _PammOverlayToastState extends State<_PammOverlayToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.isError ? 3500 : 2500),
    )..forward().whenComplete(() {
        if (mounted) widget.onDismiss();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor =
        widget.isError ? const Color(0xFF2E1014) : const Color(0xFF101F34);
    final accentColor =
        widget.isError ? const Color(0xFFF87171) : const Color(0xFF60A5FA);
    return Positioned(
      top: MediaQuery.paddingOf(context).top + 12,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: GestureDetector(
              onTap: widget.onDismiss,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: accentColor.withValues(alpha: 0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.28),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.isError
                          ? Icons.error_outline
                          : Icons.info_outline,
                      color: accentColor,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
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

void showPammMessage(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  if (!context.mounted) return;
  final route = ModalRoute.of(context);
  final hasModalContext = route is PopupRoute || route?.isCurrent == false;
  if (hasModalContext) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay != null) {
      _showPammOverlayBanner(overlay, message, isError: isError);
      return;
    }
  }
  if (appScaffoldMessengerKey.currentState != null) {
    showAppMessage(
      message,
      type: isError ? AppFeedbackType.error : AppFeedbackType.info,
    );
    return;
  }
  ScaffoldMessenger.maybeOf(context)
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
