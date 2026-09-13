// lib/screens/notifications_screen.dart

import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../config/theme.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  void _fetchNotifications() async {
    final res = await ApiService.get(ApiConfig.notifications);
    if (res['success'] == true && res['data'] != null) {
      if (res['data']['notifications'] != null) {
        setState(() {
          _notifications = (res['data']['notifications'] as List).map((n) => NotificationModel.fromJson(n)).toList();
          _isLoading = false;
        });
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(child: Text("No notifications yet."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notif = _notifications[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.roseLight,
                          child: Icon(
                            notif.type == 'booking' ? Icons.calendar_today : Icons.notifications,
                            color: AppTheme.primary,
                            size: 20,
                          ),
                        ),
                        title: Text(notif.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(notif.message),
                      ),
                    );
                  },
                ),
    );
  }
}
