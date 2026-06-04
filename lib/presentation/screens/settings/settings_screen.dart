import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:level_bot/core/extensions/context_extensions.dart';
import 'package:level_bot/core/theme/app_colors.dart';
import 'package:level_bot/presentation/providers/audio_provider.dart';
import 'package:level_bot/presentation/providers/locale_provider.dart';
import 'package:level_bot/presentation/providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final audioSettings = ref.watch(audioSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        children: [
          _SectionHeader(title: l10n.preferencesSection),
          ListTile(
            leading: _IconBox(
              color: AppColors.primary,
              icon: Icons.language_rounded,
            ),
            title: Text(l10n.language),
            subtitle: Text(_languageLabel(locale.languageCode)),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showLanguagePicker(context, ref, locale.languageCode),
          ),
          ListTile(
            leading: _IconBox(color: Colors.indigo, icon: Icons.dark_mode_rounded),
            title: Text(l10n.darkMode),
            trailing: Switch(
              value: themeMode == ThemeMode.dark,
              onChanged: (v) => ref
                  .read(themeModeProvider.notifier)
                  .setTheme(v ? ThemeMode.dark : ThemeMode.light),
            ),
          ),
          const Divider(height: 1),
          _SectionHeader(title: l10n.audioSettings),
          ListTile(
            leading: _IconBox(color: Colors.orange, icon: Icons.volume_up_rounded),
            title: Text(l10n.soundEffects),
            subtitle: Text(audioSettings.enabled ? l10n.soundEnabled : 'Disabled'),
            trailing: Switch(
              value: audioSettings.enabled,
              onChanged: (v) =>
                  ref.read(audioSettingsProvider.notifier).setEnabled(v),
            ),
          ),
          if (audioSettings.enabled)
            Padding(
              padding: const EdgeInsets.fromLTRB(72, 0, 24, 8),
              child: Row(
                children: [
                  const Icon(Icons.volume_mute_rounded,
                      size: 18, color: Colors.grey),
                  Expanded(
                    child: Slider(
                      value: audioSettings.volume,
                      onChanged: (v) => ref
                          .read(audioSettingsProvider.notifier)
                          .setVolume(v),
                      activeColor: AppColors.primary,
                    ),
                  ),
                  const Icon(Icons.volume_up_rounded,
                      size: 18, color: Colors.grey),
                ],
              ),
            ),
          const Divider(height: 1),
          _SectionHeader(title: l10n.aboutSection),
          ListTile(
            leading: _IconBox(color: Colors.teal, icon: Icons.info_outline_rounded),
            title: Text(l10n.versionLabel),
            subtitle: const Text('1.0.0'),
          ),
        ],
      ),
    );
  }

  String _languageLabel(String code) {
    switch (code) {
      case 'fr': return 'Français';
      case 'es': return 'Español';
      case 'pt': return 'Português';
      case 'de': return 'Deutsch';
      case 'it': return 'Italiano';
      case 'nl': return 'Nederlands';
      case 'pl': return 'Polski';
      default: return 'English';
    }
  }

  void _showLanguagePicker(
      BuildContext context, WidgetRef ref, String current) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          expand: false,
          builder: (_, controller) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.selectLanguage,
                  style: ctx.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    controller: controller,
                    children: [
                      _LanguageTile(flag: '🇬🇧', label: AppLocalizations.of(context)!.english, code: 'en', current: current, ref: ref, ctx: ctx),
                      const SizedBox(height: 8),
                      _LanguageTile(flag: '🇫🇷', label: AppLocalizations.of(context)!.french, code: 'fr', current: current, ref: ref, ctx: ctx),
                      const SizedBox(height: 8),
                      _LanguageTile(flag: '🇪🇸', label: AppLocalizations.of(context)!.spanish, code: 'es', current: current, ref: ref, ctx: ctx),
                      const SizedBox(height: 8),
                      _LanguageTile(flag: '🇵🇹', label: AppLocalizations.of(context)!.portuguese, code: 'pt', current: current, ref: ref, ctx: ctx),
                      const SizedBox(height: 8),
                      _LanguageTile(flag: '🇩🇪', label: AppLocalizations.of(context)!.german, code: 'de', current: current, ref: ref, ctx: ctx),
                      const SizedBox(height: 8),
                      _LanguageTile(flag: '🇮🇹', label: AppLocalizations.of(context)!.italian, code: 'it', current: current, ref: ref, ctx: ctx),
                      const SizedBox(height: 8),
                      _LanguageTile(flag: '🇳🇱', label: AppLocalizations.of(context)!.dutch, code: 'nl', current: current, ref: ref, ctx: ctx),
                      const SizedBox(height: 8),
                      _LanguageTile(flag: '🇵🇱', label: AppLocalizations.of(context)!.polish, code: 'pl', current: current, ref: ref, ctx: ctx),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: context.textTheme.labelSmall?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.color, required this.icon});
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.flag,
    required this.label,
    required this.code,
    required this.current,
    required this.ref,
    required this.ctx,
  });

  final String flag;
  final String label;
  final String code;
  final String current;
  final WidgetRef ref;
  final BuildContext ctx;

  @override
  Widget build(BuildContext context) {
    final isSelected = current == code;
    return InkWell(
      onTap: () {
        ref.read(localeProvider.notifier).setLocale(code);
        Navigator.pop(ctx);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : context.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected ? AppColors.primary : null,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
