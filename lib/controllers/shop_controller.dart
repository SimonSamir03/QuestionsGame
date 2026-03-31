import 'package:get/get.dart';
import '../models/shop_item_model.dart';
import '../services/api_service.dart';

class ShopController extends GetxController {
  final items = <ShopItemModel>[].obs;
  final isLoading = true.obs;

  static const _fallback = [
    {'id': 1, 'slug': 'coins_100',  'type': 'coins',   'name': '100 Coins',  'emoji': '🪙', 'price_coins': 0, 'price_usd': 0.99, 'reward_amount': 100},
    {'id': 2, 'slug': 'coins_500',  'type': 'coins',   'name': '500 Coins',  'emoji': '💰', 'price_coins': 0, 'price_usd': 3.99, 'reward_amount': 500},
    {'id': 3, 'slug': 'coins_1000', 'type': 'coins',   'name': '1000 Coins', 'emoji': '🏦', 'price_coins': 0, 'price_usd': 6.99, 'reward_amount': 1000},
    {'id': 4, 'slug': 'lives_5',    'type': 'lives',   'name': '5 Lives',    'emoji': '❤️', 'price_coins': 0, 'price_usd': 0.99, 'reward_amount': 5},
    {'id': 5, 'slug': 'premium',    'type': 'premium', 'name': 'Premium',    'emoji': '👑', 'price_coins': 0, 'price_usd': 4.99, 'reward_amount': 0},
  ];

  List<ShopItemModel> get coinItems  => items.where((i) => i.type == 'coins').toList();
  List<ShopItemModel> get liveItems  => items.where((i) => i.type == 'lives').toList();
  ShopItemModel?      get premiumItem => items.where((i) => i.type == 'premium').firstOrNull;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts() async {
    isLoading.value = true;
    final data = await ApiService().getProducts();
    final list = data?['data'] as List?;
    if (list != null && list.isNotEmpty) {
      items.value = list
          .map((e) => ShopItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } else {
      items.value = _fallback
          .map((e) => ShopItemModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    isLoading.value = false;
  }
}
