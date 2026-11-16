import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

const _profileNavy = Color(0xFF06163B);
const _profilePanel = Color(0xFF0B2452);
const _profileBorder = Color(0xFF174783);
const _profileMuted = Color(0xFFA9B9D5);
const _profileBlue = Color(0xFF0875F5);
const _profileGold = Color(0xFFF4C84A);
const _profileGreen = Color(0xFF16A34A);

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
  int _selectedTabIndex = 0; // 0: Overview, 1: Personal Details, 2: Verification

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

  void _showChangeBannerSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: const BoxDecoration(
          color: Color(0xFF071B42),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Color(0xFF1D4D8F), width: 1.5)),
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
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Customize Profile Banner',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Select a cosmic theme or upload a custom panoramic banner image.',
              style: TextStyle(color: _profileMuted, fontSize: 12),
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
              height: 44,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _profileBlue),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  _showSnack('Custom banner upload is available in device gallery');
                },
                icon: const Icon(LucideIcons.imageUp, size: 18, color: _profileBlue),
                label: const Text('Upload Custom Image', style: TextStyle(color: Colors.white, fontSize: 13)),
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
          color: Color(0xFF071B42),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Color(0xFF1D4D8F), width: 1.5)),
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
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Change Profile Picture',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Take a photo, pick from gallery, or choose an avatar theme color.',
              style: TextStyle(color: _profileMuted, fontSize: 12),
            ),
            const SizedBox(height: 18),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _profileBlue.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.camera, color: _profileBlue, size: 20),
              ),
              title: const Text('Take Photo', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: const Text('Use camera for instant snapshot', style: TextStyle(color: _profileMuted, fontSize: 11)),
              trailing: const Icon(LucideIcons.chevronRight, color: _profileMuted, size: 18),
              onTap: () {
                Navigator.pop(ctx);
                _showSnack('Camera snapshot simulated');
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _profileGold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.image, color: _profileGold, size: 20),
              ),
              title: const Text('Choose from Gallery', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: const Text('Upload JPG or PNG from storage', style: TextStyle(color: _profileMuted, fontSize: 11)),
              trailing: const Icon(LucideIcons.chevronRight, color: _profileMuted, size: 18),
              onTap: () {
                Navigator.pop(ctx);
                _showSnack('Gallery file picker simulated');
              },
            ),
            const SizedBox(height: 12),
            const Text(
              'Avatar Color Accent',
              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
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
            color: selected ? Colors.white : Colors.white24,
            width: selected ? 3 : 1.5,
          ),
          boxShadow: selected
              ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 10, spreadRadius: 2)]
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
            color: Color(0xFF071B42),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: Color(0xFF1D4D8F), width: 1.5)),
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
                    color: Colors.white24,
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
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(LucideIcons.x, color: _profileMuted, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Update your personal profile and contact information.',
                style: TextStyle(color: _profileMuted, fontSize: 12),
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
                      child: const Text('Cancel', style: TextStyle(color: _profileMuted)),
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
          style: const TextStyle(color: Color(0xFFCFDCF3), fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: const Color(0xFF0B2452),
            prefixIcon: Icon(icon, color: _profileMuted, size: 18),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF174783)),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF0F326D),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _profileNavy,
      child: SafeArea(
        top: false,
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
          children: [
            // Top Navigation Bar inside Profile Page
            _buildTopNavBar(),
            const SizedBox(height: 14),

            // Hero Banner Card
            _buildHeroBannerCard(),
            const SizedBox(height: 18),

            // Tabs Selector
            _buildTabsBar(),
            const SizedBox(height: 18),

            // Tab Content
            if (_selectedTabIndex == 0)
              _buildOverviewTab()
            else if (_selectedTabIndex == 1)
              _buildPersonalDetailsTab()
            else
              _buildVerificationTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavBar() {
    return Row(
      children: [
        InkWell(
          onTap: widget.onBack,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0A204A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF174783)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.arrowLeft, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text(
                  'Back',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Account settings, verification & preferences',
                style: TextStyle(color: _profileMuted, fontSize: 10),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0x28F4C84A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0x66F4C84A)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.shieldCheck, color: _profileGold, size: 14),
              SizedBox(width: 4),
              Text(
                'Tier 3',
                style: TextStyle(
                  color: _profileGold,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroBannerCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1F4E8E), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Celestial / Cosmic / Mountain Landscape Custom Painted Background
          CustomPaint(
            size: const Size(double.infinity, 310),
            painter: CelestialBannerPainter(theme: _bannerTheme),
          ),

          // Translucent gradient overlay for depth & readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.20),
                    Colors.transparent,
                    const Color(0xFF061435).withValues(alpha: 0.85),
                    const Color(0xFF04102C),
                  ],
                  stops: const [0.0, 0.35, 0.75, 1.0],
                ),
              ),
            ),
          ),

          // Banner Top Action: "Change banner" button
          Positioned(
            top: 14,
            right: 14,
            child: InkWell(
              onTap: _showChangeBannerSheet,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.40),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.45),
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

          // Banner Hero Content (Avatar, Badge, Name, Subtitle, Contact Chips)
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 55, 18, 18),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 420;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Avatar with 3px solid white border and camera badge
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _avatarBg,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
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
                                    color: const Color(0xFFE5A93C), // Amber
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFF071B42), width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.35),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      LucideIcons.camera,
                                      size: 13,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Name Row with gold checkmark and Verified Pill Chip
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          _name,
                          style: const TextStyle(
                            color: Colors.white,
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
                            color: const Color(0x3DF4C84A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0x80F4C84A)),
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
                    const SizedBox(height: 5),

                    // Subtitle: "Client   VT Index"
                    const Text(
                      'Client   VT Index',
                      style: TextStyle(
                        color: Color(0xFFB9D5FF),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Translucent glassmorphic contact chips
                    if (isNarrow) ...[
                      _glassChip(LucideIcons.mail, _email),
                      const SizedBox(height: 6),
                      _glassChip(LucideIcons.phone, _phone),
                      const SizedBox(height: 6),
                      _glassChip(LucideIcons.mapPin, _location),
                    ] else ...[
                      // Row 1: email & phone
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _glassChip(LucideIcons.mail, _email),
                          _glassChip(LucideIcons.phone, _phone),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Row 2: location
                      _glassChip(LucideIcons.mapPin, _location),
                    ],
                  ],
                );
              },
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
        color: const Color(0x4D05122B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 0.9,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF90B8F8), size: 13),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFE2EDFF),
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
        color: const Color(0xFF07193C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF143B73)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _tabButton(
              index: 0,
              icon: LucideIcons.layoutGrid,
              label: 'Overview',
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _tabButton(
              index: 1,
              icon: LucideIcons.userRound,
              label: 'Personal Details',
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _tabButton(
              index: 2,
              icon: LucideIcons.shieldCheck,
              label: 'Verification',
            ),
          ),
        ],
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
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF0E2E66) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: active
              ? Border.all(color: _profileGold, width: 1.2)
              : Border.all(color: Colors.transparent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: active ? _profileGold : _profileMuted,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: active ? _profileGold : _profileMuted,
                  fontSize: 11,
                  fontWeight: active ? FontWeight.bold : FontWeight.w500,
                ),
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
      children: [
        // 1. Profile Completion Card
        _buildProfileCompletionCard(),
        const SizedBox(height: 16),

        // 2. Account Status Card
        _buildAccountStatusCard(),
        const SizedBox(height: 16),

        // 3. Quick Actions Card
        _buildQuickActionsCard(),
        const SizedBox(height: 16),

        // 4. Personal Information Card
        _buildPersonalInformationCard(),
        const SizedBox(height: 16),

        // 5. Identity Verification Card
        _buildIdentityVerificationCard(),
        const SizedBox(height: 16),

        // 6. Payment Methods Card
        _buildPaymentMethodsCard(),
        const SizedBox(height: 16),

        // 7. Promo / Platform Journey Card
        _buildJourneyPromoCard(),
      ],
    );
  }

  // Card 1: Profile Completion Card
  Widget _buildProfileCompletionCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _profilePanel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _profileBorder),
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
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _profileGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _profileGreen.withValues(alpha: 0.5)),
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
                        backgroundColor: Color(0xFF163E75),
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
                            color: _profileMuted,
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
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Your profile, contact details, identity and settlement methods are fully verified. All Tier-3 trading, deposits and withdrawals are active.',
                      style: TextStyle(
                        color: _profileMuted,
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
          const Divider(color: Color(0xFF174783), thickness: 0.8),
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
                side: const BorderSide(color: Color(0xFF1D549A)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: const Color(0xFF09204A),
              ),
              onPressed: () => _showSnack('Profile is 100% complete and verified'),
              icon: const Icon(LucideIcons.check, size: 16, color: _profileGreen),
              label: const Text(
                'Profile Completed',
                style: TextStyle(
                  color: Colors.white,
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
        color: _profilePanel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _profileBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account Status',
            style: TextStyle(
              color: Colors.white,
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
                  color: const Color(0xFF16A34A).withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF16A34A).withValues(alpha: 0.35),
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
                      color: Colors.white,
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
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Your account is verified and ready to access all available features.',
                      style: TextStyle(
                        color: _profileMuted,
                        fontSize: 11.5,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF16A34A).withValues(alpha: 0.4),
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
        color: _profilePanel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _profileBorder),
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
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF071E47),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF1A4985)),
                ),
                child: const Icon(LucideIcons.lock, size: 14, color: _profileMuted),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _actionTile(
            icon: LucideIcons.penLine,
            iconColor: const Color(0xFF67A6FF),
            iconBg: _profileBlue.withValues(alpha: 0.15),
            title: 'Edit Profile',
            subtitle: 'Continue profile setup',
            onTap: _showEditDetailsSheet,
          ),
          const SizedBox(height: 10),
          _actionTile(
            icon: LucideIcons.fileUp,
            iconColor: const Color(0xFF67A6FF),
            iconBg: _profileBlue.withValues(alpha: 0.15),
            title: 'Upload Documents',
            subtitle: 'Manage KYC documents',
            onTap: () => setState(() => _selectedTabIndex = 2),
          ),
          const SizedBox(height: 10),
          _actionTile(
            icon: LucideIcons.landmark,
            iconColor: const Color(0xFF67A6FF),
            iconBg: _profileBlue.withValues(alpha: 0.15),
            title: 'Bank Details',
            subtitle: 'Manage bank account',
            onTap: _showBankDetailsSheet,
          ),
          const SizedBox(height: 10),
          _actionTile(
            icon: LucideIcons.wallet,
            iconColor: const Color(0xFFF4C84A),
            iconBg: _profileGold.withValues(alpha: 0.15),
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
          color: const Color(0xFF071C44),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF174783)),
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
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: _profileMuted,
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
        color: _profilePanel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _profileBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              color: Colors.white,
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
          const Divider(color: Color(0xFF143B73), height: 18, thickness: 0.8),
          _personalInfoRow(
            icon: LucideIcons.mail,
            label: 'Email address',
            value: _email,
          ),
          const Divider(color: Color(0xFF143B73), height: 18, thickness: 0.8),
          _personalInfoRow(
            icon: LucideIcons.phone,
            label: 'Phone number',
            value: _phone,
          ),
          const Divider(color: Color(0xFF143B73), height: 18, thickness: 0.8),
          _personalInfoRow(
            icon: LucideIcons.calendar,
            label: 'Date of birth',
            value: _dob,
          ),
          const Divider(color: Color(0xFF143B73), height: 18, thickness: 0.8),
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
            color: _profileBlue.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF67A6FF), size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: _profileMuted,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
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
        color: _profilePanel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _profileBorder),
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
                    color: Colors.white,
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
                    color: const Color(0xFF0B2D62),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF2667C2)),
                  ),
                  child: const Text(
                    'View all',
                    style: TextStyle(
                      color: Color(0xFF67A6FF),
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
        color: const Color(0xFF071C44),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF174783)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: _profileBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF67A6FF), size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF16A34A).withValues(alpha: 0.4),
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
        color: _profilePanel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _profileBorder),
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
                    color: Colors.white,
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
                    color: const Color(0xFF0B2D62),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF2667C2)),
                  ),
                  child: const Text(
                    'Manage',
                    style: TextStyle(
                      color: Color(0xFF67A6FF),
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
            iconColor: const Color(0xFF67A6FF),
            iconBg: _profileBlue.withValues(alpha: 0.15),
            title: 'Bank Account',
            subtitle: '****3456',
            onTap: _showBankDetailsSheet,
          ),
          const SizedBox(height: 10),
          _paymentMethodTile(
            icon: LucideIcons.wallet,
            iconColor: const Color(0xFFF4C84A),
            iconBg: _profileGold.withValues(alpha: 0.15),
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
          color: const Color(0xFF071C44),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF174783)),
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
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: _profileMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF16A34A).withValues(alpha: 0.4),
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
        border: Border.all(color: const Color(0xFF1D549A)),
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
                    color: Colors.white,
                    fontSize: 16.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Smarter Trading   Secure Investments   Global Opportunities',
                  style: TextStyle(
                    color: Color(0xFFBBE0FF),
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
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
                  icon: const Icon(LucideIcons.arrowUpRight, size: 15, color: Color(0xFF031438)),
                  label: const Text(
                    'Explore platform',
                    style: TextStyle(
                      color: Color(0xFF031438),
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
          color: Color(0xFF071B42),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Color(0xFF1D4D8F), width: 1.5)),
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
                  color: Colors.white24,
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
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _profileGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _profileGreen.withValues(alpha: 0.4)),
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
              style: TextStyle(color: _profileMuted, fontSize: 12),
            ),
            const SizedBox(height: 18),
            _infoRow('Bank Name', 'State Bank of India (SBI)'),
            _infoRow('Account Number', '****3456', copyable: true),
            _infoRow('Account Holder', _name),
            _infoRow('IFSC / Routing Code', 'SBIN0001234', copyable: true),
            _infoRow('Currency', 'INR (₹)'),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _profileBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
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
          color: Color(0xFF071B42),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Color(0xFF1D4D8F), width: 1.5)),
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
                  color: Colors.white24,
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
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _profileGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _profileGreen.withValues(alpha: 0.4)),
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
              style: TextStyle(color: _profileMuted, fontSize: 12),
            ),
            const SizedBox(height: 18),
            _infoRow('Network', 'TRON (TRC20) / UNANG'),
            _infoRow('Wallet Address', 'UNANG · 123456789asd', copyable: true),
            _infoRow('Whitelist Status', 'Whitelisted & Verified', accentColor: _profileGreen),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _profileBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
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
          color: Color(0xFF071B42),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Color(0xFF1D4D8F), width: 1.5)),
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
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Manage Payment Methods',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Add, update, or remove bank accounts and crypto wallets.',
              style: TextStyle(color: _profileMuted, fontSize: 12),
            ),
            const SizedBox(height: 18),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _profileBlue.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.landmark, color: _profileBlue, size: 20),
              ),
              title: const Text('Manage Bank Accounts', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
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
                decoration: BoxDecoration(
                  color: _profileGold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.wallet, color: _profileGold, size: 20),
              ),
              title: const Text('Manage Crypto Wallets', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
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
              height: 44,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _profileBlue),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  _showSnack('Add new payment method window opened');
                },
                icon: const Icon(LucideIcons.plus, size: 18, color: _profileBlue),
                label: const Text('Add Payment Method', style: TextStyle(color: Colors.white, fontSize: 13)),
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
          color: Color(0xFF16A34A),
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
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _profileMuted,
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF16A34A).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Verified',
            style: TextStyle(
              color: Color(0xFF16A34A),
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
              style: const TextStyle(color: _profileMuted, fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: accentColor ?? Colors.white,
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
        color: _profilePanel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _profileBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personal Information',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Identity data verified against official documents',
                    style: TextStyle(color: _profileMuted, fontSize: 11),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF113876),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Color(0xFF2667C2)),
                  ),
                ),
                onPressed: _showEditDetailsSheet,
                icon: const Icon(LucideIcons.filePenLine, size: 14, color: _profileGold),
                label: const Text(
                  'Edit Details',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFF174783), thickness: 0.8),
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
        color: const Color(0xFF071B42),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF143B73)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: _profileBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF67A6FF), size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: _profileMuted, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
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
                color: _profileGreen.withValues(alpha: 0.15),
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
    return Column(
      children: [
        // KYC Level Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF0F3A7D), Color(0xFF0B2556)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: const Color(0xFF2764BC)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _profileGold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.shieldCheck, color: _profileGold, size: 24),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KYC Level 3: Verified',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Unlimited crypto, wire deposits and priority withdrawals active.',
                      style: TextStyle(color: Color(0xFFD4E5FF), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Verification Card 1: Identity Document
        _kycDocCard(
          icon: LucideIcons.idCard,
          title: 'Identity Document',
          docType: 'National ID Card (Aadhaar / Passport)',
          docNumber: 'IND-****7842',
          issuedDate: '15 Jan 2024',
          expiryDate: '14 Jan 2034',
          status: 'Verified',
          statusColor: _profileGreen,
          onAction: () => _showSnack('Identity Document preview loaded'),
        ),
        const SizedBox(height: 12),

        // Verification Card 2: Proof of Residence
        _kycDocCard(
          icon: LucideIcons.fileCheck2,
          title: 'Proof of Residence',
          docType: 'Official Bank Statement / Utility Bill',
          docNumber: 'REF-ADDR-2024-819',
          issuedDate: '02 Feb 2024',
          expiryDate: 'Active',
          status: 'Verified',
          statusColor: _profileGreen,
          onAction: () => _showSnack('Residence Proof document preview loaded'),
        ),
        const SizedBox(height: 12),

        // Verification Card 3: Bank Account
        _kycDocCard(
          icon: LucideIcons.landmark,
          title: 'Bank Account & Settlement',
          docType: 'State Bank of India (SBI)',
          docNumber: 'A/C: *******5621 • IFSC: SBIN0001234',
          issuedDate: 'Linked 18 Jan 2024',
          expiryDate: 'Primary Method',
          status: 'Verified',
          statusColor: _profileGreen,
          onAction: () => _showSnack('Bank account details loaded'),
        ),
        const SizedBox(height: 16),

        // Upload Additional Document Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF071B42),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF1B4E94),
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            children: [
              const Icon(LucideIcons.cloudUpload, color: _profileBlue, size: 28),
              const SizedBox(height: 8),
              const Text(
                'Upload Additional Documents',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Submit corporate authority, PEP declaration, or tax certificates if requested.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _profileMuted, fontSize: 11),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _profileBlue),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onPressed: () => _showSnack('Document upload window opened'),
                icon: const Icon(LucideIcons.plus, size: 15, color: _profileBlue),
                label: const Text('Add Document', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _kycDocCard({
    required IconData icon,
    required String title,
    required String docType,
    required String docNumber,
    required String issuedDate,
    required String expiryDate,
    required String status,
    required Color statusColor,
    required VoidCallback onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _profilePanel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _profileBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _profileBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF67A6FF), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      docType,
                      style: const TextStyle(
                        color: _profileMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.check, color: statusColor, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF07193C),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    docNumber,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFD4E5FF),
                      fontSize: 11.5,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$issuedDate • $expiryDate',
                  style: const TextStyle(
                    color: _profileMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View Details',
                      style: TextStyle(
                        color: Color(0xFF5AA5FF),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(LucideIcons.chevronRight, size: 13, color: Color(0xFF5AA5FF)),
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
          color: selected ? const Color(0xFF103670) : const Color(0xFF0A204A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _profileGold : const Color(0xFF174783),
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? _profileGold : const Color(0xFF67A6FF), size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: _profileMuted, fontSize: 10.5),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(LucideIcons.circleCheck, color: _profileGold, size: 18),
          ],
        ),
      ),
    );
  }
}

