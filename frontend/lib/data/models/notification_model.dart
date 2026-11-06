class NotificationModel {
      final int unreadCount;

        const NotificationModel({
            required this.unreadCount,
              });

                factory NotificationModel.fromJson(Map<String, dynamic> json) {
                    return NotificationModel(
                          unreadCount: json['unreadCount'] as int,
                              );
                                }
                                }
