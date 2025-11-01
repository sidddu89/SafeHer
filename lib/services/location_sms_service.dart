import 'dart:async';
import 'dart:io' show Platform;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'location_service.dart';

class LocationSmsService {

  static const MethodChannel _smsChannel = MethodChannel('com.example.safeher/sms');

  /// Validate Indian mobile number (10 digits starting with 6-9)
  static bool isValidMobile(String mobile) {
    if (mobile.length != 10) return false;
    final firstDigit = mobile[0];
    return ['6', '7', '8', '9'].contains(firstDigit);
  }

  /// Pre-warm location services to ensure we have a cached position
  /// Call this when app starts or when user navigates to panic button screen
  Future<void> prewarmLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint("SafeHer: Cannot prewarm - GPS disabled");
        return;
      }

      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || 
          permission == LocationPermission.deniedForever) {
        debugPrint("SafeHer: Cannot prewarm - no permission");
        return;
      }

      debugPrint("SafeHer: Prewarming location...");
      Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 10),
      ).then((pos) {
        debugPrint("SafeHer: Location prewarmed: ${pos.latitude}, ${pos.longitude}");
      }).catchError((e) {
        debugPrint("SafeHer: Prewarm failed (not critical): $e");
      });
    } catch (e) {
      debugPrint("SafeHer: Prewarm error (not critical): $e");
    }
  }

  /// Get current location using the dedicated LocationService with Samsung-optimized GPS handling
  Future<Position?> getCurrentLocation() async {
    final locationService = LocationService();
    
    try {
      debugPrint("SafeHer: Attempting to get location using dedicated LocationService...");
      
      // First try: Use the GPS-optimized LocationService with shorter timeout for emergency
      try {
        final position = await locationService.getCurrentPositionGpsOnly(
          timeLimit: Duration(seconds: 15), // Shorter timeout for emergency situations
        );
        debugPrint("SafeHer: Got GPS location: ${position.latitude}, ${position.longitude}");
        return position;
      } catch (e) {
        debugPrint("SafeHer: GPS-optimized location failed: $e");
      }
      
      // Fallback 1: Try to get last known position (instant)
      try {
        final lastPosition = await Geolocator.getLastKnownPosition();
        if (lastPosition != null) {
          debugPrint("SafeHer: Using last known position: ${lastPosition.latitude}, ${lastPosition.longitude}");
          return lastPosition;
        }
      } catch (e) {
        debugPrint("SafeHer: Last known position failed: $e");
      }
      
      // Fallback 2: Try basic location with network assistance (for Samsung devices that may have GPS issues)
      try {
        debugPrint("SafeHer: Trying network-assisted location...");
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        );
        debugPrint("SafeHer: Got network-assisted location: ${position.latitude}, ${position.longitude}");
        return position;
      } catch (e) {
        debugPrint("SafeHer: Network-assisted location failed: $e");
      }
      
      // Fallback 3: Try low accuracy as last resort
      try {
        debugPrint("SafeHer: Trying low accuracy location as last resort...");
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 8),
        );
        debugPrint("SafeHer: Got low accuracy location: ${position.latitude}, ${position.longitude}");
        return position;
      } catch (e) {
        debugPrint("SafeHer: Low accuracy location failed: $e");
      }
      
      debugPrint("SafeHer: All location strategies failed");
      return null;
    } catch (e) {
      debugPrint("SafeHer: Error in getCurrentLocation: $e");
      return null;
    }
  }
  

  /// Build SOS alert message
  Future<String> buildAlertMessage(String userName) async {
    final position = await getCurrentLocation();
    final buffer = StringBuffer();

    buffer.writeln("$userName needs IMMEDIATE HELP!");
    buffer.writeln("Location:");

    if (position != null) {
      // Reverse geocode to get a readable place name
      String placeName = await _getPlaceName(position);
      buffer.writeln(placeName.isNotEmpty ? placeName : "Unknown area");
      buffer.writeln("Latitude: ${position.latitude}");
      buffer.writeln("Longitude: ${position.longitude}");
      buffer.writeln("Google Maps:");
      buffer.writeln(
          "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}");
    } else {
      buffer.writeln("Location unavailable");
    }

    buffer.writeln("Please reach out as soon as possible.");

    return buffer.toString();
  }

  /// Get a human-readable place name from coordinates
  Future<String> _getPlaceName(Position position) async {
    try {
      debugPrint('SafeHer: Attempting reverse geocoding for ${position.latitude}, ${position.longitude}');
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        debugPrint('SafeHer: Placemark found - name: ${p.name}, locality: ${p.locality}, subLocality: ${p.subLocality}, thoroughfare: ${p.thoroughfare}, administrativeArea: ${p.administrativeArea}');
        
        // Build a more comprehensive location string with better fallbacks
        final parts = <String>[];
        
        // Add street/building name if available
        if ((p.name ?? '').trim().isNotEmpty && p.name != p.locality) {
          parts.add(p.name!.trim());
        }
        
        // Add thoroughfare (street) if available and different from name
        if ((p.thoroughfare ?? '').trim().isNotEmpty && p.thoroughfare != p.name) {
          parts.add(p.thoroughfare!.trim());
        }
        
        // Add sub-locality (neighborhood/area)
        if ((p.subLocality ?? '').trim().isNotEmpty) {
          parts.add(p.subLocality!.trim());
        }
        
        // Add locality (city/town)
        if ((p.locality ?? '').trim().isNotEmpty) {
          parts.add(p.locality!.trim());
        }
        
        // Add administrative area (state) if locality is not available or different
        if ((p.administrativeArea ?? '').trim().isNotEmpty && 
            (p.locality?.isEmpty ?? true || p.administrativeArea != p.locality)) {
          parts.add(p.administrativeArea!.trim());
        }
        
        // Add country if available and not India (since most users are in India)
        if ((p.country ?? '').trim().isNotEmpty && p.country != 'India') {
          parts.add(p.country!.trim());
        }
        
        final result = parts.join(', ');
        debugPrint('SafeHer: Generated place name: $result');
        return result.isNotEmpty ? result : 'Near ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      }
    } catch (e) {
      debugPrint('SafeHer: Reverse geocoding failed: $e');
    }
    return 'Near ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
  }


  /// Send SMS alert to all contacts
  Future<List<Map<String, String?>>> sendAlertToContacts(
    List<Map<String, String>> contacts,
    String userName,
  ) async {
    final List<Map<String, String?>> results = [];
    final alertMessage = await buildAlertMessage(userName);

    // Filter out empty phone numbers and format them
    final List<String> validPhones = [];
    for (var contact in contacts) {
      final phone = contact['phone'] ?? '';
      if (phone.isNotEmpty) {
        // Add +91 prefix if not present and doesn't start with +
        final formattedPhone = phone.startsWith('+')
            ? phone
            : (phone.startsWith('0') ? '+91${phone.substring(1)}' : '+91$phone');
        validPhones.add(formattedPhone);
      }
    }

    if (validPhones.isEmpty) {
      for (var contact in contacts) {
        results.add({
          'name': contact['name'],
          'phone': contact['phone'],
          'status': 'Failed to send SMS',
          'error': 'No valid phone numbers found',
        });
      }
      return results;
    }

    // Prefer direct SMS on Android; do NOT open composer on Android
    if (Platform.isAndroid) {
      try {
        // Try to get READ_PHONE_STATE (Permission.phone) to allow choosing correct SIM on dual-SIM
        try {
          final phonePerm = await Permission.phone.request();
          if (!phonePerm.isGranted) {
            debugPrint('SafeHer: READ_PHONE_STATE not granted; will fallback to default SmsManager');
          }
        } catch (e) {
          debugPrint('SafeHer: Error requesting phone permission (non-fatal): $e');
        }

        // Request runtime SMS permission
        final perm = await Permission.sms.request();
        if (!perm.isGranted) {
          throw Exception('SMS permission not granted');
        }

        // Send individually to improve reliability and to capture per-contact status
        for (final contact in contacts) {
          final raw = (contact['phone'] ?? '').trim();
          if (raw.isEmpty) {
            results.add({
              'name': contact['name'],
              'phone': raw,
              'status': 'Failed to send SMS',
              'error': 'Phone number is empty',
            });
            continue;
          }
          final formattedPhone = raw.startsWith('+')
              ? raw
              : (raw.startsWith('0') ? '+91${raw.substring(1)}' : '+91$raw');

          try {
            debugPrint('SafeHer: Attempting to send SMS to $formattedPhone');
            debugPrint('SafeHer: Message length: ${alertMessage.length}');
            
            final ok = await _smsChannel.invokeMethod<bool>('sendSms', {
              'phone': formattedPhone,
              'message': alertMessage,
            });
            
            if (ok == true) {
              debugPrint('SafeHer: SMS sent successfully to ${contact['name']} ($raw)');
              results.add({
                'name': contact['name'],
                'phone': raw,
                'status': 'SMS sent successfully',
                'error': null,
              });
            } else {
              throw Exception('Native sendSms returned false');
            }
          } on PlatformException catch (e) {
            // Capture detailed error from native code
            final errorDetail = e.message ?? e.code;
            debugPrint('SafeHer: SMS PlatformException for ${contact['name']} ($raw): ${e.code} - ${e.message}');
            results.add({
              'name': contact['name'],
              'phone': raw,
              'status': 'Failed to send SMS',
              'error': errorDetail,
            });
          } catch (e) {
            debugPrint('SafeHer: SMS failed for ${contact['name']} ($raw): $e');
            results.add({
              'name': contact['name'],
              'phone': raw,
              'status': 'Failed to send SMS',
              'error': e.toString(),
            });
          }
        }
      } catch (e) {
        debugPrint('Direct SMS failed on Android: $e');
        // Do not open composer on Android as per requirement; report failures
        if (results.isEmpty) {
          for (var contact in contacts) {
            results.add({
              'name': contact['name'],
              'phone': contact['phone'],
              'status': 'Failed to send SMS',
              'error': 'Direct SMS error: ' + e.toString(),
            });
          }
        }
      }
    } else {
      await _openComposerFallback(contacts, validPhones, alertMessage, results);
    }

    return results;
  }

  Future<void> _openComposerFallback(
    List<Map<String, String>> contacts,
    List<String> validPhones,
    String alertMessage,
    List<Map<String, String?>> results,
  ) async {
    try {
      final recipientsString = validPhones.join(',');
      final encodedMessage = Uri.encodeComponent(alertMessage);
      final smsUri = Uri.parse('sms:$recipientsString?body=$encodedMessage');
      final launched = await launchUrl(smsUri);
      if (launched) {
        for (var contact in contacts) {
          final phone = contact['phone'] ?? '';
          if (phone.isNotEmpty) {
            results.add({
              'name': contact['name'],
              'phone': phone,
              'status': 'SMS app opened with all contacts',
              'error': null,
            });
          } else {
            results.add({
              'name': contact['name'],
              'phone': phone,
              'status': 'Failed to send SMS',
              'error': 'Phone number is empty',
            });
          }
        }
      } else {
        throw Exception('Could not launch SMS app');
      }
    } catch (e) {
      debugPrint('Error opening SMS app: $e');
      for (var contact in contacts) {
        results.add({
          'name': contact['name'],
          'phone': contact['phone'],
          'status': 'Failed to open SMS app',
          'error': e.toString(),
        });
      }
    }
  }
}
