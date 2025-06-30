class Tournament {
  final int? id;
  final String name;
  final String venue;
  final String startDate;
  final String endDate;
  final String organizer;
  final String email;
  final String phone;
  final String state;
  final String genderCategory;
  final String ageCategory;

  Tournament({
    this.id,
    required this.name,
    required this.venue,
    required this.startDate,
    required this.endDate,
    required this.organizer,
    required this.email,
    required this.phone,
    required this.state,
    required this.genderCategory,
    required this.ageCategory,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'],
      name: json['name'] ?? '',
      venue: json['venue'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      organizer: json['organizer'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      state: json['state'] ?? '',
      genderCategory: json['genderCategory'] ?? '',
      ageCategory: json['ageCategory'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
  }
} 