import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safenest/config/routes.dart';
import 'package:safenest/config/theme.dart';
import 'package:safenest/services/auth_service.dart';
import 'package:safenest/services/location_service.dart';
import 'package:safenest/services/sos_service.dart';
import 'package:safenest/widgets/custom_button.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isLoading = false;
  bool _isSharingLocation = false;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    final locationService = ref.read(locationServiceProvider);
    await locationService.initialize();
  }

  Future<void> _handleSOS() async {
    setState(() => _isLoading = true);

    try {
      final sosService = ref.read(sosServiceProvider);
      await sosService.sendSOSAlert();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('SOS alert sent to your emergency contacts!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send SOS alert: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleLocationSharing() async {
    setState(() => _isSharingLocation = !_isSharingLocation);

    try {
      final locationService = ref.read(locationServiceProvider);
      if (_isSharingLocation) {
        await locationService.startLocationSharing();
      } else {
        await locationService.stopLocationSharing();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to ${_isSharingLocation ? 'start' : 'stop'} location sharing: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isSharingLocation = !_isSharingLocation);
    }
  }

  Future<void> _signOut() async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign out: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SafeNest'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Your Safety is Our Priority',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _isLoading ? null : _handleSOS,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isLoading
                              ? Colors.grey
                              : AppTheme.errorColor,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.errorColor.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'SOS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      onPressed: _toggleLocationSharing,
                      backgroundColor: _isSharingLocation
                          ? Colors.green
                          : AppTheme.primaryColor,
                      child: Text(
                        _isSharingLocation
                            ? 'Stop Sharing Location'
                            : 'Share Location',
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.dangerMap);
                      },
                      child: const Text('View Danger Map'),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.safeCircle);
                      },
                      child: const Text('Safe Circle'),
                    ),
                  ],
                ),
              ),
              CustomButton(
                onPressed: _signOut,
                isOutlined: true,
                child: const Text('Sign Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 