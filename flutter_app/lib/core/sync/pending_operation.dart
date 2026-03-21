/// Represents a single pending HTTP operation queued for offline sync.
///
/// Created when a mutation request (POST, PATCH, PUT, DELETE) fails
/// due to network unavailability. Operations are replayed in FIFO order
/// when connectivity is restored.
class PendingOperation {
  /// Unique identifier for this operation (timestamp + partial UUID).
  final String id;

  /// HTTP method: POST, PATCH, PUT, or DELETE.
  final String method;

  /// Relative URL path (e.g. '/lotes', '/mortalidades/123').
  final String url;

  /// Request body as a JSON-compatible map, or null for DELETE requests.
  final Map<String, dynamic>? data;

  /// ISO 8601 timestamp of when this operation was created.
  final DateTime createdAt;

  const PendingOperation({
    required this.id,
    required this.method,
    required this.url,
    this.data,
    required this.createdAt,
  });

  /// Serialize to JSON map for storage or transmission.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'method': method,
      'url': url,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Deserialize from a JSON map.
  factory PendingOperation.fromJson(Map<String, dynamic> json) {
    return PendingOperation(
      id: json['id'] as String,
      method: json['method'] as String,
      url: json['url'] as String,
      data: json['data'] != null
          ? Map<String, dynamic>.from(json['data'] as Map)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  String toString() =>
      'PendingOperation(id: $id, method: $method, url: $url, createdAt: $createdAt)';
}
