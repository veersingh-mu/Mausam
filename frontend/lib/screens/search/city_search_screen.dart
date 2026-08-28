import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/city_model.dart';
import '../../state/city_search_provider.dart';

class CitySearchScreen extends ConsumerStatefulWidget {
  const CitySearchScreen({Key? key}) : super(key: key);

  static Future<void> showAsBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FractionallySizedBox(
        heightFactor: 0.92,
        child: CitySearchScreen(),
      ),
    );
  }

  @override
  ConsumerState<CitySearchScreen> createState() => _CitySearchScreenState();
}

class _CitySearchScreenState extends ConsumerState<CitySearchScreen> {
  late final TextEditingController _searchController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _focusNode = FocusNode();

    // Auto-focus the search field after layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onCitySelected(CityModel city) async {
    final searchNotifier = ref.read(citySearchProvider.notifier);
    final success = await searchNotifier.selectCity(city, ref);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Location set to ${city.cityName}, ${city.state}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primaryContainer,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      final error = ref.read(citySearchProvider).errorMessage ??
          "Couldn't fetch weather for ${city.cityName}, please try again";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(error)),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => _onCitySelected(city),
          ),
        ),
      );
    }
  }

  /// Builds highlighted matching text spans for search query
  Widget _buildHighlightedText(
    String fullText,
    String query, {
    required TextStyle normalStyle,
    required TextStyle highlightStyle,
  }) {
    if (query.trim().isEmpty) {
      return Text(fullText, style: normalStyle);
    }

    final lowerText = fullText.toLowerCase();
    final lowerQuery = query.trim().toLowerCase();
    final startIndex = lowerText.indexOf(lowerQuery);

    if (startIndex == -1) {
      return Text(fullText, style: normalStyle);
    }

    final endIndex = startIndex + lowerQuery.length;
    final prefix = fullText.substring(0, startIndex);
    final match = fullText.substring(startIndex, endIndex);
    final suffix = fullText.substring(endIndex);

    return RichText(
      text: TextSpan(
        children: [
          if (prefix.isNotEmpty) TextSpan(text: prefix, style: normalStyle),
          TextSpan(text: match, style: highlightStyle),
          if (suffix.isNotEmpty) TextSpan(text: suffix, style: normalStyle),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(citySearchProvider);
    final searchNotifier = ref.read(citySearchProvider.notifier);
    final isQueryEmpty = searchState.query.isEmpty;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: true,
        bottom: true,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Search Bar Header
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      bottom: BorderSide(color: AppColors.outline.withOpacity(0.2)),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
                        tooltip: 'Back',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.outline.withOpacity(0.3)),
                          ),
                          child: TextField(
                            controller: _searchController,
                            focusNode: _focusNode,
                            textInputAction: TextInputAction.search,
                            style: AppTypography.bodyMd.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search city in India...',
                              hintStyle: AppTypography.bodyMd.copyWith(
                                color: AppColors.outline,
                              ),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: AppColors.primary,
                                size: 22,
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.outline),
                                      onPressed: () {
                                        _searchController.clear();
                                        searchNotifier.onQueryChanged('');
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 13),
                            ),
                            onChanged: (val) {
                              setState(() {});
                              searchNotifier.onQueryChanged(val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Search Results / Default State List
                Expanded(
                  child: isQueryEmpty
                      ? _buildDefaultView(searchState, searchNotifier)
                      : _buildFilteredListView(searchState),
                ),
              ],
            ),

            // Loading overlay during city selection & weather fetch
            if (searchState.isSelecting)
              Container(
                color: Colors.black.withOpacity(0.25),
                child: const Center(
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: AppColors.primaryContainer),
                          SizedBox(height: 16),
                          Text(
                            'Fetching live IMD weather...',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Default View: Recent Searches + Popular Cities
  Widget _buildDefaultView(CitySearchState searchState, CitySearchNotifier searchNotifier) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        // A) Recently Searched Section
        if (searchState.recentCities.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.history_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'RECENTLY SEARCHED',
                      style: AppTypography.labelCaps.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => searchNotifier.clearRecentSearches(),
                  child: Text(
                    'Clear All',
                    style: AppTypography.labelCaps.copyWith(
                      color: AppColors.outline,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...searchState.recentCities.map((city) {
            return _buildCityTile(
              city: city,
              isRecent: true,
              searchState: searchState,
              searchNotifier: searchNotifier,
            );
          }).toList(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Divider(height: 1),
          ),
        ],

        // B) Popular Cities in India Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.location_city_rounded, size: 16, color: AppColors.onSurface),
              const SizedBox(width: 6),
              Text(
                'POPULAR INDIAN CITIES',
                style: AppTypography.labelCaps.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        ...searchState.popularCities.map((city) {
          return _buildCityTile(
            city: city,
            isRecent: false,
            searchState: searchState,
            searchNotifier: searchNotifier,
          );
        }).toList(),
      ],
    );
  }

  /// Filtered View: Matched Results with Substring Highlighting
  Widget _buildFilteredListView(CitySearchState searchState) {
    if (searchState.filteredCities.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.travel_explore_rounded,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No matching city found',
                style: AppTypography.titleMd.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Please check your spelling or search for a nearby major district.',
                style: AppTypography.bodyMd.copyWith(color: AppColors.outline),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: searchState.filteredCities.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 64),
      itemBuilder: (context, index) {
        final city = searchState.filteredCities[index];
        return _buildCityTile(
          city: city,
          isRecent: false,
          searchState: searchState,
          searchNotifier: ref.read(citySearchProvider.notifier),
          highlightQuery: searchState.query,
        );
      },
    );
  }

  /// Individual City Row
  Widget _buildCityTile({
    required CityModel city,
    required bool isRecent,
    required CitySearchState searchState,
    required CitySearchNotifier searchNotifier,
    String? highlightQuery,
  }) {
    final isFavorite = searchState.isFavorite(city);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isRecent ? AppColors.primary.withOpacity(0.1) : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          isRecent ? Icons.history_rounded : Icons.location_on_outlined,
          color: isRecent ? AppColors.primary : AppColors.primaryContainer,
          size: 20,
        ),
      ),
      title: highlightQuery != null && highlightQuery.isNotEmpty
          ? _buildHighlightedText(
              city.cityName,
              highlightQuery,
              normalStyle: AppTypography.titleMd.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
              highlightStyle: AppTypography.titleMd.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                backgroundColor: AppColors.primary.withOpacity(0.12),
              ),
            )
          : Text(
              city.cityName,
              style: AppTypography.titleMd.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
      subtitle: Row(
        children: [
          Text(
            city.state,
            style: AppTypography.bodyMd.copyWith(
              fontSize: 12,
              color: AppColors.outline,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              city.region,
              style: AppTypography.labelCaps.copyWith(
                fontSize: 9,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Favorite Star Toggle
          IconButton(
            icon: Icon(
              isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
              color: isFavorite ? Colors.amber[700] : AppColors.outline.withOpacity(0.5),
              size: 22,
            ),
            tooltip: isFavorite ? 'Remove Favorite' : 'Save as Favorite',
            onPressed: () => searchNotifier.toggleFavorite(city),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.outline,
            size: 20,
          ),
        ],
      ),
      onTap: () => _onCitySelected(city),
    );
  }
}
