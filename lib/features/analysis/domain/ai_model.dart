/// Gemini models on the free Gemini Developer API that take a photo and reply
/// with structured JSON. Check https://firebase.google.com/docs/ai-logic/models
/// before changing the list: Google retires older models and closes them to
/// new projects.
enum AiModel {
  gemini38Flash('gemini-3.8-flash', 'Gemini 3.8 Flash'),
  gemini37Flash('gemini-3.7-flash', 'Gemini 3.7 Flash'),
  gemini36Flash('gemini-3.6-flash', 'Gemini 3.6 Flash'),
  gemini35FlashLite('gemini-3.5-flash-lite', 'Gemini 3.5 Flash-Lite');

  const AiModel(this.id, this.label);

  /// The model name Firebase AI Logic expects.
  final String id;
  final String label;

  // 3.7 Flash rather than the newer 3.8: on the free tier every model has its
  // own daily quota, and during device testing (2026-10-02) 3.8 Flash used up
  // its 20 requests and was often overloaded.
  static const fallback = AiModel.gemini37Flash;

  /// Falls back when [id] is missing or no longer listed, for example after a
  /// retired model is removed from this enum.
  static AiModel fromId(String? id) =>
      values.firstWhere((model) => model.id == id, orElse: () => fallback);
}
