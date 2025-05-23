import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:guava/core/resources/util/connection_listener.dart';
import 'package:guava/core/resources/util/permission.dart';
import 'package:guava/core/styles/colors.dart';
import 'package:guava/features/account/presentation/pages/account_page.dart';
import 'package:guava/features/dashboard/presentation/notifier/bottom_nav_notifier.dart';
import 'package:guava/features/dashboard/presentation/notifier/dashboard.notifier.dart';
import 'package:guava/features/dashboard/presentation/widgets/bottom/nav.dart';
import 'package:guava/features/home/presentation/pages/home_page.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ref.invalidate(balanceUsecaseProvider);

      unawaited(performBackgroundChecks());

      Future.delayed(Durations.extralong4, () {
        ref
            .read(permissionManagerProvider)
            .requestCameraAndNotificationPermissions();
      });
    });
  }

  Future<void> performBackgroundChecks() async {
    ref.read(dashboardNotifierProvider).hasLocationChanged();

    // checks to prefund and create USDC SPLtoken account behind the scenes
    ref.read(dashboardNotifierProvider).checkNCreateUSDCAccount();
    // ref.read(dashboardNotifierProvider).initBalanceCheck();

    // triggers network connection listener
    ref.watch(connectivityStatusProvider);
  }

  final screens = [
    const HomePage(),
    const AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(bottomNavProvider);

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: screens[selectedIndex],
        bottomNavigationBar: Container(
          height: Platform.isIOS ? 100.h : 70.h,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: BrandColors.textColor.withValues(alpha: 0.3),
              ),
            ),
          ),
          child: BottomNavigator(),
        ),
      ),
    );
  }
}
