import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionChecker {
  Future<bool> getPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.phone,
      Permission.camera,
      Permission.photos,
      Permission.notification,
    ].request();
    if (statuses[Permission.camera] == PermissionStatus.denied ||
        statuses[Permission.photos] == PermissionStatus.denied ||
        statuses[Permission.notification] == PermissionStatus.denied ||
        statuses[Permission.camera] == PermissionStatus.restricted ||
        statuses[Permission.photos] == PermissionStatus.restricted ||
        statuses[Permission.notification] == PermissionStatus.restricted) {
      if (Platform.isAndroid) {
        if (statuses[Permission.phone] == PermissionStatus.denied ||
            statuses[Permission.storage] == PermissionStatus.denied ||
            statuses[Permission.phone] == PermissionStatus.restricted ||
            statuses[Permission.storage] == PermissionStatus.restricted) {
          return false;
        }
      }
      return false;
    } else
      return true;
  }
}
