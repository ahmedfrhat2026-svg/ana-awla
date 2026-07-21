import 'package:flutter/material.dart';

import '../../shared/widgets.dart';

/// صفحة الأمان وحدود التطبيق — واضحة وصادقة.
class SafetyScreen extends StatelessWidget {
  const SafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الأمان وحدود رِفْق')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          SectionCard(
            title: 'رِفْق ليس علاجًا',
            child: Text(
              'رِفْق رفيق عادات هادئ — ليس بديلًا عن طبيب أو معالج نفسي، '
              'ولا يشخّص أي اضطراب، ولا يقدّم علاجًا. تمارين التنفس هنا '
              'للاسترخاء العام فقط وليست تدخلًا طبيًا.',
            ),
          ),
          SectionCard(
            title: 'لو التعب أكبر من الفتور',
            child: Text(
              'لو استمر فقدان الطاقة أو المتعة لأسابيع، مع تغيّر واضح في '
              'النوم أو الشهية أو قدرتك على ممارسة حياتك — فالأفضل التحدث '
              'مع مختص نفسي. ولو عندك أفكار لإيذاء نفسك، كلّم فورًا شخصًا '
              'تثق فيه أو خدمة الطوارئ المحلية.',
            ),
          ),
          SectionCard(
            title: 'حدود دينية',
            child: Text(
              'التطبيق لا يصدر فتاوى ولا يحكم على النيات. كل نص ديني معروض '
              'موثّق المصدر من ملف بيانات محلي قابل للمراجعة، ولا يُخترع '
              'أي حديث أو نسبة دينية.',
            ),
          ),
          SectionCard(
            title: 'خصوصيتك',
            child: Text(
              'كل ما تكتبه يبقى على جهازك. لا يُرسل أي نص لأي خادم، '
              'حتى رسائل الدعم تظهر محليًا بالكامل.',
            ),
          ),
        ],
      ),
    );
  }
}
