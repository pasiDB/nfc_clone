import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'home_screen.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NFC Card Clone',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AuthScreen(),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  bool _isBiometricSupported = false;
  String _authStatus = 'Not Authenticated';
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _checkPlatformSupport();
  }

  Future<void> _checkPlatformSupport() async {
    if (kIsWeb) {
      setState(() {
        _authStatus = 'Biometric authentication not available in web browsers';
      });
      return;
    }

    if (!(Platform.isAndroid || Platform.isIOS)) {
      setState(() {
        _authStatus =
            'Biometric authentication only supported on mobile devices';
      });
      return;
    }

    try {
      // Check if biometrics are available on the device
      _canCheckBiometrics = await auth.canCheckBiometrics;

      // Check if the device supports biometrics
      _isBiometricSupported = await auth.isDeviceSupported();

      setState(() {
        _authStatus =
            _isBiometricSupported
                ? 'Biometric authentication available'
                : 'Biometric authentication not supported';
      });
    } on PlatformException catch (e) {
      setState(() {
        _authStatus = 'Error checking biometrics: ${e.message}';
      });
    }
  }

  Future<void> _authenticate() async {
    setState(() {
      _isAuthenticating = true;
      _authStatus = 'Authenticating...';
    });

    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Authenticate to access NFC Card Clone app',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      setState(() {
        _isAuthenticating = false;
        _authStatus =
            authenticated
                ? 'Authentication successful'
                : 'Authentication failed';
      });

      if (authenticated) {
        // Navigate to the main app screen
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      }
    } on PlatformException catch (e) {
      setState(() {
        _isAuthenticating = false;
        _authStatus = 'Error: ${e.message}';
      });
    }
  }

  void _continueWithoutBiometrics() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NFC Card Clone'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.security, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              const Text(
                'NFC Card Clone',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                _authStatus,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color:
                      _authStatus.contains('Error')
                          ? Colors.red
                          : Colors.black87,
                ),
              ),
              const SizedBox(height: 32),
              if (!kIsWeb &&
                  (Platform.isAndroid || Platform.isIOS) &&
                  _canCheckBiometrics &&
                  _isBiometricSupported)
                ElevatedButton.icon(
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('AUTHENTICATE'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _isAuthenticating ? null : _authenticate,
                ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _continueWithoutBiometrics,
                child: const Text('Continue without biometrics'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
