import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_haptics.dart';

class BrokerPrivacyPolicyPage extends StatelessWidget {
  const BrokerPrivacyPolicyPage({super.key});

  static const _policyUrl = 'https://vtindex.com/privacy-policy';
  static const _regulatoryUrl = 'https://vtindex.com/regulatory-information';
  static const _supportEmail = 'support@vtindex.com';

  Future<void> _openUrl(BuildContext context, String value) async {
    AppHaptics.selectionClick();
    try {
      final opened = await launchUrl(
        Uri.parse(value),
        mode: LaunchMode.externalApplication,
      );
      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open this link.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open this link.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final muted = theme.colorScheme.onSurfaceVariant;
    final linkColor = theme.colorScheme.primary;
    final bodyStyle = theme.textTheme.bodyMedium?.copyWith(
      color: textColor,
      height: 1.45,
      fontSize: 14,
    );
    final headingStyle = theme.textTheme.titleMedium?.copyWith(
      color: textColor,
      fontWeight: FontWeight.w700,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 20, 14, 40),
      children: [
        InkWell(
          onTap: () => _openUrl(context, _policyUrl),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              'View More Details',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: linkColor,
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 48),
        Text('About This Policy', style: headingStyle),
        const SizedBox(height: 10),
        Text.rich(
          TextSpan(
            style: bodyStyle,
            children: const [
              TextSpan(text: 'The purpose of this Privacy Policy is to provide comprehensive details on how '),
              TextSpan(text: 'VT Index Ltd', style: TextStyle(fontWeight: FontWeight.w700)),
              TextSpan(text: ' ("VTIndex", "we", "us", or "our") collects, processes, and protects personal information supplied through our official website at https://vtindex.com, the MetaTrader 5 trading infrastructure, client portal, or via telephone, chat, or email communications.'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'This policy applies to visitors, applicants, current and former clients, authorized representatives, beneficial owners, directors, partners, introducers, and other individuals whose personal data is processed through these activities.',
          style: bodyStyle,
        ),
        const SizedBox(height: 24),
        Text('Protection of Personal Data', style: headingStyle),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            style: bodyStyle,
            children: [
              const TextSpan(text: 'VT Index Ltd acts in accordance with applicable international data privacy standards and statutory regulations governed by the Mauritius Financial Services Commission (FSC License No. GB25205095). For licensing credentials and verification guidelines, review our '),
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: GestureDetector(
                  onTap: () => _openUrl(context, _regulatoryUrl),
                  child: Text(
                    'Regulatory Information',
                    style: bodyStyle?.copyWith(
                      color: linkColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const TextSpan(text: ' page. We understand the importance of maintaining strict confidentiality over personal and financial details. We use technical, physical, and administrative measures to protect the integrity, confidentiality, and availability of client data.'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('How We Safeguard Your Information', style: headingStyle),
        const SizedBox(height: 8),
        Text(
          'The following security measures are used to safeguard your personal and account data:',
          style: bodyStyle,
        ),
        const SizedBox(height: 10),
        _PolicyBullet(title: 'Secure Authentication', text: 'Account access is controlled through multi-factor authentication, encrypted credentials, and individual user identifiers.', style: bodyStyle),
        _PolicyBullet(title: 'Tier-1 Server Architecture', text: 'Personal data is stored on protected enterprise servers safeguarded by next-generation firewalls and real-time threat detection.', style: bodyStyle),
        _PolicyBullet(title: 'Encrypted Financial Transactions', text: 'Payment gateways and financial processing use 256-bit SSL/TLS encryption protocols.', style: bodyStyle),
        _PolicyBullet(title: 'Cryptographic Key Management', text: 'Cryptographic keys safeguarding sensitive stored data are maintained in secure hardware security modules (HSM).', style: bodyStyle),
        _PolicyBullet(title: 'Segregation of Client Information', text: 'Role-based access limits data exposure to authorized personnel involved in account servicing and regulatory compliance.', style: bodyStyle),
        const SizedBox(height: 20),
        Text('Data Controller & Contact Inquiries', style: headingStyle),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            style: bodyStyle,
            children: const [
              TextSpan(text: 'When you submit personal information or open a live or demo account, '),
              TextSpan(text: 'VT Index Ltd', style: TextStyle(fontWeight: FontWeight.w700)),
              TextSpan(text: ' operates as the primary data controller. For inquiries regarding your personal data, data deletion requests, or regulatory rights, contact our Data Protection Office.'),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text.rich(
          TextSpan(
            style: bodyStyle,
            children: const [
              TextSpan(text: 'Registered Address: ', style: TextStyle(fontWeight: FontWeight.w700)),
              TextSpan(text: 'Office 133, Ebene Junction, Rue de la Democratie, Ebene, Mauritius'),
            ],
          ),
        ),
        const SizedBox(height: 5),
        InkWell(
          onTap: () => _openUrl(context, 'mailto:$_supportEmail'),
          child: Text.rich(
            TextSpan(
              style: bodyStyle,
              children: [
                const TextSpan(text: 'Support Email: ', style: TextStyle(fontWeight: FontWeight.w700)),
                TextSpan(text: _supportEmail, style: TextStyle(color: linkColor, decoration: TextDecoration.underline)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text.rich(
          TextSpan(
            style: bodyStyle,
            children: const [
              TextSpan(text: 'Customer Support Line: ', style: TextStyle(fontWeight: FontWeight.w700)),
              TextSpan(text: '+971544064001'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'For the latest version of this policy, use the link above.',
          style: theme.textTheme.bodySmall?.copyWith(color: muted),
        ),
      ],
    );
  }
}

class _PolicyBullet extends StatelessWidget {
  const _PolicyBullet({required this.title, required this.text, required this.style});

  final String title;
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: style,
                  children: [
                    TextSpan(text: '$title: ', style: const TextStyle(fontWeight: FontWeight.w700)),
                    TextSpan(text: text),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}
