import 'dart:io';
import 'dart:typed_data';
import '../app_notifications.dart';
import '../services/auth_api.dart';
import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
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

  // Values below are populated from the authenticated Django profile endpoint.
  String _name = '—';
  String _email = '—';
  String _phone = '';
  String _location = '';
  String _dob = '';
  String _address = '';
  String _city = '';
  String _state = '';
  String _country = '';
  String _zipCode = '';

  Color _avatarBg = const Color(0xFF0875F5);
  String _bannerTheme = 'Cosmic Landscape';
  String? _profileImagePath;
  String? _bannerImagePath;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoadingProfile = true;
  bool _isSavingProfile = false;

  String _bankName = '—';
  String _bankAccountNumber = '—';
  String _bankIfscCode = '—';
  String _bankBranch = '—';
  String _bankStatus = 'Not submitted';

  String _cryptoWalletAddress = '—';
  String _cryptoCurrency = '—';
  String _cryptoStatus = 'Not submitted';
  String _identityDocumentStatus = 'Not submitted';
  String _residenceDocumentStatus = 'Not submitted';
  String _identityDocumentReason = '';
  String _residenceDocumentReason = '';
  bool _hasIdentityDocument = false;
  bool _hasResidenceDocument = false;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  _ProfileColors get _c => _ProfileColors.of(context);

  @override
  void initState() {
    super.initState();
    _loadProfileFromApi();
  }

  Map<String, dynamic> _profileMap(Map<String, dynamic> response) {
    dynamic value = response;
    for (var depth = 0; depth < 4 && value is Map; depth++) {
      final map = value.cast<String, dynamic>();
      if (map['user'] is Map) {
        return (map['user'] as Map).cast<String, dynamic>();
      }
      if (map['profile'] is Map) {
        return (map['profile'] as Map).cast<String, dynamic>();
      }
      if (map['data'] is Map) {
        value = map['data'];
        continue;
      }
      return map;
    }
    return <String, dynamic>{};
  }

  String _stringValue(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  String _formatDateForForm(dynamic value) {
    final raw = _stringValue(value);
    if (raw.isEmpty) return '';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return '${parsed.day.toString().padLeft(2, '0')}-'
        '${parsed.month.toString().padLeft(2, '0')}-${parsed.year}';
  }

  Future<void> _loadProfileDocuments() async {
    final response = await AuthApi.instance.getProfileDocuments();
    dynamic rows = response['data'] ?? response['documents'] ?? response['results'];
    if (rows is Map) {
      rows = rows['documents'] ?? rows['results'] ?? rows['data'];
    }
    final documents = rows is List
        ? rows.whereType<Map>().map((item) => item.cast<String, dynamic>()).toList()
        : <Map<String, dynamic>>[];
    Map<String, dynamic> findDocument(String type) {
      for (final document in documents) {
        if (_stringValue(document['document_type']) == type) return document;
      }
      return <String, dynamic>{};
    }

    final identity = findDocument('identity');
    final residence = findDocument('residence');
    if (!mounted) return;
    setState(() {
      _identityDocumentStatus = _statusLabel(identity['status'] ?? identity['verification_status']);
      _residenceDocumentStatus = _statusLabel(residence['status'] ?? residence['verification_status']);
      _identityDocumentReason = _stringValue(identity['verification_reason'] ?? identity['human_readable_reason']);
      _residenceDocumentReason = _stringValue(residence['verification_reason'] ?? residence['human_readable_reason']);
      _hasIdentityDocument = _stringValue(identity['document']).isNotEmpty;
      _hasResidenceDocument = _stringValue(residence['document']).isNotEmpty;
    });
  }

  Future<void> _pickAndUploadDocument({required String documentType}) async {
    try {
      // file_picker v12+ exposes static methods and returns a single
      // PlatformFile from pickFile().
      final picked = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
      );
      if (picked == null) return;
      final path = picked.path;
      if (path == null || path.isEmpty) {
        _showSnack('Unable to read the selected document.');
        return;
      }
      await AuthApi.instance.uploadVerificationDocument(
        documentType: documentType,
        filePath: path,
      );
      await _loadProfileDocuments();
      if (!mounted) return;
      _showSnack('Document uploaded. Current status: ${documentType == 'identity' ? _identityDocumentStatus : _residenceDocumentStatus}.');
    } catch (error) {
      if (!mounted) return;
      _showSnack(error is AuthApiException ? error.message : 'Unable to upload the verification document.');
      debugPrint('Verification document upload failed: $error');
    }
  }

  String _statusLabel(dynamic value) {
    final raw = _stringValue(value, fallback: 'not submitted')
        .replaceAll('_', ' ')
        .replaceAll('-', ' ');
    return raw
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1).toLowerCase())
        .join(' ');
  }

  Future<String?> _cacheRemoteImage(Uint8List bytes, String fileName) async {
    if (bytes.isEmpty) return null;
    final directory = await getApplicationDocumentsDirectory();
    final imageDirectory = Directory('${directory.path}/profile_images');
    if (!await imageDirectory.exists()) {
      await imageDirectory.create(recursive: true);
    }
    final file = File('${imageDirectory.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<void> _loadProfileFromApi() async {
    try {
      final responses = await Future.wait<Map<String, dynamic>>([
        AuthApi.instance.getProfile(),
        AuthApi.instance.getBankDetails(),
        AuthApi.instance.getCryptoDetails(),
      ]);

      final profile = _profileMap(responses[0]);
      final bank = _profileMap(responses[1]);
      final crypto = _profileMap(responses[2]);

      String? remoteAvatarPath;
      String? remoteBannerPath;
      if (_stringValue(profile['profile_pic']).isNotEmpty) {
        try {
          final bytes = await AuthApi.instance.getProfileImageBytes();
          remoteAvatarPath = await _cacheRemoteImage(
            bytes, 'profile_avatar_remote.webp',
          );
        } catch (error) {
          debugPrint('Profile image fetch skipped: $error');
        }
      }
      try {
        final bytes = await AuthApi.instance.getProfileBannerBytes();
        remoteBannerPath = await _cacheRemoteImage(
          bytes, 'profile_banner_remote.webp',
        );
      } catch (error) {
        // A missing banner is normal for a new profile.
        debugPrint('Profile banner not available: $error');
      }

      final city = _stringValue(profile['city']);
      final country = _stringValue(profile['country']);
      if (!mounted) return;
      setState(() {
        _name = _stringValue(profile['name'], fallback: '—');
        _email = _stringValue(profile['email'], fallback: '—');
        _phone = _stringValue(profile['phone_number'] ?? profile['phone']);
        _dob = _formatDateForForm(profile['dob']);
        _address = _stringValue(profile['address']);
        _city = city;
        _state = _stringValue(profile['state']);
        _country = country;
        _zipCode = _stringValue(profile['zip_code']);
        _location = [city, country].where((part) => part.isNotEmpty).join(', ');
        _bankName = _stringValue(bank['bank_name'], fallback: '—');
        _bankAccountNumber = _stringValue(bank['account_number'], fallback: '—');
        _bankIfscCode = _stringValue(bank['ifsc_code'], fallback: '—');
        _bankBranch = _stringValue(bank['branch_name'], fallback: '—');
        _bankStatus = _statusLabel(bank['status']);
        _cryptoWalletAddress = _stringValue(crypto['wallet_address'], fallback: '—');
        _cryptoCurrency = _stringValue(crypto['currency'], fallback: '—');
        _cryptoStatus = _statusLabel(crypto['status']);
        if (remoteAvatarPath != null) _profileImagePath = remoteAvatarPath;
        if (remoteBannerPath != null) _bannerImagePath = remoteBannerPath;
      });
      try {
        await _loadProfileDocuments();
      } catch (documentError) {
        debugPrint('Profile document status load failed: $documentError');
      }
    } catch (error) {
      debugPrint('Profile API load failed: $error');
      if (mounted) {
        _showSnack('Unable to load your latest profile details. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
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

      // Upload first. Do not replace the existing preview or show success until
      // Django has accepted and stored the image.
      if (isBanner) {
        await AuthApi.instance.uploadProfileBanner(pickedImage.path);
      } else {
        await AuthApi.instance.uploadProfileImage(pickedImage.path);
      }

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

      if (!mounted) return;
      setState(() {
        if (isBanner) {
          _bannerImagePath = savedFile.path;
        } else {
          _profileImagePath = savedFile.path;
        }
      });
      _showSnack(isBanner
          ? 'Profile banner uploaded successfully'
          : 'Profile photo uploaded successfully');
    } catch (error) {
      if (!mounted) return;
      _showSnack(error is AuthApiException
          ? error.message
          : 'Unable to upload image. Please try again.');
      debugPrint('Profile image upload error: $error');
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
    final dobCtrl = TextEditingController(text: _dob);
    final cityCtrl = TextEditingController(text: _city);
    final stateCtrl = TextEditingController(text: _state);
    final countryCtrl = TextEditingController(text: _country);
    final addressCtrl = TextEditingController(text: _address);
    final zipCtrl = TextEditingController(text: _zipCode);

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
                'Update the personal information supported by your verified account.',
                style: TextStyle(color: _profileTextSecondary, fontSize: 12),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _inputField(
                      controller: nameCtrl,
                      label: 'Registered Name (read-only)',
                      icon: LucideIcons.user,
                      readOnly: true,
                    ),
                    const SizedBox(height: 12),
                    _inputField(
                      controller: emailCtrl,
                      label: 'Registered Email (read-only)',
                      icon: LucideIcons.mail,
                      keyboardType: TextInputType.emailAddress,
                      readOnly: true,
                    ),
                    const SizedBox(height: 12),
                    _inputField(
                      controller: phoneCtrl,
                      label: 'Phone Number',
                      icon: LucideIcons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    _inputField(
                      controller: dobCtrl,
                      label: 'Date of Birth (DD-MM-YYYY)',
                      icon: LucideIcons.calendar,
                      keyboardType: TextInputType.datetime,
                    ),
                    const SizedBox(height: 12),
                    _inputField(controller: addressCtrl, label: 'Residential Address', icon: LucideIcons.home, maxLines: 2),
                    const SizedBox(height: 12),
                    _inputField(controller: cityCtrl, label: 'City', icon: LucideIcons.mapPin),
                    const SizedBox(height: 12),
                    _inputField(controller: stateCtrl, label: 'State', icon: LucideIcons.map),
                    const SizedBox(height: 12),
                    _inputField(controller: countryCtrl, label: 'Country', icon: LucideIcons.globe),
                    const SizedBox(height: 12),
                    _inputField(controller: zipCtrl, label: 'ZIP / Postal Code', icon: LucideIcons.mail),
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
                      onPressed: _isSavingProfile ? null : () => Navigator.pop(ctx),
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
                      onPressed: _isSavingProfile ? null : () async {
                        setState(() => _isSavingProfile = true);
                        try {
                          final result = await AuthApi.instance.updatePersonalInfo(
                            phoneNumber: phoneCtrl.text.trim(),
                            dateOfBirth: dobCtrl.text.trim(),
                            address: addressCtrl.text.trim(),
                            city: cityCtrl.text.trim(),
                            state: stateCtrl.text.trim(),
                            country: countryCtrl.text.trim(),
                            zipCode: zipCtrl.text.trim(),
                          );
                          final updated = _profileMap(result);
                          if (!mounted) return;
                          setState(() {
                            _phone = _stringValue(updated['phone'], fallback: phoneCtrl.text.trim());
                            _dob = _formatDateForForm(updated['dob'] ?? dobCtrl.text.trim());
                            _address = _stringValue(updated['address'], fallback: addressCtrl.text.trim());
                            _city = _stringValue(updated['city'], fallback: cityCtrl.text.trim());
                            _state = _stringValue(updated['state'], fallback: stateCtrl.text.trim());
                            _country = _stringValue(updated['country'], fallback: countryCtrl.text.trim());
                            _zipCode = _stringValue(updated['zip_code'], fallback: zipCtrl.text.trim());
                            _location = [_city, _country].where((part) => part.isNotEmpty).join(', ');
                          });
                          if (ctx.mounted) Navigator.pop(ctx);
                          _showSnack(_stringValue(result['message'], fallback: 'Profile information updated successfully'));
                        } catch (error) {
                          if (mounted) {
                            _showSnack(error is AuthApiException
                                ? error.message
                                : 'Unable to update profile information.');
                          }
                        } finally {
                          if (mounted) setState(() => _isSavingProfile = false);
                        }
                      },
                      child: _isSavingProfile
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
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
    dobCtrl.dispose();
    cityCtrl.dispose();
    stateCtrl.dispose();
    countryCtrl.dispose();
    addressCtrl.dispose();
    zipCtrl.dispose();
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool readOnly = false,
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
          readOnly: readOnly,
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
    showAppMessage(message);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = screenWidth < 360 ? 12.0 : screenWidth < 420 ? 14.0 : 18.0;
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
                  padding: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 132),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildMobileProfileHeader(),
                      if (_isLoadingProfile) ...[
                        const SizedBox(height: 10),
                        const LinearProgressIndicator(minHeight: 2),
                      ],
                      const SizedBox(height: 18),
                      _buildProfilePageTitle(),
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
    final compact = MediaQuery.sizeOf(context).width < 380;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ACCOUNT SETTINGS', style: TextStyle(
                color: _c.accentBlue, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.8)),
              const SizedBox(height: 5),
              Text('My profile', style: TextStyle(
                color: _c.text, fontSize: compact ? 25 : 28, fontWeight: FontWeight.w800, letterSpacing: -1.1)),
              const SizedBox(height: 3),
              Text('Personal details, verification and payment preferences',
                style: TextStyle(color: _c.muted, fontSize: compact ? 10 : 11.5, height: 1.3)),
            ],
          ),
        ),
        Material(
          color: _c.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: _c.border),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _showEditDetailsSheet,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(LucideIcons.pencilLine, color: _c.text, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  // Minimal identity panel: no client-role labels or account-type badges.
  // Restored profile hero header without client-role labels.
  Widget _buildMobileProfileHeader() {
    final compact = MediaQuery.sizeOf(context).width < 380;
    final avatarSize = compact ? 68.0 : 82.0;
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B1D38), Color(0xFF153D70), Color(0xFF1B548A)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2410264A),
            blurRadius: 22,
            offset: Offset(0, 9),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Keep the cover visible while retaining enough contrast for profile text.
          if (_bannerImagePath != null)
            Positioned.fill(
              child: Image.file(
                File(_bannerImagePath!),
                fit: BoxFit.cover,
                alignment: Alignment.center,
                gaplessPlayback: true,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Profile cover image render error: $error');
                  return const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF0B1D38),
                          Color(0xFF153D70),
                          Color(0xFF1B548A),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          if (_bannerImagePath != null)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x330B1D38),
              ),
            ),
          Positioned(
            right: -36,
            top: -54,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: .07),
                  width: 24,
                ),
              ),
            ),
          ),
          Positioned(
            right: 24,
            bottom: -78,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFF4C84A).withValues(alpha: .12),
                  width: 1.5,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(compact ? 14 : 18, 16, compact ? 14 : 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Spacer(),
                    _profileHeaderAction(
                      icon: LucideIcons.image,
                      label: 'Cover',
                      onTap: _showChangeBannerSheet,
                    ),
                  ],
                ),
                SizedBox(height: compact ? 14 : 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: avatarSize,
                          height: avatarSize,
                          decoration: BoxDecoration(
                            color: _avatarBg,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: _profileImagePath != null
                              ? Image.file(
                                  File(_profileImagePath!),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => _profileInitial(),
                                )
                              : _profileInitial(),
                        ),
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Material(
                            color: _profileGold,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: _showChangePhotoSheet,
                              child: const SizedBox(
                                width: 28,
                                height: 28,
                                child: Icon(
                                  LucideIcons.camera,
                                  size: 14,
                                  color: Color(0xFF10264A),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: compact ? 11 : 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: compact ? 16 : 18,
                              height: 1.1,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: .76),
                              fontSize: compact ? 10 : 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: .13),
                ),
                const SizedBox(height: 13),
                Row(
                  children: [
                    Expanded(
                      child: _profileHeroMetric(
                        LucideIcons.phone,
                        'PHONE',
                        _phone,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.white.withValues(alpha: .15),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _profileHeroMetric(
                        LucideIcons.mapPin,
                        'LOCATION',
                        _location,
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

  Widget _profileHeroMetric(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _profileGold, size: 15),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .62),
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value.isNotEmpty ? value : 'Not provided',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
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

  Widget _buildMobileSectionNavigation() {
    final compact = MediaQuery.sizeOf(context).width < 380;
    final tabs = [
      (icon: LucideIcons.layoutDashboard, label: 'Overview'),
      (icon: LucideIcons.userRound, label: 'Personal'),
      (icon: LucideIcons.shieldCheck, label: compact ? 'Verify' : 'Verification'),
      (icon: LucideIcons.wallet, label: 'Payments'),
    ];
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: _c.subCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _c.border),
      ),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedTabIndex = i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  constraints: const BoxConstraints(minHeight: 54),
                  padding: EdgeInsets.symmetric(vertical: compact ? 8 : 10, horizontal: 1),
                  decoration: BoxDecoration(
                    color: _selectedTabIndex == i ? _c.card : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                    border: _selectedTabIndex == i
                        ? Border.all(color: _c.border)
                        : null,
                    boxShadow: _selectedTabIndex == i && !_c.isDark ? _profileShadow : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(tabs[i].icon, size: 16,
                        color: _selectedTabIndex == i ? _c.accentBlue : _c.muted),
                      const SizedBox(height: 5),
                      Text(tabs[i].label, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: compact ? 9 : 10, fontWeight: FontWeight.w700,
                          color: _selectedTabIndex == i ? _c.text : _c.muted)),
                    ],
                  ),
                ),
              ),
            ),
        ],
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
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Account overview', style: TextStyle(
                  color: _c.text, fontSize: 19, fontWeight: FontWeight.w800, letterSpacing: -.5)),
                const SizedBox(height: 4),
                Text('A clear view of your account information',
                  style: TextStyle(color: _c.muted, fontSize: 10.5)),
              ],
            )),
            TextButton.icon(
              onPressed: _showEditDetailsSheet,
              icon: const Icon(LucideIcons.pencil, size: 13),
              label: const Text('Edit details'),
              style: TextButton.styleFrom(
                foregroundColor: _c.accentBlue,
                textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildOverviewVerificationPaymentGrid(),
        const SizedBox(height: 22),
        _buildMobileCompletionSummary(),
      ],
    );
  }

  Widget _buildOverviewVerificationPaymentGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: MediaQuery.sizeOf(context).width < 350 ? 1 : 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: MediaQuery.sizeOf(context).width < 350 ? 2.65 : 1.3,
          children: [
            _overviewStatusCard(
              icon: LucideIcons.idCard,
              title: 'Identity verification',
              detail: 'Identity proof',
              status: _identityDocumentStatus,
              onTap: () => setState(() => _selectedTabIndex = 2),
            ),
            _overviewStatusCard(
              icon: LucideIcons.house,
              title: 'Address verification',
              detail: 'Address proof',
              status: _residenceDocumentStatus,
              onTap: () => setState(() => _selectedTabIndex = 2),
            ),
            _overviewStatusCard(
              icon: LucideIcons.landmark,
              title: 'Bank account',
              detail: _bankName,
              status: _bankStatus,
              onTap: () => setState(() => _selectedTabIndex = 3),
            ),
            _overviewStatusCard(
              icon: LucideIcons.wallet,
              title: 'Crypto wallet',
              detail: _cryptoCurrency,
              status: _cryptoStatus,
              onTap: () => setState(() => _selectedTabIndex = 3),
            ),
          ],
        ),
      ],
    );
  }

  Widget _overviewStatusCard({
    required IconData icon,
    required String title,
    required String detail,
    required String status,
    required VoidCallback onTap,
  }) {
    final isApproved = status.toLowerCase() == 'approved' ||
        status.toLowerCase() == 'connected';
    final statusColor = isApproved ? const Color(0xFF23845B) : _c.accentBlue;
    return Material(
      color: _c.card,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 380 ? 10 : 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: _c.border),
            boxShadow: _c.isDark ? null : _profileShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _c.blueLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: _c.accentBlue, size: 17),
                  ),
                  const Spacer(),
                  Icon(LucideIcons.chevronRight, color: _c.muted, size: 15),
                ],
              ),
              const Spacer(),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _c.text,
                  fontSize: MediaQuery.sizeOf(context).width < 380 ? 10.5 : 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                detail,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: _c.muted, fontSize: 10),
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      status,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
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

  Widget _buildMobileCompletionSummary() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: _c.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _c.border),
        boxShadow: _c.isDark ? null : _profileShadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 38, height: 38,
            decoration: BoxDecoration(color: _c.blueLight, borderRadius: BorderRadius.circular(12)),
            child: Icon(LucideIcons.contactRound, color: _c.accentBlue, size: 19)),
          const SizedBox(width: 11),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Manage your profile', style: TextStyle(color: _c.text, fontSize: 14, fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            Text('Your account settings and payment details', style: TextStyle(color: _c.muted, fontSize: 10)),
          ])),
        ]),
        const SizedBox(height: 14),
        Divider(height: 1, color: _c.border),
        _profileOverviewLink(
          icon: LucideIcons.userRound, title: 'Personal information',
          subtitle: 'Contact details and personal profile',
          onTap: () => setState(() => _selectedTabIndex = 1),
        ),
        Divider(height: 1, color: _c.border),
        _profileOverviewLink(
          icon: LucideIcons.shieldCheck, title: 'Identity verification',
          subtitle: 'Review submitted verification details',
          onTap: () => setState(() => _selectedTabIndex = 2),
        ),
        Divider(height: 1, color: _c.border),
        _profileOverviewLink(
          icon: LucideIcons.landmark, title: 'Bank account',
          subtitle: 'Manage your payout bank details',
          onTap: _showBankDetailsSheet,
        ),
        Divider(height: 1, color: _c.border),
        _profileOverviewLink(
          icon: LucideIcons.wallet, title: 'Crypto wallet',
          subtitle: 'Manage your wallet details',
          onTap: _showCryptoWalletSheet,
        ),
        Divider(height: 1, color: _c.border),
        _profileOverviewLink(
          icon: LucideIcons.creditCard, title: 'Payment methods',
          subtitle: 'View all payment settings',
          onTap: () => setState(() => _selectedTabIndex = 3),
        ),
      ]),
    );
  }

  Widget _profileOverviewLink({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(children: [
          Icon(icon, color: _c.accentBlue, size: 17),
          const SizedBox(width: 11),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(color: _c.text, fontSize: 11, fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            Text(subtitle, style: TextStyle(color: _c.muted, fontSize: 9.5)),
          ])),
          Icon(LucideIcons.chevronRight, color: _c.muted, size: 17),
        ]),
      ),
    );
  }

  String get _maskedBankAccountNumber => _bankAccountNumber.length <= 4
      ? _bankAccountNumber
      : 'Ã¢â‚¬Â¢Ã¢â‚¬Â¢Ã¢â‚¬Â¢Ã¢â‚¬Â¢ ${_bankAccountNumber.substring(_bankAccountNumber.length - 4)}';

  String get _shortWalletAddress => _cryptoWalletAddress.length <= 18
      ? _cryptoWalletAddress
      : '${_cryptoWalletAddress.substring(0, 8)}Ã¢â‚¬Â¦${_cryptoWalletAddress.substring(_cryptoWalletAddress.length - 6)}';

  void _showBankDetailsSheet() {
    _showPaymentDestinationDetailsSheet(
      context: context,
      title: 'Bank Account Details',
      subtitle: 'Bank payout details returned by your account API',
      icon: LucideIcons.landmark,
      iconColor: Colors.white,
      iconBgColor: _profileNavy,
      status: _bankStatus,
      details: [
        _PaymentDetailItem(label: 'Bank Name', value: _bankName),
        _PaymentDetailItem(label: 'Account Number', value: _maskedBankAccountNumber, copyable: true),
        _PaymentDetailItem(label: 'IFSC Code', value: _bankIfscCode, copyable: true),
        _PaymentDetailItem(label: 'Branch Name', value: _bankBranch),
      ],
      onEdit: () {
        Navigator.pop(context);
        _showEditBankDestinationSheet();
      },
    );
  }

  void _showCryptoWalletSheet() {
    _showPaymentDestinationDetailsSheet(
      context: context,
      title: 'Crypto Wallet Details',
      subtitle: 'Wallet details returned by your account API',
      icon: LucideIcons.wallet,
      iconColor: Colors.white,
      iconBgColor: _profileNavy,
      status: _cryptoStatus,
      details: [
        _PaymentDetailItem(label: 'Wallet Address', value: _shortWalletAddress, copyable: true),
        _PaymentDetailItem(label: 'Currency', value: _cryptoCurrency),
      ],
      onEdit: () {
        Navigator.pop(context);
        _showEditCryptoDestinationSheet();
      },
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
                      'Profile information saved in your account',
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
          _detailCardRow(LucideIcons.mail, 'Email Address', _email),
          _detailCardRow(LucideIcons.phone, 'Phone Number', _phone),
          _detailCardRow(LucideIcons.home, 'Residential Address', _address),
          _detailCardRow(LucideIcons.mapPin, 'City', _city),
          _detailCardRow(LucideIcons.map, 'State', _state),
          _detailCardRow(LucideIcons.globe, 'Country', _country),
          _detailCardRow(LucideIcons.mail, 'ZIP / Postal Code', _zipCode),
        ],
      ),
    );
  }

  Widget _detailCardRow(IconData icon, String label, String value) {
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
                Text(label, style: TextStyle(color: _c.muted, fontSize: 11)),
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
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: VERIFICATION TAB
  // ==========================================
  Widget _buildVerificationTab() {
    return _VerificationTabView(
      identityStatus: _identityDocumentStatus,
      residenceStatus: _residenceDocumentStatus,
      identityReason: _identityDocumentReason,
      residenceReason: _residenceDocumentReason,
      hasIdentityDocument: _hasIdentityDocument,
      hasResidenceDocument: _hasResidenceDocument,
      onViewDocument: (docType) => _showDocumentViewerSheet(context, docType),
      onUploadDocument: (docType) => _pickAndUploadDocument(documentType: docType),
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
      bankAccountNumber: _maskedBankAccountNumber,
      bankIfscCode: _bankIfscCode,
      bankBranch: _bankBranch,
      bankStatus: _bankStatus,
      cryptoWalletAddress: _cryptoWalletAddress,
      cryptoCurrency: _cryptoCurrency,
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
          _PaymentDetailItem(label: 'Account Number', value: _maskedBankAccountNumber, copyable: true),
          _PaymentDetailItem(label: 'IFSC Code', value: _bankIfscCode, copyable: true),
          _PaymentDetailItem(label: 'Branch Name', value: _bankBranch),
        ],
        onEdit: () {
          Navigator.pop(context);
          _showEditBankDestinationSheet();
        },
      ),
      onEditBankDetails: _showEditBankDestinationSheet,
      onBankMenuAction: (action) async {
        if (action == 'refresh') {
          try {
            final bank = _profileMap(await AuthApi.instance.getBankDetails());
            if (!mounted) return;
            setState(() {
              _bankName = _stringValue(bank['bank_name'], fallback: '—');
              _bankAccountNumber = _stringValue(bank['account_number'], fallback: '—');
              _bankIfscCode = _stringValue(bank['ifsc_code'], fallback: '—');
              _bankBranch = _stringValue(bank['branch_name'], fallback: '—');
              _bankStatus = _statusLabel(bank['status']);
            });
            _showSnack('Bank details refreshed.');
          } catch (error) {
            if (mounted) _showSnack(error is AuthApiException ? error.message : 'Unable to refresh bank details.');
          }
        } else if (action == 'copy') {
          await Clipboard.setData(ClipboardData(
            text: 'Bank: $_bankName\nAccount: $_bankAccountNumber\nIFSC: $_bankIfscCode\nBranch: $_bankBranch',
          ));
          _showSnack('Bank details copied to clipboard.');
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
        ],
        onEdit: () {
          Navigator.pop(context);
          _showEditCryptoDestinationSheet();
        },
      ),
      onEditCryptoDetails: _showEditCryptoDestinationSheet,
      onCryptoMenuAction: (action) async {
        if (action == 'refresh') {
          try {
            final crypto = _profileMap(await AuthApi.instance.getCryptoDetails());
            if (!mounted) return;
            setState(() {
              _cryptoWalletAddress = _stringValue(crypto['wallet_address'], fallback: '—');
              _cryptoCurrency = _stringValue(crypto['currency'], fallback: '—');
              _cryptoStatus = _statusLabel(crypto['status']);
            });
            _showSnack('Crypto wallet details refreshed.');
          } catch (error) {
            if (mounted) _showSnack(error is AuthApiException ? error.message : 'Unable to refresh crypto details.');
          }
        } else if (action == 'copy') {
          await Clipboard.setData(ClipboardData(
            text: 'Wallet: $_cryptoWalletAddress\nCurrency: $_cryptoCurrency',
          ));
          _showSnack('Crypto wallet details copied to clipboard.');
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
        onSave: (name, accNum, ifsc, branch) async {
          final result = await AuthApi.instance.updateBankDetails(
            bankName: name,
            accountNumber: accNum,
            ifscCode: ifsc,
            branchName: branch,
          );
          if (!mounted) return;
          setState(() {
            _bankName = _stringValue(result['bank_name'], fallback: name);
            _bankAccountNumber = _stringValue(result['account_number'], fallback: accNum);
            _bankIfscCode = _stringValue(result['ifsc_code'], fallback: ifsc);
            _bankBranch = _stringValue(result['branch_name'], fallback: branch);
            _bankStatus = _statusLabel(result['status'] ?? 'pending');
          });
          _showSnack('Bank details submitted. Awaiting admin approval.');
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
        onSave: (address, currency) async {
          final result = await AuthApi.instance.updateCryptoDetails(
            walletAddress: address,
            currency: currency,
          );
          if (!mounted) return;
          setState(() {
            _cryptoWalletAddress = _stringValue(result['wallet_address'], fallback: address);
            _cryptoCurrency = _stringValue(result['currency'], fallback: currency);
            _cryptoStatus = _statusLabel(result['status'] ?? 'pending');
          });
          _showSnack('Crypto wallet submitted. Awaiting admin approval.');
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
    required this.identityStatus,
    required this.residenceStatus,
    required this.identityReason,
    required this.residenceReason,
    required this.hasIdentityDocument,
    required this.hasResidenceDocument,
    required this.onViewDocument,
    required this.onUploadDocument,
  });

  final String identityStatus;
  final String residenceStatus;
  final String identityReason;
  final String residenceReason;
  final bool hasIdentityDocument;
  final bool hasResidenceDocument;
  final ValueChanged<String> onViewDocument;
  final ValueChanged<String> onUploadDocument;

  @override
  Widget build(BuildContext context) {
    final c = _ProfileColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verification Documents',
                style: TextStyle(
                  color: c.text,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Upload and track the status of your identity and residence documents.',
                style: TextStyle(color: c.muted, fontSize: 12, height: 1.35),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            _VerificationDocCard(
              title: 'Identity Verification',
              badgeLabel: 'IDENTITY PROOF',
              subtitle: 'Aadhaar, PAN, passport or driving licence',
              icon: LucideIcons.idCard,
              iconBgColor: c.blueLight,
              iconColor: const Color(0xFF4988E8),
              badgeTagColor: c.isDark ? c.accentBlue : const Color(0xFF4988E8),
              status: identityStatus,
              reason: identityReason,
              hasDocument: hasIdentityDocument,
              onViewDocument: () => onViewDocument('identity'),
              onUploadDocument: () => onUploadDocument('identity'),
            ),
            const SizedBox(height: 12),
            _VerificationDocCard(
              title: 'Address Verification',
              badgeLabel: 'ADDRESS PROOF',
              subtitle: 'Bank statement or utility bill',
              icon: LucideIcons.house,
              iconBgColor: c.goldLight,
              iconColor: c.accentBlue,
              badgeTagColor: c.isDark ? c.accentBlue : _profileBlueDark,
              status: residenceStatus,
              reason: residenceReason,
              hasDocument: hasResidenceDocument,
              onViewDocument: () => onViewDocument('residence'),
              onUploadDocument: () => onUploadDocument('residence'),
            ),
          ],
        ),
        const SizedBox(height: 16),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: c.blueLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(LucideIcons.lock, color: c.accentBlue, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your documents stay protected.',
                  style: TextStyle(color: c.text, fontSize: 12.5, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  'Viewing a document requires your current CRM password.',
                  style: TextStyle(color: c.muted, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
        ],
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
    required this.status,
    required this.reason,
    required this.hasDocument,
    required this.onViewDocument,
    required this.onUploadDocument,
  });

  final String title;
  final String badgeLabel;
  final String subtitle;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final Color badgeTagColor;
  final String status;
  final String reason;
  final bool hasDocument;
  final VoidCallback onViewDocument;
  final VoidCallback onUploadDocument;

  @override
  Widget build(BuildContext context) {
    final c = _ProfileColors.of(context);
    final approved = status.toLowerCase() == 'approved' || status.toLowerCase() == 'verified';
    final rejected = status.toLowerCase() == 'rejected';
    final statusColor = approved ? _profileGreen : (rejected ? Colors.redAccent : c.accentBlue);
    final statusBackground = approved ? c.greenLight : c.blueLight;

    return Container(
      width: double.infinity,
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
                decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: c.text, fontSize: 14, height: 1.2, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: statusBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: approved ? c.greenBorder : c.blueBorder),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            badgeLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: badgeTagColor, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.4),
          ),
          const SizedBox(height: 9),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: c.muted, fontSize: 11, height: 1.35),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              color: c.subCard,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: c.border),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.fileText, size: 17, color: _profileBlue),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasDocument ? 'Document uploaded' : 'No document uploaded',
                        style: TextStyle(color: c.text, fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        hasDocument ? 'Stored securely on your account' : 'PDF / JPG / PNG / WEBP',
                        style: TextStyle(color: c.muted, fontSize: 9, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Icon(
                  hasDocument ? LucideIcons.fileCheck : LucideIcons.filePlus,
                  color: hasDocument ? statusColor : c.muted,
                  size: 17,
                ),
              ],
            ),
          ),
          const SizedBox(height: 9),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                approved ? LucideIcons.shieldCheck : LucideIcons.info,
                color: statusColor,
                size: 14,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  reason.isNotEmpty ? reason : 'Verification status: $status',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: c.text, fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              if (hasDocument) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: onViewDocument,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: c.isDark ? c.accentBlue : _profileBlueDark,
                      side: BorderSide(color: c.blueBorder),
                      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
                      minimumSize: const Size(0, 38),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                    ),
                    child: const Text('View securely', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: onUploadDocument,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _profileBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
                    minimumSize: const Size(0, 38),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                  ),
                  child: Text(
                    hasDocument ? 'Replace document' : 'Upload document',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
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
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;
  String? _error;
  Uint8List? _documentBytes;
  String _contentType = '';
  String _fileName = '';

  bool get _isIdentity => widget.documentType == 'identity';

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _verifyAndLoadDocument() async {
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() => _error = 'Enter your CRM password to continue.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final document = await AuthApi.instance.getSecureProfileDocument(
        documentType: widget.documentType,
        password: password,
      );
      if (!mounted) return;
      setState(() {
        _documentBytes = document.bytes;
        _contentType = document.contentType;
        _fileName = document.fileName;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error is AuthApiException
            ? error.message
            : 'Unable to retrieve this document securely.';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _ProfileColors.of(context);
    final title = _isIdentity ? 'Identity Verification' : 'Address Verification';
    final badge = _isIdentity ? 'IDENTITY PROOF' : 'ADDRESS PROOF';
    final bytes = _documentBytes;

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
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(color: c.muted.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(_isIdentity ? LucideIcons.idCard : LucideIcons.house, color: c.accentBlue, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(color: c.text, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(badge, style: TextStyle(color: c.muted, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(LucideIcons.x, color: c.muted, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (bytes == null) ...[
              Text(
                'Confirm your CRM password to retrieve this document from the secure backend.',
                style: TextStyle(color: c.muted, fontSize: 12, height: 1.4),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                enabled: !_loading,
                decoration: InputDecoration(
                  labelText: 'CRM password',
                  prefixIcon: const Icon(LucideIcons.lock),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(_obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _verifyAndLoadDocument,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _profileBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Verify password and view', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: c.card,
                  border: Border.all(color: c.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.fileCheck, color: c.accentBlue, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_fileName, style: TextStyle(color: c.text, fontSize: 12, fontWeight: FontWeight.w700)),
                          Text(_contentType, style: TextStyle(color: c.muted, fontSize: 10)),
                        ],
                      ),
                    ),
                    Icon(LucideIcons.shieldCheck, color: c.accentBlue, size: 18),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (_contentType.startsWith('image/'))
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(bytes, fit: BoxFit.contain),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: c.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: c.border),
                  ),
                  child: Text(
                    _contentType == 'application/pdf'
                        ? 'The PDF was retrieved securely. This app build does not currently include an embedded PDF preview.'
                        : 'The file was retrieved securely, but this file type cannot be previewed in the app.',
                    style: TextStyle(color: c.muted, fontSize: 12, height: 1.4),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodsTabView extends StatelessWidget {
  const _PaymentMethodsTabView({
    required this.bankName,
    required this.bankAccountNumber,
    required this.bankIfscCode,
    required this.bankBranch,
    required this.bankStatus,
    required this.cryptoWalletAddress,
    required this.cryptoCurrency,
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
  final String bankStatus;

  final String cryptoWalletAddress;
  final String cryptoCurrency;
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
        Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payment Methods',
                style: TextStyle(
                  color: c.text,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage the destinations used for withdrawals and payouts.',
                style: TextStyle(color: c.muted, fontSize: 12, height: 1.35),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Bank and crypto payment cards are displayed one per row.
        Column(
          children: [
            _buildBankCard(context),
            const SizedBox(height: 12),
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
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: c.text,
                    fontSize: 14,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _connectedBadge(context, status),
              _buildEllipsisMenu(context, onMenu),
            ],
          ),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: details,
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onView,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: c.isDark ? c.accentBlue : _profileBlueDark,
                    side: BorderSide(color: c.blueBorder),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                    minimumSize: const Size(0, 40),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: const Text(
                    'View details',
                    maxLines: 1,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onEdit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _profileBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                    minimumSize: const Size(0, 40),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: const Text(
                    'Edit details',
                    maxLines: 1,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _paymentGridDetail(BuildContext context, String label, String value) {
    final c = _ProfileColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: c.muted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value.trim().isEmpty ? 'Ã¢â‚¬â€' : value,
              maxLines: 1,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: c.text,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
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
    final normalized = status.toLowerCase();
    final approved = normalized == 'approved' || normalized == 'verified' || normalized == 'connected';
    final rejected = normalized == 'rejected' || normalized == 'failed';
    final foreground = approved ? _profileGreen : (rejected ? Colors.redAccent : c.accentBlue);
    final background = approved ? c.greenLight : c.blueLight;
    final border = approved ? c.greenBorder : c.blueBorder;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: foreground, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(color: foreground, fontSize: 11.5, fontWeight: FontWeight.w600),
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
    final normalizedStatus = status.toLowerCase();
    final approved = normalizedStatus == 'approved' || normalizedStatus == 'verified' || normalizedStatus == 'connected';
    final rejected = normalizedStatus == 'rejected' || normalizedStatus == 'failed';
    final statusColor = approved ? _profileGreen : (rejected ? Colors.redAccent : c.accentBlue);
    final statusBackground = approved ? c.greenLight : c.blueLight;
    final statusBorder = approved ? c.greenBorder : c.blueBorder;
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
                  color: statusBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
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
    required this.onSave,
  });

  final String currentBankName;
  final String currentAccountNumber;
  final String currentIfscCode;
  final String currentBranchName;
  final Future<void> Function(String name, String accountNumber, String ifsc, String branch) onSave;

  @override
  State<_EditBankDestinationModal> createState() => _EditBankDestinationModalState();
}

class _EditBankDestinationModalState extends State<_EditBankDestinationModal> {
  late final TextEditingController _nameController;
  late final TextEditingController _accountController;
  late final TextEditingController _ifscController;
  late final TextEditingController _branchController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentBankName == '—' ? '' : widget.currentBankName);
    _accountController = TextEditingController(text: widget.currentAccountNumber == '—' ? '' : widget.currentAccountNumber);
    _ifscController = TextEditingController(text: widget.currentIfscCode == '—' ? '' : widget.currentIfscCode);
    _branchController = TextEditingController(text: widget.currentBranchName == '—' ? '' : widget.currentBranchName);
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
    final c = _ProfileColors.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(color: _profileNavy),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Bank Details', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    icon: const Icon(LucideIcons.x, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(color: c.blueLight, borderRadius: BorderRadius.circular(12)),
                          child: Icon(LucideIcons.landmark, color: c.accentBlue, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Bank payout information', style: TextStyle(color: c.text, fontSize: 15, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 3),
                              Text('Updates are submitted for admin approval.', style: TextStyle(color: c.muted, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: c.border, thickness: 1, height: 1),
                    const SizedBox(height: 16),
                    _inputField(label: 'Bank name', controller: _nameController),
                    const SizedBox(height: 14),
                    _inputField(label: 'Account number', controller: _accountController, keyboardType: TextInputType.number),
                    const SizedBox(height: 14),
                    _inputField(label: 'IFSC code', controller: _ifscController, textCapitalization: TextCapitalization.characters),
                    const SizedBox(height: 14),
                    _inputField(label: 'Branch name', controller: _branchController),
                    const SizedBox(height: 18),
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
                              'The backend does not accept an account-holder field. Use the registered account holder details when submitting.',
                              style: TextStyle(color: c.isDark ? c.accentBlue : _profileBlueDark, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _profileBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 1,
                        ),
                        onPressed: _saving ? null : _handleSave,
                        child: _saving
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Submit bank details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    final account = _accountController.text.trim();
    if (name.isEmpty || account.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bank name and account number are required.')));
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.onSave(
        name,
        account,
        _ifscController.text.trim(),
        _branchController.text.trim(),
      );
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error is AuthApiException ? error.message : 'Unable to submit bank details.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _inputField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    final c = _ProfileColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: c.muted, fontSize: 12.5, fontWeight: FontWeight.w600)),
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: c.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: c.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: c.accentBlue, width: 1.5)),
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
  final Future<void> Function(String address, String currency) onSave;

  @override
  State<_EditCryptoDestinationModal> createState() => _EditCryptoDestinationModalState();
}

class _EditCryptoDestinationModalState extends State<_EditCryptoDestinationModal> {
  late final TextEditingController _addressController;
  late final TextEditingController _currencyController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(text: widget.currentWalletAddress == '—' ? '' : widget.currentWalletAddress);
    _currencyController = TextEditingController(text: widget.currentCurrency == '—' ? '' : widget.currentCurrency);
  }

  @override
  void dispose() {
    _addressController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _ProfileColors.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 28),
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
                decoration: BoxDecoration(color: c.muted.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text('Edit Crypto Wallet', style: TextStyle(color: c.text, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Update the wallet address and currency. Changes require admin approval.', style: TextStyle(color: c.muted, fontSize: 12)),
            const SizedBox(height: 18),
            _inputField(label: 'Wallet Address', controller: _addressController),
            const SizedBox(height: 12),
            _inputField(label: 'Currency', controller: _currencyController, textCapitalization: TextCapitalization.characters),
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
                    onPressed: _saving ? null : () => Navigator.pop(context),
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
                    onPressed: _saving ? null : _handleSave,
                    child: _saving
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Submit Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    final address = _addressController.text.trim();
    final currency = _currencyController.text.trim();
    if (address.isEmpty || currency.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wallet address and currency are required.')));
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.onSave(address, currency);
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error is AuthApiException ? error.message : 'Unable to submit crypto details.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _inputField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    final c = _ProfileColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: c.muted, fontSize: 12.5, fontWeight: FontWeight.w600)),
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: c.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: c.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: c.accentBlue, width: 1.5)),
          ),
        ),
      ],
    );
  }
}

/// Compact selectable option used by the profile-banner theme sheet.
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
    final foreground = selected ? _profileBlueDark : _profileText;
    return Material(
      color: selected ? _profileBlueLight : _profilePanel,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? _profileBlue : _profileBorder,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: selected ? Colors.white : _profileBlueLight,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: _profileBlue, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: foreground,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
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
              const SizedBox(width: 8),
              Icon(
                selected ? LucideIcons.circleCheck : LucideIcons.circle,
                color: selected ? _profileBlue : _profileMuted,
                size: 19,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
