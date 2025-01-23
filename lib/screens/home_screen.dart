import 'package:flutter/material.dart';
import 'package:cricket/ui/ui.dart';
import 'package:pretty_logger/pretty_logger.dart';
import 'package:provider/provider.dart';
import 'package:cricket/common/common.dart';
import 'package:cricket/controllers/controllers.dart';
import 'package:cricket/models/models.dart';
import 'package:cricket/screens/screens.dart';
import 'package:cricket/routes/routes.dart';

class HomeScreen extends StatelessWidget {
  final User? initialUser;

  const HomeScreen({
    super.key,
    this.initialUser,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => HomeController()..setInitialUser(initialUser)),
        // ChangeNotifierProvider.value(
        //   value: GlobalMasterDataProvider.instance,
        // ),
      ],
      child: const _HomeScreenContent(),
    );
  }
}

class _HomeScreenContent extends StatelessWidget {
  const _HomeScreenContent();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HomeController>();
    // final masterDataProvider = context.watch<GlobalMasterDataProvider>();

    if (controller.apiStatus == ApiCallStatus.empty ||
        controller.apiStatus == ApiCallStatus.error ||
        controller.apiStatus == ApiCallStatus.networkError) {
      PLog.info("IM here");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToLogin(context);
      });
      return const LoadingWidget();
    }

    if (controller.user == null) {
      return const LoadingWidget();
    }

    // if (masterDataProvider.isLoading) {
    //   return const LoadingWidget();
    // }

    // if (masterDataProvider.error != null) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     masterDataProvider.fetchMasterData();
    //   });
    //   return const LoadingWidget();
    // }

    return ApiHandleUiWidget(
      apiCallStatus: controller.apiStatus,
      successWidget: Scaffold(
        appBar: _buildAppBar(context, controller),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context, controller.user!),
              _buildEmployeeInfo(context, controller.user!),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, HomeController controller) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppBar(
      title: const Text('Dashboard'),
      centerTitle: true,
      backgroundColor: colorScheme.primaryContainer,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Logout',
          onPressed: () async {
            final result = await controller.logout();
            if (context.mounted) {
              showCustomSnackBar(context, result.message, result.success);
              if (result.success) {
                _navigateToLogin(context);
              }
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          tooltip: 'Settings',
          onPressed: () => Helper.navigateWithFadeTransition(
            context,
            AppRoutes.settings,
            null,
          ),
        ),
      ],
    );
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      FadePageRoute(
        page: const LoginScreen(),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, User user) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: colorScheme.primary,
            child: Text(
              user.name[0].toUpperCase(),
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: colorScheme.onPrimary,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Welcome back,',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                ),
          ),
          Text(
            user.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeInfo(BuildContext context, User user) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Employee Information',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          UserInfoCard(
            icon: Icons.badge_outlined,
            title: 'Employee Name',
            value: user.name,
          ),
          UserInfoCard(
            icon: Icons.email_outlined,
            title: 'Email',
            value: user.email,
          ),
          const SizedBox(height: 24),
          _buildQuickActions(context),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final controller = context.read<HomeController>();
    final List<Widget> actions = [
      Card(
        elevation: 0,
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(0.3),
        child: ListTile(
          leading: Icon(
            Icons.event_available_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: const Text('Players'),
          subtitle: const Text('View all players'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Helper.navigateWithFadeTransition(
            context,
            AppRoutes.players,
            null,
          ),
        ),
      ),
      Card(
        elevation: 0,
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(0.3),
        child: ListTile(
          leading: Icon(
            Icons.location_on_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: const Text('Stadium Images'),
          subtitle: const Text('View all stadium images'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Helper.navigateWithFadeTransition(
            context,
            AppRoutes.stadium,
            null,
          ),
        ),
      ),
    ];

    if (controller.user?.role == 'O') {
      actions.add(
        Card(
          elevation: 0,
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withOpacity(0.3),
          child: ListTile(
            leading: Icon(
              Icons.access_time_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Add Match Data'),
            subtitle: const Text('Add match data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Helper.navigateWithFadeTransition(
              context,
              AppRoutes.match,
              null,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ...actions,
      ],
    );
  }
}
