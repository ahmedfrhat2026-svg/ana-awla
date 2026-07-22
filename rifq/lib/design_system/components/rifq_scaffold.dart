import 'package:flutter/material.dart';

import '../rifq_spacing.dart';
import '../rifq_theme_extensions.dart';

/// هيكل صفحة رِفْق — خلفية القماش الدافئة، حشو أفقي مريح،
/// وعنوان اختياري. يوحّد إيقاع المساحات عبر كل الشاشات.
class RifqScaffold extends StatelessWidget {
  const RifqScaffold({
    super.key,
    this.title,
    required this.body,
    this.actions,
    this.leading,
    this.scrollable = true,
    this.padded = true,
    this.floatingActionButton,
  });

  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? leading;

  /// عند true يُغلَّف [body] في ListView بحشو الصفحة القياسي.
  final bool scrollable;
  final bool padded;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final palette = RifqPalette.of(context);
    Widget content = body;
    if (padded && !scrollable) {
      content = Padding(padding: RifqSpacing.page, child: body);
    }
    return Scaffold(
      backgroundColor: palette.canvas,
      appBar: title == null
          ? null
          : AppBar(title: Text(title!), actions: actions, leading: leading),
      body: SafeArea(
        top: title == null,
        child: scrollable
            ? ListView(
                padding: padded ? RifqSpacing.page : EdgeInsets.zero,
                children: [body],
              )
            : content,
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

/// ترويسة صفحة كبيرة هادئة — للاستخدام داخل body بلا AppBar،
/// مناسبة للأنظمة الثلاثة (مرآة/بوصلة/ملجأ).
class RifqPageHeader extends StatelessWidget {
  const RifqPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final palette = RifqPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: RifqSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (onBack != null)
            Padding(
              padding: const EdgeInsets.only(left: RifqSpacing.xs, top: 2),
              child: IconButton(
                icon: const Icon(Icons.arrow_forward),
                tooltip: 'رجوع',
                onPressed: onBack,
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                if (subtitle != null) ...[
                  const SizedBox(height: RifqSpacing.xxs),
                  Text(subtitle!,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: palette.textSecondary)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
