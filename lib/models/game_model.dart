class GameModel {
  final int     id;
  final String  slug;
  final String  emoji;
  final String  name;
  final String? description;

  const GameModel({
    required this.id,
    required this.slug,
    required this.emoji,
    required this.name,
    this.description,
  });

  factory GameModel.fromJson(Map<String, dynamic> j) => GameModel(
    id          : j['id']          as int,
    slug        : j['slug']        as String,
    emoji       : j['emoji']       as String? ?? '',
    name        : j['name']        as String? ?? '',
    description : j['description'] as String?,
  );
}
