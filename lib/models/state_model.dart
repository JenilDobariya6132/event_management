// lib/models/state_model.dart

class StateModel {
  final String stateName;
  final String displayName;
  final String subtitle;
  final String imageUrl;
  final int destinationCount;
  final int totalResorts;
  final List<String> topCities;

  StateModel({
    required this.stateName,
    required this.displayName,
    required this.subtitle,
    required this.imageUrl,
    required this.destinationCount,
    required this.totalResorts,
    required this.topCities,
  });

  static List<StateModel> defaultStates = [
    StateModel(
      stateName: 'Gujarat',
      displayName: 'Gujarat Destinations',
      subtitle: 'Kevadia • Kutch • Vadodara • Gir • Surat • Dwarka • Diu',
      imageUrl: 'https://images.unsplash.com/photo-1599661046827-dacff0c0f09a?w=800',
      destinationCount: 7,
      totalResorts: 150,
      topCities: ['Kevadia', 'Kutch', 'Vadodara', 'Sasan Gir', 'Surat', 'Dwarka', 'Diu'],
    ),
    StateModel(
      stateName: 'Rajasthan',
      displayName: 'Rajasthan Destinations',
      subtitle: 'Udaipur • Jaipur • Jodhpur • Jaisalmer Royal Palaces',
      imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800',
      destinationCount: 8,
      totalResorts: 200,
      topCities: ['Udaipur', 'Jaipur', 'Jodhpur', 'Jaisalmer'],
    ),
    StateModel(
      stateName: 'Goa',
      displayName: 'Goa Beachfronts',
      subtitle: 'Sunset Beaches • Ocean Altar Mandaps • Island Resorts',
      imageUrl: 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=800',
      destinationCount: 5,
      totalResorts: 120,
      topCities: ['Goa Beachfront', 'Bambolim', 'South Goa'],
    ),
    StateModel(
      stateName: 'Kerala',
      displayName: 'Kerala Backwaters',
      subtitle: 'Alleppey Houseboats • Kovalam Beach Palms • Green Hills',
      imageUrl: 'https://images.unsplash.com/photo-1602216056096-3b40cc0c9944?w=800',
      destinationCount: 4,
      totalResorts: 90,
      topCities: ['Alleppey', 'Kovalam', 'Munnar'],
    ),
    StateModel(
      stateName: 'Uttarakhand',
      displayName: 'Uttarakhand Himalayan',
      subtitle: 'Mussoorie Misty Valleys • Rishikesh Holy Ganges Retreats',
      imageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=800',
      destinationCount: 4,
      totalResorts: 85,
      topCities: ['Mussoorie', 'Rishikesh', 'Nainital'],
    ),
    StateModel(
      stateName: 'Himachal',
      displayName: 'Himachal Pradesh Peaks',
      subtitle: 'Shimla Pine Valleys • Manali Snow Peak Resorts',
      imageUrl: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800',
      destinationCount: 3,
      totalResorts: 70,
      topCities: ['Shimla', 'Manali'],
    ),
    StateModel(
      stateName: 'Andaman',
      displayName: 'Andaman Islands',
      subtitle: 'Havelock Turquoise Waters • Coral Beach Paradise',
      imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
      destinationCount: 3,
      totalResorts: 45,
      topCities: ['Havelock Island', 'Port Blair'],
    ),
  ];
}
