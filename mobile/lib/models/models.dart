class Area {
  const Area({
    required this.id,
    required this.name,
    required this.number,
    this.assistantGovernor,
    this.kind,
  });

  final String id;
  final String name;
  final int number;
  final String? assistantGovernor;
  final String? kind;

  bool get isDistrictTeam => kind == 'district_team';

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['id'] as String,
      name: json['name'] as String,
      number: json['number'] as int,
      assistantGovernor: json['assistant_governor'] as String?,
      kind: json['kind'] as String?,
    );
  }
}

String? _logoAsset(Object? logo) {
  if (logo is! String || logo.trim().isEmpty) return null;
  return 'assets/images/clubs/${logo.trim()}';
}

class ClubSummary {
  const ClubSummary({
    required this.id,
    required this.areaId,
    required this.name,
    this.logoAsset,
    this.kind,
    this.memberCount,
  });

  final String id;
  final String areaId;
  final String name;
  final String? logoAsset;
  final String? kind;
  final int? memberCount;

  bool get isDistrictTeam => kind == 'district_team';

  factory ClubSummary.fromJson(Map<String, dynamic> json) {
    final members = json['members'];
    final count =
        json['member_count'] as int? ??
        (members is List ? members.length : null);
    return ClubSummary(
      id: json['id'] as String,
      areaId: json['area_id'] as String,
      name: json['name'] as String,
      logoAsset: _logoAsset(json['logo']),
      kind: json['kind'] as String?,
      memberCount: count,
    );
  }
}

class TeamMember {
  const TeamMember({
    required this.role,
    required this.name,
    this.phone,
    this.email,
    this.club,
  });

  final String role;
  final String name;
  final String? phone;
  final String? email;
  final String? club;

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      role: json['role'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      club: json['club'] as String?,
    );
  }
}

class ClubDetail {
  const ClubDetail({
    required this.id,
    required this.areaId,
    required this.name,
    this.presidentName,
    this.presidentPhone,
    this.presidentEmail,
    this.address,
    this.latitude,
    this.longitude,
    this.meetingSchedule,
    this.logoAsset,
    this.kind,
    this.members = const [],
  });

  final String id;
  final String areaId;
  final String name;
  final String? presidentName;
  final String? presidentPhone;
  final String? presidentEmail;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? meetingSchedule;
  final String? logoAsset;
  final String? kind;
  final List<TeamMember> members;

  bool get isDistrictTeam => kind == 'district_team' || members.isNotEmpty;

  bool get hasLocation =>
      (address != null && address!.trim().isNotEmpty) ||
      (latitude != null && longitude != null);

  bool get hasMeeting =>
      meetingSchedule != null && meetingSchedule!.trim().isNotEmpty;

  factory ClubDetail.fromJson(Map<String, dynamic> json) {
    final rawMembers = json['members'];
    final members = rawMembers is List
        ? rawMembers
              .map((e) => TeamMember.fromJson(e as Map<String, dynamic>))
              .toList()
        : const <TeamMember>[];
    return ClubDetail(
      id: json['id'] as String,
      areaId: json['area_id'] as String,
      name: json['name'] as String,
      presidentName: json['president_name'] as String?,
      presidentPhone: json['president_phone'] as String?,
      presidentEmail: json['president_email'] as String?,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      meetingSchedule: json['meeting_schedule'] as String?,
      logoAsset: _logoAsset(json['logo']),
      kind: json['kind'] as String?,
      members: members,
    );
  }
}
