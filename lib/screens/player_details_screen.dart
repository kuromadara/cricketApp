import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cricket/controllers/controllers.dart';
import 'package:cricket/models/models.dart';
import 'package:cricket/common/common.dart';
import 'package:cricket/ui/ui.dart';

class PlayerDetailsScreen extends StatelessWidget {
  final int playerId;

  const PlayerDetailsScreen({Key? key, required this.playerId}) : super(key: key);

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

    return ApiHandleUiWidget(
      apiCallStatus: controller.apiStatus,
      successWidget: Scaffold(
        appBar: AppBar(
          title: Text(player?.name ?? 'Player Details'),
          centerTitle: true,
        ),
        body: player == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(context, player),
                    const SizedBox(height: 16),
                    _buildStats(context, player),
                    const SizedBox(height: 16),
                    _buildPerformance(context, player),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Player player) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Text(
              player.name.substring(0, 1).toUpperCase(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            player.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Age: ${player.age}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context, Player player) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Statistics',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildStatRow(
                context,
                'Total Wickets',
                player.wickets.toString(),
                Icons.sports_cricket,
              ),
              const Divider(),
              _buildStatRow(
                context,
                'Yearly Score',
                player.totalScoreYearly.toString(),
                Icons.calendar_today,
              ),
              const Divider(),
              _buildStatRow(
                context,
                'Daily Score',
                player.totalScoreDaily.toString(),
                Icons.today,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerformance(BuildContext context, Player player) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Best Performance',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                player.bestPerformance,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
