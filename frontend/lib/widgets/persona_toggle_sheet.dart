import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/persona_type.dart';
import '../state/user_persona_provider.dart';

class PersonaToggleSheet extends ConsumerWidget {
  const PersonaToggleSheet({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PersonaToggleSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personaState = ref.watch(userPersonaProvider);
    final allPersonas = PersonaType.values;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Sheet Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Weather Personas',
                      style: AppTypography.titleMd.copyWith(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Toggle modules to customize your live homepage',
                      style: AppTypography.bodyMd.copyWith(fontSize: 11.5, color: AppColors.outline),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${personaState.selectedPersonas.length} active',
                    style: AppTypography.labelCaps.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),

          // Error Toast
          if (personaState.errorMessage != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      personaState.errorMessage!,
                      style: AppTypography.bodyMd.copyWith(fontSize: 11.5, color: AppColors.onErrorContainer),
                    ),
                  ),
                ],
              ),
            ),

          // 8 Persona List Tiles
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: allPersonas.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final p = allPersonas[index];
                final isSelected = personaState.selectedPersonas.contains(p);

                return SwitchListTile.adaptive(
                  value: isSelected,
                  activeColor: p.color,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  secondary: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected ? p.color.withOpacity(0.12) : AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? p.color.withOpacity(0.4) : AppColors.outlineVariant,
                      ),
                    ),
                    child: Icon(p.icon, color: p.color, size: 22),
                  ),
                  title: Text(
                    p.displayName,
                    style: AppTypography.titleMd.copyWith(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.onSurface : AppColors.outline,
                    ),
                  ),
                  subtitle: Text(
                    p.description,
                    style: AppTypography.bodyMd.copyWith(fontSize: 11, color: AppColors.outline),
                  ),
                  onChanged: (val) {
                    ref.read(userPersonaProvider.notifier).togglePersona(p);
                  },
                );
              },
            ),
          ),

          // Done CTA
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
