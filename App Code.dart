import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;
  runApp(NaogaonBhojbariApp(isLoggedIn: isLoggedIn));
}

// ============================================================================
// DYNAMIC & SMART COLOR PALETTE
// - Deep Emerald Green Header
// - Combined Summary Card: Soft Warm Amber / Pastel Gold + Dark Rounded Border + Rich Green Text
// - Lunch Orders Card: Light Mint / Pastel Green Tinted Card + Green Badge Icon
// - Dinner Orders Card: Light Teal / Pastel Indigo Tinted Card + Night/Moon Icon
// - Status Badges: Soft Pastel Orange/Amber (Pending) & Soft Emerald/Green (Delivered)
// - Customer Order Cards: Light Ivory / Subtle Off-White + Soft Colored Border & Shift Accents
// ============================================================================
class AppColors {
  // Primary Emerald Header & Accents
  static const Color deepEmerald = Color(0xFF064E3B);
  static const Color richGreen = Color(0xFF1B4332);
  static const Color darkForest = Color(0xFF0F291E);
  static const Color vibrantGreen = Color(0xFF047857);

  // Combined Main Summary Card (Soft Warm Amber / Pastel Gold + Dark Border)
  static const Color combinedGoldBg = Color(0xFFFEF3C7);
  static const Color combinedGoldSecondary = Color(0xFFFDE68A);
  static const Color combinedTileBg = Color(0xFFFFFBEB);
  static const Color combinedDarkBorder = Color(0xFF1B4332);
  static const Color warmAmber = Color(0xFFD97706);
  static const Color warmAmberDark = Color(0xFF92400E);

  // Lunch Orders Card (Light Mint / Pastel Green Tinted)
  static const Color lunchMintBg = Color(0xFFECFDF5);
  static const Color lunchMintTile = Color(0xFFD1FAE5);
  static const Color lunchMintBorder = Color(0xFF6EE7B7);
  static const Color lunchBadgeGreen = Color(0xFF059669);

  // Dinner Orders Card (Light Teal / Pastel Indigo Tinted)
  static const Color dinnerIndigoBg = Color(0xFFEEF2FF);
  static const Color dinnerIndigoTile = Color(0xFFE0E7FF);
  static const Color dinnerIndigoBorder = Color(0xFFA5B4FC);
  static const Color dinnerBadgeIndigo = Color(0xFF4338CA);
  static const Color dinnerTealAccent = Color(0xFF0F766E);

  // Status Badges (Pending & Delivered)
  static const Color pendingBadgeBg = Color(0xFFFFEDD5);
  static const Color pendingBadgeBorder = Color(0xFFF59E0B);
  static const Color pendingBadgeText = Color(0xFF9A3412);

  static const Color deliveredBadgeBg = Color(0xFFD1FAE5);
  static const Color deliveredBadgeBorder = Color(0xFF10B981);
  static const Color deliveredBadgeText = Color(0xFF065F46);

  // Customer Order Cards (Light Ivory / Off-White + Soft Colored Borders)
  static const Color appCanvasBg = Color(0xFFF4F1EA);
  static const Color ivoryCardBg = Color(0xFFFFFDF7);
  static const Color ivorySurface = Color(0xFFF7F4EB);
  static const Color softCardBorder = Color(0xFFDED8C8);
}

// ============================================================================
// HELPERS: BANGLA NUMBER & DATE FORMATTERS (DD-MM-YYYY)
// ============================================================================
String toBanglaNumber(dynamic input) {
  final String str = input.toString();
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const bangla = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
  String result = str;
  for (int i = 0; i < english.length; i++) {
    result = result.replaceAll(english[i], bangla[i]);
  }
  return result;
}

String formatDateDDMMYYYY(DateTime date) {
  final dd = date.day.toString().padLeft(2, '0');
  final mm = date.month.toString().padLeft(2, '0');
  final yyyy = date.year.toString();
  return '$dd-$mm-$yyyy';
}

DateTime parseDateDDMMYYYY(String dateStr) {
  try {
    final parts = dateStr.split('-');
    if (parts.length == 3) {
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      return DateTime(year, month, day);
    }
  } catch (_) {}
  return DateTime.now();
}

String getTodayDateString() => formatDateDDMMYYYY(DateTime.now());

String getTomorrowDateString() =>
    formatDateDDMMYYYY(DateTime.now().add(const Duration(days: 1)));

const List<String> kBanglaMonths = [
  'জানুয়ারি',
  'ফেব্রুয়ারি',
  'মার্চ',
  'এপ্রিল',
  'মে',
  'জুন',
  'জুলাই',
  'আগস্ট',
  'সেপ্টেম্বর',
  'অক্টোবর',
  'নভেম্বর',
  'ডিসেম্বর',
];

// ============================================================================
// DATA MODEL 1: DYNAMIC MENU ITEM
// ============================================================================
class MenuItemModel {
  final String id;
  final String name;
  final int price;

  const MenuItemModel({
    required this.id,
    required this.name,
    required this.price,
  });

  MenuItemModel copyWith({String? name, int? price}) {
    return MenuItemModel(
      id: id,
      name: name ?? this.name,
      price: price ?? this.price,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
      };

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    String itemName = json['name']?.toString() ?? '';
    if (itemName == 'রুই মাছ' || itemName == 'রুই মাছ ভুনা') {
      itemName = 'বড় মাছ ভুনা';
    }
    return MenuItemModel(
      id: json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: itemName,
      price: (json['price'] as num?)?.toInt() ?? 0,
    );
  }
}

const List<MenuItemModel> kInitialMenuItems = [
  MenuItemModel(id: 'small_fish', name: 'ছোট মাছ', price: 100),
  MenuItemModel(id: 'big_fish_bhuna', name: 'বড় মাছ ভুনা', price: 110),
  MenuItemModel(id: 'chicken_bhuna', name: 'মুরগি ভুনা', price: 130),
];

// ============================================================================
// DATA MODEL 2: FOOD ORDER (Multi-Shift, Shift-Wise CoD Split, Dynamic Menu)
// ============================================================================
class FoodOrder {
  final String id;
  final String deliveryDate; // DD-MM-YYYY
  final String customerName;
  final String phone;
  final String address;
  final bool includeLunch; // দুপুর
  final bool includeDinner; // রাত
  final Map<String, int> lunchItems;
  final Map<String, int> dinnerItems;
  final int lunchBill;
  final int dinnerBill;
  final int totalBill;
  final int advanceAmount;
  final int lunchCodAmount;
  final int dinnerCodAmount;
  final bool lunchCodPaid;
  final bool dinnerCodPaid;
  final String paymentMethod; // 'বিকাশ' | 'নগদ' | 'ক্যাশ'
  final String specialNote;
  final String lunchDeliveryStatus; // 'Pending' | 'Delivered'
  final String dinnerDeliveryStatus; // 'Pending' | 'Delivered'
  final int createdAt;

  FoodOrder({
    required this.id,
    required this.deliveryDate,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.includeLunch,
    required this.includeDinner,
    required this.lunchItems,
    required this.dinnerItems,
    required this.lunchBill,
    required this.dinnerBill,
    required this.totalBill,
    required this.advanceAmount,
    required this.lunchCodAmount,
    required this.dinnerCodAmount,
    required this.lunchCodPaid,
    required this.dinnerCodPaid,
    required this.paymentMethod,
    required this.specialNote,
    required this.lunchDeliveryStatus,
    required this.dinnerDeliveryStatus,
    required this.createdAt,
  });

  // Total initial Cash on Delivery (Total Bill - Advance)
  int get initialCodTotal => (totalBill - advanceAmount).clamp(0, 9999999);

  // CoD already collected from shift-specific CoD buttons
  int get codCollectedAmount {
    int sum = 0;
    if (includeLunch && lunchCodPaid) sum += lunchCodAmount;
    if (includeDinner && dinnerCodPaid) sum += dinnerCodAmount;
    return sum;
  }

