import 'package:package_info_plus/package_info_plus.dart';

class GlobalState {
  static String baseUrl = "";
  static String shinigamiUrl = "";
  static String refererUrl = "";
  static String commentUrl = "";
  static bool underMaintenance = false;
  static PackageInfo? packageInfo;
}
