/// WebSocket notification model matching backend NotificationWSDTO
class NotificationWS {
  final int? id;
  final int? itemId;
  final String? type;
  final String? content;

  NotificationWS({
    this.id,
    this.itemId,
    this.type,
    this.content,
  });

  factory NotificationWS.fromJson(Map<String, dynamic> json) {
    return NotificationWS(
      id: json['id'] as int?,
      itemId: json['itemId'] as int?,
      type: json['type'] as String?,
      content: json['content'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemId': itemId,
      'type': type,
      'content': content,
    };
  }

  @override
  String toString() {
    return 'NotificationWS{id: $id, itemId: $itemId, type: $type, content: $content}';
  }
}
