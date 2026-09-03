import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/persona_type.dart';
import '../../state/homepage_feed_provider.dart';
import '../../state/layout_customization_provider.dart';
import '../../core/responsive/responsive_layout.dart';

class CustomizeHomepageScreen extends ConsumerStatefulWidget {
  const CustomizeHomepageScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CustomizeHomepageScreen> createState() => _CustomizeHomepageScreenState();
}

class _CustomizeHomepageScreenState extends ConsumerState<CustomizeHomepageScreen> {
  late List<String> _localOrder;
  late Set<String> _localHidden;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final layoutState = ref.watch(layoutCustomizationProvider);
    final userPersonas = ref.watch(userPersonasProvider);

    if (!_initialized) {
      // Initialize with layoutState or active user personas
      final activePersonaValues = userPersonas.map((p) => p.value).toList();
      _localOrder = layoutState.cardOrder.isNotEmpty
          ? List<String>.from(layoutState.cardOrder)
          : List<String>.from(activePersonaValues);

      // Ensure any missing active personas are present in order list
      for (final p in activePersonaValues) {
        if (!_localOrder.contains(p)) {
          _localOrder.add(p);
        }
      }

      _localHidden = Set<String>.from(layoutState.hiddenCards);
      _initialized = true;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Customize Homepage'),
        actions: [
          TextButton(
            onPressed: () async {
              final notifier = ref.read(layoutCustomizationProvider.notifier);
              final success = await notifier.saveLayout();
              if (success && mounted) {
                // Refresh feed
                ref.invalidate(homepageFeedProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Homepage layout saved successfully!')),
                );
                Navigator.of(context).pop();
              }
            },
            child: Text(
              'Save',
              style: AppTypography.titleMd.copyWith(
                color: AppColors.primaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 860,
          child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                'Hold and drag cards to rearrange your feed hierarchy. Toggle switches to hide or show modules.',
                style: AppTypography.bodyMd,
              ),
            ),
            const Divider(height: 1, color: AppColors.surfaceContainerHigh),
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _localOrder.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final item = _localOrder.removeAt(oldIndex);
                    _localOrder.insert(newIndex, item);
                  });
                  ref.read(layoutCustomizationProvider.notifier).reorderCards(oldIndex, newIndex);
                },
                itemBuilder: (context, index) {
                  final personaStr = _localOrder[index];
                  final persona = PersonaTypeExtension.fromString(personaStr);
                  final isHidden = _localHidden.contains(personaStr);

                  return Container(
                    key: ValueKey(personaStr),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isHidden
                          ? AppColors.surfaceContainerLow
                          : AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.drag_handle_rounded, color: AppColors.outline),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: persona.color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(persona.icon, color: persona.color, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            persona.displayName,
                            style: AppTypography.titleMd.copyWith(
                              color: isHidden ? AppColors.outline : AppColors.onSurface,
                              decoration: isHidden ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        Switch.adaptive(
                          value: !isHidden,
                          activeColor: AppColors.primaryContainer,
                          onChanged: (val) {
                            setState(() {
                              if (val) {
                                _localHidden.remove(personaStr);
                              } else {
                                _localHidden.add(personaStr);
                              }
                            });
                            ref.read(layoutCustomizationProvider.notifier).toggleCardVisibility(personaStr);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
