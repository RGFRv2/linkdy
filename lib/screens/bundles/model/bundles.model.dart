import 'package:linkdy/constants/enums.dart';
import 'package:linkdy/models/data/bookmark_bundles.dart';

class BundlesModel {
  List<BookmarkBundle> bundles;
  LoadStatus loadStatus;
  bool unsupportedServer;
  bool reordering;

  BundlesModel({
    this.bundles = const [],
    this.loadStatus = LoadStatus.loading,
    this.unsupportedServer = false,
    this.reordering = false,
  });
}
