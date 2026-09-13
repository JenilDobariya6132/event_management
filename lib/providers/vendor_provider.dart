// lib/providers/vendor_provider.dart

import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../models/category_model.dart';
import '../models/destination_model.dart';
import '../models/vendor_model.dart';
import '../models/package_model.dart';
import '../models/review_model.dart';
import '../models/banner_model.dart';
import '../services/api_service.dart';

class VendorProvider with ChangeNotifier {
  List<CategoryModel> _categories = [];
  List<VendorModel> _vendors = [];
  List<VendorModel> _popularVendors = [];
  List<DestinationModel> _destinations = [];
  List<VendorModel> _favorites = [];
  List<BannerModel> _banners = [];
  List<OfferModel> _offers = [];

  // Selected Vendor Details State
  VendorModel? _selectedVendor;
  List<PackageModel> _selectedPackages = [];
  List<ReviewModel> _selectedReviews = [];
  List<String> _selectedGallery = [];

  bool _isLoading = false;
  final String _selectedCity = 'All';
  final int _selectedCategoryFilter = 0;

  List<CategoryModel> get categories => _categories;
  List<VendorModel> get vendors => _vendors;
  List<VendorModel> get popularVendors => _popularVendors;
  List<DestinationModel> get destinations => _destinations;
  List<VendorModel> get favorites => _favorites;
  List<BannerModel> get banners => _banners;
  List<OfferModel> get offers => _offers;

  VendorModel? get selectedVendor => _selectedVendor;
  List<PackageModel> get selectedPackages => _selectedPackages;
  List<ReviewModel> get selectedReviews => _selectedReviews;
  List<String> get selectedGallery => _selectedGallery;
  bool get isLoading => _isLoading;
  String get selectedCity => _selectedCity;
  int get selectedCategoryFilter => _selectedCategoryFilter;

  Future<void> fetchCategories() async {
    final res = await ApiService.get(ApiConfig.categories);
    if (res['success'] == true && res['data'] != null) {
      _categories = (res['data'] as List).map((c) => CategoryModel.fromJson(c)).toList();
    } else if (_categories.isEmpty) {
      _categories = _getDefaultCategories();
    }
    notifyListeners();
  }

  Future<void> fetchBannersAndOffers() async {
    final res = await ApiService.get(ApiConfig.banners);
    if (res['success'] == true && res['data'] != null) {
      if (res['data']['banners'] != null) {
        _banners = (res['data']['banners'] as List).map((b) => BannerModel.fromJson(b)).toList();
      }
      if (res['data']['offers'] != null) {
        _offers = (res['data']['offers'] as List).map((o) => OfferModel.fromJson(o)).toList();
      }
    } else if (_banners.isEmpty) {
      _banners = _getDefaultBanners();
      _offers = _getDefaultOffers();
    }
    notifyListeners();
  }

