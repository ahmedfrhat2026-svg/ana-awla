/// نصوص دينية موثّقة المصدر — لا يعرض التطبيق أي نص ديني خارج هذا الملف.
///
/// الآيات القرآنية منقولة حرفيًا (بالرسم الإملائي المبسّط دون تشكيل) من قاعدة
/// بيانات مركز تفسير للدراسات القرآنية عبر Tafsir MCP، مع ذكر السورة ورقم الآية.
/// الأذكار والأحاديث مقتصرة على المشهور المتفق على صحته مع ذكر مصدره.
/// لا يُضاف أي نص هنا دون مصدر قابل للمراجعة.
library;

class SacredText {
  const SacredText({
    required this.text,
    required this.source,
    this.kind = SacredKind.ayah,
  });

  final String text;

  /// المصدر الموثّق: اسم السورة ورقم الآية، أو مصدر الحديث.
  final String source;
  final SacredKind kind;
}

enum SacredKind { ayah, dhikr, hadith, dua }

/// آيات قصيرة للطمأنينة — تُعرض في خطوة «ارجع لقلبك» من جلسة العودة.
const List<SacredText> calmingTexts = [
  SacredText(
    text: 'الذين آمنوا وتطمئن قلوبهم بذكر الله ألا بذكر الله تطمئن القلوب',
    source: 'سورة الرعد — الآية 28',
  ),
  SacredText(
    text: 'فإن مع العسر يسرا',
    source: 'سورة الشرح — الآية 5',
  ),
  SacredText(
    text: 'إن مع العسر يسرا',
    source: 'سورة الشرح — الآية 6',
  ),
  SacredText(
    text: 'قال رب اشرح لي صدري',
    source: 'سورة طه — الآية 25',
  ),
  SacredText(
    text: 'ويسر لي أمري',
    source: 'سورة طه — الآية 26',
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
];

/// حديث روح التطبيق — الاستمرار الصغير خير من الاندفاع المنقطع.
const SacredText appSpiritHadith = SacredText(
  text: 'أحب الأعمال إلى الله أدومها وإن قل',
  source: 'حديث صحيح — متفق عليه (رواه البخاري ومسلم) بألفاظ متقاربة',
  kind: SacredKind.hadith,
);
