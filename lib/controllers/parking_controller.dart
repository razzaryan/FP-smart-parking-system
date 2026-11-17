import 'package:flutter/material.dart';

class ParkingController extends ChangeNotifier {
  final List<bool> _slotsOccupied = [true, false, false, false];

  int? _myBookedSlot;
  String? _checkInTime;

  bool _wifiConnected = false;
  String _sensorIp = '192.168.1.100';
  final String _ssidName = 'ESP32_PARKIR';

  List<bool> get slotsOccupied => List.unmodifiable(_slotsOccupied);
  int? get myBookedSlot => _myBookedSlot;
  String? get checkInTime => _checkInTime;
  bool get wifiConnected => _wifiConnected;
  String get sensorIp => _sensorIp;
  String get ssidName => _ssidName;

  int get maxCapacity => _slotsOccupied.length;
  int get occupiedCount => _slotsOccupied.where((occupied) => occupied).length;
  int get availableCount => maxCapacity - occupiedCount;
  bool get isFull => occupiedCount >= maxCapacity;
  double get occupancyRate => occupiedCount / maxCapacity;

  bool bookSlot(int index, {required VoidCallback onAlreadyBooked, required VoidCallback onSuccess}) {
    if (_myBookedSlot != null) {
      onAlreadyBooked();
      return false;
    }

    if (!_slotsOccupied[index]) {
      final now = TimeOfDay.now();
      _slotsOccupied[index] = true;
      _myBookedSlot = index;
      _checkInTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} WIB';
      notifyListeners();
      onSuccess();
      return true;
    }
    return false;
  }

  int? checkout() {
    if (_myBookedSlot != null) {
      final int releasedSlot = _myBookedSlot! + 1;
      _slotsOccupied[_myBookedSlot!] = false;
      _myBookedSlot = null;
      _checkInTime = null;
      notifyListeners();
      return releasedSlot;
    }
    return null;
  }

  bool adminCarEnter() {
    if (!_wifiConnected) return false;
    final int emptyIndex = _slotsOccupied.indexOf(false);
    if (emptyIndex != -1) {
      _slotsOccupied[emptyIndex] = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  bool adminCarExit() {
    if (!_wifiConnected) return false;
    for (int i = maxCapacity - 1; i >= 0; i--) {
      if (_slotsOccupied[i] && i != _myBookedSlot) {
        _slotsOccupied[i] = false;
        notifyListeners();
        return true;
      }
    }
    if (_myBookedSlot != null) {
      _slotsOccupied[_myBookedSlot!] = false;
      _myBookedSlot = null;
      _checkInTime = null;
      notifyListeners();
      return true;
    }
    return false;
  }

  bool adminToggleSlot(int index) {
    if (!_wifiConnected) {
      return false;
    }
    _slotsOccupied[index] = !_slotsOccupied[index];
    if (!_slotsOccupied[index] && _myBookedSlot == index) {
      _myBookedSlot = null;
      _checkInTime = null;
    }
    notifyListeners();
    return true;
  }

  void toggleWifi(String ip) {
    _wifiConnected = !_wifiConnected;
    _sensorIp = ip;
    notifyListeners();
  }

  bool resetAll() {
    if (!_wifiConnected) return false;
    for (int i = 0; i < maxCapacity; i++) {
      _slotsOccupied[i] = false;
    }
    _myBookedSlot = null;
    _checkInTime = null;
    notifyListeners();
    return true;
  }
}
