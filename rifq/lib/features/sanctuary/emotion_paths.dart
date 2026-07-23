/// مسارات المشاعر في الملجأ — لكل حالة استجابة مختلفة تمامًا.
/// الهدف: يفهمك التطبيق في أقل من دقيقة ثم يعيدك للحياة بخطوة واحدة.
/// لا دفع للإنتاجية، لا اقتباسات تحفيزية، لا استجواب طويل.
library;

enum Emotion {
  tired,
  sad,
  afraid,
  distracted,
  bored,
  frustrated,
  overloaded,
  unknown,
}

extension EmotionLabel on Emotion {
  String get label => switch (this) {
        Emotion.tired => 'مرهق',
        Emotion.sad => 'حزين',
        Emotion.afraid => 'خائف',
        Emotion.distracted => 'مشتت',
        Emotion.bored => 'زهقان',
        Emotion.frustrated => 'محبط',
        Emotion.overloaded => 'مجهد ذهنيًا',
        Emotion.unknown => 'لا أعرف',
      };
}

/// استجابة الملجأ لحالة: عنوان لطيف، سطر تأطير، وأفعال صغيرة جدًا.
class EmotionResponse {
  const EmotionResponse({
    required this.opening,
    required this.actions,
    this.needsSupport = false,
    this.suggestBreathing = false,
    this.suggestVoiceNote = false,
  });

  /// سطر تأطير رحيم — يسمّي الحالة بلا حكم.
  final String opening;

  /// أفعال صغيرة جدًا (خطوة واحدة تكفي).
  final List<String> actions;

  /// حالات ثقيلة (الحزن) — نعرض لغة دعم وتواصل، لا أمرًا بالعمل.
  final bool needsSupport;

  /// اقتراح جلسة تنفّس بدل الكلام.
  final bool suggestBreathing;

  /// اقتراح تفريغ بالصوت.
  final bool suggestVoiceNote;
}

EmotionResponse responseFor(Emotion e) => switch (e) {
      Emotion.tired => const EmotionResponse(
          opening: 'جسدك يطلب راحة، لا إنجازًا. اسمع له.',
          actions: [
            'اشرب كوب ماء',
            'هل أكلت من ساعتين؟ كُل شيئًا خفيفًا',
            'نم عشرين دقيقة لو تقدر',
            'خفّف مطلوب اليوم — لك أن تتوقف',
          ],
        ),
      Emotion.sad => const EmotionResponse(
          opening: 'الحزن ليس مشكلة تُحَل الآن. مسموح لك أن تشعر به.',
          actions: [
            'سمِّ الشعور في كلمة واحدة',
            'كلّم شخصًا تثق فيه',
            'اجلس مع الشعور دقيقة دون أن تدفعه',
          ],
          needsSupport: true,
          suggestVoiceNote: true,
        ),
      Emotion.afraid => const EmotionResponse(
          opening: 'الخوف غالبًا توقّع، لا حقيقة. لنفصل بينهما برفق.',
          actions: [
            'اكتب أسوأ ما تخافه في جملة',
            'ما الحقيقة الآن مقابل التوقّع؟',
            'ما أصغر خطوة قابلة للرجوع؟',
            'أجّل أي قرار لا رجعة فيه حتى تهدأ',
          ],
        ),
      Emotion.distracted => const EmotionResponse(
          opening: 'مش محتاج تركيز طويل — محتاج تشيل مصدر تشتيت واحد.',
          actions: [
            'حط الموبايل في أوضة تانية',
            'اختار مهمة واحدة فقط',
            'افتح أول شيء قدامك بلا تفكير',
          ],
          suggestBreathing: true,
        ),
      Emotion.bored => const EmotionResponse(
          opening: 'الزهق مش عيب — غالبًا محتاج تغيير، مش انضباط.',
          actions: [
            'غيّر مكانك، ولو للبلكونة',
            'غيّر نوع النشاط بالكامل',
            'اتحرك خمس دقايق',
          ],
        ),
      Emotion.frustrated => const EmotionResponse(
          opening: 'الإحباط علامة إنك مهتم. خذ نفسًا، وانزل بالتوقّع.',
          actions: [
            'سمِّ اللي ضايقك في جملة',
            'نصّف المهمة، وخذ نصفها الأصغر',
            'ارفق بنفسك كما ترفق بصديق',
          ],
          suggestBreathing: true,
        ),
      Emotion.overloaded => const EmotionResponse(
          opening: 'دماغك مزدحم. مش محتاج تنظّم كله — تفرّغ حاجة واحدة.',
          actions: [
            'اكتب كل اللي في دماغك في ورقة بسرعة',
            'اختار سطرًا واحدًا فقط منها',
            'قلّل المدخلات: اقفل الإشعارات دلوقتي',
          ],
          suggestBreathing: true,
        ),
      Emotion.unknown => const EmotionResponse(
          opening: 'مش لازم تعرف السبب. نبدأ بفحص جسدي بسيط.',
          actions: [
            'نمت كفاية؟',
            'شربت ماء؟',
            'أكلت؟',
            'اتحركت النهارده؟',
            'في ألم أو ضوضاء أو عزلة طويلة؟',
          ],
        ),
    };
