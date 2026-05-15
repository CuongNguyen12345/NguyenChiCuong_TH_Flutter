import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestStoragePermission() async {
    if (!Platform.isAndroid) {
      return true;
    }

    final audioStatus = await Permission.audio.request();
    if (audioStatus.isGranted) {
      return true;
    }

    final storageStatus = await Permission.storage.request();
    if (storageStatus.isGranted) {
      return true;
    }

    if (audioStatus.isPermanentlyDenied || storageStatus.isPermanentlyDenied) {
      await openAppSettings();
    }
    return false;
  }

  Future<bool> requestAudioPermission() async {
    if (!Platform.isAndroid) {
      return true;
    }
    final status = await Permission.audio.request();
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
    return status.isGranted;
  }

  Future<bool> hasPermissions() async {
    if (!Platform.isAndroid) {
      return true;
    }
    return await Permission.audio.isGranted ||
        await Permission.storage.isGranted;
  }
}
