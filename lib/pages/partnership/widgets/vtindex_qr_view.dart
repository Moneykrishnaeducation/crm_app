import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

// ============================================================================
// BRANDED QR CODE WIDGET WITH VTINDEX LOGO IN CENTER
// ============================================================================

class VtIndexQrView extends StatelessWidget {
  const VtIndexQrView({
    super.key,
    required this.data,
    required this.size,
  });

  final String data;
  final double size;

  @override
  Widget build(BuildContext context) {
    final logoSize = (size * 0.22).clamp(38.0, 52.0);

    return Stack(
      alignment: Alignment.center,
      children: [
        QrImageView(
          data: data,
          version: QrVersions.auto,
          size: size,
          backgroundColor: Colors.white,
          errorCorrectionLevel: QrErrorCorrectLevel.H,
        ),
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFCBD5E1), width: 1.8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.all(logoSize * 0.12),
          child: ClipOval(
            child: Image.asset(
              'assets/images/vtindex_logo_img.png',
              fit: BoxFit.contain,
              cacheWidth: 120,
              cacheHeight: 120,
            ),
          ),
        ),
      ],
    );
  }
}
