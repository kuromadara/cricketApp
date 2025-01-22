import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cricket/controllers/match_controller.dart';
import 'package:cricket/controllers/players_controller.dart';
import 'package:cricket/common/common.dart';
import 'package:cricket/models/models.dart';
import 'package:cricket/ui/ui.dart';

class MatchScreen extends StatelessWidget {
  const MatchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => MatchController()..fetchPendingMatches(),
        ),
        ChangeNotifierProvider(
          create: (context) => PlayersController(),
        ),
      ],
      child: const _MatchScreenContent(),
    );
  }
}

class _MatchScreenContent extends StatefulWidget {
  const _MatchScreenContent();

  @override
  __MatchScreenContentState createState() => __MatchScreenContentState();
}

class __MatchScreenContentState extends State<_MatchScreenContent> {
  MatchModel? _selectedMatch;
  TeamData? _selectedTeam;
  int? _selectedPlayer;

  // Text controllers for input fields
  final TextEditingController _scoreController = TextEditingController();
  final TextEditingController _wicketsController = TextEditingController();
  final TextEditingController _ballsController = TextEditingController();
  final TextEditingController _runsController = TextEditingController();
  final TextEditingController _extrasController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _scoreController.dispose();
    _wicketsController.dispose();
    _ballsController.dispose();
    _runsController.dispose();
    _extrasController.dispose();
    super.dispose();
  }

  // Method to submit match details
  void _submitMatchDetails(BuildContext context) {
    final matchController = context.read<MatchController>();

    // Validate inputs
    if (_selectedMatch == null || _selectedPlayer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a match and player first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Parse input values with error handling
    int? score = int.tryParse(_scoreController.text);
    int? wickets = int.tryParse(_wicketsController.text);
    int? balls = int.tryParse(_ballsController.text);
    int? runs = int.tryParse(_runsController.text);
    int? extras = int.tryParse(_extrasController.text);

    // Validate numeric inputs
    if (score == null || wickets == null || balls == null || runs == null || extras == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter valid numeric values'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Prepare match details data
    final matchDetailsData = {
      'cricket_match_id': _selectedMatch!.id,
      'player_id': _selectedPlayer,
      'score': score,
      'wickets': wickets,
      'ball': balls,
      'runs': runs,
      'extras': extras,
      'status': 'completed', // Default status as requested
    };

    // Call method to submit match details
    matchController.submitMatchDetails(matchDetailsData).then((_) {
      // Success scenario
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Match details submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Reset input fields and selections
      _scoreController.clear();
      _wicketsController.clear();
      _ballsController.clear();
      _runsController.clear();
      _extrasController.clear();
      setState(() {
        _selectedPlayer = null;
      });
    }).catchError((error) {
      // Error scenario
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit match details: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final matchController = context.watch<MatchController>();
    final playersController = context.watch<PlayersController>();
    final theme = Theme.of(context);

    return ApiHandleUiWidget(
      apiCallStatus: matchController.apiStatus,
      successWidget: Scaffold(
        appBar: AppBar(
          title: const Text('Match Details Entry'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Match Selection Section
                _buildSectionHeader(context, 'Select Match', Icons.sports_cricket),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Match Dropdown
                        _buildDropdownWithLabel(
                          context: context,
                          label: 'Match',
                          hint: 'Select a match',
                          value: _selectedMatch,
                          items: matchController.matches.map((match) {
                            return DropdownMenuItem(
                              value: match,
                              child: Text(
                                '${match.team1.name} vs ${match.team2.name}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (MatchModel? newMatch) {
                            setState(() {
                              _selectedMatch = newMatch;
                              _selectedTeam = null;
                              _selectedPlayer = null;
                            });
                          },
                        ),

                        // Team Dropdown (if match selected)
                        if (_selectedMatch != null) ...[
                          const SizedBox(height: 16),
                          _buildDropdownWithLabel(
                            context: context,
                            label: 'Team',
                            hint: 'Select a team',
                            value: _selectedTeam,
                            items: [
                              _selectedMatch!.team1,
                              _selectedMatch!.team2,
                            ].map((team) {
                              return DropdownMenuItem(
                                value: team,
                                child: Text(team.name),
                              );
                            }).toList(),
                            onChanged: (TeamData? newTeam) {
                              setState(() {
                                _selectedTeam = newTeam;
                                _selectedPlayer = null;
                              });
                              if (newTeam != null) {
                                playersController.fetchPlayersByIds(newTeam.players);
                              }
                            },
                          ),
                        ],

                        // Player Dropdown (if team selected)
                        if (_selectedTeam != null) ...[
                          const SizedBox(height: 16),
                          Builder(
                            builder: (context) {
                              final players = playersController.selectedPlayers;
                              final apiStatus = playersController.apiStatus;

                              if (apiStatus == ApiCallStatus.loading) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              if (apiStatus == ApiCallStatus.error) {
                                return Text(
                                  'Error fetching players',
                                  style: theme.textTheme.bodyLarge?.copyWith(color: Colors.red),
                                );
                              }

                              if (players.isEmpty) {
                                return Text(
                                  'No players found for this team',
                                  style: theme.textTheme.bodyLarge,
                                );
                              }

                              return _buildDropdownWithLabel(
                                context: context,
                                label: 'Player',
                                hint: 'Select a player',
                                value: _selectedPlayer,
                                items: players.map((player) {
                                  return DropdownMenuItem<int>(
                                    value: player.id,
                                    child: Text(
                                      '${player.name} (ID: ${player.id})', 
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (int? newPlayerId) {
                                  setState(() {
                                    _selectedPlayer = newPlayerId;
                                  });
                                },
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Match Details Section
                if (_selectedPlayer != null) ...[
                  const SizedBox(height: 16),
                  _buildSectionHeader(context, 'Match Performance', Icons.analytics_outlined),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // First Row: Score and Wickets
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _scoreController,
                                  label: 'Score',
                                  icon: Icons.score,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  controller: _wicketsController,
                                  label: 'Wickets',
                                  icon: Icons.sports_cricket,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Second Row: Balls and Runs
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _ballsController,
                                  label: 'Balls',
                                  icon: Icons.timer,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  controller: _runsController,
                                  label: 'Runs',
                                  icon: Icons.trending_up,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Extras TextField
                          _buildTextField(
                            controller: _extrasController,
                            label: 'Extras',
                            icon: Icons.add_box,
                          ),
                          const SizedBox(height: 24),
                          // Submit Button
                          ElevatedButton.icon(
                            onPressed: () => _submitMatchDetails(context),
                            icon: const Icon(Icons.send),
                            label: const Text('Submit Match Details'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to create section headers
  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: theme.primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to create dropdowns with labels
  Widget _buildDropdownWithLabel<T>({
    required BuildContext context,
    required String label,
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          value: value,
          onChanged: onChanged,
          items: items,
          isExpanded: true,
        ),
      ],
    );
  }

  // Helper method to create text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}