part of '../main.dart';

class BrokerTicketsPage extends StatefulWidget {
  const BrokerTicketsPage({super.key});
  @override
  State<BrokerTicketsPage> createState() => _BrokerTicketsPageState();
}

class _BrokerTicketsPageState extends State<BrokerTicketsPage> {
  String _filter = 'All';
  List<Map<String, dynamic>> _tickets = [];
  bool _loading = true;
  String? _loadError;

  @override
  void initState() { super.initState(); _loadTickets(); }

  Future<void> _loadTickets() async {
    if (mounted) setState(() { _loading = true; _loadError = null; });
    try {
      final rows = await AuthApi.instance.getSupportTickets();
      if (!mounted) return;
      setState(() { _tickets = rows; _loading = false; });
    } catch (error) {
      if (!mounted) return;
      setState(() { _loadError = error.toString(); _loading = false; });
    }
  }

  String _ticketStatus(Map<String, dynamic> ticket) => (ticket['status'] ?? 'open').toString().toLowerCase();
  String _ticketSubject(Map<String, dynamic> ticket) => (ticket['subject'] ?? 'Support request').toString().replaceFirst(RegExp(r'^\\[[^\\]]+\\]\\s*'), '');
  String _ticketDepartment(Map<String, dynamic> ticket) {
    final match = RegExp(r'^\\[([^\\]]+)\\]').firstMatch((ticket['subject'] ?? '').toString());
    return match?.group(1) ?? 'General Support';
  }
  List<Map<String, dynamic>> get _visibleTickets => _filter == 'All' ? _tickets : _tickets.where((t) => _ticketStatus(t) == _filter.toLowerCase()).toList();

