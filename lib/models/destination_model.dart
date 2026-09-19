import 'package:flutter/material.dart';

class EventSpace {
  final String name;
  final String description;
  final String capacity;
  final IconData icon;

  EventSpace({
    required this.name,
    required this.description,
    required this.capacity,
    required this.icon,
  });

  factory EventSpace.fromJson(Map<String, dynamic> json) {
    return EventSpace(
      name: json['name'] ?? json['title'] ?? '',
      description: json['description'] ?? json['desc'] ?? '',
      capacity: json['capacity'] ?? '200 - 500 Guests',
      icon: _parseIcon(json['icon'] ?? json['icon_name']),
    );
  }

  static IconData _parseIcon(dynamic iconVal) {
    if (iconVal is IconData) return iconVal;
    final str = iconVal?.toString().toLowerCase() ?? '';
    if (str.contains('pool') || str.contains('swimming')) return Icons.pool;
    if (str.contains('deck') || str.contains('patio')) return Icons.deck;
    if (str.contains('castle') || str.contains('fort') || str.contains('palace')) return Icons.castle;
    if (str.contains('park') || str.contains('lawn') || str.contains('garden')) return Icons.park;
    if (str.contains('beach') || str.contains('sea') || str.contains('ocean')) return Icons.beach_access;
    if (str.contains('mountain') || str.contains('landscape') || str.contains('hill')) return Icons.landscape;
    if (str.contains('water') || str.contains('river') || str.contains('lake')) return Icons.water;
    return Icons.meeting_room;
  }
}

class DestinationPackage {
  final int id;
  final String packageName;
  final double price;
  final String duration;
  final List<String> inclusions;
  final String? imageUrl;

  DestinationPackage({
    required this.id,
    required this.packageName,
    required this.price,
    required this.duration,
    required this.inclusions,
    this.imageUrl,
  });

  factory DestinationPackage.fromJson(Map<String, dynamic> json) {
    return DestinationPackage(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      packageName: json['package_name'] ?? '',
      price: (json['price'] != null) ? double.parse(json['price'].toString()) : 0.0,
      duration: json['duration'] ?? '3 Days / 2 Nights',
      inclusions: json['inclusions'] != null ? List<String>.from(json['inclusions']) : [],
      imageUrl: json['image_url'],
    );
  }
}

class DestinationVenue {
  final int id;
  final String name;
  final String category; // '5-Star Resort', 'Royal Palace Venue', 'Heritage Hotel'
  final String location;
  final double rating;
  final int totalReviews;
  final double startingPrice;
  final String imageUrl;
  final List<String>? galleryImages;
  final String description;
  final List<String> amenities;
  final List<EventSpace>? eventSpaces;
  final String? timings;

  DestinationVenue({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.rating,
    required this.totalReviews,
    required this.startingPrice,
    required this.imageUrl,
    this.galleryImages,
    required this.description,
    required this.amenities,
    this.eventSpaces,
    this.timings,
  });

  factory DestinationVenue.fromJson(Map<String, dynamic> json) {
    return DestinationVenue(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      category: json['category'] ?? 'Resort',
      location: json['location'] ?? '',
      rating: (json['rating'] != null) ? double.parse(json['rating'].toString()) : 4.8,
      totalReviews: json['total_reviews'] != null ? int.parse(json['total_reviews'].toString()) : 25,
      startingPrice: (json['starting_price'] != null) ? double.parse(json['starting_price'].toString()) : 50000.0,
      imageUrl: json['image_url'] ?? '',
      galleryImages: json['gallery_images'] != null ? List<String>.from(json['gallery_images']) : null,
      description: json['description'] ?? '',
      amenities: json['amenities'] != null ? List<String>.from(json['amenities']) : [],
      eventSpaces: json['event_spaces'] != null && json['event_spaces'] is List
          ? (json['event_spaces'] as List).map((e) => EventSpace.fromJson(e)).toList()
          : null,
      timings: json['timings'],
    );
  }

  String getOperatingHours() {
    if (timings != null && timings!.isNotEmpty) return timings!;
    final nameLower = name.toLowerCase();
    if (nameLower.contains('laxmi vilas') || nameLower.contains('palace')) {
      return 'Palace Sightseeing Tour: 9:30 AM - 5:00 PM (Closed Mondays)\nWedding Event Slots: Day (9:00 AM - 3:00 PM) | Evening (6:00 PM - 1:00 AM)';
    } else if (nameLower.contains('statue of unity') || nameLower.contains('kevadia')) {
      return 'Statue Monument Hours: 8:00 AM - 6:00 PM (Closed Mondays)\nResort Check-in: 12:00 PM | Check-out: 10:00 AM';
    } else if (nameLower.contains('rann') || nameLower.contains('kutch')) {
      return 'White Desert Visit: 6:00 AM - 8:00 PM (Full Moon Recommended)\nLuxury Tent Check-in: 12:30 PM | Check-out: 9:30 AM';
    }
    return 'Resort Check-in: 2:00 PM | Check-out: 11:00 AM\nEvent Banquets: Available 24 Hours on Prior Booking';
  }

  List<String> getGalleryImages() {
    if (galleryImages != null && galleryImages!.isNotEmpty) {
      return galleryImages!;
    }
    return [
      imageUrl,
      'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=1000',
      'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1000',
      'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=1000',
      'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=1000',
    ];
  }

