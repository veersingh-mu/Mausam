import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/responsive/responsive_breakpoints.dart';
import '../../core/responsive/responsive_layout.dart';
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

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedNavIndex = 0;

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

  void _onNavTapped(int index) {
    setState(() {
      _selectedNavIndex = index;
    });

    // Handle secondary destinations
    switch (index) {
      case 1: // Radar/Map
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('IMD Doppler Weather Radar & NWP Wind Map view.'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      case 2: // Alerts
        final alerts = ref.read(activeAlertsProvider);
        if (alerts.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${alerts.length} active severe meteorological alerts in your area.'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No active severe weather warnings. Weather conditions normal.'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        break;
      case 3: // Saved Places
        CitySearchScreen.showAsBottomSheet(context);
        break;
      case 4: // Profile / Preferences
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PersonaSettingsScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(currentLocationProvider);
    final feedAsync = ref.watch(homepageFeedFamilyProvider(location));
    final activeAlerts = ref.watch(activeAlertsProvider);
    final breakpoint = ResponsiveBreakpoints.of(context);
    final isCompact = breakpoint == ScreenBreakpoint.compact;
    final isMedium = breakpoint == ScreenBreakpoint.medium;
    final isExpanded = breakpoint == ScreenBreakpoint.expanded;

    feedAsync.whenData((feed) {
      print('[DIAGNOSTIC 6 - Frontend UI] HomeScreen rendered with location: "${feed.location.name}" (${feed.location.latitude}, ${feed.location.longitude}), temp: ${feed.current.temperatureC}°C, cards: ${feed.cards.length}');
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      // On Compact and Medium screens, show the standard mobile/tablet app bar.
      // On Expanded desktop screens, the top bar is integrated directly into the desktop layout.
      appBar: isExpanded ? null : _buildMobileAppBar(context),
      body: Row(
        children: [
          // NavigationRail docked to left on Medium and Expanded screens
          if (!isCompact)
            _buildNavigationRail(
              context,
              isExtended: isExpanded,
            ),

          // Main Responsive Content Area
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(homepageFeedFamilyProvider(location));
                ref.invalidate(homepageFeedProvider);
              },
              child: feedAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryContainer),
                ),
                error: (err, stack) => _buildErrorState(err),
                data: (feed) {
                  final combinedAlerts = activeAlerts.isNotEmpty ? activeAlerts : feed.alerts;

                  return CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // Desktop Persistent Fixed Top Bar (Expanded screen only)
                      if (isExpanded)
                        SliverToBoxAdapter(
                          child: _buildDesktopTopBar(context, feed),
                        ),

                      // Main Content Area wrapped in ResponsiveContainer
                      SliverToBoxAdapter(
                        child: ResponsiveContainer(
                          maxWidth: isExpanded ? 1360 : 960,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 1. Live Severe Alert Banner
                              if (combinedAlerts.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isCompact ? 16 : 24,
                                    vertical: 8,
                                  ),
                                  child: AlertBanner(alerts: combinedAlerts),
                                ),

                              // 2. IMD Weather Hero Header
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isCompact ? 0 : 8,
                                  vertical: 4,
                                ),
                                child: WeatherHeroHeader(
                                  location: feed.location,
                                  current: feed.current,
                                  onLocationTap: () => CitySearchScreen.showAsBottomSheet(context),
                                  onSearchTap: () => CitySearchScreen.showAsBottomSheet(context),
                                ),
                              ),

                              // 3. Active Persona Quick Chips Row
                              _buildPersonaChipsRow(context, feed),

                              const SizedBox(height: 8),

                              // 4. Responsive Card Grid (1 col on Compact, 2 col on Medium, 3 col on Expanded)
                              _buildResponsiveCardGrid(
                                context,
                                cards: feed.cards,
                                columns: ResponsiveBreakpoints.gridColumns(
                                  context,
                                  compact: 1,
                                  medium: 2,
                                  expanded: 3,
                                ),
                              ),

                              const SizedBox(height: 36),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
      // Compact phone bottom navigation bar
      bottomNavigationBar: isCompact ? _buildBottomNavigationBar(context) : null,
    );
  }

  /// Compact mobile AppBar
  PreferredSizeWidget _buildMobileAppBar(BuildContext context) {
    return AppBar(
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
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: 1.2,
              ),
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
          onPressed: () => CitySearchScreen.showAsBottomSheet(context),
        ),
        IconButton(
          tooltip: 'Toggle Personas',
          icon: const Icon(Icons.tune_rounded, color: AppColors.primaryContainer),
          onPressed: () => PersonaToggleSheet.show(context),
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
    );
  }

  /// Fixed Desktop Top Bar for Expanded breakpoint (> 1024px)
  Widget _buildDesktopTopBar(BuildContext context, dynamic feed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant.withOpacity(0.5), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Location Badge
          InkWell(
            onTap: () => CitySearchScreen.showAsBottomSheet(context),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded, color: AppColors.primaryContainer, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    feed.location.name,
                    style: AppTypography.titleMd.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryContainer,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryContainer, size: 18),
                ],
              ),
            ),
          ),

          const SizedBox(width: 24),

          // Desktop Search Input Trigger (opens 520px centered modal)
          Expanded(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => CitySearchScreen.showAsBottomSheet(context),
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.outlineVariant.withOpacity(0.8)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: AppColors.outline, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        'Search Indian cities, districts, or marine coastlines...',
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.outline,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('ESC to exit', style: TextStyle(fontSize: 10, color: AppColors.outline)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 20),

          // Desktop Quick Action Buttons
          OutlinedButton.icon(
            icon: const Icon(Icons.tune_rounded, size: 16),
            label: const Text('Toggle Personas'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryContainer,
              side: const BorderSide(color: AppColors.primaryContainer),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => PersonaToggleSheet.show(context),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            icon: const Icon(Icons.dashboard_customize_rounded, size: 16),
            label: const Text('Edit Layout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CustomizeHomepageScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Built-in NavigationRail for Medium (tablet) and Expanded (desktop) screens
  Widget _buildNavigationRail(BuildContext context, {required bool isExtended}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(color: AppColors.outlineVariant.withOpacity(0.5), width: 1),
        ),
      ),
      child: NavigationRail(
        selectedIndex: _selectedNavIndex,
        onDestinationSelected: _onNavTapped,
        extended: isExtended,
        minWidth: 72,
        minExtendedWidth: 200,
        backgroundColor: Colors.transparent,
        selectedIconTheme: const IconThemeData(color: AppColors.primaryContainer, size: 24),
        unselectedIconTheme: const IconThemeData(color: AppColors.outline, size: 22),
        selectedLabelTextStyle: const TextStyle(
          color: AppColors.primaryContainer,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        unselectedLabelTextStyle: const TextStyle(
          color: AppColors.outline,
          fontSize: 12,
        ),
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: isExtended
              ? Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'MAUSAM',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'IMD Portal',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ],
                )
              : Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'M',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                  ),
                ),
        ),
        destinations: const [
          NavigationRailDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: Text('Home'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.radar_outlined),
            selectedIcon: Icon(Icons.radar_rounded),
            label: Text('Radar & Map'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.warning_amber_rounded),
            selectedIcon: Icon(Icons.warning_rounded),
            label: Text('Alerts'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.bookmarks_outlined),
            selectedIcon: Icon(Icons.bookmarks_rounded),
            label: Text('Saved Places'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: Text('Profile'),
          ),
        ],
      ),
    );
  }

  /// Compact mobile BottomNavigationBar
  Widget _buildBottomNavigationBar(BuildContext context) {
    return NavigationBar(
      selectedIndex: _selectedNavIndex,
      onDestinationSelected: _onNavTapped,
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.primaryContainer.withOpacity(0.12),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded, color: AppColors.primaryContainer),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.radar_outlined),
          selectedIcon: Icon(Icons.radar_rounded, color: AppColors.primaryContainer),
          label: 'Radar',
        ),
        NavigationDestination(
          icon: Icon(Icons.warning_amber_rounded),
          selectedIcon: Icon(Icons.warning_rounded, color: AppColors.primaryContainer),
          label: 'Alerts',
        ),
        NavigationDestination(
          icon: Icon(Icons.bookmarks_outlined),
          selectedIcon: Icon(Icons.bookmarks_rounded, color: AppColors.primaryContainer),
          label: 'Saved',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded, color: AppColors.primaryContainer),
          label: 'Profile',
        ),
      ],
    );
  }

  /// Persona Chips Row with support for both touch drag and mouse wheel/trackpad scrolling
  Widget _buildPersonaChipsRow(BuildContext context, dynamic feed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
              },
            ),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: [
                // Interactive + Toggle Personas Button Chip
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: InkWell(
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
                ),
                const SizedBox(width: 8),

                ...feed.selectedPersonas.map((p) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
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
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Responsive Card Grid:
  /// - 1 column: Vertical list
  /// - 2 columns: Balanced 2-column masonry on tablets
  /// - 3 columns: Balanced 3-column masonry on desktops
  Widget _buildResponsiveCardGrid(
    BuildContext context, {
    required List<WidgetCard> cards,
    required int columns,
  }) {
    if (columns <= 1) {
      // Compact phone single-column stack
      return Column(
        children: cards.map((card) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: WidgetCardFactory.createCard(
              card,
              onTap: () => _navigateToDetails(context, card),
            ),
          );
        }).toList(),
      );
    }

    // Multi-column masonry partition (Medium: 2 cols, Expanded: 3 cols)
    final List<List<WidgetCard>> columnBuckets = List.generate(columns, (_) => []);
    for (int i = 0; i < cards.length; i++) {
      columnBuckets[i % columns].add(cards[i]);
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: columns == 2 ? 18 : 24,
        vertical: 8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int c = 0; c < columns; c++) ...[
            if (c > 0) SizedBox(width: columns == 2 ? 16 : 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: columnBuckets[c].map((card) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: WidgetCardFactory.createCard(
                      card,
                      onTap: () => _navigateToDetails(context, card),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(dynamic err) {
    return Center(
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
              onPressed: () {
                final loc = ref.read(currentLocationProvider);
                ref.invalidate(homepageFeedFamilyProvider(loc));
                ref.invalidate(homepageFeedProvider);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
