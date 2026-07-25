import 'package:flutter/material.dart';

import 'package:laforika/core/theme/app_semantic_colors.dart';
import 'package:laforika/core/theme/app_tokens.dart';

/// Focused RTL theme specimen used by width, text-scale, and golden tests.
class ThemeSpecimen extends StatelessWidget {
  const ThemeSpecimen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.semanticColors;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: colors.appBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.all(AppTokens.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text('عنوان نمایشی', style: theme.textTheme.headlineSmall),
                const SizedBox(height: AppTokens.spaceSm),
                Text(
                  'متن اصلی برای بررسی کنتراست و مقیاس',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: AppTokens.spaceSm),
                Text(
                  'متن ثانویه برای نقش‌های کم‌رنگ‌تر',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.secondaryText,
                  ),
                ),
                const SizedBox(height: AppTokens.spaceMd),
                Container(
                  padding: const EdgeInsetsDirectional.all(AppTokens.spaceMd),
                  decoration: BoxDecoration(
                    color: colors.primarySurface,
                    borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                    border: Border.all(
                      color: colors.border,
                      width: AppTokens.borderWidth,
                    ),
                  ),
                  child: Text('سطح اصلی', style: theme.textTheme.titleMedium),
                ),
                const SizedBox(height: AppTokens.spaceSm),
                Container(
                  padding: const EdgeInsetsDirectional.all(AppTokens.spaceMd),
                  decoration: BoxDecoration(
                    color: colors.secondarySurface,
                    borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                  ),
                  child: Text('سطح ثانویه', style: theme.textTheme.bodyMedium),
                ),
                const SizedBox(height: AppTokens.spaceSm),
                Material(
                  color: colors.elevatedSurface,
                  elevation: AppTokens.elevationLow,
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.all(AppTokens.spaceMd),
                    child: Text('سطح مرتفع', style: theme.textTheme.bodyMedium),
                  ),
                ),
                const SizedBox(height: AppTokens.spaceMd),
                Container(
                  padding: const EdgeInsetsDirectional.all(AppTokens.spaceSm),
                  color: colors.subtleSelection,
                  child: Text('انتخاب ظریف', style: theme.textTheme.labelLarge),
                ),
                const SizedBox(height: AppTokens.spaceMd),
                const TextField(
                  decoration: InputDecoration(labelText: 'فیلد نمونه'),
                ),
                const SizedBox(height: AppTokens.spaceMd),
                Wrap(
                  spacing: AppTokens.spaceSm,
                  runSpacing: AppTokens.spaceSm,
                  children: <Widget>[
                    FilledButton(onPressed: () {}, child: const Text('اصلی')),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('ثانویه'),
                    ),
                    OutlinedButton(onPressed: () {}, child: const Text('خطی')),
                    FilledButton(onPressed: null, child: const Text('غیرفعال')),
                  ],
                ),
                const SizedBox(height: AppTokens.spaceMd),
                Text(
                  'خطا',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.error,
                  ),
                ),
                Text(
                  'موفقیت',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.success,
                  ),
                ),
                const SizedBox(height: AppTokens.spaceMd),
                Align(
                  alignment: AlignmentDirectional.center,
                  child: SizedBox(
                    width: AppTokens.minTouchTarget,
                    height: AppTokens.minTouchTarget,
                    child: CircularProgressIndicator(
                      value: 0.65,
                      color: colors.brandAccent,
                      backgroundColor: colors.subtleSelection,
                    ),
                  ),
                ),
                const SizedBox(height: AppTokens.spaceMd),
                Divider(color: colors.border, thickness: AppTokens.borderWidth),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