  // Remaining unpaid CoD balance
  int get remainingDue {
    int due = 0;
    if (includeLunch && !lunchCodPaid) due += lunchCodAmount;
    if (includeDinner && !dinnerCodPaid) due += dinnerCodAmount;
    return due;
  }

  // Full order is Paid when all active shift CoDs are paid (or if initial CoD was 0)
  bool get isFullyPaid => remainingDue <= 0;

  FoodOrder copyWith({
    String? lunchDeliveryStatus,
    String? dinnerDeliveryStatus,
    bool? lunchCodPaid,
    bool? dinnerCodPaid,
  }) {
    return FoodOrder(
      id: id,
      deliveryDate: deliveryDate,
      customerName: customerName,
      phone: phone,
      address: address,
      includeLunch: includeLunch,
      includeDinner: includeDinner,
      lunchItems: Map<String, int>.from(lunchItems),
      dinnerItems: Map<String, int>.from(dinnerItems),
      lunchBill: lunchBill,
      dinnerBill: dinnerBill,
      totalBill: totalBill,
      advanceAmount: advanceAmount,
      lunchCodAmount: lunchCodAmount,
      dinnerCodAmount: dinnerCodAmount,
      lunchCodPaid: lunchCodPaid ?? this.lunchCodPaid,
      dinnerCodPaid: dinnerCodPaid ?? this.dinnerCodPaid,
      paymentMethod: paymentMethod,
      specialNote: specialNote,
      lunchDeliveryStatus: lunchDeliveryStatus ?? this.lunchDeliveryStatus,
      dinnerDeliveryStatus: dinnerDeliveryStatus ?? this.dinnerDeliveryStatus,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'deliveryDate': deliveryDate,
        'customerName': customerName,
        'phone': phone,
        'address': address,
        'includeLunch': includeLunch,
        'includeDinner': includeDinner,
        'lunchItems': lunchItems,
        'dinnerItems': dinnerItems,
        'lunchBill': lunchBill,
        'dinnerBill': dinnerBill,
        'totalBill': totalBill,
        'advanceAmount': advanceAmount,
        'lunchCodAmount': lunchCodAmount,
        'dinnerCodAmount': dinnerCodAmount,
        'lunchCodPaid': lunchCodPaid,
        'dinnerCodPaid': dinnerCodPaid,
        'paymentMethod': paymentMethod,
        'specialNote': specialNote,
        'lunchDeliveryStatus': lunchDeliveryStatus,
        'dinnerDeliveryStatus': dinnerDeliveryStatus,
        'createdAt': createdAt,
      };

  static Map<String, int> _parseItemMap(dynamic raw) {
    final result = <String, int>{};
    if (raw is Map) {
      raw.forEach((key, value) {
        String k = key.toString();
        if (k == 'রুই মাছ' || k == 'রুই মাছ ভুনা') {
          k = 'বড় মাছ ভুনা';
        }
        result[k] = (value as num?)?.toInt() ?? 0;
      });
    }
    return result;
  }

  static String _normalizeStatus(String? st) {
    if (st == 'Delivered') return 'Delivered';
    return 'Pending';
  }

  // Helper to split CoD between Lunch and Dinner using direct whole-number subtraction
  // (NO fractional/percentage ratio math):
  // Lunch CoD reflects the exact Lunch meal price (capped at Total CoD),
  // and Dinner CoD receives the remaining whole-number CoD balance.
  static List<int> calculateShiftCodSplit({
    required bool includeLunch,
    required bool includeDinner,
    required int lunchBill,
    required int dinnerBill,
    required int totalBill,
    required int advanceAmount,
  }) {
    final int totalCod = (totalBill - advanceAmount).clamp(0, 9999999);
    if (totalCod <= 0) return [0, 0];
    if (includeLunch && !includeDinner) return [totalCod, 0];
    if (!includeLunch && includeDinner) return [0, totalCod];
    if (totalBill <= 0) return [0, 0];

    final int lunchCod = lunchBill <= totalCod ? lunchBill : totalCod;
    final int dinnerCod = (totalCod - lunchCod).clamp(0, 9999999);
    return [lunchCod, dinnerCod];
  }

  factory FoodOrder.fromJson(Map<String, dynamic> json) {
    final bool includeLunch = json['includeLunch'] ?? true;
    final bool includeDinner = json['includeDinner'] ?? false;
    final lunchItems = _parseItemMap(json['lunchItems']);
    final dinnerItems = _parseItemMap(json['dinnerItems']);
    final int totalBill = (json['totalBill'] as num?)?.toInt() ?? 0;
    final int advanceAmount = (json['advanceAmount'] as num?)?.toInt() ?? 0;

    final int lunchBill = (json['lunchBill'] as num?)?.toInt() ??
        (includeLunch && !includeDinner ? totalBill : (totalBill ~/ 2));
    final int dinnerBill = (json['dinnerBill'] as num?)?.toInt() ??
        (!includeLunch && includeDinner ? totalBill : (totalBill - lunchBill));

    final split = calculateShiftCodSplit(
      includeLunch: includeLunch,
      includeDinner: includeDinner,
      lunchBill: lunchBill,
      dinnerBill: dinnerBill,
      totalBill: totalBill,
      advanceAmount: advanceAmount,
    );

    final int lunchCod = split[0];
    final int dinnerCod = split[1];

    return FoodOrder(
      id: json['id']?.toString() ?? '',
      deliveryDate: json['deliveryDate']?.toString() ?? getTodayDateString(),
      customerName: json['customerName']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      includeLunch: includeLunch,
      includeDinner: includeDinner,
      lunchItems: lunchItems,
      dinnerItems: dinnerItems,
      lunchBill: lunchBill,
      dinnerBill: dinnerBill,
      totalBill: totalBill,
      advanceAmount: advanceAmount,
      lunchCodAmount: lunchCod,
      dinnerCodAmount: dinnerCod,
      lunchCodPaid: json['lunchCodPaid'] == true || lunchCod <= 0,
      dinnerCodPaid: json['dinnerCodPaid'] == true || dinnerCod <= 0,
      paymentMethod: json['paymentMethod']?.toString() ?? 'বিকাশ',
      specialNote: json['specialNote']?.toString() ?? '',
      lunchDeliveryStatus:
          _normalizeStatus(json['lunchDeliveryStatus']?.toString()),
      dinnerDeliveryStatus:
          _normalizeStatus(json['dinnerDeliveryStatus']?.toString()),
      createdAt: (json['createdAt'] as num?)?.toInt() ?? 0,
    );
  }
}

// ============================================================================
// REUSABLE LOGO PLACEHOLDER WIDGET ('assets/logo.png')
// ============================================================================
class AppLogoWidget extends StatelessWidget {
  final double size;
  const AppLogoWidget({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.combinedGoldBg,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.warmAmber, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/logo.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(
              Icons.restaurant_menu_rounded,
              size: size * 0.52,
              color: AppColors.deepEmerald,
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// ROOT APPLICATION WIDGET
// ============================================================================
class NaogaonBhojbariApp extends StatelessWidget {
  final bool isLoggedIn;
  const NaogaonBhojbariApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'নওগাঁ-ভোজবাড়ি Order Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.appCanvasBg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.deepEmerald,
          primary: AppColors.deepEmerald,
          secondary: AppColors.warmAmber,
          surface: AppColors.ivoryCardBg,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.deepEmerald,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: isLoggedIn ? const DashboardScreen() : const LoginScreen(),
    );
  }
}

// ============================================================================
// 1. LOGIN SCREEN (Hardcoded Credentials + SharedPreferences)
// ============================================================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;

  static const String _validUserId = '01779479417';
  static const String _validPassword = '479417';

  Future<void> _handleLogin() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    final userId = _userIdController.text.trim();
    final password = _passwordController.text.trim();

    if (userId == _validUserId && password == _validPassword) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      setState(() {
        _errorMessage =
            'ভুল ইউজার আইডি অথবা পাসওয়ার্ড! অনুগ্রহ করে সঠিক তথ্য দিন।';
      });
    }
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepEmerald,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                padding: const EdgeInsets.all(28.0),
                decoration: BoxDecoration(
                  color: AppColors.ivoryCardBg,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.combinedGoldSecondary, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AppLogoWidget(size: 84),
                      const SizedBox(height: 16),
                      const Text(
                        'নওগাঁ-ভোজবাড়ি',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.deepEmerald,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Order Manager অ্যাপে লগইন করুন',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 24),
                      if (_errorMessage != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red.shade800,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextFormField(
                        controller: _userIdController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'ইউজার আইডি (মোবাইল নম্বর)',
                          hintText: '01779479417',
                          filled: true,
                          fillColor: AppColors.ivorySurface,
                          prefixIcon: const Icon(Icons.person_outline,
                              color: AppColors.deepEmerald),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                                ? 'ইউজার আইডি লিখুন'
                                : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'পাসওয়ার্ড',
                          hintText: '479417',
                          filled: true,
                          fillColor: AppColors.ivorySurface,
                          prefixIcon: const Icon(Icons.lock_outline,
                              color: AppColors.deepEmerald),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                                ? 'পাসওয়ার্ড লিখুন'
                                : null,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.warmAmber,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _handleLogin,
                          child: const Text(
                            'লগইন করুন',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 2. HOME DASHBOARD SCREEN
// - Combined Summary Card: Soft Warm Amber / Pastel Gold + Dark Rounded Border + Rich Green Text
// - Lunch Card: Light Mint / Pastel Green + Green Badge Icon
// - Dinner Card: Light Teal / Pastel Indigo + Night/Moon Icon
// ============================================================================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  static const String _ordersStorageKey = 'naogaon_bhojbari_orders_v3';
  static const String _menuStorageKey = 'naogaon_bhojbari_menu_v2';

  late TabController _tabController;
  List<MenuItemModel> _menuItems = List.from(kInitialMenuItems);
  List<FoodOrder> _orders = [];
  bool _isLoading = true;

  // Upon login, always display Dashboard filtered for Today's Date
  late String _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = getTodayDateString();
    _tabController = TabController(length: 2, vsync: this);
    _loadDataFromStorage();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDataFromStorage() async {
    final prefs = await SharedPreferences.getInstance();

    final rawMenu = prefs.getString(_menuStorageKey);
    if (rawMenu != null && rawMenu.isNotEmpty) {
      try {
        final List<dynamic> decodedMenu = jsonDecode(rawMenu);
        _menuItems = decodedMenu
            .map((m) => MenuItemModel.fromJson(m as Map<String, dynamic>))
            .toList();
      } catch (_) {
        _menuItems = List.from(kInitialMenuItems);
      }
    }

    final rawOrders = prefs.getString(_ordersStorageKey) ??
        prefs.getString('naogaon_bhojbari_orders_v2');
    if (rawOrders != null && rawOrders.isNotEmpty) {
      try {
        final List<dynamic> decodedOrders = jsonDecode(rawOrders);
        _orders = decodedOrders
            .map((o) => FoodOrder.fromJson(o as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveMenuToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_menuItems.map((m) => m.toJson()).toList());
    await prefs.setString(_menuStorageKey, encoded);
  }

  Future<void> _saveOrdersToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_orders.map((o) => o.toJson()).toList());
    await prefs.setString(_ordersStorageKey, encoded);
  }

  Future<void> _updateMenuItems(List<MenuItemModel> updatedMenu) async {
    setState(() {
      _menuItems = updatedMenu;
    });
    await _saveMenuToStorage();
  }

  Future<void> _addNewOrder(FoodOrder order) async {
    setState(() {
      _orders.insert(0, order);
      _selectedDate = order.deliveryDate;
    });
    await _saveOrdersToStorage();

    if (order.includeLunch) {
      _tabController.animateTo(0);
    } else if (order.includeDinner) {
      _tabController.animateTo(1);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'অর্ডার সেভ হয়েছে (ডেলিভারি তারিখ: ${toBanglaNumber(order.deliveryDate)})',
        ),
        backgroundColor: AppColors.deepEmerald,
      ),
    );
  }

  Future<void> _updateShiftDeliveryStatus(
    String orderId,
    bool isLunchShift,
    String nextStatus,
  ) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return;
    setState(() {
      if (isLunchShift) {
        _orders[index] =
            _orders[index].copyWith(lunchDeliveryStatus: nextStatus);
      } else {
        _orders[index] =
            _orders[index].copyWith(dinnerDeliveryStatus: nextStatus);
      }
    });
    await _saveOrdersToStorage();
  }

  // Shift-specific CoD payment update button handler
  Future<void> _markShiftCodPaid(String orderId, bool isLunchShift) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return;
    final order = _orders[index];
    setState(() {
      if (isLunchShift) {
        _orders[index] = order.copyWith(lunchCodPaid: true);
      } else {
        _orders[index] = order.copyWith(dinnerCodPaid: true);
      }
    });
    await _saveOrdersToStorage();
  }

  Future<void> _deleteOrder(String orderId) async {
    setState(() {
      _orders.removeWhere((o) => o.id == orderId);
    });
    await _saveOrdersToStorage();
  }

  Future<void> _pickDashboardDate() async {
    final initial = parseDateDDMMYYYY(_selectedDate);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = formatDateDDMMYYYY(picked);
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> _launchPhoneDialer(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final Uri telUri = Uri(scheme: 'tel', path: cleanPhone);
    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    }
  }

  Future<void> _launchWhatsApp(FoodOrder order, bool isLunchShift) async {
    String cleanPhone = order.phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.startsWith('01')) {
      cleanPhone = '88$cleanPhone';
    }

    final shiftLabel = isLunchShift ? 'দুপুরের অর্ডার' : 'রাতের অর্ডার';
    final shiftItems = isLunchShift ? order.lunchItems : order.dinnerItems;
    final status =
        isLunchShift ? order.lunchDeliveryStatus : order.dinnerDeliveryStatus;

    final itemsText = shiftItems.entries
        .where((e) => e.value > 0)
        .map((e) => '${e.key} (${toBanglaNumber(e.value)}টি)')
        .join(', ');

    final message = Uri.encodeComponent(
      'আসসালামু আলাইকুম ${order.customerName},\n'
      'নওগাঁ-ভোজবাড়ি থেকে আপনার ${order.deliveryDate} তারিখের $shiftLabel নিশ্চিত করা হয়েছে।\n'
      'খাবারের মেনু: $itemsText\n'
      'Total: ৳${order.totalBill} | Advance: ৳${order.advanceAmount} (${order.paymentMethod}) | Remaining CoD: ৳${order.remainingDue}\n'
      'ডেলিভারি স্ট্যাটাস: $status',
    );

    final Uri waUri = Uri.parse('https://wa.me/$cleanPhone?text=$message');
    if (await canLaunchUrl(waUri)) {
      await launchUrl(waUri, mode: LaunchMode.externalApplication);
    }
  }

  void _openManageMenuScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ManageMenuScreen(
          menuItems: _menuItems,
          onUpdateMenu: _updateMenuItems,
        ),
      ),
    );
  }

  void _openReportsScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReportsScreen(
          orders: _orders,
          menuItems: _menuItems,
        ),
      ),
    );
  }

  void _openAddOrderModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddOrderBottomSheet(
        menuItems: _menuItems,
        onSaveOrder: _addNewOrder,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String todayStr = getTodayDateString();
    final String tomorrowStr = getTomorrowDateString();

    final dateOrders =
        _orders.where((o) => o.deliveryDate == _selectedDate).toList();

    final lunchOrders = dateOrders.where((o) => o.includeLunch).toList();
    final dinnerOrders = dateOrders.where((o) => o.includeDinner).toList();
    final int combinedMealOrderCount = lunchOrders.length + dinnerOrders.length;

    final Map<String, int> lunchItemCounts = {
      for (final m in _menuItems) m.name: 0,
    };
    final Map<String, int> dinnerItemCounts = {
      for (final m in _menuItems) m.name: 0,
    };
    final Map<String, int> combinedItemCounts = {
      for (final m in _menuItems) m.name: 0,
    };

    for (final order in lunchOrders) {
      order.lunchItems.forEach((itemName, qty) {
        if (qty > 0) {
          lunchItemCounts[itemName] = (lunchItemCounts[itemName] ?? 0) + qty;
          combinedItemCounts[itemName] =
              (combinedItemCounts[itemName] ?? 0) + qty;
        }
      });
    }

    for (final order in dinnerOrders) {
      order.dinnerItems.forEach((itemName, qty) {
        if (qty > 0) {
          dinnerItemCounts[itemName] = (dinnerItemCounts[itemName] ?? 0) + qty;
          combinedItemCounts[itemName] =
              (combinedItemCounts[itemName] ?? 0) + qty;
        }
      });
    }

    int totalBillForDay = 0;
    int totalAdvanceForDay = 0;
    int totalCodForDay = 0;
    int totalCodCollectedForDay = 0;
    int totalCodDueForDay = 0;

    for (final o in dateOrders) {
      totalBillForDay += o.totalBill;
      totalAdvanceForDay += o.advanceAmount;
      totalCodForDay += o.initialCodTotal;
      totalCodCollectedForDay += o.codCollectedAmount;
      totalCodDueForDay += o.remainingDue;
    }

    int pendingCount = 0;
    int deliveredCount = 0;

    for (final o in lunchOrders) {
      if (o.lunchDeliveryStatus == 'Delivered') {
        deliveredCount++;
      } else {
        pendingCount++;
      }
    }
    for (final o in dinnerOrders) {
      if (o.dinnerDeliveryStatus == 'Delivered') {
        deliveredCount++;
      } else {
        pendingCount++;
      }
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 68,
        titleSpacing: 12,
        backgroundColor: AppColors.deepEmerald,
        title: Row(
          children: [
            const AppLogoWidget(size: 38),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'নওগাঁ-ভোজবাড়ি Order Manager',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'আজকের তারিখ: ${toBanglaNumber(todayStr)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.combinedGoldBg,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'রিপোর্ট ও অ্যানালিটিক্স',
            onPressed: _openReportsScreen,
            icon: const Icon(Icons.bar_chart_rounded,
                color: AppColors.combinedGoldBg),
          ),
          IconButton(
            tooltip: 'মেনু ম্যানেজমেন্ট',
            onPressed: _openManageMenuScreen,
            icon: const Icon(Icons.restaurant_menu, color: Colors.white),
          ),
          IconButton(
            tooltip: 'লগআউট করুন',
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date Selector Bar (Ivory Tinted Surface)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.ivoryCardBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.softCardBorder),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'ডেলিভারি তারিখ: ${toBanglaNumber(_selectedDate)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.deepEmerald,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    setState(() => _selectedDate = todayStr),
                                child: Text(
                                  'আজ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: _selectedDate == todayStr
                                        ? AppColors.deepEmerald
                                        : Colors.black54,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    setState(() => _selectedDate = tomorrowStr),
                                child: Text(
                                  'আগামীকাল',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: _selectedDate == tomorrowStr
                                        ? AppColors.warmAmber
                                        : Colors.black54,
                                  ),
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: _pickDashboardDate,
                                icon:
                                    const Icon(Icons.calendar_month, size: 15),
                                label: const Text(
                                  'তারিখ',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ====================================================
                        // 1. COMBINED MAIN SUMMARY CARD ("আজকের মোট সামারি (দুপুর + রাত)")
                        // Soft warm amber / pastel gold background card with
                        // dark rounded borders and rich green accent text
                        // ====================================================
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.combinedGoldBg,
                                AppColors.combinedGoldSecondary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: AppColors.combinedDarkBorder,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.deepEmerald.withValues(alpha: 0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'আজকের মোট সামারি (দুপুর + রাত)',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.deepEmerald,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.deepEmerald,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      'মোট অর্ডার: ${toBanglaNumber(combinedMealOrderCount)}টি',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.combinedGoldBg,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Overall Item Breakdown Chips inside Combined Gold Card
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: combinedItemCounts.entries.map((e) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.combinedTileBg,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: AppColors.deepEmerald.withValues(alpha: 0.25),
                                      ),
                                    ),
                                    child: Text(
                                      '${e.key}: ${toBanglaNumber(e.value)}টি',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.deepEmerald,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const Divider(
                                color: AppColors.combinedDarkBorder,
                                height: 22,
                                thickness: 0.6,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _CombinedMetricCol(
                                    label: 'মোট বিল (Total)',
                                    value: '৳${toBanglaNumber(totalBillForDay)}',
                                    color: AppColors.deepEmerald,
                                  ),
                                  _CombinedMetricCol(
                                    label: 'মোট অগ্রিম (Advance)',
                                    value:
                                        '৳${toBanglaNumber(totalAdvanceForDay)}',
                                    color: AppColors.warmAmberDark,
                                  ),
                                  _CombinedMetricCol(
                                    label: 'মোট CoD (বাকি: ৳${toBanglaNumber(totalCodDueForDay)})',
                                    value: '৳${toBanglaNumber(totalCodForDay)}',
                                    color: AppColors.vibrantGreen,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // Status Badges Row inside Combined Card
                              Row(
                                children: [
                                  _StatusBadgeWidget(
                                    status: 'Pending',
                                    label:
                                        'Pending (অপেক্ষমাণ): ${toBanglaNumber(pendingCount)}',
                                  ),
                                  const SizedBox(width: 8),
                                  _StatusBadgeWidget(
                                    status: 'Delivered',
                                    label:
                                        'Delivered (ডেলিভার্ড): ${toBanglaNumber(deliveredCount)}',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ====================================================
                        // 2. LUNCH ORDERS CARD ("দুপুরের মোট অর্ডার")
                        // Light mint / pastel green tinted card background
                        // with a green badge icon
                        // ====================================================
                        _ShiftBreakdownSummaryCard(
                          title: 'দুপুরের মোট অর্ডার',
                          orderCount: lunchOrders.length,
                          itemBreakdown: lunchItemCounts,
                          cardBgColor: AppColors.lunchMintBg,
                          tileBgColor: AppColors.lunchMintTile,
                          borderColor: AppColors.lunchMintBorder,
                          badgeBgColor: AppColors.lunchBadgeGreen,
                          accentTextColor: AppColors.deepEmerald,
                          icon: Icons.wb_sunny_rounded,
                        ),
                        const SizedBox(height: 10),

                        // ====================================================
                        // 3. DINNER ORDERS CARD ("রাতের মোট অর্ডার")
                        // Light teal / pastel indigo tinted card background
                        // with a subtle night/moon icon
                        // ====================================================
                        _ShiftBreakdownSummaryCard(
                          title: 'রাতের মোট অর্ডার',
                          orderCount: dinnerOrders.length,
                          itemBreakdown: dinnerItemCounts,
                          cardBgColor: AppColors.dinnerIndigoBg,
                          tileBgColor: AppColors.dinnerIndigoTile,
                          borderColor: AppColors.dinnerIndigoBorder,
                          badgeBgColor: AppColors.dinnerBadgeIndigo,
                          accentTextColor: AppColors.dinnerBadgeIndigo,
                          icon: Icons.nights_stay_rounded,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      indicatorColor: AppColors.warmAmber,
                      indicatorWeight: 3.5,
                      labelColor: AppColors.deepEmerald,
                      unselectedLabelColor: Colors.black54,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.wb_sunny_rounded,
                                  size: 17, color: AppColors.lunchBadgeGreen),
                              const SizedBox(width: 6),
                              Text(
                                'দুপুরের অর্ডার (${toBanglaNumber(lunchOrders.length)})',
                              ),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.nights_stay_rounded,
                                  size: 17, color: AppColors.dinnerBadgeIndigo),
                              const SizedBox(width: 6),
                              Text(
                                'রাতের অর্ডার (${toBanglaNumber(dinnerOrders.length)})',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              body: TabBarView(
                controller: _tabController,
                children: [
                  _ShiftOrderListTab(
                    isLunchShift: true,
                    orders: lunchOrders,
                    itemBreakdown: lunchItemCounts,
                    emptyText:
                        '${toBanglaNumber(_selectedDate)} তারিখে দুপুরের কোনো অর্ডার নেই।',
                    onStatusChange: (orderId, nextStatus) =>
                        _updateShiftDeliveryStatus(orderId, true, nextStatus),
                    onMarkShiftCodPaid: (orderId, isLunch) =>
                        _markShiftCodPaid(orderId, isLunch),
                    onDelete: _deleteOrder,
                    onCall: _launchPhoneDialer,
                    onWhatsApp: (order) => _launchWhatsApp(order, true),
                  ),
                  _ShiftOrderListTab(
                    isLunchShift: false,
                    orders: dinnerOrders,
                    itemBreakdown: dinnerItemCounts,
                    emptyText:
                        '${toBanglaNumber(_selectedDate)} তারিখে রাতের কোনো অর্ডার নেই।',
                    onStatusChange: (orderId, nextStatus) =>
                        _updateShiftDeliveryStatus(orderId, false, nextStatus),
                    onMarkShiftCodPaid: (orderId, isLunch) =>
                        _markShiftCodPaid(orderId, isLunch),
                    onDelete: _deleteOrder,
                    onCall: _launchPhoneDialer,
                    onWhatsApp: (order) => _launchWhatsApp(order, false),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.warmAmber,
        foregroundColor: Colors.white,
        onPressed: _openAddOrderModal,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          '+ নতুন অর্ডার',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
      ),
    );
  }
}

class _CombinedMetricCol extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _CombinedMetricCol({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.richGreen,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// STATUS BADGE WIDGET (Pending = Soft Pastel Orange/Amber, Delivered = Soft Emerald)
// ============================================================================
class _StatusBadgeWidget extends StatelessWidget {
  final String status; // 'Pending' | 'Delivered'
  final String? label;

  const _StatusBadgeWidget({
    required this.status,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDelivered = status == 'Delivered';
    final Color bgColor =
        isDelivered ? AppColors.deliveredBadgeBg : AppColors.pendingBadgeBg;
    final Color borderColor = isDelivered
        ? AppColors.deliveredBadgeBorder
        : AppColors.pendingBadgeBorder;
    final Color textColor =
        isDelivered ? AppColors.deliveredBadgeText : AppColors.pendingBadgeText;
    final String displayLabel = label ??
        (isDelivered ? 'Delivered (ডেলিভার্ড)' : 'Pending (অপেক্ষমাণ)');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        displayLabel,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
      ),
    );
  }
}

// ============================================================================
// DASHBOARD TINTED SHIFT BREAKDOWN CARD WIDGET (Mint Green / Pastel Indigo)
// ============================================================================
class _ShiftBreakdownSummaryCard extends StatelessWidget {
  final String title;
  final int orderCount;
  final Map<String, int> itemBreakdown;
  final Color cardBgColor;
  final Color tileBgColor;
  final Color borderColor;
  final Color badgeBgColor;
  final Color accentTextColor;
  final IconData icon;

  const _ShiftBreakdownSummaryCard({
    required this.title,
    required this.orderCount,
    required this.itemBreakdown,
    required this.cardBgColor,
    required this.tileBgColor,
    required this.borderColor,
    required this.badgeBgColor,
    required this.accentTextColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: badgeBgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 19, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: accentTextColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: tileBgColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor),
                ),
                child: Text(
                  '${toBanglaNumber(orderCount)} টি অর্ডার',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: accentTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: itemBreakdown.entries.map((e) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: tileBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${e.key}: ${toBanglaNumber(e.value)}টি',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: accentTextColor,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _StickyTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.ivoryCardBg,
        border: Border(bottom: BorderSide(color: AppColors.softCardBorder)),
      ),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) => true;
}

// ============================================================================
// 3. SHIFT ORDER LIST TAB & CUSTOMER ORDER CARD
// - Customer Order Cards: Light Ivory / Off-White + Soft Colored Subtle Border
//   + Distinct Color Accents for Shift Tags (Lunch vs Dinner) + Status Badges
// ============================================================================
class _ShiftOrderListTab extends StatelessWidget {
  final bool isLunchShift;
  final List<FoodOrder> orders;
  final Map<String, int> itemBreakdown;
  final String emptyText;
  final Function(String orderId, String nextStatus) onStatusChange;
  final Function(String orderId, bool isLunchShift) onMarkShiftCodPaid;
  final Function(String orderId) onDelete;
  final Function(String phone) onCall;
  final Function(FoodOrder order) onWhatsApp;

  const _ShiftOrderListTab({
    required this.isLunchShift,
    required this.orders,
    required this.itemBreakdown,
    required this.emptyText,
    required this.onStatusChange,
    required this.onMarkShiftCodPaid,
    required this.onDelete,
    required this.onCall,
    required this.onWhatsApp,
  });

  @override
  Widget build(BuildContext context) {
    final breakdownSummary = itemBreakdown.entries
        .map((e) => '${e.key}: ${toBanglaNumber(e.value)}টি')
        .join('  ·  ');

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isLunchShift
                ? AppColors.lunchMintBg
                : AppColors.dinnerIndigoBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isLunchShift
                  ? AppColors.lunchMintBorder
                  : AppColors.dinnerIndigoBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isLunchShift
                    ? 'দুপুরের মোট অর্ডার: ${toBanglaNumber(orders.length)}টি — আইটেম ব্রেকডাউন:'
                    : 'রাতের মোট অর্ডার: ${toBanglaNumber(orders.length)}টি — আইটেম ব্রেকডাউন:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isLunchShift
                      ? AppColors.deepEmerald
                      : AppColors.dinnerBadgeIndigo,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                breakdownSummary,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isLunchShift
                      ? AppColors.vibrantGreen
                      : AppColors.dinnerBadgeIndigo,
                ),
              ),
            ],
          ),
        ),
        if (orders.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                emptyText,
                style: const TextStyle(fontSize: 15, color: Colors.black54),
              ),
            ),
          )
        else
          ...orders.map(
            (order) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _OrderCard(
                order: order,
                isLunchShift: isLunchShift,
                onStatusChange: onStatusChange,
                onMarkShiftCodPaid: onMarkShiftCodPaid,
                onDelete: onDelete,
                onCall: onCall,
                onWhatsApp: onWhatsApp,
              ),
            ),
          ),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  final FoodOrder order;
  final bool isLunchShift;
  final Function(String orderId, String nextStatus) onStatusChange;
  final Function(String orderId, bool isLunchShift) onMarkShiftCodPaid;
  final Function(String orderId) onDelete;
  final Function(String phone) onCall;
  final Function(FoodOrder order) onWhatsApp;

  const _OrderCard({
    required this.order,
    required this.isLunchShift,
    required this.onStatusChange,
    required this.onMarkShiftCodPaid,
    required this.onDelete,
    required this.onCall,
    required this.onWhatsApp,
  });

  @override
  Widget build(BuildContext context) {
    final shiftItems = isLunchShift ? order.lunchItems : order.dinnerItems;
    final currentStatus =
        isLunchShift ? order.lunchDeliveryStatus : order.dinnerDeliveryStatus;

    final orderedItemsList = shiftItems.entries
        .where((e) => e.value > 0)
        .map((e) => '${e.key} × ${toBanglaNumber(e.value)}')
        .join('  ·  ');

    final Color shiftBorderAccent = isLunchShift
        ? AppColors.lunchMintBorder
        : AppColors.dinnerIndigoBorder;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.ivoryCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: shiftBorderAccent, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Customer Info + Status Badge + Delete
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            order.customerName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkForest,
                            ),
                          ),
                        ),
                        _StatusBadgeWidget(status: currentStatus),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Shift Accent Tags (Lunch vs Dinner)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (order.includeLunch)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.lunchMintTile,
                              borderRadius: BorderRadius.circular(6),
                              border:
                                  Border.all(color: AppColors.lunchMintBorder),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.wb_sunny_rounded,
                                    size: 12, color: AppColors.lunchBadgeGreen),
                                SizedBox(width: 4),
                                Text(
                                  'দুপুরের শিফট',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.deepEmerald,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (order.includeDinner)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.dinnerIndigoTile,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: AppColors.dinnerIndigoBorder),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.nights_stay_rounded,
                                    size: 12,
                                    color: AppColors.dinnerBadgeIndigo),
                                SizedBox(width: 4),
                                Text(
                                  'রাতের শিফট',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.dinnerBadgeIndigo,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'মোবাইল: ${order.phone}  ·  তারিখ: ${toBanglaNumber(order.deliveryDate)}',
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                    Text(
                      'ঠিকানা: ${order.address}',
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.delete_outline,
                    size: 20, color: Colors.black45),
                onPressed: () => onDelete(order.id),
                tooltip: 'অর্ডার মুছে ফেলুন',
              ),
            ],
          ),
          const Divider(height: 18),
          Text(
            orderedItemsList.isEmpty ? 'কোনো আইটেম নেই' : orderedItemsList,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isLunchShift
                  ? AppColors.deepEmerald
                  : AppColors.dinnerBadgeIndigo,
            ),
          ),
          if (order.specialNote.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'স্পেশাল নির্দেশ: ${order.specialNote}',
              style: const TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.black54,
              ),
            ),
          ],
          const SizedBox(height: 10),

          // Payment & Shift-Wise CoD Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.ivorySurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.softCardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Total: ৳${toBanglaNumber(order.totalBill)} | Advance: ৳${toBanglaNumber(order.advanceAmount)} (${order.paymentMethod}) | Cash on Delivery: ৳${toBanglaNumber(order.initialCodTotal)}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkForest,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      order.isFullyPaid
                          ? 'পরিশোধিত'
                          : 'বাকি: ৳${toBanglaNumber(order.remainingDue)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: order.isFullyPaid
                            ? AppColors.vibrantGreen
                            : AppColors.pendingBadgeText,
                      ),
                    ),
                  ],
                ),
                if (order.includeLunch && order.includeDinner)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'শিফট অনুযায়ী CoD ভাগ — দুপুর: ৳${toBanglaNumber(order.lunchCodAmount)}  ·  রাত: ৳${toBanglaNumber(order.dinnerCodAmount)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),

                // Shift-Specific Payment Buttons
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (order.includeLunch && order.lunchCodAmount > 0)
                      order.lunchCodPaid
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.deliveredBadgeBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '✓ দুপুরের CoD (৳${toBanglaNumber(order.lunchCodAmount)}) পরিশোধিত',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.deliveredBadgeText,
                                ),
                              ),
                            )
                          : OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: AppColors.lunchMintBg,
                                foregroundColor: AppColors.deepEmerald,
                                side: const BorderSide(
                                    color: AppColors.lunchBadgeGreen),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                minimumSize: const Size(0, 32),
                              ),
                              onPressed: () =>
                                  onMarkShiftCodPaid(order.id, true),
                              child: Text(
                                'দুপুরের CoD (৳${toBanglaNumber(order.lunchCodAmount)}) পরিশোধিত মার্ক করুন',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                    if (order.includeDinner && order.dinnerCodAmount > 0)
                      order.dinnerCodPaid
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.deliveredBadgeBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '✓ রাতের CoD (৳${toBanglaNumber(order.dinnerCodAmount)}) পরিশোধিত',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.deliveredBadgeText,
                                ),
                              ),
                            )
                          : OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: AppColors.dinnerIndigoBg,
                                foregroundColor: AppColors.dinnerBadgeIndigo,
                                side: const BorderSide(
                                    color: AppColors.dinnerBadgeIndigo),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                minimumSize: const Size(0, 32),
                              ),
                              onPressed: () =>
                                  onMarkShiftCodPaid(order.id, false),
                              child: Text(
                                'রাতের CoD (৳${toBanglaNumber(order.dinnerCodAmount)}) পরিশোধিত মার্ক করুন',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.deepEmerald,
                  side: const BorderSide(color: AppColors.deepEmerald),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: const Size(0, 36),
                ),
                onPressed: () => onCall(order.phone),
                icon: const Icon(Icons.call_outlined, size: 16),
                label: const Text('কল করুন', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF128C7E),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: const Size(0, 36),
                ),
                onPressed: () => onWhatsApp(order),
                icon: const Icon(Icons.chat_bubble_outline, size: 16),
                label:
                    const Text('হোয়াটসঅ্যাপ', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Status Toggle Buttons styled with Pending Amber & Delivered Emerald
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.ivorySurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.softCardBorder),
            ),
            child: Row(
              children: [
                _StatusStepButton(
                  label: 'Pending (অপেক্ষমাণ)',
                  isSelected: currentStatus == 'Pending',
                  activeBgColor: AppColors.pendingBadgeBg,
                  activeBorderColor: AppColors.pendingBadgeBorder,
                  activeTextColor: AppColors.pendingBadgeText,
                  onTap: () => onStatusChange(order.id, 'Pending'),
                ),
                const SizedBox(width: 6),
                _StatusStepButton(
                  label: 'Delivered (ডেলিভার্ড)',
                  isSelected: currentStatus == 'Delivered',
                  activeBgColor: AppColors.deliveredBadgeBg,
                  activeBorderColor: AppColors.deliveredBadgeBorder,
                  activeTextColor: AppColors.deliveredBadgeText,
                  onTap: () => onStatusChange(order.id, 'Delivered'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusStepButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color activeBgColor;
  final Color activeBorderColor;
  final Color activeTextColor;
  final VoidCallback onTap;

  const _StatusStepButton({
    required this.label,
    required this.isSelected,
    required this.activeBgColor,
    required this.activeBorderColor,
    required this.activeTextColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? activeBgColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected ? Border.all(color: activeBorderColor, width: 1.5) : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: isSelected ? activeTextColor : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 4. REPORTS & ANALYTICS SCREEN ("রিপোর্ট")
// ============================================================================
class ReportsScreen extends StatefulWidget {
  final List<FoodOrder> orders;
  final List<MenuItemModel> menuItems;

  const ReportsScreen({
    super.key,
    required this.orders,
    required this.menuItems,
  });

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  // Mode: 'range' (Date Range) | 'month' (Specific Month)
  String _filterMode = 'range';
  late DateTime _startDate;
  late DateTime _endDate;
  late int _selectedMonth; // 1..12
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = now.add(const Duration(days: 7));
    _selectedMonth = now.month;
    _selectedYear = now.year;
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
        if (_startDate.isAfter(_endDate)) {
          _startDate = _endDate;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = widget.orders.where((o) {
      final d = parseDateDDMMYYYY(o.deliveryDate);
      final dateOnly = DateTime(d.year, d.month, d.day);

      if (_filterMode == 'month') {
        return dateOnly.month == _selectedMonth &&
            dateOnly.year == _selectedYear;
      } else {
        final startOnly =
            DateTime(_startDate.year, _startDate.month, _startDate.day);
        final endOnly = DateTime(_endDate.year, _endDate.month, _endDate.day);
        return !dateOnly.isBefore(startOnly) && !dateOnly.isAfter(endOnly);
      }
    }).toList();

    int totalMealOrders = 0;
    int totalBill = 0;
    int totalAdvance = 0;
    int totalCodCollected = 0;
    int totalCodRemaining = 0;

    final Map<String, int> itemSales = {
      for (final m in widget.menuItems) m.name: 0,
    };

    for (final order in filteredOrders) {
      if (order.includeLunch) totalMealOrders++;
      if (order.includeDinner) totalMealOrders++;

      totalBill += order.totalBill;
      totalAdvance += order.advanceAmount;
      totalCodCollected += order.codCollectedAmount;
      totalCodRemaining += order.remainingDue;

      if (order.includeLunch) {
        order.lunchItems.forEach((k, v) {
          if (v > 0) itemSales[k] = (itemSales[k] ?? 0) + v;
        });
      }
      if (order.includeDinner) {
        order.dinnerItems.forEach((k, v) {
          if (v > 0) itemSales[k] = (itemSales[k] ?? 0) + v;
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('রিপোর্ট ও অ্যানালিটিক্স (Reports)'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Filter Mode Selector: Custom Date Range vs Specific Month
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.ivoryCardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.softCardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('তারিখ রেঞ্জ (Date Range)',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w700)),
                        value: 'range',
                        groupValue: _filterMode,
                        activeColor: AppColors.deepEmerald,
                        onChanged: (v) =>
                            setState(() => _filterMode = v ?? 'range'),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('নির্দিষ্ট মাস (Month)',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w700)),
                        value: 'month',
                        groupValue: _filterMode,
                        activeColor: AppColors.deepEmerald,
                        onChanged: (v) =>
                            setState(() => _filterMode = v ?? 'month'),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                if (_filterMode == 'range')
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickStartDate,
                          icon: const Icon(Icons.date_range, size: 16),
                          label: Text(
                            'শুরু: ${formatDateDDMMYYYY(_startDate)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickEndDate,
                          icon: const Icon(Icons.date_range, size: 16),
                          label: Text(
                            'শেষ: ${formatDateDDMMYYYY(_endDate)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _selectedMonth,
                          decoration: const InputDecoration(
                            labelText: 'মাস নির্বাচন করুন',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: List.generate(12, (idx) {
                            return DropdownMenuItem(
                              value: idx + 1,
                              child: Text(kBanglaMonths[idx]),
                            );
                          }),
                          onChanged: (val) => setState(
                              () => _selectedMonth = val ?? _selectedMonth),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _selectedYear,
                          decoration: const InputDecoration(
                            labelText: 'বছর',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: [2025, 2026, 2027].map((yr) {
                            return DropdownMenuItem(
                              value: yr,
                              child: Text(toBanglaNumber(yr)),
                            );
                          }).toList(),
                          onChanged: (val) => setState(
                              () => _selectedYear = val ?? _selectedYear),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Combined Financial & Order Metrics (Warm Amber / Gold Card)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.combinedGoldBg,
                  AppColors.combinedGoldSecondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.combinedDarkBorder, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'নির্বাচিত সময়ের মোট হিসাব',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.deepEmerald,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _CombinedMetricCol(
                      label: 'মোট অর্ডার সংখ্যা',
                      value: '${toBanglaNumber(totalMealOrders)}টি',
                      color: AppColors.deepEmerald,
                    ),
                    _CombinedMetricCol(
                      label: 'মোট বিল (Total Bill)',
                      value: '৳${toBanglaNumber(totalBill)}',
                      color: AppColors.deepEmerald,
                    ),
                  ],
                ),
                const Divider(color: AppColors.combinedDarkBorder, height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _CombinedMetricCol(
                      label: 'অগ্রিম প্রাপ্ত (Advance)',
                      value: '৳${toBanglaNumber(totalAdvance)}',
                      color: AppColors.warmAmberDark,
                    ),
                    _CombinedMetricCol(
                      label: 'CoD আদায়কৃত (Collected)',
                      value: '৳${toBanglaNumber(totalCodCollected)}',
                      color: AppColors.vibrantGreen,
                    ),
                    _CombinedMetricCol(
                      label: 'CoD বকেয়া (Due)',
                      value: '৳${toBanglaNumber(totalCodRemaining)}',
                      color: AppColors.pendingBadgeText,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Item-wise Sales Count Card (Mint Tinted)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lunchMintBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lunchMintBorder, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'আইটেম অনুযায়ী মোট বিক্রি সংখ্যা',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.deepEmerald,
                  ),
                ),
                const Divider(height: 20),
                ...itemSales.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkForest,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.lunchMintTile,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${toBanglaNumber(entry.value)} টি',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.deepEmerald,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 5. MANAGE MENU SCREEN ("মেনু ম্যানেজমেন্ট")
// ============================================================================
class ManageMenuScreen extends StatefulWidget {
  final List<MenuItemModel> menuItems;
  final Function(List<MenuItemModel>) onUpdateMenu;

  const ManageMenuScreen({
    super.key,
    required this.menuItems,
    required this.onUpdateMenu,
  });

  @override
  State<ManageMenuScreen> createState() => _ManageMenuScreenState();
}

class _ManageMenuScreenState extends State<ManageMenuScreen> {
  late List<MenuItemModel> _items;
  final _newNameController = TextEditingController();
  final _newPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.menuItems);
  }

  @override
  void dispose() {
    _newNameController.dispose();
    _newPriceController.dispose();
    super.dispose();
  }

  void _addNewMenuItem() {
    final name = _newNameController.text.trim();
    final price = int.tryParse(_newPriceController.text.trim()) ?? 0;
    if (name.isEmpty || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('সঠিক আইটেমের নাম ও মূল্য লিখুন')),
      );
      return;
    }

    setState(() {
      _items.add(
        MenuItemModel(
          id: 'item_${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          price: price,
        ),
      );
      _newNameController.clear();
      _newPriceController.clear();
    });
    widget.onUpdateMenu(_items);
  }

  void _editMenuItemPrice(int index, int currentPrice) {
    final controller = TextEditingController(text: currentPrice.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${_items[index].name} - মূল্য পরিবর্তন'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'নতুন মূল্য (টাকা)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepEmerald,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final nextPrice = int.tryParse(controller.text.trim());
              if (nextPrice != null && nextPrice > 0) {
                setState(() {
                  _items[index] = _items[index].copyWith(price: nextPrice);
                });
                widget.onUpdateMenu(_items);
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('সেভ করুন'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('মেনু ম্যানেজমেন্ট (Manage Menu)'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.combinedGoldBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.combinedDarkBorder, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '+ নতুন মেনু আইটেম যোগ করুন',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.deepEmerald,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _newNameController,
                        decoration: const InputDecoration(
                          labelText: 'আইটেমের নাম (যেমন: ডিম ভুনা)',
                          filled: true,
                          fillColor: AppColors.ivoryCardBg,
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: _newPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'মূল্য (৳)',
                          filled: true,
                          fillColor: AppColors.ivoryCardBg,
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.deepEmerald,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _addNewMenuItem,
                    icon: const Icon(Icons.add),
                    label: const Text(
                      'মেনুতে যোগ করুন',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'বর্তমান খাবারের মেনু তালিকা',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.darkForest,
            ),
          ),
          const SizedBox(height: 10),
          ...List.generate(_items.length, (index) {
            final item = _items[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.ivoryCardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.lunchMintBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.deepEmerald,
                        ),
                      ),
                      Text(
                        'মূল্য: ${toBanglaNumber(item.price)} টাকা (৳${item.price})',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _editMenuItemPrice(index, item.price),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('মূল্য এডিট'),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ============================================================================
// 6. ADD NEW ORDER MODAL FORM (Tomorrow Default Date, Multi-Shift, CoD Split)
// ============================================================================
class AddOrderBottomSheet extends StatefulWidget {
  final List<MenuItemModel> menuItems;
  final Function(FoodOrder) onSaveOrder;

  const AddOrderBottomSheet({
    super.key,
    required this.menuItems,
    required this.onSaveOrder,
  });

  @override
  State<AddOrderBottomSheet> createState() => _AddOrderBottomSheetState();
}

class _AddOrderBottomSheetState extends State<AddOrderBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _advanceController = TextEditingController(text: '0');
  final _specialNoteController = TextEditingController();

  late String _deliveryDate;
  bool _includeLunch = true;
  bool _includeDinner = false;

  late Map<String, int> _lunchQuantities;
  late Map<String, int> _dinnerQuantities;

  String _selectedPaymentMethod = 'বিকাশ';

  @override
  void initState() {
    super.initState();
    _deliveryDate = getTomorrowDateString();
    _lunchQuantities = {for (final m in widget.menuItems) m.name: 0};
    _dinnerQuantities = {for (final m in widget.menuItems) m.name: 0};
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _advanceController.dispose();
    _specialNoteController.dispose();
    super.dispose();
  }

  Future<void> _pickOrderDate() async {
    final initial = parseDateDDMMYYYY(_deliveryDate);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _deliveryDate = formatDateDDMMYYYY(picked);
      });
    }
  }

  int get _lunchBill {
    if (!_includeLunch) return 0;
    int sum = 0;
    for (final item in widget.menuItems) {
      sum += (_lunchQuantities[item.name] ?? 0) * item.price;
    }
    return sum;
  }

  int get _dinnerBill {
    if (!_includeDinner) return 0;
    int sum = 0;
    for (final item in widget.menuItems) {
      sum += (_dinnerQuantities[item.name] ?? 0) * item.price;
    }
    return sum;
  }

  int get _totalBill => _lunchBill + _dinnerBill;

  int get _advanceAmount => int.tryParse(_advanceController.text.trim()) ?? 0;

  List<int> get _codSplit => FoodOrder.calculateShiftCodSplit(
        includeLunch: _includeLunch && _lunchBill > 0,
        includeDinner: _includeDinner && _dinnerBill > 0,
        lunchBill: _lunchBill,
        dinnerBill: _dinnerBill,
        totalBill: _totalBill,
        advanceAmount: _advanceAmount,
      );

  void _changeQty(bool isLunch, String itemName, int delta) {
    setState(() {
      final map = isLunch ? _lunchQuantities : _dinnerQuantities;
      final next = (map[itemName] ?? 0) + delta;
      if (next >= 0) {
        map[itemName] = next;
      }
    });
  }

  void _submitOrder() {
    if (!_formKey.currentState!.validate()) return;
    if (!_includeLunch && !_includeDinner) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('অন্তত একটি শিফট (দুপুর অথবা রাত) নির্বাচন করুন!')),
      );
      return;
    }
    if (_totalBill <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অন্তত একটি খাবারের আইটেম নির্বাচন করুন!')),
      );
      return;
    }

    final split = _codSplit;
    final hasLunch = _includeLunch && _lunchBill > 0;
    final hasDinner = _includeDinner && _dinnerBill > 0;

    final newOrder = FoodOrder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      deliveryDate: _deliveryDate,
      customerName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      includeLunch: hasLunch,
      includeDinner: hasDinner,
      lunchItems: hasLunch ? Map<String, int>.from(_lunchQuantities) : {},
      dinnerItems: hasDinner ? Map<String, int>.from(_dinnerQuantities) : {},
      lunchBill: _lunchBill,
      dinnerBill: _dinnerBill,
      totalBill: _totalBill,
      advanceAmount: _advanceAmount,
      lunchCodAmount: split[0],
      dinnerCodAmount: split[1],
      lunchCodPaid: !hasLunch || split[0] <= 0,
      dinnerCodPaid: !hasDinner || split[1] <= 0,
      paymentMethod: _selectedPaymentMethod,
      specialNote: _specialNoteController.text.trim(),
      lunchDeliveryStatus: 'Pending',
      dinnerDeliveryStatus: 'Pending',
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    widget.onSaveOrder(newOrder);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final split = _codSplit;
    final int remainingDue = split[0] + split[1];

    return Container(
      margin: const EdgeInsets.only(top: 36),
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset + 20),
      decoration: const BoxDecoration(
        color: AppColors.ivoryCardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '+ নতুন অর্ডার বুকিং',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.deepEmerald,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _pickOrderDate,
                    icon: const Icon(Icons.calendar_today, size: 15),
                    label: Text(
                      'ডেলিভারি: $_deliveryDate',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'কাস্টমারের নাম *',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'কাস্টমারের নাম লিখুন'
                    : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'মোবাইল নম্বর *',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'মোবাইল নম্বর লিখুন'
                    : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'ঠিকানা *',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'ডেলিভারি ঠিকানা লিখুন'
                    : null,
              ),
              const SizedBox(height: 14),
              const Text(
                'অর্ডারের শিফট নির্বাচন করুন (এক বা উভয়ই)',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('দুপুর (Lunch)'),
                      value: _includeLunch,
                      activeColor: AppColors.lunchBadgeGreen,
                      onChanged: (val) =>
                          setState(() => _includeLunch = val ?? false),
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('রাত (Dinner)'),
                      value: _includeDinner,
                      activeColor: AppColors.dinnerBadgeIndigo,
                      onChanged: (val) =>
                          setState(() => _includeDinner = val ?? false),
                    ),
                  ),
                ],
              ),
              if (_includeLunch) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.lunchMintBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.lunchMintBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'দুপুরের খাবারের মেনু (বিল: ৳${toBanglaNumber(_lunchBill)})',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: AppColors.deepEmerald,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ...widget.menuItems.map((item) {
                        final qty = _lunchQuantities[item.name] ?? 0;
                        return _MenuQtyRow(
                          item: item,
                          qty: qty,
                          onDec: () => _changeQty(true, item.name, -1),
                          onInc: () => _changeQty(true, item.name, 1),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
              if (_includeDinner) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.dinnerIndigoBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.dinnerIndigoBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'রাতের খাবারের মেনু (বিল: ৳${toBanglaNumber(_dinnerBill)})',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: AppColors.dinnerBadgeIndigo,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ...widget.menuItems.map((item) {
                        final qty = _dinnerQuantities[item.name] ?? 0;
                        return _MenuQtyRow(
                          item: item,
                          qty: qty,
                          onDec: () => _changeQty(false, item.name, -1),
                          onInc: () => _changeQty(false, item.name, 1),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _advanceController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'অগ্রিম পেমেন্ট (Advance ৳)',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedPaymentMethod,
                      decoration: const InputDecoration(
                        labelText: 'পেমেন্ট পদ্ধতি',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: ['বিকাশ', 'নগদ', 'ক্যাশ']
                          .map((m) => DropdownMenuItem(
                                value: m,
                                child: Text(m),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() =>
                          _selectedPaymentMethod = val ?? _selectedPaymentMethod),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.combinedGoldBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.combinedDarkBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total: ৳${toBanglaNumber(_totalBill)} | Advance: ৳${toBanglaNumber(_advanceAmount)} ($_selectedPaymentMethod) | Cash on Delivery: ৳${toBanglaNumber(remainingDue)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.deepEmerald,
                      ),
                    ),
                    if (_includeLunch && _includeDinner && remainingDue > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'শিফট অনুযায়ী CoD ভাগ — দুপুরের CoD: ৳${toBanglaNumber(split[0])}  ·  রাতের CoD: ৳${toBanglaNumber(split[1])}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.richGreen,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _specialNoteController,
                decoration: const InputDecoration(
                  labelText: 'স্পেশাল নির্দেশ (ঐচ্ছিক)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepEmerald,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _submitOrder,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text(
                    'অর্ডার সেভ করুন',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuQtyRow extends StatelessWidget {
  final MenuItemModel item;
  final int qty;
  final VoidCallback onDec;
  final VoidCallback onInc;

  const _MenuQtyRow({
    required this.item,
    required this.qty,
    required this.onDec,
    required this.onInc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.ivoryCardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: qty > 0 ? AppColors.warmAmber : AppColors.softCardBorder,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${item.name} — ৳${toBanglaNumber(item.price)}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          Row(
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: onDec,
                icon: const Icon(Icons.remove_circle_outline),
                color: Colors.black54,
              ),
              SizedBox(
                width: 26,
                child: Text(
                  toBanglaNumber(qty),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: onInc,
                icon: const Icon(Icons.add_circle_rounded),
                color: AppColors.warmAmber,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