/// Custom painter rendering a cosmic/celestial/mountain landscape banner.
class CelestialBannerPainter extends CustomPainter {
  const CelestialBannerPainter({this.theme = 'Cosmic Landscape'});

  final String theme;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1. Theme-dependent Base Sky Gradient
    final Gradient skyGradient;
    if (theme == 'Deep Ocean Aurora') {
      skyGradient = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF021B2F),
          Color(0xFF043258),
          Color(0xFF064775),
          Color(0xFF0A2B4E),
          Color(0xFF031024),
        ],
      );
    } else if (theme == 'Astral Cyber Gold') {
      skyGradient = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1A1202),
          Color(0xFF382307),
          Color(0xFF1E284A),
          Color(0xFF0C193B),
          Color(0xFF030A1C),
        ],
      );
    } else {
      // Cosmic Landscape (Default)
      skyGradient = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF020716),
          Color(0xFF07193F),
          Color(0xFF0E2F6C),
          Color(0xFF143B80),
          Color(0xFF081C44),
          Color(0xFF030A1C),
        ],
      );
    }

    final skyPaint = Paint()..shader = skyGradient.createShader(rect);
    canvas.drawRect(rect, skyPaint);

    // 2. Cosmic Nebula Glow (Radial lights)
    final nebulaPaint1 = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.4, -0.6),
        radius: 0.9,
        colors: [
          const Color(0xFF2C74DE).withValues(alpha: 0.35),
          const Color(0xFF6B21A8).withValues(alpha: 0.18),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, nebulaPaint1);

    final nebulaPaint2 = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.6, -0.3),
        radius: 0.7,
        colors: [
          const Color(0xFF00E5FF).withValues(alpha: 0.22),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, nebulaPaint2);

    // 3. Celestial Orbital Ring / Planet Glow Arc
    final arcCenter = Offset(size.width * 0.78, size.height * 0.25);
    final arcPaint = Paint()
      ..color = const Color(0xFF9CC7FF).withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    canvas.drawArc(
      Rect.fromCircle(center: arcCenter, radius: size.width * 0.32),
      math.pi * 0.8,
      math.pi * 0.9,
      false,
      arcPaint,
    );

    // Planet disk glow
    final planetPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF88BCFF).withValues(alpha: 0.40),
          const Color(0xFF336FD1).withValues(alpha: 0.15),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: arcCenter, radius: 48));
    canvas.drawCircle(arcCenter, 48, planetPaint);

    // 4. Fixed Deterministic Stars (Points & Sparkles)
    final starPaint = Paint()..style = PaintingStyle.fill;
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

      starPaint.color = Colors.white.withValues(alpha: alpha);
      canvas.drawCircle(starOffset, radius, starPaint);

      // Star sparkle cross on prominent stars
      if (i % 4 == 0) {
        final crossPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.6)
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

    // 5. Mountain / Earth Horizon Silhouettes (Layer 1 - distant mountains)
    final mountainPaint1 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0F2F64).withValues(alpha: 0.70),
          const Color(0xFF081C40).withValues(alpha: 0.95),
        ],
      ).createShader(rect);

    final path1 = Path();
    path1.moveTo(0, size.height * 0.72);
    path1.quadraticBezierTo(
      size.width * 0.20,
      size.height * 0.58,
      size.width * 0.42,
      size.height * 0.68,
    );
    path1.quadraticBezierTo(
      size.width * 0.65,
      size.height * 0.52,
      size.width * 0.85,
      size.height * 0.64,
    );
    path1.quadraticBezierTo(
      size.width * 0.95,
      size.height * 0.60,
      size.width,
      size.height * 0.66,
    );
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    canvas.drawPath(path1, mountainPaint1);

    // Mountain Layer 2 - foreground sharp ridges
    final mountainPaint2 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF081734).withValues(alpha: 0.85),
          const Color(0xFF030C1C),
        ],
      ).createShader(rect);

    final path2 = Path();
    path2.moveTo(0, size.height * 0.82);
    path2.quadraticBezierTo(
      size.width * 0.16,
      size.height * 0.74,
      size.width * 0.35,
      size.height * 0.80,
    );
    path2.quadraticBezierTo(
      size.width * 0.55,
      size.height * 0.70,
      size.width * 0.75,
      size.height * 0.82,
    );
    path2.quadraticBezierTo(
      size.width * 0.90,
      size.height * 0.76,
      size.width,
      size.height * 0.84,
    );
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, mountainPaint2);
  }

  @override
  bool shouldRepaint(covariant CelestialBannerPainter oldDelegate) =>
      oldDelegate.theme != theme;
}

/// Custom painter for the Platform Journey card with cosmic/orbital rings and gradient glow.
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
          Color(0xFF031438),
          Color(0xFF062258),
          Color(0xFF0B2866),
        ],
      ).createShader(rect);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(20)), bgPaint);

    // Glowing cyan/blue orbital arcs
    final arcCenter = Offset(size.width * 0.88, size.height * 0.35);
    final arcPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.22)
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
      arcPaint..color = const Color(0xFF60A5FA).withValues(alpha: 0.18),
    );

    // Light radial glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF38BDF8).withValues(alpha: 0.25),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: arcCenter, radius: 80));
    canvas.drawCircle(arcCenter, 80, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
