import 'package:flutter/material.dart';

import '../../../app_haptics.dart';
import 'partnership_theme.dart';

// ============================================================================
// INTERACTIVE IB FAQ ACCORDION SECTION
// ============================================================================

class IbFaqSection extends StatefulWidget {
  const IbFaqSection({
    super.key,
    required this.colors,
  });

  final PartnershipColors colors;

  @override
  State<IbFaqSection> createState() => _IbFaqSectionState();
}

class _IbFaqSectionState extends State<IbFaqSection> {
  final Set<int> _openFaqs = {0};

  static const _faqs = [
    {
      'q': 'How does the commission split work across the 3 tiers?',
      'a': 'Commissions are distributed from an \$8.00/lot standard rebate pool across 3 tiers: Level 1 (Direct Referrals) receives 50%, Level 2 (Sub-IBs) receives 20%, and Level 3 (Extended Network) receives 10%. Overrides compound automatically without reducing your partners\' earnings.',
    },
    {
      'q': 'What is the VT-Index Introducing Broker (IB) Program?',
      'a': 'The VT-Index IB program enables traders, educators, fund managers, and digital marketers to earn lifetime recurring commissions by introducing clients to our institutional multi-asset MT5 platform.',
    },
    {
      'q': 'How and when are my commissions paid?',
      'a': 'Commissions are calculated automatically upon trade closure and credited on a daily basis directly to your Partner Commission Wallet. You can withdraw funds instantly to crypto, bank wire, or transfer to your trading account with zero fees.',
    },
    {
      'q': 'Are there any setup fees or minimum trading volume requirements?',
      'a': 'No. Becoming an IB partner at VT-Index is 100% free with no upfront setup costs, no mandatory deposit, and no restrictive quotas. You start earning from the very first lot traded by your referred clients.',
    },
    {
      'q': 'How long does the approval process take?',
      'a': 'Our compliance and partnership specialists review IB requests promptly—typically within 2 to 24 hours on business days. Once verified, your Partner Portal and unique referral links activate instantly.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FREQUENTLY ASKED QUESTIONS',
          style: TextStyle(color: colors.muted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8),
        ),
        const SizedBox(height: 10),
        ..._faqs.asMap().entries.map((entry) {
          final idx = entry.key;
          final f = entry.value;
          final isOpen = _openFaqs.contains(idx);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isOpen ? colors.blue.withValues(alpha: 0.5) : colors.border),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  initiallyExpanded: isOpen,
                  onExpansionChanged: (expanded) {
                    AppHaptics.selectionClick();
                    setState(() {
                      if (expanded) {
                        _openFaqs.add(idx);
                      } else {
                        _openFaqs.remove(idx);
                      }
                    });
                  },
                  title: Text(
                    f['q']!,
                    style: TextStyle(color: colors.text, fontSize: 12.5, fontWeight: FontWeight.w700),
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  children: [
                    Text(
                      f['a']!,
                      style: TextStyle(color: colors.muted, fontSize: 11.5, height: 1.45),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
