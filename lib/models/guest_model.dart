// lib/models/guest_model.dart

class GuestModel {
  final int id;
  final int weddingId;
  final String guestName;
  final String? phone;
  final String familyTag;
  final String side; // bride, groom
  final int memberCount;
  final String invitationStatus; // invited, not_invited
  final String rsvpStatus;       // attending, declined, pending
  final String foodPreference;   // veg, non_veg, jain
  final bool accommodationNeeded;

  GuestModel({
    required this.id,
    required this.weddingId,
    required this.guestName,
    this.phone,
    required this.familyTag,
    required this.side,
    required this.memberCount,
    required this.invitationStatus,
    required this.rsvpStatus,
    required this.foodPreference,
    required this.accommodationNeeded,
  });

  factory GuestModel.fromJson(Map<String, dynamic> json) {
    return GuestModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      weddingId: json['wedding_id'] is int ? json['wedding_id'] : int.parse(json['wedding_id'].toString()),
      guestName: json['guest_name'] ?? '',
      phone: json['phone'],
      familyTag: json['family_tag'] ?? 'Family',
      side: json['side'] ?? 'bride',
      memberCount: json['member_count'] != null ? int.parse(json['member_count'].toString()) : 1,
      invitationStatus: json['invitation_status'] ?? 'invited',
      rsvpStatus: json['rsvp_status'] ?? 'pending',
      foodPreference: json['food_preference'] ?? 'veg',
      accommodationNeeded: json['accommodation_needed'].toString() == '1' || json['accommodation_needed'] == true,
    );
  }
}
