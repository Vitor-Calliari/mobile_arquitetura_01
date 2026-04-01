import 'package:flutter/foundation.dart';

class FavoritesViewModel extends ChangeNotifier {
  final Set<int> _favoriteIds = {};

  bool isFavorite(int productId) => _favoriteIds.contains(productId);

  void toggleFavorite(int productId) {
    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
    } else {
      _favoriteIds.add(productId);
    }
    notifyListeners();
  }
}