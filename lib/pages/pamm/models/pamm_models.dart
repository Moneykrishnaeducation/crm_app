import 'dart:math' as math;

import 'package:crm_app/app_haptics.dart';
import 'package:crm_app/services/auth_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  static const gold = Color(0xFFD4AF37);
  static const green = Color(0xFF10B981);
  static const rose = Color(0xFFEF4444);
  static const closedRose = Color(0xFFDC3152);

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color card(BuildContext context) =>
      isDark(context) ? const Color(0xFF0C1833) : Colors.white;

  static Color surface(BuildContext context) =>
      isDark(context) ? const Color(0xFF07142A) : const Color(0xFFF8FAFC);

  static Color border(BuildContext context) =>
      isDark(context) ? const Color(0xFF223C70) : const Color(0xFFCBD5E1);

  static Color text(BuildContext context) =>
      isDark(context) ? Colors.white : const Color(0xFF0A1629);

  static Color muted(BuildContext context) =>
      isDark(context) ? const Color(0xFFCBD5E1) : const Color(0xFF334155);
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

double pammNumberValue(Map<String, dynamic> row, List<String> keys) {
  final value = pammFirstValue(row, keys);
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString().replaceAll(',', '') ?? '') ?? 0;
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
  final acceptsInvestors = row['is_accepting_investors'];
  final statusValue = pammStringValue(row, const ['status']);
  final status = acceptsInvestors is bool
      ? (acceptsInvestors ? 'Open' : 'Closed')
      : (statusValue.toLowerCase().contains('clos') ? 'Closed' : 'Open');
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
  final totalDeposited =
      pammNumberValue(row, const ['total_deposited', 'amount']);
  final totalWithdrawn = pammNumberValue(row, const ['total_withdrawn']);
  return PammInvestment(
    pammStringValue(
      row,
      const ['pamm_mt5_account_id', 'mt5_account_id', 'login', 'account_id'],
    ),
    pammStringValue(
      row,
      const [
        'user_name',
        'investor_name',
        'pam_account_name',
        'name',
        'user_email',
      ],
      fallback: 'PAMM Investment',
    ),
    pammStringValue(
      row,
      const ['manager_name', 'manager'],
      fallback: 'PAMM Manager',
    ),
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
    pammId: pammStringValue(row, const ['pamm_id', 'id']),
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

String formatPammMoney(double value) => '\$${value.toStringAsFixed(2)}';

Future<void> copyPammValue(BuildContext context, String value) async {
  AppHaptics.lightImpact();
  await Clipboard.setData(ClipboardData(text: value));
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }
}

void showPammMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
