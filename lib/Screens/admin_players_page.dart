import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/player.dart';

class AdminPlayersPage extends StatefulWidget {
  const AdminPlayersPage({super.key});

  @override
  State<AdminPlayersPage> createState() => _AdminPlayersPageState();
}

class _AdminPlayersPageState extends State<AdminPlayersPage> {
  List<Player> players = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await ApiService.getAllPlayers();
      
      if (result['success']) {
        setState(() {
          players = result['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = result['error'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading players: $e';
        _isLoading = false;
      });
    }
  }

  List<Player> get _filteredPlayers {
    if (_searchQuery.isEmpty) {
      return players;
    }
    return players.where((player) {
      return player.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             player.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             (player.sport?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registered Players'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPlayers,
          ),
          IconButton(
            icon: const Icon(Icons.wifi),
            onPressed: _testConnection,
            tooltip: 'Test Connection',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFF5F5F5)],
          ),
        ),
        child: Column(
        children: [
          // Search Bar
            Container(
              margin: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search players by name, email, or sport...',
                  prefixIcon: const Icon(Icons.search, color: Colors.blue),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          
          // Players Count
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12.0),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            child: Row(
                mainAxisSize: MainAxisSize.min,
              children: [
                  const Icon(Icons.people, color: Colors.blue, size: 18),
                  const SizedBox(width: 6),
                Text(
                  '${_filteredPlayers.length} player${_filteredPlayers.length == 1 ? '' : 's'} found',
                    style: const TextStyle(
                      fontSize: 14,
                    fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                ),
              ],
            ),
          ),
          
            const SizedBox(height: 12),
          
          // Players List
          Expanded(
            child: _buildPlayersList(),
          ),
        ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateMatchDialog,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Create Match'),
      ),
    );
  }

  Widget _buildPlayersList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
                size: 48,
              color: Colors.red,
            ),
              const SizedBox(height: 12),
            Text(
              'Error',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
              const SizedBox(height: 6),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
              const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadPlayers,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              child: const Text('Retry'),
            ),
          ],
          ),
        ),
      );
    }

    if (_filteredPlayers.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
                size: 48,
              color: Colors.grey,
            ),
              SizedBox(height: 12),
            Text(
              'No players found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPlayers,
      color: Colors.blue,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: _filteredPlayers.length,
        itemBuilder: (context, index) {
          final player = _filteredPlayers[index];
          return _buildPlayerCard(player, index);
        },
      ),
    );
  }

  Widget _buildPlayerCard(Player player, int index) {
    final displayName = player.name.isNotEmpty ? player.name : player.email.split('@')[0];
    final sportName = player.sport ?? 'Not specified';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showPlayerDetails(player),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar Circle
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: _getAvatarColor(index),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _getAvatarColor(index).withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Player Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Player Name
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 3),
                      
                      // Sport Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.sports_soccer,
                              size: 12,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              sportName,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 3),
                      
                      // Email
                      Text(
                        player.email,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Action Buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Delete Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        onPressed: () => _showDeleteConfirmation(player),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        tooltip: 'Delete Player',
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Arrow Icon
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.blue,
                      size: 14,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getAvatarColor(int index) {
    final colors = [
      Colors.blue,
      Colors.blue.shade700,
      Colors.blue.shade600,
      Colors.blue.shade500,
      Colors.blue.shade400,
      Colors.indigo,
      Colors.indigo.shade600,
      Colors.indigo.shade500,
    ];
    return colors[index % colors.length];
  }

  void _showPlayerDetails(Player player) {
    final String displayName = player.name.isNotEmpty ? player.name : 'Not provided';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Player Details',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('ID', player.id?.toString() ?? 'N/A'),
              _buildDetailRow('Name', displayName),
              _buildDetailRow('Email', player.email),
              _buildDetailRow('Father\'s Name', player.fatherName ?? 'N/A'),
              _buildDetailRow('Date of Birth', player.dateOfBirth ?? 'N/A'),
              _buildDetailRow('Gender', player.gender ?? 'N/A'),
              _buildDetailRow('Aadhaar', player.aadhaarNumber ?? 'N/A'),
              _buildDetailRow('Phone', player.phoneNumber ?? 'N/A'),
              _buildDetailRow('Sport', player.sport ?? 'N/A'),
              _buildDetailRow('Federation ID', player.federationId ?? 'N/A'),
              _buildDetailRow('State', player.state ?? 'N/A'),
              _buildDetailRow('District', player.district ?? 'N/A'),
              _buildDetailRow('Address', player.address ?? 'N/A'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3.0),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.blue,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Player player) {
    final displayName = player.name.isNotEmpty ? player.name : player.email.split('@')[0];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Delete Player',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete this player?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Player Details:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Name: $displayName',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Email: ${player.email}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Sport: ${player.sport ?? 'Not specified'}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This action cannot be undone.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePlayer(player);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePlayer(Player player) async {
    // Debug: Print player information
    print('Attempting to delete player:');
    print('Player ID: ${player.id}');
    print('Player Name: ${player.name}');
    print('Player Email: ${player.email}');
    
    // Check if player ID is null
    if (player.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Player ID is null'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            SizedBox(width: 16),
            Text('Deleting player...'),
          ],
        ),
      ),
    );

    try {
      print('Calling API to delete player with ID: ${player.id}');
      
      // Call API to delete player
      final result = await ApiService.deletePlayer(player.id!);
      
      print('API Response: $result');
      
      // Close loading dialog
      Navigator.pop(context);
      
      if (result['success']) {
        // Remove player from local list
        setState(() {
          players.remove(player);
        });
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Player ${player.name.isNotEmpty ? player.name : player.email} deleted successfully'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${result['error']}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Exception during delete operation: $e');
      
      // Close loading dialog
      Navigator.pop(context);
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting player: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _testConnection() async {
    try {
      final result = await ApiService.testConnection();
      
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection failed: ${result['error']}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Test error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showCreateMatchDialog() {
    String? selectedPlayer1Id;
    String? selectedPlayer2Id;
    TimeOfDay selectedTime = TimeOfDay.now();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Upcoming Match'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Player 1 Selection
                DropdownButtonFormField<String>(
                  value: selectedPlayer1Id,
                  decoration: const InputDecoration(
                    labelText: 'Player 1',
                    border: OutlineInputBorder(),
                  ),
                  items: _filteredPlayers.map((player) {
                    return DropdownMenuItem(
                      value: player.id.toString(),
                      child: Text('${player.name} (ID: ${player.id})'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedPlayer1Id = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // Player 2 Selection
                DropdownButtonFormField<String>(
                  value: selectedPlayer2Id,
                  decoration: const InputDecoration(
                    labelText: 'Player 2',
                    border: OutlineInputBorder(),
                  ),
                  items: _filteredPlayers.map((player) {
                    return DropdownMenuItem(
                      value: player.id.toString(),
                      child: Text('${player.name} (ID: ${player.id})'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedPlayer2Id = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // Date Selection
                ListTile(
                  title: const Text('Match Date'),
                  subtitle: Text(
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        selectedDate = date;
                      });
                    }
                  },
                ),
                
                // Time Selection
                ListTile(
                  title: const Text('Match Time'),
                  subtitle: Text(selectedTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (time != null) {
                      setState(() {
                        selectedTime = time;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedPlayer1Id == null || selectedPlayer2Id == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select both players'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (selectedPlayer1Id == selectedPlayer2Id) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select different players'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Show loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );

                // Create match
                final result = await ApiService.createUpcomingMatch(
                  player1Id: selectedPlayer1Id!,
                  player2Id: selectedPlayer2Id!,
                  matchTime: '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                  matchDate: '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}',
                );

                // Hide loading
                Navigator.pop(context);

                if (result['success']) {
                  Navigator.pop(context); // Close dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message'] ?? 'Match created successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['error'] ?? 'Failed to create match'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Create Match'),
            ),
          ],
        ),
      ),
    );
  }
} 