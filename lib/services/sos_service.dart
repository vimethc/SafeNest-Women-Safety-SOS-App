import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:safenest/config/constants.dart';
import 'package:safenest/services/auth_service.dart';
import 'package:safenest/services/location_service.dart';

final sosServiceProvider = Provider<SOSService>((ref) {
  return SOSService(ref);
});

class SOSService {
  final Ref _ref;
  final _supabase = Supabase.instance.client;

  SOSService(this._ref);

  Future<void> sendSOSAlert() async {
    try {
      final user = await _ref.read(authServiceProvider).getCurrentUser();
      if (user == null) throw Exception('User not authenticated');

      final location = await _ref.read(locationServiceProvider).getCurrentLocation();
      if (location == null) throw Exception('Unable to get current location');

      // Create SOS alert in database
      final sosAlert = {
        'user_id': user.id,
        'latitude': location.latitude,
        'longitude': location.longitude,
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('sos_alerts').insert(sosAlert);

      // Trigger Supabase Edge Function to send notifications
      await _supabase.functions.invoke(
        'send-sos-notifications',
        body: {
          'user_id': user.id,
          'latitude': location.latitude,
          'longitude': location.longitude,
        },
      );

      // Start a timer to automatically deactivate the SOS alert
      Future.delayed(
        Duration(seconds: Constants.sosTimeout),
        () => _deactivateSOSAlert(user.id),
      );
    } catch (e) {
      print('Error sending SOS alert: $e');
      rethrow;
    }
  }

  Future<void> _deactivateSOSAlert(String userId) async {
    try {
      await _supabase
          .from('sos_alerts')
          .update({'status': 'resolved'})
          .eq('user_id', userId)
          .eq('status', 'active');
    } catch (e) {
      print('Error deactivating SOS alert: $e');
    }
  }

  Future<void> deactivateSOSAlert(String userId) async {
    await _deactivateSOSAlert(userId);
  }

  Future<Map<String, dynamic>?> getActiveSOSAlert(String userId) async {
    try {
      final response = await _supabase
          .from('sos_alerts')
          .select()
          .eq('user_id', userId)
          .eq('status', 'active')
          .order('created_at', ascending: false)
          .limit(1)
          .single();

      return response;
    } catch (e) {
      return null;
    }
  }

  Stream<List<Map<String, dynamic>>> watchSOSAlerts() {
    return _supabase
        .from('sos_alerts')
        .stream(primaryKey: ['id'])
        .eq('status', 'active')
        .order('created_at', ascending: false);
  }
} 