part of '../main.dart';

class BrokerTicketsPage extends StatefulWidget {
  const BrokerTicketsPage({super.key});
  @override
  State<BrokerTicketsPage> createState() => _BrokerTicketsPageState();
}

class _BrokerTicketsPageState extends State<BrokerTicketsPage> {
  String _filter = 'All';

  Future<void> _openRequestForm() async {
    final submitted = await showModalBottomSheet<bool>(
      context: context, isScrollControlled: true, useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _TicketRequestSheet(),
    );
    if (!mounted || submitted != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ticket submission is not connected yet.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final scheme = theme.colorScheme;
    final muted = scheme.onSurfaceVariant;
    final border = theme.dividerColor.withValues(alpha: dark ? .72 : .85);
    final surface = scheme.surface;
    const gold = Color(0xFFFFC533);
    const filters = ['All', 'Open', 'Closed'];

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: EdgeInsets.fromLTRB(16, 14, 16, 116 + MediaQuery.paddingOf(context).bottom),
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('HELP CENTRE', style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.45)),
              const SizedBox(height: 5),
              Text('Support tickets', style: TextStyle(color: scheme.onSurface, fontSize: 25, height: 1.1, fontWeight: FontWeight.w900, letterSpacing: -.65)),
              const SizedBox(height: 5),
              Text('Track your requests and get help from our team.', style: TextStyle(color: muted, fontSize: 11, height: 1.4)),
            ])),
            const SizedBox(width: 10),
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: scheme.primary.withValues(alpha: .10), borderRadius: BorderRadius.circular(15), border: Border.all(color: scheme.primary.withValues(alpha: .16))),
              child: Icon(LucideIcons.headset, color: scheme.primary, size: 21),
            ),
          ]),
          const SizedBox(height: 19),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: dark ? const [Color(0xFF183B5E), Color(0xFF102943)] : const [Color(0xFF194B78), Color(0xFF123354)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF6D91B3).withValues(alpha: .28)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: dark ? .16 : .07), blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 36, height: 36, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .12), borderRadius: BorderRadius.circular(11)), child: const Icon(LucideIcons.messageSquareText, color: gold, size: 18)),
                const SizedBox(width: 10),
                const Expanded(child: Text('How can we help?', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: .10), borderRadius: BorderRadius.circular(20)),
                  child: const Text('SUPPORT', style: TextStyle(color: Colors.white70, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: .8)),
                ),
              ]),
              const SizedBox(height: 9),
              const Text('Create a request for account, trading, payments or technical assistance.', style: TextStyle(color: Colors.white70, fontSize: 10.5, height: 1.5)),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity, height: 45,
                child: FilledButton.icon(
                  onPressed: _openRequestForm,
                  icon: const Icon(LucideIcons.plus, size: 17),
                  label: const Text('Create a ticket', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                  style: FilledButton.styleFrom(backgroundColor: gold, foregroundColor: const Color(0xFF17243A), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 23),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('YOUR REQUESTS', style: TextStyle(color: scheme.onSurface, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: .55)),
              const SizedBox(height: 3),
              Text('View and filter your support history', style: TextStyle(color: muted, fontSize: 10)),
            ])),
            Icon(LucideIcons.listFilter, color: muted, size: 17),
          ]),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
            child: Row(children: [
              for (final filter in filters)
                Expanded(child: Semantics(
                  button: true, selected: _filter == filter, label: '$filter tickets',
                  child: InkWell(
                    onTap: () => setState(() => _filter = filter),
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 170), height: 38,
                      decoration: BoxDecoration(
                        color: _filter == filter ? scheme.primary.withValues(alpha: .12) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: _filter == filter ? Border.all(color: scheme.primary.withValues(alpha: .20)) : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(filter, style: TextStyle(color: _filter == filter ? scheme.primary : muted, fontSize: 10, fontWeight: FontWeight.w900)),
                    ),
                  ),
                )),
            ]),
          ),
          const SizedBox(height: 13),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 25, 20, 22),
            decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(19), border: Border.all(color: border)),
            child: Column(children: [
              Container(
                width: 58, height: 58,
                decoration: BoxDecoration(color: scheme.primary.withValues(alpha: .09), borderRadius: BorderRadius.circular(18)),
                child: Icon(LucideIcons.inbox, color: scheme.primary, size: 26),
              ),
              const SizedBox(height: 14),
              Text(_filter == 'All' ? 'No support tickets yet' : 'No $_filter tickets', textAlign: TextAlign.center,
                style: TextStyle(color: scheme.onSurface, fontSize: 14, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 270),
                child: Text(
                  _filter == 'All' ? 'Your support requests will appear here once they are available.' : 'There are no ${_filter.toLowerCase()} requests to display.',
                  textAlign: TextAlign.center, style: TextStyle(color: muted, fontSize: 10.5, height: 1.55),
                ),
              ),
              const SizedBox(height: 17),
              OutlinedButton.icon(
                onPressed: _openRequestForm,
                icon: const Icon(LucideIcons.messageCirclePlus, size: 16),
                label: const Text('Contact support', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: scheme.primary, side: BorderSide(color: scheme.primary.withValues(alpha: .35)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(LucideIcons.info, color: muted, size: 13),
            const SizedBox(width: 7),
            Expanded(child: Text('Ticket creation is currently a UI preview; requests are not sent to the support system.', style: TextStyle(color: muted, fontSize: 9, height: 1.45))),
          ]),
        ],
      ),
    );
  }
}

class _TicketRequestSheet extends StatefulWidget {
  const _TicketRequestSheet();

  @override
  State<_TicketRequestSheet> createState() => _TicketRequestSheetState();
}