  void _openTicketDetails(Map<String, dynamic> ticket) async {
    final changed = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => _LiveTicketDetailsPage(ticket: ticket)));
    if (changed == true && mounted) _loadTickets();
  }

  Future<void> _openRequestForm() async {
    final created = await showModalBottomSheet<bool>(context: context, isScrollControlled: true, useSafeArea: true, backgroundColor: Colors.transparent, builder: (_) => const _LiveTicketRequestSheet());
    if (created == true && mounted) {
      await _loadTickets();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Support ticket created successfully.')));
    }
  }

  Color _ticketStatusColor(String status) => status == 'closed' ? const Color(0xFF249B72) : status == 'pending' ? const Color(0xFF3989D6) : const Color(0xFFE39A24);

  Widget _ticketCard(Map<String, dynamic> ticket, ThemeData theme) {
    final scheme = theme.colorScheme;
    final status = _ticketStatus(ticket);
    final statusColor = _ticketStatusColor(status);
    final ticketId = (ticket['id'] ?? '').toString();
    return InkWell(
      onTap: () => _openTicketDetails(ticket),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withValues(alpha: .8))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text('TICKET #$ticketId', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: .45))),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(color: statusColor.withValues(alpha: .12), borderRadius: BorderRadius.circular(20)),
              child: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.w900))),
          ]),
          const SizedBox(height: 9),
          Text(_ticketSubject(ticket), style: TextStyle(color: scheme.onSurface, fontSize: 12, fontWeight: FontWeight.w800, height: 1.35)),
          const SizedBox(height: 9),
          Row(children: [
            Icon(LucideIcons.folder, size: 12, color: scheme.onSurfaceVariant),
            const SizedBox(width: 5),
            Expanded(child: Text(_ticketDepartment(ticket), style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 9))),

          ]),
          const SizedBox(height: 11),
          Divider(height: 1, color: theme.dividerColor.withValues(alpha: .65)),
          const SizedBox(height: 9),
          Row(children: [
            Icon(LucideIcons.clock3, size: 12, color: scheme.onSurfaceVariant),
            const SizedBox(width: 5),
            Expanded(child: Text('Updated ${ticket['updated_at'] ?? ticket['created_at']}', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 9))),
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
      builder: (_) => const _LiveTicketRequestSheet(),
    );
    if (!mounted || submitted != true) return;
    await _loadTickets();
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
    const filters = ['All', 'Open', 'Pending', 'Closed'];

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
              ('Open', _tickets.where((t) => _ticketStatus(t) == 'open').length, const Color(0xFFE39A24)),
              ('Pending', _tickets.where((t) => _ticketStatus(t) == 'pending').length, const Color(0xFF3989D6)),
              ('Closed', _tickets.where((t) => _ticketStatus(t) == 'closed').length, const Color(0xFF249B72)),
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
          if (_loading)
            const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()))
          else if (_loadError != null)
            Center(child: Column(children: [Text('Could not load tickets: $_loadError'), TextButton(onPressed: _loadTickets, child: const Text('Retry'))]))
          else if (_visibleTickets.isEmpty)
            Container(padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)),
              child: Center(child: Text('No tickets in this status.', style: TextStyle(color: muted, fontSize: 11))))
          else
            for (final ticket in _visibleTickets) _ticketCard(ticket, theme),
          const SizedBox(height: 12),

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
  final List<Map<String, dynamic>> _messages = [];
  final List<PlatformFile> _replyAttachments = [];
  bool _pickingReplyAttachment = false;

  bool get _canReply => widget.ticket['status'] == 'In-progress';

  @override
  void initState() {
    super.initState();
    if (widget.ticket['id'] == 'TKT-2026-1036') {
      _messages.addAll([
        {'from': 'You', 'time': 'Today, 08:42 AM', 'body': 'I am unable to sign in to my MT5 account. The platform keeps showing an authorization error.'},
        {'from': 'Support team', 'time': 'Today, 09:02 AM', 'body': 'Thank you for contacting us. Please confirm the MT5 login ID and the server name displayed in your account details. Do not share your password.', 'attachments': ['MT5_login_troubleshooting.pdf']},
        {'from': 'You', 'time': 'Today, 09:15 AM', 'body': 'My login ID is 8201456. The server shown is VTIndex-Live.'},
      ]);
    } else if (widget.ticket['id'] == 'TKT-2026-1019') {
      _messages.addAll([
        {'from': 'You', 'time': 'Yesterday, 03:55 PM', 'body': 'I need to correct the phone number registered on my profile.'},
        {'from': 'Support team', 'time': 'Yesterday, 04:12 PM', 'body': 'We have received your request. Our verification team is reviewing the account details. We will update you here if any additional information is required.', 'attachments': ['Profile_update_guide.pdf']},
      ]);
    } else {
      final isClosed = widget.ticket['status'] == 'Closed';
      _messages.add({
        'from': 'You',
        'time': widget.ticket['updated'] ?? 'Recently',
        'body': isClosed
            ? 'I have attached the relevant document for reference. Please review the details.'
            : 'I am following up on this request. Please let me know if you need any further information.',
        'attachments': isClosed
            ? ['Withdrawal_confirmation.pdf', 'Transaction_screenshot.png']
            : ['Supporting_document.pdf', 'Issue_screenshot.png'],
      });
    }
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _pickReplyAttachments() async {
    if (!_canReply || _pickingReplyAttachment) return;
    setState(() => _pickingReplyAttachment = true);
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['png', 'jpg', 'jpeg', 'pdf', 'doc', 'docx'],
      );
      if (!mounted || files.isEmpty) return;
      final accepted = <PlatformFile>[];
      var rejected = false;
      for (final file in files) {
        final size = await file.length();
        if (size != null && size <= 5 * 1024 * 1024) {
          accepted.add(file);
        } else {
          rejected = true;
        }
      }
      if (!mounted) return;
      setState(() {
        for (final file in accepted) {
          if (_replyAttachments.length < 5) _replyAttachments.add(file);
          else rejected = true;
        }
      });
      if (rejected && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attachments must be 5 MB or smaller. Maximum 5 files per reply.')),
        );
      }
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not attach files: $error')),
      );
    } finally {
      if (mounted) setState(() => _pickingReplyAttachment = false);
    }
  }

  void _sendReply() {
    final body = _replyController.text.trim();
    if ((body.isEmpty && _replyAttachments.isEmpty) || !_canReply) return;
    setState(() {
      _messages.add({
        'from': 'You', 'time': 'Just now', 'body': body,
        'attachments': _replyAttachments.map((file) => file.name).toList(),
      });
      _replyController.clear();
      _replyAttachments.clear();
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
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (_replyAttachments.isNotEmpty)
              SizedBox(height: 42, child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final file in _replyAttachments)
                    Padding(padding: const EdgeInsets.only(right: 7), child: InputChip(
                      avatar: const Icon(LucideIcons.paperclip, size: 14),
                      label: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 150),
                        child: Text(file.name, overflow: TextOverflow.ellipsis)),
                      onDeleted: () => setState(() => _replyAttachments.remove(file)),
                    )),
                ],
              )),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              IconButton(
                tooltip: 'Attach files', onPressed: _canReply ? _pickReplyAttachments : null,
                icon: _pickingReplyAttachment
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(LucideIcons.paperclip),
              ),
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

  Widget _messageBubble(Map<String, dynamic> message, ThemeData theme) {
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
            if ((message['body'] as String? ?? '').isNotEmpty)
              Text(message['body'] as String, style: TextStyle(color: scheme.onSurface, fontSize: 11, height: 1.5)),
            if ((message['attachments'] as List?)?.isNotEmpty == true) ...[
              const SizedBox(height: 9),
              for (final name in message['attachments'] as List)
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: .07),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: theme.dividerColor.withValues(alpha: .6)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(LucideIcons.fileText, size: 14, color: scheme.primary),
                    const SizedBox(width: 7),
                    Flexible(child: Text(name.toString(), style: TextStyle(color: scheme.onSurface, fontSize: 9, fontWeight: FontWeight.w700))),
                    const SizedBox(width: 5),
                    Icon(LucideIcons.paperclip, size: 11, color: scheme.onSurfaceVariant),
                  ]),
                ),
            ],
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

