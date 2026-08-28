import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/persona_type.dart';
import '../../models/weather_card_model.dart';
import '../../state/homepage_feed_provider.dart';
import '../../state/realtime_alert_provider.dart';
import '../../widgets/weather_hero_header.dart';
import '../../widgets/alert_banner.dart';
import '../../widgets/cards/base_widget_card.dart';
import '../../widgets/persona_toggle_sheet.dart';
import '../onboarding/onboarding_wizard_screen.dart';
import '../settings/persona_settings_screen.dart';
import '../customize/customize_homepage_screen.dart';
import '../search/city_search_screen.dart';

// Details screens
import '../details/commute_details_screen.dart';
import '../details/fitness_details_screen.dart';
import '../details/travel_details_screen.dart';
import '../details/health_details_screen.dart';
import '../details/family_details_screen.dart';
import '../details/marine_details_screen.dart';
import '../details/agri_details_screen.dart';
import '../details/event_planner_details_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void _navigateToDetails(BuildContext context, WidgetCard card) {
    Widget screen;
    switch (card.persona) {
      case PersonaType.health:
        screen = HealthDetailsScreen(healthData: HealthData.fromMap(card.data));
        break;
      case PersonaType.fitness:
        screen = FitnessDetailsScreen(fitnessData: FitnessData.fromMap(card.data));
        break;
      case PersonaType.beach:
        screen = MarineDetailsScreen(marineData: MarineData.fromMap(card.data));
        break;
      case PersonaType.travel:
        screen = TravelDetailsScreen(travelData: TravelData.fromMap(card.data));
        break;
      case PersonaType.family:
        screen = FamilyDetailsScreen(familyData: FamilyData.fromMap(card.data));
        break;
      case PersonaType.agriculture:
        screen = AgriDetailsScreen(agriData: AgriData.fromMap(card.data));
        break;
      case PersonaType.commute:
        screen = CommuteDetailsScreen(commuteData: CommuteData.fromMap(card.data));
        break;
      case PersonaType.events:
        screen = EventPlannerDetailsScreen(eventsData: EventsData.fromMap(card.data));
        break;
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(homepageFeedProvider);
    final activeAlerts = ref.watch(activeAlertsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'MAUSAM',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'IMD Weather',
              style: AppTypography.titleMd.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Search City',
            icon: const Icon(Icons.search_rounded, color: AppColors.primaryContainer),
            onPressed: () {
              CitySearchScreen.showAsBottomSheet(context);
            },
          ),
          IconButton(
            tooltip: 'Toggle Personas',
            icon: const Icon(Icons.tune_rounded, color: AppColors.primaryContainer),
            onPressed: () {
              PersonaToggleSheet.show(context);
            },
          ),
          IconButton(
            tooltip: 'Customize Layout',
            icon: const Icon(Icons.dashboard_customize_rounded, color: AppColors.primaryContainer),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CustomizeHomepageScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Onboarding Wizard',
            icon: const Icon(Icons.auto_awesome_rounded, color: AppColors.primaryContainer),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const OnboardingWizardScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(homepageFeedProvider);
        },
        child: feedAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryContainer),
          ),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.outline),
                  const SizedBox(height: 12),
                  Text('Failed to load personalized feed', style: AppTypography.titleMd),
                  const SizedBox(height: 6),
                  Text(err.toString(), style: AppTypography.bodyMd, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(homepageFeedProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (feed) {
            // Combine active websocket alerts with server alerts
            final combinedAlerts = activeAlerts.isNotEmpty ? activeAlerts : feed.alerts;

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                // 1. Live Severe Alert Banner
                if (combinedAlerts.isNotEmpty) AlertBanner(alerts: combinedAlerts),

                // 2. IMD Weather Hero Header with Search Bar
                WeatherHeroHeader(
                  location: feed.location,
                  current: feed.current,
                  onLocationTap: () => CitySearchScreen.showAsBottomSheet(context),
                  onSearchTap: () => CitySearchScreen.showAsBottomSheet(context),
                ),

                // 3. Active Persona Quick Chips Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('YOUR PERSONA MODULES', style: AppTypography.labelCaps),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const CustomizeHomepageScreen()),
                          );
                        },
                        child: Text(
                          'Edit Layout',
                          style: AppTypography.labelCaps.copyWith(
                            color: AppColors.primaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    children: [
                      // Interactive + Toggle Personas Button Chip
                      InkWell(
                        onTap: () => PersonaToggleSheet.show(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.tune_rounded, color: AppColors.primary, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                '+ Toggle Personas',
                                style: AppTypography.labelCaps.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      ...feed.selectedPersonas.map((p) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () => PersonaToggleSheet.show(context),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: p.color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: p.color.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(p.icon, color: p.color, size: 14),
                                  const SizedBox(width: 6),
                                  Text(
                                    p.displayName,
                                    style: AppTypography.labelCaps.copyWith(color: p.color, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // 4. Dynamic Polymorphic Cards
                ...feed.cards.map((card) {
                  return WidgetCardFactory.createCard(
                    card,
                    onTap: () => _navigateToDetails(context, card),
                  );
                }).toList(),

                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }
}
