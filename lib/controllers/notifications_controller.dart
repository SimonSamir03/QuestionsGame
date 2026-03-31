import 'package:get/get.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class NotificationsController extends GetxController {
  final notifications = <NotificationItem>[].obs;
  final isLoading = true.obs;
  final readIds = <int>{}.obs;

  final _storage = StorageService();

  @override
  void onInit() {
    super.onInit();
    _loadReadIds();
    fetchNotifications();
  }

  void _loadReadIds() {
    final stored = _storage.read<List>('read_notification_ids');
    if (stored != null) {
      readIds.addAll(stored.cast<int>());
    }
  }

  void _saveReadIds() {
    _storage.write('read_notification_ids', readIds.toList());
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    final data = await ApiService().getNotifications();
    if (data != null) {
      notifications.value = data
          .map((json) => NotificationItem.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    }
    isLoading.value = false;
  }

  bool isRead(int id) => readIds.contains(id);

  void markAsRead(int id) {
    readIds.add(id);
    readIds.refresh();
    _saveReadIds();
  }

  void markAllAsRead() {
    for (final n in notifications) {
      readIds.add(n.id);
    }
    readIds.refresh();
    _saveReadIds();
  }

  int get unreadCount =>
      notifications.where((n) => !readIds.contains(n.id)).length;
}
