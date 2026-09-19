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
    } else {
      // Seed Data Offline Mode: Always query against fresh full seed vendor list
      final allDefault = _getDefaultVendors();
      if (_popularVendors.isEmpty) {
        _popularVendors = List.from(allDefault);
      }

      List<VendorModel> filtered = List.from(allDefault);

      if (categoryId != null && categoryId > 0) {
        filtered = filtered.where((v) => v.categoryId == categoryId).toList();
      }
      if (city != null && city.isNotEmpty && city != 'All') {
        filtered = filtered.where((v) =>
          v.city.toLowerCase().contains(city.toLowerCase()) ||
          (v.address ?? '').toLowerCase().contains(city.toLowerCase())
        ).toList();
      }
      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        filtered = filtered.where((v) =>
          v.businessName.toLowerCase().contains(q) ||
          (v.categoryName ?? '').toLowerCase().contains(q) ||
          v.city.toLowerCase().contains(q) ||
          (v.description ?? '').toLowerCase().contains(q)
        ).toList();
      }
      if (minRating != null && minRating > 0) {
        filtered = filtered.where((v) => v.rating >= minRating).toList();
      }

      _vendors = filtered;
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
      CategoryModel(id: 6, name: 'Bridal Wear', icon: 'checkroom', description: 'Designer Lehengas, Sarees & Gowns'),
      CategoryModel(id: 7, name: 'Groom Wear', icon: 'styler', description: 'Royal Sherwanis, Tuxedos & Indo-Western'),
      CategoryModel(id: 8, name: 'DJs & Music', icon: 'music_note', description: 'Live Bands, DJs & Sound Systems'),
      CategoryModel(id: 9, name: 'Mehndi Artists', icon: 'back_hand', description: 'Traditional & Bridal Organic Mehndi'),
      CategoryModel(id: 10, name: 'Wedding Planners', icon: 'event', description: 'Full Service & Luxury Event Coordination'),
      CategoryModel(id: 11, name: 'Invitations & Cards', icon: 'card_giftcard', description: 'Digital, Boxed & Traditional E-Invites'),
      CategoryModel(id: 12, name: 'Jewelry & Accessories', icon: 'diamond', description: 'Kundan, Polki & Gold Wedding Jewelry'),
      CategoryModel(id: 13, name: 'Pandits & Priests', icon: 'auto_awesome', description: 'Vedic Pandits, Pujaris & Ritual Officiants'),
      CategoryModel(id: 14, name: 'Choreographers', icon: 'directions_run', description: 'Sangeet & Couple Dance Choreography'),
      CategoryModel(id: 15, name: 'Cakes & Sweets', icon: 'cake', description: 'Custom Wedding Cakes & Traditional Mithai'),
      CategoryModel(id: 16, name: 'Bar & Mixologists', icon: 'local_bar', description: 'Craft Cocktails, Bar Setups & Bartenders'),
      CategoryModel(id: 17, name: 'Vintage Cars', icon: 'directions_car', description: 'Vintage Cars, Limousines & Guest Buses'),
      CategoryModel(id: 18, name: 'Gifts & Favors', icon: 'gift', description: 'Custom Return Gifts & Luxury Hampers'),
      CategoryModel(id: 19, name: 'Honeymoon Tours', icon: 'flight_takeoff', description: 'Romantic Luxury Tours & Island Resorts'),
      CategoryModel(id: 20, name: 'Entertainment', icon: 'celebration', description: 'Folk Dancers, Shehnai Players & Live Acts'),
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
        id: 21,
        userId: 22,
        businessName: 'Stories by Joseph Radhik',
        categoryId: 2,
        categoryName: 'Photographers',
        city: 'Mumbai',
        address: 'Bandra West, Mumbai',
        startingPrice: 120000.0,
        rating: 5.0,
        totalReviews: 95,
        status: 'approved',
        profileImage: 'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=800&q=80',
        description: 'Celebrity candid wedding photography & cinematic films capturing royal emotions.',
      ),
      VendorModel(
        id: 22,
        userId: 23,
        businessName: 'Mewar Royal Tales Photography',
        categoryId: 2,
        categoryName: 'Photographers',
        city: 'Udaipur',
        address: 'Lake Palace Road, Udaipur',
        startingPrice: 65000.0,
        rating: 4.9,
        totalReviews: 44,
        status: 'approved',
        profileImage: 'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?auto=format&fit=crop&w=800&q=80',
        description: 'Palace wedding pre-wedding portraiture, drone videography, and heritage album design.',
      ),
      VendorModel(
        id: 23,
        userId: 24,
        businessName: 'Pink City Shutterbug Studio',
        categoryId: 2,
        categoryName: 'Photographers',
        city: 'Jaipur',
        address: 'Amer Fort Road, Jaipur',
        startingPrice: 50000.0,
        rating: 4.8,
        totalReviews: 39,
        status: 'approved',
        profileImage: 'https://images.unsplash.com/photo-1537633552985-df8429e8048b?auto=format&fit=crop&w=800&q=80',
        description: 'Traditional Marwari baraat coverage, candid photography, and 4K wedding highlight trailers.',
      ),
      VendorModel(
        id: 24,
        userId: 25,
        businessName: 'Sunset Ocean Lens Goa',
        categoryId: 2,
        categoryName: 'Photographers',
        city: 'Goa',
        address: 'Calangute, North Goa',
        startingPrice: 55000.0,
        rating: 4.9,
        totalReviews: 51,
        status: 'approved',
        profileImage: 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?auto=format&fit=crop&w=800&q=80',
        description: 'Beachfront sunset pre-wedding shoots, underwater couple portraits & destination wedding films.',
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
        id: 26,
        userId: 27,
        businessName: 'Ambika Pillai Bridal Beauty',
        categoryId: 4,
        categoryName: 'Makeup Artists',
        city: 'Delhi',
        address: 'South Extension, New Delhi',
        startingPrice: 35000.0,
        rating: 5.0,
        totalReviews: 83,
        status: 'approved',
        profileImage: 'https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&fit=crop&w=800&q=80',
        description: 'Luxury HD airbrush bridal makeup, hair styling & saree draping for royal weddings.',
      ),
      VendorModel(
        id: 27,
        userId: 28,
        businessName: 'Royal Rajputi Glam by Parul',
        categoryId: 4,
        categoryName: 'Makeup Artists',
        city: 'Jaipur',
        address: 'C Scheme, Jaipur',
        startingPrice: 28000.0,
        rating: 4.9,
        totalReviews: 47,
        status: 'approved',
        profileImage: 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=800&q=80',
        description: 'Specialist in traditional Rajasthani royal bridal looks, borla hair styling & long-lasting glam.',
      ),
      VendorModel(
        id: 28,
        userId: 29,
        businessName: 'Lakecity Bridal Elegance',
        categoryId: 4,
        categoryName: 'Makeup Artists',
        city: 'Udaipur',
        address: 'Saheli Marg, Udaipur',
        startingPrice: 30000.0,
        rating: 4.8,
        totalReviews: 35,
        status: 'approved',
        profileImage: 'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?auto=format&fit=crop&w=800&q=80',
        description: 'Destination wedding bridal packages, cocktail party looks & groom makeup touchups.',
      ),
      VendorModel(
        id: 29,
        userId: 30,
        businessName: 'Oceana Waterproof Bridal Studio',
        categoryId: 4,
        categoryName: 'Makeup Artists',
        city: 'Goa',
        address: 'Panjim, Goa',
        startingPrice: 32000.0,
        rating: 4.9,
        totalReviews: 40,
        status: 'approved',
        profileImage: 'https://images.unsplash.com/photo-1516975080664-ed2fc6a32937?auto=format&fit=crop&w=800&q=80',
        description: 'Waterproof beach wedding makeup, humid-proof hair setting & glowing tropical bride glam.',
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
      VendorModel(
        id: 6,
        userId: 7,
        businessName: 'Sabyasachi Bridal Couture',
        categoryId: 6,
        categoryName: 'Bridal Wear',
        city: 'Mumbai',
        address: 'Kala Ghoda, Fort, Mumbai',
        startingPrice: 180000.0,
        rating: 5.0,
        totalReviews: 88,
        status: 'approved',
        profileImage: 'https://images.unsplash.com/photo-1595815771614-ade9d652a65d?auto=format&fit=crop&w=800&q=80',
        description: 'Iconic designer bridal lehengas, heritage silk sarees, and bespoke bridal couture.',
      ),
      VendorModel(
        id: 7,
        userId: 8,
        businessName: 'Manish Malhotra Royal Groom',
        categoryId: 7,
        categoryName: 'Groom Wear',
        city: 'Delhi',
        address: 'Mehrauli, New Delhi',
        startingPrice: 95000.0,
        rating: 4.9,
        totalReviews: 64,
        status: 'approved',
        profileImage: 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?auto=format&fit=crop&w=800&q=80',
        description: 'Handcrafted royal sherwanis, embroidered bandhgala suits, tuxedos & stole accessories.',
      ),
      VendorModel(
        id: 8,
        userId: 9,
        businessName: 'Beats & Bass Live DJ Ensemble',
        categoryId: 8,
        categoryName: 'DJs & Music',
        city: 'Goa',
        address: 'Baga Road, North Goa',
        startingPrice: 35000.0,
        rating: 4.8,
        totalReviews: 45,
        status: 'approved',
        profileImage: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?auto=format&fit=crop&w=800&q=80',
        description: 'High-energy wedding DJ, live brass bands, LED percussionists & intelligent lighting setups.',
      ),
      VendorModel(
        id: 9,
        userId: 10,
        businessName: 'Veena Nagda Bridal Mehndi',
        categoryId: 9,
        categoryName: 'Mehndi Artists',
        city: 'Mumbai',
        address: 'Juhu Scheme, Mumbai',
        startingPrice: 15000.0,
        rating: 4.9,
        totalReviews: 76,
        status: 'approved',
        profileImage: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=800&q=80',
        description: 'Celebrity bridal henna artist specializing in intricate Marwari, Arabic & portrait Mehndi designs.',
      ),
      VendorModel(
        id: 10,
        userId: 11,
        businessName: 'Vogue Weddings & Events',
        categoryId: 10,
        categoryName: 'Wedding Planners',
        city: 'Udaipur',
        address: 'Fatehpura Main Road, Udaipur',
        startingPrice: 200000.0,
        rating: 4.9,
        totalReviews: 58,
        status: 'approved',
        profileImage: 'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=800&q=80',
        description: 'Turnkey luxury wedding planning, destination management, guest logistics & royal decor concept designs.',
      ),
      VendorModel(
        id: 11,
        userId: 12,
        businessName: 'Royal Crafts Wedding Cards & E-Invites',
        categoryId: 11,
        categoryName: 'Invitations & Cards',
        city: 'Jaipur',
        address: 'Johari Bazaar, Jaipur',
        startingPrice: 12000.0,
        rating: 4.8,
        totalReviews: 33,
        status: 'approved',
        profileImage: 'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?auto=format&fit=crop&w=800&q=80',
        description: 'Bespoke boxed invitation suites, wax seal scrolls, 3D animated video invitations, and luxury stationery.',
      ),
      VendorModel(
        id: 12,
        userId: 13,
        businessName: 'Tanishq Kundan & Polki Fine Jewelry',
        categoryId: 12,
        categoryName: 'Jewelry & Accessories',
        city: 'Ahmedabad',
        address: 'CG Road, Ahmedabad',
        startingPrice: 150000.0,
        rating: 4.9,
        totalReviews: 92,
        status: 'approved',
        profileImage: 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?auto=format&fit=crop&w=800&q=80',
        description: 'Certified uncut diamond polki chokers, temple gold jewelry sets, maang tikka, and bridal matha patti.',
      ),
      VendorModel(
        id: 13,
        userId: 14,
        businessName: 'Pandit Ramcharan Shastri & Vedic Ensemble',
        categoryId: 13,
        categoryName: 'Pandits & Priests',
        city: 'Varanasi',
        address: 'Dashashwamedh Ghat Road, Varanasi',
        startingPrice: 11000.0,
        rating: 5.0,
        totalReviews: 67,
        status: 'approved',
        profileImage: 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?auto=format&fit=crop&w=800&q=80',
        description: 'Experienced Vedic scholars performing authentic Marwari, Gujarati, Punjabi & South Indian wedding rituals with live chanting.',
      ),
      VendorModel(
        id: 14,
        userId: 15,
        businessName: 'Bollywood Steps Sangeet Choreography',
        categoryId: 14,
        categoryName: 'Choreographers',
        city: 'Mumbai',
        address: 'Andheri West, Mumbai',
        startingPrice: 30000.0,
        rating: 4.8,
        totalReviews: 49,
        status: 'approved',
        profileImage: 'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?auto=format&fit=crop&w=800&q=80',
        description: 'Sangeet night concept choreography, couple entry dance routines, and flashmob rehearsals for wedding families.',
      ),
      VendorModel(
        id: 15,
        userId: 16,
        businessName: 'The Royal Bakery & Gourmet Mithai',
        categoryId: 15,
        categoryName: 'Cakes & Sweets',
        city: 'Delhi',
        address: 'Khan Market, New Delhi',
        startingPrice: 8000.0,
        rating: 4.9,
        totalReviews: 54,
        status: 'approved',
        profileImage: 'https://images.unsplash.com/photo-1535141192574-5d4897c13136?auto=format&fit=crop&w=800&q=80',
        description: 'Multi-tiered floral fondant wedding cakes, artisanal macaron towers, and handcrafted silver foil dry fruit mithai hampers.',
      ),
      VendorModel(
        id: 16,
        userId: 17,
        businessName: 'Cocktail Craft Bar & Flaring Legends',
        categoryId: 16,
        categoryName: 'Bar & Mixologists',
        city: 'Goa',
        address: 'Panaji Riverfront, Goa',
        startingPrice: 40000.0,
        rating: 4.9,
        totalReviews: 42,
        status: 'approved',
        profileImage: 'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?auto=format&fit=crop&w=800&q=80',
        description: 'International flair bartenders, molecular cocktail counters, personalized smoke infusion bars, and luxury wine cellars.',
      ),
      VendorModel(
        id: 17,
        userId: 18,
        businessName: 'Vintage Wheels Baraat Car Rentals',
        categoryId: 17,
        categoryName: 'Vintage Cars',
        city: 'Udaipur',
        address: 'City Palace Road, Udaipur',
        startingPrice: 25000.0,
        rating: 4.8,
        totalReviews: 38,
        status: 'approved',
        profileImage: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=800&q=80',
        description: 'Restored 1930s Rolls Royce, vintage convertibles, open-top royal carriages, and luxury Mercedes buses for wedding guests.',
      ),
      VendorModel(
        id: 18,
        userId: 19,
        businessName: 'Aura Luxury Return Gifts & Hampers',
        categoryId: 18,
        categoryName: 'Gifts & Favors',
        city: 'Surat',
        address: 'Ghod Dod Road, Surat',
        startingPrice: 15000.0,
        rating: 4.8,
        totalReviews: 31,
        status: 'approved',
        profileImage: 'https://images.unsplash.com/photo-1549465220-1a8b9238cd48?auto=format&fit=crop&w=800&q=80',
        description: 'Silver plated puja thalis, scented soy candle hampers, gourmet dry fruit boxes, and customized guest welcome kits.',
      ),
      VendorModel(
        id: 19,
        userId: 20,
        businessName: 'Escapes Luxury Honeymoon & Island Tours',
        categoryId: 19,
        categoryName: 'Honeymoon Tours',
        city: 'Mumbai',
        address: 'Nariman Point, Mumbai',
        startingPrice: 120000.0,
        rating: 4.9,
        totalReviews: 61,
        status: 'approved',
        profileImage: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80',
        description: 'Tailor-made overwater villa itineraries in Maldives, Swiss Alps chalets, Bali infinity pool villas & romantic cruises.',
      ),
      VendorModel(
        id: 20,
        userId: 21,
        businessName: 'Manganiyar Folk Troupe & Shehnai Masters',
        categoryId: 20,
        categoryName: 'Entertainment',
        city: 'Jaipur',
        address: 'Amer Road, Jaipur',
        startingPrice: 45000.0,
        rating: 5.0,
        totalReviews: 55,
        status: 'approved',
        profileImage: 'https://images.unsplash.com/photo-1465847899084-d164df4dedc6?auto=format&fit=crop&w=800&q=80',
        description: 'Authentic Rajasthani Ghoomar dancers, Kutchi Garba ensembles, Punjabi Dhol troupes, and Shehnai welcoming masters.',
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
        id: 9,
        title: 'Statue of Unity Tent City',
        location: 'Kevadia, Gujarat',
        description: 'Grand Narmada riverfront wedding surrounded by Vindhyachal hills and luxury tented resorts.',
        imageUrl: 'https://images.unsplash.com/photo-1599661046827-dacff0c0f09a?auto=format&fit=crop&w=800&q=80',
        startingPrice: 1700000.0,
        isPopular: true,
        packages: [
          DestinationPackage(
            id: 901,
            packageName: 'Narmada Royal Tent City 1 Experience',
            price: 1700000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Grand Narmada Riverfront Mandap', 'Luxury AC Tent Stay for 150 Guests', 'Authentic Gujarati Thali & Global Buffet', 'Laser Light Show & Sangeet Setup'],
          ),
          DestinationPackage(
            id: 902,
            packageName: 'Unity Village Eco-Cottage Wedding Package',
            price: 1500000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Nature Mountain Lawn Mandap', 'Luxury Cottages Stay for 120 Guests', 'Organic Farm-to-Table Catering', 'Folk Garba & Bonfire Sangeet'],
          ),
          DestinationPackage(
            id: 903,
            packageName: 'Vivanta Ekta Nagar 5-Star Grand Gala',
            price: 2200000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Royal Ballroom & Riverfront Deck', '5-Star Luxury Suites for 200 Guests', 'Multi-Catering Gourmet Feast', 'Helipad Arrival & Laser Show'],
          ),
          DestinationPackage(
            id: 904,
            packageName: 'Villa Euphoria Private Villa Sanctuary',
            price: 1650000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Private Villa Courtyard Mandap', 'Poolside Cocktail & DJ Night', 'Luxury Accommodations for 100 Guests', 'Bridal Suite & Spa Credit'],
          ),
        ],
      ),
      DestinationModel(
        id: 2,
        title: 'Jaipur Pink City Heritage',
        location: 'Jaipur, Rajasthan',
        description: 'The Pink City Royal Heritage with world-class Maharaja palace resorts, fort venues, and grand elephant welcome.',
        imageUrl: 'https://images.unsplash.com/photo-1477587458883-47145ed94245?auto=format&fit=crop&w=800&q=80',
        startingPrice: 2100000.0,
        isPopular: true,
        packages: [
          DestinationPackage(
            id: 201,
            packageName: 'ITC Rajputana Luxury Heritage Gala',
            price: 2500000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Stepwell Pool Mandap & Courtyard', 'Royal Haveli Suites for 150 Guests', 'Traditional Rajasthani Folk Welcome', 'Kaya Kalp Gourmet Catering'],
          ),
          DestinationPackage(
            id: 202,
            packageName: 'Rambagh Palace Taj Grand Maharaja Wedding',
            price: 3500000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['47-Acre Royal Mughal Gardens & Mandap', 'Maharaja Suite Stay for Bride & Groom', 'Royal Elephant & Shehnai Procession', 'Taj Gourmet Fine Dining Feast', 'Vintage Car Groom Entry'],
          ),
          DestinationPackage(
            id: 203,
            packageName: 'Taj Devi Ratn Aravalli Sky Wedding',
            price: 2700000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Geometric Mirror Pavilion Mandap', 'Aravalli Sky Lawns for 180 Guests', 'Jiva Spa & Sunset Cocktail Bar', 'Taj Fine Dining Gastronomy'],
          ),
          DestinationPackage(
            id: 204,
            packageName: 'Hotel Royal Orchid Crystal Ballroom Package',
            price: 2100000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Rooftop Plunge Pool Cocktail Party', 'Crystal Ballroom Stage for 200 Guests', 'Luxury Executive Suites Stay', 'Multi-Cuisine Grand Buffet'],
          ),
          DestinationPackage(
            id: 205,
            packageName: 'The Oberoi Rajvilas Fort Resort Experience',
            price: 3200000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['32-Acre Fort Grounds & Private Pool Villas', 'Royal Tent Stay for 120 Guests', 'Traditional Folk & Kalbelia Sangeet', '5-Star Oberoi Chef Royal Feast'],
          ),
          DestinationPackage(
            id: 206,
            packageName: 'The Raj Palace 300-Year Heritage Gala',
            price: 3100000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Gold Leaf Darbar Hall Mandap', 'Royal Museum Suites for 100 Guests', 'Crystal Chandelier Sangeet Night', 'Royal Charbagh Garden Feast'],
          ),
          DestinationPackage(
            id: 207,
            packageName: 'Sawai Man Mahal Taj Regal Celebration',
            price: 3300000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Regal Rajput Lawns & Altar Setup', 'Private Plunge Pool Suites for Couple', 'Taj Signature Marwari Thali', 'Royal Shehnai Welcome'],
          ),
          DestinationPackage(
            id: 208,
            packageName: 'Buena Vista Aravalli Villa Resort Gala',
            price: 2400000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Private Garden Pool Villas Stay', 'French & Rajasthani Fusion Feast', 'Aravalli Sunset Mandap Lawns', 'Willow Spa Pampering'],
          ),
          DestinationPackage(
            id: 209,
            packageName: 'Anantara Jewel Bagh Royal Wedding',
            price: 2600000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Jewel Garden Lawns & Mandap', 'Fountain Courtyard Sangeet Stage', 'Anantara Signature Hospitality', 'Royal Banquet Feast'],
          ),
          DestinationPackage(
            id: 210,
            packageName: 'Mementos By ITC Hotels Mega Resort Wedding',
            price: 2800000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Colossal Amphitheatre Lawn Mandap', 'Private Villa Clusters for 200 Guests', 'ITC Signature Dining Experience', 'Fireworks & Laser Display'],
          ),
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
            id: 1001,
            packageName: 'Rann Utsav Tent City Royal Darbari Package',
            price: 2100000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['White Desert Glass Mandap', 'Darbari Luxury Suite Stay for 150 Guests', 'Camel Safari Procession for Groom', 'Kutchi Garba & Folk Night', 'Traditional Kutchi Buffet & Handicrafts'],
          ),
          DestinationPackage(
            id: 1002,
            packageName: 'Praveg White Rann Rajwadi Bhunga Experience',
            price: 1950000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Rajwadi AC Bhunga Stay for 120 Guests', 'White Desert Entry & Sunset Mandap', 'Royal Kutchi Feast', 'Folk Music Ensemble'],
          ),
          DestinationPackage(
            id: 1003,
            packageName: 'Rann Visamo Village Heritage Wedding',
            price: 1600000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Traditional Village Sangeet Lawn', 'Luxury Bhungas Stay for 100 Guests', 'Kutchi Handicrafts & Thali Dining', 'Star Gazing & Bonfire Party'],
          ),
        ],
      ),
      DestinationModel(
        id: 3,
        title: 'Goa Sunset Beach Wedding',
        location: 'Goa Beachfront',
        description: 'Beachfront Sunset Weddings with ocean view mandap, tropical palm lawns, and sunset beach party.',
        imageUrl: 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?auto=format&fit=crop&w=800&q=80',
        startingPrice: 2200000.0,
        isPopular: true,
        packages: [
          DestinationPackage(
            id: 301,
            packageName: 'Taj Exotica Mediterranean Sunset Mandap',
            price: 3200000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['56-Acre Palm Lawn Ocean Altar', 'Luxury Pool Villas Stay for Couple', 'Seafood & Sunset Cocktail Bar', 'Live Acoustic Band & Beach DJ'],
          ),
          DestinationPackage(
            id: 302,
            packageName: 'The St. Regis Lagoon & White Sand Beach Gala',
            price: 3600000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['White Sand Beach Mandap Setup', 'Lagoon Suites Stay for 150 Guests', 'St. Regis Butler Service', 'Imperial Goan & Global Buffet'],
          ),
          DestinationPackage(
            id: 303,
            packageName: 'ITC Grand Goa Indo-Portuguese Village Wedding',
            price: 2900000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Arossim Beach Sunset Mandap', 'Multi-Tiered Lagoon Pool Sangeet Party', 'Kaya Kalp Spa Pampering', 'Indo-Portuguese Banquet Feast'],
          ),
          DestinationPackage(
            id: 304,
            packageName: 'The Leela Mobor Beach & Lotus Lagoon Gala',
            price: 3400000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Sal River & Ocean Frontage Altar', 'Royal Portuguese Villa Stay', 'Golf Lawn Cocktail Gala', 'Live Saxophone & Violin Welcome'],
          ),
          DestinationPackage(
            id: 305,
            packageName: 'W Goa Vagator Cliffside DJ Sangeet Party',
            price: 3000000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Vagator Rock Pool Sangeet Stage', 'Chic Luxury Villa Stay for 120 Guests', 'Glamorous Sunset Deck Bar', 'Gourmet World Cuisine Buffet'],
          ),
          DestinationPackage(
            id: 306,
            packageName: 'Grand Hyatt Bambolim Bay Palace Wedding',
            price: 2800000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Bambolim Waterfront Lawn Altar', 'Grand Ballroom Sangeet Stage', 'Palace Rooms Stay for 200 Guests', 'Gourmet Multi-Cuisine Feast'],
          ),
          DestinationPackage(
            id: 307,
            packageName: 'Caravela Varca Beach Golf Resort Gala',
            price: 2500000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Varca White Sand Beach Mandap', '23-Acre Palms Estate Rooms Stay', 'Oceanfront Cocktail Lawn Party', 'Goan & Seafood Barbecue Buffet'],
          ),
          DestinationPackage(
            id: 308,
            packageName: 'Alila Diwa Paddy Field Infinity Pool Wedding',
            price: 2600000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Majorda Beach Sunset Altar', 'Infinity Pool Sangeet Night', 'Contemporary Resort Stay for 150 Guests', 'Spa Alila Couple Wellness'],
          ),
          DestinationPackage(
            id: 309,
            packageName: 'Taj Fort Aguada 16th-Century Cliffside Mandap',
            price: 3100000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Fort Rampart Cliffside Mandap', 'Sinquerim Beach Lawn Reception', 'Taj Heritage Cuisine Feast', 'Goan Brass Band Procession'],
          ),
          DestinationPackage(
            id: 310,
            packageName: 'Taj Holiday Village Terracotta Cottage Celebration',
            price: 2950000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Candolim Beach Sunset Mandap', 'Terracotta Beach Cottage Stay', 'Banyan Tree Garden Cocktail Party', 'Goan Seafood & International Banquet'],
          ),
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
        id: 13,
        title: 'Vadodara Laxmi Vilas Palace',
        location: 'Vadodara, Gujarat',
        description: 'Majestic Indo-Saracenic royal palace lawns four times the size of Buckingham Palace.',
        imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?auto=format&fit=crop&w=800&q=80',
        startingPrice: 3000000.0,
        isPopular: true,
        packages: [
          DestinationPackage(
            id: 1301,
            packageName: 'Laxmi Vilas Royal Palace Grandeur',
            price: 3000000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Palace Courtyard Mandap Rental', 'Royal Maratha Elephant Welcome', 'Lavish 50+ Item Gourmet Spread', 'Chandelier Lighting & Royal Guard'],
          ),
          DestinationPackage(
            id: 1302,
            packageName: 'Vivanta Vadodara 5-Star Luxury Package',
            price: 2400000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['IHCL Grand Ballroom & Poolside Lawn', '120 5-Star Luxury Suites for Guests', 'Multi-Catering International Feast', 'Spa & Pampering for Couple'],
          ),
          DestinationPackage(
            id: 1303,
            packageName: 'Courtyard Marriott Subhanpura Celebration',
            price: 2200000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Marriott Grand Banquet Hall', 'Rooftop Cocktail Sundowner', 'Luxury Suite Stay for Family', 'Signature Marriott Chef Buffet'],
          ),
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
            id: 1401,
            packageName: 'Surat Marriott Tapi Riverfront Luxury Gala',
            price: 2200000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Tapi Riverfront Lawn & Floating Stage', '5-Star Marriott Suites for 150 Guests', 'Surti & International Buffet', 'LED Sangeet Stage & Fireworks'],
          ),
          DestinationPackage(
            id: 1402,
            packageName: 'Le Méridien Surat Airport Garden Package',
            price: 2000000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Expansive Garden Mandap', 'Pure Veg Gourmet Banquet Catering', 'Luxury Accommodation for 120 Guests', 'Airport Guest Transfers'],
          ),
          DestinationPackage(
            id: 1403,
            packageName: 'Courtyard Marriott Pal Gam Celebration',
            price: 1850000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Poolside Sundowner Deck & Mandap', 'Ballroom Reception Stage', 'Luxury Suite Stay for Family', 'Signature Marriott Catering'],
          ),
          DestinationPackage(
            id: 1404,
            packageName: 'Vedik Mega Resort Destination Experience',
            price: 1750000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['10-Acre Resort Grounds Rental', '176 Rooms for Wedding Guests', 'Massive Banquet Hall & Lawn Stage', 'Full Catering & Lighting'],
          ),
        ],
      ),
      DestinationModel(
        id: 6,
        title: 'Jodhpur Mehrangarh Fort',
        location: 'Jodhpur, Rajasthan',
        description: 'Grand fort celebrations, imperial palace resorts, and Mehrangarh fort view mandaps.',
        imageUrl: 'https://images.unsplash.com/photo-1599661046827-dacff0c0f09a?auto=format&fit=crop&w=800&q=80',
        startingPrice: 2400000.0,
        isPopular: true,
        packages: [
          DestinationPackage(
            id: 601,
            packageName: 'Umaid Bhawan Palace Taj Royal Gala',
            price: 4500000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['26-Acre Baradari Lawn Altar Setup', 'Palace Suites Stay for Bride & Groom', 'Royal Cannon Procession & Marwari Band', 'Taj Fine Dining Imperial Feast', 'Vintage Car Groom Entrance'],
          ),
          DestinationPackage(
            id: 602,
            packageName: 'RAAS Jodhpur Mehrangarh Fort View Experience',
            price: 3200000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Uninterrupted Fort View Poolside Mandap', '18th-Century Haveli Suites Stay', 'Stepwell Terrace Sunset Cocktail Party', 'Al Fresco Gourmet Marwari Feast'],
          ),
          DestinationPackage(
            id: 603,
            packageName: 'Ajit Bhawan Heritage Resort Marwari Gala',
            price: 2700000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Historical Stone Courtyard Mandap', 'Royal Marwari Suites for 150 Guests', 'Traditional Kalbelia & Folk Sangeet', 'Royal Rajput Thali Dining'],
          ),
          DestinationPackage(
            id: 604,
            packageName: 'WelcomHeritage Bal Samand Lake Palace Celebration',
            price: 2500000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Private Lakefront Altar & Lawn Mandap', '17th-Century Red Sandstone Palace Stay', 'Peacock & Royal Horse Procession', 'Pomegranate Orchard Buffet'],
          ),
          DestinationPackage(
            id: 605,
            packageName: 'Taj Hari Mahal Royal Arch Wedding',
            price: 2800000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Mughal Arch Ballroom & Pool Lawn', 'Taj Royal Executive Suites Stay', 'Jiva Spa Groom & Bride Pampering', 'Multi-Cuisine Taj Banquet Feast'],
          ),
          DestinationPackage(
            id: 606,
            packageName: 'Indana Palace Jaali Courtyard Gala',
            price: 2600000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Intricate Jaali Courtyard Mandap', 'Royal Palace Rooms for 180 Guests', 'Royal Elephant Welcome Procession', 'Grand Wedding Banquet Buffet'],
          ),
          DestinationPackage(
            id: 607,
            packageName: 'Radisson Jodhpur Rooftop Fort View Package',
            price: 2400000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Rooftop Fort View Sunset Mandap', 'Red Sandstone Haveli Suite Stay', 'Haveli Balcony Cocktail Sangeet', 'Jodhpur Fine Dining Feast'],
          ),
        ],
      ),
      DestinationModel(
        id: 12,
        title: 'Dwarka Ocean Temple & Beach',
        location: 'Dwarka, Gujarat',
        description: 'Sacred coastal temple blessing ceremony with Arabian Sea sunset mandap and seaside banquet.',
        imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80',
        startingPrice: 1400000.0,
        isPopular: true,
        packages: [
          DestinationPackage(
            id: 1201,
            packageName: 'The Fern Sattva 5-Star Eco Resort Celebration',
            price: 1800000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['8-Acre Event Lawn & Altar Mandap', '5-Star Eco Resort Stay for 150 Guests', 'Pure Veg & Jain Gourmet Feast', 'Shehnai Welcome & Vedic Blessing'],
          ),
          DestinationPackage(
            id: 1202,
            packageName: 'Hawthorn Suites Arabian Sea Beach Package',
            price: 1650000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Arabian Sea Beachfront Mandap', 'Luxury Villas for 120 Guests', 'Seaside Sunset Cocktail Party', 'Pure Veg Kathiyawadi Catering'],
          ),
          DestinationPackage(
            id: 1203,
            packageName: 'VITS Devbhumi Temple Blessing Package',
            price: 1400000.0,
            duration: '2 Days / 2 Nights',
            inclusions: ['Temple View Lawn Altar Setup', 'Traditional Shehnai & Chants', 'Pure Jain & Pure Veg Feast', 'Sunset Beach Reception'],
          ),
          DestinationPackage(
            id: 1204,
            packageName: 'Shivrajpur Blue Flag Beach Sunset Mandap',
            price: 1550000.0,
            duration: '2 Days / 2 Nights',
            inclusions: ['Blue Flag White Sand Sunset Mandap', 'Luxury AC Beach Tents', 'Live Acoustic Shehnai', 'Seaside Sunset Feast'],
          ),
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
        id: 15,
        title: 'Diu Island Portuguese Coast',
        location: 'Diu Coast, Gujarat',
        description: 'Colonial Portuguese fort ruins & quiet sandy beach mandap with European coastal charm.',
        imageUrl: 'https://images.unsplash.com/photo-1510414842594-a61c69b5ae57?auto=format&fit=crop&w=800&q=80',
        startingPrice: 1750000.0,
        isPopular: true,
        packages: [
          DestinationPackage(
            id: 1501,
            packageName: 'Praveg Nagoa Beach 5-Star Luxury Package',
            price: 2100000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Direct Nagoa Beach Mandap', '5-Star Beach Chalets for 150 Guests', 'Seafood & Global Barbecue Feast', 'Portuguese Live Music & DJ'],
          ),
          DestinationPackage(
            id: 1502,
            packageName: 'Gateway Diu IHCL SeleQtions Fort Heritage Gala',
            price: 2300000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Diu Fort View Rampart Terrace', 'IHCL Imperial Suites for 120 Guests', 'Fine Dining Gourmet Feast', 'Vintage Car Groom Entry'],
          ),
          DestinationPackage(
            id: 1503,
            packageName: 'The Fern Seaside Nagoa Palm Grove Wedding',
            price: 1850000.0,
            duration: '3 Days / 2 Nights',
            inclusions: ['Coconut Palm Grove Lawn Stage', 'Eco Chalets for 100 Guests', 'Seaside Bar & Grill Buffet', 'Poolside Sundowner Party'],
          ),
          DestinationPackage(
            id: 1504,
            packageName: 'Radhika Beach Resort & Spa Portuguese Package',
            price: 1750000.0,
            duration: '2 Days / 2 Nights',
            inclusions: ['Cliffside Sea View Mandap', 'Beachside Sunset Bar & Grill', 'Live Jazz & Portuguese Music', 'Spa pampering for Couple'],
          ),
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
