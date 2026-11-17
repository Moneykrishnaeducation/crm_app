part of '../main.dart';

const _mt5AndroidApkUrl =
    'https://download.terminal.free/cdn/web/metaquotes.software.corp/mt5/metatrader5.apk?utm_source=chatgpt.com&utm_campaign=install.metaquotes';
const _vtindexPlatformUrl = 'https://client.vtindex.com/platform';

class BrokerDownloadCenterPage extends StatelessWidget {
  const BrokerDownloadCenterPage({super.key});

  Future<void> _openDownload(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open the download link. Please try again.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open the download link. Please check your connection.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final muted = colors.onSurfaceVariant;
    final panel = theme.cardColor;
    final border = theme.dividerColor;

    return SafeArea(
      top: false,
      bottom: false,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('DOWNLOAD CENTER', style: TextStyle(
                  color: muted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.25,
                )),
                const SizedBox(height: 6),
                Text('Trading platforms', style: TextStyle(
                  color: colors.onSurface, fontSize: 25, height: 1.15, fontWeight: FontWeight.w800,
                )),
                const SizedBox(height: 7),
                Text(
                  'Get the official MetaTrader 5 app and access your VTIndex trading account on the go.',
                  style: TextStyle(color: muted, fontSize: 12, height: 1.5),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: dark
                          ? const [Color(0xFF1A2D49), Color(0xFF111E32)]
                          : const [Color(0xFFFFFFFF), Color(0xFFF0F4FA)],
                    ),
                    border: Border.all(color: dark ? const Color(0xFF344B6A) : border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: dark ? .16 : .045),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B4F91).withValues(alpha: .16),
                              borderRadius: BorderRadius.circular(17),
                            ),
                            child: const Icon(LucideIcons.chartNoAxesCombined, color: Color(0xFF3E9BFF), size: 31),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Flexible(child: Text('MetaTrader 5', style: TextStyle(
                                    color: colors.onSurface, fontSize: 18, fontWeight: FontWeight.w800,
                                  ))),
                                  const SizedBox(width: 7),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF079B62).withValues(alpha: .13),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text('OFFICIAL', style: TextStyle(
                                      color: Color(0xFF079B62), fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: .5,
                                    )),
                                  ),
                                ]),
                                const SizedBox(height: 4),
                                Text('Android mobile application', style: TextStyle(color: muted, fontSize: 11)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _DownloadMetaChip(icon: LucideIcons.smartphone, label: 'Android'),
                          _DownloadMetaChip(icon: LucideIcons.package, label: 'APK installer'),
                          _DownloadMetaChip(icon: LucideIcons.shieldCheck, label: 'VTIndex platform'),
                        ],
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => _openDownload(context, _mt5AndroidApkUrl),
                          icon: const Icon(LucideIcons.download, size: 18),
                          label: const Text('Download MT5 for Android'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFFC52E),
                            foregroundColor: const Color(0xFF14243B),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 9),
                      Center(
                        child: Text('APK download • Opens in your browser', style: TextStyle(color: muted, fontSize: 9)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text('INSTALLATION GUIDE', style: TextStyle(
                  color: muted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.1,
                )),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: panel,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: border),
                  ),
                  child: Column(
                    children: const [
                      _DownloadStep(number: '01', title: 'Download the APK', detail: 'Tap the download button and wait for the APK file to finish downloading.'),
                      _DownloadStep(number: '02', title: 'Allow installation if prompted', detail: 'Android may ask you to allow your browser to install apps. Only proceed if you trust the source.'),
                      _DownloadStep(number: '03', title: 'Install MetaTrader 5', detail: 'Open the downloaded APK and follow the Android installation prompts.'),
                      _DownloadStep(number: '04', title: 'Sign in to your VTIndex account', detail: 'Open MT5, search for your broker server and enter your trading login details.'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8A82E).withValues(alpha: dark ? .10 : .12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD8A82E).withValues(alpha: .35)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(LucideIcons.info, color: Color(0xFFD8A82E), size: 19),
                      const SizedBox(width: 10),
                      Expanded(child: Text(
                        'Security note: Android APK files are installed outside Google Play. Verify the publisher and download source before installing. Never share your MT5 password with anyone.',
                        style: TextStyle(color: colors.onSurface, fontSize: 10, height: 1.5),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => _openDownload(context, _vtindexPlatformUrl),
                  icon: const Icon(LucideIcons.externalLink, size: 16),
                  label: const Text('Open VTIndex Platform'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.onSurface,
                    side: BorderSide(color: border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 10),
                Center(child: Text(
                  'Access your trading platform through VTIndex.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: muted, fontSize: 9),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DownloadMetaChip extends StatelessWidget {
  const _DownloadMetaChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: .75),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: colors.primary),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(color: colors.onSurface, fontSize: 9, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _DownloadStep extends StatelessWidget {
  const _DownloadStep({required this.number, required this.title, required this.detail});
  final String number;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final muted = colors.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFD8A82E).withValues(alpha: .15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(number, style: const TextStyle(color: Color(0xFFB88716), fontSize: 10, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(width: 11),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(color: colors.onSurface, fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 3),
          Text(detail, style: TextStyle(color: muted, fontSize: 9, height: 1.45)),
        ])),
      ]),
    );
  }
}