class _TicketRequestSheetState extends State<_TicketRequestSheet> {
  final _formKey = GlobalKey<FormState>();
  final _detailsController = TextEditingController();
  String _department = 'Trading & MT5';
  PlatformFile? _attachment;
  bool _pickingAttachment = false;

  static const _departments = <(String, IconData, Color)>[
    ('Trading & MT5', Icons.trending_up, Color(0xFFFFA400)),
    ('Deposit & Payout', Icons.credit_card_outlined, Color(0xFF00B98B)),
    ('Account & KYC', Icons.verified_user_outlined, Color(0xFFB43DFF)),
    ('Partnership / IB', Icons.people_alt_outlined, Color(0xFFFF9D00)),
    ('Technical Issue', Icons.build_outlined, Color(0xFF00BCD4)),
    ('Others', Icons.help_outline, Color(0xFFFF4565)),
  ];

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String label, ThemeData theme) => InputDecoration(
        hintText: label,
        hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: .75), fontSize: 12, fontWeight: FontWeight.w600),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.dividerColor)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.dividerColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.colorScheme.primary)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
      );

  Future<void> _pickAttachment() async {
    setState(() => _pickingAttachment = true);
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['png', 'jpg', 'jpeg', 'pdf', 'doc', 'docx'],
      );
      if (!mounted || files.isEmpty) return;
      final file = files.first;
      final fileSize = await file.length();
      if (!mounted) return;
      if (fileSize == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not verify the attachment size.')));
        return;
      }
      if (fileSize > 5 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Each attachment must be 5 MB or smaller.')));
        return;
      }
      setState(() => _attachment = file);
    } on MissingPluginException catch (error, stackTrace) {
      debugPrint('Ticket file picker plugin is unavailable: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File picker is not loaded. Stop and restart the app.')),
        );
      }
    } catch (error, stackTrace) {
      debugPrint('Ticket file picker failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open the file picker: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _pickingAttachment = false);
    }
  }

  Widget _fieldLabel(String text, {bool required = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(color: Color(0xFF4C5D78), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: .35),
            children: [TextSpan(text: text), if (required) const TextSpan(text: ' *', style: TextStyle(color: Color(0xFFFF4565)))],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 520;
    final surface = theme.colorScheme.surface;
    final muted = theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Material(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .94),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 13),
                child: Column(
                  children: [
                    Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: theme.dividerColor, borderRadius: BorderRadius.circular(5)))),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(child: Text('Create support ticket', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface))),
                        IconButton(tooltip: 'Close', onPressed: () => Navigator.of(context).pop(), icon: Icon(Icons.close, size: 20, color: muted)),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: theme.dividerColor),
              Flexible(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                    children: [
                      _fieldLabel('TARGET DEPARTMENT', required: true),
                      LayoutBuilder(builder: (context, constraints) {
                        final columns = constraints.maxWidth < 450 ? 2 : 3;
                        final itemWidth = (constraints.maxWidth - (columns - 1) * 8) / columns;
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final item in _departments)
                              SizedBox(
                                width: itemWidth,
                                height: 42,
                                child: _TicketDepartmentChip(
                                  label: item.$1,
                                  icon: item.$2,
                                  accent: item.$3,
                                  selected: _department == item.$1,
                                  onTap: () => setState(() => _department = item.$1),
                                ),
                              ),
                          ],
                        );
                      }),
                      const SizedBox(height: 17),
                      _fieldLabel('ISSUE DESCRIPTION', required: true),
                      TextFormField(
                        controller: _detailsController,
                        decoration: _decoration('Please describe the issue in detail, including affected trading accounts, order tickets, or error messages...', theme),
                        minLines: compact ? 4 : 3,
                        maxLines: 6,
                        textCapitalization: TextCapitalization.sentences,
                        validator: (value) => (value == null || value.trim().isEmpty) ? 'Please describe the issue' : null,
                      ),
                      const SizedBox(height: 18),
                      _fieldLabel('SUPPORTING DOCUMENTS / SCREENSHOTS (OPTIONAL)'),
                      InkWell(
                        onTap: _pickingAttachment ? null : _pickAttachment,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 88),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: .32),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: .28), style: BorderStyle.solid),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(_attachment == null ? Icons.attach_file : Icons.image_outlined, color: theme.colorScheme.primary, size: 22),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_pickingAttachment ? 'Opening files…' : (_attachment?.name ?? 'Tap here to attach a file'), style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 3),
                                    Text('PNG, JPG, PDF, DOC, DOCX up to 5 MB', style: theme.textTheme.labelSmall?.copyWith(color: muted)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(height: 1, color: theme.dividerColor),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                    const SizedBox(width: 10),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFFD8A82E), foregroundColor: Colors.white),
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) return;
                        Navigator.of(context).pop(true);
                      },
                      icon: const Icon(Icons.send_outlined, size: 16),
                      label: const Text('SUBMIT TICKET'),
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

class _TicketDepartmentChip extends StatelessWidget {
  const _TicketDepartmentChip({required this.label, required this.icon, required this.accent, required this.selected, required this.onTap});

  final String label;
  final IconData icon;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected ? accent.withValues(alpha: .12) : theme.colorScheme.surfaceContainerHighest.withValues(alpha: .28),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? accent : theme.dividerColor, width: selected ? 1.3 : 1),
          ),
          child: Row(
            children: [
              Icon(icon, color: accent, size: 16),
              const SizedBox(width: 7),
              Expanded(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 11, fontWeight: FontWeight.w700))),
            ],
          ),
        ),
      ),
    );
  }
}
