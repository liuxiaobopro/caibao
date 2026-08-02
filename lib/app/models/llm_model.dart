import 'package:nylo_framework/nylo_framework.dart';

class LlmModel extends Model {
  static StorageKey key = 'llm_model';

  String? id;
  String? name;
  String? model;
  String? baseUrl;
  String? apiKey;
  String? category;
  bool enabled;

  LlmModel({
    this.id,
    this.name,
    this.model,
    this.baseUrl,
    this.apiKey,
    this.category,
    this.enabled = false,
  }) : super(key: key);

  LlmModel.fromJson(dynamic data)
      : id = data['id']?.toString(),
        name = data['name']?.toString(),
        model = data['model']?.toString(),
        baseUrl = data['base_url']?.toString(),
        apiKey = data['api_key']?.toString(),
        category = data['category']?.toString(),
        enabled = data['enabled'] == true,
        super(key: key);

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'model': model,
        'base_url': baseUrl,
        'api_key': apiKey,
        'category': category,
        'enabled': enabled,
      };
}
