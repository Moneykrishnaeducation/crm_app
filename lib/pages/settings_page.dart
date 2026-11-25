part of '../main.dart';

class BrokerSettingsPage extends StatefulWidget {
  const BrokerSettingsPage({
    super.key,
    this.themeMode = ThemeMode.system,
    this.onThemeModeChanged,
    this.onSelectPage,
    this.biometricSignIn,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode>? onThemeModeChanged;
  final ValueChanged<String>? onSelectPage;
  final BiometricSignIn? biometricSignIn;

  @override
  State<BrokerSettingsPage> createState() => _BrokerSettingsPageState();
}

class _BrokerSettingsPageState extends State<BrokerSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return ColoredBox(
      color: colors.surface,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(2, 0, 2, 22),
                        child: Row(children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: .10),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(LucideIcons.settings2, color: colors.primary, size: 23),
                          ),
                          const SizedBox(width: 13),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Personalize your experience',
                                style: TextStyle(
                                  color: colors.onSurface,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Manage appearance, privacy, and app details.',
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          )),
                        ]),
                      ),
                      _SettingsSection(
                        title: 'PREFERENCES',
                        children: [
                          _SettingsTile(
                            icon: LucideIcons.sun,
                            title: 'Theme Mode',
                            subtitle: 'Choose light, dark, or device default.',
                            value: _themeModeLabel(widget.themeMode),
                            onTap: () => widget.onSelectPage?.call('Theme Mode'),
                          ),
                          const _SettingsDivider(),
                          _SettingsTile(
                            icon: LucideIcons.shieldCheck,
                            title: 'Privacy Policy',
                            subtitle: 'Review how your information is handled.',
                            onTap: () => widget.onSelectPage?.call('Privacy Policy'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      _SettingsSection(
                        title: 'ABOUT',
                        children: const [
                          _SettingsTile(
                            icon: LucideIcons.info,
                            title: 'Version',
                            value: 'V 2.20.0 (g)',
                            showChevron: false,
                          ),
                          _SettingsDivider(),
                          _SettingsTile(
                            icon: LucideIcons.hash,
                            title: 'Sub-version',
                            value: '1',
                            showChevron: false,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(18, 10, 18, 14),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
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
                                widget.onSelectPage?.call('Logout');
                            },
                          ),
                        ),
                        icon: const Icon(LucideIcons.logOut, size: 19),
                        label: const Text('Log Out'),
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.error,
                          foregroundColor: colors.onError,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'You can sign back in at any time.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.onSurfaceVariant, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 3, bottom: 9),
          child: Text(
            title,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: .65)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.value,
    this.onTap,
    this.showChevron = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? value;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: .09),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 19, color: colors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 10,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 96,
                child: Row(
                  children: [
                    if (value != null) ...[
                      Expanded(
                        child: Text(
                          value!,
                          textAlign: TextAlign.end,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: onTap == null ? colors.onSurfaceVariant : colors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (showChevron) const SizedBox(width: 7),
                    ] else
                      const Spacer(),
                    if (showChevron)
                      Icon(
                        LucideIcons.chevronRight,
                        size: 16,
                        color: colors.onSurfaceVariant.withValues(alpha: .7),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 66),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Theme.of(context).dividerColor.withValues(alpha: .55),
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
