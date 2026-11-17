import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

const _profileNavy = Color(0xFF10264A);
const _profilePanel = Color(0xFFFFFFFF);
const _profileBorder = Color(0xFFDCE5F1);
const _profileMuted = Color(0xFF62738E);
const _profileBlue = Color(0xFF0875F5);
const _profileGold = Color(0xFFF4C84A);
const _profileGreen = Color(0xFF16A34A);
const _profileBg = Color(0xFFF8FAFC);
const _profileCard = _profilePanel;
const _profileText = _profileNavy;
const _profileTextSecondary = _profileMuted;
const _profileBlueDark = Color(0xFF174A8B);
const _profileBlueLight = Color(0xFFEAF2FC);
const _profileBlueBorder = Color(0xFFD3E2F8);
const _profileGoldLight = Color(0xFFFFF7E3);
const _profileGoldBorder = Color(0xFFF0DFAF);
const _profileGreenLight = Color(0xFFEAF7EF);
const _profileGreenBorder = Color(0xFFCBE9D4);
const _profileShadow = [
  BoxShadow(
    color: Color(0x0D10264A),
    blurRadius: 16,
    offset: Offset(0, 5),
  ),
];
const _profileSheetShadow = [
  BoxShadow(
    color: Color(0x1A10264A),
    blurRadius: 24,
    offset: Offset(0, -5),
  ),
];

class BrokerProfilePage extends StatefulWidget {
  const BrokerProfilePage({
    super.key,
    required this.onBack,
    required this.onSelectPage,
  });

  final VoidCallback onBack;
  final ValueChanged<String> onSelectPage;

  @override
  State<BrokerProfilePage> createState() => _BrokerProfilePageState();
}

class _BrokerProfilePageState extends State<BrokerProfilePage> {
  int _selectedTabIndex = 0; // Overview, Personal Details, Verification, Payment Methods

  // Mutable user profile details
  String _name = 'INR-DEVOP B';
  String _email = 'iyyanar@vtindex.com';
  String _phone = '7894561235';
  String _location = 'kattu edaiyar, india';
  final String _dob = '24 Aug 2003';
  final String _gender = 'Male';
  final String _nationality = 'Indian (IN)';
  String _address = 'No 3 south street kattu edaiyar villupuram, kattu edaiyar, tamil nadu, india, 605751';
  String _occupation = 'Software Engineer';
  Color _avatarBg = const Color(0xFF5E9422); // Olive-green
  String _bannerTheme = 'Cosmic Landscape';

  // Mutable Payment Methods details
  String _bankName = 'NONE BANK';
  String _bankAccountNumber = '789456123456';
  String _bankIfscCode = 'IDIB000R101D';
  String _bankBranch = 'Kallakurichi';
  final String _bankHolder = 'INR-DEVOP B';
  final String _bankStatus = 'Connected';

  String _cryptoWalletAddress = '123456789asdfghjklrgq094i50i3i45kjdfjweir099iwe9f';
  String _cryptoCurrency = 'UNANG';
  final String _cryptoNetwork = 'TRON (TRC20)';
  final String _cryptoStatus = 'Connected';

