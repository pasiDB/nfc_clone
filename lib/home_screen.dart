import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _nfcAvailable = false;
  bool _isReading = false;
  bool _canClone = false;
  String _statusMessage = 'Checking NFC availability...';
  Map<String, dynamic>? _tagData;

  @override
  void initState() {
    super.initState();
    _checkPlatformSupport();
  }

  Future<void> _checkPlatformSupport() async {
    if (kIsWeb) {
      setState(() {
        _nfcAvailable = false;
        _statusMessage =
            'NFC is not available in web browsers. Please run on a physical device.';
      });
      return;
    }

    if (!(Platform.isAndroid || Platform.isIOS)) {
      setState(() {
        _nfcAvailable = false;
        _statusMessage = 'NFC is only available on Android and iOS devices.';
      });
      return;
    }

    try {
      bool isAvailable = await NfcManager.instance.isAvailable();
      setState(() {
        _nfcAvailable = isAvailable;
        _statusMessage =
            isAvailable
                ? 'NFC is available. Ready to read cards.'
                : 'NFC is not available on this device.';
      });
    } catch (e) {
      setState(() {
        _nfcAvailable = false;
        _statusMessage = 'Error checking NFC: ${e.toString()}';
      });
    }
  }

  void _startNfcReading() {
    setState(() {
      _isReading = true;
      _statusMessage = 'Place an NFC card near your device...';
    });

    try {
      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          final Map<String, dynamic> tagData = {};

          // Extract tag data
          tag.data.forEach((key, value) {
            if (value is Map) {
              tagData[key] = Map<String, dynamic>.from(value);
            } else {
              tagData[key] = value;
            }
          });

          setState(() {
            _tagData = tagData;
            _isReading = false;
            _canClone = true;
            _statusMessage = 'Card read successfully! Ready to clone.';
          });

          // Stop the NFC session after reading
          NfcManager.instance.stopSession();
        },
      );
    } catch (e) {
      setState(() {
        _isReading = false;
        _statusMessage = 'Error starting NFC: ${e.toString()}';
      });
    }
  }

  void _cloneCard() {
    setState(() {
      _statusMessage = 'Place the target card to write data...';
    });

    try {
      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          try {
            // In a real app, you would implement the actual writing logic here
            // This is simplified for demonstration
            await Future.delayed(const Duration(seconds: 2));

            setState(() {
              _statusMessage = 'Card cloned successfully!';
              _canClone = false;
            });

            // Stop the NFC session after writing
            NfcManager.instance.stopSession();
          } catch (e) {
            setState(() {
              _statusMessage = 'Error cloning card: ${e.toString()}';
            });
            NfcManager.instance.stopSession();
          }
        },
      );
    } catch (e) {
      setState(() {
        _statusMessage = 'Error starting NFC: ${e.toString()}';
      });
    }
  }

  void _stopSession() {
    try {
      NfcManager.instance.stopSession();
      setState(() {
        _isReading = false;
        _statusMessage = 'NFC reading cancelled.';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error stopping NFC: ${e.toString()}';
      });
    }
  }

  void _showDemoData() {
    setState(() {
      _tagData = {
        'id': 'AD65DA23F59880',
        'standard': 'ISO 14443-3 (Type A)',
        'type': 'MIFARE Classic 1K',
        'atqa': [0x04, 0x00],
        'sak': 0x08,
        'historicalBytes': [0x90, 0x17, 0x00, 0xB8],
        'sector0': {
          'block0': [0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF],
          'block1': [0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF, 0x11, 0x22],
        },
      };
      _canClone = true;
      _statusMessage = 'Demo card data loaded! Ready to clone.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NFC Card Clone'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // NFC Status Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      _nfcAvailable ? Icons.nfc : Icons.nfc_outlined,
                      size: 48,
                      color: _nfcAvailable ? Colors.green : Colors.red,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _statusMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _nfcAvailable ? Colors.black87 : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Card Data Section
            if (_tagData != null) ...[
              const Text(
                'Card Data:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _tagData.toString(),
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Action Buttons
            if (_nfcAvailable && !_isReading && !_canClone)
              ElevatedButton.icon(
                icon: const Icon(Icons.search),
                label: const Text('READ NFC CARD'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: _startNfcReading,
              ),

            if (!_nfcAvailable && !_canClone)
              ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('LOAD DEMO DATA'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.white,
                ),
                onPressed: _showDemoData,
              ),

            if (_isReading)
              ElevatedButton.icon(
                icon: const Icon(Icons.stop),
                label: const Text('CANCEL READING'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: _stopSession,
              ),

            if (_canClone)
              ElevatedButton.icon(
                icon: const Icon(Icons.copy),
                label: const Text('CLONE CARD'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: _cloneCard,
              ),
          ],
        ),
      ),
    );
  }
}
