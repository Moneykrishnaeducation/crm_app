import 'dart:io';
import 'dart:math' as math;

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

const _profileNavy = Color(0xFF10264A);
const _profilePanel = Color(0xFFFFFFFF);
const _profileBorder = Color(0xFFDCE5F1);
const _profileMuted = Color(0xFF62738E);
const _profileBlue = Color(0xFF0875F5);
const _profileGold = Color(0xFFF4C84A);
const _profileGreen = Color(0xFF174A8B);
const _profileCard = _profilePanel;
const _profileText = _profileNavy;
const _profileTextSecondary = _profileMuted;
const _profileBlueDark = Color(0xFF174A8B);
const _profileBlueLight = Color(0xFFEAF2FC);
const _profileGoldLight = Color(0xFFFFF7E3);
const _profileGreenLight = Color(0xFFEAF2FC);
const _profileGreenBorder = Color(0xFFD3E2F8);
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

class _ProfileColors {
  const _ProfileColors({
    required this.isDark,
    required this.text,
    required this.muted,
    required this.card,
    required this.border,
    required this.subCard,
    required this.subBorder,
    required this.blueLight,
    required this.blueBorder,
    required this.greenLight,
    required this.greenBorder,
    required this.goldLight,
    required this.goldBorder,
    required this.navy,
    required this.accentBlue,
  });

  final bool isDark;
  final Color text;
  final Color muted;
  final Color card;
  final Color border;
  final Color subCard;
  final Color subBorder;
  final Color blueLight;
  final Color blueBorder;
  final Color greenLight;
  final Color greenBorder;
  final Color goldLight;
  final Color goldBorder;
  final Color navy;
  final Color accentBlue;

