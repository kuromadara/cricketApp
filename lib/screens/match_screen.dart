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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Details'),
        centerTitle: true,
      ),
      body: ApiHandleUiWidget(
        apiCallStatus: matchController.apiStatus,
        successWidget: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dropdown for Match
                  DropdownButton<MatchModel>(
                    hint: const Text("Select Match"),
                    value: _selectedMatch,
                    onChanged: (MatchModel? newMatch) {
                      setState(() {
                        _selectedMatch = newMatch;
                        _selectedTeam = null; // Reset team and player selection
                        _selectedPlayer = null;
                      });
                    },
                    items: matchController.matches.map((match) {
                      return DropdownMenuItem(
                        value: match,
                        child: Text(
                          '${match.team1.name} vs ${match.team2.name}',
                        ),
                      );
                    }).toList(),
                  ),

                  // Dropdown for Team (if a match is selected)
                  if (_selectedMatch != null) ...[
                    DropdownButton<TeamData>(
                      hint: const Text("Select Team"),
                      value: _selectedTeam,
                      onChanged: (TeamData? newTeam) {
                        setState(() {
                          _selectedTeam = newTeam;
                          _selectedPlayer = null; // Reset player selection
                        });
                        // Fetch players for the selected team
                        if (newTeam != null) {
                          playersController.fetchPlayersByIds(newTeam.players);
                        }
                      },
                      items: [
                        _selectedMatch!.team1,
                        _selectedMatch!.team2,
                      ].map((team) {
                        return DropdownMenuItem(
                          value: team,
                          child: Text(team.name),
                        );
                      }).toList(),
                    ),
                  ],

                  // Dropdown for Player (if a team is selected)
                  if (_selectedTeam != null) ...[
                    Builder(
                      builder: (context) {
                        final players = playersController.selectedPlayers;
                        final apiStatus = playersController.apiStatus;

                        // Debug print to understand the state
                        debugPrint('Players count: ${players.length}');
                        debugPrint('API Status: $apiStatus');

                        // Handle different API statuses
                        if (apiStatus == ApiCallStatus.loading) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (apiStatus == ApiCallStatus.error) {
                          return Text(
                            'Error fetching players',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.red),
                          );
                        }

                        if (players.isEmpty) {
                          return Text(
                            'No players found for this team',
                            style: Theme.of(context).textTheme.bodyLarge,
                          );
                        }

                        // Dropdown for players
                        return DropdownButton<int>(
                          isExpanded: true,
                          hint: const Text("Select Player"),
                          value: _selectedPlayer,
                          onChanged: (int? newPlayerId) {
                            setState(() {
                              _selectedPlayer = newPlayerId;
                            });
                          },
                          items: players.map((player) {
                            return DropdownMenuItem<int>(
                              value: player.id,
                              child: Text(
                                '${player.name} (ID: ${player.id})', 
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],

                  // Number input boxes for match details
                  if (_selectedPlayer != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Match Details',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _scoreController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Score',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _wicketsController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Wickets',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _ballsController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Balls',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _runsController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Runs',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _extrasController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Extras',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _submitMatchDetails(context),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text('Submit Match Details'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}