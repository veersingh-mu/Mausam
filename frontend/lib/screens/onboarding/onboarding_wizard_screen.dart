import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/persona_type.dart';
import '../../models/onboarding_model.dart';
import '../../state/user_persona_provider.dart';
import '../../core/responsive/responsive_breakpoints.dart';
import '../../core/responsive/responsive_layout.dart';

class OnboardingWizardScreen extends ConsumerStatefulWidget {
  const OnboardingWizardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingWizardScreen> createState() => _OnboardingWizardScreenState();
}

class _OnboardingWizardScreenState extends ConsumerState<OnboardingWizardScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Onboarding draft state
  final Set<PersonaType> _selectedPersonas = {
    PersonaType.health,
    PersonaType.fitness,
    PersonaType.commute,
    PersonaType.family
  };

  SavedLocationItem _primaryLocation = SavedLocationItem(
    name: 'New Delhi, India',
    latitude: 28.6139,
    longitude: 77.2090,
    isPrimary: true,
    label: 'Home',
  );

  final List<SavedLocationItem> _auxiliaryLocations = [
    SavedLocationItem(name: 'Goa Beach Coast', latitude: 15.2993, longitude: 74.1240, label: 'Beach Getaway'),
    SavedLocationItem(name: 'Shimla Hills, HP', latitude: 31.1048, longitude: 77.1734, label: 'Vacation Home'),
  ];

  final TextEditingController _locationInputCtrl = TextEditingController();

  void _nextPage() {
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _previousPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _toggleTile(PersonaType persona) {
    setState(() {
      if (_selectedPersonas.contains(persona)) {
        if (_selectedPersonas.length > 1) {
          _selectedPersonas.remove(persona);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select at least 1 persona to personalize your feed.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        _selectedPersonas.add(persona);
      }
    });
  }

  Future<void> _finishOnboarding() async {
    final payload = OnboardingPayload(
      userId: 'citizen_delhi_01',
      selectedPersonas: _selectedPersonas.toList(),
      primaryLocation: _primaryLocation,
      savedLocations: _auxiliaryLocations,
    );

    await ref.read(userPersonaProvider.notifier).submitOnboarding(payload);

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
                onPressed: _previousPage,
              )
            : null,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'MAUSAM',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Personalize',
              style: AppTypography.titleMd.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'Step ${_currentStep + 1} of 4',
                style: AppTypography.labelCaps.copyWith(color: AppColors.outline),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Step Progress Bar
          LinearProgressIndicator(
            value: (_currentStep + 1) / 4.0,
            backgroundColor: AppColors.outlineVariant.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 4,
          ),

          // 4-Step PageView centered with max width on desktop
          Expanded(
            child: ResponsiveContainer(
              maxWidth: 900,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (idx) {
                  setState(() {
                    _currentStep = idx;
                  });
                },
                children: [
                  _buildScreen1Welcome(),
                  _buildScreen2PersonaGrid(),
                  _buildScreen3LocationSetup(),
                  _buildScreen4Summary(),
                ],
              ),
            ),
          ),

          // Bottom Action Navigation Bar constrained for desktop
          ResponsiveContainer(
            maxWidth: 900,
            child: _buildBottomAction(),
          ),
        ],
      ),
    );
  }

  // --- Screen 1: Welcome ---
  Widget _buildScreen1Welcome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF000666), Color(0xFF1A237E)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.wb_sunny_rounded, color: Colors.amber, size: 36),
          ),
          const SizedBox(height: 24),
          Text(
            'Weather That Matters to You',
            style: AppTypography.displayTemp.copyWith(
              fontSize: 28,
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Welcome to Mausam, India Meteorological Department\'s modular weather platform. Say goodbye to generic forecasts and get real-time actionable insights tailored specifically to your daily lifestyle.',
            style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant, height: 1.5),
          ),
          const SizedBox(height: 32),

          // Feature Highlights
          _buildFeatureRow(
            Icons.tune_rounded,
            'Personalized Modules',
            'Tailor your homepage with AQI, tides, running hours, farming data or traffic alerts.',
          ),
          const SizedBox(height: 16),
          _buildFeatureRow(
            Icons.electric_bolt_rounded,
            'Sub-Second IMD Alerts',
            'Instant severe weather push notifications directly from regional meteorological centers.',
          ),
          const SizedBox(height: 16),
          _buildFeatureRow(
            Icons.security_rounded,
            'Accurate & Reliable',
            'Backed by CPCB air monitors, INCOIS coastal ocean buoys and IMD NWP radar models.',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.titleMd.copyWith(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTypography.bodyMd.copyWith(fontSize: 12.5, color: AppColors.outline)),
            ],
          ),
        ),
      ],
    );
  }

  // --- Screen 2: Persona Grid ---
  Widget _buildScreen2PersonaGrid() {
    final allPersonas = PersonaType.values;
    final selectedCount = _selectedPersonas.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select Your Personas', style: AppTypography.titleMd.copyWith(fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text('Choose all lifestyles that apply to you', style: AppTypography.bodyMd.copyWith(color: AppColors.outline, fontSize: 12)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$selectedCount selected',
                  style: AppTypography.labelCaps.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 8 Tappable Persona Tiles with responsive 2/3/4 columns
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: ResponsiveBreakpoints.gridColumns(
                  context,
                  compact: 2,
                  medium: 3,
                  expanded: 4,
                ),
                childAspectRatio: ResponsiveBreakpoints.value(
                  context,
                  compact: 1.15,
                  medium: 1.10,
                  expanded: 1.12,
                ),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: allPersonas.length,
              itemBuilder: (context, index) {
                final p = allPersonas[index];
                final isSelected = _selectedPersonas.contains(p);

                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    transform: Matrix4.diagonal3Values(
                      isSelected ? 1.0 : 0.98,
                      isSelected ? 1.0 : 0.98,
                      1.0,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? p.color.withOpacity(0.08) : AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? p.color : AppColors.outlineVariant,
                        width: isSelected ? 2.2 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: p.color.withOpacity(0.18),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _toggleTile(p),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSelected ? p.color : p.color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  p.icon,
                                  color: isSelected ? Colors.white : p.color,
                                  size: 20,
                                ),
                              ),
                              AnimatedOpacity(
                                duration: const Duration(milliseconds: 200),
                                opacity: isSelected ? 1.0 : 0.0,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: p.color,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 12),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            p.displayName,
                            style: AppTypography.titleMd.copyWith(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? AppColors.onSurface : AppColors.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            p.description,
                            style: AppTypography.bodyMd.copyWith(
                              fontSize: 10.5,
                              color: AppColors.outline,
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
        ],
      ),
    );
  }

  // --- Screen 3: Location Setup ---
  Widget _buildScreen3LocationSetup() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Location & Places', style: AppTypography.titleMd.copyWith(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('Set your primary city and add destinations for travel insights', style: AppTypography.bodyMd.copyWith(color: AppColors.outline, fontSize: 12.5)),
          const SizedBox(height: 20),

          // Primary GPS Location Box
          Text('PRIMARY LOCATION (GPS DETECTED)', style: AppTypography.labelCaps),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.my_location_rounded, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(_primaryLocation.name, style: AppTypography.titleMd.copyWith(fontWeight: FontWeight.w700, fontSize: 15)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('DEFAULT', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('Lat: ${_primaryLocation.latitude}, Lon: ${_primaryLocation.longitude}', style: AppTypography.labelCaps.copyWith(color: AppColors.outline)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                  tooltip: 'Re-detect GPS',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('GPS calibrated: New Delhi, India')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Saved Auxiliary Destinations
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('SAVED DESTINATIONS (FOR TRAVEL & FAMILY)', style: AppTypography.labelCaps),
              Text('${_auxiliaryLocations.length} places', style: AppTypography.labelCaps.copyWith(color: AppColors.outline)),
            ],
          ),
          const SizedBox(height: 8),
          ..._auxiliaryLocations.asMap().entries.map((entry) {
            final idx = entry.key;
            final loc = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: AppColors.outline, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(loc.name, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700)),
                        Text(loc.label, style: AppTypography.labelCaps.copyWith(fontSize: 10, color: AppColors.outline)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.outline),
                    onPressed: () {
                      setState(() {
                        _auxiliaryLocations.removeAt(idx);
                      });
                    },
                  ),
                ],
              ),
            );
          }).toList(),

          // Add Destination Field
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _locationInputCtrl,
                  decoration: InputDecoration(
                    hintText: 'Add another destination (e.g. Mumbai, Bengaluru)',
                    hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.outline, fontSize: 13),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.outlineVariant),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  final text = _locationInputCtrl.text.trim();
                  if (text.isNotEmpty) {
                    setState(() {
                      _auxiliaryLocations.add(
                        SavedLocationItem(name: text, latitude: 19.0760, longitude: 72.8777, label: 'Saved Trip'),
                      );
                      _locationInputCtrl.clear();
                    });
                  }
                },
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Screen 4: Confirmation Summary ---
  Widget _buildScreen4Summary() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 36),
          ),
          const SizedBox(height: 16),
          Text(
            'Your Weather Feed is Ready!',
            style: AppTypography.displayTemp.copyWith(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primary),
          ),
          const SizedBox(height: 6),
          Text(
            'Here is a quick overview of your personalized meteorological feed setup:',
            style: AppTypography.bodyMd.copyWith(color: AppColors.outline),
          ),
          const SizedBox(height: 24),

          // Selected Personas Recap
          Text('ACTIVE PERSONA MODULES (${_selectedPersonas.length})', style: AppTypography.labelCaps),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedPersonas.map((p) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: p.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: p.color.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(p.icon, color: p.color, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      p.displayName,
                      style: AppTypography.labelCaps.copyWith(color: p.color, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Primary Location Recap
          Text('PRIMARY LOCATION', style: AppTypography.labelCaps),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                Text(_primaryLocation.name, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Quick Note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'You can add or remove personas anytime from the top app bar or Settings tab.',
                    style: AppTypography.bodyMd.copyWith(fontSize: 11.5, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Bottom Navigation Button ---
  Widget _buildBottomAction() {
    final bool canContinue = _currentStep != 1 || _selectedPersonas.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(top: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: canContinue ? AppColors.primary : AppColors.outlineVariant,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: canContinue ? 2 : 0,
            ),
            onPressed: canContinue ? _nextPage : null,
            child: Text(
              _currentStep == 3
                  ? 'Go to My Homepage'
                  : (_currentStep == 0 ? 'Let\'s Personalize' : 'Continue'),
              style: AppTypography.titleMd.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
