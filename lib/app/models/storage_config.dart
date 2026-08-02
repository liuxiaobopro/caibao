import 'package:nylo_framework/nylo_framework.dart';

class S3StorageConfig extends Model {
  static StorageKey key = 'storage_config';

  String? id;
  String? name;
  String? endpoint;
  String? region;
  String? bucket;
  String? accessKeyId;
  String? secretAccessKey;
  String? domain;
  bool forcePathStyle;
  bool enabled;

  S3StorageConfig({
    this.id,
    this.name,
    this.endpoint,
    this.region,
    this.bucket,
    this.accessKeyId,
    this.secretAccessKey,
    this.domain,
    this.forcePathStyle = false,
    this.enabled = false,
  }) : super(key: key);

  S3StorageConfig.fromJson(dynamic data)
      : id = data['id']?.toString(),
        name = data['name']?.toString(),
        endpoint = data['endpoint']?.toString(),
        region = data['region']?.toString(),
        bucket = data['bucket']?.toString(),
        accessKeyId = data['access_key_id']?.toString(),
        secretAccessKey = data['secret_access_key']?.toString(),
        domain = data['domain']?.toString(),
        forcePathStyle = data['force_path_style'] == true,
        enabled = data['enabled'] == true,
        super(key: key);

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'endpoint': endpoint,
        'region': region,
        'bucket': bucket,
        'access_key_id': accessKeyId,
        'secret_access_key': secretAccessKey,
        'domain': domain,
        'force_path_style': forcePathStyle,
        'enabled': enabled,
      };
}
