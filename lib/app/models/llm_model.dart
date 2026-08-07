import 'package:nylo_framework/nylo_framework.dart';

/// 对齐后端 `ModelCategory` / Web `LLMModelCategory`。
enum LlmModelCategory {
  text('text', '文本'),
  vision('vision', '视觉'),
  multimodal('multimodal', '多模态'),
  embedding('embedding', '向量'),
  rerank('rerank', '重排序'),
  image('image', '图像生成'),
  asr('asr', '语音识别'),
  tts('tts', '语音合成'),
  audio('audio', '音频'),
  video('video', '视频'),
  code('code', '代码'),
  moderation('moderation', '内容审核'),
  reasoning('reasoning', '推理');

  const LlmModelCategory(this.value, this.label);

  final String value;
  final String label;

  static LlmModelCategory? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final item in LlmModelCategory.values) {
      if (item.value == raw) return item;
    }
    return null;
  }

  static LlmModelCategory parse(
    String? raw, {
    LlmModelCategory fallback = LlmModelCategory.multimodal,
  }) {
    return tryParse(raw) ?? fallback;
  }
}

class LlmModel extends Model {
  static StorageKey key = 'llm_model';

  String? id;
  String? name;
  String? model;
  String? baseUrl;
  String? apiKey;
  LlmModelCategory? category;
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
        category = LlmModelCategory.tryParse(data['category']?.toString()),
        enabled = data['enabled'] == true,
        super(key: key);

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'model': model,
        'base_url': baseUrl,
        'api_key': apiKey,
        'category': category?.value,
        'enabled': enabled,
      };
}
