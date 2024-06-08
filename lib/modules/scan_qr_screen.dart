import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qrcode_scan_app/modules/generate_qr_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: true,
  );

  bool isFlashOn = false;

  void _toggleFlash() {
    setState(() {
      isFlashOn = !isFlashOn;
      controller.toggleTorch();
    });
  }


  Future<void> launchURLBrowser(String urlText) async {
    Uri url = Uri.parse(urlText);
    if (!await launchUrl(url )) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20.0,
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            onPressed: _toggleFlash,
            icon: Icon(
              isFlashOn ? Icons.flash_on : Icons.flash_off,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GenerateQrScreen(),
                ),
              );
            },
            icon: const Icon(Icons.qr_code),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Place QR code in the area',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text('Scanning will be started automatically'),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: MobileScanner(
              controller: controller,
              onDetect: (capture) async {
                final List<Barcode> barcodes = capture.barcodes;
                final Uint8List? image = capture.image;
                if (barcodes.isNotEmpty) {
                  final String rawValue = barcodes.first.rawValue ?? '';
                  if (image != null) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: TextButton(
                            onPressed: ()async{
                              await launchURLBrowser(rawValue);
                            },
                            child: Text(
                                rawValue,
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                                fontSize: 16.sp
                              ),
                            ),
                          ),
                          content: Image(
                            image: MemoryImage(image),
                          ),
                        );
                      },
                    );
                  } else {
                    await launchURLBrowser(rawValue);
                  }
                }
              },
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
               'Developed by Nrmeen',
                              ),
            ),
          ),
        ],
      ),
    );
  }
}
