class BusinessProfile {
  final String id;
  final String name;
  final String businessName;
  final String phone;
  final String? email;
  final String? address;
  final String? tagline;
  final String preferredLanguage; // 'bilingual', 'kannada', 'english'
  final String? businessLogo;

  const BusinessProfile({
    required this.id,
    required this.name,
    required this.businessName,
    required this.phone,
    this.email,
    this.address,
    this.tagline,
    this.preferredLanguage = 'bilingual',
    this.businessLogo,
  });

  BusinessProfile copyWith({
    String? id,
    String? name,
    String? businessName,
    String? phone,
    String? email,
    String? address,
    String? tagline,
    String? preferredLanguage,
    String? businessLogo,
  }) {
    return BusinessProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      businessName: businessName ?? this.businessName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      tagline: tagline ?? this.tagline,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      businessLogo: businessLogo ?? this.businessLogo,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'businessName': businessName,
        'phone': phone,
        if (email != null) 'email': email,
        if (address != null) 'address': address,
        if (tagline != null) 'tagline': tagline,
        'preferredLanguage': preferredLanguage,
        if (businessLogo != null) 'businessLogo': businessLogo,
      };

  factory BusinessProfile.fromJson(Map<String, dynamic> json) => BusinessProfile(
        id: json['id'] as String? ?? 'default_owner',
        name: json['name'] as String? ?? 'Prashanth Bhat',
        businessName: json['businessName'] as String? ??
            'Sri Raghavendra Catering Services',
        phone: json['phone'] as String? ?? '+91 98450 12345',
        email: json['email'] as String? ?? 'catering@sriraghavendra.com',
        address: json['address'] as String? ?? 'Bengaluru, Karnataka',
        tagline: json['tagline'] as String? ??
            'Authentic Traditional Catering for All Occasions',
        preferredLanguage: json['preferredLanguage'] as String? ?? 'bilingual',
        businessLogo: json['businessLogo'] as String?,
      );

  static BusinessProfile defaultProfile() => const BusinessProfile(
        id: 'caterer_001',
        name: 'Prashanth Bhat',
        businessName: 'Sri Raghavendra Catering Services',
        phone: '+91 98450 12345',
        email: 'raghavendracaterers@gmail.com',
        address: 'Malleswaram, Bengaluru, Karnataka',
        tagline: 'ಶುದ್ಧ ಸಾಂಪ್ರದಾಯಿಕ ಅಡುಗೆ ಸೇವೆ • Authentic Catering',
        preferredLanguage: 'bilingual',
      );
}
