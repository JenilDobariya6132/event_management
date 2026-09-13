// lib/providers/guest_provider.dart

import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../models/guest_model.dart';
import '../services/api_service.dart';

class GuestProvider with ChangeNotifier {
  List<GuestModel> _guests = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = false;

  List<GuestModel> get guests => _guests;
  Map<String, dynamic> get stats => _stats;
  bool get isLoading => _isLoading;

  int get totalHeadcount => _stats['total_headcount'] != null ? int.parse(_stats['total_headcount'].toString()) : 0;
  int get attendingHeadcount => _stats['attending_headcount'] != null ? int.parse(_stats['attending_headcount'].toString()) : 0;
  int get vegCount => _stats['veg_count'] != null ? int.parse(_stats['veg_count'].toString()) : 0;
  int get accommodationCount => _stats['accommodation_count'] != null ? int.parse(_stats['accommodation_count'].toString()) : 0;

  Future<void> fetchGuests({String? search, String? side, String? rsvpStatus}) async {
    _isLoading = true;
    notifyListeners();

    String url = ApiConfig.guests;
    List<String> params = [];
    if (search != null && search.isNotEmpty) params.add('search=$search');
    if (side != null && side.isNotEmpty && side != 'All') params.add('side=${side.toLowerCase()}');
    if (rsvpStatus != null && rsvpStatus.isNotEmpty && rsvpStatus != 'All') params.add('rsvp_status=${rsvpStatus.toLowerCase()}');

    if (params.isNotEmpty) {
      url += '?${params.join('&')}';
    }

    final res = await ApiService.get(url);
    if (res['success'] == true && res['data'] != null) {
      final data = res['data'];
      if (data['stats'] != null) {
        _stats = data['stats'];
      }
      if (data['guests'] != null) {
        _guests = (data['guests'] as List).map((g) => GuestModel.fromJson(g)).toList();
      }
    } else if (_guests.isEmpty) {
      _guests = [
        GuestModel(id: 1, weddingId: 1, guestName: 'Ramesh Sharma & Family', phone: '+91 98200 11223', familyTag: 'Sharma Family', side: 'groom', memberCount: 4, invitationStatus: 'sent', rsvpStatus: 'attending', foodPreference: 'veg', accommodationNeeded: true),
        GuestModel(id: 2, weddingId: 1, guestName: 'Sunita Verma', phone: '+91 98200 44556', familyTag: 'Verma Family', side: 'bride', memberCount: 2, invitationStatus: 'sent', rsvpStatus: 'attending', foodPreference: 'veg', accommodationNeeded: false),
        GuestModel(id: 3, weddingId: 1, guestName: 'Kapoor Relatives', phone: '+91 98200 77889', familyTag: 'Kapoor Family', side: 'bride', memberCount: 5, invitationStatus: 'sent', rsvpStatus: 'pending', foodPreference: 'non_veg', accommodationNeeded: true),
        GuestModel(id: 4, weddingId: 1, guestName: 'Mehta Uncle & Aunty', phone: '+91 98200 99000', familyTag: 'Mehta Family', side: 'groom', memberCount: 2, invitationStatus: 'sent', rsvpStatus: 'declined', foodPreference: 'veg', accommodationNeeded: false),
      ];
      _recalculateStats();
    }

    _isLoading = false;
    notifyListeners();
  }

  void _recalculateStats() {
    final headcount = _guests.fold(0, (sum, g) => sum + g.memberCount);
    final attending = _guests.where((g) => g.rsvpStatus == 'attending').fold(0, (sum, g) => sum + g.memberCount);
    final veg = _guests.where((g) => g.foodPreference == 'veg').fold(0, (sum, g) => sum + g.memberCount);
    final accom = _guests.where((g) => g.accommodationNeeded).fold(0, (sum, g) => sum + g.memberCount);

    _stats = {
      'total_headcount': headcount,
      'attending_headcount': attending,
      'veg_count': veg,
      'accommodation_count': accom,
    };
  }

  Future<bool> saveGuest({
    int id = 0,
    required String guestName,
    String? phone,
    required String familyTag,
    required String side,
    required int memberCount,
    required String invitationStatus,
    required String rsvpStatus,
    required String foodPreference,
    required bool accommodationNeeded,
  }) async {
    _isLoading = true;
    notifyListeners();

    final res = await ApiService.post(ApiConfig.guests, {
      'id': id,
      'guest_name': guestName,
      'phone': phone,
      'family_tag': familyTag,
      'side': side,
      'member_count': memberCount,
      'invitation_status': invitationStatus,
      'rsvp_status': rsvpStatus,
      'food_preference': foodPreference,
      'accommodation_needed': accommodationNeeded ? 1 : 0,
    });

    _isLoading = false;
    if (res['success'] == true) {
      await fetchGuests();
      return true;
    }

    if (id > 0) {
      final idx = _guests.indexWhere((g) => g.id == id);
      if (idx >= 0) {
        _guests[idx] = GuestModel(
          id: id,
          weddingId: 1,
          guestName: guestName,
          phone: phone,
          familyTag: familyTag,
          side: side,
          memberCount: memberCount,
          invitationStatus: invitationStatus,
          rsvpStatus: rsvpStatus,
          foodPreference: foodPreference,
          accommodationNeeded: accommodationNeeded,
        );
      }
    } else {
      _guests.add(GuestModel(
        id: _guests.length + 1,
        weddingId: 1,
        guestName: guestName,
        phone: phone,
        familyTag: familyTag,
        side: side,
        memberCount: memberCount,
        invitationStatus: invitationStatus,
        rsvpStatus: rsvpStatus,
        foodPreference: foodPreference,
        accommodationNeeded: accommodationNeeded,
      ));
    }

    _recalculateStats();
    notifyListeners();
    return true;
  }

  Future<bool> deleteGuest(int id) async {
    final res = await ApiService.delete("${ApiConfig.guests}?id=$id");
    if (res['success'] == true) {
      await fetchGuests();
      return true;
    }

    _guests.removeWhere((g) => g.id == id);
    _recalculateStats();
    notifyListeners();
    return true;
  }
}
