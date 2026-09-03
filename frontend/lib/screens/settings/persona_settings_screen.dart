import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/persona_type.dart';
import '../../state/user_persona_provider.dart';
import '../../widgets/persona_toggle_sheet.dart';
import '../../core/responsive/responsive_layout.dart';

class PersonaSettingsScreen extends ConsumerWidget {
  const PersonaSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personaState = ref.watch(userPersonaProvider);
    final allPersonas = PersonaType.values;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Weather Personas'),
      ),
      body: ResponsiveContainer(
        maxWidth: 860,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF000666), Color(0xFF1A237E)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tune_rounded, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'ACTIVE MODULES (${personaState.selectedPersonas.length}/8)',
                      style: AppTypography.labelCaps.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Customize which meteorological modules appear on your home screen.',
                  style: AppTypography.bodyMd.copyWith(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text('ALL WEATHER PERSONAS', style: AppTypography.labelCaps),
          const SizedBox(height: 8),

          // Persona List
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              children: allPersonas.map((p) {
                final isSelected = personaState.selectedPersonas.contains(p);
                return SwitchListTile.adaptive(
                  value: isSelected,
                  activeColor: p.color,
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: p.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(p.icon, color: p.color, size: 20),
                  ),
                  title: Text(
                    p.displayName,
                    style: AppTypography.titleMd.copyWith(
                      fontSize: 14,
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
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Primary Location Info
          Text('PRIMARY LOCATION', style: AppTypography.labelCaps),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(personaState.primaryLocation.name, style: AppTypography.titleMd.copyWith(fontSize: 14, fontWeight: FontWeight.w700)),
                      Text(
                        'Lat: ${personaState.primaryLocation.latitude}, Lon: ${personaState.primaryLocation.longitude}',
                        style: AppTypography.labelCaps.copyWith(color: AppColors.outline),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
