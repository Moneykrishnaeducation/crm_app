part of '../main.dart';

const _mt5AndroidApkUrl =
    'https://download.terminal.free/cdn/web/metaquotes.software.corp/mt5/metatrader5.apk?utm_source=chatgpt.com&utm_campaign=install.metaquotes';
const _vtindexPlatformUrl = 'https://client.vtindex.com/platform';

class BrokerDownloadCenterPage extends StatelessWidget {
  const BrokerDownloadCenterPage({super.key});

  Future<void> _openLink(BuildContext context, String url) async {
    try {
      final opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open this link. Please try again.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open this link. Check your connection and try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final muted = scheme.onSurfaceVariant;
    final border = theme.dividerColor;
    final gold = const Color(0xFFFFC52E);

    return SafeArea(
      top: false,
      bottom: false,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 116),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('VTINDEX • RESOURCES', style: TextStyle(
                            color: muted, fontSize: 9, letterSpacing: 1.35,
                            fontWeight: FontWeight.w800,
                          )),
                          const SizedBox(height: 6),
                          Text('Download Center', style: TextStyle(
                            color: scheme.onSurface, fontSize: 25,
                            height: 1.12, fontWeight: FontWeight.w800,
                            letterSpacing: -.55,
                          )),
                          const SizedBox(height: 5),
                          Text('Your trading platform, one tap away.',
                            style: TextStyle(color: muted, fontSize: 11, height: 1.45)),
                        ],
                      ),
                    ),
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: gold.withValues(alpha: dark ? .14 : .18),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(LucideIcons.download, color: Color(0xFFD49A00), size: 21),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Primary destination: VTIndex client platform.
                Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: dark
                          ? const [Color(0xFF101F35), Color(0xFF0A1426)]
                          : const [Color(0xFFFFFFFF), Color(0xFFF2F6FC)],
                    ),
                    border: Border.all(color: dark ? const Color(0xFF29466A) : const Color(0xFFDCE5F1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: dark ? .18 : .05),
                        blurRadius: 22, offset: const Offset(0, 9),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -34, top: -45,
                        child: Container(
                          width: 150, height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: gold.withValues(alpha: .12), width: 22),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(19),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48, height: 48,
                                  decoration: BoxDecoration(
                                    color: gold.withValues(alpha: .16),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: const Icon(LucideIcons.chartNoAxesCombined,
                                    color: Color(0xFFFFC52E), size: 25),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('VTIndex Platform', style: TextStyle(
                                        color: scheme.onSurface, fontSize: 17,
                                        fontWeight: FontWeight.w800, letterSpacing: -.25,
                                      )),
                                      const SizedBox(height: 3),
                                      Text('Client portal & trading access',
                                        style: TextStyle(color: muted, fontSize: 10)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: gold.withValues(alpha: dark ? .16 : .20),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text('RECOMMENDED', style: TextStyle(
                                    color: Color(0xFF0A9B68), fontSize: 7,
                                    fontWeight: FontWeight.w900, letterSpacing: .45,
                                  )),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Text('Manage your trading journey', style: TextStyle(
                              color: scheme.onSurface, fontSize: 19,
                              fontWeight: FontWeight.w800, height: 1.2,
                            )),
                            const SizedBox(height: 6),
                            Text(
                              'Open the VTIndex client platform to access your account and available platform resources.',
                              style: TextStyle(color: muted, fontSize: 10, height: 1.55),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () => _openLink(context, _vtindexPlatformUrl),
                                style: FilledButton.styleFrom(
                                  backgroundColor: gold,
                                  foregroundColor: const Color(0xFF17243A),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(LucideIcons.externalLink, size: 17),
                                    SizedBox(width: 9),
                                    Text('Open VTIndex Platform', style: TextStyle(
                                      fontSize: 12, fontWeight: FontWeight.w800,
                                    )),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TRADING APPLICATION', style: TextStyle(
                          color: muted, fontSize: 9, letterSpacing: 1.1,
                          fontWeight: FontWeight.w800,
                        )),
                        const SizedBox(height: 5),
                        Text('MetaTrader 5', style: TextStyle(
                          color: scheme.onSurface, fontSize: 17, fontWeight: FontWeight.w800,
                        )),
                      ],
                    )),
                    Text('ANDROID', style: TextStyle(
                      color: muted, fontSize: 8, letterSpacing: .8, fontWeight: FontWeight.w800,
                    )),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(19),
                    border: Border.all(color: border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46, height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3478F6).withValues(alpha: dark ? .18 : .10),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(LucideIcons.smartphone, color: Color(0xFF3E9BFF), size: 23),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('MT5 for Android', style: TextStyle(
                              color: scheme.onSurface, fontSize: 12, fontWeight: FontWeight.w800,
                            )),
                            const SizedBox(height: 4),
                            Text('APK installer • Android devices',
                              style: TextStyle(color: muted, fontSize: 9)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.tonalIcon(
                        onPressed: () => _openLink(context, _mt5AndroidApkUrl),
                        icon: const Icon(LucideIcons.download, size: 14),
                        label: const Text('Get APK'),
                        style: FilledButton.styleFrom(
                          foregroundColor: dark ? const Color(0xFFB8D2FF) : const Color(0xFF245DB5),
                          backgroundColor: dark ? const Color(0xFF203B60) : const Color(0xFFEAF1FC),
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
                          textStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 9),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(LucideIcons.info, size: 14, color: muted),
                    const SizedBox(width: 7),
                    Expanded(child: Text(
                      'APK files install outside Google Play. Verify the download source before installing and never share your MT5 password.',
                      style: TextStyle(color: muted, fontSize: 9, height: 1.45),
                    )),
                  ],
                ),

                const SizedBox(height: 22),
                Text('GET STARTED', style: TextStyle(
                  color: muted, fontSize: 9, letterSpacing: 1.1, fontWeight: FontWeight.w800,
                )),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 5, 14, 5),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: border),
                  ),
                  child: const Column(
                    children: [
                      _DownloadCenterStep(number: '01', title: 'Open VTIndex Platform',
                        detail: 'Sign in to the client portal using your registered credentials.'),
                      _DownloadCenterStep(number: '02', title: 'Choose your platform',
                        detail: 'Review the platform and device options available in the portal.'),
                      _DownloadCenterStep(number: '03', title: 'Connect your MT5 account',
                        detail: 'Use your trading login and the correct VTIndex server in MetaTrader 5.'),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: gold.withValues(alpha: dark ? .09 : .12),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: gold.withValues(alpha: .28)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(LucideIcons.shieldCheck, color: Color(0xFFD49A00), size: 18),
                      const SizedBox(width: 10),
                      Expanded(child: Text(
                        'Security reminder: download software only from trusted sources. VTIndex will never ask you to disclose your account password or one-time security codes.',
                        style: TextStyle(color: scheme.onSurface, fontSize: 9, height: 1.5),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DownloadCenterStep extends StatelessWidget {
  const _DownloadCenterStep({
    required this.number,
    required this.title,
    required this.detail,
  });

  final String number;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 31, height: 31,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFFC52E).withValues(alpha: .17),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(number, style: const TextStyle(
              color: Color(0xFFB88716), fontSize: 9, fontWeight: FontWeight.w900,
            )),
          ),
          const SizedBox(width: 11),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(
                color: scheme.onSurface, fontSize: 10, fontWeight: FontWeight.w800,
              )),
              const SizedBox(height: 3),
              Text(detail, style: TextStyle(color: muted, fontSize: 9, height: 1.45)),
            ],
          )),
        ],
      ),
    );
  }
}
