part of '../main.dart';

class BrokerSettingsPage extends StatelessWidget {
  const BrokerSettingsPage({
    super.key,
    this.themeMode = ThemeMode.system,
    this.onThemeModeChanged,
    this.onSelectPage,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode>? onThemeModeChanged;
  final ValueChanged<String>? onSelectPage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ColoredBox(
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                _SettingsRow(
                  title: 'Theme Mode',
                  value: _themeModeLabel(themeMode),
                  onTap: () => onSelectPage?.call('Theme Mode'),
                ),
                _SettingsRow(
                  title: 'Privacy Policy',
                  onTap: () => onSelectPage?.call('Privacy Policy'),
                ),
                const _SettingsRow(title: 'Version', value: 'V 2.20.0 (g)'),
                const _SettingsRow(title: 'Sub-version', value: '1', showChevron: false),
              ],
            ),
          ),
          SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(18, 8, 18, 14),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  backgroundColor: Colors.transparent,
                  barrierColor: Colors.black54,
                  isDismissible: true,
                  isScrollControlled: true,
                  builder: (sheetContext) => LogoutBottomSheet(
                    onConfirm: () {
                      Navigator.of(sheetContext).pop();
                      onSelectPage?.call('Logout');
                    },
                  ),
                ),
                icon: const Icon(LucideIcons.logOut, size: 21),
                label: const Text('Log Out'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2454F5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.title,
    this.value,
    this.onTap,
    this.showChevron = true,
  });

  final String title;
  final String? value;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 54,
          margin: const EdgeInsets.symmetric(horizontal: 18),
          padding: const EdgeInsets.symmetric(horizontal: 0),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: theme.dividerColor.withValues(alpha: .55))),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(title, style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.w600)),
              ),
              if (value != null)
                Text(value!, style: TextStyle(color: title == 'Theme Mode' ? const Color(0xFF2454F5) : theme.colorScheme.onSurfaceVariant, fontSize: 12)),
              if (showChevron) ...[
                const SizedBox(width: 8),
                Icon(LucideIcons.chevronRight, size: 17, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: .7)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String _themeModeLabel(ThemeMode mode) => switch (mode) {
  ThemeMode.system => 'Auto',
  ThemeMode.light => 'Light Mode',
  ThemeMode.dark => 'Dark Mode',
};

class BrokerThemeModePage extends StatelessWidget {
  const BrokerThemeModePage({super.key, this.themeMode = ThemeMode.system, this.onThemeModeChanged});

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode>? onThemeModeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return ColoredBox(
      color: theme.colorScheme.surface,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        children: [
          Text('Theme Settings', style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
            'Choose your preferred display mode. You can also switch automatically based on your system settings.',
            style: TextStyle(color: muted, fontSize: 12, height: 1.45),
          ),
          const SizedBox(height: 26),
          _ThemeModeCard(
            mode: ThemeMode.system,
            title: 'Auto',
            subtitle: 'Automatically adjusts to your device settings.',
            icon: LucideIcons.smartphone,
            selected: themeMode == ThemeMode.system,
            onTap: () => onThemeModeChanged?.call(ThemeMode.system),
          ),
          const SizedBox(height: 16),
          _ThemeModeCard(
            mode: ThemeMode.light,
            title: 'Light Mode',
            subtitle: 'A clean and bright experience.',
            icon: LucideIcons.sun,
            selected: themeMode == ThemeMode.light,
            onTap: () => onThemeModeChanged?.call(ThemeMode.light),
          ),
          const SizedBox(height: 16),
          _ThemeModeCard(
            mode: ThemeMode.dark,
            title: 'Dark Mode',
            subtitle: 'A sleek and focused experience.',
            icon: LucideIcons.moon,
            selected: themeMode == ThemeMode.dark,
            onTap: () => onThemeModeChanged?.call(ThemeMode.dark),
          ),
        ],
      ),
    );
  }
}

class _ThemeModeCard extends StatelessWidget {
  const _ThemeModeCard({required this.mode, required this.title, required this.subtitle, required this.icon, required this.selected, required this.onTap});

  final ThemeMode mode;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF2454F5);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedBackground = isDark
        ? const Color(0xFF172B49)
        : const Color(0xFFEAF1FF);
    final selectedBorder = isDark
        ? const Color(0xFF38577D)
        : blue;
    final titleColor = selected && isDark
        ? const Color(0xFFF3F6FB)
        : selected
            ? const Color(0xFF172033)
            : Theme.of(context).colorScheme.onSurface;
    final subtitleColor = selected && isDark
        ? const Color(0xFFB2C0D2)
        : selected
            ? const Color(0xFF667085)
            : Theme.of(context).colorScheme.onSurfaceVariant;
    return Material(
      color: selected ? selectedBackground : Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 124,
          padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? selectedBorder : Theme.of(context).dividerColor.withValues(alpha: .65), width: selected ? 1.2 : .8),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: const Color(0xFFEAF1FF), shape: BoxShape.circle),
                child: Icon(icon, size: 22, color: blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: titleColor, fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 7),
                    Text(subtitle, style: TextStyle(color: subtitleColor, fontSize: 10, height: 1.3)),
                  ],
                ),
              ),
              _ThemePreview(mode: mode),
              const SizedBox(width: 10),
              Icon(selected ? LucideIcons.circleCheck : LucideIcons.circle, size: 18, color: selected ? blue : Theme.of(context).dividerColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemePreview extends StatelessWidget {
  const _ThemePreview({required this.mode});
  final ThemeMode mode;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 82,
      height: 104,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: mode == ThemeMode.system
            ? const Row(
                children: [
                  Expanded(child: _ThemePreviewPanel(dark: false)),
                  Expanded(child: _ThemePreviewPanel(dark: true)),
                ],
              )
            : _ThemePreviewPanel(dark: mode == ThemeMode.dark),
      ),
    );
  }
}

class _ThemePreviewPanel extends StatelessWidget {
  const _ThemePreviewPanel({required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final background = dark ? const Color(0xFF242424) : const Color(0xFFF2F2F2);
    final block = dark ? const Color(0xFF555555) : const Color(0xFFD5D5D5);
    return ColoredBox(
      color: background,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 24, height: 7, color: block),
            const SizedBox(height: 6),
            Row(children: [for (var i = 0; i < 3; i++) Expanded(child: Container(height: 14, margin: const EdgeInsets.only(right: 2), color: block))]),
            const SizedBox(height: 6),
            Container(width: 28, height: 5, color: block),
            const Spacer(),
            Container(height: 7, color: const Color(0xFF08A66A)),
            const SizedBox(height: 3),
            Container(height: 7, color: const Color(0xFFEA4056)),
          ],
        ),
      ),
    );
  }
}
