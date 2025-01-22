import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cricket/controllers/controllers.dart';
import 'package:cricket/models/models.dart';
import 'package:cricket/common/common.dart';
import 'package:cricket/ui/ui.dart';
import 'package:cricket/routes/routes.dart';

class PlayersScreen extends StatelessWidget {
  const PlayersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PlayersController()..fetchPlayers(),
      child: const PlayersView(),
    );
  }
}

class PlayersView extends StatelessWidget {
  const PlayersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PlayersController>();

    return ApiHandleUiWidget(
      apiCallStatus: controller.apiStatus,
      successWidget: Scaffold(
        appBar: AppBar(
          title: const Text('Players'),
        ),
        body: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo is ScrollEndNotification) {
              if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                // At the bottom of the list
                controller.loadNextPage();
              } else if (scrollInfo.metrics.pixels == 0) {
                // At the top of the list
                controller.loadPreviousPage();
              }
            }
            return true;
          },
          child: RefreshIndicator(
            onRefresh: controller.refreshPlayers,
            child: CustomScrollView(
              slivers: [
                if (controller.isLoadingMore && controller.hasPrevious)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => PlayerListTile(player: controller.players[index]),
                    childCount: controller.players.length,
                  ),
                ),
                if (controller.isLoadingMore && controller.hasMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PlayerListTile extends StatelessWidget {
  final Player player;

  const PlayerListTile({Key? key, required this.player}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.sports_cricket_outlined,
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(
          player.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            _buildPlayerStatRow(
              icon: Icons.cake_outlined,
              label: 'Age',
              value: player.age.toString(),
              theme: theme,
            ),
            _buildPlayerStatRow(
              icon: Icons.trending_up,
              label: 'Yearly Score',
              value: player.totalScoreYearly.toString(),
              theme: theme,
            ),
            _buildPlayerStatRow(
              icon: Icons.today,
              label: 'Daily Score',
              value: player.totalScoreDaily.toString(),
              theme: theme,
            ),
            _buildPlayerStatRow(
              icon: Icons.sports_cricket,
              label: 'Wickets',
              value: player.wickets.toString(),
              theme: theme,
            ),
          ],
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: theme.colorScheme.secondary,
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.playerDetails,
            arguments: {'playerId': player.id},
          );
        },
      ),
    );
  }

  Widget _buildPlayerStatRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: $value',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