  List<EventSpace> getEventSpaces() {
    if (eventSpaces != null && eventSpaces!.isNotEmpty) {
      return eventSpaces!;
    }

    final String nameLower = name.toLowerCase();
    final String categoryLower = category.toLowerCase();
    final String locationLower = location.toLowerCase();

    // Deterministic hash based on venue.id and venue.name length to create varied capacities and space names
    final int hash = (id * 31 + name.length * 17) % 997;

    // Clean up short name for building natural titles (e.g. "Taj Lake", "Umaid Bhawan", "Narmada Tent")
    final String venueShortName = name
        .replaceAll(RegExp(r'^(The|A)\s+', caseSensitive: false), '')
        .split(' ')
        .take(2)
        .join(' ');

    List<EventSpace> list = [];

    // 1. Royal Palace / Fort / Heritage Venue
    if (categoryLower.contains('palace') ||
        categoryLower.contains('fort') ||
        categoryLower.contains('heritage') ||
        nameLower.contains('palace') ||
        nameLower.contains('fort') ||
        nameLower.contains('haveli') ||
        nameLower.contains('garh') ||
        nameLower.contains('mahal')) {
      final cap1Min = 500 + (hash % 6) * 50;
      final cap1Max = cap1Min + 450 + (hash % 5) * 100;
      final cap2Min = 300 + (hash % 4) * 50;
      final cap2Max = cap2Min + 250 + (hash % 4) * 80;
      final cap3Min = 200 + (hash % 3) * 50;
      final cap3Max = cap3Min + 200 + (hash % 3) * 50;
      final cap4Min = 150 + (hash % 3) * 30;
      final cap4Max = cap4Min + 120 + (hash % 4) * 40;

      list = [
        EventSpace(
          name: "$venueShortName Royal Mandap Lawn",
          description: "Outdoor Marwari Floral Mandap, Elephant Welcome & Baraat Stage",
          capacity: "$cap1Min - $cap1Max Guests",
          icon: Icons.castle,
        ),
        EventSpace(
          name: "Grand Imperial Chandelier Ballroom",
          description: "Indoor Air-Conditioned Royal Heritage Banquet",
          capacity: "$cap2Min - $cap2Max Guests",
          icon: Icons.meeting_room,
        ),
        EventSpace(
          name: "Rooftop Fort Rampart Terrace",
          description: "Sunset Cocktail Lounge, Folk Dance & Sangeet Stage",
          capacity: "$cap3Min - $cap3Max Guests",
          icon: Icons.deck,
        ),
        EventSpace(
          name: "Lotus Palace Courtyard",
          description: "Traditional Haldi, Mehendi & Intimate Pre-wedding Rituals",
          capacity: "$cap4Min - $cap4Max Guests",
          icon: Icons.pool,
        ),
      ];
    }
    // 2. Beach / Coastal / Ocean Resort
    else if (categoryLower.contains('beach') ||
        categoryLower.contains('ocean') ||
        categoryLower.contains('coastal') ||
        nameLower.contains('beach') ||
        nameLower.contains('ocean') ||
        nameLower.contains('sea') ||
        nameLower.contains('bay') ||
        nameLower.contains('cove') ||
        nameLower.contains('lagoon') ||
        locationLower.contains('goa') ||
        locationLower.contains('kovalam') ||
        locationLower.contains('kerala') ||
        locationLower.contains('andaman') ||
        locationLower.contains('pondicherry')) {
      final cap1Min = 400 + (hash % 5) * 50;
      final cap1Max = cap1Min + 400 + (hash % 6) * 90;
      final cap2Min = 250 + (hash % 4) * 50;
      final cap2Max = cap2Min + 250 + (hash % 4) * 80;
      final cap3Min = 180 + (hash % 3) * 40;
      final cap3Max = cap3Min + 200 + (hash % 4) * 50;
      final cap4Min = 100 + (hash % 4) * 25;
      final cap4Max = cap4Min + 140 + (hash % 3) * 35;

      list = [
        EventSpace(
          name: "$venueShortName Sunset Ocean Lawn",
          description: "Beachside Sand Mandap & Sunset Vows Exchange",
          capacity: "$cap1Min - $cap1Max Guests",
          icon: Icons.beach_access,
        ),
        EventSpace(
          name: "Grand Coastal Palms Ballroom",
          description: "Indoor AC Sea-view Banquet & Reception Hall",
          capacity: "$cap2Min - $cap2Max Guests",
          icon: Icons.meeting_room,
        ),
        EventSpace(
          name: "Poolside Sundowner Deck",
          description: "Tropical Cocktail, DJ Sangeet & Beach Sundowner",
          capacity: "$cap3Min - $cap3Max Guests",
          icon: Icons.pool,
        ),
        EventSpace(
          name: "Private Lagoon Garden Cove",
          description: "Haldi & Mehendi Sundowner Rituals by the Water",
          capacity: "$cap4Min - $cap4Max Guests",
          icon: Icons.water,
        ),
      ];
    }
    // 3. Hill Station / Mountain / Valley Resort
    else if (categoryLower.contains('hill') ||
        categoryLower.contains('mountain') ||
        categoryLower.contains('valley') ||
        categoryLower.contains('eco') ||
        nameLower.contains('hill') ||
        nameLower.contains('ridge') ||
        nameLower.contains('valley') ||
        nameLower.contains('pine') ||
        nameLower.contains('alpine') ||
        locationLower.contains('shimla') ||
        locationLower.contains('manali') ||
        locationLower.contains('mussoorie') ||
        locationLower.contains('nainital') ||
        locationLower.contains('coorg') ||
        locationLower.contains('munnar')) {
      final cap1Min = 300 + (hash % 4) * 50;
      final cap1Max = cap1Min + 300 + (hash % 5) * 80;
      final cap2Min = 200 + (hash % 4) * 40;
      final cap2Max = cap2Min + 220 + (hash % 4) * 70;
      final cap3Min = 120 + (hash % 3) * 30;
      final cap3Max = cap3Min + 160 + (hash % 3) * 40;

      list = [
        EventSpace(
          name: "$venueShortName Panoramic Ridge Meadow",
          description: "Open Mountain Peak Mandap & Valley View Ceremony",
          capacity: "$cap1Min - $cap1Max Guests",
          icon: Icons.landscape,
        ),
        EventSpace(
          name: "Pine Wood Glasshouse Pavilion",
          description: "Heated Indoor Glasshouse Banquet & Stage",
          capacity: "$cap2Min - $cap2Max Guests",
          icon: Icons.domain,
        ),
        EventSpace(
          name: "Sunset Bonfire Deck",
          description: "Acoustic Sangeet Night, High Tea & Bonfire Gala",
          capacity: "$cap3Min - $cap3Max Guests",
          icon: Icons.deck,
        ),
      ];
    }
    // 4. Desert / Tent City / Kutch / Jaisalmer Resort
    else if (categoryLower.contains('tent') ||
        categoryLower.contains('desert') ||
        nameLower.contains('tent') ||
        nameLower.contains('rann') ||
        nameLower.contains('desert') ||
        nameLower.contains('dunes') ||
        locationLower.contains('kutch') ||
        locationLower.contains('jaisalmer') ||
        locationLower.contains('kevadia') ||
        locationLower.contains('bikaner')) {
      final cap1Min = 450 + (hash % 5) * 50;
      final cap1Max = cap1Min + 400 + (hash % 6) * 90;
      final cap2Min = 280 + (hash % 4) * 40;
      final cap2Max = cap2Min + 270 + (hash % 4) * 70;
      final cap3Min = 160 + (hash % 3) * 30;
      final cap3Max = cap3Min + 190 + (hash % 4) * 40;

      list = [
        EventSpace(
          name: "$venueShortName Moonlit Desert Arena",
          description: "Open Sky Desert Mandap with Camel Carriage Entrance",
          capacity: "$cap1Min - $cap1Max Guests",
          icon: Icons.park,
        ),
        EventSpace(
          name: "Royal Marwari Tent Pavilion",
          description: "Luxury Tented Air-Conditioned Banquet & Dining Hall",
          capacity: "$cap2Min - $cap2Max Guests",
          icon: Icons.meeting_room,
        ),
        EventSpace(
          name: "Dune View Folk Sangeet Stage",
          description: "Cultural Folk Dance, Garba Night & Firework Gala",
          capacity: "$cap3Min - $cap3Max Guests",
          icon: Icons.deck,
        ),
      ];
    }
    // 5. General Luxury Hotel / Banquet / Resort
    else {
      final cap1Min = 400 + (hash % 6) * 50;
      final cap1Max = cap1Min + 450 + (hash % 5) * 90;
      final cap2Min = 250 + (hash % 4) * 50;
      final cap2Max = cap2Min + 270 + (hash % 4) * 80;
      final cap3Min = 150 + (hash % 3) * 30;
      final cap3Max = cap3Min + 180 + (hash % 4) * 50;

      list = [
        EventSpace(
          name: "$venueShortName Grand Emerald Lawn",
          description: "Sprawling Floral Mandap & Open Sky Wedding Reception",
          capacity: "$cap1Min - $cap1Max Guests",
          icon: Icons.deck,
        ),
        EventSpace(
          name: "Pillarless Crystal Ballroom",
          description: "Indoor Air-Conditioned Luxury Banquet & HD Stage",
          capacity: "$cap2Min - $cap2Max Guests",
          icon: Icons.meeting_room,
        ),
        EventSpace(
          name: "Poolside Sangeet & Cocktail Terrace",
          description: "Sunset Cocktail Party, DJ Sangeet & Sundowner",
          capacity: "$cap3Min - $cap3Max Guests",
          icon: Icons.pool,
        ),
      ];
    }

    return list;
  }
}

class DestinationModel {
  final int id;
  final String title;
  final String location;
  final String? imageUrl;
  final String? description;
  final double startingPrice;
  final bool isPopular;
  final List<DestinationPackage> packages;
  final List<DestinationVenue>? customVenues;

  DestinationModel({
    required this.id,
    required this.title,
    required this.location,
    this.imageUrl,
    this.description,
    required this.startingPrice,
    required this.isPopular,
    required this.packages,
    this.customVenues,
  });

