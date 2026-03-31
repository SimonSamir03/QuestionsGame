class ShopItemModel {
  final int     id;
  final String  slug;
  final String  type;       // coins | lives | premium | mystery_box
  final String  name;
  final String? description;
  final String? emoji;
  final int     priceCoins;
  final double  priceUsd;
  final int     rewardAmount;

  const ShopItemModel({
    required this.id,
    required this.slug,
    required this.type,
    required this.name,
    this.description,
    this.emoji,
    required this.priceCoins,
    required this.priceUsd,
    required this.rewardAmount,
  });

  factory ShopItemModel.fromJson(Map<String, dynamic> j) => ShopItemModel(
    id           : j['id']            as int,
    slug         : j['slug']          as String,
    type         : j['type']          as String,
    name         : j['name']          as String? ?? '',
    description  : j['description']   as String?,
    emoji        : j['emoji']         as String?,
    priceCoins   : (j['price_coins']  as num?)?.toInt()   ?? 0,
    priceUsd     : (j['price_usd']    as num?)?.toDouble() ?? 0,
    rewardAmount : (j['reward_amount'] as num?)?.toInt()  ?? 0,
  );
}