class _LiveTicketRequestSheet extends StatefulWidget {
  const _LiveTicketRequestSheet();
  @override
  State<_LiveTicketRequestSheet> createState() => _LiveTicketRequestSheetState();
}

class _LiveTicketRequestSheetState extends State<_LiveTicketRequestSheet> {
  final _form = GlobalKey<FormState>();
  final _subject = TextEditingController();
  final _description = TextEditingController();
  String _department = 'Trading & MT5';
  PlatformFile? _file;
  bool _busy = false;
  bool _picking = false;
  static const _departments = <(String, IconData, Color)>[
    ('Trading & MT5', Icons.trending_up, Color(0xFFFFA400)),
    ('Deposit & Payout', Icons.credit_card_outlined, Color(0xFF00B98B)),
    ('Account & KYC', Icons.verified_user_outlined, Color(0xFFB43DFF)),
    ('Partnership / IB', Icons.people_alt_outlined, Color(0xFFFF9D00)),
    ('Technical Issue', Icons.build_outlined, Color(0xFF00BCD4)),
    ('Others', Icons.help_outline, Color(0xFFFF4565)),
  ];
  @override
  void dispose() { _subject.dispose(); _description.dispose(); super.dispose(); }
  Future<void> _pick() async {
    setState(() => _picking = true);
    try {
      final result = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: const ['png','jpg','jpeg','webp','pdf']);
      if (result.isEmpty || !mounted) return;
      final file = result.files.first;
      final size = await file.length();
      if (size == null || size > 5 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Attachment must be 5 MB or smaller.')));
      } else { setState(() => _file = file); }
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not attach file: $error')));
    } finally { if (mounted) setState(() => _picking = false); }
  }
  Future<void> _submit() async {
    if (_busy || !_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      List<int>? bytes;
      if (_file != null) {
        bytes = _file!.bytes ?? (_file!.path == null ? null : await File(_file!.path!).readAsBytes());
        if (bytes == null) throw Exception('Could not read the selected attachment.');
      }
      await AuthApi.instance.createSupportTicket(
        subject: _subject.text.trim(), description: _description.text.trim(),
        department: _department, fileName: _file?.name, fileBytes: bytes,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ticket could not be submitted: $error')));
    } finally { if (mounted) setState(() => _busy = false); }
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    InputDecoration dec(String hint) => InputDecoration(
      hintText: hint, filled: true, fillColor: theme.scaffoldBackgroundColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.dividerColor)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.dividerColor)),
    );
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Material(color: scheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .94),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(padding: const EdgeInsets.fromLTRB(18, 14, 10, 12), child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Create support ticket', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                Text('Our team will respond in this conversation.', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 10)),
              ])),
              IconButton(onPressed: _busy ? null : () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ])),
            Divider(height: 1, color: theme.dividerColor),
            Flexible(child: Form(key: _form, child: ListView(shrinkWrap: true, padding: const EdgeInsets.all(18), children: [
              Text('DEPARTMENT', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 9, fontWeight: FontWeight.w900)),
              const SizedBox(height: 9),
              LayoutBuilder(builder: (context, constraints) {
                final columns = constraints.maxWidth < 450 ? 2 : 3;
                final width = (constraints.maxWidth - (columns - 1) * 8) / columns;
                return Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final item in _departments)
                    SizedBox(width: width, height: 42, child: _TicketDepartmentChip(
                      label: item.$1, icon: item.$2, accent: item.$3,
                      selected: _department == item.$1,
                      onTap: _busy ? () {} : () => setState(() => _department = item.$1),
                    )),
                ]);
              }),
              const SizedBox(height: 16),
              TextFormField(controller: _subject, maxLength: 200, decoration: dec('Subject').copyWith(counterText: ''),
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter a subject' : null),
              const SizedBox(height: 10),
              TextFormField(controller: _description, minLines: 4, maxLines: 7, maxLength: 5000,
                decoration: dec('Describe the issue. Include relevant account IDs or error messages. Never share passwords.'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Describe your issue' : null),
              OutlinedButton.icon(onPressed: _busy || _picking ? null : _pick,
                icon: const Icon(LucideIcons.paperclip, size: 16),
                label: Text(_picking ? 'Selecting…' : (_file?.name ?? 'Attach screenshot or PDF · max 5 MB'), overflow: TextOverflow.ellipsis)),
              if (_file != null) TextButton(onPressed: _busy ? null : () => setState(() => _file = null), child: const Text('Remove attachment')),
            ]))),
            Divider(height: 1, color: theme.dividerColor),
            Padding(padding: const EdgeInsets.fromLTRB(18, 10, 18, 14), child: Row(children: [
              Expanded(child: OutlinedButton(onPressed: _busy ? null : () => Navigator.pop(context), child: const Text('Cancel'))),
              const SizedBox(width: 9),
              Expanded(child: FilledButton.icon(onPressed: _busy ? null : _submit,
                icon: _busy ? const SizedBox(width: 15,height: 15,child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(LucideIcons.send, size: 15),
                label: Text(_busy ? 'Submitting…' : 'Submit ticket'))),
            ])),
          ]),
        ),
      ),
    );
  }
}

