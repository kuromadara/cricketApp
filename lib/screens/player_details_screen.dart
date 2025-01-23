import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cricket/controllers/controllers.dart';
import 'package:cricket/models/models.dart';
import 'package:cricket/ui/ui.dart';

class PlayerDetailsScreen extends StatelessWidget {
  final int playerId;

  const PlayerDetailsScreen({Key? key, required this.playerId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PlayerDetailsController(playerId)..fetchPlayerDetails(),
      child: const PlayerDetailsView(),
    );
  }
}

class PlayerDetailsView extends StatelessWidget {
  const PlayerDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PlayerDetailsController>();
    final player = controller.player;
    final theme = Theme.of(context);

    return ApiHandleUiWidget(
      apiCallStatus: controller.apiStatus,
      successWidget: Scaffold(
        body: player == null
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 250.0,
                    floating: false,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        player.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      background: _buildHeaderBackground(context, player),
                      centerTitle: true,
                      titlePadding: const EdgeInsets.only(bottom: 16),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildPlayerQuickStats(context, player),
                        const SizedBox(height: 16),
                        _buildDetailedStats(context, player),
                        const SizedBox(height: 16),
                        _buildPerformanceSection(context, player),
                      ]),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHeaderBackground(BuildContext context, Player player) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.7),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'player_avatar_${player.id}',
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: Text(
                    player.name.substring(0, 1).toUpperCase(),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Age: ${player.age}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white70,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerQuickStats(BuildContext context, Player player) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildQuickStatColumn(
              context,
              icon: Icons.sports_cricket,
              label: 'Wickets',
              value: player.wickets.toString(),
            ),
            _buildQuickStatColumn(
              context,
              icon: Icons.trending_up,
              label: 'Yearly Score',
              value: player.totalScoreYearly.toString(),
            ),
            _buildQuickStatColumn(
              context,
              icon: Icons.today,
              label: 'Daily Score',
              value: player.totalScoreDaily.toString(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatColumn(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(
          icon,
          color: theme.primaryColor,
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedStats(BuildContext context, Player player) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detailed Statistics',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailStatRow(
              context,
              label: 'Total Wickets',
              value: player.wickets.toString(),
              icon: Icons.sports_cricket_outlined,
            ),
            const Divider(),
            _buildDetailStatRow(
              context,
              label: 'Yearly Performance Score',
              value: player.totalScoreYearly.toString(),
              icon: Icons.calendar_today,
            ),
            const Divider(),
            _buildDetailStatRow(
              context,
              label: 'Daily Performance Score',
              value: player.totalScoreDaily.toString(),
              icon: Icons.today,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailStatRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: theme.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyLarge,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSection(BuildContext context, Player player) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.star_outline,
                  color: theme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Best Performance',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              player.bestPerformance,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
