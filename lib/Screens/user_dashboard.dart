import 'package:flutter/material.dart';
import 'login_Screen.dart';
import '../models/player.dart';
import '../services/api_service.dart';

class UserDashboard extends StatefulWidget {
  final Map<String, dynamic>? userData;
  
  const UserDashboard({super.key, this.userData});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  // Dynamic data from backend
  late Player? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    try {
      // Convert userData to Player object if available
      if (widget.userData != null) {
        user = Player.fromJson(widget.userData!);
        setState(() {
          isLoading = false;
        });
      } else {
        // If no userData provided, try to fetch it from the API
        // This could happen if the login response doesn't include user data
        setState(() {
          isLoading = true;
        });
        
        // You might want to store the user email in shared preferences or pass it here
        // For now, we'll just set user to null
        user = null;
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        user = null;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(user?.name != null ? "${user!.name}'s Dashboard" : 'Player Dashboard'),
          backgroundColor: Colors.blue,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading your data...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(user?.name != null ? "${user!.name}'s Dashboard" : 'Player Dashboard'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildDetailsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue.shade100,
              child: Icon(Icons.person, size: 50, color: Colors.blue),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? 'User Name',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  if (user?.sport != null) ...[
                    const SizedBox(height: 4),
                    _buildInfoRow(Icons.sports_cricket, user!.sport!),
                  ],
                  if (user?.state != null) ...[
                    const SizedBox(height: 4),
                    _buildInfoRow(Icons.location_on, user!.state!),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Player Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 24),
            _buildDetailItem(Icons.badge, 'Player ID', user?.id?.toString() ?? '-'),
            _buildDetailItem(Icons.person, "Father's Name", user?.fatherName ?? '-'),
            _buildDetailItem(Icons.cake, 'Date of Birth', user?.dateOfBirth ?? '-'),
            _buildDetailItem(Icons.wc, 'Gender', user?.gender ?? '-'),
            _buildDetailItem(Icons.credit_card, 'Aadhaar Number', user?.aadhaarNumber ?? '-'),
            _buildDetailItem(Icons.home, 'Address', user?.address ?? '-'),
            _buildDetailItem(Icons.phone, 'Phone Number', user?.phoneNumber ?? '-'),
            _buildDetailItem(Icons.sports, 'Sport', user?.sport ?? '-'),
            _buildDetailItem(Icons.verified, 'Federation ID', user?.federationId ?? '-'),
            _buildDetailItem(Icons.location_city, 'District', user?.district ?? '-'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Text(
            label + ':',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blue),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
} 