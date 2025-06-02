import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safenest/config/theme.dart';
import 'package:safenest/services/location_service.dart';
import 'package:safenest/widgets/custom_button.dart';

class DangerMapScreen extends ConsumerStatefulWidget {
  const DangerMapScreen({super.key});

  @override
  ConsumerState<DangerMapScreen> createState() => _DangerMapScreenState();
}

class _DangerMapScreenState extends ConsumerState<DangerMapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  bool _isLoading = true;
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      final location = await ref.read(locationServiceProvider).getCurrentLocation();
      if (location != null) {
        setState(() {
          _currentLocation = LatLng(location.latitude, location.longitude);
          _isLoading = false;
        });
        _loadDangerZones();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading map: ${e.toString()}')),
      );
    }
  }

  Future<void> _loadDangerZones() async {
    // TODO: Implement loading danger zones from Supabase
    // This will be implemented when we set up the danger zones table
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currentLocation != null) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentLocation!,
            zoom: 15,
          ),
        ),
      );
    }
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Danger Zone'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select the type of danger:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark Area'),
              onTap: () {
                Navigator.pop(context);
                _reportDangerZone('dark_area');
              },
            ),
            ListTile(
              leading: const Icon(Icons.warning),
              title: const Text('Harassment'),
              onTap: () {
                Navigator.pop(context);
                _reportDangerZone('harassment');
              },
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Other'),
              onTap: () {
                Navigator.pop(context);
                _reportDangerZone('other');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _reportDangerZone(String type) async {
    if (_currentLocation == null) return;

    try {
      // TODO: Implement reporting danger zone to Supabase
      // This will be implemented when we set up the danger zones table
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Danger zone reported successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error reporting danger zone: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danger Map'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentLocation == null
              ? const Center(child: Text('Unable to get current location'))
              : Stack(
                  children: [
                    GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: _currentLocation!,
                        zoom: 15,
                      ),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      markers: _markers,
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: FloatingActionButton(
                        onPressed: _showReportDialog,
                        backgroundColor: AppTheme.primaryColor,
                        child: const Icon(Icons.add_location),
                      ),
                    ),
                  ],
                ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
} 