  Future<void> fetchVendors({int? categoryId, String? city, String? search, double? minPrice, double? maxPrice, double? minRating}) async {
    _isLoading = true;
    notifyListeners();

    String url = ApiConfig.vendors;
    List<String> queryParams = [];

    if (categoryId != null && categoryId > 0) queryParams.add('category_id=$categoryId');
    if (city != null && city.isNotEmpty && city != 'All') queryParams.add('city=$city');
    if (search != null && search.isNotEmpty) queryParams.add('search=$search');
    if (minPrice != null && minPrice > 0) queryParams.add('min_price=$minPrice');
    if (maxPrice != null && maxPrice > 0) queryParams.add('max_price=$maxPrice');
    if (minRating != null && minRating > 0) queryParams.add('min_rating=$minRating');

    if (queryParams.isNotEmpty) {
      url += '?${queryParams.join('&')}';
    }

    final res = await ApiService.get(url);
    if (res['success'] == true && res['data'] != null) {
      _vendors = (res['data'] as List).map((v) => VendorModel.fromJson(v)).toList();
      if (_popularVendors.isEmpty) {
        _popularVendors = List.from(_vendors);
      }
    } else if (_vendors.isEmpty) {
      _vendors = _getDefaultVendors();
      _popularVendors = List.from(_vendors);
    }

    // Local client side filtering if offline
    if (res['success'] != true) {
      if (categoryId != null && categoryId > 0) {
        _vendors = _vendors.where((v) => v.categoryId == categoryId).toList();
      }
      if (city != null && city.isNotEmpty && city != 'All') {
        _vendors = _vendors.where((v) => v.city.toLowerCase() == city.toLowerCase()).toList();
      }
      if (search != null && search.isNotEmpty) {
        _vendors = _vendors.where((v) => v.businessName.toLowerCase().contains(search.toLowerCase()) || (v.categoryName ?? '').toLowerCase().contains(search.toLowerCase())).toList();
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchVendorDetails(int vendorId) async {
    _isLoading = true;
    notifyListeners();

    final res = await ApiService.get("${ApiConfig.vendorDetails}?id=$vendorId");

    if (res['success'] == true && res['data'] != null) {
      final data = res['data'];
      _selectedVendor = VendorModel.fromJson(data['vendor']);

      if (data['packages'] != null) {
        _selectedPackages = (data['packages'] as List).map((p) => PackageModel.fromJson(p)).toList();
      }
      if (data['reviews'] != null) {
        _selectedReviews = (data['reviews'] as List).map((r) => ReviewModel.fromJson(r)).toList();
      }
      if (data['gallery'] != null) {
        _selectedGallery = (data['gallery'] as List).map((g) => g['image_url'].toString()).toList();
      }
    } else {
      // Fallback selection from memory / seed
      _selectedVendor = _vendors.firstWhere(
        (v) => v.id == vendorId,
        orElse: () => _getDefaultVendors().first,
      );
      _selectedPackages = _getDefaultPackages();
      _selectedReviews = _getDefaultReviews();
      _selectedGallery = [
        "https://images.unsplash.com/photo-1519167758481-83f550bb49b3?auto=format&fit=crop&w=800&q=80",
        "https://images.unsplash.com/photo-1511795409834-ef04bbd61622?auto=format&fit=crop&w=800&q=80",
        "https://images.unsplash.com/photo-1465495976277-4387d4b0b4c6?auto=format&fit=crop&w=800&q=80"
      ];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchDestinations() async {
    final res = await ApiService.get(ApiConfig.destinations);
    if (res['success'] == true && res['data'] != null) {
      _destinations = (res['data'] as List).map((d) => DestinationModel.fromJson(d)).toList();
    } else if (_destinations.isEmpty) {
      _destinations = _getDefaultDestinations();
    }
    notifyListeners();
  }

  Future<void> fetchFavorites() async {
    final res = await ApiService.get(ApiConfig.favorites);
    if (res['success'] == true && res['data'] != null) {
      _favorites = (res['data'] as List).map((v) => VendorModel.fromJson(v)).toList();
    }
    notifyListeners();
  }

  Future<bool> toggleFavorite(int vendorId) async {
    final res = await ApiService.post(ApiConfig.favorites, {'vendor_id': vendorId});
    if (res['success'] == true) {
      await fetchFavorites();
      return true;
    }
    final existingIndex = _favorites.indexWhere((v) => v.id == vendorId);
    if (existingIndex >= 0) {
      _favorites.removeAt(existingIndex);
    } else {
      final vendor = _vendors.firstWhere((v) => v.id == vendorId, orElse: () => _getDefaultVendors().first);
      _favorites.add(vendor);
    }
    notifyListeners();
    return true;
  }

  bool isFavorite(int vendorId) {
    return _favorites.any((v) => v.id == vendorId);
  }

  // --- Seed Data Helpers for Offline Preview ---
  List<CategoryModel> _getDefaultCategories() {
    return [
      CategoryModel(id: 1, name: 'Venues', icon: 'location_city', description: 'Royal Palaces, Hotels & Gardens'),
      CategoryModel(id: 2, name: 'Photographers', icon: 'camera_alt', description: 'Candid Photography & Cinematography'),
      CategoryModel(id: 3, name: 'Caterers', icon: 'restaurant', description: 'Gourmet Indian & International Cuisine'),
      CategoryModel(id: 4, name: 'Makeup Artists', icon: 'brush', description: 'Bridal & Party Makeup Professionals'),
      CategoryModel(id: 5, name: 'Decorators', icon: 'palette', description: 'Theme & Stage Floral Decorators'),
      CategoryModel(id: 6, name: 'Bridal Wear', icon: 'checkroom', description: 'Designer Lehengas & Sarees'),
      CategoryModel(id: 7, name: 'DJs & Music', icon: 'music_note', description: 'Live Bands, DJs & Sound Systems'),
      CategoryModel(id: 8, name: 'Mehndi Artists', icon: 'dry_cleaning', description: 'Traditional & Bridal Mehndi'),
    ];
  }

  List<VendorModel> _getDefaultVendors() {
    return [
      VendorModel(
        id: 1,
        userId: 2,
        businessName: 'The Grand Palace Resort',
        categoryId: 1,
        categoryName: 'Venues',
        city: 'Mumbai',
        address: '123 Beach Road, Bandra, Mumbai',
        startingPrice: 150000.0,
        rating: 4.9,
        totalReviews: 48,
        status: 'approved',
        profileImage: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?auto=format&fit=crop&w=800&q=80',
        description: 'Luxurious beachfront wedding venue featuring majestic banquet halls, lush gardens, and premium catering facilities.',
      ),
      VendorModel(
        id: 2,
        userId: 3,
        businessName: 'Royal Snaps Studio',
        categoryId: 2,
        categoryName: 'Photographers',
        city: 'Delhi',
        address: '45 Connaught Place, New Delhi',
        startingPrice: 45000.0,
        rating: 4.8,
        totalReviews: 36,
        status: 'approved',
        profileImage: 'https://images.unsplash.com/photo-1537633552985-df8429e8048b?auto=format&fit=crop&w=800&q=80',
        description: 'Award-winning wedding photography team capturing magical moments with cinematic brilliance.',
      ),
      VendorModel(
        id: 3,
        userId: 4,
        businessName: 'Imperial Feast Catering',
        categoryId: 3,
        categoryName: 'Caterers',
        city: 'Jaipur',
        address: '78 Palace Road, Jaipur',
        startingPrice: 85000.0,
        rating: 4.7,
        totalReviews: 29,
        status: 'approved',
        profileImage: 'https://images.unsplash.com/photo-1555244162-803834f70033?auto=format&fit=crop&w=800&q=80',
        description: 'Royal Rajasthani, North Indian, and Multi-cuisine gourmet dining experience for grand weddings.',
      ),
      VendorModel(
        id: 4,
        userId: 5,
        businessName: 'Glamour Glow Studio',
        categoryId: 4,
        categoryName: 'Makeup Artists',
        city: 'Mumbai',
        address: '14 Juhu Tara Road, Mumbai',
        startingPrice: 25000.0,
        rating: 4.9,
        totalReviews: 52,
        status: 'approved',
        profileImage: 'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?auto=format&fit=crop&w=800&q=80',
        description: 'HD & Airbrush bridal makeup specialist bringing out your timeless beauty on your special day.',
      ),
      VendorModel(
        id: 5,
        userId: 6,
        businessName: 'Dream Flora Decorators',
        categoryId: 5,
        categoryName: 'Decorators',
        city: 'Udaipur',
        address: '89 Lakeview Enclave, Udaipur',
        startingPrice: 120000.0,
        rating: 4.8,
        totalReviews: 41,
        status: 'approved',
        profileImage: 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?auto=format&fit=crop&w=800&q=80',
        description: 'Exquisite theme styling, royal stage mandaps, and exotic floral arrangements.',
      ),
    ];
  }

  List<DestinationModel> _getDefaultDestinations() {
    return [
      DestinationModel(
        id: 1,
        title: 'Udaipur Royal Palaces',
        location: 'Udaipur, Rajasthan',
        description: 'The City of Lakes & Royal Palaces for unforgettable heritage weddings.',
        imageUrl: 'https://images.unsplash.com/photo-1599661046827-dacff0c0f09a?auto=format&fit=crop&w=800&q=80',
        startingPrice: 2500000.0,
        isPopular: true,
        packages: [
          DestinationPackage(
            id: 1,
            packageName: 'Lake Palace Heritage Package',
            price: 2500000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Palace Venue Rental', 'Royal Feast Catering for 300 Guests', 'Folk Dance & Sangeet Decor', '2 Night Luxury Suite Stay'],
          )
        ],
      ),
      DestinationModel(
        id: 2,
        title: 'Jaipur Pink City Heritage',
        location: 'Jaipur, Rajasthan',
        description: 'The Pink City Royal Heritage with fort venues and grand elephant welcome.',
        imageUrl: 'https://images.unsplash.com/photo-1477587458883-47145ed94245?auto=format&fit=crop&w=800&q=80',
        startingPrice: 2000000.0,
        isPopular: true,
        packages: [
          DestinationPackage(
            id: 2,
            packageName: 'Fort Heritage Royal Package',
            price: 2000000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Fort Mandap Rental', 'Traditional Shehnai Welcome', 'Royal Buffet Catering', 'Decor & Lighting'],
          )
        ],
      ),
      DestinationModel(
        id: 3,
        title: 'Goa Sunset Beach Wedding',
        location: 'Goa Beachfront',
        description: 'Beachfront Sunset Weddings with ocean view mandap and beach party.',
        imageUrl: 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?auto=format&fit=crop&w=800&q=80',
        startingPrice: 1800000.0,
        isPopular: true,
        packages: [
          DestinationPackage(
            id: 3,
            packageName: 'Sunset Beachfront Package',
            price: 1800000.0,
            duration: '2 Days / 2 Nights',
            inclusions: ['Beach Altar & Floral Mandap', 'Seafood & Cocktail Bar', 'Live Acoustic Band', 'Beach DJ Night'],
          )
        ],
      ),
      DestinationModel(
        id: 4,
        title: 'Kerala Backwater Houseboat',
        location: 'Alleppey, Kerala',
        description: 'Serene backwater weddings with houseboat processions & traditional Sadya feast.',
        imageUrl: 'https://images.unsplash.com/photo-1602216056096-3b40cc0c9944?auto=format&fit=crop&w=800&q=80',
        startingPrice: 1600000.0,
        isPopular: true,
        packages: [
          DestinationPackage(
            id: 4,
            packageName: 'Backwater Luxury Houseboat Experience',
            price: 1600000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Luxury Houseboat Bride Entry', 'Lakeside Floral Mandap', 'Traditional Kerala Sadya Feast', 'Kathakali & Chenda Melam Performance'],
          )
        ],
      ),
      DestinationModel(
        id: 5,
        title: 'Mussoorie Cloud Misty Hills',
        location: 'Mussoorie, Uttarakhand',
        description: 'Romantic hill station wedding surrounded by pine valleys and Himalayan sunsets.',
        imageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80',
        startingPrice: 1900000.0,
        isPopular: true,
        packages: [
          DestinationPackage(
            id: 5,
            packageName: 'Himalayan Ridge Royal Wedding',
            price: 1900000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Pine Ridge Valley Outdoor Mandap', 'Cozy Bonfire & Acoustic Night', 'Himalayan Gourmet Buffet', 'Luxury Mountain Resort Stay for 150 Guests'],
          )
        ],
      ),
      DestinationModel(
        id: 6,
        title: 'Jodhpur Mehrangarh Fort',
        location: 'Jodhpur, Rajasthan',
        description: 'Grand fort celebration with royal cannons, desert dune pre-wedding gala, and illuminations.',
        imageUrl: 'https://images.unsplash.com/photo-1599661046827-dacff0c0f09a?auto=format&fit=crop&w=800&q=80',
        startingPrice: 2800000.0,
        isPopular: true,
        packages: [
          DestinationPackage(
            id: 6,
            packageName: 'Mehrangarh Fort & Royal Courtyard',
            price: 2800000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Fort Rampart Fireworks & Illumination', 'Royal Marwari Feast Catering', 'Desert Safari Sangeet Party', 'Vintage Car Groom Procession'],
          )
        ],
      ),
      DestinationModel(
        id: 7,
        title: 'Andaman Crystal Beach Paradise',
        location: 'Havelock Island, Andaman',
        description: 'Exotic island weddings featuring turquoise waters, coral beach ceremonies, and beach BBQ.',
        imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80',
        startingPrice: 2200000.0,
        isPopular: true,
        packages: [
          DestinationPackage(
            id: 7,
            packageName: 'Exotic Island Coral Paradise',
            price: 2200000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Private Coral Beach Mandap', 'Seafood & Tropical Barbecue', 'Speedboat Guest Transfers', 'Scuba Pre-Wedding Photography Session'],
          )
        ],
      ),
      DestinationModel(
        id: 8,
        title: 'Rishikesh Holy Ganges Retreat',
        location: 'Rishikesh, Uttarakhand',
        description: 'Spiritual and serene riverside wedding with traditional Vedic chants and Ganga Aarti ceremony.',
        imageUrl: 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?auto=format&fit=crop&w=800&q=80',
        startingPrice: 1500000.0,
        isPopular: false,
        packages: [
          DestinationPackage(
            id: 8,
            packageName: 'Vedic Riverside Ganga Blessing',
            price: 1500000.0,
            duration: '2 Days / 2 Nights',
            inclusions: ['Ganga Ghat Floral Mandap', 'Vedic Priest & Live Shehnai Ensemble', 'Pure Sattvik Organic Feast', 'Evening Ganga Aarti Celebration'],
          )
        ],
      ),
      DestinationModel(
        id: 9,
        title: 'Statue of Unity Tent City',
        location: 'Kevadia, Gujarat',
        description: 'Grand Narmada riverfront wedding surrounded by Vindhyachal hills and luxury tented resorts.',
        imageUrl: 'https://images.unsplash.com/photo-1599661046827-dacff0c0f09a?auto=format&fit=crop&w=800&q=80',
        startingPrice: 1700000.0,
        isPopular: true,
        packages: [
          DestinationPackage(
            id: 9,
            packageName: 'Narmada Royal Tent City Experience',
            price: 1700000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Grand Narmada Riverfront Mandap', 'Luxury AC Tent Stay for 150 Guests', 'Authentic Gujarati Thali & Global Buffet', 'Laser Light Show & Sangeet Setup'],
          )
        ],
      ),
      DestinationModel(
        id: 10,
        title: 'Rann of Kutch White Desert',
        location: 'Kutch, Gujarat',
        description: 'Enchanting white desert full-moon mandap under starry skies with Kutchi folk music.',
        imageUrl: 'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?auto=format&fit=crop&w=800&q=80',
        startingPrice: 2100000.0,
        isPopular: true,
        packages: [
          DestinationPackage(
            id: 10,
            packageName: 'Kutch Moonlit White Desert Package',
            price: 2100000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['White Desert Glass Mandap', 'Camel Safari Procession for Groom', 'Kutchi Garba & Folk Night', 'Traditional Kutchi Buffet & Handicrafts'],
          )
        ],
      ),
      DestinationModel(
        id: 11,
        title: 'Gir Forest Eco Resort',
        location: 'Sasan Gir, Gujarat',
        description: 'Royal wilderness wedding surrounded by lush teak forests & luxury jungle safari lodges.',
        imageUrl: 'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?auto=format&fit=crop&w=800&q=80',
        startingPrice: 1650000.0,
        isPopular: true,
        packages: [
          DestinationPackage(
            id: 11,
            packageName: 'Gir Lion Wilderness Eco Package',
            price: 1650000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Jungle Canopy Floral Mandap', 'Open-Air Campfire Acoustic Night', 'Organic Kathiyawadi & Continental Feast', 'Safari Tour for Wedding Guests'],
          )
        ],
      ),
      DestinationModel(
        id: 12,
        title: 'Dwarka Ocean Temple & Beach',
        location: 'Dwarka, Gujarat',
        description: 'Sacred coastal temple blessing ceremony with Arabian Sea sunset mandap and seaside banquet.',
        imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80',
        startingPrice: 1400000.0,
        isPopular: false,
        packages: [
          DestinationPackage(
            id: 12,
            packageName: 'Dwarka Coastal Holy Vows Package',
            price: 1400000.0,
            duration: '2 Days / 2 Nights',
            inclusions: ['Seaside Temple Altar Setup', 'Traditional Shehnai & Vedic Chants', 'Pure Jain & Pure Veg Feast', 'Sunset Beach Reception'],
          )
        ],
      ),
      DestinationModel(
        id: 13,
        title: 'Vadodara Laxmi Vilas Palace',
        location: 'Vadodara, Gujarat',
        description: 'Majestic Indo-Saracenic royal palace lawns four times the size of Buckingham Palace.',
        imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?auto=format&fit=crop&w=800&q=80',
        startingPrice: 3000000.0,
        isPopular: true,
        packages: [
          DestinationPackage(
            id: 13,
            packageName: 'Laxmi Vilas Royal Palace Grandeur',
            price: 3000000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Palace Courtyard Mandap Rental', 'Royal Maratha Elephant Welcome', 'Lavish 50+ Item Gourmet Spread', 'Chandelier Lighting & Royal Guard'],
          )
        ],
      ),
      DestinationModel(
        id: 14,
        title: 'Surat Tapi Riverfront Resort',
        location: 'Surat, Gujarat',
        description: 'Modern riverfront resort with diamond-inspired decor, floating stage & lavish Surti sweets.',
        imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&q=80',
        startingPrice: 1850000.0,
        isPopular: true,
        packages: [
          DestinationPackage(
            id: 14,
            packageName: 'Surat Tapi Riverfront Diamond Package',
            price: 1850000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Tapi Riverfront Floating Stage', 'Surti Gourmet Catered Feast', 'Grand LED Sangeet Stage', 'Luxury Suite Stay for Family'],
          )
        ],
      ),
      DestinationModel(
        id: 15,
        title: 'Diu Island Portuguese Coast',
        location: 'Diu Coast, Gujarat',
        description: 'Colonial Portuguese fort ruins & quiet sandy beach mandap with European coastal charm.',
        imageUrl: 'https://images.unsplash.com/photo-1510414842594-a61c69b5ae57?auto=format&fit=crop&w=800&q=80',
        startingPrice: 1750000.0,
        isPopular: false,
        packages: [
          DestinationPackage(
            id: 15,
            packageName: 'Diu Fort Colonial Beach Package',
            price: 1750000.0,
            duration: '2 Days / 2 Nights',
            inclusions: ['Cliffside Sea View Mandap', 'Beachside Sunset Bar & Grill', 'Live Jazz & Portuguese Music', 'Vintage Car Bride Entry'],
          )
        ],
      ),
      DestinationModel(
        id: 16,
        title: 'Shimla Heritage Snow Ridge',
        location: 'Shimla, Himachal Pradesh',
        description: 'Colonial luxury estate wedding amidst pine valleys & snow-capped Himalayan peaks.',
        imageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80',
        startingPrice: 1850000.0,
        isPopular: true,
        packages: [
          DestinationPackage(
            id: 16,
            packageName: 'Shimla Colonial Snow Estate',
            price: 1850000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Pine Ridge Valley Outdoor Mandap', 'Cozy Bonfire & Acoustic Night', 'Himachali Dham Gourmet Buffet', 'Luxury Mountain Resort Stay'],
          )
        ],
      ),
      DestinationModel(
        id: 17,
        title: 'Manali Alpine Valley Resort',
        location: 'Manali, Himachal Pradesh',
        description: 'Alpine riverfront mandap with pine forest backdrop, snow peaks, and cozy chalets.',
        imageUrl: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=800&q=80',
        startingPrice: 1750000.0,
        isPopular: true,
        packages: [
          DestinationPackage(
            id: 17,
            packageName: 'Manali Alpine Riverfront Delight',
            price: 1750000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Beas Riverbank Floral Mandap', 'Snow Valley Pre-Wedding Shoot', 'Multi-Cuisine Buffet', 'Chalet Lodging for Guests'],
          )
        ],
      ),
      DestinationModel(
        id: 18,
        title: 'Srinagar Dal Lake Palace',
        location: 'Srinagar, Kashmir',
        description: 'Paradise wedding on floating Shikaras & Shalimar Bagh Mughal Gardens with saffron feast.',
        imageUrl: 'https://images.unsplash.com/photo-1595815771614-ade9d652a65d?auto=format&fit=crop&w=800&q=80',
        startingPrice: 2600000.0,
        isPopular: true,
        packages: [
          DestinationPackage(
            id: 18,
            packageName: 'Kashmir Mughal Garden & Shikara Royal',
            price: 2600000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Shikara Grand Procession Entry', 'Mughal Garden Floral Mandap', 'Authentic Kashmiri Wazwan Feast', 'Live Rabab & Folk Ensemble'],
          )
        ],
      ),
      DestinationModel(
        id: 19,
        title: 'Amritsar Punjabi Farmhouse',
        location: 'Amritsar, Punjab',
        description: 'Traditional vibrant Punjabi wedding with live Dhol, Gidda dancers & mustard field views.',
        imageUrl: 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?auto=format&fit=crop&w=800&q=80',
        startingPrice: 1550000.0,
        isPopular: true,
        packages: [
          DestinationPackage(
            id: 19,
            packageName: 'Grand Royal Punjabi Farm Package',
            price: 1550000.0,
            duration: '2 Days / 2 Nights',
            inclusions: ['Sarson Field Farmhouse Mandap', 'Live Punjabi Dhol & Bhangra Troupe', 'Amritsari Gourmet Feast', 'Vintage Tractor & Horse Entry'],
          )
        ],
      ),
      DestinationModel(
        id: 20,
        title: 'Mahabaleshwar Foggy Hills',
        location: 'Mahabaleshwar, Maharashtra',
        description: 'Strawberry farm sunset mandap in lush foggy Western Ghats mountain resorts.',
        imageUrl: 'https://images.unsplash.com/photo-1501785888041-af3ef285b470?auto=format&fit=crop&w=800&q=80',
        startingPrice: 1600000.0,
        isPopular: false,
        packages: [
          DestinationPackage(
            id: 20,
            packageName: 'Mahabaleshwar Strawberry Valley Package',
            price: 1600000.0,
            duration: '2 Days / 2 Nights',
            inclusions: ['Strawberry Valley Sunset Lawn', 'Maharashtrian & Continental Buffet', 'Live Saxophone & Acoustic Band', 'Luxury Valley View Rooms'],
          )
        ],
      ),
      DestinationModel(
        id: 21,
        title: 'Alibaug Seaside Private Villa',
        location: 'Alibaug, Maharashtra',
        description: 'Chic beachside villa wedding with speedboat arrival, private infinity pool mandap & lounge.',
        imageUrl: 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?auto=format&fit=crop&w=800&q=80',
        startingPrice: 1950000.0,
        isPopular: true,
        packages: [
          DestinationPackage(
            id: 21,
            packageName: 'Alibaug Speedboat & Villa Glamour',
            price: 1950000.0,
            duration: '2 Days / 2 Nights',
            inclusions: ['Speedboat Entry for Couple', 'Infinity Poolside Mandap', 'Seafood & Global Fusion Buffet', 'Sundowner DJ Party'],
          )
        ],
      ),
      DestinationModel(
        id: 22,
        title: 'Coorg Coffee Estate Haven',
        location: 'Coorg, Karnataka',
        description: 'Misty coffee plantation wedding with Kodava traditions, aromatic garden mandap & lawns.',
        imageUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=800&q=80',
        startingPrice: 1700000.0,
        isPopular: true,
        packages: [
          DestinationPackage(
            id: 22,
            packageName: 'Coorg Plantation Green Haven',
            price: 1700000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Coffee Plantation Open Lawn Mandap', 'Kodava Valaga Music & Dance', 'South Indian & Global Feast', 'Ecolodge Stay for 120 Guests'],
          )
        ],
      ),
      DestinationModel(
        id: 23,
        title: 'Bengaluru Palace Grounds',
        location: 'Bengaluru, Karnataka',
        description: 'Tudor-style royal palace grounds with grand floral arches, vintage carriages & royal dining.',
        imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?auto=format&fit=crop&w=800&q=80',
        startingPrice: 2400000.0,
        isPopular: true,
        packages: [
          DestinationPackage(
            id: 23,
            packageName: 'Bengaluru Tudor Palace Experience',
            price: 2400000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Tudor Palace Lawn Rental', 'Grand Glasshouse Sangeet Stage', 'South & North Gourmet Buffet', 'Royal Carriage Entrance'],
          )
        ],
      ),
      DestinationModel(
        id: 24,
        title: 'Mahabalipuram Shore Beach',
        location: 'Mahabalipuram, Tamil Nadu',
        description: 'UNESCO granite temple backdrop with golden beach Mandap, Carnatic violin & ocean breeze.',
        imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80',
        startingPrice: 1800000.0,
        isPopular: false,
        packages: [
          DestinationPackage(
            id: 24,
            packageName: 'Mahabalipuram Shore Temple Heritage',
            price: 1800000.0,
            duration: '2 Days / 2 Nights',
            inclusions: ['Shore Temple View Beach Mandap', 'Carnatic Live Ensemble & Nadaswaram', 'Traditional Banana Leaf Feast', 'Beachfire Sunset Reception'],
          )
        ],
      ),
      DestinationModel(
        id: 25,
        title: 'Darjeeling Kanchenjunga Estate',
        location: 'Darjeeling, West Bengal',
        description: 'Panoramic views of Mt. Kanchenjunga with colonial tea estate luxury & flower decor.',
        imageUrl: 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?auto=format&fit=crop&w=800&q=80',
        startingPrice: 1600000.0,
        isPopular: false,
        packages: [
          DestinationPackage(
            id: 25,
            packageName: 'Darjeeling Kanchenjunga Tea Resort',
            price: 1600000.0,
            duration: '2 Days / 2 Nights',
            inclusions: ['Tea Estate Valley View Mandap', 'Darjeeling Heritage Toy Train Entry', 'Bengali & Nepalese Gourmet Spread', 'Folk Dance & Acoustic Night'],
          )
        ],
      ),
    ];
  }

  List<BannerModel> _getDefaultBanners() {
    return [
      BannerModel(
        id: 1,
        title: 'Plan Your Royal Wedding',
        imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?auto=format&fit=crop&w=800&q=80',
        linkType: 'vendor',
        linkId: 1,
      ),
      BannerModel(
        id: 2,
        title: 'Destination Wedding Packages',
        imageUrl: 'https://images.unsplash.com/photo-1599661046827-dacff0c0f09a?auto=format&fit=crop&w=800&q=80',
        linkType: 'destination',
        linkId: 1,
      ),
    ];
  }

  List<OfferModel> _getDefaultOffers() {
    return [
      OfferModel(
        id: 1,
        title: 'Early Bird Venue Discount',
        code: 'ROYAL20',
        discountPercentage: 20.0,
        maxDiscount: 10000.0,
        validUntil: '2026-12-31',
      ),
      OfferModel(
        id: 2,
        title: 'Complimentary Pre-wedding Shoot',
        code: 'SNAPFREE',
        discountPercentage: 100.0,
        maxDiscount: 15000.0,
        validUntil: '2026-12-31',
      ),
    ];
  }

  List<PackageModel> _getDefaultPackages() {
    return [
      PackageModel(
        id: 1,
        vendorId: 1,
        title: 'Silver Celebration Package',
        price: 150000.0,
        description: 'Includes main banquet hall for 500 guests, basic stage decor, and sound setup.',
        features: ['Main AC Banquet Hall', 'Basic Floral Stage Decor', 'Standard Lighting & Sound', 'Valet Parking'],
      ),
      PackageModel(
        id: 2,
        vendorId: 1,
        title: 'Royal Gold Wedding Package',
        price: 350000.0,
        description: 'Full venue access, lawn gardens, royal mandap decor, LED screens, and bridal suite.',
        features: ['Lawn + Hall Access (1000 guests)', 'Royal Mandap & Floral Entry', 'HD LED Wall & Stage Lights', 'Complimentary Bridal Suite'],
      ),
    ];
  }

  List<ReviewModel> _getDefaultReviews() {
    return [
      ReviewModel(
        id: 1,
        bookingId: 101,
        customerId: 1,
        vendorId: 1,
        customerName: 'Priya & Rahul',
        rating: 5,
        comment: 'Hosted our grand wedding reception here! The hospitality and decor were magnificent. Highly recommended!',
        createdAt: '2026-08-15',
      ),
      ReviewModel(
        id: 2,
        bookingId: 102,
        customerId: 2,
        vendorId: 1,
        customerName: 'Vikram Mehta',
        rating: 5,
        comment: 'Spacious lawns, excellent management team, and seamless catering arrangement.',
        createdAt: '2026-07-20',
      ),
    ];
  }
}
