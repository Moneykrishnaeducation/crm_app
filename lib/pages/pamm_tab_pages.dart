import 'package:flutter/material.dart';

abstract class _PammTabPage extends StatelessWidget {
  const _PammTabPage({required this.children, required this.storageKey});

  final List<Widget> children;
  final String storageKey;

  @override
  Widget build(BuildContext context) => ListView(
    key: PageStorageKey<String>(storageKey),
    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
    padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
    children: children,
  );
}

class PammManagedTabPage extends _PammTabPage {
  const PammManagedTabPage({required super.children}) : super(storageKey: 'pamm-managed-tab');
}

class PammAvailableTabPage extends _PammTabPage {
  const PammAvailableTabPage({required super.children}) : super(storageKey: 'pamm-available-tab');
}

class PammInvestmentsTabPage extends _PammTabPage {
  const PammInvestmentsTabPage({required super.children}) : super(storageKey: 'pamm-investments-tab');
}
