// lib/models/destination_model.dart

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
    );
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
          name: 'Narmada Tent City 1 Luxury Resort',
          category: '5-Star Luxury Resort',
          location: 'Kevadia, Narmada District, Gujarat',
          rating: 4.9,
          totalReviews: 84,
          startingPrice: 45000.0,
          imageUrl: 'https://images.unsplash.com/photo-1599661046827-dacff0c0f09a?w=800',
          description: 'Sprawling luxury tented resort right next to Narmada river with royal dining halls, swimming pool, and grand mandap lawn for 500+ guests.',
          amenities: ['Riverfront Lawns', 'Luxury AC Tents', 'Helipad', 'Multicuisine Catering', 'Free Wifi'],
        ),
        DestinationVenue(
          id: 902,
          name: 'Tent City 2 Narmada Villas',
          category: 'Eco Resort & Banquets',
          location: 'Vindhyachal Hills, Kevadia, Gujarat',
          rating: 4.8,
          totalReviews: 62,
          startingPrice: 38000.0,
          imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
          description: 'Eco-luxury villa resort surrounded by Vindhyachal mountains featuring sunset cocktail terrace and open amphitheater.',
          amenities: ['Sunset Terrace', 'Glass Banquet', 'Poolside Lounge', 'Garden Lawns'],
        ),
        DestinationVenue(
          id: 903,
          name: 'Statue View Heritage Palace Hotel',
          category: 'Heritage Hotel',
          location: 'Narmada Riverfront, Kevadia, Gujarat',
          rating: 4.7,
          totalReviews: 45,
          startingPrice: 52000.0,
          imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800',
          description: 'Royal hotel venue offering panoramic view of the Statue of Unity with 120 guest suites and royal banquet halls.',
          amenities: ['120 Guest Suites', 'Royal Ballroom', 'Valet Parking', 'Bridal Suite'],
        ),
      ];
    } else if (locLower.contains('kutch') || titleLower.contains('rann of kutch')) {
      return [
        DestinationVenue(
          id: 1001,
          name: 'White Rann Resort Dhordo',
          category: '5-Star Desert Resort',
          location: 'Dhordo, White Rann, Kutch, Gujarat',
          rating: 4.9,
          totalReviews: 110,
          startingPrice: 55000.0,
          imageUrl: 'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?w=800',
          description: 'Premium white desert resort featuring moonlit mandaps, Swiss cottages, Kutchi folk amphitheater, and camel cart entries.',
          amenities: ['Moonlit Desert Mandap', 'Kutchi Crafts Market', 'Swiss Cottages', 'Cultural Stage'],
        ),
        DestinationVenue(
          id: 1002,
          name: 'Rann Utsav Tent City Grand',
          category: 'Luxury Tent Resort',
          location: 'Rann of Kutch Enclave, Gujarat',
          rating: 4.8,
          totalReviews: 95,
          startingPrice: 48000.0,
          imageUrl: 'https://images.unsplash.com/photo-1510414842594-a61c69b5ae57?w=800',
          description: 'Famous Rann Utsav luxury tent village with dedicated sangeet lawns, authentic Kutchi food stalls, and full-moon photography spots.',
          amenities: ['Garba Grounds', 'Royal Tents', 'Star Gazing Deck', 'Full Power Backup'],
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
          name: 'Hawthorn Suites by Wyndham Dwarka',
          category: '5-Star Beach Resort',
          location: 'Arabian Sea Coast, Dwarka, Gujarat',
          rating: 4.8,
          totalReviews: 70,
          startingPrice: 35000.0,
          imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
          description: 'Sprawling eco-resort overlooking the Arabian Sea with seaside mandap lawns and pure vegetarian gourmet kitchens.',
          amenities: ['Oceanfront Lawns', 'Pure Veg & Jain Dining', 'Seaside Pool', 'Vedic Ceremony Stage'],
        ),
        DestinationVenue(
          id: 1202,
          name: 'Dwarkadhish Beach Resort & Banquets',
          category: 'Coastal Resort Hotel',
          location: 'Temple Road, Dwarka, Gujarat',
          rating: 4.7,
          totalReviews: 48,
          startingPrice: 28000.0,
          imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800',
          description: 'Serene beach resort near historic Dwarkadhish temple featuring ocean view lawns and shehnai mandaps.',
          amenities: ['Temple View', 'Beachfront Mandap', '100 Guest Rooms', 'Mandap Catering'],
        ),
      ];
    } else if (locLower.contains('vadodara')) {
      return [
        DestinationVenue(
          id: 1301,
          name: 'Laxmi Vilas Palace Lawns & Pavilion',
          category: 'Royal Palace Venue',
          location: 'Jawaharlal Nehru Marg, Vadodara, Gujarat',
          rating: 5.0,
          totalReviews: 140,
          startingPrice: 150000.0,
          imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800',
          description: 'Grandest royal palace grounds in Gujarat featuring majestic Indo-Saracenic architecture, marble courtyards, and royal elephant procession pathways.',
          amenities: ['Palace Courtyard', 'Royal Maratha Decor', 'Elephant Procession Route', '2000 Guest Lawns'],
        ),
        DestinationVenue(
          id: 1302,
          name: 'Grand Mercure Surya Palace',
          category: '5-Star Luxury Hotel',
          location: 'Sayajigunj, Vadodara, Gujarat',
          rating: 4.8,
          totalReviews: 88,
          startingPrice: 45000.0,
          imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
          description: 'Luxury heritage-style hotel with grand indoor glass ballrooms and poolside sangeet decks.',
          amenities: ['Grand Ballroom', 'Poolside Deck', '5 Star Catering', 'Luxury Suites'],
        ),
      ];
    } else if (locLower.contains('surat')) {
      return [
        DestinationVenue(
          id: 1401,
          name: 'Meraki Riverfront Resort & Lawns',
          category: '5-Star Riverfront Resort',
          location: 'Tapi Riverfront, Surat, Gujarat',
          rating: 4.9,
          totalReviews: 92,
          startingPrice: 65000.0,
          imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
          description: 'Ultra-modern riverfront resort featuring diamond-crystal mandap installations and floating banquet stages.',
          amenities: ['Floating Stage', 'Tapi River View', 'Diamond LED Decor', 'Surti Gourmet Kitchen'],
        ),
      ];
    } else if (locLower.contains('diu')) {
      return [
        DestinationVenue(
          id: 1501,
          name: 'Radhika Beach Resort Diu',
          category: 'Beachfront Resort',
          location: 'Nagoa Beach, Diu Coast, Gujarat Border',
          rating: 4.8,
          totalReviews: 66,
          startingPrice: 32000.0,
          imageUrl: 'https://images.unsplash.com/photo-1510414842594-a61c69b5ae57?w=800',
          description: 'Beautiful palm-fringed resort on Nagoa Beach with Portuguese colonial architecture and beachside mandap.',
          amenities: ['Nagoa Beach View', 'Palm Grove Lawns', 'Cocktail Lounge', 'Seafood Grill'],
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
