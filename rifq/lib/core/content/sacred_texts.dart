/// نصوص دينية موثّقة المصدر — لا يعرض التطبيق أي نص ديني خارج هذا الملف.
///
/// الآيات القرآنية منقولة حرفيًا (بالرسم الإملائي المبسّط دون تشكيل) من قاعدة
/// بيانات مركز تفسير للدراسات القرآنية عبر Tafsir MCP، مع ذكر السورة ورقم الآية.
/// نصوص التدبر منقولة حرفيًا من «هدايات القرآن الكريم — مصحف التدبّر»
/// (هدايات وتدبر — ليس تفسيرًا مسندًا) عبر نفس القاعدة.
/// الأذكار والأحاديث مقتصرة على المشهور المتفق على صحته مع ذكر مصدره.
/// لا يُضاف أي نص هنا دون مصدر قابل للمراجعة.
library;

class SacredText {
  const SacredText({
    required this.text,
    required this.source,
    this.kind = SacredKind.ayah,
    this.tadabbur,
    this.tadabburSource,
  });

  final String text;

  /// المصدر الموثّق: اسم السورة ورقم الآية، أو مصدر الحديث.
  final String source;
  final SacredKind kind;

  /// نص تدبّر اختياري منقول حرفيًا مع مصدره.
  final String? tadabbur;
  final String? tadabburSource;

  bool get hasTadabbur => tadabbur != null && tadabbur!.isNotEmpty;
}

enum SacredKind { ayah, dhikr, hadith, dua }

const String _tadabburSourceName =
    'هدايات القرآن الكريم — مصحف التدبّر (هدايات وتدبر، ليس تفسيرًا مسندًا)';

/// آيات وأذكار قصيرة للطمأنينة — تُعرض في خطوة «ارجع لقلبك» وبعد التنفّس.
const List<SacredText> calmingTexts = [
  SacredText(
    text: 'الذين آمنوا وتطمئن قلوبهم بذكر الله ألا بذكر الله تطمئن القلوب',
    source: 'سورة الرعد — الآية 28',
    tadabbur:
        'أيُّ قلبٍ لا يطمئنُّ وهو يَركَنُ إلى مولاه، ولا يزال يذكره، ويأنَس به وبالقرب منه؟',
    tadabburSource: _tadabburSourceName,
  ),
  SacredText(
    text: 'فإن مع العسر يسرا',
    source: 'سورة الشرح — الآية 5',
    tadabbur:
        'ابحث دومًا عن المِنَح المَخفيَّة في تلافيف المِحَن، واستخلص من العقَبات العسيرة دروسًا في التفاؤل والأمَل، فما كان عُسرٌ إلا صاحبَه يُسر.',
    tadabburSource: _tadabburSourceName,
  ),
  SacredText(
    text: 'إن مع العسر يسرا',
    source: 'سورة الشرح — الآية 6',
  ),
  SacredText(
    text: 'قال رب اشرح لي صدري',
    source: 'سورة طه — الآية 25',
    tadabbur:
        'إذا ما شرح اللهُ تعالى صدر الداعية هانت عليه تكاليفُ الدعوة، وسرَت روح تلك الطمأنينة التي يعيش بها إلى المدعوين.',
    tadabburSource: _tadabburSourceName,
  ),
  SacredText(
    text: 'ويسر لي أمري',
    source: 'سورة طه — الآية 26',
  ),
  SacredText(
    text: 'فاذكروني أذكركم واشكروا لي ولا تكفرون',
    source: 'سورة البقرة — الآية 152',
  ),
  SacredText(
    text: 'ولسوف يعطيك ربك فترضى',
    source: 'سورة الضحى — الآية 5',
  ),
  SacredText(
    text: 'سبحان الله وبحمده',
    source: 'ذكر ثابت — متفق عليه (البخاري ومسلم)',
    kind: SacredKind.dhikr,
  ),
  SacredText(
    text: 'لا حول ولا قوة إلا بالله',
    source: 'ذكر ثابت — متفق عليه (البخاري ومسلم)',
    kind: SacredKind.dhikr,
  ),
  SacredText(
    text: 'أستغفر الله',
    source: 'ذكر ثابت في السنة الصحيحة',
    kind: SacredKind.dhikr,
  ),
  SacredText(
    text: 'اللهم أعني على ذكرك وشكرك وحسن عبادتك',
    source: 'دعاء صحيح — رواه أبو داود والنسائي من حديث معاذ بن جبل',
    kind: SacredKind.dua,
  ),
];

/// حديث روح التطبيق — الاستمرار الصغير خير من الاندفاع المنقطع.
const SacredText appSpiritHadith = SacredText(
  text: 'أحب الأعمال إلى الله أدومها وإن قل',
  source: 'حديث صحيح — متفق عليه (رواه البخاري ومسلم) بألفاظ متقاربة',
  kind: SacredKind.hadith,
);

/// آيات «بوابة القرآن» قبل فتح إنستجرام — قراءة هادئة تعيد النية.
/// نفس القائمة الموثقة؛ الآيات فقط دون الأذكار.
List<SacredText> get gateAyat =>
    calmingTexts.where((t) => t.kind == SacredKind.ayah).toList();
