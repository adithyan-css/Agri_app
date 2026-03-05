import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// Holds the user's current GPS position.
final locationProvider =
    StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  final notifier = LocationNotifier();
  // Auto-fetch location on first access
  notifier.getCurrentLocation();
  return notifier;
});

class LocationState {
  final double? latitude;
  final double? longitude;
  final bool isLoading;
  final String? error;

  LocationState(
      {this.latitude, this.longitude, this.isLoading = false, this.error});

  bool get hasLocation => latitude != null && longitude != null;

  LocationState copyWith({
    double? latitude,
    double? longitude,
    bool? isLoading,
    String? error,
  }) {
    return LocationState(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(LocationState());

  StreamSubscription<Position>? _positionSub;

  Future<void> getCurrentLocation() async {
    // Skip if already loading
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
          isLoading: false,
          error: 'Location services are disabled. Please enable them.',
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = state.copyWith(
            isLoading: false,
            error: 'Location permission denied.',
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          isLoading: false,
          error:
              'Location permission permanently denied. Please enable in settings.',
        );
        return;
      }

      // Get current position first (one-shot)
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      state = state.copyWith(
        latitude: position.latitude,
        longitude: position.longitude,
        isLoading: false,
      );

      // Start listening for location updates in the background
      _startLocationStream();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to get location: $e',
      );
    }
  }

  /// Stream location updates so distance recalculates as user moves.
  void _startLocationStream() {
    _positionSub?.cancel();
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100, // update every 100m movement
      ),
    ).listen(
      (Position pos) {
        if (mounted) {
          state = state.copyWith(
            latitude: pos.latitude,
            longitude: pos.longitude,
            isLoading: false,
          );
        }
      },
      onError: (e) {
        // Silently ignore stream errors — we already have a position
      },
    );
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }
}
