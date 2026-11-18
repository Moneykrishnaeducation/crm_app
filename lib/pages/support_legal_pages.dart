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
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
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
    final muted = theme.colorScheme.onSurfaceVariant;
    final filters = const ['All', 'Open', 'Closed'];
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
      children: [
        Text('SUPPORT', style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        const SizedBox(height: 5),
        Text('Tickets', style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w800)),
        const SizedBox(height: 5),
        Text('Get help with your account or trading services.', style: theme.textTheme.bodySmall?.copyWith(color: muted)),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _openRequestForm,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Create ticket'),
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 13)),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: Text('Your requests', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w800))),
            Icon(Icons.support_agent, color: theme.colorScheme.primary, size: 19),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            for (final filter in filters)
              ChoiceChip(
                label: Text(filter),
                selected: _filter == filter,
                onSelected: (_) => setState(() => _filter = filter),
                showCheckmark: false,
              ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: .09), shape: BoxShape.circle),
                child: Icon(Icons.inbox_outlined, color: theme.colorScheme.primary, size: 25),
              ),
              const SizedBox(height: 13),
              Text(_filter == 'All' ? 'No support tickets yet' : 'No $_filter tickets', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(
                _filter == 'All' ? 'When you contact support, your requests will appear here.' : 'There are no ${_filter.toLowerCase()} requests to show.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(color: muted, height: 1.45),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _openRequestForm,
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Request support'),
              ),
            ],
          ),
        ),
      ],
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
