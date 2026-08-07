class UploadSignature {
  final String storageConfigId;
  final String uploadUrl;
  final String key;
  final String contentType;
  final int expireSeconds;

  UploadSignature({
    required this.storageConfigId,
    required this.uploadUrl,
    required this.key,
    this.contentType = '',
    this.expireSeconds = 0,
  });

  factory UploadSignature.fromJson(dynamic data) {
    final map = Map<String, dynamic>.from(data as Map);
    return UploadSignature(
      storageConfigId: map['storage_config_id']?.toString() ?? '',
      uploadUrl: map['upload_url']?.toString() ?? '',
      key: map['key']?.toString() ?? '',
      contentType: map['content_type']?.toString() ?? '',
      expireSeconds: map['expire_seconds'] is int
          ? map['expire_seconds'] as int
          : int.tryParse('${map['expire_seconds'] ?? 0}') ?? 0,
    );
  }
}
