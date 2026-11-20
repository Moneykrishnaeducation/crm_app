part of '../main.dart';

class BrokerTicketsPage extends StatefulWidget {
  const BrokerTicketsPage({super.key});
  @override
  State<BrokerTicketsPage> createState() => _BrokerTicketsPageState();
}

class _BrokerTicketsPageState extends State<BrokerTicketsPage> {
  String _filter = 'All';

  static const List<Map<String, String>> _mockTickets = [
    {'id': 'TKT-2026-1048', 'subject': 'Deposit not reflected in trading account', 'department': 'Deposit & Payout', 'status': 'Open', 'priority': 'High', 'updated': 'Today, 10:42 AM'},
    {'id': 'TKT-2026-1036', 'subject': 'Unable to access MT5 trading platform', 'department': 'Trading & MT5', 'status': 'In-progress', 'priority': 'Medium', 'updated': 'Today, 09:15 AM'},
    {'id': 'TKT-2026-1019', 'subject': 'Request to update profile information', 'department': 'Account & KYC', 'status': 'In-progress', 'priority': 'Low', 'updated': 'Yesterday, 04:30 PM'},
    {'id': 'TKT-2026-0987', 'subject': 'Withdrawal status clarification', 'department': 'Deposit & Payout', 'status': 'Closed', 'priority': 'Medium', 'updated': '18 Nov 2026'},
    {'id': 'TKT-2026-0962', 'subject': 'Partner commission statement query', 'department': 'Partnership / IB', 'status': 'Open', 'priority': 'Low', 'updated': '17 Nov 2026'},
  ];

  List<Map<String, String>> get _visibleTickets => _filter == 'All'
      ? _mockTickets
      : _mockTickets.where((ticket) => ticket['status'] == _filter).toList();

  void _openTicketDetails(Map<String, String> ticket) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _MockTicketDetailsPage(ticket: ticket),
    ));
  }

  Widget _ticketCard(Map<String, String> ticket, ThemeData theme) {
    final scheme = theme.colorScheme;
    final status = ticket['status']!;
    final statusColor = status == 'Open' ? const Color(0xFFE39A24)
        : status == 'In-progress' ? const Color(0xFF3989D6) : const Color(0xFF249B72);
    final priority = ticket['priority']!;
    final priorityColor = priority == 'High' ? const Color(0xFFE15B5B)
        : priority == 'Medium' ? const Color(0xFFE39A24) : scheme.onSurfaceVariant;
    return InkWell(
      onTap: () => _openTicketDetails(ticket),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withValues(alpha: .8))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(ticket['id']!, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: .45))),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(color: statusColor.withValues(alpha: .12), borderRadius: BorderRadius.circular(20)),
              child: Text(status, style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.w900))),
          ]),
          const SizedBox(height: 9),
          Text(ticket['subject']!, style: TextStyle(color: scheme.onSurface, fontSize: 12, fontWeight: FontWeight.w800, height: 1.35)),
          const SizedBox(height: 9),
          Row(children: [
            Icon(LucideIcons.folder, size: 12, color: scheme.onSurfaceVariant),
            const SizedBox(width: 5),
            Expanded(child: Text(ticket['department']!, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 9))),
            Container(width: 5, height: 5, decoration: BoxDecoration(color: priorityColor, shape: BoxShape.circle)),
            const SizedBox(width: 5),
            Text('${priority} priority', style: TextStyle(color: priorityColor, fontSize: 9, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 11),
          Divider(height: 1, color: theme.dividerColor.withValues(alpha: .65)),
          const SizedBox(height: 9),
          Row(children: [
            Icon(LucideIcons.clock3, size: 12, color: scheme.onSurfaceVariant),
            const SizedBox(width: 5),
            Expanded(child: Text('Updated ${ticket['updated']}', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 9))),
            Icon(LucideIcons.chevronRight, size: 16, color: scheme.onSurfaceVariant),
          ]),
        ]),
      ),
    );
  }

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
    const filters = ['All', 'Open', 'In-progress', 'Closed'];

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
          const SizedBox(height: 12),
          Row(children: [
            for (final item in [
              ('Open', _mockTickets.where((t) => t['status'] == 'Open').length, const Color(0xFFE39A24)),
              ('In progress', _mockTickets.where((t) => t['status'] == 'In-progress').length, const Color(0xFF3989D6)),
              ('Closed', _mockTickets.where((t) => t['status'] == 'Closed').length, const Color(0xFF249B72)),
            ])
              Expanded(child: Container(
                margin: const EdgeInsets.only(right: 7), padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
                decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(13), border: Border.all(color: border)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${item.$2}', style: TextStyle(color: item.$3, fontSize: 17, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 2),
                  Text(item.$1, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: muted, fontSize: 8, fontWeight: FontWeight.w700)),
                ]),
              )),
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
          if (_visibleTickets.isEmpty)
            Container(padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)),
              child: Center(child: Text('No tickets in this status.', style: TextStyle(color: muted, fontSize: 11))))
          else
            for (final ticket in _visibleTickets) _ticketCard(ticket, theme),
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