  void _showChangeBannerSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: const BoxDecoration(
          color: _profileCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: _profileSheetShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Customize Profile Banner',
              style: TextStyle(
                color: _profileText,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Select a cosmic theme or upload a custom panoramic banner image.',
              style: TextStyle(color: _profileTextSecondary, fontSize: 12),
            ),
            const SizedBox(height: 18),
            _BannerOptionTile(
              title: 'Cosmic Landscape (Default)',
              subtitle: 'Midnight sapphire with stars and mountain ridges',
              icon: LucideIcons.sparkles,
              selected: _bannerTheme == 'Cosmic Landscape',
              onTap: () {
                setState(() => _bannerTheme = 'Cosmic Landscape');
                Navigator.pop(ctx);
                _showSnack('Banner updated to Cosmic Landscape');
              },
            ),
            const SizedBox(height: 10),
            _BannerOptionTile(
              title: 'Deep Ocean Aurora',
              subtitle: 'Cyan and deep cobalt planetary glow',
              icon: LucideIcons.waves,
              selected: _bannerTheme == 'Deep Ocean Aurora',
              onTap: () {
                setState(() => _bannerTheme = 'Deep Ocean Aurora');
                Navigator.pop(ctx);
                _showSnack('Banner updated to Deep Ocean Aurora');
              },
            ),
            const SizedBox(height: 10),
            _BannerOptionTile(
              title: 'Astral Cyber Gold',
              subtitle: 'Warm celestial nebula with gold horizon',
              icon: LucideIcons.sun,
              selected: _bannerTheme == 'Astral Cyber Gold',
              onTap: () {
                setState(() => _bannerTheme = 'Astral Cyber Gold');
                Navigator.pop(ctx);
                _showSnack('Banner updated to Astral Cyber Gold');
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _profileBlue),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: _profileBlueLight,
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  _showSnack('Custom banner upload is available in device gallery');
                },
                icon: const Icon(LucideIcons.imageUp, size: 18, color: _profileBlue),
                label: const Text('Upload Custom Image', style: TextStyle(color: _profileBlueDark, fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePhotoSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: const BoxDecoration(
          color: _profileCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: _profileSheetShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Change Profile Picture',
              style: TextStyle(
                color: _profileText,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Take a photo, pick from gallery, or choose an avatar theme color.',
              style: TextStyle(color: _profileTextSecondary, fontSize: 12),
            ),
            const SizedBox(height: 18),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: _profileBlueLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.camera, color: _profileBlue, size: 20),
              ),
              title: const Text('Take Photo', style: TextStyle(color: _profileText, fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: const Text('Use camera for instant snapshot', style: TextStyle(color: _profileTextSecondary, fontSize: 11)),
              trailing: const Icon(LucideIcons.chevronRight, color: _profileMuted, size: 18),
              onTap: () {
                Navigator.pop(ctx);
                _showSnack('Camera snapshot simulated');
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: _profileGoldLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.image, color: _profileGold, size: 20),
              ),
              title: const Text('Choose from Gallery', style: TextStyle(color: _profileText, fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: const Text('Upload JPG or PNG from storage', style: TextStyle(color: _profileTextSecondary, fontSize: 11)),
              trailing: const Icon(LucideIcons.chevronRight, color: _profileMuted, size: 18),
              onTap: () {
                Navigator.pop(ctx);
                _showSnack('Gallery file picker simulated');
              },
            ),
            const SizedBox(height: 14),
            const Text(
              'Avatar Color Accent',
              style: TextStyle(color: _profileText, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _colorCircle(const Color(0xFF5E9422), 'Olive (Default)'),
                _colorCircle(const Color(0xFF0875F5), 'Sapphire'),
                _colorCircle(const Color(0xFF9333EA), 'Amethyst'),
                _colorCircle(const Color(0xFFE5A93C), 'Amber'),
                _colorCircle(const Color(0xFFDC2626), 'Crimson'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _colorCircle(Color color, String name) {
    final selected = _avatarBg.toARGB32() == color.toARGB32();
    return GestureDetector(
      onTap: () {
        setState(() => _avatarBg = color);
        Navigator.pop(context);
        _showSnack('Avatar color set to $name');
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? _profileBlue : const Color(0xFFE2E8F0),
            width: selected ? 3.5 : 2.0,
          ),
          boxShadow: selected
              ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 10, spreadRadius: 2)]
              : null,
        ),
        child: selected
            ? const Icon(LucideIcons.check, color: Colors.white, size: 20)
            : null,
      ),
    );
  }

  void _showEditDetailsSheet() {
    final nameCtrl = TextEditingController(text: _name);
    final emailCtrl = TextEditingController(text: _email);
    final phoneCtrl = TextEditingController(text: _phone);
    final locationCtrl = TextEditingController(text: _location);
    final addressCtrl = TextEditingController(text: _address);
    final occupationCtrl = TextEditingController(text: _occupation);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.85,
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: const BoxDecoration(
            color: _profileCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: _profileSheetShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    'Edit Personal Details',
                    style: TextStyle(
                      color: _profileText,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(LucideIcons.x, color: _profileTextSecondary, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Update your personal profile and contact information.',
                style: TextStyle(color: _profileTextSecondary, fontSize: 12),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _inputField(controller: nameCtrl, label: 'Full Legal Name', icon: LucideIcons.user),
                    const SizedBox(height: 12),
                    _inputField(controller: emailCtrl, label: 'Email Address', icon: LucideIcons.mail),
                    const SizedBox(height: 12),
                    _inputField(controller: phoneCtrl, label: 'Phone Number', icon: LucideIcons.phone),
                    const SizedBox(height: 12),
                    _inputField(controller: locationCtrl, label: 'City & Country', icon: LucideIcons.mapPin),
                    const SizedBox(height: 12),
                    _inputField(controller: addressCtrl, label: 'Residential Address', icon: LucideIcons.home, maxLines: 2),
                    const SizedBox(height: 12),
                    _inputField(controller: occupationCtrl, label: 'Occupation', icon: LucideIcons.briefcase),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _profileBorder),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel', style: TextStyle(color: _profileTextSecondary, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _profileBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 1,
                      ),
                      onPressed: () {
                        setState(() {
                          _name = nameCtrl.text.trim().isEmpty ? _name : nameCtrl.text.trim();
                          _email = emailCtrl.text.trim().isEmpty ? _email : emailCtrl.text.trim();
                          _phone = phoneCtrl.text.trim().isEmpty ? _phone : phoneCtrl.text.trim();
                          _location = locationCtrl.text.trim().isEmpty ? _location : locationCtrl.text.trim();
                          _address = addressCtrl.text.trim().isEmpty ? _address : addressCtrl.text.trim();
                          _occupation = occupationCtrl.text.trim().isEmpty ? _occupation : occupationCtrl.text.trim();
                        });
                        Navigator.pop(ctx);
                        _showSnack('Personal details updated successfully');
                      },
                      child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF475569), fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: _profileText, fontSize: 13, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            prefixIcon: Icon(icon, color: _profileBlue, size: 18),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _profileBlue, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // This profile experience is intentionally phone-only.
        // Do not introduce tablet or desktop breakpoints/layout variants.
        if (constraints.maxWidth > 600) {
          return Container(
            color: _profileBg,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: _profileBlueLight,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    LucideIcons.smartphone,
                    color: _profileBlue,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Mobile experience only',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _profileNavy,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This profile is designed exclusively for mobile phone screens.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _profileMuted,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: widget.onBack,
                  icon: const Icon(LucideIcons.arrowLeft, size: 16),
                  label: const Text('Go back'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _profileBlue,
                    side: const BorderSide(color: _profileBlueBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          color: _profileBg,
          child: SafeArea(
            top: false,
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildMobileProfileHeader(),
                      const SizedBox(height: 22),
                      _buildMobileSectionNavigation(),
                      const SizedBox(height: 20),
                      if (_selectedTabIndex == 0)
                        _buildOverviewTab()
                      else if (_selectedTabIndex == 1)
                        _buildPersonalDetailsTab()
                      else if (_selectedTabIndex == 2)
                        _buildVerificationTab()
                      else if (_selectedTabIndex == 3)
                        _buildPaymentMethodsTab(),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Native-app profile identity header. Keeps the existing avatar/banner actions.
  Widget _buildMobileProfileHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _profileBorder),
        boxShadow: _profileShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 164,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 130,
                  child: CustomPaint(
                    painter: _ProfileCoverPainter(),
                    child: const SizedBox.expand(),
                  ),
                ),
                Positioned(
                  top: 14,
                  right: 14,
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(24),
                    child: InkWell(
                      onTap: _showChangeBannerSheet,
                      borderRadius: BorderRadius.circular(24),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.image, color: _profileNavy, size: 14),
                            SizedBox(width: 6),
                            Text(
                              'Edit cover',
                              style: TextStyle(
                                color: _profileNavy,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 18,
                  bottom: 0,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 86,
                        height: 86,
                        decoration: BoxDecoration(
                          color: _avatarBg,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 5),
                          boxShadow: _profileShadow,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _name.isNotEmpty ? _name[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Positioned(
                        right: -2,
                        bottom: 2,
                        child: Material(
                          color: _profileBlue,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _showChangePhotoSheet,
                            child: const SizedBox(
                              width: 31,
                              height: 31,
                              child: Icon(
                                LucideIcons.camera,
                                color: Colors.white,
                                size: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 5,
                        children: [
                          Text(
                            _name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _profileNavy,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const Icon(
                            LucideIcons.badgeCheck,
                            color: _profileGold,
                            size: 17,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _profileGreenLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'VERIFIED',
                              style: TextStyle(
                                color: _profileGreen,
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: _showEditDetailsSheet,
                      icon: const Icon(LucideIcons.pencil, size: 14),
                      label: const Text('Edit profile'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _profileBlue,
                        side: const BorderSide(color: _profileBlueBorder),
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 9,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                const Text(
                  'Client account  ·  VT Index',
                  style: TextStyle(
                    color: _profileMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _profileBlueLight.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _profileBlueBorder),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _profileContactItem(
                          icon: LucideIcons.mail,
                          value: _email,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        color: _profileBlueBorder,
                      ),
                      Expanded(
                        child: _profileContactItem(
                          icon: LucideIcons.phone,
                          value: _phone,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _mobileMetric(
                        'ACCOUNT LEVEL',
                        'Tier 3',
                        LucideIcons.layers,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _mobileMetric(
                        'PROFILE STATUS',
                        'Complete',
                        LucideIcons.shieldCheck,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileContactItem({
    required IconData icon,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: _profileBlue, size: 17),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _profileNavy,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _mobileContactLine(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 15, color: _profileBlue),
        const SizedBox(width: 9),
        Expanded(child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _profileMuted, fontSize: 12, fontWeight: FontWeight.w500))),
      ],
    );
  }

  Widget _mobileMetric(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
      decoration: BoxDecoration(
        color: _profileBlueLight.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(15),
        border: const Border(
          left: BorderSide(color: _profileBlue, width: 3),
          top: BorderSide(color: _profileBlueBorder),
          right: BorderSide(color: _profileBlueBorder),
          bottom: BorderSide(color: _profileBlueBorder),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: _profileBlue, size: 23),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _profileMuted,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.35,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _profileNavy,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 3),
          const Icon(LucideIcons.chevronRight, color: _profileNavy, size: 16),
        ],
      ),
    );
  }

  Widget _buildMobileSectionNavigation() {
    const tabs = [
      (icon: LucideIcons.layoutDashboard, label: 'Overview'),
      (icon: LucideIcons.userRound, label: 'Personal'),
      (icon: LucideIcons.shieldCheck, label: 'Verification'),
      (icon: LucideIcons.wallet, label: 'Payments'),
    ];
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: _profileBorder)),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Material(
                  color: _selectedTabIndex == i ? _profileNavy : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(11),
                    onTap: () => setState(() => _selectedTabIndex = i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(tabs[i].icon, size: 17, color: _selectedTabIndex == i ? Colors.white : _profileMuted),
                          const SizedBox(height: 5),
                          Text(
                            tabs[i].label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 9, fontWeight: _selectedTabIndex == i ? FontWeight.w700 : FontWeight.w500, color: _selectedTabIndex == i ? Colors.white : _profileMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeroBannerCard() {
    return Container(
      decoration: BoxDecoration(
        color: _profileCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _profileBorder, width: 1.2),
        boxShadow: _profileShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Scenic / Cosmic Banner
              SizedBox(
                height: 125,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomPaint(
                      painter: CelestialBannerPainter(theme: _bannerTheme),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: InkWell(
                        onTap: _showChangeBannerSheet,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.5),
                              width: 1.1,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.camera, color: Colors.white, size: 14),
                              SizedBox(width: 6),
                              Text(
                                'Change banner',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Profile Details on Pure White Card Surface
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 52, 18, 18),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 420;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name Row with gold checkmark and Verified Pill Chip
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Text(
                              _name,
                              style: const TextStyle(
                                color: _profileText,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const Icon(
                              LucideIcons.badgeCheck,
                              color: _profileGold,
                              size: 20,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _profileGoldLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _profileGoldBorder),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 3,
                                    backgroundColor: _profileGold,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'Verified',
                                    style: TextStyle(
                                      color: _profileGold,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Subtitle: "Client   VT Index"
                        const Text(
                          'Client   VT Index',
                          style: TextStyle(
                            color: _profileTextSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Clean modern contact chips
                        if (isNarrow) ...[
                          _glassChip(LucideIcons.mail, _email),
                          const SizedBox(height: 6),
                          _glassChip(LucideIcons.phone, _phone),
                          const SizedBox(height: 6),
                          _glassChip(LucideIcons.mapPin, _location),
                        ] else ...[
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _glassChip(LucideIcons.mail, _email),
                              _glassChip(LucideIcons.phone, _phone),
                            ],
                          ),
                          const SizedBox(height: 6),
                          _glassChip(LucideIcons.mapPin, _location),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ),

          // Avatar positioned overlapping banner by 45px
          Positioned(
            top: 80,
            left: 18,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _avatarBg,
                    border: Border.all(color: Colors.white, width: 3.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1F0F172A),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _name.isNotEmpty ? _name[0].toUpperCase() : 'I',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Camera Edit Badge at bottom-right of avatar
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: GestureDetector(
                    onTap: _showChangePhotoSheet,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B), // Amber
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x26000000),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          LucideIcons.camera,
                          size: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _profileBorder,
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _profileBlue, size: 13),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabsBar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAF1FA)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const tabWidth = 132.0;
          const tabGap = 4.0;
          final tabs = [
            _tabButton(
              index: 0,
              icon: LucideIcons.layoutGrid,
              label: 'Overview',
            ),
            _tabButton(
              index: 1,
              icon: LucideIcons.userRound,
              label: 'Personal Details',
            ),
            _tabButton(
              index: 2,
              icon: LucideIcons.shieldCheck,
              label: 'Verification',
            ),
            _tabButton(
              index: 3,
              icon: LucideIcons.creditCard,
              label: 'Payment Methods',
            ),
          ];

          final requiredWidth =
              tabs.length * tabWidth + (tabs.length - 1) * tabGap;
          if (constraints.maxWidth >= requiredWidth) {
            return Row(
              children: [
                for (var i = 0; i < tabs.length; i++) ...[
                  if (i > 0) const SizedBox(width: tabGap),
                  Expanded(child: tabs[i]),
                ],
              ],
            );
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < tabs.length; i++) ...[
                  if (i > 0) const SizedBox(width: tabGap),
                  SizedBox(width: tabWidth, child: tabs[i]),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _tabButton({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final active = _selectedTabIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedTabIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFF7F9FC) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: active
              ? Border.all(color: _profileBlueBorder, width: 1.2)
              : Border.all(color: Colors.transparent),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 15,
                  color: active ? const Color(0xFF10264A) : _profileMuted,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: active ? const Color(0xFF10264A) : _profileMuted,
                      fontSize: 11,
                      fontWeight: active ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Container(
              width: 22,
              height: 2.5,
              decoration: BoxDecoration(
                color: active ? _profileGold : Colors.transparent,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: OVERVIEW TAB
  // ==========================================
  Widget _buildOverviewTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Account overview',
                style: TextStyle(color: _profileNavy, fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(color: _profileGreenLight, borderRadius: BorderRadius.circular(20)),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.circleCheck, color: _profileGreen, size: 12),
                  SizedBox(width: 5),
                  Text('Active', style: TextStyle(color: _profileGreen, fontSize: 10, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildMobileCompletionSummary(),
        const SizedBox(height: 22),
        const Text('Quick actions', style: TextStyle(color: _profileNavy, fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 11),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.45,
          children: [
            _mobileQuickAction(
              icon: LucideIcons.userRound,
              title: 'Edit details',
              subtitle: 'Personal profile',
              onTap: _showEditDetailsSheet,
            ),
            _mobileQuickAction(
              icon: LucideIcons.shieldCheck,
              title: 'Verification',
              subtitle: 'View KYC status',
              onTap: () => setState(() => _selectedTabIndex = 2),
            ),
            _mobileQuickAction(
              icon: LucideIcons.landmark,
              title: 'Bank account',
              subtitle: 'Payout details',
              onTap: _showBankDetailsSheet,
            ),
            _mobileQuickAction(
              icon: LucideIcons.wallet,
              title: 'Crypto wallet',
              subtitle: 'Wallet settings',
              onTap: _showCryptoWalletSheet,
            ),
          ],
        ),
        const SizedBox(height: 22),
        _buildPersonalInformationCard(),
        const SizedBox(height: 14),
        _buildIdentityVerificationCard(),
        const SizedBox(height: 14),
        _buildPaymentMethodsCard(),
      ],
    );
  }

  Widget _buildMobileCompletionSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _profileNavy,
        borderRadius: BorderRadius.circular(18),
        boxShadow: _profileShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Profile completion', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
              ),
              Text('100%', style: TextStyle(color: Color(0xFFFFD76A), fontSize: 17, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 11),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: const LinearProgressIndicator(
              value: 1,
              minHeight: 6,
              backgroundColor: Color(0xFF526987),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF4C84A)),
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Icon(LucideIcons.shieldCheck, color: Color(0xFF9EDDB2), size: 15),
              SizedBox(width: 7),
              Expanded(child: Text('Your profile and verification are complete.', style: TextStyle(color: Color(0xFFD9E5F4), fontSize: 11, height: 1.3))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mobileQuickAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: _profileBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: _profileBlueLight, borderRadius: BorderRadius.circular(11)),
                child: Icon(icon, color: _profileBlue, size: 17),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _profileNavy, fontSize: 11, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _profileMuted, fontSize: 9)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Card 1: Profile Completion Card
  Widget _buildProfileCompletionCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _profileCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _profileBorder),
        boxShadow: _profileShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Profile Completion',
                  style: TextStyle(
                    color: const Color(0xFF10264A),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _profileGreenLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _profileGreenBorder),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.circleCheck, color: _profileGreen, size: 12),
                    SizedBox(width: 4),
                    Text(
                      '100% COMPLETE',
                      style: TextStyle(
                        color: _profileGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Gauge & text explanation
          Row(
            children: [
              // Circular 100% progress gauge in gold/amber
              SizedBox(
                width: 78,
                height: 78,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const SizedBox(
                      width: 78,
                      height: 78,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 8,
                        strokeCap: StrokeCap.round,
                        backgroundColor: Color(0xFFFEF3C7),
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4A838)),
                      ),
                    ),
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '100%',
                          style: TextStyle(
                            color: Color(0xFFD4A838),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'VERIFIED',
                          style: TextStyle(
                            color: _profileTextSecondary,
                            fontSize: 7,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Fully Unlocked',
                      style: TextStyle(
                        color: const Color(0xFF10264A),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Your profile, contact details, identity and settlement methods are fully verified. All Tier-3 trading, deposits and withdrawals are active.',
                      style: TextStyle(
                        color: _profileTextSecondary,
                        fontSize: 11,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFDCE5F1), thickness: 0.8),
          const SizedBox(height: 12),

          // 4 Checklist items with green circular checkmarks
          _completionItem(
            title: 'Personal Information',
            subtitle: 'Full name, email & verified contact phone number',
          ),
          const SizedBox(height: 10),
          _completionItem(
            title: 'Identity Verification',
            subtitle: 'Government issued ID document approved',
          ),
          const SizedBox(height: 10),
          _completionItem(
            title: 'Address Verification',
            subtitle: 'Residential address proof confirmed',
          ),
          const SizedBox(height: 10),
          _completionItem(
            title: 'Payment Methods',
            subtitle: 'Settlement bank account linked & authorized',
          ),
          const SizedBox(height: 16),

          // Bottom button: [✓] Profile Completed
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _profileBorder),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: const Color(0xFFF8FAFC),
              ),
              onPressed: () => _showSnack('Profile is 100% complete and verified'),
              icon: const Icon(LucideIcons.check, size: 16, color: _profileGreen),
              label: const Text(
                'Profile Completed',
                style: TextStyle(
                  color: const Color(0xFF10264A),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Card 2: Account Status Card
  Widget _buildAccountStatusCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _profileCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _profileBorder),
        boxShadow: _profileShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account Status',
            style: TextStyle(
              color: const Color(0xFF10264A),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Concentric green circle badge with shield-check icon
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _profileGreenLight,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _profileGreenBorder,
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.all(6),
                child: Container(
                  decoration: const BoxDecoration(
                    color: _profileGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      LucideIcons.shieldCheck,
                      color: const Color(0xFF10264A),
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Verified Account',
                      style: TextStyle(
                        color: const Color(0xFF10264A),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Your account is verified and ready to access all available features.',
                      style: TextStyle(
                        color: _profileTextSecondary,
                        fontSize: 11.5,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _profileGreenLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _profileGreenBorder,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.check, size: 13, color: _profileGreen),
                          SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              'All verifications completed',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: _profileGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Card 3: Quick Actions Card
  Widget _buildQuickActionsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _profileCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _profileBorder),
        boxShadow: _profileShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Quick Actions',
                  style: TextStyle(
                    color: const Color(0xFF10264A),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _profileBlueLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _profileBlueBorder),
                ),
                child: const Icon(LucideIcons.lock, size: 14, color: _profileBlue),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _actionTile(
            icon: LucideIcons.penLine,
            iconColor: _profileBlue,
            iconBg: _profileBlueLight,
            title: 'Edit Profile',
            subtitle: 'Continue profile setup',
            onTap: _showEditDetailsSheet,
          ),
          const SizedBox(height: 10),
          _actionTile(
            icon: LucideIcons.fileUp,
            iconColor: _profileBlue,
            iconBg: _profileBlueLight,
            title: 'Upload Documents',
            subtitle: 'Manage KYC documents',
            onTap: () => setState(() => _selectedTabIndex = 2),
          ),
          const SizedBox(height: 10),
          _actionTile(
            icon: LucideIcons.landmark,
            iconColor: _profileBlue,
            iconBg: _profileBlueLight,
            title: 'Bank Details',
            subtitle: 'Manage bank account',
            onTap: _showBankDetailsSheet,
          ),
          const SizedBox(height: 10),
          _actionTile(
            icon: LucideIcons.wallet,
            iconColor: _profileGold,
            iconBg: _profileGoldLight,
            title: 'Crypto Wallet',
            subtitle: 'Manage crypto wallet',
            onTap: _showCryptoWalletSheet,
          ),
        ],
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F9FC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFDCE5F1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: const Color(0xFF10264A),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: _profileTextSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, size: 16, color: _profileMuted),
          ],
        ),
      ),
    );
  }

  // Card 4: Personal Information Card
  Widget _buildPersonalInformationCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _profileCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _profileBorder),
        boxShadow: _profileShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              color: const Color(0xFF10264A),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          _personalInfoRow(
            icon: LucideIcons.userRound,
            label: 'Full name',
            value: _name,
          ),
          const Divider(color: Color(0xFFEAF1FA), height: 18, thickness: 0.8),
          _personalInfoRow(
            icon: LucideIcons.mail,
            label: 'Email address',
            value: _email,
          ),
          const Divider(color: Color(0xFFEAF1FA), height: 18, thickness: 0.8),
          _personalInfoRow(
            icon: LucideIcons.phone,
            label: 'Phone number',
            value: _phone,
          ),
          const Divider(color: Color(0xFFEAF1FA), height: 18, thickness: 0.8),
          _personalInfoRow(
            icon: LucideIcons.calendar,
            label: 'Date of birth',
            value: _dob,
          ),
          const Divider(color: Color(0xFFEAF1FA), height: 18, thickness: 0.8),
          _personalInfoRow(
            icon: LucideIcons.mapPin,
            label: 'Address',
            value: _address,
          ),
        ],
      ),
    );
  }

  Widget _personalInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _profileBlueLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: _profileBlue, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: _profileTextSecondary,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color: const Color(0xFF10264A),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Card 5: Identity Verification Card
  Widget _buildIdentityVerificationCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _profileCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _profileBorder),
        boxShadow: _profileShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Identity Verification',
                  style: TextStyle(
                    color: const Color(0xFF10264A),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => setState(() => _selectedTabIndex = 2),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: _profileBlueLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _profileBlueBorder),
                  ),
                  child: const Text(
                    'View all',
                    style: TextStyle(
                      color: _profileBlueDark,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _verificationItemCard(
            icon: LucideIcons.idCard,
            title: 'Identity Proof',
          ),
          const SizedBox(height: 10),
          _verificationItemCard(
            icon: LucideIcons.house,
            title: 'Address Proof',
          ),
        ],
      ),
    );
  }

  Widget _verificationItemCard({
    required IconData icon,
    required String title,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDCE5F1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: _profileBlueLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _profileBlue, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: const Color(0xFF10264A),
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _profileGreenLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _profileGreenBorder,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.check, size: 12, color: _profileGreen),
                SizedBox(width: 4),
                Text(
                  'Verified',
                  style: TextStyle(
                    color: _profileGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Card 6: Payment Methods Card
  Widget _buildPaymentMethodsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _profileCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _profileBorder),
        boxShadow: _profileShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Payment Methods',
                  style: TextStyle(
                    color: const Color(0xFF10264A),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _showPaymentMethodsSheet,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: _profileBlueLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _profileBlueBorder),
                  ),
                  child: const Text(
                    'Manage',
                    style: TextStyle(
                      color: _profileBlueDark,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _paymentMethodTile(
            icon: LucideIcons.landmark,
            iconColor: _profileBlue,
            iconBg: _profileBlueLight,
            title: 'Bank Account',
            subtitle: '****3456',
            onTap: _showBankDetailsSheet,
          ),
          const SizedBox(height: 10),
          _paymentMethodTile(
            icon: LucideIcons.wallet,
            iconColor: _profileGold,
            iconBg: _profileGoldLight,
            title: 'Crypto Wallet',
            subtitle: 'UNANG · 123456789asd',
            onTap: _showCryptoWalletSheet,
          ),
        ],
      ),
    );
  }

  Widget _paymentMethodTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F9FC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFDCE5F1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: const Color(0xFF10264A),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: _profileTextSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _profileGreenLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _profileGreenBorder,
                ),
              ),
              child: const Text(
                'Active',
                style: TextStyle(
                  color: _profileGreen,
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(LucideIcons.arrowUpRight, size: 16, color: _profileMuted),
          ],
        ),
      ),
    );
  }

  // Card 7: Promo / Platform Journey Card
  Widget _buildJourneyPromoCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF93C5FD)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x191D4ED8),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned.fill(
            child: CustomPaint(
              painter: PromoOrbitPainter(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Journey with VT Index',
                  style: TextStyle(
                    color: const Color(0xFF10264A),
                    fontSize: 16.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Smarter Trading   Secure Investments   Global Opportunities',
                  style: TextStyle(
                    color: Color(0xFFDBEAFE),
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10264A),
                    foregroundColor: const Color(0xFF031438),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () {
                    widget.onSelectPage('Trading Accounts');
                    _showSnack('Exploring VT Index platform features');
                  },
                  icon: const Icon(LucideIcons.arrowUpRight, size: 15, color: Color(0xFF1E3A8A)),
                  label: const Text(
                    'Explore platform',
                    style: TextStyle(
                      color: Color(0xFF1E3A8A),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBankDetailsSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Color(0xFFDCE5F1), width: 1.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0x2410264A),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Bank Account Details',
                  style: TextStyle(
                    color: const Color(0xFF10264A),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _profileGreenLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _profileGreenBorder),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(color: _profileGreen, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Linked bank account for fiat deposits and withdrawals.',
              style: TextStyle(color: _profileTextSecondary, fontSize: 12),
            ),
            const SizedBox(height: 18),
            _infoRow('Bank Name', 'State Bank of India (SBI)'),
            _infoRow('Account Number', '****3456', copyable: true),
            _infoRow('Account Holder', _name),
            _infoRow('IFSC / Routing Code', 'SBIN0001234', copyable: true),
            _infoRow('Branch Name', _bankBranch),
            _infoRow('Currency', 'INR (₹)'),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _profileBlue,
                  foregroundColor: const Color(0xFF10264A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCryptoWalletSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Color(0xFFDCE5F1), width: 1.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0x2410264A),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Crypto Wallet Details',
                  style: TextStyle(
                    color: const Color(0xFF10264A),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _profileGreenLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _profileGreenBorder),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(color: _profileGreen, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Authorized wallet address for direct USDT / crypto settlements.',
              style: TextStyle(color: _profileTextSecondary, fontSize: 12),
            ),
            const SizedBox(height: 18),
            _infoRow('Network', 'TRON (TRC20) / UNANG'),
            _infoRow('Wallet Address', 'UNANG · 123456789asd', copyable: true),
            _infoRow('Whitelist Status', 'Whitelisted & Verified', accentColor: _profileGreen),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _profileBlue,
                  foregroundColor: const Color(0xFF10264A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentMethodsSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Color(0xFFDCE5F1), width: 1.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0x2410264A),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Manage Payment Methods',
              style: TextStyle(
                color: const Color(0xFF10264A),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Add, update, or remove bank accounts and crypto wallets.',
              style: TextStyle(color: _profileTextSecondary, fontSize: 12),
            ),
            const SizedBox(height: 18),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: _profileBlueLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.landmark, color: _profileBlue, size: 20),
              ),
              title: const Text('Manage Bank Accounts', style: TextStyle(color: const Color(0xFF10264A), fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: const Text('SBI • ****3456 (Primary)', style: TextStyle(color: _profileMuted, fontSize: 11)),
              trailing: const Icon(LucideIcons.chevronRight, color: _profileMuted, size: 18),
              onTap: () {
                Navigator.pop(ctx);
                _showBankDetailsSheet();
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: _profileGoldLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.wallet, color: _profileGold, size: 20),
              ),
              title: const Text('Manage Crypto Wallets', style: TextStyle(color: const Color(0xFF10264A), fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: const Text('UNANG · 123456789asd', style: TextStyle(color: _profileMuted, fontSize: 11)),
              trailing: const Icon(LucideIcons.chevronRight, color: _profileMuted, size: 18),
              onTap: () {
                Navigator.pop(ctx);
                _showCryptoWalletSheet();
              },
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _profileBlue),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: _profileBlueLight,
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  _showSnack('Add new payment method window opened');
                },
                icon: const Icon(LucideIcons.plus, size: 18, color: _profileBlue),
                label: const Text('Add Payment Method', style: TextStyle(color: const Color(0xFF10264A), fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _completionItem({required String title, required String subtitle}) {
    return Row(
      children: [
        const Icon(
          LucideIcons.circleCheck,
          color: _profileGreen,
          size: 19,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: const Color(0xFF10264A),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _profileTextSecondary,
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: _profileGreenLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Verified',
            style: TextStyle(
              color: _profileGreen,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value, {bool copyable = false, Color? accentColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: _profileTextSecondary, fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: accentColor ?? const Color(0xFF10264A),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (copyable) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => _showSnack('$label copied to clipboard'),
                  child: const Icon(LucideIcons.copy, size: 13, color: _profileBlue),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: PERSONAL DETAILS TAB
  // ==========================================
  Widget _buildPersonalDetailsTab() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _profileCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _profileBorder),
        boxShadow: _profileShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Personal Information',
                      style: TextStyle(
                        color: const Color(0xFF10264A),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Identity data verified against official documents',
                      style: TextStyle(color: _profileTextSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF113876),
                  foregroundColor: const Color(0xFF10264A),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 1,
                ),
                onPressed: _showEditDetailsSheet,
                icon: const Icon(LucideIcons.filePenLine, size: 14, color: Color(0xFFFDE68A)),
                label: const Text(
                  'Edit Details',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFDCE5F1), thickness: 0.8),
          const SizedBox(height: 6),

          _detailCardRow(LucideIcons.user, 'Full Legal Name', _name),
          _detailCardRow(LucideIcons.calendar, 'Date of Birth', _dob),
          _detailCardRow(LucideIcons.usersRound, 'Gender', _gender),
          _detailCardRow(LucideIcons.flag, 'Nationality', _nationality),
          _detailCardRow(LucideIcons.mail, 'Email Address', _email, verified: true),
          _detailCardRow(LucideIcons.phone, 'Phone Number', _phone, verified: true),
          _detailCardRow(LucideIcons.home, 'Residential Address', _address),
          _detailCardRow(LucideIcons.mapPin, 'City & Country', _location),
          _detailCardRow(LucideIcons.briefcase, 'Occupation', _occupation),
          _detailCardRow(LucideIcons.landmark, 'Tax Residency', 'India (PAN: *****8921J)'),
        ],
      ),
    );
  }

  Widget _detailCardRow(IconData icon, String label, String value, {bool verified = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAF1FA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: _profileBlueLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: _profileBlue, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: _profileTextSecondary, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: const Color(0xFF10264A),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (verified)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _profileGreenLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.check, color: _profileGreen, size: 11),
                  SizedBox(width: 3),
                  Text(
                    'Verified',
                    style: TextStyle(
                      color: _profileGreen,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: VERIFICATION TAB
  // ==========================================
  Widget _buildVerificationTab() {
    return _VerificationTabView(
      onViewDocument: (docType) => _showDocumentViewerSheet(context, docType),
    );
  }

  void _showDocumentViewerSheet(BuildContext context, String docType) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DocumentViewerModal(documentType: docType),
    );
  }

  // ==========================================
  // TAB 4: PAYMENT METHODS TAB
  // ==========================================
  Widget _buildPaymentMethodsTab() {
    return _PaymentMethodsTabView(
      bankName: _bankName,
      bankAccountNumber: _bankAccountNumber,
      bankIfscCode: _bankIfscCode,
      bankBranch: _bankBranch,
      bankHolder: _bankHolder,
      bankStatus: _bankStatus,
      cryptoWalletAddress: _cryptoWalletAddress,
      cryptoCurrency: _cryptoCurrency,
      cryptoNetwork: _cryptoNetwork,
      cryptoStatus: _cryptoStatus,
      onViewBankDetails: () => _showPaymentDestinationDetailsSheet(
        context: context,
        title: 'Bank Account Details',
        subtitle: 'Linked bank account for fiat payouts',
        icon: LucideIcons.landmark,
        iconColor: const Color(0xFFF7F9FC),
        iconBgColor: const Color(0xFF10264A),
        status: _bankStatus,
        details: [
          _PaymentDetailItem(label: 'Bank Name', value: _bankName),
          _PaymentDetailItem(label: 'Account Number', value: _bankAccountNumber, copyable: true),
          _PaymentDetailItem(label: 'Beneficiary Name', value: _bankHolder),
          _PaymentDetailItem(label: 'IFSC / Routing Code', value: _bankIfscCode, copyable: true),
          _PaymentDetailItem(label: 'Branch Name', value: _bankBranch),
          const _PaymentDetailItem(label: 'Routing Channel', value: 'NEFT / RTGS / IMPS'),
        ],
        onEdit: () {
          Navigator.pop(context);
          _showEditBankDestinationSheet();
        },
      ),
      onEditBankDetails: _showEditBankDestinationSheet,
      onBankMenuAction: (action) {
        if (action == 'primary') {
          _showSnack('Bank Account set as primary payout destination');
        }
      },
      onViewCryptoDetails: () => _showPaymentDestinationDetailsSheet(
        context: context,
        title: 'Crypto Wallet Details',
        subtitle: 'Digital asset destination for instant withdrawals',
        icon: LucideIcons.wallet,
        iconColor: const Color(0xFF6366F1),
        iconBgColor: const Color(0xFF10264A),
        status: _cryptoStatus,
        details: [
          _PaymentDetailItem(label: 'Wallet Address', value: _cryptoWalletAddress, copyable: true),
          _PaymentDetailItem(label: 'Settlement Currency', value: _cryptoCurrency),
          _PaymentDetailItem(label: 'Network', value: _cryptoNetwork),
          const _PaymentDetailItem(label: 'Whitelist Status', value: 'Whitelisted & Approved'),
          const _PaymentDetailItem(label: 'Settlement Speed', value: 'Instant (~2 min)'),
        ],
        onEdit: () {
          Navigator.pop(context);
          _showEditCryptoDestinationSheet();
        },
      ),
      onEditCryptoDetails: _showEditCryptoDestinationSheet,
      onCryptoMenuAction: (action) {
        if (action == 'primary') {
          _showSnack('Crypto Wallet set as primary payout destination');
        }
      },
    );
  }

  void _showPaymentDestinationDetailsSheet({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String status,
    required List<_PaymentDetailItem> details,
    required VoidCallback onEdit,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PaymentDestinationDetailsModal(
        title: title,
        subtitle: subtitle,
        icon: icon,
        iconColor: iconColor,
        iconBgColor: iconBgColor,
        status: status,
        details: details,
        onEdit: onEdit,
      ),
    );
  }

  void _showEditBankDestinationSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditBankDestinationModal(
        currentBankName: _bankName,
        currentAccountNumber: _bankAccountNumber,
        currentIfscCode: _bankIfscCode,
        currentBranchName: _bankBranch,
        onSave: (name, accNum, ifsc, branch) {
          setState(() {
            _bankName = name;
            _bankAccountNumber = accNum;
            _bankIfscCode = ifsc;
            _bankBranch = branch;
          });
          _showSnack('Bank details updated successfully');
        },
      ),
    );
  }

  void _showEditCryptoDestinationSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditCryptoDestinationModal(
        currentWalletAddress: _cryptoWalletAddress,
        currentCurrency: _cryptoCurrency,
        onSave: (address, currency) {
          setState(() {
            _cryptoWalletAddress = address;
            _cryptoCurrency = currency;
          });
          _showSnack('Crypto wallet updated successfully');
        },
      ),
    );
  }
}

// ==========================================
// VERIFICATION TAB VIEW COMPONENT
// ==========================================
class _VerificationTabView extends StatelessWidget {
  const _VerificationTabView({
    required this.onViewDocument,
  });

  final ValueChanged<String> onViewDocument;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Header Section
        Center(
          child: Column(
            children: const [
              Text(
                'Verification Documents',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF10264A),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
        const SizedBox(height: 22),

        // 2. Card 1: Identity Verification (IDENTITY PROOF)
        // Verification document cards use a compact two-column phone grid.
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 0.50,
          children: [
            _VerificationDocCard(
              title: 'Identity Verification',
              badgeLabel: 'IDENTITY PROOF',
              subtitle: 'Aadhaar, PAN, passport or driving licence',
              icon: LucideIcons.idCard,
              iconBgColor: const Color(0xFFF7F9FC),
              iconColor: const Color(0xFF4988E8),
              badgeTagColor: const Color(0xFF4988E8),
              isIdentity: true,
              onViewDocument: () => onViewDocument('Identity Verification'),
            ),
            _VerificationDocCard(
              title: 'Address Verification',
              badgeLabel: 'ADDRESS PROOF',
              subtitle: 'Bank statement or utility bill',
              icon: LucideIcons.house,
              iconBgColor: const Color(0xFFF3E8FF),
              iconColor: const Color(0xFF7C3AED),
              badgeTagColor: _profileBlueDark,
              isIdentity: false,
              onViewDocument: () => onViewDocument('Address Verification'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 4. Security / Privacy Footer Card
        _buildSecurityPrivacyFooter(),
      ],
    );
  }

  Widget _buildSecurityPrivacyFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _profileCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _profileBorder, width: 1.2),
        boxShadow: _profileShadow,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 450;
          final badge = Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _profileBlueLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _profileBlueBorder),
            ),
            child: const Text(
              'Secure document access',
              style: TextStyle(
                color: _profileBlueDark,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F9FC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(LucideIcons.lock, color: _profileBlue, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Your documents stay protected.',
                          style: TextStyle(
                            color: const Color(0xFF10264A),
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'You must verify your CRM password before viewing a document.',
                          style: TextStyle(
                            color: Color(0xFF62738E),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isCompact) ...[
                    const SizedBox(width: 12),
                    badge,
                  ],
                ],
              ),
              if (isCompact) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: badge,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

// ==========================================
// VERIFICATION DOCUMENT CARD WIDGET
// ==========================================
class _VerificationDocCard extends StatelessWidget {
  const _VerificationDocCard({
    required this.title,
    required this.badgeLabel,
    required this.subtitle,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.badgeTagColor,
    required this.isIdentity,
    required this.onViewDocument,
  });

  final String title;
  final String badgeLabel;
  final String subtitle;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final Color badgeTagColor;
  final bool isIdentity;
  final VoidCallback onViewDocument;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _profileBorder),
        boxShadow: _profileShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const Spacer(),
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: _profileGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              const Flexible(
                child: Text(
                  'Approved',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _profileGreen,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _profileNavy,
              fontSize: 13,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            badgeLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: badgeTagColor,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 9),
          Expanded(
            child: Text(
              subtitle,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _profileMuted,
                fontSize: 11,
                height: 1.35,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
            decoration: BoxDecoration(
              color: _profileBg,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: _profileBorder),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(LucideIcons.fileText, size: 16, color: _profileBlue),
                SizedBox(height: 5),
                Text(
                  'Document file',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _profileMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'PDF / IMAGE',
                  style: TextStyle(
                    color: _profileBlueDark,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              const Icon(
                LucideIcons.shieldCheck,
                color: _profileGreen,
                size: 14,
              ),
              const SizedBox(width: 5),
              const Expanded(
                child: Text(
                  'Verification complete',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _profileNavy,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onViewDocument,
              style: OutlinedButton.styleFrom(
                foregroundColor: _profileBlueDark,
                side: const BorderSide(color: _profileBlueBorder),
                padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
                minimumSize: const Size(0, 34),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              child: const Text(
                'View document',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentViewerModal extends StatefulWidget {
  const _DocumentViewerModal({required this.documentType});

  final String documentType;

  @override
  State<_DocumentViewerModal> createState() => _DocumentViewerModalState();
}

class _DocumentViewerModalState extends State<_DocumentViewerModal> {
  bool _passwordVerified = true;
  final TextEditingController _passwordController = TextEditingController(text: '••••••••');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIdentity = widget.documentType.contains('Identity');
    final docTitle = isIdentity ? 'Identity Verification' : 'Address Verification';
    final docBadge = isIdentity ? 'IDENTITY PROOF' : 'ADDRESS PROOF';
    final docTypeDetail = isIdentity
        ? 'National ID Card (Aadhaar / Passport)'
        : 'Official Bank Statement / Utility Bill';
    final docRef = isIdentity ? 'IND-****7842' : 'REF-ADDR-2024-819';
    final docScore = isIdentity ? '96% (Auto-Approved >80%)' : '92% (Auto-Approved >80%)';
    final docComparison = isIdentity
        ? 'Name & Date of Birth matched with profile'
        : 'Name & Complete Profile Address matched';

    return Container(
      padding: EdgeInsets.fromLTRB(20, 14, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
        color: Color(0xFFF7F9FC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: Color(0xFFEAF1FA), width: 1.5)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isIdentity ? const Color(0xFFF7F9FC) : const Color(0xFF221752),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isIdentity ? LucideIcons.idCard : LucideIcons.house,
                    color: isIdentity ? _profileBlue : const Color(0xFF7C3AED),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        docTitle,
                        style: const TextStyle(
                          color: const Color(0xFF10264A),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        docBadge,
                        style: const TextStyle(
                          color: _profileBlueDark,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _profileGreenLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _profileGreenBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: _profileGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'Approved',
                        style: TextStyle(
                          color: _profileGreen,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(LucideIcons.x, color: Color(0xFF62738E), size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Password Prompt Simulation Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _passwordVerified ? const Color(0xFF1B6A41) : const Color(0xFFDCE5F1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _passwordVerified
                              ? const Color(0xFF0C3925)
                              : const Color(0xFFF7F9FC),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _passwordVerified ? LucideIcons.shieldCheck : LucideIcons.lock,
                          size: 16,
                          color: _passwordVerified
                              ? _profileGreen
                              : _profileBlue,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'CRM Password Authentication',
                          style: TextStyle(
                            color: const Color(0xFF10264A),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _passwordVerified
                              ? _profileGreenLight
                              : _profileBorder,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _passwordVerified ? 'Verified' : 'Required',
                          style: TextStyle(
                            color: _passwordVerified
                                ? const Color(0xFF22C55E)
                                : const Color(0xFF62738E),
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _passwordVerified
                        ? 'Your CRM identity password was successfully verified. Full document decrypt key active for this session.'
                        : 'Confirm your CRM password to decrypt and view confidential document files.',
                    style: const TextStyle(
                      color: Color(0xFF62738E),
                      fontSize: 11.5,
                      height: 1.35,
                    ),
                  ),
                  if (!_passwordVerified) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(color: const Color(0xFF10264A), fontSize: 13),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFF7F9FC),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              hintText: 'Enter CRM password',
                              hintStyle: const TextStyle(color: _profileMuted, fontSize: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFDCE5F1)),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                                  size: 16,
                                  color: const Color(0xFF62738E),
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => setState(() => _passwordVerified = true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _profileBlue,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Verify', style: TextStyle(color: const Color(0xFF10264A), fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Document Details & Metadata
            const Text(
              'Document Details & Metadata',
              style: TextStyle(
                color: const Color(0xFF10264A),
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _profileBorder),
              ),
              child: Column(
                children: [
                  _metaRow('Document Type', docTypeDetail),
                  const Divider(color: Color(0xFFF7F9FC), height: 16),
                  _metaRow('Document Number', docRef),
                  const Divider(color: Color(0xFFF7F9FC), height: 16),
                  _metaRow('AI Matching Score', docScore),
                  const Divider(color: Color(0xFFF7F9FC), height: 16),
                  _metaRow('Comparison Result', docComparison),
                  const Divider(color: Color(0xFFF7F9FC), height: 16),
                  _metaRow('Storage Vault', 'AES-256 Protected & Tamper Sealed'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Visual document preview box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _profileBorder),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isIdentity ? LucideIcons.idCard : LucideIcons.fileSpreadsheet,
                            color: _profileBlue,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isIdentity ? 'identity_document_verified.pdf' : 'address_statement_verified.pdf',
                            style: const TextStyle(
                              color: _profileText,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        '1.8 MB',
                        style: TextStyle(color: Color(0xFF62738E), fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    height: 90,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F9FC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFEAF1FA)),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(LucideIcons.shieldCheck, color: _profileGreen, size: 26),
                          SizedBox(height: 6),
                          Text(
                            'CONFIDENTIAL • VERIFIED BY CRM SYSTEM',
                            style: TextStyle(
                              color: _profileBlueDark,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF7F9FC),
                  foregroundColor: const Color(0xFF10264A),
                  side: const BorderSide(color: Color(0xFFDCE5F1)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                ),
                child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF62738E), fontSize: 11.5),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: const Color(0xFF10264A),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _BannerOptionTile extends StatelessWidget {
  const _BannerOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF103670) : const Color(0xFFF4F7FC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _profileGold : const Color(0xFFDCE5F1),
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? _profileBlue : _profileTextSecondary, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: const Color(0xFF10264A),
                      fontSize: 12.5,
                      fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: _profileTextSecondary, fontSize: 10.5),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(LucideIcons.circleCheck, color: _profileBlue, size: 18),
          ],
        ),
      ),
    );
  }
}

/// Custom painter rendering a celestial / mountain landscape banner.
class _ProfileCoverPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final background = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFEAF3FF),
          Color(0xFFBBD9FF),
          Color(0xFF4C9AF5),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds);
    canvas.drawRect(bounds, background);

    final paleWave = Path()
      ..moveTo(0, size.height * 0.58)
      ..cubicTo(
        size.width * 0.18, size.height * 0.10,
        size.width * 0.34, size.height * 0.88,
        size.width * 0.57, size.height * 0.48,
      )
      ..cubicTo(
        size.width * 0.76, size.height * 0.12,
        size.width * 0.84, size.height * 0.02,
        size.width, size.height * 0.22,
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(
      paleWave,
      Paint()..color = Colors.white.withValues(alpha: 0.48),
    );

    final whiteWave = Path()
      ..moveTo(0, size.height * 0.78)
      ..cubicTo(
        size.width * 0.22, size.height * 0.40,
        size.width * 0.40, size.height * 0.98,
        size.width * 0.62, size.height * 0.62,
      )
      ..cubicTo(
        size.width * 0.80, size.height * 0.34,
        size.width * 0.90, size.height * 0.46,
        size.width, size.height * 0.66,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      whiteWave,
      Paint()..color = Colors.white.withValues(alpha: 0.62),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CelestialBannerPainter extends CustomPainter {
  const CelestialBannerPainter({required this.theme});

  final String theme;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Theme-dependent Sky Gradient
    final Gradient skyGradient;
    if (theme == 'Deep Ocean Aurora') {
      skyGradient = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF0369A1),
          Color(0xFF0284C7),
          Color(0xFF0EA5E9),
          Color(0xFF1E3A8A),
        ],
      );
    } else if (theme == 'Astral Cyber Gold') {
      skyGradient = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF92400E),
          Color(0xFFD97706),
          Color(0xFFF59E0B),
          Color(0xFF1E3A8A),
        ],
      );
    } else {
      // Cosmic Landscape (Default) - Royal Blue & Sapphire
      skyGradient = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF172554),
          Color(0xFF1E3A8A),
          Color(0xFF1D4ED8),
          Color(0xFF2563EB),
        ],
      );
    }

    final skyPaint = Paint()..shader = skyGradient.createShader(rect);
    canvas.drawRect(rect, skyPaint);

    // Stars & constellations
    final starPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;

    final starPositions = [
      const Offset(0.08, 0.15),
      const Offset(0.14, 0.28),
      const Offset(0.22, 0.12),
      const Offset(0.28, 0.35),
      const Offset(0.35, 0.18),
      const Offset(0.42, 0.08),
      const Offset(0.48, 0.22),
      const Offset(0.55, 0.14),
      const Offset(0.62, 0.30),
      const Offset(0.68, 0.10),
      const Offset(0.72, 0.42),
      const Offset(0.85, 0.12),
      const Offset(0.90, 0.25),
      const Offset(0.94, 0.38),
      const Offset(0.18, 0.45),
      const Offset(0.32, 0.52),
      const Offset(0.52, 0.48),
      const Offset(0.65, 0.55),
    ];

    for (int i = 0; i < starPositions.length; i++) {
      final pos = starPositions[i];
      final starOffset = Offset(pos.dx * size.width, pos.dy * size.height);
      final radius = (i % 3 == 0) ? 2.2 : (i % 2 == 0 ? 1.5 : 1.0);
      final alpha = (i % 3 == 0) ? 0.90 : 0.65;

      starPaint.color = const Color(0xFF10264A).withValues(alpha: alpha);
      canvas.drawCircle(starOffset, radius, starPaint);

      // Star sparkle cross on prominent stars
      if (i % 4 == 0) {
        final crossPaint = Paint()
          ..color = const Color(0xFF10264A).withValues(alpha: 0.6)
          ..strokeWidth = 0.8;
        canvas.drawLine(
          Offset(starOffset.dx - 4, starOffset.dy),
          Offset(starOffset.dx + 4, starOffset.dy),
          crossPaint,
        );
        canvas.drawLine(
          Offset(starOffset.dx, starOffset.dy - 4),
          Offset(starOffset.dx, starOffset.dy + 4),
          crossPaint,
        );
      }
    }

    // Mountain silhouettes in background
    final mountainPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF1E3A8A).withValues(alpha: 0.85),
          const Color(0xFF0F172A),
        ],
      ).createShader(rect);

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.75)
      ..lineTo(size.width * 0.20, size.height * 0.55)
      ..lineTo(size.width * 0.45, size.height * 0.70)
      ..lineTo(size.width * 0.70, size.height * 0.48)
      ..lineTo(size.width * 0.88, size.height * 0.65)
      ..lineTo(size.width, size.height * 0.52)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, mountainPaint);
  }

  @override
  bool shouldRepaint(covariant CelestialBannerPainter oldDelegate) =>
      oldDelegate.theme != theme;
}

class PromoOrbitPainter extends CustomPainter {
  const PromoOrbitPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1E3A8A),
          Color(0xFF1D4ED8),
          Color(0xFF2563EB),
        ],
      ).createShader(rect);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(20)), bgPaint);

    // Glowing orbital arcs
    final arcCenter = Offset(size.width * 0.88, size.height * 0.35);
    final arcPaint = Paint()
      ..color = const Color(0xFF93C5FD).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawArc(
      Rect.fromCircle(center: arcCenter, radius: size.width * 0.40),
      math.pi * 0.6,
      math.pi * 0.9,
      false,
      arcPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: arcCenter, radius: size.width * 0.25),
      math.pi * 0.4,
      math.pi * 0.8,
      false,
      arcPaint..color = const Color(0xFFFDE68A).withValues(alpha: 0.4),
    );

    // Light radial glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF60A5FA).withValues(alpha: 0.3),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: arcCenter, radius: 80));
    canvas.drawCircle(arcCenter, 80, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ==========================================
// PAYMENT METHODS TAB VIEW COMPONENT
// ==========================================
class _PaymentMethodsTabView extends StatelessWidget {
  const _PaymentMethodsTabView({
    required this.bankName,
    required this.bankAccountNumber,
    required this.bankIfscCode,
    required this.bankBranch,
    required this.bankHolder,
    required this.bankStatus,
    required this.cryptoWalletAddress,
    required this.cryptoCurrency,
    required this.cryptoNetwork,
    required this.cryptoStatus,
    required this.onViewBankDetails,
    required this.onEditBankDetails,
    required this.onBankMenuAction,
    required this.onViewCryptoDetails,
    required this.onEditCryptoDetails,
    required this.onCryptoMenuAction,
  });

  final String bankName;
  final String bankAccountNumber;
  final String bankIfscCode;
  final String bankBranch;
  final String bankHolder;
  final String bankStatus;

  final String cryptoWalletAddress;
  final String cryptoCurrency;
  final String cryptoNetwork;
  final String cryptoStatus;

  final VoidCallback onViewBankDetails;
  final VoidCallback onEditBankDetails;
  final ValueChanged<String> onBankMenuAction;
  final VoidCallback onViewCryptoDetails;
  final VoidCallback onEditCryptoDetails;
  final ValueChanged<String> onCryptoMenuAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Payment Methods',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _profileNavy,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 18),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 0.46,
          children: [
            _buildBankCard(context),
            _buildCryptoCard(context),
          ],
        ),
        const SizedBox(height: 16),
        _buildSecurityFooter(),
      ],
    );
  }

  Widget _buildBankCard(BuildContext context) {
    return _paymentGridCard(
      icon: LucideIcons.landmark,
      iconColor: _profileBlue,
      title: 'Bank Account',
      status: bankStatus,
      description: 'Bank-based withdrawals and payouts',
      details: [
        _paymentGridDetail('Bank', bankName),
        _paymentGridDetail('Account', bankAccountNumber),
        _paymentGridDetail('IFSC', bankIfscCode),
        _paymentGridDetail('Branch', bankBranch),
      ],
      onView: onViewBankDetails,
      onEdit: onEditBankDetails,
      onMenu: onBankMenuAction,
    );
  }

  Widget _buildCryptoCard(BuildContext context) {
    return _paymentGridCard(
      icon: LucideIcons.wallet,
      iconColor: _profileGold,
      title: 'Crypto Wallet',
      status: cryptoStatus,
      description: 'Digital asset withdrawal destination',
      details: [
        _paymentGridDetail('Wallet', cryptoWalletAddress),
        _paymentGridDetail('Currency', cryptoCurrency),
        _paymentGridDetail('Network', cryptoNetwork),
      ],
      onView: onViewCryptoDetails,
      onEdit: onEditCryptoDetails,
      onMenu: onCryptoMenuAction,
    );
  }

  Widget _paymentGridCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String status,
    required String description,
    required List<Widget> details,
    required VoidCallback onView,
    required VoidCallback onEdit,
    required ValueChanged<String> onMenu,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _profileBorder),
        boxShadow: _profileShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _profileBlueLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const Spacer(),
              _buildEllipsisMenu(onMenu),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _profileNavy,
              fontSize: 13,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          _connectedBadge(status),
          const SizedBox(height: 8),
          Text(
            description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _profileMuted,
              fontSize: 10,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: details,
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onView,
              style: OutlinedButton.styleFrom(
                foregroundColor: _profileBlueDark,
                side: const BorderSide(color: _profileBlueBorder),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              child: const Text(
                'View details',
                maxLines: 1,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onEdit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _profileBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              child: const Text(
                'Edit details',
                maxLines: 1,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentGridDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _profileMuted,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _profileNavy,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _profileCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _profileBorder, width: 1.2),
        boxShadow: _profileShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _profileBlueBorder),
            ),
            child: const Icon(
              LucideIcons.shieldCheck,
              color: _profileBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Keep your destinations up to date.',
                  style: TextStyle(
                    color: const Color(0xFF10264A),
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Always double-check account and wallet details before saving changes.',
                  style: TextStyle(
                    color: Color(0xFF62738E),
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _connectedBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
      decoration: BoxDecoration(
        color: _profileGreenLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _profileGreenBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: _profileGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            status,
            style: const TextStyle(
              color: _profileGreen,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEllipsisMenu(ValueChanged<String> onAction) {
    return PopupMenuButton<String>(
      icon: const Icon(LucideIcons.ellipsis, color: Color(0xFF62738E), size: 20),
      tooltip: 'Options',
      color: const Color(0xFFF7F9FC),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFDCE5F1)),
      ),
      onSelected: onAction,
      itemBuilder: (context) => [
        const PopupMenuItem<String>(
          value: 'primary',
          child: Row(
            children: [
              Icon(LucideIcons.star, size: 16, color: Color(0xFFF4C84A)),
              SizedBox(width: 10),
              Text('Set as primary', style: TextStyle(color: const Color(0xFF10264A), fontSize: 13)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'refresh',
          child: Row(
            children: [
              Icon(LucideIcons.refreshCw, size: 16, color: Color(0xFF4988E8)),
              SizedBox(width: 10),
              Text('Refresh status', style: TextStyle(color: const Color(0xFF10264A), fontSize: 13)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'copy',
          child: Row(
            children: [
              Icon(LucideIcons.copy, size: 16, color: Color(0xFF62738E)),
              SizedBox(width: 10),
              Text('Copy details', style: TextStyle(color: const Color(0xFF10264A), fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _detailRow({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF62738E),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: const Color(0xFF10264A),
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionButtons({
    required VoidCallback onView,
    required VoidCallback onEdit,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 450;
        final viewBtn = OutlinedButton.icon(
          onPressed: onView,
          icon: const Icon(LucideIcons.eye, color: _profileBlue, size: 16),
          label: const Text(
            'View Details',
            style: TextStyle(
              color: _profileBlue,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: const Color(0xFFF7F9FC),
            side: const BorderSide(color: Color(0xFFEAF1FA)),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        final editBtn = ElevatedButton.icon(
          onPressed: onEdit,
          icon: const Icon(LucideIcons.penLine, color: const Color(0xFF10264A), size: 16),
          label: const Text(
            'Edit Details',
            style: TextStyle(
              color: const Color(0xFF10264A),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1D4ED8),
            foregroundColor: const Color(0xFF10264A),
            elevation: 1.5,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              viewBtn,
              const SizedBox(height: 10),
              editBtn,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: viewBtn),
            const SizedBox(width: 12),
            Expanded(child: editBtn),
          ],
        );
      },
    );
  }
}

// ------------------------------------------
// 3D/ISOMETRIC GRAPHIC ELEMENTS
// ------------------------------------------

class _IsometricBankGraphic extends StatelessWidget {
  const _IsometricBankGraphic();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFEFF6FF),
            Color(0xFFDBEAFE),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFEAF1FA), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F2563EB),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _IsometricBankPainter(),
      ),
    );
  }
}

class _IsometricBankPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Pediment / Roof 3D
    final frontPediment = Path()
      ..moveTo(w * 0.48, h * 0.12)
      ..lineTo(w * 0.18, h * 0.40)
      ..lineTo(w * 0.78, h * 0.40)
      ..close();

    final pedimentPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(frontPediment, pedimentPaint);

    // Roof isometric side facet (depth)
    final roofDepth = Path()
      ..moveTo(w * 0.48, h * 0.12)
      ..lineTo(w * 0.64, h * 0.04)
      ..lineTo(w * 0.90, h * 0.32)
      ..lineTo(w * 0.78, h * 0.40)
      ..close();

    final depthPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(roofDepth, depthPaint);

    // Architrave (eaves bar)
    final architrave = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.14, h * 0.40, w * 0.68, h * 0.08),
      const Radius.circular(2),
    );
    final eavePaint = Paint()..color = const Color(0xFF60A5FA);
    canvas.drawRRect(architrave, eavePaint);

    // 3 Classical Columns / Pillars
    final pillarPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF93C5FD), Color(0xFF1D4ED8)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final colW = w * 0.10;
    final colH = h * 0.28;
    final colY = h * 0.48;

    // Column 1
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.20, colY, colW, colH), const Radius.circular(1.5)),
      pillarPaint,
    );
    // Column 2
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.43, colY, colW, colH), const Radius.circular(1.5)),
      pillarPaint,
    );
    // Column 3
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.66, colY, colW, colH), const Radius.circular(1.5)),
      pillarPaint,
    );

    // Plinth / Foundation Base
    final plinth = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.12, h * 0.76, w * 0.72, h * 0.10),
      const Radius.circular(2),
    );
    final plinthPaint = Paint()..color = const Color(0xFF1E3A8A);
    canvas.drawRRect(plinth, plinthPaint);

    // Golden accent dot on pediment
    final goldPaint = Paint()..color = const Color(0xFFF59E0B);
    canvas.drawCircle(Offset(w * 0.48, h * 0.28), 2.5, goldPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _IsometricCryptoGraphic extends StatelessWidget {
  const _IsometricCryptoGraphic();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFFBEB),
            Color(0xFFFEF3C7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: _profileGoldBorder, width: 1.1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0FD97706),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Isometric rotated crypto card
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.002)
              ..rotateZ(-0.15)
              ..rotateX(0.1),
            child: Container(
              width: 48,
              height: 30,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF93C5FD), width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x26000000),
                    blurRadius: 4,
                    offset: Offset(1, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Metallic gold chip
                  Container(
                    width: 7,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCD34D),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  // Abstract card stripes
                  Row(
                    children: [
                      Container(
                        width: 14,
                        height: 2,
                        decoration: BoxDecoration(
                          color: const Color(0xFFBFDBFE),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      const SizedBox(width: 3),
                      Container(
                        width: 8,
                        height: 2,
                        decoration: BoxDecoration(
                          color: const Color(0xFF60A5FA),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Overlapping glowing gold coin badge peeking at bottom right
          Positioned(
            right: 6,
            bottom: 6,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFDE68A), Color(0xFFD97706)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: const Color(0xFFFEF3C7), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  LucideIcons.coins,
                  size: 11,
                  color: Color(0xFF78350F),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------
// PAYMENT METHOD MODALS
// ------------------------------------------

class _PaymentDetailItem {
  const _PaymentDetailItem({
    required this.label,
    required this.value,
    this.copyable = false,
  });

  final String label;
  final String value;
  final bool copyable;
}

class _PaymentDestinationDetailsModal extends StatelessWidget {
  const _PaymentDestinationDetailsModal({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.status,
    required this.details,
    required this.onEdit,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String status;
  final List<_PaymentDetailItem> details;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: Color(0xFFDCE5F1), width: 1.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0x2410264A),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header Row
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: const Color(0xFF10264A),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF62738E),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _profileGreenLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _profileGreenBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: _profileGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: const TextStyle(
                        color: _profileGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Details List
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF7F9FC)),
            ),
            child: Column(
              children: [
                for (var i = 0; i < details.length; i++) ...[
                  if (i > 0)
                    const Divider(color: Color(0xFFF7F9FC), height: 16, thickness: 1),
                  _modalDetailRow(context, details[i]),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFEAF1FA)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close', style: TextStyle(color: const Color(0xFF10264A), fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D4ED8),
                    foregroundColor: const Color(0xFF10264A),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 1,
                  ),
                  onPressed: onEdit,
                  icon: const Icon(LucideIcons.penLine, size: 16),
                  label: const Text('Edit Details', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _modalDetailRow(BuildContext context, _PaymentDetailItem item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            item.label,
            style: const TextStyle(
              color: Color(0xFF62738E),
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  item.value,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: const Color(0xFF10264A),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (item.copyable) ...[
                const SizedBox(width: 6),
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${item.label} copied to clipboard'),
                        backgroundColor: const Color(0xFFFFFFFF),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: Color(0xFFDCE5F1)),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(LucideIcons.copy, size: 14, color: _profileBlue),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _EditBankDestinationModal extends StatefulWidget {
  const _EditBankDestinationModal({
    required this.currentBankName,
    required this.currentAccountNumber,
    required this.currentIfscCode,
    required this.currentBranchName,
    required this.onSave,
  });

  final String currentBankName;
  final String currentAccountNumber;
  final String currentIfscCode;
  final String currentBranchName;
  final void Function(String name, String accNum, String ifsc, String branch) onSave;

  @override
  State<_EditBankDestinationModal> createState() => _EditBankDestinationModalState();
}

class _EditBankDestinationModalState extends State<_EditBankDestinationModal> {
  late final TextEditingController _nameController;
  late final TextEditingController _accountController;
  late final TextEditingController _ifscController;
  late final TextEditingController _branchController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentBankName);
    _accountController = TextEditingController(text: widget.currentAccountNumber);
    _ifscController = TextEditingController(text: widget.currentIfscCode);
    _branchController = TextEditingController(text: widget.currentBranchName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _accountController.dispose();
    _ifscController.dispose();
    _branchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: const BoxDecoration(
          color: _profileCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: _profileSheetShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dark Navy / Blue Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF1D4ED8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Bank Details',
                    style: TextStyle(
                      color: const Color(0xFF10264A),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10264A).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF10264A).withValues(alpha: 0.18),
                          width: 1.2,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          LucideIcons.x,
                          color: const Color(0xFF10264A),
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Modal Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Banner Card
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _profileBlueLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            LucideIcons.landmark,
                            color: _profileBlue,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bank account information',
                                style: TextStyle(
                                  color: _profileText,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Enter the account details you want to use for payouts.',
                                style: TextStyle(
                                  color: _profileTextSecondary,
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: _profileBorder, thickness: 1, height: 1),
                    const SizedBox(height: 16),

                    // 4 Form Input Fields
                    _inputField(label: 'Bank name', controller: _nameController),
                    const SizedBox(height: 14),
                    _inputField(label: 'Account number', controller: _accountController),
                    const SizedBox(height: 14),
                    _inputField(label: 'IFSC code', controller: _ifscController),
                    const SizedBox(height: 14),
                    _inputField(label: 'Branch name', controller: _branchController),
                    const SizedBox(height: 18),

                    // Info Note Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: _profileBlueLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _profileBlueBorder, width: 1),
                      ),
                      child: const Row(
                        children: [
                          Icon(LucideIcons.shieldCheck, color: _profileBlue, size: 18),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Check your bank details carefully before saving.',
                              style: TextStyle(
                                color: _profileBlueDark,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Action Button: Save bank details ↗
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF143878),
                          foregroundColor: const Color(0xFF10264A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 1,
                        ),
                        onPressed: _handleSave,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Save bank details',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF10264A),
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(LucideIcons.arrowUpRight, size: 16, color: const Color(0xFF10264A)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSave() {
    final name = _nameController.text.trim();
    final acc = _accountController.text.trim();
    final ifsc = _ifscController.text.trim();
    final branch = _branchController.text.trim();
    if (name.isNotEmpty && acc.isNotEmpty && ifsc.isNotEmpty && branch.isNotEmpty) {
      widget.onSave(name, acc, ifsc, branch);
      Navigator.pop(context);
    }
  }

  Widget _inputField({required String label, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF475569),
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(color: _profileText, fontSize: 14, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: const Color(0xFF10264A),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _profileBlue, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _EditCryptoDestinationModal extends StatefulWidget {
  const _EditCryptoDestinationModal({
    required this.currentWalletAddress,
    required this.currentCurrency,
    required this.onSave,
  });

  final String currentWalletAddress;
  final String currentCurrency;
  final void Function(String address, String currency) onSave;

  @override
  State<_EditCryptoDestinationModal> createState() => _EditCryptoDestinationModalState();
}

class _EditCryptoDestinationModalState extends State<_EditCryptoDestinationModal> {
  late final TextEditingController _addressController;
  late final TextEditingController _currencyController;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(text: widget.currentWalletAddress);
    _currencyController = TextEditingController(text: widget.currentCurrency);
  }

  @override
  void dispose() {
    _addressController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: Color(0xFFDCE5F1), width: 1.5)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0x2410264A),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Edit Crypto Wallet',
              style: TextStyle(
                color: const Color(0xFF10264A),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Update your cryptocurrency destination address and currency.',
              style: TextStyle(color: Color(0xFF62738E), fontSize: 12),
            ),
            const SizedBox(height: 18),
            _inputField(label: 'Wallet Address', controller: _addressController),
            const SizedBox(height: 12),
            _inputField(label: 'Currency', controller: _currencyController),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFEAF1FA)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: const Color(0xFF10264A), fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D4ED8),
                      foregroundColor: const Color(0xFF10264A),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 1,
                    ),
                    onPressed: () {
                      final addr = _addressController.text.trim();
                      final curr = _currencyController.text.trim();
                      if (addr.isNotEmpty && curr.isNotEmpty) {
                        widget.onSave(addr, curr);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField({required String label, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF62738E),
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(color: const Color(0xFF10264A), fontSize: 14),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: const Color(0xFFF7F9FC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFF7F9FC)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFF7F9FC)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _profileBlue, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
