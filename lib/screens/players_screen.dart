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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(player.name),
        subtitle: Text(
          'Age: ${player.age} | Wickets: ${player.wickets}\n'
          'Yearly Score: ${player.totalScoreYearly} | Daily Score: ${player.totalScoreDaily}',
        ),
        isThreeLine: true,
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
}
