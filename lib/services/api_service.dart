import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/player.dart';
import '../models/tournament.dart';
import 'dart:io';

class ApiService {
  // Your Spring Boot API endpoint - handle different platforms
  static const String baseUrl = 'http://10.0.2.2:8080'; // For Android emulator
  // static const String baseUrl = 'http://localhost:8080'; // For web/desktop
  // static const String baseUrl = 'http://127.0.0.1:8080'; // Alternative localhost
  // static const String baseUrl = 'http://192.168.1.XXX:8080'; // For physical device (replace XXX with your IP)

  // Register user with all form data
  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    String? fatherName,
    String? dateOfBirth,
    String? gender,
    String? aadhaarNumber,
    String? address,
    String? phoneNumber,
    String? sport,
    String? federationId,
    String? state,
    String? district,
  }) async {
    try {
      print('=== REGISTRATION API CALL ===');
      print('Sending registration data to: $baseUrl/registration');
      print('Password length: ${password.length}');
      print('Password (first 3 chars): ${password.substring(0, password.length > 3 ? 3 : password.length)}***');

      final requestBody = {
        'fullName': name,
        'email': email,
        'password': password,
        'fatherName': fatherName,
        'dob': dateOfBirth,
        'gender': gender,
        'aadhaarNumber': aadhaarNumber,
        'address': address,
        'phoneNumber': phoneNumber,
        'sport': sport,
        'federationId': federationId,
        'state': state,
        'district': district,
      };

      print('Request body keys: ${requestBody.keys.toList()}');
      print('Password field present: ${requestBody.containsKey('password')}');

      final response = await http.post(
        Uri.parse('$baseUrl/registration'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {
          'success': false,
          'error':
              'Registration failed: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      print('Error in API call: $e');
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Get all registered players
  static Future<Map<String, dynamic>> getAllPlayers() async {
    try {
      print('Fetching players from: $baseUrl/playerdata');

      final response = await http.get(
        Uri.parse('$baseUrl/playerdata'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> playersData = jsonDecode(response.body);
        final List<Player> players =
            playersData.map((json) => Player.fromJson(json)).toList();

        return {'success': true, 'data': players};
      } else {
        return {
          'success': false,
          'error':
              'Failed to fetch players: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      print('Error fetching players: $e');
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Test connection to Spring Boot server
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      print('=== TESTING CONNECTION ===');
      print('Testing connection to: $baseUrl');
      print('Platform: ${Platform.operatingSystem}');

      final response = await http.get(
        Uri.parse('$baseUrl/playerdata'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('Test Response Status: ${response.statusCode}');
      print('Test Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Connection successful'};
      } else {
        return {
          'success': false,
          'error': 'Connection failed: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      print('Connection test error: $e');
      
      // Provide specific error messages
      if (e.toString().contains('SocketException')) {
        return {
          'success': false, 
          'error': 'Cannot connect to server. Make sure:\n1. Spring Boot is running on port 8080\n2. You\'re using the correct URL for your platform\n3. No firewall is blocking the connection'
        };
      } else if (e.toString().contains('TimeoutException')) {
        return {
          'success': false,
          'error': 'Connection timeout. Server might be slow or not responding.'
        };
      } else if (e.toString().contains('HandshakeException')) {
        return {
          'success': false,
          'error': 'SSL/TLS handshake failed. Check server configuration.'
        };
      } else {
        return {'success': false, 'error': 'Connection error: $e'};
      }
    }
  }

  // Delete a player by ID (using POST method to avoid 405 error)
  static Future<Map<String, dynamic>> deletePlayer(int playerId) async {
    try {
      final url = '$baseUrl/delete/$playerId';
      print('=== DELETE PLAYER DEBUG ===');
      print('Player ID: $playerId');
      print('Full URL: $url');
      print('Base URL: $baseUrl');

      // Using POST method instead of DELETE to avoid 405 error
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        body: jsonEncode({'id': playerId, 'action': 'delete'}),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');

      // Handle different success status codes
      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 202) {
        print('Delete successful');
        return {'success': true, 'message': 'Player deleted successfully'};
      } else if (response.statusCode == 404) {
        print('Player not found');
        return {'success': false, 'error': 'Player not found (404)'};
      } else if (response.statusCode == 405) {
        print('Method not allowed - trying alternative approach');
        return {
          'success': false,
          'error':
              'Method not allowed (405) - Check Spring Boot controller mapping',
        };
      } else if (response.statusCode == 500) {
        print('Server error');
        return {
          'success': false,
          'error': 'Server error (500) - Check Spring Boot logs',
        };
      } else {
        print('Delete failed with status: ${response.statusCode}');
        return {
          'success': false,
          'error':
              'Failed to delete player: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      print('=== DELETE PLAYER ERROR ===');
      print('Error type: ${e.runtimeType}');
      print('Error message: $e');
      print('Stack trace: ${StackTrace.current}');

      // Check for specific network errors
      if (e.toString().contains('SocketException')) {
        return {
          'success': false,
          'error':
              'Cannot connect to server. Make sure Spring Boot is running on port 8080',
        };
      } else if (e.toString().contains('HandshakeException')) {
        return {
          'success': false,
          'error': 'SSL/TLS handshake failed. Check server configuration',
        };
      } else {
        return {'success': false, 'error': 'Network error: $e'};
      }
    }
  }

  // Login user with email and password
  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      print('Sending login data to: $baseUrl/login');

      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('Login Response Status: ${response.statusCode}');
      print('Login Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Handle different response formats from your Spring Boot backend
        if (responseData is bool && responseData == true) {
          // If backend returns just 'true', fetch user data separately
          final userDataResult = await getUserByEmail(email);
          if (userDataResult['success']) {
            return {
              'success': true,
              'message': 'Login successful',
              'userData': userDataResult['data'],
            };
          } else {
            return {
              'success': true,
              'message': 'Login successful',
              'userData': null,
            };
          }
        } else if (responseData is Map<String, dynamic>) {
          // If backend returns user data directly
          if (responseData['success'] == true ||
              responseData['authenticated'] == true ||
              responseData['status'] == 'success') {
            return {
              'success': true,
              'message': 'Login successful',
              'userData':
                  responseData['user'] ??
                  responseData['userData'] ??
                  responseData['data'] ??
                  responseData,
            };
          } else if (responseData['success'] == false ||
              responseData['authenticated'] == false ||
              responseData['status'] == 'error') {
            return {
              'success': false,
              'error':
                  responseData['message'] ??
                  responseData['error'] ??
                  responseData['reason'] ??
                  'Login failed',
            };
          }
        }

        // If responseData is a user object directly (no success/error wrapper)
        return {
          'success': true,
          'message': 'Login successful',
          'userData': responseData,
        };
      } else if (response.statusCode == 401) {
        return {'success': false, 'error': 'Invalid email or password'};
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'error':
              'Login endpoint not found. Please check server configuration.',
        };
      } else if (response.statusCode == 500) {
        return {
          'success': false,
          'error': 'Server error. Please try again later.',
        };
      } else {
        return {
          'success': false,
          'error': 'Login failed: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      print('Error in login API call: $e');

      // Handle specific network errors
      if (e.toString().contains('SocketException')) {
        return {
          'success': false,
          'error':
              'Cannot connect to server. Make sure Spring Boot is running on port 8080',
        };
      } else if (e.toString().contains('HandshakeException')) {
        return {
          'success': false,
          'error': 'SSL/TLS handshake failed. Check server configuration',
        };
      } else if (e.toString().contains('FormatException')) {
        return {
          'success': false,
          'error': 'Invalid response format from server',
        };
      } else {
        return {'success': false, 'error': 'Network error: $e'};
      }
    }
  }

  // Get user data by email
  static Future<Map<String, dynamic>> getUserByEmail(String email) async {
    try {
      print('Fetching user data for email: $email');

      final response = await http.get(
        Uri.parse('$baseUrl/user/$email'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Get User Response Status: ${response.statusCode}');
      print('Get User Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);

        // Validate that we received user data
        if (userData != null) {
          return {'success': true, 'data': userData};
        } else {
          return {
            'success': false,
            'error': 'No user data received from server',
          };
        }
      } else if (response.statusCode == 404) {
        return {'success': false, 'error': 'User not found with email: $email'};
      } else if (response.statusCode == 500) {
        return {
          'success': false,
          'error': 'Server error while fetching user data',
        };
      } else {
        return {
          'success': false,
          'error':
              'Failed to fetch user data: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      print('Error fetching user data: $e');

      // Handle specific network errors
      if (e.toString().contains('SocketException')) {
        return {
          'success': false,
          'error':
              'Cannot connect to server. Make sure Spring Boot is running on port 8080',
        };
      } else if (e.toString().contains('FormatException')) {
        return {
          'success': false,
          'error': 'Invalid response format from server',
        };
      } else {
        return {'success': false, 'error': 'Network error: $e'};
      }
    }
  }

  // Create tournament
  static Future<Map<String, dynamic>> createTournament({
    required String name,
    required String venue,
    required String startDate,
    required String endDate,
    required String organizer,
    required String email,
    required String phone,
    required String state,
    required String genderCategory,
    required String ageCategory,
  }) async {
    try {
      print('=== CREATE TOURNAMENT API CALL ===');
      print('Sending tournament data to: $baseUrl/create');

      final requestBody = {
        'name': name,
        'venue': venue,
        'startDate': startDate,
        'endDate': endDate,
        'organizer': organizer,
        'email': email,
        'phone': phone,
        'state': state,
        'genderCategory': genderCategory,
        'ageCategory': ageCategory,
      };

      print('Request body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse('$baseUrl/create'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'Tournament created successfully'};
      } else {
        return {
          'success': false,
          'error': 'Failed to create tournament: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      print('Error creating tournament: $e');
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Get all tournaments
  static Future<Map<String, dynamic>> getAllTournaments() async {
    try {
      print('Fetching tournaments from: $baseUrl/eventdata');

      final response = await http.get(
        Uri.parse('$baseUrl/eventdata'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> tournamentsData = jsonDecode(response.body);
        final List<Tournament> tournaments =
            tournamentsData.map((json) => Tournament.fromJson(json)).toList();

        return {'success': true, 'data': tournaments};
      } else {
        return {
          'success': false,
          'error': 'Failed to fetch tournaments: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      print('Error fetching tournaments: $e');
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Register player for tournament
  static Future<Map<String, dynamic>> registerPlayerForTournament({
    required String playerId,
    required String playerName,
    required String playerPassword,
    required String tournamentName,
  }) async {
    try {
      print('=== PLAYER REGISTRATION API CALL ===');
      print('Sending player registration to: $baseUrl/Register');
      print('Tournament Name: $tournamentName');
     

      final requestBody = {
        'player_id': playerId, // Send as string instead of converting to int
        'player_name': playerName,
        'password': playerPassword,
        'eventName': tournamentName,
      };

      print('Request body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse('$baseUrl/Register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = jsonDecode(response.body);
          return {
            'success': true, 
            'message': responseData['message'] ?? 'Player registered successfully for tournament'
          };
        } catch (e) {
          // If response is not JSON, treat it as success message
          return {
            'success': true,
            'message': 'Player registered successfully for tournament'
          };
        }
      } else {
        return {
          'success': false,
          'error': 'Failed to register player: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      print('Error registering player: $e');
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Get registered players for events
  static Future<Map<String, dynamic>> getRegisteredPlayers() async {
    try {
      print('=== FETCHING REGISTERED PLAYERS ===');
      print('Fetching from: $baseUrl/showRegistedPlayer');

      final response = await http.get(
        Uri.parse('$baseUrl/showRegistedPlayer'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> playersData = jsonDecode(response.body);
        return {'success': true, 'data': playersData};
      } else {
        return {
          'success': false,
          'error': 'Failed to fetch registered players: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      print('Error fetching registered players: $e');
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Create upcoming match
  static Future<Map<String, dynamic>> createUpcomingMatch({
    required String player1Id,
    required String player2Id,
    required String matchTime,
    required String matchDate,
  }) async {
    try {
      print('=== CREATE UPCOMING MATCH API CALL ===');
      print('Sending match data to: $baseUrl/createMatch');

      final requestBody = {
        'player1Id': player1Id,
        'player2Id': player2Id,
        'matchTime': matchTime,
        'matchDate': matchDate,
      };

      print('Request body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse('$baseUrl/createMatch'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'Match created successfully'};
      } else {
        return {
          'success': false,
          'error': 'Failed to create match: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      print('Error creating match: $e');
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Get all upcoming matches
  static Future<Map<String, dynamic>> getUpcomingMatches() async {
    try {
      print('=== FETCHING UPCOMING MATCHES ===');
      print('Fetching from: $baseUrl/getMatches');

      final response = await http.get(
        Uri.parse('$baseUrl/getMatches'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> matchesData = jsonDecode(response.body);
        return {'success': true, 'data': matchesData};
      } else {
        return {
          'success': false,
          'error': 'Failed to fetch matches: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      print('Error fetching matches: $e');
      return {'success': false, 'error': 'Network error: $e'};
    }
  }
}