  factory DestinationModel.fromJson(Map<String, dynamic> json) {
    List<DestinationPackage> pkgs = [];
    if (json['packages'] != null && json['packages'] is List) {
      pkgs = (json['packages'] as List).map((p) => DestinationPackage.fromJson(p)).toList();
    }

    return DestinationModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      imageUrl: json['image_url'],
      description: json['description'],
      startingPrice: (json['starting_price'] != null) ? double.parse(json['starting_price'].toString()) : 0.0,
      isPopular: json['is_popular'].toString() == '1' || json['is_popular'] == true,
      packages: pkgs,
    );
  }

  /// Returns tailored resorts, venues, and luxury hotels for this destination (22+ items per destination)
  List<DestinationVenue> getVenuesAndResorts() {
    if (customVenues != null && customVenues!.length >= 20) {
      return customVenues!;
    }

    final baseVenues = _getSpecificVenues();
    final List<DestinationVenue> fullList = List.from(baseVenues);

    final String cityName = location.split(',').first.trim();
    final String stateName = location.contains(',') ? location.split(',').last.trim() : location;

    final categories = [
      '5-Star Luxury Resort',
      'Royal Palace Venue',
      'Heritage Hotel & Banquets',
      'Oceanfront Beach Resort',
      'Riverfront Eco Lodge',
      'Grand Ballrooms & Lawns',
      'Hilltop Valley Resort',
      'Boutique Heritage Villa',
      'Luxury Tent City Resort',
      'Lakeview Palace Hotel',
      'Fort Heritage Resort',
    ];

    final venuePrefixes = [
      'The Grand', 'Royal', 'Imperial', 'Taj', 'Leela', 'Oberoi', 'JW', 'Welcomhotel by ITC',
      'Fern', 'Fortune Park', 'Radisson Blu', 'Courtyard by Marriott', 'Hyatt Regency',
      'Novotel', 'Sayaji', 'Club Mahindra', 'Sterling', 'Vivanta', 'Lemon Tree Premier',
      'Ananta', 'Heritage Haveli', 'Sun & Sand'
    ];

    final venueSuffixes = [
      'Resort & Spa', 'Palace Lawns', 'Grand Hotel', 'Eco Lodge', 'Heritage Banquets',
      'Beach Resort', 'Valley Retreat', 'Riverside Resort', 'Palace Pavilion',
      'Luxury Suites', 'Lakeside Lawn', 'Fort Resort & Spa'
    ];

    final images = [
      'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
      'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800',
      'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=800',
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
      'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=800',
      'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?w=800',
      'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=800',
      'https://images.unsplash.com/photo-1477587458883-47145ed94245?w=800',
      'https://images.unsplash.com/photo-1602216056096-3b40cc0c9944?w=800',
      'https://images.unsplash.com/photo-1599661046827-dacff0c0f09a?w=800',
      'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?w=800',
      'https://images.unsplash.com/photo-1510414842594-a61c69b5ae57?w=800',
      'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=800',
      'https://images.unsplash.com/photo-1595815771614-ade9d652a65d?w=800',
      'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=800',
      'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=800',
      'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=800',
    ];

    final amenityPresets = [
      ['Royal Mandap Lawn', 'Poolside Deck', 'Valet Parking', 'Bridal Suite', 'Multicuisine Catering'],
      ['5-Star Suites', 'Helipad', 'Glass Banquet Hall', 'Fireworks Permit', 'Luxury Spa'],
      ['Riverfront Terrace', 'Infinity Pool', '24/7 Butler Service', 'Sangeet Stage', 'Live Music'],
      ['Heritage Courtyard', 'Elephant Entry Route', 'Marwari Catering', 'Illuminated Mandap'],
      ['Private Beach Access', 'Sunset Cocktail Lounge', 'Seafood Grill', 'Acoustic Stage'],
      ['Pine Valley View', 'Bonfire & BBQ Deck', 'Mountain Chalets', 'Heated Swimming Pool'],
    ];

    const int targetCount = 22;
    int index = fullList.length;

    while (fullList.length < targetCount) {
      final prefix = venuePrefixes[index % venuePrefixes.length];
      final suffix = venueSuffixes[index % venueSuffixes.length];
      final category = categories[index % categories.length];
      final imgUrl = images[index % images.length];
      final amenities = amenityPresets[index % amenityPresets.length];

      final String venueName = "$prefix $cityName $suffix";
      final double price = 25000.0 + ((index * 7500) % 95000);
      final double rating = 4.6 + ((index * 3) % 5) / 10.0;
      final int reviews = 35 + (index * 13) % 180;

      fullList.add(
        DestinationVenue(
          id: id * 1000 + index + 1,
          name: venueName,
          category: category,
          location: "$cityName, $stateName",
          rating: rating > 5.0 ? 4.9 : double.parse(rating.toStringAsFixed(1)),
          totalReviews: reviews,
          startingPrice: price,
          imageUrl: imgUrl,
          description: "Premier $category in $cityName providing magnificent floral mandaps, luxury guest rooms, and royal dining for grand destination weddings.",
          amenities: amenities,
        ),
      );
      index++;
    }

    return fullList;
  }

  List<DestinationVenue> _getSpecificVenues() {
    final locLower = location.toLowerCase();
    final titleLower = title.toLowerCase();

    if (locLower.contains('kevadia') || titleLower.contains('statue of unity')) {
      return [
        DestinationVenue(
          id: 901,
          name: 'Statue of Unity Tent City - 1',
          category: '5-Star Luxury Tent Resort',
          location: 'Tent City 1, Dyke 4, Sardar Sarovar Dam site, Kevadia, Gujarat',
          rating: 4.9,
          totalReviews: 124,
          startingPrice: 50000.0,
          imageUrl: 'https://images.unsplash.com/photo-1599661046827-dacff0c0f09a?w=800',
          description: 'Sprawling luxury tented resort right next to Narmada river with royal dining halls, swimming pool, and grand mandap lawn for 500+ guests.',
          amenities: ['Riverfront Lawns', 'Luxury AC Tents', 'Helipad', 'Multicuisine Catering', 'Free Wifi'],
        ),
        DestinationVenue(
          id: 902,
          name: 'Narmada Tent City 2',
          category: 'Eco Resort & Banquets',
          location: 'Tent City Narmada, Dyke 3, Kevadia, Gujarat',
          rating: 4.8,
          totalReviews: 98,
          startingPrice: 42000.0,
          imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
          description: 'Eco-luxury villa resort surrounded by Vindhyachal mountains featuring sunset cocktail terrace and open amphitheater.',
          amenities: ['Sunset Terrace', 'Glass Banquet', 'Poolside Lounge', 'Garden Lawns'],
        ),
        DestinationVenue(
          id: 903,
          name: 'Unity Village Resort By Aalpine',
          category: 'Eco Luxury Resort & Cottages',
          location: 'Near Bhilvasi, Bhandara Gora Road, Kevadia, Gujarat',
          rating: 4.9,
          totalReviews: 86,
          startingPrice: 40000.0,
          imageUrl: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=800',
          description: 'Beautifully designed luxury cottages surrounded by nature and mountain views. Ideal for serene pre-wedding & wedding events.',
          amenities: ['Mountain View Cottages', 'Nature Lawns', 'Swimming Pool', 'Bonfire Area'],
        ),
        DestinationVenue(
          id: 904,
          name: 'Villa Euphoria Resort',
          category: 'Luxury Villa & Resort',
          location: '9 KM from Statue of Unity Parking, NH 56, Kevadia, Gujarat',
          rating: 4.8,
          totalReviews: 74,
          startingPrice: 46000.0,
          imageUrl: 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800',
          description: 'Tranquil luxury resort beside the majesty of the Statue of Unity with private villas, swimming pool, and grand banquet hall.',
          amenities: ['Private Villas', 'Grand Banquet', 'Infinity Pool', 'Valet Parking'],
        ),
        DestinationVenue(
          id: 905,
          name: 'Soil to Soul Resort',
          category: 'Wellness & Nature Resort',
          location: 'Tilakwada, Statue of Unity Road, Kevadia, Gujarat',
          rating: 4.8,
          totalReviews: 65,
          startingPrice: 48000.0,
          imageUrl: 'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800',
          description: 'A peaceful wellness & luxury resort surrounded by nature, featuring lush organic gardens and serene mandap lawns.',
          amenities: ['Organic Dining', 'Wellness Spa', 'Open Mandap Lawn', 'Eco Tents'],
        ),
        DestinationVenue(
          id: 906,
          name: 'River View Tent Resort',
          category: 'Riverfront Tent Resort',
          location: 'Rajpipla Gora Road, Garudeshwar, Kevadia, Gujarat',
          rating: 4.7,
          totalReviews: 58,
          startingPrice: 45000.0,
          imageUrl: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800',
          description: 'Perfect resort with Narmada river views near Statue of Unity, offering luxury tented villas and riverfront lawns.',
          amenities: ['Narmada Riverfront View', 'Luxury Tents', 'Cultural Deck', 'Bonfire Night'],
        ),
        DestinationVenue(
          id: 907,
          name: 'Vivanta Hotel Ekta Nagar',
          category: '5-Star Luxury Hotel',
          location: 'Ekta Nagar, Kevadia, Gujarat 393151',
          rating: 4.9,
          totalReviews: 112,
          startingPrice: 65000.0,
          imageUrl: 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800',
          description: 'Premium luxury hotel with Narmada river view near Statue of Unity, offering state-of-the-art ballrooms and guest suites.',
          amenities: ['Grand Ballroom', 'Luxury Guest Suites', 'Infinity Pool', 'Fine Dining'],
        ),
        DestinationVenue(
          id: 908,
          name: 'Rama Hills Unity Resort',
          category: 'Hillside Luxury Resort',
          location: 'Kevadiya Rd, Vavdi, Rajpipla, Kevadia, Gujarat',
          rating: 4.7,
          totalReviews: 52,
          startingPrice: 38000.0,
          imageUrl: 'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800',
          description: 'Nestled amidst Vindhyachal hills with breathtaking panoramic views, grand sangeet lawns, and hilltop mandaps.',
          amenities: ['Hilltop Deck', 'Sangeet Lawns', 'Panoramic View Rooms', 'Multicuisine Restaurant'],
        ),
        DestinationVenue(
          id: 909,
          name: 'Luxuriaa Inn Resort',
          category: 'Luxury Boutique Resort',
          location: 'Bypass Road, Ekta Nagar, Kevadiya, Gujarat 393151',
          rating: 4.7,
          totalReviews: 44,
          startingPrice: 40000.0,
          imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
          description: 'Modern luxury resort situated on the Ekta Nagar bypass, featuring contemporary banquet halls and poolside celebration lawns.',
          amenities: ['Poolside Lawn', 'Banquet Hall', 'Modern Suites', '24/7 Room Service'],
        ),
        DestinationVenue(
          id: 910,
          name: 'Hotel Sai Inn',
          category: 'Boutique Hotel & Banquets',
          location: 'Gurudeshwar Bypass Road, Kevadia, Gujarat',
          rating: 4.6,
          totalReviews: 39,
          startingPrice: 32000.0,
          imageUrl: 'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800',
          description: 'Popular venue offering luxury suites, courtyard mandap, and fine dining for intimate destination weddings.',
          amenities: ['Courtyard Lawn', 'AC Banquet', 'Deluxe Rooms', 'Valet Parking'],
        ),
        DestinationVenue(
          id: 911,
          name: 'Hotel Valley',
          category: 'Valley Resort & Banquets',
          location: 'Statue Of Unity Highway 56, Kevadia, Gujarat 391120',
          rating: 4.6,
          totalReviews: 35,
          startingPrice: 28000.0,
          imageUrl: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800',
          description: 'Peaceful valley resort near Statue of Unity with open lawns, comfortable accommodation, and global cuisine catering.',
          amenities: ['Open Valley Lawn', 'Banquet Room', 'Free Parking', 'Restaurant'],
        ),
      ];
    } else if (locLower.contains('kutch') || titleLower.contains('rann of kutch')) {
      return [
        DestinationVenue(
          id: 1001,
          name: 'Rann Utsav - The Tent City',
          category: '5-Star Desert Luxury Tent City',
          location: 'Dhordo, White Rann, Kutch, Gujarat',
          rating: 4.9,
          totalReviews: 185,
          startingPrice: 58000.0,
          imageUrl: 'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?w=800',
          description: 'Premier luxury desert tent city with Darbari & Rajwadi suites, grand garba grounds, full-moon night mandaps, and authentic Kutchi cultural stage.',
          amenities: ['Darbari & Rajwadi Suites', 'Moonlit Desert Arena', 'Kutchi Crafts Bazaar', 'Star Gazing Deck', 'Golf Carts'],
        ),
        DestinationVenue(
          id: 1002,
          name: 'Praveg White Rann Resort',
          category: 'Luxury Heritage Bhungas & Tents',
          location: 'Dhordo, White Rann, Kutch, Gujarat',
          rating: 4.9,
          totalReviews: 142,
          startingPrice: 54000.0,
          imageUrl: 'https://images.unsplash.com/photo-1510414842594-a61c69b5ae57?w=800',
          description: 'Luxury redefined featuring traditional Rajwadi AC Bhungas and Swiss-style tents right at the entrance of the White Rann salt desert.',
          amenities: ['Rajwadi AC Bhungas', 'White Desert View Mandap', 'Cultural Performances', 'Guided Tours'],
        ),
        DestinationVenue(
          id: 1003,
          name: 'White Rann Resort Dhordo',
          category: '5-Star Desert Resort',
          location: 'Dhordo, White Rann, Kutch, Gujarat',
          rating: 4.8,
          totalReviews: 110,
          startingPrice: 50000.0,
          imageUrl: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=800',
          description: 'Premium white desert resort featuring moonlit mandaps, Swiss cottages, Kutchi folk amphitheater, and camel cart entries.',
          amenities: ['Moonlit Desert Mandap', 'Swiss Cottages', 'Cultural Stage', 'Camel Procession'],
        ),
        DestinationVenue(
          id: 1004,
          name: 'Rann Visamo Village Resort',
          category: 'Luxury Heritage Village Retreat',
          location: 'Dhordo, Kutch, Gujarat',
          rating: 4.8,
          totalReviews: 88,
          startingPrice: 44000.0,
          imageUrl: 'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800',
          description: 'Specialized luxury desert retreat offering refined traditional Bhunga stay, sunset terrace, and authentic Kutchi dining banquet.',
          amenities: ['Luxury Bhungas', 'Sunset Terrace', 'Kutchi Thali Restaurant', 'Bonfire Area'],
        ),
        DestinationVenue(
          id: 1005,
          name: 'Rann Kutch Resort',
          category: 'Heritage Eco Resort',
          location: 'Gorewali, Near Dhordo, Kutch, Gujarat',
          rating: 4.7,
          totalReviews: 76,
          startingPrice: 38000.0,
          imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
          description: 'Vibrant desert resort featuring traditional mud cottages, open-air wedding lawns, and cultural sangeet night setups.',
          amenities: ['Mud Bhungas', 'Sangeet Lawn', 'Folk Music Ensemble', 'Free Parking'],
        ),
        DestinationVenue(
          id: 1006,
          name: 'Rann Kandhi Resort',
          category: 'Cultural Desert Resort',
          location: 'Gorewali Village, Kutch, Gujarat',
          rating: 4.7,
          totalReviews: 64,
          startingPrice: 36000.0,
          imageUrl: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800',
          description: 'Serene desert resort noted for authentic Kutchi hospitality, vibrant sangeet decor, and handcrafted Mandap structures.',
          amenities: ['Handcrafted Mandap', 'Kutchi Buffet', 'Cultural Garba Lawn', 'AC Tents'],
        ),
        DestinationVenue(
          id: 1007,
          name: 'Rann Bhumi Villa & Resort',
          category: 'Luxury Desert Villa',
          location: 'Hodka Village, Kutch, Gujarat',
          rating: 4.8,
          totalReviews: 59,
          startingPrice: 42000.0,
          imageUrl: 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800',
          description: 'Exclusive villa stay in Hodka offering modern 5-star comforts merged with Kutchi art, private courtyards, and dune views.',
          amenities: ['Private Villas', 'Poolside Lounge', 'Dune View Deck', 'Valet Parking'],
        ),
        DestinationVenue(
          id: 1008,
          name: 'Rann Chandni Resort',
          category: 'Eco Heritage Resort',
          location: 'Hodka, Kutch, Gujarat',
          rating: 4.6,
          totalReviews: 51,
          startingPrice: 35000.0,
          imageUrl: 'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800',
          description: 'Charming desert resort in Hodka village featuring moonlit courtyard celebrations, traditional craft workshops, and open amphitheater.',
          amenities: ['Moonlit Courtyard', 'Amphitheater', 'Traditional Bhungas', 'Multi-Catering'],
        ),
        DestinationVenue(
          id: 1009,
          name: 'Kutch Classic Rider Camp',
          category: 'Adventure & Desert Camp',
          location: 'Gorewali, Kutch, Gujarat',
          rating: 4.6,
          totalReviews: 43,
          startingPrice: 32000.0,
          imageUrl: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800',
          description: 'Unique desert camping and resort experience offering camel rides, bonfire sangeet, and traditional Kutchi feast.',
          amenities: ['Bonfire Sangeet', 'Luxury Camping Tents', 'Camel Safari', 'Buffet Hall'],
        ),
        DestinationVenue(
          id: 1010,
          name: 'White Desert Eco Homestay',
          category: 'Boutique Eco Resort',
          location: 'Dhordo Gate, Kutch, Gujarat',
          rating: 4.7,
          totalReviews: 38,
          startingPrice: 30000.0,
          imageUrl: 'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800',
          description: 'Intimate boutique resort offering private Kutchi cottages, starlit mandap setups, and organic local cuisine.',
          amenities: ['Private Cottages', 'Starlit Mandap', 'Organic Dining', 'Free Wifi'],
        ),
      ];
    } else if (locLower.contains('gir') || titleLower.contains('gir forest')) {
      return [
        DestinationVenue(
          id: 1101,
          name: 'Woods at Sasan Eco Resort',
          category: '5-Star Eco Wilderness Resort',
          location: 'Sasan Gir Jungle, Gujarat',
          rating: 4.9,
          totalReviews: 78,
          startingPrice: 42000.0,
          imageUrl: 'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?w=800',
          description: 'Luxury eco-conscious jungle resort nestled in mango orchards and teak forests with open-air floral mandaps.',
          amenities: ['Teak Forest Lawns', 'Private Villas', 'Organic Kathiyawadi Kitchen', 'Spa & Wellness'],
        ),
        DestinationVenue(
          id: 1102,
          name: 'Aramness Gir Safari Lodge',
          category: 'Wilderness Luxury Hotel',
          location: 'Gir National Park Border, Gujarat',
          rating: 4.8,
          totalReviews: 54,
          startingPrice: 60000.0,
          imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
          description: 'Ultra-luxury safari lodge crafted with local stone and wood, perfect for boutique wilderness weddings.',
          amenities: ['Plunge Pools', 'Courtyard Mandap', 'Butler Service', 'Wilderness Safari'],
        ),
      ];
    } else if (locLower.contains('dwarka')) {
      return [
        DestinationVenue(
          id: 1201,
          name: 'The Fern Sattva Resort, Dwarka',
          category: '5-Star Luxury Eco Resort',
          location: 'Jamnagar-Dwarka Highway, Dwarka, Gujarat 361335',
          rating: 4.9,
          totalReviews: 145,
          startingPrice: 48000.0,
          imageUrl: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=800',
          description: 'Premier 5-star eco-luxury resort spread across lush green acres near Dwarkadhish Temple, offering grand event lawns, wellness spa, and pure vegetarian feast catering.',
          amenities: ['8-Acre Event Lawns', 'Pure Veg & Jain Dining', 'Wellness Spa', 'Swimming Pool', 'Bridal Suites'],
        ),
        DestinationVenue(
          id: 1202,
          name: 'Hawthorn Suites by Wyndham Dwarka',
          category: '5-Star Oceanfront Resort',
          location: 'Arabian Sea Coast, Dwarka, Gujarat 361335',
          rating: 4.8,
          totalReviews: 120,
          startingPrice: 45000.0,
          imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
          description: 'Sprawling 5-star eco-resort overlooking the Arabian Sea with oceanfront mandap lawns, luxury villas, and Vedic ceremony stages.',
          amenities: ['Arabian Sea Mandap Lawn', 'Luxury Villas', 'Vedic Ceremony Stage', 'Pure Veg Gourmet Kitchen'],
        ),
        DestinationVenue(
          id: 1203,
          name: 'VITS Devbhumi Hotel & Resort',
          category: '4-Star Luxury Resort',
          location: 'Station Road, Near Dwarkadhish Temple, Dwarka 361335',
          rating: 4.7,
          totalReviews: 98,
          startingPrice: 38000.0,
          imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
          description: 'Popular luxury resort featuring traditional Gujarati architecture, wellness spa, ocean view banquets, and shehnai welcome.',
          amenities: ['Temple View Lawn', 'Wellness Spa', 'AC Banquet Hall', 'Valet Parking'],
        ),
        DestinationVenue(
          id: 1204,
          name: 'Lemon Tree Premier, Dwarka',
          category: '4-Star Premium Hotel',
          location: 'Iscon Gate, Dwarka, Gujarat 361335',
          rating: 4.7,
          totalReviews: 88,
          startingPrice: 36000.0,
          imageUrl: 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800',
          description: 'Modern 4-star premium hotel near Dwarkadhish Temple featuring stylish celebration halls, poolside deck, and international vegetarian dining.',
          amenities: ['Celebration Banquet', 'Poolside Deck', 'Pure Veg Kitchen', 'Executive Suites'],
        ),
        DestinationVenue(
          id: 1205,
          name: 'The Grand Ladhukara, Dwarka',
          category: 'Luxury Heritage Hotel',
          location: 'Near Reliance Green, Dwarka, Gujarat 361335',
          rating: 4.8,
          totalReviews: 76,
          startingPrice: 40000.0,
          imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800',
          description: 'Elegant heritage-inspired luxury hotel & banquets with crystal chandelier ballrooms and traditional royal Gujarati welcome.',
          amenities: ['Chandelier Ballroom', 'Heritage Courtyard', 'Royal Thali Dining', 'Free Wifi'],
        ),
        DestinationVenue(
          id: 1206,
          name: 'Dwarkadhish Ocean Beach Resort',
          category: 'Coastal Beach Resort',
          location: 'Temple Beach Road, Dwarka, Gujarat 361335',
          rating: 4.6,
          totalReviews: 65,
          startingPrice: 32000.0,
          imageUrl: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800',
          description: 'Serene beach resort right on the Arabian Sea front featuring sunset mandap lawns, sea breeze decks, and temple blessing stages.',
          amenities: ['Arabian Sea Beach View', 'Sunset Mandap Lawn', '100 Guest Rooms', 'Mandap Catering'],
        ),
        DestinationVenue(
          id: 1207,
          name: 'Goverdhan Greens Eco Resort',
          category: 'Eco Heritage Resort',
          location: 'Baradia, Highway 8, Dwarka, Gujarat 361335',
          rating: 4.6,
          totalReviews: 58,
          startingPrice: 30000.0,
          imageUrl: 'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800',
          description: 'Sprawling eco-resort featuring organic farming, open amphitheater for sangeet nights, and traditional Kutchi & Kathiyawadi dining.',
          amenities: ['Organic Farming Grounds', 'Amphitheater Sangeet Stage', 'Eco Cottages', 'Buffet Hall'],
        ),
        DestinationVenue(
          id: 1208,
          name: 'Encity Hotel & Banquets',
          category: '4-Star Boutique Hotel',
          location: 'Near Shivrajpur Beach Rd, Dwarka 361335',
          rating: 4.6,
          totalReviews: 50,
          startingPrice: 28000.0,
          imageUrl: 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800',
          description: 'Contemporary boutique hotel offering glass-walled banquet halls, bridal suites, and proximity to Blue Flag Shivrajpur Beach.',
          amenities: ['Glass Banquet Hall', 'Bridal Suite', 'Free Parking', 'Restaurant'],
        ),
        DestinationVenue(
          id: 1209,
          name: 'Mercure Dwarka Resort',
          category: '4-Star Coastal Resort',
          location: 'Dwarka Bypass Road, Gujarat 361335',
          rating: 4.7,
          totalReviews: 60,
          startingPrice: 35000.0,
          imageUrl: 'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800',
          description: 'Premium Accor hotel property offering coastal views, luxury guest rooms, and spacious celebratory lawns.',
          amenities: ['Celebration Lawn', 'Pure Veg Dining', 'Luxury Rooms', 'Airport Shuttle'],
        ),
        DestinationVenue(
          id: 1210,
          name: 'Shivrajpur Beach Resort & Camping',
          category: 'Coastal Sunset Beach Resort',
          location: 'Shivrajpur Blue Flag Beach, Dwarka 361335',
          rating: 4.7,
          totalReviews: 54,
          startingPrice: 34000.0,
          imageUrl: 'https://images.unsplash.com/photo-1510414842594-a61c69b5ae57?w=800',
          description: 'Exclusive beach resort & luxury tent setup right at Blue Flag Shivrajpur Beach, perfect for white sand sunset mandap vows.',
          amenities: ['Blue Flag White Sand Beach', 'Sunset Mandap Deck', 'Luxury AC Tents', 'Seaside Barbecue'],
        ),
      ];
    } else if (locLower.contains('vadodara')) {
      return [
        DestinationVenue(
          id: 1301,
          name: 'Laxmi Vilas Palace Lawns & Banquets',
          category: 'Royal Palace Venue',
          location: 'Jawaharlal Nehru Marg, Vadodara, Gujarat 390001',
          rating: 5.0,
          totalReviews: 195,
          startingPrice: 150000.0,
          imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800',
          description: 'Grandest royal palace estate in Gujarat featuring majestic Indo-Saracenic architecture, marble courtyards, and royal elephant procession pathways for up to 3000 guests.',
          amenities: ['Royal Palace Courtyard', 'Maratha Imperial Decor', 'Elephant Procession Route', 'Helipad', 'Bridal Suites'],
        ),
        DestinationVenue(
          id: 1302,
          name: 'Vivanta Vadodara',
          category: '5-Star Luxury Hotel',
          location: 'Akota, Vadodara, Gujarat 390020',
          rating: 4.9,
          totalReviews: 128,
          startingPrice: 65000.0,
          imageUrl: 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800',
          description: 'Iconic 5-star IHCL luxury hotel offering pillarless grand ballrooms, manicured pool lawns, and exquisite fine-dining catering.',
          amenities: ['Grand Ballroom', 'Poolside Celebration Lawn', '120 Luxury Rooms', 'Spa & Salon'],
        ),
        DestinationVenue(
          id: 1303,
          name: 'Courtyard by Marriott Vadodara',
          category: '5-Star Luxury Hotel',
          location: 'Subhanpura, Vadodara, Gujarat 390023',
          rating: 4.8,
          totalReviews: 115,
          startingPrice: 60000.0,
          imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
          description: 'Modern luxury 5-star hotel in Subhanpura featuring elegant chandeliers, contemporary banquet halls, and international culinary team.',
          amenities: ['Marriott Banquet Hall', 'Rooftop Lounge', 'Bridal Suite', 'Valet Parking'],
        ),
        DestinationVenue(
          id: 1304,
          name: 'Welcomhotel by ITC Hotels, Alkapuri',
          category: '5-Star Heritage Luxury Hotel',
          location: 'Alkapuri, Vadodara, Gujarat 390007',
          rating: 4.9,
          totalReviews: 104,
          startingPrice: 58000.0,
          imageUrl: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=800',
          description: 'Prestigious 5-star hotel by ITC offering royal Gujarati hospitality, grand celebratory halls, and signature royal feast dining.',
          amenities: ['ITC Imperial Banquet', 'Royal Gujarati Feast', 'Poolside Lounge', 'Luxury Suites'],
        ),
        DestinationVenue(
          id: 1305,
          name: 'Hyatt Place Vadodara',
          category: '5-Star Luxury Hotel',
          location: 'Vasna-Bhayli Main Rd, Nilamber Palma, Vadodara 391410',
          rating: 4.8,
          totalReviews: 92,
          startingPrice: 55000.0,
          imageUrl: 'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800',
          description: 'Ultra-modern 5-star hotel featuring lush open garden lawns, glass-walled banquet spaces, and signature luxury suites.',
          amenities: ['Open Garden Lawn', 'Glass Banquet', 'Infinity Pool', '24/7 Butler Service'],
        ),
        DestinationVenue(
          id: 1306,
          name: 'Fairfield by Marriott Vadodara',
          category: '5-Star Luxury Business Hotel',
          location: 'Alkapuri, Vadodara, Gujarat 390007',
          rating: 4.7,
          totalReviews: 80,
          startingPrice: 48000.0,
          imageUrl: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800',
          description: 'Contemporary Marriott property located in prime Alkapuri with spacious wedding banquet halls and gourmet catering.',
          amenities: ['Banquet Hall', 'Modern Suites', 'Executive Catering', 'Free Wifi'],
        ),
        DestinationVenue(
          id: 1307,
          name: 'Grand Mercure Surya Palace',
          category: '5-Star Heritage Hotel',
          location: 'Sayajigunj, Vadodara, Gujarat 390020',
          rating: 4.8,
          totalReviews: 88,
          startingPrice: 45000.0,
          imageUrl: 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800',
          description: 'Luxury heritage-style hotel with grand indoor glass ballrooms and poolside sangeet decks in central Vadodara.',
          amenities: ['Grand Ballroom', 'Poolside Deck', '5 Star Catering', 'Luxury Suites'],
        ),
        DestinationVenue(
          id: 1308,
          name: 'Shiv Mahal Palace Banquets',
          category: 'Heritage Palace Resort',
          location: 'Old Padra Rd, Vadodara, Gujarat 390007',
          rating: 4.7,
          totalReviews: 72,
          startingPrice: 50000.0,
          imageUrl: 'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800',
          description: 'Historic royal palace transformed into a boutique wedding destination with regal courtyards and manicured sangeet lawns.',
          amenities: ['Palace Courtyard', 'Royal Sangeet Lawn', 'Heritage Rooms', 'Valet Parking'],
        ),
        DestinationVenue(
          id: 1309,
          name: 'Lilleria Banquets & Gardens',
          category: 'Luxury Garden Resort',
          location: 'Vasna-Bhayli Rd, Vadodara, Gujarat 391410',
          rating: 4.7,
          totalReviews: 65,
          startingPrice: 42000.0,
          imageUrl: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800',
          description: 'Expansive luxury wedding lawns with grand floral mandap stages, crystal lightings, and air-conditioned banquet pavilions.',
          amenities: ['Grand Floral Lawn', 'AC Banquet Pavilion', 'VIP Lounge', 'Stage Lighting'],
        ),
        DestinationVenue(
          id: 1310,
          name: 'Banyan Paradise Resort',
          category: 'Eco Luxury Resort',
          location: 'Vemali, NH 8, Vadodara, Gujarat 390024',
          rating: 4.6,
          totalReviews: 58,
          startingPrice: 38000.0,
          imageUrl: 'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800',
          description: 'Lush green resort surrounded by banyan groves, featuring private residential wedding villas, pool mandaps, and open amphitheaters.',
          amenities: ['Resort Pool Mandap', 'Residential Villas', 'Amphitheater', 'Multi-Cuisine Catering'],
        ),
      ];
    } else if (locLower.contains('surat')) {
      return [
        DestinationVenue(
          id: 1401,
          name: 'Surat Marriott Hotel',
          category: '5-Star Riverfront Luxury Hotel',
          location: 'Athwa, Tapi Riverfront, Surat, Gujarat 395007',
          rating: 4.9,
          totalReviews: 175,
          startingPrice: 75000.0,
          imageUrl: 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800',
          description: 'Premier 5-star luxury hotel on the banks of Tapi River featuring panoramic riverfront wedding lawns, grand ballrooms, and floating mandap setups.',
          amenities: ['Tapi Riverfront Lawns', 'Marriott Grand Ballroom', 'Open River Terrace', 'Infinity Pool', 'Bridal Suites'],
        ),
        DestinationVenue(
          id: 1402,
          name: 'Le Méridien Surat',
          category: '5-Star Luxury Hotel',
          location: 'Dumas Road, Near Surat Airport, Gujarat 395007',
          rating: 4.9,
          totalReviews: 138,
          startingPrice: 70000.0,
          imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
          description: 'Ultra-luxurious 5-star Marriott hotel offering expansive manicured garden lawns, gourmet vegetarian dining, and luxury suites.',
          amenities: ['Expansive Garden Lawns', 'Grand Banquet Hall', 'Pure Veg Gourmet Dining', 'Airport Transfers'],
        ),
        DestinationVenue(
          id: 1403,
          name: 'Courtyard by Marriott Surat',
          category: '5-Star Luxury Hotel & Banquets',
          location: 'Pal Gam, Hazira Road, Surat, Gujarat 395009',
          rating: 4.8,
          totalReviews: 120,
          startingPrice: 62000.0,
          imageUrl: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=800',
          description: 'Contemporary 5-star hotel in Pal Gam featuring poolside wedding decks, crystal chandeliers, and grand celebratory banquets.',
          amenities: ['Poolside Wedding Deck', 'Marriott Ballroom', 'Executive Catering', 'Valet Parking'],
        ),
        DestinationVenue(
          id: 1404,
          name: 'Vedik Resort & Country Club',
          category: '5-Star Mega Destination Resort',
          location: 'Surat Outskirts, Gujarat 394185',
          rating: 4.8,
          totalReviews: 110,
          startingPrice: 58000.0,
          imageUrl: 'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800',
          description: 'Sprawling 10-acre luxury resort featuring 176 rooms, massive wedding celebration lawns, and large air-conditioned banquet halls.',
          amenities: ['10-Acre Resort Grounds', '176 Guest Rooms', 'Massive Wedding Lawn', 'Mega Banquet Hall'],
        ),
        DestinationVenue(
          id: 1405,
          name: 'Meraki Riverfront Resort & Lawns',
          category: '5-Star Riverfront Resort',
          location: 'Tapi Riverfront, Surat, Gujarat 395009',
          rating: 4.9,
          totalReviews: 92,
          startingPrice: 65000.0,
          imageUrl: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800',
          description: 'Ultra-modern riverfront resort featuring diamond-crystal mandap installations, floating banquet stages, and panoramic river views.',
          amenities: ['Floating Mandap Stage', 'Tapi River View', 'Diamond LED Decor', 'Surti Gourmet Kitchen'],
        ),
        DestinationVenue(
          id: 1406,
          name: 'The World Surat',
          category: '5-Star Luxury Resort Hotel',
          location: 'Shakti Nagar, Dumas Rd, Surat 395007',
          rating: 4.7,
          totalReviews: 84,
          startingPrice: 52000.0,
          imageUrl: 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800',
          description: 'Tranquil luxury resort offering serene garden wedding spaces, fine-dining banquets, and spacious guest suites.',
          amenities: ['Garden Wedding Lawn', 'Grand Dining Banquet', 'Quiet Luxury Suites', 'Free Parking'],
        ),
        DestinationVenue(
          id: 1407,
          name: 'Hilton Garden Inn Surat City Centre',
          category: '5-Star Luxury Hotel',
          location: 'Ring Road, Surat, Gujarat 395002',
          rating: 4.7,
          totalReviews: 76,
          startingPrice: 48000.0,
          imageUrl: 'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800',
          description: 'Central 5-star hotel featuring modern celebration ballrooms, executive lounge, and international chef menus.',
          amenities: ['City Centre Ballroom', 'Executive Lounge', 'Gourmet Kitchen', 'Spa Service'],
        ),
        DestinationVenue(
          id: 1408,
          name: 'The Grand Bhagwati Resort & Banquets',
          category: 'Luxury Resort & Convention Hall',
          location: 'Dumas Road, Magdalla, Surat 395007',
          rating: 4.8,
          totalReviews: 130,
          startingPrice: 55000.0,
          imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800',
          description: 'Famous luxury resort & convention hall known for opulent Gujarati wedding feasts, royal chandeliers, and massive event grounds.',
          amenities: ['Opulent Convention Hall', 'Royal Gujarati Feast', 'Ample Parking', 'VIP Suites'],
        ),
        DestinationVenue(
          id: 1409,
          name: 'Vatika Garden & Banquets',
          category: 'Riverfront Garden Resort',
          location: 'Katargam, Tapi Riverfront, Surat 395004',
          rating: 4.6,
          totalReviews: 62,
          startingPrice: 40000.0,
          imageUrl: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800',
          description: 'Scenic riverfront garden venue near Weir-cum-Causeway with lush green lawns and glass banquet hall for evening receptions.',
          amenities: ['Riverfront Garden Lawn', 'Glass Banquet', 'Stage Decor', 'Buffet Dining'],
        ),
        DestinationVenue(
          id: 1410,
          name: 'Riverfront Celebration Lawns',
          category: 'Open-Air Riverfront Venue',
          location: 'Udhna, Tapi Riverfront, Surat 394210',
          rating: 4.6,
          totalReviews: 54,
          startingPrice: 35000.0,
          imageUrl: 'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800',
          description: 'Vast open-air riverfront lawns ideal for grand evening sangeet, fireworks, and live orchestra mandap setups.',
          amenities: ['Open-Air River Lawns', 'Firework Launch Pad', 'Live Orchestra Stage', 'Catering Setup'],
        ),
      ];
    } else if (locLower.contains('diu')) {
      return [
        DestinationVenue(
          id: 1501,
          name: 'Praveg Beach Resort, Nagoa Beach',
          category: '5-Star Luxury Beach Resort',
          location: 'Nagoa Beach Road, Diu, Gujarat Border 362520',
          rating: 4.9,
          totalReviews: 150,
          startingPrice: 58000.0,
          imageUrl: 'https://images.unsplash.com/photo-1510414842594-a61c69b5ae57?w=800',
          description: 'Premier 5-star luxury beach resort on famous Nagoa Beach with direct sea access, palm grove wedding lawns for 400+ guests, and Portuguese-style chalets.',
          amenities: ['Nagoa Beach Access', 'Palm Grove Lawns', 'Poolside Barbecue', 'Portuguese Chalets', 'Spa & Wellness'],
        ),
        DestinationVenue(
          id: 1502,
          name: 'Praveg Beach Resort, Ghoghla Beach',
          category: '5-Star Luxury Ocean Resort',
          location: 'Ghoghla Beach, Diu Coast, Gujarat Border 362520',
          rating: 4.9,
          totalReviews: 125,
          startingPrice: 55000.0,
          imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
          description: 'Luxury beachfront resort on serene Blue Flag Ghoghla Beach featuring golden sand mandap lawns, private sun decks, and gourmet seafood banquet.',
          amenities: ['Ghoghla Blue Flag Beach', 'Golden Sand Mandap', 'Sun Deck Lounge', 'Seafood Banquet'],
        ),
        DestinationVenue(
          id: 1503,
          name: 'The Fern Seaside Resort, Nagoa Beach',
          category: '4-Star Premium Beach Resort',
          location: 'Nagoa Beach, Diu Coast, Gujarat Border 362520',
          rating: 4.8,
          totalReviews: 110,
          startingPrice: 48000.0,
          imageUrl: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=800',
          description: 'Tranquil 4-star eco-sensitive beach resort by The Fern featuring coconut palm lawns, ocean breeze banquets, and sea-view chalets.',
          amenities: ['Palm Grove Beach Lawns', 'Infinity Pool', 'Seaside Bar & Grill', 'Eco Chalets'],
        ),
        DestinationVenue(
          id: 1504,
          name: 'Radhika Beach Resort & Spa',
          category: '4-Star Heritage Beach Resort',
          location: 'Nagoa Beach, Diu Coast, Gujarat Border 362520',
          rating: 4.8,
          totalReviews: 95,
          startingPrice: 42000.0,
          imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
          description: 'Iconic beach resort & spa with Portuguese colonial arches, coconut grove sangeet lawns, swimming pool, and seafood dining.',
          amenities: ['Portuguese Arches', 'Coconut Grove Lawn', 'Ayu Spa', 'Seafood Restaurant'],
        ),
        DestinationVenue(
          id: 1505,
          name: 'Gateway Diu (IHCL SeleQtions)',
          category: '5-Star Heritage Luxury Hotel',
          location: 'Fort Road, Near Diu Fort, Diu 362520',
          rating: 4.9,
          totalReviews: 105,
          startingPrice: 65000.0,
          imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800',
          description: 'High-end IHCL heritage luxury hotel near historic Diu Fort offering Portuguese fortress architecture, sea-facing terraces, and imperial banquets.',
          amenities: ['Diu Fort View Terrace', 'Portuguese Courtyard', 'IHCL Gourmet Dining', 'Luxury Suites'],
        ),
        DestinationVenue(
          id: 1506,
          name: 'Kostamar Beach Resort',
          category: '4-Star Luxury Beach Hotel',
          location: '40m from Nagoa Beach, Diu 362520',
          rating: 4.7,
          totalReviews: 82,
          startingPrice: 38000.0,
          imageUrl: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800',
          description: 'Contemporary 4-star luxury resort located 40 meters from Nagoa Beach with lavish sea-facing rooms, rooftop dining deck, and cocktail lounge.',
          amenities: ['40m Nagoa Beach Walk', 'Rooftop Dining Deck', 'Cocktail Lounge', 'Free Wifi'],
        ),
        DestinationVenue(
          id: 1507,
          name: 'The Fort House, Diu',
          category: 'Boutique Heritage Resort',
          location: 'Fort Rampart Road, Near Diu Lighthouse 362520',
          rating: 4.8,
          totalReviews: 70,
          startingPrice: 50000.0,
          imageUrl: 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800',
          description: 'Boutique heritage luxury hotel overlooking historic Diu Fort and Portuguese sea ramparts with intimate cliffside mandap decks.',
          amenities: ['Cliffside Sea View Deck', 'Fort Rampart View', 'Boutique Suites', 'Fine Dining'],
        ),
        DestinationVenue(
          id: 1508,
          name: 'Rass Residency & Beach Resort',
          category: 'Coastal Beach Resort',
          location: 'Jalandhar Beach Road, Diu 362520',
          rating: 4.6,
          totalReviews: 58,
          startingPrice: 32000.0,
          imageUrl: 'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800',
          description: 'Modern coastal resort on Jalandhar Beach with open-air sea view terraces, Portuguese-themed sangeet decor, and buffet hall.',
          amenities: ['Jalandhar Beach Terrace', 'Portuguese Sangeet Stage', 'Multi-Cuisine Buffet', 'Valet Parking'],
        ),
        DestinationVenue(
          id: 1509,
          name: 'Diu Sunset Beach Resort',
          category: 'Coastal Sunset Resort',
          location: 'Chakratirth Beach & Sunset Point, Diu 362520',
          rating: 4.6,
          totalReviews: 52,
          startingPrice: 30000.0,
          imageUrl: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800',
          description: 'Scenic resort near Chakratirth Beach & Sunset Point featuring sunset lawn decks and beachside banquet halls for evening vows.',
          amenities: ['Chakratirth Sunset Lawn', 'Beachside Banquet', 'Cocktail Terrace', 'Free Parking'],
        ),
        DestinationVenue(
          id: 1510,
          name: 'Hotel Kohinoor & Water Park Resort',
          category: 'Heritage Resort & Banquets',
          location: 'Fofrara, Nagoa Beach Rd, Diu 362520',
          rating: 4.6,
          totalReviews: 64,
          startingPrice: 28000.0,
          imageUrl: 'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800',
          description: 'Spacious resort with Portuguese courtyard lawns, swimming pool deck, and multi-cuisine catering for residential wedding parties.',
          amenities: ['Portuguese Courtyard', 'Swimming Pool Deck', 'Water Park Access', 'Resort Rooms'],
        ),
      ];
    } else if (locLower.contains('udaipur')) {
      return [
        DestinationVenue(
          id: 101,
          name: 'The Oberoi Udaivilas, Udaipur',
          category: '5-Star Luxury Resort',
          location: 'Haridas Ji Ki Magri, Lake Pichola, Udaipur',
          rating: 5.0,
          totalReviews: 240,
          startingPrice: 160000.0,
          imageUrl: 'https://images.unsplash.com/photo-1599661046827-dacff0c0f09a?w=800',
          description: 'Ranked among the top luxury resorts globally, featuring royal Mewari domes, reflection pools, lakeside mandap lawns, and boat arrival dock for couples.',
          amenities: ['Private Boat Dock', 'Reflection Pools', 'Mewari Lawns', 'Royal Butler Service', 'Fireworks Deck'],
        ),
        DestinationVenue(
          id: 102,
          name: 'Taj Lake Palace, Udaipur',
          category: 'Heritage Floating Palace',
          location: 'Lake Pichola, Udaipur, Rajasthan',
          rating: 5.0,
          totalReviews: 215,
          startingPrice: 180000.0,
          imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800',
          description: 'The iconic 18th-century white marble floating palace in the middle of Lake Pichola offering royal heritage courtyards and fireworks over water.',
          amenities: ['Floating Palace Mandap', 'Royal Marwari Feast', 'Shikara Procession', 'Heritage Suites'],
        ),
        DestinationVenue(
          id: 103,
          name: 'The Leela Palace Udaipur',
          category: '5-Star Lakeside Resort',
          location: 'Lake Pichola Shore, Udaipur',
          rating: 4.9,
          totalReviews: 195,
          startingPrice: 145000.0,
          imageUrl: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=800',
          description: 'Ultra-luxury lakefront palace resort boasting royal Mewar architecture, crystal chandelier ballrooms, infinity pool, and lakeside sangeet terrace.',
          amenities: ['Lakefront Mandap Lawn', 'Crystal Chandelier Ballroom', 'Infinity Pool Deck', 'Helipad Access'],
        ),
        DestinationVenue(
          id: 104,
          name: 'Jagmandir Island Palace, Udaipur',
          category: 'Historic Island Palace Venue',
          location: 'Lake Pichola Island, Udaipur',
          rating: 4.9,
          totalReviews: 180,
          startingPrice: 150000.0,
          imageUrl: 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=800',
          description: 'Historic 17th-century marble palace on an island in Lake Pichola, famous for celebrity weddings, royal elephant statues, and evening illuminations.',
          amenities: ['Island Palace Mandap', 'Royal Marble Courtyard', 'Shikara Guest Entry', 'Illuminated Towers'],
        ),
        DestinationVenue(
          id: 105,
          name: 'Raffles Udaipur',
          category: '5-Star Private Island Resort',
          location: 'Udai Sagar Lake, Udaipur',
          rating: 4.9,
          totalReviews: 140,
          startingPrice: 135000.0,
          imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
          description: 'Exclusive luxury resort situated on a private island on Udai Sagar Lake, featuring European-Mewari fusion architecture and grand glasshouse banquets.',
          amenities: ['Private Island Lawns', 'Glasshouse Ballroom', 'Sunset Boat Ride', 'Butler Concierge'],
        ),
        DestinationVenue(
          id: 106,
          name: 'Taj Aravali Resort & Spa, Udaipur',
          category: '5-Star Mountain Resort',
          location: 'Kodiyat Road, Aravali Foothills, Udaipur',
          rating: 4.8,
          totalReviews: 165,
          startingPrice: 95000.0,
          imageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=800',
          description: 'Sprawling 27-acre luxury mountain resort surrounded by the rugged Aravali hills, offering high-capacity amphitheater lawns and glass banquet halls.',
          amenities: ['Aravali Foothill Lawns', 'Amphitheater Sangeet', 'Grand Ballroom', 'Luxury Cottages'],
        ),
        DestinationVenue(
          id: 107,
          name: 'Ananta Resort & Spa, Udaipur',
          category: '5-Star Luxury Villa Resort',
          location: 'Kodiyat Main Road, Udaipur',
          rating: 4.8,
          totalReviews: 210,
          startingPrice: 85000.0,
          imageUrl: 'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?w=800',
          description: 'Sprawled across 75 acres of lush greenery, featuring Balinese-inspired luxury villas, open-air hilltop mandaps, and giant sangeet lawns for 1000+ guests.',
          amenities: ['75-Acre Hilltop Estate', 'Open Air Amphitheater', 'Balinese Villas', 'Golf Cart Shuttle'],
        ),
        DestinationVenue(
          id: 108,
          name: 'Fateh Garh Heritage Resort, Udaipur',
          category: 'Heritage Hilltop Palace',
          location: 'Sisarma, Kelwa Parikrama, Udaipur',
          rating: 4.8,
          totalReviews: 130,
          startingPrice: 90000.0,
          imageUrl: 'https://images.unsplash.com/photo-1477587458883-47145ed94245?w=800',
          description: 'Perched high on a hill overlooking Udaipur city and lakes, rebuilt using historic stone carvings and heritage zero-waste architecture.',
          amenities: ['360 Hilltop View Lawn', 'Heritage Poolside Deck', 'Vintage Car Museum', 'Sunset Terrace'],
        ),
        DestinationVenue(
          id: 109,
          name: 'Aurika, Udaipur by Lemon Tree Hotels',
          category: '5-Star Hilltop Luxury Hotel',
          location: 'Haridas Ji Ki Magri, Udaipur',
          rating: 4.9,
          totalReviews: 155,
          startingPrice: 105000.0,
          imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800',
          description: 'Majestic hilltop palace hotel spread across 5 acres with ornate courtyards, grand ballroom, and sweeping views of Pichola & Fateh Sagar lakes.',
          amenities: ['Sweeping Lake View Lawn', 'Ornate Courtyard', 'Grand Ballroom', 'Spa & Wellness'],
        ),
        DestinationVenue(
          id: 110,
          name: 'The Lalit Laxmi Vilas Palace, Udaipur',
          category: 'Royal Heritage Palace Hotel',
          location: 'Fateh Sagar Lake, Udaipur',
          rating: 4.8,
          totalReviews: 175,
          startingPrice: 98000.0,
          imageUrl: 'https://images.unsplash.com/photo-1602216056096-3b40cc0c9944?w=800',
          description: 'Historic 1911 palace built by Maharana Fateh Singh, sitting on a hilltop overlooking Fateh Sagar Lake with traditional Royal Bagpiper welcome.',
          amenities: ['Fateh Sagar Lake Lawn', 'Royal Bagpiper Welcome', 'Heritage Suite Wing', 'Puppet Show Deck'],
        ),
        DestinationVenue(
          id: 111,
          name: 'RAAS Devigarh, Udaipur',
          category: '18th-Century Fort Palace',
          location: 'Delwara, NH 8, Near Udaipur',
          rating: 4.9,
          totalReviews: 145,
          startingPrice: 125000.0,
          imageUrl: 'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?w=800',
          description: 'A spectacular 18th-century palace fort in the Aravali hills featuring modern luxury suites, mirror courtyard, and intimate royal mandaps.',
          amenities: ['18th-Century Palace Fort', 'Sheesh Mahal Courtyard', 'Rooftop Stargazing Lawn', 'Spa by L\'Occitane'],
        ),
        DestinationVenue(
          id: 112,
          name: 'Trident Hotel, Udaipur',
          category: '5-Star Lakefront Resort',
          location: 'Haridas Ji Ki Magri, Udaipur',
          rating: 4.8,
          totalReviews: 190,
          startingPrice: 80000.0,
          imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
          description: 'Spanning 43 acres of manicured gardens on the banks of Lake Pichola, offering classic Rajasthani hospitality and lush banquet lawns.',
          amenities: ['43-Acre Garden Lawns', 'Lakeview Poolside', 'Bada Mahal Banquets', 'Kids Activity Club'],
        ),
        DestinationVenue(
          id: 113,
          name: 'Radisson Blu Udaipur Palace Resort & Spa',
          category: '5-Star Luxury Resort',
          location: 'Fateh Sagar Lake, Udaipur',
          rating: 4.8,
          totalReviews: 185,
          startingPrice: 92000.0,
          imageUrl: 'https://images.unsplash.com/photo-1510414842594-a61c69b5ae57?w=800',
          description: 'Overlooking Fateh Sagar Lake with a grand two-tier outdoor pool, high-tech indoor ballrooms, and rooftop cocktail decks.',
          amenities: ['Two-Tier Pool Deck', 'Fateh Sagar View Lawns', 'Fateh Ballroom', 'Rooftop Lounge'],
        ),
        DestinationVenue(
          id: 114,
          name: 'Chundavanam Heritage Resort, Udaipur',
          category: 'Royal Heritage Resort',
          location: 'Chundavanam Enclave, Udaipur',
          rating: 4.7,
          totalReviews: 110,
          startingPrice: 65000.0,
          imageUrl: 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=800',
          description: 'Authentic royal Mewari architecture with carved stone pillars, central jharokhas, and intimate garden mandap setups.',
          amenities: ['Carved Jharokha Stage', 'Mewari Dining Hall', 'Courtyard Mandap', 'Folk Dance Stage'],
        ),
        DestinationVenue(
          id: 115,
          name: 'Bhairav Garh Resort & Spa, Udaipur',
          category: 'Hilltop Luxury Resort',
          location: 'Chitrakoot Nagar, Maharana Pratap Khel Gaon, Udaipur',
          rating: 4.7,
          totalReviews: 125,
          startingPrice: 70000.0,
          imageUrl: 'https://images.unsplash.com/photo-1595815771614-ade9d652a65d?w=800',
          description: 'Perched on the highest hill of Udaipur offering panoramic city skyline views, infinity pool mandap, and grand banquet lawns.',
          amenities: ['Panoramic City Skyline Lawn', 'Infinity Pool Mandap', 'Grand Banquet Hall', 'Rooftop Sangeet'],
        ),
        DestinationVenue(
          id: 116,
          name: 'Ramada Udaipur Resort & Spa',
          category: '5-Star Heritage Style Resort',
          location: 'Rampura, Rampura Circle, Udaipur',
          rating: 4.8,
          totalReviews: 160,
          startingPrice: 88000.0,
          imageUrl: 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=800',
          description: 'Built with traditional Tekri work stone masonry, featuring central courtyards, peacock garden lawns, and poolside sangeet stages.',
          amenities: ['Tekri Stone Masonry', 'Peacock Garden Lawns', 'Poolside Sangeet Stage', 'Ayurvedic Spa'],
        ),
        DestinationVenue(
          id: 117,
          name: 'The Royal Retreat Resort & Spa, Udaipur',
          category: 'Luxury Boutique Resort',
          location: 'Badi Hawala Road, Near Badi Lake, Udaipur',
          rating: 4.7,
          totalReviews: 135,
          startingPrice: 75000.0,
          imageUrl: 'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=800',
          description: 'Lush boutique resort surrounded by Sajjangarh monsoon palace sanctuary, filled with rare antiques, sculptures, and forest lawns.',
          amenities: ['Sajjangarh Sanctuary View', 'Antique Art Decor', 'Forest Garden Lawns', 'Poolside Mandap'],
        ),
        DestinationVenue(
          id: 118,
          name: 'Hotel Lakend, Udaipur',
          category: '4-Star Waterfront Luxury Hotel',
          location: 'Alka Puri, Fateh Sagar Lake, Udaipur',
          rating: 4.8,
          totalReviews: 170,
          startingPrice: 78000.0,
          imageUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=800',
          description: 'Directly situated on the shores of Fateh Sagar Lake, offering water-facing wedding lawns, glass dining pavilions, and sunset sangeets.',
          amenities: ['Direct Lake Shore Lawn', 'Waterfront Mandap', 'Glass Dining Pavilion', 'Sunset Cocktail Deck'],
        ),
        DestinationVenue(
          id: 119,
          name: 'Labh Garh Palace Resort, Udaipur',
          category: 'Grand Palace Resort & Convention',
          location: 'Cheetak Circle, Cheerwa Ghat, Udaipur',
          rating: 4.7,
          totalReviews: 140,
          startingPrice: 68000.0,
          imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
          description: 'Sprawling palace resort surrounded by green valleys with dual swimming pools, massive sangeet grounds, and luxury guest wings.',
          amenities: ['Dual Swimming Pools', '1500 Guest Lawn', 'Palace Ballroom', 'Fireworks Deck'],
        ),
        DestinationVenue(
          id: 120,
          name: 'Fateh Prakash Palace (Durbar Hall), Udaipur',
          category: 'City Palace Complex Venue',
          location: 'The City Palace Complex, Lake Pichola, Udaipur',
          rating: 5.0,
          totalReviews: 220,
          startingPrice: 170000.0,
          imageUrl: 'https://images.unsplash.com/photo-1599661046827-dacff0c0f09a?w=800',
          description: 'Exclusive royal venue inside the City Palace complex, home to the historic Durbar Hall with giant crystal chandeliers and velvet thrones.',
          amenities: ['Historic Durbar Hall', '1000kg Crystal Chandelier', 'City Palace Access', 'Royal Throne Stage'],
        ),
        DestinationVenue(
          id: 121,
          name: 'Zenana Mahal, City Palace, Udaipur',
          category: 'Royal Heritage Courtyard',
          location: 'The City Palace Complex, Udaipur',
          rating: 5.0,
          totalReviews: 200,
          startingPrice: 175000.0,
          imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800',
          description: 'The historic 16th-century Queen\'s Palace courtyard inside the City Palace, lit up by thousands of candles and floral mandap arches.',
          amenities: ['16th Century Queen Palace', 'Candlelit Courtyard', 'Royal Shehnai Stage', 'Mewari Banquet'],
        ),
        DestinationVenue(
          id: 122,
          name: 'Shiv Niwas Palace, Udaipur',
          category: 'Crescent Heritage Palace Hotel',
          location: 'The City Palace Complex, Udaipur',
          rating: 4.9,
          totalReviews: 190,
          startingPrice: 130000.0,
          imageUrl: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=800',
          description: 'Crescent-shaped heritage palace built in the early 20th century by Maharana Fateh Singh, featuring marble pool courtyards and royal suites.',
          amenities: ['Crescent Marble Pool Lawn', 'Heritage Suites', 'Royal Courtyard Sangeet', 'Butler Service'],
        ),
        DestinationVenue(
          id: 123,
          name: 'Spectrum Resort Spa & Convention, Udaipur',
          category: 'Sprawling Convention Resort',
          location: 'NH 8, Gram Balicha, Udaipur',
          rating: 4.6,
          totalReviews: 105,
          startingPrice: 58000.0,
          imageUrl: 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=800',
          description: 'Large-scale destination resort with massive wedding convention halls, manicured palm lawns, and budget-friendly luxury suites.',
          amenities: ['Convention Hall for 2000', 'Palm Tree Lawns', 'Poolside Deck', 'Valet Parking'],
        ),
        DestinationVenue(
          id: 124,
          name: 'TatSaraasa Resort & Spa, Udaipur',
          category: 'Lakeside Boutique Resort',
          location: 'Lakhawali Lake Shore, Udaipur',
          rating: 4.8,
          totalReviews: 115,
          startingPrice: 72000.0,
          imageUrl: 'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?w=800',
          description: 'Peaceful boutique resort on the secluded Lakhawali Lake, offering tranquil sunset mandap lawns and organic farm-to-table dining.',
          amenities: ['Lakhawali Lake View', 'Sunset Mandap Lawn', 'Organic Farm Kitchen', 'Private Jacuzzis'],
        ),
        DestinationVenue(
          id: 125,
          name: 'Viveda Wellness & Luxury Resort, Udaipur',
          category: 'Luxury Eco Resort',
          location: 'Badi Lake Enclave, Udaipur',
          rating: 4.8,
          totalReviews: 95,
          startingPrice: 82000.0,
          imageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=800',
          description: 'Ultra-modern eco-wellness resort surrounded by mountain peaks and glass mandap pavilions for serene destination weddings.',
          amenities: ['Glass Mandap Pavilion', 'Mountain Peak Views', 'Sattvik & Gourmet Menu', 'Ayurvedic Spa'],
        ),
      ];
    } else if (locLower.contains('jaipur')) {
      return [
        DestinationVenue(
          id: 201,
          name: 'Chomu Palace Heritage Resort',
          category: 'Heritage Fort Palace',
          location: 'Chomu, Jaipur, Rajasthan',
          rating: 4.8,
          totalReviews: 96,
          startingPrice: 85000.0,
          imageUrl: 'https://images.unsplash.com/photo-1477587458883-47145ed94245?w=800',
          description: 'Authentic 300-year-old fort palace with Sheesh Mahal courtyards, elephant welcome routes, and royal banquet gardens.',
          amenities: ['Sheesh Mahal Courtyard', 'Elephant Entry', 'Heritage Fort Lawns', 'Royal Dining'],
        ),
      ];
    } else if (locLower.contains('goa')) {
      return [
        DestinationVenue(
          id: 301,
          name: 'Taj Exotica Seaside Resort & Spa',
          category: '5-Star Beach Resort',
          location: 'Benaulim Beach, South Goa',
          rating: 4.9,
          totalReviews: 115,
          startingPrice: 75000.0,
          imageUrl: 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=800',
          description: 'Mediterranean-style beachfront resort spread across 56 acres with sunset ocean mandap lawns and beach DJ party setups.',
          amenities: ['Private Beach', '56 Acre Gardens', 'Poolside Cocktail Bar', 'Sunset Mandap'],
        ),
      ];
    }

    return [];
  }
}
