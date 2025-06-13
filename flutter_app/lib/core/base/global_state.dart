import 'package:package_info_plus/package_info_plus.dart';

import '../../data/models/must_update_model.dart';

class GlobalState {
  static String baseUrl = "";
  static String shinigamiUrl = "";
  static String refererUrl = "";
  static String commentUrl = "";
  static bool underMaintenance = false;
  static MustUpdateModel? mustUpdate;
  static PackageInfo? packageInfo;
}
