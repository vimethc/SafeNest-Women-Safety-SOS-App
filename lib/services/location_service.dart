import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:safenest/config/constants.dart';
import 'package:safenest/services/auth_service.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService(ref);
});

class LocationService {
  final Ref _ref;
  final _supabase = Supabase.instance.client;
  Timer? _locationUpdateTimer;
  bool _isInitialized = false;

  LocationService(this._ref);

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Request location permissions
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }

    _isInitialized = true;
  }

  Future<void> startLocationSharing() async {
    if (!_isInitialized) {
      await initialize();
    }

    // Start periodic location updates
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = Timer.periodic(
      Duration(seconds: Constants.locationUpdateInterval),
      (_) => _updateLocation(),
    );

    // Initial location update
    await _updateLocation();
  }

  Future<void> stopLocationSharing() async {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;

    // Clear last location from database
    try {
      final user = await _ref.read(authServiceProvider).getCurrentUser();
      if (user != null) {
        await _supabase
            .from('user_locations')
            .delete()
            .eq('user_id', user.id);
      }
    } catch (e) {
      print('Error clearing location: $e');
    }
  }

  Future<void> _updateLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final user = await _ref.read(authServiceProvider).getCurrentUser();
      if (user == null) return;

      await _supabase.from('user_locations').upsert({
        'user_id': user.id,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error updating location: $e');
    }
  }

  Future<Position?> getCurrentLocation() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }
} 