class _LiveTicketDetailsPage extends StatefulWidget {
  const _LiveTicketDetailsPage({required this.ticket});
  final Map<String, dynamic> ticket;
  @override
  State<_LiveTicketDetailsPage> createState() => _LiveTicketDetailsPageState();
}

class _LiveTicketDetailsPageState extends State<_LiveTicketDetailsPage> {
  final _reply = TextEditingController();
  Map<String, dynamic>? _ticket;
  List<Map<String, dynamic>> _messages = [];
  PlatformFile? _file;
  bool _loading = true, _sending = false, _picking = false, _changed = false;
  String? _error;
  int get _id => int.tryParse((_ticket?['id'] ?? widget.ticket['id'] ?? '').toString()) ?? 0;
  String get _status => (_ticket?['status'] ?? widget.ticket['status'] ?? 'open').toString().toLowerCase();
  @override
  void initState() { super.initState(); _ticket = Map<String, dynamic>.from(widget.ticket); _load(); }
  @override
  void dispose() { _reply.dispose(); super.dispose(); }
  Future<void> _load() async {
    try {
      final data = await AuthApi.instance.getSupportTicket(_id);
      final rows = data['messages'];
      if (!mounted) return;
      setState(() {
        _ticket = data;
        _messages = rows is List ? rows.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList() : [];
        _loading = false; _error = null;
      });
    } catch (error) { if (mounted) setState(() { _loading = false; _error = error.toString(); }); }
  }
  Future<void> _pick() async {
    setState(() => _picking = true);
    try {
      final result = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: const ['png','jpg','jpeg','webp','pdf']);
      if (result.isEmpty || !mounted) return;
      final file = result.files.first;
      final size = await file.length();
      if (size == null || size > 5 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Attachment must be 5 MB or smaller.')));
      } else { setState(() => _file = file); }
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not attach file: $error')));
    } finally { if (mounted) setState(() => _picking = false); }
  }
  Future<void> _send() async {
    final content = _reply.text.trim();
    if (_sending || (content.isEmpty && _file == null) || _status == 'closed') return;
    setState(() => _sending = true);
    try {
      List<int>? bytes;
      if (_file != null) {
        bytes = _file!.bytes ?? (_file!.path == null ? null : await File(_file!.path!).readAsBytes());
        if (bytes == null) throw Exception('Could not read the selected attachment.');
      }
      await AuthApi.instance.replySupportTicket(ticketId: _id, message: content, fileName: _file?.name, fileBytes: bytes);
      _reply.clear(); _file = null; _changed = true; FocusScope.of(context).unfocus();
      await _load();
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reply could not be sent: $error')));
    } finally { if (mounted) setState(() => _sending = false); }
  }
  String _date(dynamic value) {
    final d = DateTime.tryParse((value ?? '').toString())?.toLocal();
    if (d == null) return '—';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), scheme = theme.colorScheme;
    final ticket = _ticket ?? widget.ticket;
    final raw = (ticket['subject'] ?? 'Support request').toString();
    final subject = raw.replaceFirst(RegExp(r'^\[[^\]]+\]\s*'), '');
    final dept = RegExp(r'^\[([^\]]+)\]').firstMatch(raw)?.group(1) ?? 'General Support';
    final statusColor = _status == 'closed' ? const Color(0xFF249B72) : _status == 'pending' ? const Color(0xFF3989D6) : const Color(0xFFE39A24);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Ticket details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
        backgroundColor: theme.scaffoldBackgroundColor, surfaceTintColor: Colors.transparent,
        actions: [IconButton(onPressed: _load, icon: const Icon(LucideIcons.refreshCw, size: 18))]),
      body: Column(children: [
        Expanded(child: _loading ? const Center(child: CircularProgressIndicator())
          : _error != null ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 11)),
              TextButton(onPressed: _load, child: const Text('Retry')),
            ]))
          : ListView(padding: const EdgeInsets.all(16), children: [
              Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: theme.dividerColor)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text('TICKET #$_id', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 9, fontWeight: FontWeight.w900))),
                    Text(_status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.w900)),
                  ]),
                  const SizedBox(height: 10),
                  Text(subject, style: TextStyle(color: scheme.onSurface, fontSize: 16, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 7),
                  Text(dept, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 10)),
                  if ((ticket['description'] ?? '').toString().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(ticket['description'].toString(), style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 11, height: 1.45)),
                  ],
                  const SizedBox(height: 8),
                  Text('Created ${_date(ticket['created_at'])} · Updated ${_date(ticket['updated_at'])}', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 9)),
                ])),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: Text('CONVERSATION', style: TextStyle(color: scheme.onSurface, fontSize: 12, fontWeight: FontWeight.w900))),
                Text('${_messages.length} messages', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 9)),
              ]),
              const SizedBox(height: 12),
              if (_messages.isEmpty) Padding(padding: const EdgeInsets.all(18), child: Text('No replies yet. Our team will respond here.', textAlign: TextAlign.center, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 10))),
              for (final message in _messages) _bubble(message, theme),
            ])),
        if (!_loading && _error == null)
          SafeArea(top: false, child: Container(
            padding: EdgeInsets.fromLTRB(12, 8, 12, 8 + MediaQuery.viewInsetsOf(context).bottom),
            decoration: BoxDecoration(color: scheme.surface, border: Border(top: BorderSide(color: theme.dividerColor))),
            child: _status == 'closed'
              ? Row(children: [
                  Expanded(child: Text('This ticket is closed.', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 10))),
                  TextButton(onPressed: _sending ? null : () async {
                    setState(() => _sending = true);
                    try {
                      await AuthApi.instance.changeSupportTicketStatus(_id, 'open');
                      _changed = true; await _load();
                    } catch (error) {
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not reopen ticket: $error')));
                    } finally { if (mounted) setState(() => _sending = false); }
                  }, child: const Text('Reopen')),
                ])
              : Column(mainAxisSize: MainAxisSize.min, children: [
                  if (_file != null) Row(children: [
                    Expanded(child: Text(_file!.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: scheme.primary, fontSize: 9))),
                    IconButton(onPressed: _sending ? null : () => setState(() => _file = null), icon: const Icon(Icons.close, size: 16)),
                  ]),
                  Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    IconButton(onPressed: _picking || _sending ? null : _pick, icon: _picking ? const SizedBox(width: 17,height: 17,child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(LucideIcons.paperclip)),
                    Expanded(child: TextField(controller: _reply, minLines: 1, maxLines: 4,
                      decoration: InputDecoration(hintText: 'Write a reply…', filled: true, fillColor: theme.scaffoldBackgroundColor,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide.none)))),
                    const SizedBox(width: 8),
                    SizedBox(width: 44,height: 44,child: FilledButton(onPressed: _sending ? null : _send,
                      style: FilledButton.styleFrom(padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: _sending ? const SizedBox(width: 16,height: 16,child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(LucideIcons.send, size: 16))),
                  ]),
                ]),
          )),
      ]),
    );
  }
  Widget _bubble(Map<String, dynamic> message, ThemeData theme) {
    final scheme = theme.colorScheme;
    final mine = message['sender']?.toString() == (_ticket?['created_by'] ?? widget.ticket['created_by'])?.toString();
    final content = (message['content'] ?? '').toString();
    final fileName = (message['file_name'] ?? '').toString();
    return Align(alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * .86),
        child: Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: mine ? scheme.primary.withValues(alpha: .10) : scheme.surface,
            borderRadius: BorderRadius.circular(14), border: Border.all(color: theme.dividerColor.withValues(alpha: .7))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(mine ? 'You' : (message['sender_name'] ?? 'Support team').toString(),
              style: TextStyle(color: mine ? scheme.primary : scheme.onSurface, fontSize: 9, fontWeight: FontWeight.w900)),
            if (content.isNotEmpty) ...[const SizedBox(height: 6), Text(content, style: TextStyle(color: scheme.onSurface, fontSize: 11, height: 1.45))],
            if (fileName.isNotEmpty) ...[const SizedBox(height: 8), Text('Attachment: $fileName', style: TextStyle(color: scheme.primary, fontSize: 9, fontWeight: FontWeight.w700))],
            const SizedBox(height: 5),
            Text(_date(message['created_at']), style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 8)),
          ]),
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
