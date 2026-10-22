import '../../map/presentation/widgets/proximity_banner.dart';
import '../../map/providers/map_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../activities/presentation/timeline_screen.dart';
import '../../auth/presentation/auth_screen.dart';
import '../../auth/presentation/pairing_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../../todos/presentation/todo_screen.dart';
import '../../map/presentation/live_map_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import 'widgets/floating_glassy_nav_bar.dart';

class MainNavigationScaffold extends ConsumerStatefulWidget {
  final int initialIndex;
  const MainNavigationScaffold({super.key, this.initialIndex = 0});

  @override
  ConsumerState<MainNavigationScaffold> createState() =>
      _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState
    extends ConsumerState<MainNavigationScaffold> {
  late int _currentIndex;

  final List<KisaNavItem> _navItems = const [
    KisaNavItem(
      icon: Icons.auto_stories_outlined,
      selectedIcon: Icons.auto_stories_rounded,
      label: 'Momen',
    ),
    KisaNavItem(
      icon: Icons.checklist_outlined,
      selectedIcon: Icons.checklist_rounded,
      label: 'Wishlist',
    ),
    KisaNavItem(
      icon: Icons.map_outlined,
      selectedIcon: Icons.map_rounded,
      label: 'Lokasi',
    ),
    KisaNavItem(
      icon: Icons.favorite_border_rounded,
      selectedIcon: Icons.favorite_rounded,
      label: 'Kita',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    // Protected Route Guard
    final authState = ref.watch(authProvider);

    if (authState.user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthScreen()),
          (route) => false,
        );
      });
      return const Scaffold(backgroundColor: KisaColors.background);
    }

    if (!authState.isPaired) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const PairingScreen()),
          (route) => false,
        );
      });
      return const Scaffold(backgroundColor: KisaColors.background);
    }

    final mapState = ref.watch(mapProvider);

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: const [
              TimelineScreen(),
              TodoScreen(),
              LiveMapScreen(),
              ProfileScreen(),
            ],
          ),

          // Proximity Alert Banner (< 100 meters)
          if (mapState.showProximityBanner && mapState.proximityMeters != null)
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ProximityBanner(
                    partnerName: mapState.partnerLocation?.userName ?? 'Fexa',
                    distanceMeters: mapState.proximityMeters!,
                    onTapViewMap: () {
                      setState(() => _currentIndex = 2);
                      ref.read(mapProvider.notifier).dismissProximityBanner();
                    },
                    onDismiss: () {
                      ref.read(mapProvider.notifier).dismissProximityBanner();
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: FloatingGlassyNavBar(
          selectedIndex: _currentIndex,
          onItemSelected: (index) {
            setState(() => _currentIndex = index);
          },
          items: _navItems,
        ),
      ),
    );
  }
}
