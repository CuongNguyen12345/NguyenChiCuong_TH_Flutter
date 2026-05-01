import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../services/location_service.dart';

class LocationProvider extends ChangeNotifier {
  final LocationService _locationService;

  Position? _position;
  LocationPermission _permission = LocationPermission.denied;
  bool _serviceEnabled = true;
  String _cityName = 'Unknown';

  LocationProvider(this._locationService);

  Position? get position => _position;
  LocationPermission get permission => _permission;
  bool get serviceEnabled => _serviceEnabled;
  String get cityName => _cityName;

  Future<void> refreshLocation() async {
    _serviceEnabled = await Geolocator.isLocationServiceEnabled();
    _permission = await Geolocator.checkPermission();

    if (!_serviceEnabled) {
      notifyListeners();
      return;
    }

    if (_permission == LocationPermission.denied) {
      _permission = await Geolocator.requestPermission();
    }

    if (_permission == LocationPermission.deniedForever ||
        _permission == LocationPermission.denied) {
      notifyListeners();
      return;
    }

    _position = await _locationService.getCurrentLocation();
    _cityName = await _locationService.getCityName(
      _position!.latitude,
      _position!.longitude,
    );
    notifyListeners();
  }
}
