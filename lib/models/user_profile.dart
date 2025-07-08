class UserProfile {
  String name;
  String photoPath; // path lokal foto profil
  String email;
  String phone;
  String address;
  String bio;
  List<String> skills;
  List<Education> education;
  List<Experience> experiences;
  List<String> hobbies;
  String instagram;
  Map<String, double> characteristics;
  List<Activity> activities;
  String characteristicsLabel;

  UserProfile({
    required this.name,
    required this.photoPath,
    required this.email,
    required this.phone,
    required this.address,
    required this.bio,
    required this.skills,
    required this.education,
    required this.experiences,
    required this.hobbies,
    required this.instagram,
    required this.characteristics,
    required this.activities,
    required this.characteristicsLabel,
  });

  factory UserProfile.empty() => UserProfile(
        name: '',
        photoPath: '',
        email: '',
        phone: '',
        address: '',
        bio: '',
        skills: [],
        education: [],
        experiences: [],
        hobbies: [],
        instagram: '',
        characteristics: {
          'KOSONG': 1.0,
        },
        activities: [],
        characteristicsLabel: 'KOSONG',
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'photoPath': photoPath,
        'email': email,
        'phone': phone,
        'address': address,
        'bio': bio,
        'skills': skills,
        'education': education.map((e) => e.toMap()).toList(),
        'experiences': experiences.map((e) => e.toMap()).toList(),
        'hobbies': hobbies,
        'instagram': instagram,
        'characteristics': characteristics,
        'activities': activities.map((a) => a.toMap()).toList(),
        'characteristicsLabel': characteristicsLabel,
      };

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        name: map['name'] ?? '',
        photoPath: map['photoPath'] ?? '',
        email: map['email'] ?? '',
        phone: map['phone'] ?? '',
        address: map['address'] ?? '',
        bio: map['bio'] ?? '',
        skills: List<String>.from(map['skills'] ?? []),
        education: (map['education'] as List<dynamic>? ?? [])
            .map((e) => Education.fromMap(e))
            .toList(),
        experiences: (map['experiences'] as List<dynamic>? ?? [])
            .map((e) => Experience.fromMap(e))
            .toList(),
        hobbies: List<String>.from(map['hobbies'] ?? []),
        instagram: map['instagram'] ?? '',
        characteristics: Map<String, double>.from(map['characteristics'] ?? {
          'KOSONG': 1.0,
        }),
        activities: (map['activities'] as List<dynamic>? ?? [])
            .map((a) => Activity.fromMap(a))
            .toList(),
        characteristicsLabel: map['characteristicsLabel'] ?? 'KOSONG',
      );
}

class Education {
  String level;
  String schoolName;
  String year;
  String description;

  Education({
    required this.level,
    required this.schoolName,
    required this.year,
    required this.description,
  });

  Map<String, dynamic> toMap() => {
        'level': level,
        'schoolName': schoolName,
        'year': year,
        'description': description,
      };

  factory Education.fromMap(Map<String, dynamic> map) => Education(
        level: map['level'] ?? '',
        schoolName: map['schoolName'] ?? '',
        year: map['year'] ?? '',
        description: map['description'] ?? '',
      );
}

class Experience {
  String title;
  String company;
  String year;
  String description;

  Experience({
    required this.title,
    required this.company,
    required this.year,
    required this.description,
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'company': company,
        'year': year,
        'description': description,
      };

  factory Experience.fromMap(Map<String, dynamic> map) => Experience(
        title: map['title'] ?? '',
        company: map['company'] ?? '',
        year: map['year'] ?? '',
        description: map['description'] ?? '',
      );
}

class Activity {
  String time;
  String name;
  String description;
  String icon; // Simpan nama ikon, nanti di-mapping di UI

  Activity({
    required this.time,
    required this.name,
    required this.description,
    required this.icon,
  });

  Map<String, dynamic> toMap() => {
        'time': time,
        'name': name,
        'description': description,
        'icon': icon,
      };

  factory Activity.fromMap(Map<String, dynamic> map) => Activity(
        time: map['time'] ?? '',
        name: map['name'] ?? '',
        description: map['description'] ?? '',
        icon: map['icon'] ?? '',
      );
} 