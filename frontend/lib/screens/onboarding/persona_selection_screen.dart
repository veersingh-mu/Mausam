import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/persona_type.dart';
import '../../state/homepage_feed_provider.dart';
import '../home/home_screen.dart';

class PersonaSelectionScreen extends ConsumerStatefulWidget {
  const PersonaSelectionScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PersonaSelectionScreen> createState() => _PersonaSelectionScreenState();
}

class _PersonaSelectionScreenState extends ConsumerState<PersonaSelectionScreen> {
  final Set<PersonaType> _selected = {
    PersonaType.health,
    PersonaType.commute,
    PersonaType.fitness,
    PersonaType.family,
  };
  bool _isSaving = false;

  void _togglePersona(PersonaType p) {
    setState(() {
      if (_selected.contains(p)) {
        if (_selected.length > 1) {
          _selected.remove(p);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please keep at least 1 persona selected.')),
          );
        }
      } else {
        _selected.add(p);
      }
    });
  }

  Future<void> _saveAndContinue() async {
    setState(() {
      _isSaving = true;
    });

    final notifier = ref.read(userPersonasProvider.notifier);
    await notifier.setPersonas(_selected.toList());

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Personalize Your Mausam'),
        actions: [
          TextButton(
            onPressed: _saveAndContinue,
            child: Text(
              'Skip',
              style: AppTypography.titleMd.copyWith(color: AppColors.primaryContainer),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Your Weather Personas',
                    style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Choose the weather modules relevant to your daily routine. We will customize your homepage feed accordingly.',
                    style: AppTypography.bodyMd,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_selected.length} of ${PersonaType.values.length} Selected',
                          style: AppTypography.labelCaps.copyWith(color: AppColors.primaryContainer),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.surfaceContainerHigh),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: PersonaType.values.length,
                itemBuilder: (context, index) {
                  final p = PersonaType.values[index];
                  final isSelected = _selected.contains(p);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? p.color.withOpacity(0.04)
                          : AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? p.color : AppColors.outlineVariant.withOpacity(0.6),
                        width: isSelected ? 1.8 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: p.color.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _togglePersona(p),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: p.color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(p.icon, color: p.color, size: 24),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.displayName,
                                      style: AppTypography.titleMd.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      p.description,
                                      style: AppTypography.bodyMd.copyWith(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Checkbox(
                                value: isSelected,
                                activeColor: p.color,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                onChanged: (_) => _togglePersona(p),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveAndContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Continue with ${_selected.length} Personas',
                          style: AppTypography.titleMd.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