  factory _ProfileColors.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _ProfileColors(
      isDark: isDark,
      text: isDark ? const Color(0xFFF2F5FA) : const Color(0xFF10264A),
      muted: isDark ? const Color(0xFF94A3B8) : const Color(0xFF62738E),
      card: isDark ? const Color(0xFF17243A) : Colors.white,
      border: isDark ? const Color(0xFF2A3A53) : const Color(0xFFDCE5F1),
      subCard: isDark ? const Color(0xFF132238) : const Color(0xFFF8FAFC),
      subBorder: isDark ? const Color(0xFF2A3A53) : const Color(0xFFEAF1FA),
      blueLight: isDark ? const Color(0xFF1E2E48) : const Color(0xFFEAF2FC),
      blueBorder: isDark ? const Color(0xFF2A3A53) : const Color(0xFFD3E2F8),
      greenLight: isDark ? const Color(0xFF132D28) : const Color(0xFFEAF7EF),
      greenBorder: isDark ? const Color(0xFF1B4D3E) : const Color(0xFFCBE9D4),
      goldLight: isDark ? const Color(0xFF2D2619) : const Color(0xFFFFF7E3),
      goldBorder: isDark ? const Color(0xFF4A3E20) : const Color(0xFFF0DFAF),
      navy: isDark ? const Color(0xFF1E3A5F) : const Color(0xFF10264A),
      accentBlue: isDark ? const Color(0xFF60A5FA) : _profileBlue,
    );
  }
}

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
  String _dob = '24 Aug 2003';
  String _gender = 'Male';
  String _nationality = 'Indian (IN)';
  String _taxResidency = 'India (PAN: *****8921J)';
  String _address = 'No 3 south street kattu edaiyar villupuram, kattu edaiyar, tamil nadu, india, 605751';
  String _occupation = 'Software Engineer';
  Color _avatarBg = const Color(0xFF0875F5); // VTIndex blue
  String _bannerTheme = 'Cosmic Landscape';
  String? _profileImagePath;
  String? _bannerImagePath;
  final ImagePicker _imagePicker = ImagePicker();

  // Mutable Payment Methods details
  String _bankName = 'NONE BANK';
  String _bankAccountNumber = '789456123456';
  String _bankIfscCode = 'IDIB000R101D';
  String _bankBranch = 'Kallakurichi';
  String _bankHolder = 'INR-DEVOP B';
  final String _bankStatus = 'Connected';

  String _cryptoWalletAddress = '123456789asdfghjklrgq094i50i3i45kjdfjweir099iwe9f';
  String _cryptoCurrency = 'UNANG';
  String _cryptoNetwork = 'TRON (TRC20)';
  final String _cryptoStatus = 'Connected';

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  _ProfileColors get _c => _ProfileColors.of(context);

  @override
  void initState() {
    super.initState();
    _loadSavedProfileImages();
  }

  Future<void> _loadSavedProfileImages() async {
    final preferences = await SharedPreferences.getInstance();
    final avatarPath = preferences.getString('profile_avatar_path');
    final bannerPath = preferences.getString('profile_banner_path');
    final avatarExists = avatarPath != null && await File(avatarPath).exists();
    final bannerExists = bannerPath != null && await File(bannerPath).exists();
    if (!mounted) return;
    setState(() {
      _profileImagePath = avatarExists ? avatarPath : null;
      _bannerImagePath = bannerExists ? bannerPath : null;
    });
  }

  Future<void> _pickAndSaveImage({
    required ImageSource source,
    required bool isBanner,
  }) async {
    try {
      final pickedImage = await _imagePicker.pickImage(
        source: source,
        imageQuality: 88,
        maxWidth: isBanner ? 2200 : 1200,
        maxHeight: isBanner ? 1200 : 1200,
      );
      if (pickedImage == null) return;

      final appDirectory = await getApplicationDocumentsDirectory();
      final imageFolder = Directory('${appDirectory.path}/profile_images');
      if (!await imageFolder.exists()) {
        await imageFolder.create(recursive: true);
      }

      final extension = pickedImage.path.contains('.')
          ? pickedImage.path.split('.').last.toLowerCase()
          : 'jpg';
      final imageName = isBanner ? 'profile_banner' : 'profile_avatar';
      final savedFile = await File(pickedImage.path).copy(
        '${imageFolder.path}/${imageName}_${DateTime.now().millisecondsSinceEpoch}.$extension',
      );

      final preferences = await SharedPreferences.getInstance();
      final preferenceKey = isBanner ? 'profile_banner_path' : 'profile_avatar_path';
      final previousPath = preferences.getString(preferenceKey);
      await preferences.setString(preferenceKey, savedFile.path);

      if (previousPath != null && previousPath != savedFile.path) {
        final previousFile = File(previousPath);
        if (await previousFile.exists()) {
          await previousFile.delete();
        }
      }

      if (!mounted) return;
      setState(() {
        if (isBanner) {
          _bannerImagePath = savedFile.path;
        } else {
          _profileImagePath = savedFile.path;
        }
      });
      _showSnack(isBanner ? 'Profile banner updated successfully' : 'Profile photo updated successfully');
    } catch (error) {
      if (!mounted) return;
      _showSnack('Unable to update image. Please check app permissions and try again.');
      debugPrint('Profile image picker error: $error');
    }
  }

  void _showChangeBannerSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: BoxDecoration(
          color: _c.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: _c.border, width: 1.5)),
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
                  _pickAndSaveImage(source: ImageSource.gallery, isBanner: true);
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
        decoration: BoxDecoration(
          color: _c.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: _c.border, width: 1.5)),
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
            Material(
              color: _profileCard,
              child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _c.blueLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.camera, color: _profileBlue, size: 20),
              ),
              title: const Text('Take Photo', style: TextStyle(color: _profileText, fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: const Text('Use camera for instant snapshot', style: TextStyle(color: _profileTextSecondary, fontSize: 11)),
              trailing: const Icon(LucideIcons.chevronRight, color: _profileMuted, size: 18),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndSaveImage(source: ImageSource.camera, isBanner: false);
              },
            )
            ),
            Material(
              color: _profileCard,
              child: ListTile(
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
                _pickAndSaveImage(source: ImageSource.gallery, isBanner: false);
              },
            )
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
                _colorCircle(const Color(0xFF0875F5), 'VT Blue'),
                _colorCircle(const Color(0xFF174A8B), 'Navy'),
                _colorCircle(const Color(0xFFF4C84A), 'Gold'),
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

  Future<void> _showEditDetailsSheet() async {
    final nameCtrl = TextEditingController(text: _name);
    final emailCtrl = TextEditingController(text: _email);
    final phoneCtrl = TextEditingController(text: _phone);
    final locationCtrl = TextEditingController(text: _location);
    final addressCtrl = TextEditingController(text: _address);
    final occupationCtrl = TextEditingController(text: _occupation);
    final dobCtrl = TextEditingController(text: _dob);
    final genderCtrl = TextEditingController(text: _gender);
    final nationalityCtrl = TextEditingController(text: _nationality);
    final taxResidencyCtrl = TextEditingController(text: _taxResidency);

    await showModalBottomSheet<void>(
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
          decoration: BoxDecoration(
            color: _c.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: _c.border, width: 1.5)),
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
                    _inputField(controller: emailCtrl, label: 'Email Address', icon: LucideIcons.mail, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 12),
                    _inputField(controller: phoneCtrl, label: 'Phone Number', icon: LucideIcons.phone, keyboardType: TextInputType.phone),
                    const SizedBox(height: 12),
                    _inputField(controller: dobCtrl, label: 'Date of Birth', icon: LucideIcons.calendar, keyboardType: TextInputType.datetime),
                    const SizedBox(height: 12),
                    _inputField(controller: genderCtrl, label: 'Gender', icon: LucideIcons.userRound),
                    const SizedBox(height: 12),
                    _inputField(controller: nationalityCtrl, label: 'Nationality', icon: LucideIcons.globe),
                    const SizedBox(height: 12),
                    _inputField(controller: locationCtrl, label: 'City & Country', icon: LucideIcons.mapPin),
                    const SizedBox(height: 12),
                    _inputField(controller: addressCtrl, label: 'Residential Address', icon: LucideIcons.home, maxLines: 2),
                    const SizedBox(height: 12),
                    _inputField(controller: occupationCtrl, label: 'Occupation', icon: LucideIcons.briefcase),
                    const SizedBox(height: 12),
                    _inputField(controller: taxResidencyCtrl, label: 'Tax Residency', icon: LucideIcons.landmark),
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
                          _dob = dobCtrl.text.trim().isEmpty ? _dob : dobCtrl.text.trim();
                          _gender = genderCtrl.text.trim().isEmpty ? _gender : genderCtrl.text.trim();
                          _nationality = nationalityCtrl.text.trim().isEmpty ? _nationality : nationalityCtrl.text.trim();
                          _taxResidency = taxResidencyCtrl.text.trim().isEmpty ? _taxResidency : taxResidencyCtrl.text.trim();
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

    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    locationCtrl.dispose();
    addressCtrl.dispose();
    occupationCtrl.dispose();
    dobCtrl.dispose();
    genderCtrl.dispose();
    nationalityCtrl.dispose();
    taxResidencyCtrl.dispose();
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: _profileMuted, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          cursorColor: _profileBlue,
          style: TextStyle(color: _profileText, fontSize: 13, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: _isDark ? const Color(0xFF101D31) : const Color(0xFFF8FAFC),
            prefixIcon: Icon(icon, color: _profileBlue, size: 18),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _profileBorder),
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
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 132),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildProfilePageTitle(),
                      const SizedBox(height: 16),
                      _buildMobileProfileHeader(),
                      const SizedBox(height: 18),
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
        ),
      ),
    );
  }

  Widget _buildProfilePageTitle() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('MY PROFILE', style: TextStyle(
                color: _c.accentBlue, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              const SizedBox(height: 4),
              Text('Account & identity', style: TextStyle(
                color: _c.text, fontSize: 23, fontWeight: FontWeight.w900, letterSpacing: -.7)),
            ],
          ),
        ),
        Material(
          color: _c.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
            side: BorderSide(color: _c.border),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(13),
            onTap: _showEditDetailsSheet,
            child: Padding(
              padding: const EdgeInsets.all(11),
              child: Icon(LucideIcons.settings2, color: _c.text, size: 19),
            ),
          ),
        ),
      ],
    );
  }

  // Native-app profile identity header. Keeps the existing avatar/banner actions.
  Widget _buildMobileProfileHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF0B1D38), Color(0xFF153D70), Color(0xFF1B548A)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Color(0x2410264A), blurRadius: 22, offset: Offset(0, 9))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(right: -36, top: -54,
            child: Container(width: 170, height: 170,
              decoration: BoxDecoration(shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: .07), width: 24)))),
          Positioned(right: 24, bottom: -78,
            child: Container(width: 180, height: 180,
              decoration: BoxDecoration(shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF4C84A).withValues(alpha: .12), width: 1.5)))),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Expanded(child: Text('CLIENT PROFILE', style: TextStyle(
                  color: Color(0xFFFFD76A), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.4))),
                _profileHeaderAction(icon: LucideIcons.image, label: 'Cover', onTap: _showChangeBannerSheet),
              ]),
              const SizedBox(height: 20),
              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Stack(clipBehavior: Clip.none, children: [
                  Container(
                    width: 82, height: 82,
                    decoration: BoxDecoration(
                      color: _avatarBg, shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _profileImagePath != null
                      ? Image.file(File(_profileImagePath!), fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _profileInitial())
                      : _profileInitial(),
                  ),
                  Positioned(right: -2, bottom: -2,
                    child: Material(
                      color: const Color(0xFFF4C84A), shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(), onTap: _showChangePhotoSheet,
                        child: const SizedBox(width: 28, height: 28,
                          child: Icon(LucideIcons.camera, size: 14, color: Color(0xFF10264A))),
                      ),
                    )),
                ]),
                const SizedBox(width: 15),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Flexible(child: Text(_name, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.1, fontWeight: FontWeight.w900))),
                    const SizedBox(width: 5),
                    const Icon(LucideIcons.badgeCheck, color: Color(0xFFFFD76A), size: 17),
                  ]),
                  const SizedBox(height: 6),
                  Text(_email, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white.withValues(alpha: .76), fontSize: 10.5)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .11),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: .16)),
                    ),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(LucideIcons.shieldCheck, color: Color(0xFFFFD76A), size: 11),
                      SizedBox(width: 5),
                      Text('Client account', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ])),
              ]),
              const SizedBox(height: 18),
              Container(height: 1, color: Colors.white.withValues(alpha: .13)),
              const SizedBox(height: 13),
              Row(children: [
                Expanded(child: _profileHeroMetric(LucideIcons.phone, 'PHONE', _phone)),
                Container(width: 1, height: 30, color: Colors.white.withValues(alpha: .15)),
                const SizedBox(width: 12),
                Expanded(child: _profileHeroMetric(LucideIcons.mapPin, 'LOCATION', _location)),
              ]),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _profileHeroMetric(IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, color: const Color(0xFFFFD76A), size: 15),
      const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: .58), fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: .7)),
        const SizedBox(height: 3),
        Text(value, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
      ])),
    ]);
  }

  Widget _profileInitial() => Center(child: Text(_name.isNotEmpty ? _name[0].toUpperCase() : 'U',
    style: const TextStyle(color: Colors.white, fontSize: 31, fontWeight: FontWeight.w800)));

  Widget _profileHeaderAction({required IconData icon, required String label, required VoidCallback onTap}) {
    return Material(
      color: Colors.white.withValues(alpha: .16),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: Colors.white, size: 13),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }

  Widget _profileIdentityTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      decoration: BoxDecoration(
        color: _c.subCard,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _c.subBorder),
      ),
      child: Row(children: [
        Icon(icon, color: _c.accentBlue, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: TextStyle(color: _c.muted, fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: .45)),
          const SizedBox(height: 4),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: TextStyle(color: _c.text, fontSize: 10, fontWeight: FontWeight.w700)),
        ])),
      ]),
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
            style: TextStyle(
              color: _c.text,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _mobileMetric(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
      decoration: BoxDecoration(
        color: _c.blueLight,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _c.blueBorder),
      ),
      child: Stack(
        children: [
          Row(
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
                      style: TextStyle(
                        color: _c.muted,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _c.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            left: -10,
            top: 0,
            bottom: 0,
            child: Container(
              width: 3,
              decoration: BoxDecoration(
                color: _profileBlue,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
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
      decoration: BoxDecoration(
        color: _c.card, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _c.border),
      ),
      child: Row(children: [
        for (var i = 0; i < tabs.length; i++)
          Expanded(child: GestureDetector(
            onTap: () => setState(() => _selectedTabIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 1),
              decoration: BoxDecoration(
                color: _selectedTabIndex == i ? _c.navy : Colors.transparent,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(tabs[i].icon, size: 16,
                  color: _selectedTabIndex == i ? const Color(0xFFFFD76A) : _c.muted),
                const SizedBox(height: 5),
                Text(tabs[i].label, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800,
                    color: _selectedTabIndex == i ? Colors.white : _c.muted)),
              ]),
            ),
          )),
      ]),
    );
  }


  // ==========================================
  // TAB 1: OVERVIEW TAB
  // ==========================================
  Widget _buildOverviewTab() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Account snapshot', style: TextStyle(color: _c.text, fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: -.35)),
          const SizedBox(height: 3),
          Text('A quick view of your client profile', style: TextStyle(color: _c.muted, fontSize: 10.5)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: _c.blueLight, borderRadius: BorderRadius.circular(20), border: Border.all(color: _c.blueBorder)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(LucideIcons.circleCheck, color: _c.accentBlue, size: 12),
            const SizedBox(width: 5),
            Text('Active', style: TextStyle(color: _c.accentBlue, fontSize: 10, fontWeight: FontWeight.w800)),
          ]),
        ),
      ]),
      const SizedBox(height: 14),
      _buildMobileCompletionSummary(),
      const SizedBox(height: 22),
      Row(children: [
        Expanded(child: Text('Manage your account', style: TextStyle(color: _c.text, fontSize: 15, fontWeight: FontWeight.w900))),
        Text('QUICK ACCESS', style: TextStyle(color: _c.muted, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
      ]),
      const SizedBox(height: 11),
      GridView.count(
        crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 2.1,
        children: [
          _mobileQuickAction(icon: LucideIcons.userRoundPen, title: 'Personal details', subtitle: 'Edit your information', onTap: () => setState(() => _selectedTabIndex = 1)),
          _mobileQuickAction(icon: LucideIcons.fileCheck2, title: 'Verification', subtitle: 'Identity and address', onTap: () => setState(() => _selectedTabIndex = 2)),
          _mobileQuickAction(icon: LucideIcons.landmark, title: 'Bank account', subtitle: 'Manage payout details', onTap: _showBankDetailsSheet),
          _mobileQuickAction(icon: LucideIcons.wallet, title: 'Crypto wallet', subtitle: 'Manage wallet details', onTap: _showCryptoWalletSheet),
        ],
      ),
      const SizedBox(height: 22),
      _buildPersonalInformationCard(),
      const SizedBox(height: 14),
      _buildIdentityVerificationCard(),
      const SizedBox(height: 14),
      _buildPaymentMethodsCard(),
    ]);
  }

  Widget _buildMobileCompletionSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF10264A), Color(0xFF1B477A)]),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Color(0x2410264A), blurRadius: 16, offset: Offset(0, 6))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 34, height: 34,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: .12), borderRadius: BorderRadius.circular(10)),
            child: const Icon(LucideIcons.shieldCheck, color: Color(0xFFFFD76A), size: 18)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Profile completion', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text('Your account information is up to date', style: TextStyle(color: Colors.white.withValues(alpha: .7), fontSize: 9.5)),
          ])),
          const Text('100%', style: TextStyle(color: Color(0xFFFFD76A), fontSize: 19, fontWeight: FontWeight.w900)),
        ]),
        const SizedBox(height: 14),
        ClipRRect(borderRadius: BorderRadius.circular(10),
          child: const LinearProgressIndicator(value: 1, minHeight: 6,
            backgroundColor: Color(0xFF526987), valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF4C84A)))),
        const SizedBox(height: 11),
        Row(children: [
          const Icon(LucideIcons.checkCircle2, color: Color(0xFF9EDDB2), size: 14),
          const SizedBox(width: 7),
          Expanded(child: Text('Profile and verification details are marked complete.',
            style: TextStyle(color: Colors.white.withValues(alpha: .82), fontSize: 10, height: 1.3))),
          const Icon(LucideIcons.arrowUpRight, color: Color(0xFFFFD76A), size: 16),
        ]),
      ]),
    );
  }

  Widget _mobileQuickAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: _c.card,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: _c.border),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: _c.blueLight, borderRadius: BorderRadius.circular(11)),
                child: Icon(icon, color: _profileBlue, size: 17),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: _c.text, fontSize: 11, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: _c.muted, fontSize: 9)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  // Personal Information Card
  Widget _buildPersonalInformationCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _c.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _c.border),
        boxShadow: _c.isDark ? null : _profileShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: TextStyle(
              color: _c.text,
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
          Divider(color: _c.border, height: 18, thickness: 0.8),
          _personalInfoRow(
            icon: LucideIcons.mail,
            label: 'Email address',
            value: _email,
          ),
          Divider(color: _c.border, height: 18, thickness: 0.8),
          _personalInfoRow(
            icon: LucideIcons.phone,
            label: 'Phone number',
            value: _phone,
          ),
          Divider(color: _c.border, height: 18, thickness: 0.8),
          _personalInfoRow(
            icon: LucideIcons.calendar,
            label: 'Date of birth',
            value: _dob,
          ),
          Divider(color: _c.border, height: 18, thickness: 0.8),
          _personalInfoRow(icon: LucideIcons.usersRound, label: 'Gender', value: _gender),
          Divider(color: _c.border, height: 18, thickness: 0.8),
          _personalInfoRow(icon: LucideIcons.flag, label: 'Nationality', value: _nationality),
          Divider(color: _c.border, height: 18, thickness: 0.8),
          _personalInfoRow(icon: LucideIcons.mapPin, label: 'Address', value: _address),
          Divider(color: _c.border, height: 18, thickness: 0.8),
          _personalInfoRow(icon: LucideIcons.briefcase, label: 'Occupation', value: _occupation),
          Divider(color: _c.border, height: 18, thickness: 0.8),
          _personalInfoRow(icon: LucideIcons.mapPin, label: 'City & Country', value: _location),
          Divider(color: _c.border, height: 18, thickness: 0.8),
          _personalInfoRow(icon: LucideIcons.landmark, label: 'Tax Residency', value: _taxResidency),
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
            color: _c.blueLight,
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
                style: TextStyle(
                  color: _c.muted,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: TextStyle(
                  color: _c.text,
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

  // Identity Verification Card
  Widget _buildIdentityVerificationCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _c.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _c.border),
        boxShadow: _c.isDark ? null : _profileShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Identity Verification',
                  style: TextStyle(
                    color: _c.text,
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
                    color: _c.blueLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _c.blueBorder),
                  ),
                  child: Text(
                    'View all',
                    style: TextStyle(
                      color: _c.isDark ? _c.accentBlue : _profileBlueDark,
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
        color: _c.subCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _c.subBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: _c.blueLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _c.accentBlue, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: _c.text,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _c.greenLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _c.greenBorder,
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

  // Payment Methods Card
  Widget _buildPaymentMethodsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _c.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _c.border),
        boxShadow: _isDark ? null : _profileShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Payment Methods',
                  style: TextStyle(
                    color: _c.text,
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
                    color: _c.blueLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _c.blueBorder),
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
            iconColor: _ProfileColors.of(context).accentBlue,
            iconBg: _c.blueLight,
            title: 'Bank Account',
            subtitle: _maskedBankAccountNumber,
            onTap: _showBankDetailsSheet,
          ),
          const SizedBox(height: 10),
          _paymentMethodTile(
            icon: LucideIcons.wallet,
            iconColor: _profileGold,
            iconBg: _c.goldLight,
            title: 'Crypto Wallet',
            subtitle: '$_cryptoCurrency · $_shortWalletAddress',
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
          color: _c.subCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _c.subBorder),
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
                    style: TextStyle(
                      color: _c.text,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: _c.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _c.greenLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _c.greenBorder,
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
            Icon(LucideIcons.arrowUpRight, size: 16, color: _c.muted),
          ],
        ),
      ),
    );
  }


  String get _maskedBankAccountNumber => _bankAccountNumber.length <= 4
      ? _bankAccountNumber
      : '•••• ${_bankAccountNumber.substring(_bankAccountNumber.length - 4)}';

  String get _shortWalletAddress => _cryptoWalletAddress.length <= 18
      ? _cryptoWalletAddress
      : '${_cryptoWalletAddress.substring(0, 8)}…${_cryptoWalletAddress.substring(_cryptoWalletAddress.length - 6)}';

  void _showBankDetailsSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: BoxDecoration(
          color: _c.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: _c.border, width: 1.5)),
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
                  color: _c.muted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bank Account Details',
                  style: TextStyle(
                    color: _c.text,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _c.greenLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _c.greenBorder),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(color: _profileGreen, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Linked bank account for fiat deposits and withdrawals.',
              style: TextStyle(color: _c.muted, fontSize: 12),
            ),
            const SizedBox(height: 18),
            _infoRow('Bank Name', _bankName),
            _infoRow('Account Number', _maskedBankAccountNumber, copyable: true),
            _infoRow('Account Holder', _bankHolder),
            _infoRow('IFSC / Routing Code', _bankIfscCode, copyable: true),
            _infoRow('Branch Name', _bankBranch),
            _infoRow('Currency', 'INR (₹)'),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _profileBlue,
                  foregroundColor: Colors.white,
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
        decoration: BoxDecoration(
          color: _c.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: _c.border, width: 1.5)),
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
                  color: _c.muted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Crypto Wallet Details',
                  style: TextStyle(
                    color: _c.text,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _c.greenLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _c.greenBorder),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(color: _profileGreen, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Authorized wallet address for direct USDT / crypto settlements.',
              style: TextStyle(color: _c.muted, fontSize: 12),
            ),
            const SizedBox(height: 18),
            _infoRow('Network', '$_cryptoNetwork / $_cryptoCurrency'),
            _infoRow('Wallet Address', _shortWalletAddress, copyable: true),
            _infoRow('Whitelist Status', 'Whitelisted & Verified', accentColor: _profileGreen),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _profileBlue,
                  foregroundColor: Colors.white,
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
        decoration: BoxDecoration(
          color: _c.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: _c.border, width: 1.5)),
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
                  color: _c.muted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Manage Payment Methods',
              style: TextStyle(
                color: _c.text,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Add, update, or remove bank accounts and crypto wallets.',
              style: TextStyle(color: _c.muted, fontSize: 12),
            ),
            const SizedBox(height: 18),
            Material(
              color: _c.card,
              child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _c.blueLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.landmark, color: _profileBlue, size: 20),
              ),
              title: Text('Manage Bank Accounts', style: TextStyle(color: _c.text, fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: Text('$_bankName • $_maskedBankAccountNumber (Primary)', style: TextStyle(color: _c.muted, fontSize: 11)),
              trailing: Icon(LucideIcons.chevronRight, color: _c.muted, size: 18),
              onTap: () {
                Navigator.pop(ctx);
                _showBankDetailsSheet();
              },
            )
            ),
            Material(
              color: _c.card,
              child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: _profileGoldLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.wallet, color: _profileGold, size: 20),
              ),
              title: Text('Manage Crypto Wallets', style: TextStyle(color: _c.text, fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: Text('$_cryptoCurrency · $_shortWalletAddress', style: TextStyle(color: _c.muted, fontSize: 11)),
              trailing: Icon(LucideIcons.chevronRight, color: _c.muted, size: 18),
              onTap: () {
                Navigator.pop(ctx);
                _showCryptoWalletSheet();
              },
            )
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _c.blueBorder),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: _c.blueLight,
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  _showSnack('Add new payment method window opened');
                },
                icon: Icon(LucideIcons.plus, size: 18, color: _c.accentBlue),
                label: Text('Add Payment Method', style: TextStyle(color: _c.text, fontSize: 13)),
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
                style: TextStyle(
                  color: _c.text,
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
              style: TextStyle(color: _c.muted, fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: accentColor ?? _c.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (copyable) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
                    _showSnack('$label copied to clipboard');
                  },
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
        color: _c.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _c.border),
        boxShadow: _isDark ? null : _profileShadow,
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
                  children: [
                    Text(
                      'Personal Information',
                      style: TextStyle(
                        color: _c.text,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Identity data verified against official documents',
                      style: TextStyle(color: _c.muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _c.navy,
                  foregroundColor: Colors.white,
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
          Divider(color: _c.border, thickness: 0.8),
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
          _detailCardRow(LucideIcons.landmark, 'Tax Residency', _taxResidency),
        ],
      ),
    );
  }

  Widget _detailCardRow(IconData icon, String label, String value, {bool verified = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: _c.subCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _c.subBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: _c.blueLight,
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
                  style: TextStyle(color: _c.muted, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: _c.text,
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
                color: _c.greenLight,
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
        currentAccountHolder: _bankHolder,
        onSave: (name, accNum, ifsc, branch, holder) {
          setState(() {
            _bankName = name;
            _bankAccountNumber = accNum;
            _bankIfscCode = ifsc;
            _bankBranch = branch;
            _bankHolder = holder;
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
        currentNetwork: _cryptoNetwork,
        onSave: (address, currency, network) {
          setState(() {
            _cryptoWalletAddress = address;
            _cryptoCurrency = currency;
            _cryptoNetwork = network;
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
    final c = _ProfileColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Header Section
        Center(
          child: Column(
            children: [
              Text(
                'Verification Documents',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: c.text,
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
          childAspectRatio: 0.72,
          children: [
            _VerificationDocCard(
              title: 'Identity Verification',
              badgeLabel: 'IDENTITY PROOF',
              subtitle: 'Aadhaar, PAN, passport or driving licence',
              icon: LucideIcons.idCard,
              iconBgColor: c.blueLight,
              iconColor: const Color(0xFF4988E8),
              badgeTagColor: c.isDark ? c.accentBlue : const Color(0xFF4988E8),
              isIdentity: true,
              onViewDocument: () => onViewDocument('Identity Verification'),
            ),
            _VerificationDocCard(
              title: 'Address Verification',
              badgeLabel: 'ADDRESS PROOF',
              subtitle: 'Bank statement or utility bill',
              icon: LucideIcons.house,
              iconBgColor: c.goldLight,
              iconColor: c.accentBlue,
              badgeTagColor: c.isDark ? c.accentBlue : _profileBlueDark,
              isIdentity: false,
              onViewDocument: () => onViewDocument('Address Verification'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 4. Security / Privacy Footer Card
        _buildSecurityPrivacyFooter(context),
      ],
    );
  }

  Widget _buildSecurityPrivacyFooter(BuildContext context) {
    final c = _ProfileColors.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border, width: 1.2),
        boxShadow: _profileShadow,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 450;
          final badge = Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: c.blueLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: c.blueBorder),
            ),
            child: Text(
              'Secure document access',
              style: TextStyle(
                color: c.isDark ? c.accentBlue : _profileBlueDark,
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
                      color: c.blueLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      LucideIcons.lock,
                      color: c.accentBlue,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your documents stay protected.',
                          style: TextStyle(
                            color: c.text,
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'You must verify your CRM password before viewing a document.',
                          style: TextStyle(
                            color: c.muted,
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
    final c = _ProfileColors.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.border),
        boxShadow: c.isDark ? null : _profileShadow,
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
            style: TextStyle(
              color: c.text,
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
              style: TextStyle(
                color: c.muted,
                fontSize: 11,
                height: 1.35,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
            decoration: BoxDecoration(
              color: c.subCard,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: c.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(LucideIcons.fileText, size: 16, color: _profileBlue),
                SizedBox(height: 5),
                Text(
                  'Document file',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: c.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'PDF / IMAGE',
                  style: TextStyle(
                    color: c.isDark ? c.accentBlue : _profileBlueDark,
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
              Expanded(
                child: Text(
                  'Verification complete',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: c.text,
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
                foregroundColor: c.isDark ? c.accentBlue : _profileBlueDark,
                side: BorderSide(color: c.blueBorder),
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

    final c = _ProfileColors.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(20, 14, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: BoxDecoration(
        color: c.subCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: c.subBorder, width: 1.5)),
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
                  color: c.muted.withValues(alpha: 0.3),
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
                    color: isIdentity ? c.blueLight : c.goldLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isIdentity ? LucideIcons.idCard : LucideIcons.house,
                    color: c.accentBlue,
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
                        style: TextStyle(
                          color: c.text,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        docBadge,
                        style: TextStyle(
                          color: c.isDark ? c.accentBlue : _profileBlueDark,
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
                    color: c.greenLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: c.greenBorder),
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
                  icon: Icon(LucideIcons.x, color: c.muted, size: 20),
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
                color: c.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _passwordVerified ? c.greenBorder : c.border,
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
                          color: _passwordVerified ? c.greenLight : c.blueLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _passwordVerified ? LucideIcons.shieldCheck : LucideIcons.lock,
                          size: 16,
                          color: _passwordVerified ? _profileGreen : c.accentBlue,
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
                          color: _passwordVerified ? c.greenLight : c.blueLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _passwordVerified ? 'Verified' : 'Required',
                          style: TextStyle(
                            color: _passwordVerified ? _profileGreen : c.muted,
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
                    style: TextStyle(
                      color: c.muted,
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
                            style: TextStyle(color: c.text, fontSize: 13),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: c.subCard,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              hintText: 'Enter CRM password',
                              hintStyle: TextStyle(color: c.muted, fontSize: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: c.border),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                                  size: 16,
                                  color: c.muted,
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
                            backgroundColor: c.accentBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Verify', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Document Details & Metadata
            Text(
              'Document Details & Metadata',
              style: TextStyle(
                color: c.text,
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: c.border),
              ),
              child: Column(
                children: [
                  _metaRow('Document Type', docTypeDetail),
                  Divider(color: c.border, height: 16),
                  _metaRow('Document Number', docRef),
                  Divider(color: c.border, height: 16),
                  _metaRow('AI Matching Score', docScore),
                  Divider(color: c.border, height: 16),
                  _metaRow('Comparison Result', docComparison),
                  Divider(color: c.border, height: 16),
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
                color: c.subCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: c.border),
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
                            color: c.accentBlue,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isIdentity ? 'identity_document_verified.pdf' : 'address_statement_verified.pdf',
                            style: TextStyle(
                              color: c.text,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '1.8 MB',
                        style: TextStyle(color: c.muted, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    height: 90,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: c.card,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: c.border),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.shieldCheck, color: _profileGreen, size: 26),
                          const SizedBox(height: 6),
                          Text(
                            'CONFIDENTIAL • VERIFIED BY CRM SYSTEM',
                            style: TextStyle(
                              color: c.isDark ? c.accentBlue : _profileBlueDark,
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
                  backgroundColor: c.blueLight,
                  foregroundColor: c.text,
                  side: BorderSide(color: c.border),
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
    final c = _ProfileColors.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: c.muted, fontSize: 11.5),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: c.text,
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
    final c = _ProfileColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? c.navy : c.subCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _profileGold : c.border,
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? c.accentBlue : c.muted, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: c.text,
                      fontSize: 12.5,
                      fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: c.muted, fontSize: 10.5),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(LucideIcons.circleCheck, color: c.accentBlue, size: 18),
          ],
        ),
      ),
    );
  }
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
    final c = _ProfileColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Payment Methods',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: c.text,
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
        _buildSecurityFooter(context),
      ],
    );
  }

  Widget _buildBankCard(BuildContext context) {
    return _paymentGridCard(
      context,
      icon: LucideIcons.landmark,
      iconColor: _profileBlue,
      title: 'Bank Account',
      status: bankStatus,
      description: 'Bank-based withdrawals and payouts',
      details: [
        _paymentGridDetail(context, 'Bank', bankName),
        _paymentGridDetail(context, 'Account', bankAccountNumber),
        _paymentGridDetail(context, 'IFSC', bankIfscCode),
        _paymentGridDetail(context, 'Branch', bankBranch),
      ],
      onView: onViewBankDetails,
      onEdit: onEditBankDetails,
      onMenu: onBankMenuAction,
    );
  }

  Widget _buildCryptoCard(BuildContext context) {
    return _paymentGridCard(
      context,
      icon: LucideIcons.wallet,
      iconColor: _profileGold,
      title: 'Crypto Wallet',
      status: cryptoStatus,
      description: 'Digital asset withdrawal destination',
      details: [
        _paymentGridDetail(context, 'Wallet', cryptoWalletAddress),
        _paymentGridDetail(context, 'Currency', cryptoCurrency),
        _paymentGridDetail(context, 'Network', cryptoNetwork),
      ],
      onView: onViewCryptoDetails,
      onEdit: onEditCryptoDetails,
      onMenu: onCryptoMenuAction,
    );
  }

  Widget _paymentGridCard(
    BuildContext context, {
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
    final c = _ProfileColors.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.border),
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
                  color: c.blueLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const Spacer(),
              _buildEllipsisMenu(context, onMenu),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: c.text,
              fontSize: 13,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          _connectedBadge(context, status),
          const SizedBox(height: 8),
          Text(
            description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: c.muted,
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
                foregroundColor: c.isDark ? c.accentBlue : _profileBlueDark,
                side: BorderSide(color: c.blueBorder),
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

  Widget _paymentGridDetail(BuildContext context, String label, String value) {
    final c = _ProfileColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: c.muted,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: c.text,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityFooter(BuildContext context) {
    final c = _ProfileColors.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border, width: 1.2),
        boxShadow: _profileShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: c.subCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: c.blueBorder),
            ),
            child: Icon(
              LucideIcons.shieldCheck,
              color: c.accentBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keep your destinations up to date.',
                  style: TextStyle(
                    color: c.text,
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Always double-check account and wallet details before saving changes.',
                  style: TextStyle(
                    color: c.muted,
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

  Widget _connectedBadge(BuildContext context, String status) {
    final c = _ProfileColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
      decoration: BoxDecoration(
        color: c.greenLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.greenBorder),
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

  Widget _buildEllipsisMenu(BuildContext context, ValueChanged<String> onAction) {
    return PopupMenuButton<String>(
      icon: Icon(
        LucideIcons.ellipsis,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        size: 20,
      ),
      tooltip: 'Options',
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      onSelected: onAction,
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'primary',
          child: Row(
            children: [
              const Icon(LucideIcons.star, size: 16, color: Color(0xFFF4C84A)),
              const SizedBox(width: 10),
              Text(
                'Set as primary',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 13),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'refresh',
          child: Row(
            children: [
              const Icon(LucideIcons.refreshCw, size: 16, color: Color(0xFF4988E8)),
              const SizedBox(width: 10),
              Text(
                'Refresh status',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 13),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'copy',
          child: Row(
            children: [
              Icon(
                LucideIcons.copy,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Text(
                'Copy details',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
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
    final c = _ProfileColors.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: c.border, width: 1.5)),
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
                color: c.muted.withValues(alpha: 0.3),
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
                      style: TextStyle(
                        color: c.text,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: c.muted,
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
              color: c.subCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.subBorder),
            ),
            child: Column(
              children: [
                for (var i = 0; i < details.length; i++) ...[
                  if (i > 0)
                    Divider(color: c.subBorder, height: 16, thickness: 1),
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
                    side: BorderSide(color: c.border),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close', style: TextStyle(color: c.text, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.accentBlue,
                    foregroundColor: Colors.white,
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
    final c = _ProfileColors.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            item.label,
            style: TextStyle(
              color: c.muted,
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
                  style: TextStyle(
                    color: c.text,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (item.copyable) ...[
                const SizedBox(width: 6),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: item.value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${item.label} copied to clipboard'),
                        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Theme.of(context).dividerColor),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(LucideIcons.copy, size: 14, color: c.accentBlue),
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
    required this.currentAccountHolder,
    required this.onSave,
  });

  final String currentBankName;
  final String currentAccountNumber;
  final String currentIfscCode;
  final String currentBranchName;
  final String currentAccountHolder;
  final void Function(String name, String accNum, String ifsc, String branch, String holder) onSave;

  @override
  State<_EditBankDestinationModal> createState() => _EditBankDestinationModalState();
}

class _EditBankDestinationModalState extends State<_EditBankDestinationModal> {
  late final TextEditingController _nameController;
  late final TextEditingController _accountController;
  late final TextEditingController _ifscController;
  late final TextEditingController _branchController;
  late final TextEditingController _holderController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentBankName);
    _accountController = TextEditingController(text: widget.currentAccountNumber);
    _ifscController = TextEditingController(text: widget.currentIfscCode);
    _branchController = TextEditingController(text: widget.currentBranchName);
    _holderController = TextEditingController(text: widget.currentAccountHolder);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _accountController.dispose();
    _ifscController.dispose();
    _branchController.dispose();
    _holderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _ProfileColors.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: c.border, width: 1.5)),
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
                color: _profileNavy,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Bank Details',
                    style: TextStyle(
                      color: Colors.white,
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
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.45),
                          width: 1.2,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          LucideIcons.x,
                          color: Colors.white,
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
                            color: c.blueLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            LucideIcons.landmark,
                            color: c.accentBlue,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bank account information',
                                style: TextStyle(
                                  color: c.text,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Enter the account details you want to use for payouts.',
                                style: TextStyle(
                                  color: c.muted,
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
                    Divider(color: c.border, thickness: 1, height: 1),
                    const SizedBox(height: 16),

                    // 4 Form Input Fields
                    _inputField(label: 'Bank name', controller: _nameController),
                    const SizedBox(height: 14),
                    _inputField(label: 'Account holder name', controller: _holderController),
                    const SizedBox(height: 14),
                    _inputField(label: 'Account number', controller: _accountController, keyboardType: TextInputType.number),
                    const SizedBox(height: 14),
                    _inputField(label: 'IFSC code', controller: _ifscController, textCapitalization: TextCapitalization.characters),
                    const SizedBox(height: 14),
                    _inputField(label: 'Branch name', controller: _branchController),
                    const SizedBox(height: 18),

                    // Info Note Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: c.blueLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: c.blueBorder, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.shieldCheck, color: c.accentBlue, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Check your bank details carefully before saving.',
                              style: TextStyle(
                                color: c.isDark ? c.accentBlue : _profileBlueDark,
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
                          backgroundColor: _profileBlue,
                          foregroundColor: Colors.white,
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
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(LucideIcons.arrowUpRight, size: 16, color: Colors.white),
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
    final holder = _holderController.text.trim();
    if (name.isNotEmpty && acc.isNotEmpty && ifsc.isNotEmpty && branch.isNotEmpty && holder.isNotEmpty) {
      widget.onSave(name, acc, ifsc, branch, holder);
      Navigator.pop(context);
    }
  }

  Widget _inputField({required String label, required TextEditingController controller, TextInputType? keyboardType, TextCapitalization textCapitalization = TextCapitalization.none}) {
    final c = _ProfileColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: c.muted,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          cursorColor: c.accentBlue,
          style: TextStyle(color: c.text, fontSize: 14, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: c.subCard,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: c.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: c.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: c.accentBlue, width: 1.5),
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
    required this.currentNetwork,
    required this.onSave,
  });

  final String currentWalletAddress;
  final String currentCurrency;
  final String currentNetwork;
  final void Function(String address, String currency, String network) onSave;

  @override
  State<_EditCryptoDestinationModal> createState() => _EditCryptoDestinationModalState();
}

class _EditCryptoDestinationModalState extends State<_EditCryptoDestinationModal> {
  late final TextEditingController _addressController;
  late final TextEditingController _currencyController;
  late final TextEditingController _networkController;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(text: widget.currentWalletAddress);
    _currencyController = TextEditingController(text: widget.currentCurrency);
    _networkController = TextEditingController(text: widget.currentNetwork);
  }

  @override
  void dispose() {
    _addressController.dispose();
    _currencyController.dispose();
    _networkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _ProfileColors.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: c.border, width: 1.5)),
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
                  color: c.muted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Edit Crypto Wallet',
              style: TextStyle(
                color: c.text,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Update your cryptocurrency destination address and currency.',
              style: TextStyle(color: c.muted, fontSize: 12),
            ),
            const SizedBox(height: 18),
            _inputField(label: 'Wallet Address', controller: _addressController),
            const SizedBox(height: 12),
            _inputField(label: 'Currency', controller: _currencyController, textCapitalization: TextCapitalization.characters),
            const SizedBox(height: 12),
            _inputField(label: 'Network', controller: _networkController, textCapitalization: TextCapitalization.characters),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: c.border),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel', style: TextStyle(color: c.text, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: c.accentBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 1,
                    ),
                    onPressed: () {
                      final addr = _addressController.text.trim();
                      final curr = _currencyController.text.trim();
                      final network = _networkController.text.trim();
                      if (addr.isNotEmpty && curr.isNotEmpty && network.isNotEmpty) {
                        widget.onSave(addr, curr, network);
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

  Widget _inputField({required String label, required TextEditingController controller, TextInputType? keyboardType, TextCapitalization textCapitalization = TextCapitalization.none}) {
    final c = _ProfileColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: c.muted,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          cursorColor: c.accentBlue,
          style: TextStyle(color: c.text, fontSize: 14),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: c.subCard,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: c.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: c.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: c.accentBlue, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
