class Player {
  final int? id;
  final String name;
  final String email;
  final String? fatherName;
  final String? dateOfBirth;
  final String? gender;
  final String? aadhaarNumber;
  final String? address;
  final String? phoneNumber;
  final String? sport;
  final String? federationId;
  final String? state;
  final String? district;

  Player({
    this.id,
    required this.name,
    required this.email,
    this.fatherName,
    this.dateOfBirth,
    this.gender,
    this.aadhaarNumber,
    this.address,
    this.phoneNumber,
    this.sport,
    this.federationId,
    this.state,
    this.district,
  });

  // Convert JSON to Player object
  factory Player.fromJson(Map<String, dynamic> json) {
    try {
      return Player(
        id: json['id'],
        name: json['fullName'] ?? json['name'] ?? '', // Handle both field names
        email: json['email'] ?? '',
        fatherName: json['fatherName'],
        dateOfBirth: json['dob'] ?? json['dateOfBirth'], // Handle both field names
        gender: json['gender'],
        aadhaarNumber: json['aadhaarNumber'],
        address: json['address'],
        phoneNumber: json['phoneNumber'],
        sport: json['sport'],
        federationId: json['federationId'],
        state: json['state'],
        district: json['district'],
      );
    } catch (e) {
      print('Error parsing Player from JSON: $e');
      print('JSON data: $json');
      // Return a default player with available data
      return Player(
        id: json['id'],
        name: json['fullName'] ?? json['name'] ?? 'Unknown',
        email: json['email'] ?? '',
        fatherName: json['fatherName'],
        dateOfBirth: json['dob'] ?? json['dateOfBirth'],
        gender: json['gender'],
        aadhaarNumber: json['aadhaarNumber'],
        address: json['address'],
        phoneNumber: json['phoneNumber'],
        sport: json['sport'],
        federationId: json['federationId'],
        state: json['state'],
        district: json['district'],
      );
    }
  }

  // Convert Player object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'fatherName': fatherName,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'aadhaarNumber': aadhaarNumber,
      'address': address,
      'phoneNumber': phoneNumber,
      'sport': sport,
      'federationId': federationId,
      'state': state,
      'district': district,
    };
  }

  @override
  String toString() {
    return 'Player(id: $id, name: $name, email: $email, sport: $sport)';
  }
} 