class _MockTicketDetailsPage extends StatefulWidget {
  final Map<String, String> ticket;
  const _MockTicketDetailsPage({required this.ticket});

  @override
  State<_MockTicketDetailsPage> createState() => _MockTicketDetailsPageState();
}

class _MockTicketDetailsPageState extends State<_MockTicketDetailsPage> {
  final TextEditingController _replyController = TextEditingController();
  final List<Map<String, String>> _messages = [];

  bool get _canReply => widget.ticket['status'] == 'In-progress';

  @override
  void initState() {
    super.initState();
    if (widget.ticket['id'] == 'TKT-2026-1036') {
      _messages.addAll([
        {'from': 'You', 'time': 'Today, 08:42 AM', 'body': 'I am unable to sign in to my MT5 account. The platform keeps showing an authorization error.'},
        {'from': 'Support team', 'time': 'Today, 09:02 AM', 'body': 'Thank you for contacting us. Please confirm the MT5 login ID and the server name displayed in your account details. Do not share your password.'},
        {'from': 'You', 'time': 'Today, 09:15 AM', 'body': 'My login ID is 8201456. The server shown is VTIndex-Live.'},
      ]);
    } else if (widget.ticket['id'] == 'TKT-2026-1019') {
      _messages.addAll([
        {'from': 'You', 'time': 'Yesterday, 03:55 PM', 'body': 'I need to correct the phone number registered on my profile.'},
        {'from': 'Support team', 'time': 'Yesterday, 04:12 PM', 'body': 'We have received your request. Our verification team is reviewing the account details. We will update you here if any additional information is required.'},
      ]);
    } else {
      _messages.add({'from': 'You', 'time': widget.ticket['updated'] ?? 'Recently', 'body': 'I am following up on this request. Please let me know if you need any further information.'});
    }
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _sendReply() {
    final body = _replyController.text.trim();
    if (body.isEmpty || !_canReply) return;
    setState(() {
      _messages.add({'from': 'You', 'time': 'Just now', 'body': body});
      _replyController.clear();
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = scheme.onSurfaceVariant;
    final ticket = widget.ticket;
    final status = ticket['status']!;
    final statusColor = status == 'Open' ? const Color(0xFFE39A24)
        : status == 'In-progress' ? const Color(0xFF3989D6) : const Color(0xFF249B72);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Ticket details', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(children: [
        Expanded(child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(18),
                border: Border.all(color: theme.dividerColor.withValues(alpha: .8))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(ticket['id']!, style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: .6))),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(color: statusColor.withValues(alpha: .12), borderRadius: BorderRadius.circular(20)),
                    child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w900))),
                ]),
                const SizedBox(height: 12),
                Text(ticket['subject']!, style: TextStyle(color: scheme.onSurface, fontSize: 17, fontWeight: FontWeight.w900, height: 1.3)),
                const SizedBox(height: 13),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  _detailChip(LucideIcons.folder, ticket['department'] ?? '', theme),
                  _detailChip(LucideIcons.flag, '${ticket['priority']} priority', theme),
                ]),
                const SizedBox(height: 13),
                Divider(height: 1, color: theme.dividerColor.withValues(alpha: .7)),
                const SizedBox(height: 10),
                Row(children: [
                  Icon(LucideIcons.clock3, size: 13, color: muted),
                  const SizedBox(width: 6),
                  Expanded(child: Text('Last updated ${ticket['updated']}', style: TextStyle(color: muted, fontSize: 10))),
                ]),
              ]),
            ),
            const SizedBox(height: 22),
            Row(children: [
              Expanded(child: Text('CONVERSATION', style: TextStyle(color: scheme.onSurface, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: .7))),
              Text('${_messages.length} messages', style: TextStyle(color: muted, fontSize: 10)),
            ]),
            const SizedBox(height: 13),
            for (final message in _messages) _messageBubble(message, theme),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: scheme.primary.withValues(alpha: .07), borderRadius: BorderRadius.circular(13)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(LucideIcons.info, size: 14, color: scheme.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(
                  _canReply ? 'You can reply to this in-progress ticket. Replies are added to this local preview only.'
                    : 'Replies are available only while a ticket is in progress. This ticket is read-only.',
                  style: TextStyle(color: muted, fontSize: 10, height: 1.45),
                )),
              ]),
            ),
          ],
        )),
        SafeArea(top: false, child: Container(
          padding: EdgeInsets.fromLTRB(14, 10, 14, 10 + MediaQuery.viewInsetsOf(context).bottom),
          decoration: BoxDecoration(color: scheme.surface, border: Border(top: BorderSide(color: theme.dividerColor.withValues(alpha: .7)))),
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(child: TextField(
              controller: _replyController, enabled: _canReply, minLines: 1, maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: _canReply ? 'Write a reply...' : 'Replies are disabled',
                filled: true, fillColor: theme.scaffoldBackgroundColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            )),
            const SizedBox(width: 9),
            SizedBox(width: 46, height: 46, child: FilledButton(
              onPressed: _canReply ? _sendReply : null,
              style: FilledButton.styleFrom(padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: const Icon(LucideIcons.send, size: 17),
            )),
          ]),
        )),
      ]),
    );
  }

  Widget _detailChip(IconData icon, String label, ThemeData theme) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
    decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: .55), borderRadius: BorderRadius.circular(9)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: theme.colorScheme.onSurfaceVariant),
      const SizedBox(width: 5),
      Text(label, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 9, fontWeight: FontWeight.w700)),
    ]),
  );

  Widget _messageBubble(Map<String, String> message, ThemeData theme) {
    final isUser = message['from'] == 'You';
    final scheme = theme.colorScheme;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * .84),
        child: Container(
          margin: const EdgeInsets.only(bottom: 11), padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isUser ? scheme.primary.withValues(alpha: .11) : scheme.surface,
            borderRadius: BorderRadius.only(topLeft: const Radius.circular(15), topRight: const Radius.circular(15),
              bottomLeft: Radius.circular(isUser ? 15 : 4), bottomRight: Radius.circular(isUser ? 4 : 15)),
            border: Border.all(color: theme.dividerColor.withValues(alpha: .55)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              Text(message['from']!, style: TextStyle(color: isUser ? scheme.primary : scheme.onSurface, fontSize: 10, fontWeight: FontWeight.w900)),
              const SizedBox(width: 8),
              Text(message['time']!, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 8)),
            ]),
            const SizedBox(height: 7),
            Text(message['body']!, style: TextStyle(color: scheme.onSurface, fontSize: 11, height: 1.5)),
          ]),
        ),
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
