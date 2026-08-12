library home_service_app;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Hive Storage Engine
  await Hive.initFlutter();

  // 2. Register & Open Hive Storage Boxes
  await Hive.openBox('auth_box');
  await Hive.openBox('users_box');
  await Hive.openBox('workers_box');
  await Hive.openBox('categories_box');
  await Hive.openBox('bookings_box');
  await Hive.openBox('chats_box');
  await Hive.openBox('reviews_box');
  await Hive.openBox('complaints_box');
  await Hive.openBox('addresses_box');
  await Hive.openBox('notifications_box');
  await Hive.openBox('payouts_box');

  // 3. Dependency Injection for Core GetX Services & Controllers
  Get.put(HiveStorageService());
  Get.put(AuthController());
  Get.put(NotificationController());
  Get.put(AddressController());
  Get.put(CategoryController());
  Get.put(WorkerController());
  Get.put(BookingController());
  Get.put(ChatController());
  Get.put(ReviewController());
  Get.put(ComplaintController());
  Get.put(PayoutController());
  Get.put(AdminController());

  runApp(const HomeServiceApp());
}

// ============================================================================
// 1. DATA MODELS & ENUMS
// ============================================================================

enum UserRole { user, worker, admin }

enum BookingStatus { pending, accepted, rejected, inProgress, completed, cancelled }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? address;
  final String? city;
  final String? avatar;
  bool isDisabled;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.address,
    this.city,
    this.avatar,
    this.isDisabled = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role.name,
        'address': address,
        'city': city,
        'avatar': avatar,
        'isDisabled': isDisabled,
      };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        phone: map['phone'] ?? '',
        role: UserRole.values.firstWhere(
          (e) => e.name == map['role'],
          orElse: () => UserRole.user,
        ),
        address: map['address'],
        city: map['city'],
        avatar: map['avatar'],
        isDisabled: map['isDisabled'] ?? false,
      );
}

class WorkerModel extends UserModel {
  List<String> categoryIds;
  String bio;
  double hourlyRate;
  String serviceArea;
  bool isAvailable;
  bool isApproved;
  double rating;
  int reviewCount;
  int completedJobsCount;
  double totalEarnings;

  WorkerModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.role,
    super.address,
    super.city,
    super.avatar,
    super.isDisabled,
    required this.categoryIds,
    required this.bio,
    required this.hourlyRate,
    required this.serviceArea,
    this.isAvailable = true,
    this.isApproved = false,
    this.rating = 5.0,
    this.reviewCount = 0,
    this.completedJobsCount = 0,
    this.totalEarnings = 0.0,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'categoryIds': categoryIds,
      'bio': bio,
      'hourlyRate': hourlyRate,
      'serviceArea': serviceArea,
      'isAvailable': isAvailable,
      'isApproved': isApproved,
      'rating': rating,
      'reviewCount': reviewCount,
      'completedJobsCount': completedJobsCount,
      'totalEarnings': totalEarnings,
    });
    return map;
  }

  factory WorkerModel.fromWorkerMap(Map<String, dynamic> map) => WorkerModel(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        phone: map['phone'] ?? '',
        role: UserRole.worker,
        address: map['address'],
        city: map['city'],
        avatar: map['avatar'],
        isDisabled: map['isDisabled'] ?? false,
        categoryIds: List<String>.from(map['categoryIds'] ?? []),
        bio: map['bio'] ?? '',
        hourlyRate: (map['hourlyRate'] as num? ?? 45.0).toDouble(),
        serviceArea: map['serviceArea'] ?? 'Downtown',
        isAvailable: map['isAvailable'] ?? true,
        isApproved: map['isApproved'] ?? false,
        rating: (map['rating'] as num? ?? 5.0).toDouble(),
        reviewCount: map['reviewCount'] ?? 0,
        completedJobsCount: map['completedJobsCount'] ?? 0,
        totalEarnings: (map['totalEarnings'] as num? ?? 0.0).toDouble(),
      );
}

class CategoryModel {
  final String id;
  String name;
  String iconName;
  String description;
  double basePrice;

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconName,
    required this.description,
    required this.basePrice,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'iconName': iconName,
        'description': description,
        'basePrice': basePrice,
      };

  factory CategoryModel.fromMap(Map<String, dynamic> map) => CategoryModel(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        iconName: map['iconName'] ?? 'build',
        description: map['description'] ?? '',
        basePrice: (map['basePrice'] as num? ?? 30.0).toDouble(),
      );
}

class AddressModel {
  final String id;
  final String label; // Home, Office, Apartment
  final String addressLine;
  final String city;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.label,
    required this.addressLine,
    required this.city,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'label': label,
        'addressLine': addressLine,
        'city': city,
        'isDefault': isDefault,
      };

  factory AddressModel.fromMap(Map<String, dynamic> map) => AddressModel(
        id: map['id'] ?? '',
        label: map['label'] ?? 'Home',
        addressLine: map['addressLine'] ?? '',
        city: map['city'] ?? 'Downtown',
        isDefault: map['isDefault'] ?? false,
      );
}

class BookingModel {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  String userAddress;
  final String workerId;
  final String workerName;
  final String workerPhone;
  final String categoryId;
  final String categoryName;
  final String serviceTitle;
  String scheduledDate;
  String scheduledTime;
  final String locationArea;
  final String notes;
  final double basePrice;
  final double hourlyRate;
  final double estimatedPrice;
  BookingStatus status;
  String? rejectionReason;
  String? cancelReason;

  BookingModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.userAddress,
    required this.workerId,
    required this.workerName,
    required this.workerPhone,
    required this.categoryId,
    required this.categoryName,
    required this.serviceTitle,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.locationArea,
    required this.notes,
    required this.basePrice,
    required this.hourlyRate,
    required this.estimatedPrice,
    required this.status,
    this.rejectionReason,
    this.cancelReason,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'userName': userName,
        'userPhone': userPhone,
        'userAddress': userAddress,
        'workerId': workerId,
        'workerName': workerName,
        'workerPhone': workerPhone,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'serviceTitle': serviceTitle,
        'scheduledDate': scheduledDate,
        'scheduledTime': scheduledTime,
        'locationArea': locationArea,
        'notes': notes,
        'basePrice': basePrice,
        'hourlyRate': hourlyRate,
        'estimatedPrice': estimatedPrice,
        'status': status.name,
        'rejectionReason': rejectionReason,
        'cancelReason': cancelReason,
      };

  factory BookingModel.fromMap(Map<String, dynamic> map) => BookingModel(
        id: map['id'] ?? '',
        userId: map['userId'] ?? '',
        userName: map['userName'] ?? '',
        userPhone: map['userPhone'] ?? '',
        userAddress: map['userAddress'] ?? '',
        workerId: map['workerId'] ?? '',
        workerName: map['workerName'] ?? '',
        workerPhone: map['workerPhone'] ?? '',
        categoryId: map['categoryId'] ?? '',
        categoryName: map['categoryName'] ?? '',
        serviceTitle: map['serviceTitle'] ?? '',
        scheduledDate: map['scheduledDate'] ?? '',
        scheduledTime: map['scheduledTime'] ?? '',
        locationArea: map['locationArea'] ?? '',
        notes: map['notes'] ?? '',
        basePrice: (map['basePrice'] as num? ?? 30.0).toDouble(),
        hourlyRate: (map['hourlyRate'] as num? ?? 45.0).toDouble(),
        estimatedPrice: (map['estimatedPrice'] as num? ?? 75.0).toDouble(),
        status: BookingStatus.values.firstWhere(
          (e) => e.name == map['status'],
          orElse: () => BookingStatus.pending,
        ),
        rejectionReason: map['rejectionReason'],
        cancelReason: map['cancelReason'],
      );
}

class ChatMessageModel {
  final String id;
  final String bookingId;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String text;
  final String timestamp;

  ChatMessageModel({
    required this.id,
    required this.bookingId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'bookingId': bookingId,
        'senderId': senderId,
        'senderName': senderName,
        'senderRole': senderRole,
        'text': text,
        'timestamp': timestamp,
      };

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) => ChatMessageModel(
        id: map['id'] ?? '',
        bookingId: map['bookingId'] ?? '',
        senderId: map['senderId'] ?? '',
        senderName: map['senderName'] ?? '',
        senderRole: map['senderRole'] ?? '',
        text: map['text'] ?? '',
        timestamp: map['timestamp'] ?? '',
      );
}

class ReviewModel {
  final String id;
  final String bookingId;
  final String workerId;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final String date;
  String? workerReply;

  ReviewModel({
    required this.id,
    required this.bookingId,
    required this.workerId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
    this.workerReply,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'bookingId': bookingId,
        'workerId': workerId,
        'userId': userId,
        'userName': userName,
        'rating': rating,
        'comment': comment,
        'date': date,
        'workerReply': workerReply,
      };

  factory ReviewModel.fromMap(Map<String, dynamic> map) => ReviewModel(
        id: map['id'] ?? '',
        bookingId: map['bookingId'] ?? '',
        workerId: map['workerId'] ?? '',
        userId: map['userId'] ?? '',
        userName: map['userName'] ?? '',
        rating: (map['rating'] as num? ?? 5.0).toDouble(),
        comment: map['comment'] ?? '',
        date: map['date'] ?? '',
        workerReply: map['workerReply'],
      );
}

class ComplaintModel {
  final String id;
  final String bookingId;
  final String userId;
  final String userName;
  final String workerId;
  final String workerName;
  final String issueCategory;
  final String description;
  String status; // 'Open', 'Resolved'
  String? resolutionNote;
  final String createdAt;

  ComplaintModel({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.userName,
    required this.workerId,
    required this.workerName,
    required this.issueCategory,
    required this.description,
    this.status = 'Open',
    this.resolutionNote,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'bookingId': bookingId,
        'userId': userId,
        'userName': userName,
        'workerId': workerId,
        'workerName': workerName,
        'issueCategory': issueCategory,
        'description': description,
        'status': status,
        'resolutionNote': resolutionNote,
        'createdAt': createdAt,
      };

  factory ComplaintModel.fromMap(Map<String, dynamic> map) => ComplaintModel(
        id: map['id'] ?? '',
        bookingId: map['bookingId'] ?? '',
        userId: map['userId'] ?? '',
        userName: map['userName'] ?? '',
        workerId: map['workerId'] ?? '',
        workerName: map['workerName'] ?? '',
        issueCategory: map['issueCategory'] ?? '',
        description: map['description'] ?? '',
        status: map['status'] ?? 'Open',
        resolutionNote: map['resolutionNote'],
        createdAt: map['createdAt'] ?? '',
      );
}

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String timestamp;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'title': title,
        'message': message,
        'timestamp': timestamp,
        'isRead': isRead,
      };

  factory NotificationModel.fromMap(Map<String, dynamic> map) => NotificationModel(
        id: map['id'] ?? '',
        userId: map['userId'] ?? '',
        title: map['title'] ?? '',
        message: map['message'] ?? '',
        timestamp: map['timestamp'] ?? '',
        isRead: map['isRead'] ?? false,
      );
}

class PayoutModel {
  final String id;
  final String workerId;
  final double amount;
  final String requestDate;
  String status; // 'Pending', 'Processed'
  final String bankDetails;

  PayoutModel({
    required this.id,
    required this.workerId,
    required this.amount,
    required this.requestDate,
    this.status = 'Pending',
    required this.bankDetails,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'workerId': workerId,
        'amount': amount,
        'requestDate': requestDate,
        'status': status,
        'bankDetails': bankDetails,
      };

  factory PayoutModel.fromMap(Map<String, dynamic> map) => PayoutModel(
        id: map['id'] ?? '',
        workerId: map['workerId'] ?? '',
        amount: (map['amount'] as num? ?? 0.0).toDouble(),
        requestDate: map['requestDate'] ?? '',
        status: map['status'] ?? 'Pending',
        bankDetails: map['bankDetails'] ?? '',
      );
}

// ============================================================================
// 2. HIVE LOCAL STORAGE SERVICE
// ============================================================================

class HiveStorageService extends GetxService {
  late Box authBox;
  late Box usersBox;
  late Box workersBox;
  late Box categoriesBox;
  late Box bookingsBox;
  late Box chatsBox;
  late Box reviewsBox;
  late Box complaintsBox;
  late Box addressesBox;
  late Box notificationsBox;
  late Box payoutsBox;

  @override
  void onInit() {
    super.onInit();
    authBox = Hive.box('auth_box');
    usersBox = Hive.box('users_box');
    workersBox = Hive.box('workers_box');
    categoriesBox = Hive.box('categories_box');
    bookingsBox = Hive.box('bookings_box');
    chatsBox = Hive.box('chats_box');
    reviewsBox = Hive.box('reviews_box');
    complaintsBox = Hive.box('complaints_box');
    addressesBox = Hive.box('addresses_box');
    notificationsBox = Hive.box('notifications_box');
    payoutsBox = Hive.box('payouts_box');

    _seedInitialDataIfNeeded();
  }

  void _seedInitialDataIfNeeded() {
    if (categoriesBox.isEmpty) {
      final defaultCategories = [
        CategoryModel(
          id: 'cat_plumbing',
          name: 'Plumbing',
          iconName: 'build',
          description: 'Leak fix, pipe repair, drainage & bathroom fittings',
          basePrice: 45.0,
        ),
        CategoryModel(
          id: 'cat_electrical',
          name: 'Electrical',
          iconName: 'flash_on',
          description: 'Wiring, circuit breaker repair & light fixture installation',
          basePrice: 50.0,
        ),
        CategoryModel(
          id: 'cat_ac',
          name: 'AC Repair & HVAC',
          iconName: 'ac_unit',
          description: 'Air conditioning gas refill, filter cleaning & cooling fixes',
          basePrice: 65.0,
        ),
        CategoryModel(
          id: 'cat_cleaning',
          name: 'Deep Cleaning',
          iconName: 'cleaning_services',
          description: 'Full house sanitization, kitchen deep clean & sofa wash',
          basePrice: 40.0,
        ),
        CategoryModel(
          id: 'cat_painting',
          name: 'House Painting',
          iconName: 'format_paint',
          description: 'Interior & exterior wall painting & waterproofing',
          basePrice: 55.0,
        ),
      ];
      for (var cat in defaultCategories) {
        categoriesBox.put(cat.id, cat.toMap());
      }
    }

    if (addressesBox.isEmpty) {
      final defaultAddress = AddressModel(
        id: 'addr_default',
        label: 'Home',
        addressLine: '742 Evergreen Terrace, Downtown',
        city: 'Downtown',
        isDefault: true,
      );
      addressesBox.put(defaultAddress.id, defaultAddress.toMap());
    }
  }

  void saveAuthUser(UserModel user) => authBox.put('current_user', user.toMap());

  UserModel? getAuthUser() {
    final raw = authBox.get('current_user');
    return raw != null ? UserModel.fromMap(Map<String, dynamic>.from(raw)) : null;
  }

  void clearAuth() => authBox.delete('current_user');

  List<CategoryModel> getCategories() {
    return categoriesBox.values
        .map((e) => CategoryModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }
}

// ============================================================================
// 3. GETX CONTROLLERS
// ============================================================================

class AuthController extends GetxController {
  final HiveStorageService _storage = Get.find();
  var currentUser = Rxn<UserModel>();
  var isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    final saved = _storage.getAuthUser();
    if (saved != null) {
      currentUser.value = saved;
      isLoggedIn.value = true;
    } else {
      login('john.doe@user.com', UserRole.user);
    }
  }

  void login(String email, UserRole role) {
    UserModel user;
    if (role == UserRole.admin) {
      user = UserModel(
        id: 'usr_admin',
        name: 'System Admin',
        email: 'admin@homeservice.com',
        phone: '+1 (555) 000-9999',
        role: UserRole.admin,
      );
    } else if (role == UserRole.worker) {
      user = WorkerModel(
        id: 'wrk_alex',
        name: 'Alex Smith',
        email: 'alex.smith@worker.com',
        phone: '+1 (555) 345-6789',
        role: UserRole.worker,
        categoryIds: ['cat_plumbing'],
        bio: 'Licensed Master Plumber with 8+ years experience in commercial & residential plumbing.',
        hourlyRate: 48.0,
        serviceArea: 'Downtown',
        isAvailable: true,
        isApproved: true,
        rating: 4.9,
        reviewCount: 38,
        completedJobsCount: 42,
        totalEarnings: 1840.0,
      );
    } else {
      user = UserModel(
        id: 'usr_john',
        name: 'John Doe',
        email: 'john.doe@user.com',
        phone: '+1 (555) 234-5678',
        role: UserRole.user,
        address: '742 Evergreen Terrace',
        city: 'Downtown',
      );
    }
    currentUser.value = user;
    isLoggedIn.value = true;
    _storage.saveAuthUser(user);
    Get.snackbar(
      'Role Activated',
      'Logged in as ${user.name} (${user.role.name.toUpperCase()})',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.shade900,
      colorText: Colors.white,
    );
  }

  void registerUser({
    required String name,
    required String email,
    required String phone,
    required UserRole role,
    String? categoryId,
    double? hourlyRate,
    String? bio,
    String? serviceArea,
    String? address,
  }) {
    if (role == UserRole.worker) {
      final newWorker = WorkerModel(
        id: 'wrk_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        phone: phone,
        role: UserRole.worker,
        categoryIds: categoryId != null ? [categoryId] : ['cat_plumbing'],
        bio: bio ?? 'Newly registered certified service technician.',
        hourlyRate: hourlyRate ?? 40.0,
        serviceArea: serviceArea ?? 'Downtown',
        isApproved: false,
      );
      Get.find<AdminController>().pendingWorkers.add(newWorker);
      Get.snackbar(
        'Application Submitted',
        'Your worker profile is pending Admin approval.',
        backgroundColor: Colors.amber.shade800,
        colorText: Colors.white,
      );
    } else {
      final newUser = UserModel(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        phone: phone,
        role: UserRole.user,
        address: address ?? 'Downtown Main Street',
        city: 'Downtown',
      );
      currentUser.value = newUser;
      isLoggedIn.value = true;
      _storage.saveAuthUser(newUser);
      Get.snackbar('Registration Complete', 'Welcome to Home Service Hub!');
    }
  }

  void logout() {
    currentUser.value = null;
    isLoggedIn.value = false;
    _storage.clearAuth();
  }
}

class NotificationController extends GetxController {
  var notifications = <NotificationModel>[
    NotificationModel(
      id: 'notif_1',
      userId: 'usr_john',
      title: 'Booking Update',
      message: 'Alex Smith started work on Kitchen Pipe Leak Repair.',
      timestamp: '10:00 AM',
    ),
    NotificationModel(
      id: 'notif_2',
      userId: 'usr_john',
      title: 'New Message',
      message: 'Alex Smith sent a message regarding spare parts.',
      timestamp: '09:18 AM',
    ),
  ].obs;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  void addNotification(String userId, String title, String message) {
    notifications.insert(
      0,
      NotificationModel(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        title: title,
        message: message,
        timestamp: 'Just now',
      ),
    );
  }

  void markAllAsRead() {
    for (var n in notifications) {
      n.isRead = true;
    }
    notifications.refresh();
  }
}

class AddressController extends GetxController {
  var addresses = <AddressModel>[
    AddressModel(
      id: 'addr_1',
      label: 'Home',
      addressLine: '742 Evergreen Terrace',
      city: 'Downtown',
      isDefault: true,
    ),
    AddressModel(
      id: 'addr_2',
      label: 'Office',
      addressLine: '100 Innovation Plaza, Suite 400',
      city: 'Midtown',
      isDefault: false,
    ),
  ].obs;

  void addAddress(String label, String addressLine, String city) {
    final newAddr = AddressModel(
      id: 'addr_${DateTime.now().millisecondsSinceEpoch}',
      label: label,
      addressLine: addressLine,
      city: city,
      isDefault: addresses.isEmpty,
    );
    addresses.add(newAddr);
    Get.snackbar('Address Saved', '$label address added to your profile');
  }

  void deleteAddress(String id) {
    addresses.removeWhere((a) => a.id == id);
    Get.snackbar('Address Deleted', 'Removed from saved locations');
  }

  void setDefault(String id) {
    for (var a in addresses) {
      addresses[addresses.indexOf(a)] = AddressModel(
        id: a.id,
        label: a.label,
        addressLine: a.addressLine,
        city: a.city,
        isDefault: a.id == id,
      );
    }
    addresses.refresh();
    Get.snackbar('Default Updated', 'Primary service address changed');
  }
}

class CategoryController extends GetxController {
  final HiveStorageService _storage = Get.find();
  var categories = <CategoryModel>[].obs;
  var selectedCategoryId = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  void loadCategories() {
    categories.assignAll(_storage.getCategories());
  }

  void addCategory(String name, String iconName, String description, double basePrice) {
    final newCat = CategoryModel(
      id: 'cat_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      iconName: iconName,
      description: description,
      basePrice: basePrice,
    );
    categories.add(newCat);
    _storage.categoriesBox.put(newCat.id, newCat.toMap());
    Get.snackbar('Category Added', '$name service is now active');
  }

  void updateCategory(String id, String name, String description, double basePrice) {
    final idx = categories.indexWhere((c) => c.id == id);
    if (idx != -1) {
      categories[idx].name = name;
      categories[idx].description = description;
      categories[idx].basePrice = basePrice;
      categories.refresh();
      Get.snackbar('Category Updated', '$name details updated');
    }
  }

  void deleteCategory(String id) {
    categories.removeWhere((c) => c.id == id);
    _storage.categoriesBox.delete(id);
    Get.snackbar('Category Removed', 'Service category deleted');
  }
}

class WorkerController extends GetxController {
  var workers = <WorkerModel>[
    WorkerModel(
      id: 'wrk_alex',
      name: 'Alex Smith',
      email: 'alex.smith@worker.com',
      phone: '+1 (555) 345-6789',
      role: UserRole.worker,
      categoryIds: ['cat_plumbing'],
      bio: 'Master Plumber with 8+ yrs experience. Specializes in pipe repairs, leak detection & bathroom fitting.',
      hourlyRate: 48.0,
      serviceArea: 'Downtown',
      isAvailable: true,
      isApproved: true,
      rating: 4.9,
      reviewCount: 38,
      completedJobsCount: 42,
      totalEarnings: 1840.0,
    ),
    WorkerModel(
      id: 'wrk_sarah',
      name: 'Sarah Jenkins',
      email: 'sarah.jenkins@worker.com',
      phone: '+1 (555) 456-7890',
      role: UserRole.worker,
      categoryIds: ['cat_electrical', 'cat_ac'],
      bio: 'Certified Master Electrician & HVAC specialist. Safe, clean, and efficient power wiring.',
      hourlyRate: 55.0,
      serviceArea: 'Westside',
      isAvailable: true,
      isApproved: true,
      rating: 4.8,
      reviewCount: 29,
      completedJobsCount: 31,
      totalEarnings: 1520.0,
    ),
    WorkerModel(
      id: 'wrk_david',
      name: 'David Miller',
      email: 'david.m@worker.com',
      phone: '+1 (555) 987-6543',
      role: UserRole.worker,
      categoryIds: ['cat_cleaning', 'cat_painting'],
      bio: 'Eco-friendly deep cleaning & professional interior wall painter.',
      hourlyRate: 38.0,
      serviceArea: 'Midtown',
      isAvailable: true,
      isApproved: true,
      rating: 5.0,
      reviewCount: 19,
      completedJobsCount: 24,
      totalEarnings: 910.0,
    ),
  ].obs;

  void toggleAvailability(String workerId) {
    final idx = workers.indexWhere((w) => w.id == workerId);
    if (idx != -1) {
      final w = workers[idx];
      w.isAvailable = !w.isAvailable;
      workers.refresh();
      Get.snackbar(
        'Duty Status Updated',
        w.isAvailable ? 'ON DUTY (Accepting Job Requests)' : 'Off Duty (Paused)',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void updateWorkerProfile(String workerId, String bio, double hourlyRate, String serviceArea, List<String> categories) {
    final idx = workers.indexWhere((w) => w.id == workerId);
    if (idx != -1) {
      workers[idx].bio = bio;
      workers[idx].hourlyRate = hourlyRate;
      workers[idx].serviceArea = serviceArea;
      workers[idx].categoryIds = categories;
      workers.refresh();
      Get.snackbar('Profile Updated', 'Duty profile & rate updated successfully');
    }
  }
}

class BookingController extends GetxController {
  var bookings = <BookingModel>[
    BookingModel(
      id: 'bk_1001',
      userId: 'usr_john',
      userName: 'John Doe',
      userPhone: '+1 (555) 234-5678',
      userAddress: '742 Evergreen Terrace, Downtown',
      workerId: 'wrk_alex',
      workerName: 'Alex Smith',
      workerPhone: '+1 (555) 345-6789',
      categoryId: 'cat_plumbing',
      categoryName: 'Plumbing',
      serviceTitle: 'Kitchen Pipe Leak Repair',
      scheduledDate: '2026-08-16',
      scheduledTime: '10:00 AM',
      locationArea: 'Downtown',
      notes: 'Water leaking under the kitchen sink onto hardwood floor.',
      basePrice: 45.0,
      hourlyRate: 48.0,
      estimatedPrice: 93.0,
      status: BookingStatus.inProgress,
    ),
    BookingModel(
      id: 'bk_1002',
      userId: 'usr_john',
      userName: 'John Doe',
      userPhone: '+1 (555) 234-5678',
      userAddress: '742 Evergreen Terrace, Downtown',
      workerId: 'wrk_sarah',
      workerName: 'Sarah Jenkins',
      workerPhone: '+1 (555) 456-7890',
      categoryId: 'cat_electrical',
      categoryName: 'Electrical',
      serviceTitle: 'Living Room Switchboard Installation',
      scheduledDate: '2026-08-18',
      scheduledTime: '02:00 PM',
      locationArea: 'Downtown',
      notes: 'Install 2 new smart wall switches and check circuit breaker.',
      basePrice: 50.0,
      hourlyRate: 55.0,
      estimatedPrice: 105.0,
      status: BookingStatus.pending,
    ),
  ].obs;

  void createBooking({
    required WorkerModel worker,
    required CategoryModel category,
    required String date,
    required String time,
    required String address,
    required String notes,
  }) {
    final auth = Get.find<AuthController>();
    final user = auth.currentUser.value;

    final newBk = BookingModel(
      id: 'bk_${1000 + bookings.length + 1}',
      userId: user?.id ?? 'usr_john',
      userName: user?.name ?? 'John Doe',
      userPhone: user?.phone ?? '+1 (555) 234-5678',
      userAddress: address.isNotEmpty ? address : (user?.address ?? 'Downtown Area'),
      workerId: worker.id,
      workerName: worker.name,
      workerPhone: worker.phone,
      categoryId: category.id,
      categoryName: category.name,
      serviceTitle: '${category.name} Request',
      scheduledDate: date,
      scheduledTime: time,
      locationArea: worker.serviceArea,
      notes: notes,
      basePrice: category.basePrice,
      hourlyRate: worker.hourlyRate,
      estimatedPrice: category.basePrice + worker.hourlyRate,
      status: BookingStatus.pending,
    );

    bookings.insert(0, newBk);
    
    Get.find<NotificationController>().addNotification(
      worker.id,
      'New Job Request',
      '${user?.name ?? "Customer"} requested ${category.name} for $date at $time.',
    );

    Get.snackbar(
      'Service Booked!',
      'Request submitted to ${worker.name}. Status: Pending Acceptance',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.shade700,
      colorText: Colors.white,
    );
  }

  void updateStatus(String bookingId, BookingStatus newStatus, {String? reason}) {
    final idx = bookings.indexWhere((b) => b.id == bookingId);
    if (idx != -1) {
      bookings[idx].status = newStatus;
      if (reason != null) {
        if (newStatus == BookingStatus.rejected) bookings[idx].rejectionReason = reason;
        if (newStatus == BookingStatus.cancelled) bookings[idx].cancelReason = reason;
      }
      bookings.refresh();

      final bk = bookings[idx];
      final targetUserId = bk.userId;
      Get.find<NotificationController>().addNotification(
        targetUserId,
        'Booking Status Update',
        'Job #${bk.id} (${bk.serviceTitle}) is now ${newStatus.name.toUpperCase()}.',
      );

      if (newStatus == BookingStatus.completed) {
        final wIdx = Get.find<WorkerController>().workers.indexWhere((w) => w.id == bk.workerId);
        if (wIdx != -1) {
          final w = Get.find<WorkerController>().workers[wIdx];
          w.completedJobsCount += 1;
          w.totalEarnings += bk.estimatedPrice * 0.85; // 85% to worker
          Get.find<WorkerController>().workers.refresh();
        }
      }

      Get.snackbar(
        'Booking Updated',
        'Booking #${bookings[idx].id} is now ${newStatus.name.toUpperCase()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void rescheduleBooking(String bookingId, String newDate, String newTime) {
    final idx = bookings.indexWhere((b) => b.id == bookingId);
    if (idx != -1) {
      bookings[idx].scheduledDate = newDate;
      bookings[idx].scheduledTime = newTime;
      bookings.refresh();
      Get.snackbar('Rescheduled', 'Booking updated to $newDate at $newTime');
    }
  }
}

class ChatController extends GetxController {
  var messages = <ChatMessageModel>[
    ChatMessageModel(
      id: 'msg_1',
      bookingId: 'bk_1001',
      senderId: 'usr_john',
      senderName: 'John Doe',
      senderRole: 'user',
      text: 'Hi Alex! Will you be bringing spare PVC pipes?',
      timestamp: '09:15 AM',
    ),
    ChatMessageModel(
      id: 'msg_2',
      bookingId: 'bk_1001',
      senderId: 'wrk_alex',
      senderName: 'Alex Smith',
      senderRole: 'worker',
      text: 'Hello John! Yes, I have standard 1/2 inch and 3/4 inch replacement fittings.',
      timestamp: '09:18 AM',
    ),
  ].obs;

  void sendMessage(String bookingId, String text) {
    if (text.trim().isEmpty) return;
    final user = Get.find<AuthController>().currentUser.value;
    if (user == null) return;

    messages.add(ChatMessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      bookingId: bookingId,
      senderId: user.id,
      senderName: user.name,
      senderRole: user.role.name,
      text: text,
      timestamp: 'Just now',
    ));
  }
}

class ReviewController extends GetxController {
  var reviews = <ReviewModel>[
    ReviewModel(
      id: 'rev_1',
      bookingId: 'bk_99',
      workerId: 'wrk_alex',
      userId: 'usr_john',
      userName: 'John Doe',
      rating: 5.0,
      comment: 'Alex arrived right on time and fixed the pipe burst under 40 minutes! Excellent service.',
      date: '2026-08-10',
      workerReply: 'Thank you John! Happy to keep your home water pipes leak-free.',
    ),
  ].obs;

  void addReview(String bookingId, String workerId, double rating, String comment) {
    final user = Get.find<AuthController>().currentUser.value;
    final newRev = ReviewModel(
      id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
      bookingId: bookingId,
      workerId: workerId,
      userId: user?.id ?? 'usr_john',
      userName: user?.name ?? 'John Doe',
      rating: rating,
      comment: comment,
      date: '2026-08-12',
    );
    reviews.insert(0, newRev);
    Get.snackbar('Review Submitted', 'Thank you for your feedback!');
  }

  void replyToReview(String reviewId, String reply) {
    final idx = reviews.indexWhere((r) => r.id == reviewId);
    if (idx != -1) {
      reviews[idx].workerReply = reply;
      reviews.refresh();
      Get.snackbar('Reply Published', 'Your response is now visible to clients.');
    }
  }
}

class ComplaintController extends GetxController {
  var complaints = <ComplaintModel>[
    ComplaintModel(
      id: 'cmp_1',
      bookingId: 'bk_1001',
      userId: 'usr_john',
      userName: 'John Doe',
      workerId: 'wrk_alex',
      workerName: 'Alex Smith',
      issueCategory: 'Late Arrival',
      description: 'Worker arrived 25 minutes after the scheduled slot without prior notice.',
      status: 'Open',
      createdAt: '2026-08-11',
    ),
  ].obs;

  void fileComplaint(String bookingId, String workerId, String workerName, String category, String details) {
    final user = Get.find<AuthController>().currentUser.value;
    final cmp = ComplaintModel(
      id: 'cmp_${DateTime.now().millisecondsSinceEpoch}',
      bookingId: bookingId,
      userId: user?.id ?? 'usr_john',
      userName: user?.name ?? 'John Doe',
      workerId: workerId,
      workerName: workerName,
      issueCategory: category,
      description: details,
      createdAt: '2026-08-12',
    );
    complaints.insert(0, cmp);
    Get.snackbar('Complaint Filed', 'Support team will review your ticket within 24 hours');
  }

  void resolveComplaint(String id, String note) {
    final idx = complaints.indexWhere((c) => c.id == id);
    if (idx != -1) {
      complaints[idx].status = 'Resolved';
      complaints[idx].resolutionNote = note;
      complaints.refresh();
      Get.snackbar('Resolved', 'Complaint ticket marked as resolved.');
    }
  }
}

class PayoutController extends GetxController {
  var payouts = <PayoutModel>[
    PayoutModel(
      id: 'pay_101',
      workerId: 'wrk_alex',
      amount: 450.0,
      requestDate: '2026-08-01',
      status: 'Processed',
      bankDetails: 'Chase Bank (**** 4829)',
    ),
  ].obs;

  void requestPayout(String workerId, double amount, String bankDetails) {
    if (amount <= 0) {
      Get.snackbar('Invalid Amount', 'Enter a valid payout amount');
      return;
    }
    payouts.insert(
      0,
      PayoutModel(
        id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
        workerId: workerId,
        amount: amount,
        requestDate: '2026-08-12',
        status: 'Pending',
        bankDetails: bankDetails,
      ),
    );
    Get.snackbar('Payout Requested', 'Withdrawal request submitted to admin for processing.');
  }

  void processPayout(String id) {
    final idx = payouts.indexWhere((p) => p.id == id);
    if (idx != -1) {
      payouts[idx].status = 'Processed';
      payouts.refresh();
      Get.snackbar('Payout Processed', 'Funds transferred to worker bank account.');
    }
  }
}

class AdminController extends GetxController {
  var pendingWorkers = <WorkerModel>[
    WorkerModel(
      id: 'wrk_michael',
      name: 'Michael Brown',
      email: 'michael@worker.com',
      phone: '+1 (555) 567-8901',
      role: UserRole.worker,
      categoryIds: ['cat_cleaning'],
      bio: 'Eco-cleaning technician specializing in sanitization.',
      hourlyRate: 35.0,
      serviceArea: 'North Hill',
      isApproved: false,
    ),
  ].obs;

  var allRegisteredUsers = <UserModel>[
    UserModel(
      id: 'usr_john',
      name: 'John Doe',
      email: 'john.doe@user.com',
      phone: '+1 (555) 234-5678',
      role: UserRole.user,
      address: '742 Evergreen Terrace',
      city: 'Downtown',
    ),
    UserModel(
      id: 'usr_alice',
      name: 'Alice Cooper',
      email: 'alice@user.com',
      phone: '+1 (555) 888-1122',
      role: UserRole.user,
      address: '12 Oak Lane',
      city: 'Westside',
    ),
  ].obs;

  void approveWorker(WorkerModel w) {
    pendingWorkers.remove(w);
    Get.find<WorkerController>().workers.add(WorkerModel(
      id: w.id,
      name: w.name,
      email: w.email,
      phone: w.phone,
      role: w.role,
      categoryIds: w.categoryIds,
      bio: w.bio,
      hourlyRate: w.hourlyRate,
      serviceArea: w.serviceArea,
      isApproved: true,
    ));
    Get.snackbar('Approved!', '${w.name} is now an active verified pro.');
  }

  void rejectWorker(WorkerModel w) {
    pendingWorkers.remove(w);
    Get.snackbar('Rejected', 'Application for ${w.name} was declined.');
  }

  void toggleDisableUser(String userId) {
    final idx = allRegisteredUsers.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      allRegisteredUsers[idx].isDisabled = !allRegisteredUsers[idx].isDisabled;
      allRegisteredUsers.refresh();
      Get.snackbar('User Status Updated', 'Account state changed.');
    }
  }
}

// ============================================================================
// 4. MAIN APP ENTRY POINT
// ============================================================================

class HomeServiceApp extends StatelessWidget {
  const HomeServiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Home Service Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const RootNavigationHandler(),
    );
  }
}

class RootNavigationHandler extends StatelessWidget {
  const RootNavigationHandler({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController auth = Get.find();
    return Obx(() {
      if (!auth.isLoggedIn.value) return const LoginScreen();
      final role = auth.currentUser.value?.role;
      if (role == UserRole.admin) return const AdminMainShell();
      if (role == UserRole.worker) return const WorkerMainShell();
      return const UserMainShell();
    });
  }
}

// ============================================================================
// 5. AUTHENTICATION, LOGIN & REGISTER SCREENS
// ============================================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController(text: 'john.doe@user.com');
  final _passCtrl = TextEditingController(text: 'password123');

  @override
  Widget build(BuildContext context) {
    final AuthController auth = Get.find();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.home_repair_service, size: 64, color: Color(0xFF1E88E5)),
                    const SizedBox(height: 12),
                    Text(
                      'Home Service Hub',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E88E5),
                          ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'On-Demand Home Repairs & Maintenance',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _emailCtrl,
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passCtrl,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFF1E88E5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => auth.login(_emailCtrl.text, UserRole.user),
                      child: const Text('Sign In to Account', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Get.to(() => const RegisterScreen()),
                      child: const Text("Don't have an account? Register Here"),
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('QUICK ROLE SWITCHER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.person),
                      label: const Text('Login as Customer'),
                      onPressed: () => auth.login('john.doe@user.com', UserRole.user),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.engineering),
                      label: const Text('Login as Service Pro (Worker)'),
                      onPressed: () => auth.login('alex.smith@worker.com', UserRole.worker),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.admin_panel_settings),
                      label: const Text('Login as Admin Console'),
                      onPressed: () => auth.login('admin@homeservice.com', UserRole.admin),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  UserRole _selectedRole = UserRole.user;
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _rateCtrl = TextEditingController(text: '45');
  final _areaCtrl = TextEditingController(text: 'Downtown');
  final _addressCtrl = TextEditingController();
  String _selectedCategory = 'cat_plumbing';

  @override
  Widget build(BuildContext context) {
    final AuthController auth = Get.find();
    final CategoryController catCtrl = Get.find();

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<UserRole>(
              segments: const [
                ButtonSegment(value: UserRole.user, label: Text('Customer'), icon: Icon(Icons.person)),
                ButtonSegment(value: UserRole.worker, label: Text('Service Pro'), icon: Icon(Icons.engineering)),
              ],
              selected: {_selectedRole},
              onSelectionChanged: (set) => setState(() => _selectedRole = set.first),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),

            if (_selectedRole == UserRole.user) ...[
              TextField(
                controller: _addressCtrl,
                decoration: const InputDecoration(labelText: 'Default Service Address', border: OutlineInputBorder()),
              ),
            ],

            if (_selectedRole == UserRole.worker) ...[
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Primary Skill Category', border: OutlineInputBorder()),
                items: catCtrl.categories.map((cat) {
                  return DropdownMenuItem(value: cat.id, child: Text(cat.name));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _rateCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Hourly Rate (\$)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _areaCtrl,
                decoration: const InputDecoration(labelText: 'Service Area / City', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _bioCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Professional Bio / Experience', border: OutlineInputBorder()),
              ),
            ],

            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF1E88E5),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                auth.registerUser(
                  name: _nameCtrl.text.isNotEmpty ? _nameCtrl.text : 'New User',
                  email: _emailCtrl.text.isNotEmpty ? _emailCtrl.text : 'user@example.com',
                  phone: _phoneCtrl.text.isNotEmpty ? _phoneCtrl.text : '+1 (555) 000-1111',
                  role: _selectedRole,
                  categoryId: _selectedCategory,
                  hourlyRate: double.tryParse(_rateCtrl.text) ?? 45.0,
                  bio: _bioCtrl.text,
                  serviceArea: _areaCtrl.text,
                  address: _addressCtrl.text,
                );
                Get.back();
              },
              child: Text(
                _selectedRole == UserRole.worker ? 'Submit Worker Application' : 'Register Customer Account',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 6. USER MAIN NAVIGATION SHELL (4 TABS)
// ============================================================================

class UserMainShell extends StatefulWidget {
  const UserMainShell({super.key});

  @override
  State<UserMainShell> createState() => _UserMainShellState();
}

class _UserMainShellState extends State<UserMainShell> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const UserBrowseTab(),
    const UserBookingsTab(),
    const UserMessagesTab(),
    const UserProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: const Color(0xFF1E88E5),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

// --- USER TAB 1: BROWSE SERVICES & PROS ---
class UserBrowseTab extends StatefulWidget {
  const UserBrowseTab({super.key});

  @override
  State<UserBrowseTab> createState() => _UserBrowseTabState();
}

class _UserBrowseTabState extends State<UserBrowseTab> {
  String selectedCity = 'All Cities';
  String searchQuery = '';
  String selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final CategoryController catCtrl = Get.find();
    final WorkerController workerCtrl = Get.find();
    final NotificationController notifCtrl = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Service Hub', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Obx(() => Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () => Get.to(() => const NotificationScreen()),
                  ),
                  if (notifCtrl.unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: CircleAvatar(
                        radius: 8,
                        backgroundColor: Colors.red,
                        child: Text('${notifCtrl.unreadCount}', style: const TextStyle(fontSize: 10, color: Colors.white)),
                      ),
                    )
                ],
              )),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: DropdownButton<String>(
              value: selectedCity,
              underline: const SizedBox(),
              icon: const Icon(Icons.location_on, color: Color(0xFF1E88E5)),
              items: ['All Cities', 'Downtown', 'Westside', 'Midtown', 'North Hill']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12))))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => selectedCity = val);
              },
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search plumbing, electrical, cleaning...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade900, Colors.indigo.shade800],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade400.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'VERIFIED PROS ON DEMAND',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Book Skilled Technicians in Minutes',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Transparent hourly rates, background checked workers & instant scheduling.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Service Categories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Obx(() => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All Services'),
                        selected: selectedCategory == 'all',
                        onSelected: (_) => setState(() => selectedCategory = 'all'),
                      ),
                      const SizedBox(width: 8),
                      ...catCtrl.categories.map((cat) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(cat.name),
                            selected: selectedCategory == cat.id,
                            onSelected: (_) => setState(() => selectedCategory = cat.id),
                          ),
                        );
                      }),
                    ],
                  ),
                )),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Top Rated Service Pros', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('${workerCtrl.workers.length} Available', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() {
              final list = workerCtrl.workers.where((w) {
                if (!w.isApproved || w.isDisabled) return false;
                if (selectedCategory != 'all' && !w.categoryIds.contains(selectedCategory)) return false;
                if (selectedCity != 'All Cities' && w.serviceArea != selectedCity) return false;
                if (searchQuery.isNotEmpty && !w.name.toLowerCase().contains(searchQuery.toLowerCase())) return false;
                return true;
              }).toList();

              if (list.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('No service professionals match your search filter.', style: TextStyle(color: Colors.grey)),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length,
                itemBuilder: (ctx, i) {
                  final wrk = list[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.blue.shade100,
                            child: Text(wrk.name[0], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(wrk.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.verified, size: 16, color: Colors.blue),
                                  ],
                                ),
                                Text('${wrk.serviceArea} • \$${wrk.hourlyRate.toInt()}/hr', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star, size: 14, color: Colors.amber),
                                    Text(' ${wrk.rating.toStringAsFixed(1)} (${wrk.reviewCount} reviews)', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E88E5),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Book'),
                            onPressed: () => Get.to(() => WorkerDetailScreen(worker: wrk)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

// --- USER TAB 2: MY BOOKINGS ---
class UserBookingsTab extends StatelessWidget {
  const UserBookingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final BookingController bookingCtrl = Get.find();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Booking Requests'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: Obx(() {
          final allBookings = bookingCtrl.bookings;

          return TabBarView(
            children: [
              _buildBookingList(
                context,
                allBookings.where((b) => b.status == BookingStatus.pending || b.status == BookingStatus.accepted || b.status == BookingStatus.inProgress).toList(),
              ),
              _buildBookingList(
                context,
                allBookings.where((b) => b.status == BookingStatus.completed).toList(),
              ),
              _buildBookingList(
                context,
                allBookings.where((b) => b.status == BookingStatus.cancelled || b.status == BookingStatus.rejected).toList(),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildBookingList(BuildContext context, List<BookingModel> list) {
    if (list.isEmpty) {
      return const Center(child: Text('No bookings found in this section.', style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (ctx, i) {
        final bk = list[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(bk.serviceTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: bk.status == BookingStatus.completed
                            ? Colors.green.shade100
                            : (bk.status == BookingStatus.inProgress ? Colors.amber.shade100 : Colors.blue.shade100),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        bk.status.name.toUpperCase(),
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Service Pro: ${bk.workerName} (${bk.workerPhone})', style: const TextStyle(fontSize: 13)),
                Text('Scheduled: ${bk.scheduledDate} at ${bk.scheduledTime}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                Text('Estimated Total: \$${bk.estimatedPrice.toInt()}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blue)),
                const Divider(),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  alignment: WrapAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.receipt_long, size: 16),
                      label: const Text('Receipt'),
                      onPressed: () => _showReceiptDialog(context, bk),
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.chat_bubble_outline, size: 16),
                      label: const Text('Chat'),
                      onPressed: () => Get.to(() => ChatScreen(booking: bk)),
                    ),
                    if (bk.status == BookingStatus.pending) ...[
                      OutlinedButton(
                        child: const Text('Reschedule'),
                        onPressed: () => _showRescheduleDialog(context, bk),
                      ),
                      TextButton(
                        child: const Text('Cancel Request', style: TextStyle(color: Colors.red)),
                        onPressed: () => _showCancelDialog(context, bk),
                      ),
                    ],
                    if (bk.status == BookingStatus.completed) ...[
                      ElevatedButton(
                        child: const Text('Rate Pro'),
                        onPressed: () => _showRatingDialog(context, bk),
                      ),
                      TextButton(
                        child: const Text('File Dispute', style: TextStyle(color: Colors.orange)),
                        onPressed: () => _showDisputeDialog(context, bk),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showReceiptDialog(BuildContext context, BookingModel bk) {
    Get.dialog(
      AlertDialog(
        title: Text('Receipt #${bk.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category Base Fee: \$${bk.basePrice.toInt()}'),
            Text('Worker Hourly Rate: \$${bk.hourlyRate.toInt()}'),
            const Text('Platform Service Fee: \$5.00'),
            const Divider(),
            Text('Total Charged: \$${(bk.estimatedPrice + 5.0).toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            const Text('Payment Method: Direct Card / Cash on Completion', style: TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showRescheduleDialog(BuildContext context, BookingModel bk) {
    final dateCtrl = TextEditingController(text: bk.scheduledDate);
    final timeCtrl = TextEditingController(text: bk.scheduledTime);

    Get.dialog(
      AlertDialog(
        title: const Text('Reschedule Service Slot'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'New Date (YYYY-MM-DD)')),
            TextField(controller: timeCtrl, decoration: const InputDecoration(labelText: 'New Time Slot')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.find<BookingController>().rescheduleBooking(bk.id, dateCtrl.text, timeCtrl.text);
              Get.back();
            },
            child: const Text('Update Slot'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, BookingModel bk) {
    final reasonCtrl = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Reason for cancellation:'),
            const SizedBox(height: 8),
            TextField(controller: reasonCtrl, decoration: const InputDecoration(hintText: 'Change of plans, emergency...')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Back')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Get.find<BookingController>().updateStatus(bk.id, BookingStatus.cancelled, reason: reasonCtrl.text);
              Get.back();
            },
            child: const Text('Confirm Cancel'),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context, BookingModel bk) {
    double rating = 5.0;
    final commentCtrl = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('Rate ${bk.workerName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('How satisfied were you with the service?'),
            const SizedBox(height: 12),
            TextField(
              controller: commentCtrl,
              decoration: const InputDecoration(hintText: 'Write feedback comment...'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.find<ReviewController>().addReview(bk.id, bk.workerId, rating, commentCtrl.text);
              Get.back();
            },
            child: const Text('Submit Review'),
          ),
        ],
      ),
    );
  }

  void _showDisputeDialog(BuildContext context, BookingModel bk) {
    String category = 'Late Arrival';
    final detailsCtrl = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('File Dispute Ticket'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              value: category,
              isExpanded: true,
              items: ['Late Arrival', 'Incomplete Work', 'Unprofessional', 'Price Dispute']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) {
                if (val != null) category = val;
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: detailsCtrl,
              maxLines: 2,
              decoration: const InputDecoration(hintText: 'Describe issue details...'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.find<ComplaintController>().fileComplaint(bk.id, bk.workerId, bk.workerName, category, detailsCtrl.text);
              Get.back();
            },
            child: const Text('Submit Ticket'),
          ),
        ],
      ),
    );
  }
}

// --- USER TAB 3: MESSAGES ---
class UserMessagesTab extends StatelessWidget {
  const UserMessagesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final BookingController bookingCtrl = Get.find();

    return Scaffold(
      appBar: AppBar(title: const Text('Messages & Support')),
      body: Obx(() {
        final bookings = bookingCtrl.bookings;
        if (bookings.isEmpty) {
          return const Center(child: Text('No active chats. Book a service to chat with a pro.'));
        }

        return ListView.builder(
          itemCount: bookings.length,
          itemBuilder: (ctx, i) {
            final bk = bookings[i];
            return ListTile(
              leading: CircleAvatar(child: Text(bk.workerName[0])),
              title: Text(bk.workerName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${bk.serviceTitle} • ${bk.scheduledDate}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Get.to(() => ChatScreen(booking: bk)),
            );
          },
        );
      }),
    );
  }
}

// --- USER TAB 4: PROFILE & ACCOUNT ---
class UserProfileTab extends StatelessWidget {
  const UserProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController auth = Get.find();
    final AddressController addrCtrl = Get.find();

    return Scaffold(
      appBar: AppBar(title: const Text('My Account Profile')),
      body: Obx(() {
        final user = auth.currentUser.value;
        final defaultAddr = addrCtrl.addresses.firstWhereOrNull((a) => a.isDefault) ?? addrCtrl.addresses.firstOrNull;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue.shade100,
                    child: Text(user?.name[0] ?? 'U', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),
                  Text(user?.name ?? 'User Name', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(user?.email ?? '', style: const TextStyle(color: Colors.grey)),
                  Text(user?.phone ?? '', style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: const Text('Saved Address Book'),
              subtitle: Text(defaultAddr != null ? '${defaultAddr.label}: ${defaultAddr.addressLine}' : 'Add locations'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showAddressBookSheet(context),
            ),
            ListTile(
              leading: const Icon(Icons.switch_account_outlined),
              title: const Text('Switch Role Persona'),
              subtitle: const Text('Test Worker or Admin view'),
              onTap: () => _showRoleSwitchDialog(context),
            ),
            ListTile(
              leading: const Icon(Icons.support_agent),
              title: const Text('Customer Help & Hotline'),
              onTap: () => Get.snackbar('Support Hotline', 'Call toll-free: 1-800-HOME-HUB'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
                padding: const EdgeInsets.all(14),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Logout of Account'),
              onPressed: () => auth.logout(),
            ),
          ],
        );
      }),
    );
  }

  void _showAddressBookSheet(BuildContext context) {
    final AddressController addrCtrl = Get.find();
    final labelCtrl = TextEditingController();
    final lineCtrl = TextEditingController();
    final cityCtrl = TextEditingController(text: 'Downtown');

    Get.bottomSheet(
      Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Saved Locations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Obx(() => ListView.builder(
                    shrinkWrap: true,
                    itemCount: addrCtrl.addresses.length,
                    itemBuilder: (ctx, i) {
                      final a = addrCtrl.addresses[i];
                      return ListTile(
                        title: Text('${a.label} ${a.isDefault ? "(Default)" : ""}'),
                        subtitle: Text(a.addressLine),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => addrCtrl.deleteAddress(a.id),
                        ),
                        onTap: () => addrCtrl.setDefault(a.id),
                      );
                    },
                  )),
              const Divider(),
              const Text('Add New Address', style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(controller: labelCtrl, decoration: const InputDecoration(labelText: 'Label (Home, Office)')),
              TextField(controller: lineCtrl, decoration: const InputDecoration(labelText: 'Street Address')),
              TextField(controller: cityCtrl, decoration: const InputDecoration(labelText: 'City')),
              const SizedBox(height: 12),
              ElevatedButton(
                child: const Text('Save Address'),
                onPressed: () {
                  if (lineCtrl.text.isNotEmpty) {
                    addrCtrl.addAddress(labelCtrl.text.isEmpty ? 'Home' : labelCtrl.text, lineCtrl.text, cityCtrl.text);
                    labelCtrl.clear();
                    lineCtrl.clear();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRoleSwitchDialog(BuildContext context) {
    final AuthController auth = Get.find();
    Get.dialog(
      SimpleDialog(
        title: const Text('Switch Role Persona'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Get.back();
              auth.login('john.doe@user.com', UserRole.user);
            },
            child: const Text('User (Customer) View'),
          ),
          SimpleDialogOption(
            onPressed: () {
              Get.back();
              auth.login('alex.smith@worker.com', UserRole.worker);
            },
            child: const Text('Worker (Service Pro) View'),
          ),
          SimpleDialogOption(
            onPressed: () {
              Get.back();
              auth.login('admin@homeservice.com', UserRole.admin);
            },
            child: const Text('Admin Console View'),
          ),
        ],
      ),
    );
  }
}

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationController notifCtrl = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            child: const Text('Mark Read', style: TextStyle(color: Colors.white)),
            onPressed: () => notifCtrl.markAllAsRead(),
          )
        ],
      ),
      body: Obx(() {
        if (notifCtrl.notifications.isEmpty) {
          return const Center(child: Text('No notifications.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: notifCtrl.notifications.length,
          itemBuilder: (ctx, i) {
            final n = notifCtrl.notifications[i];
            return Card(
              color: n.isRead ? Colors.white : Colors.blue.shade50,
              child: ListTile(
                leading: Icon(Icons.notifications, color: n.isRead ? Colors.grey : Colors.blue),
                title: Text(n.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${n.message}\n${n.timestamp}'),
              ),
            );
          },
        );
      }),
    );
  }
}

// ============================================================================
// 7. WORKER MAIN SHELL & DASHBOARD (4 TABS)
// ============================================================================

class WorkerMainShell extends StatefulWidget {
  const WorkerMainShell({super.key});

  @override
  State<WorkerMainShell> createState() => _WorkerMainShellState();
}

class _WorkerMainShellState extends State<WorkerMainShell> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const WorkerJobRequestsTab(),
    const WorkerEarningsTab(),
    const WorkerReviewsTab(),
    const WorkerDutyProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: Colors.blue.shade800,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Job Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.payments_outlined), label: 'Earnings'),
          BottomNavigationBarItem(icon: Icon(Icons.star_outline), label: 'Reviews'),
          BottomNavigationBarItem(icon: Icon(Icons.work_outline), label: 'Duty Settings'),
        ],
      ),
    );
  }
}

class WorkerJobRequestsTab extends StatelessWidget {
  const WorkerJobRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final BookingController bookingCtrl = Get.find();
    final AuthController auth = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Worker Service Console'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => auth.logout()),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: const Color(0xFF1565C0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Duty Status: ON DUTY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.blue.shade900),
                          child: const Text('Toggle Status'),
                          onPressed: () => Get.find<WorkerController>().toggleAvailability('wrk_alex'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('Monthly Balance: \$1,840.00', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const Text('Completed Jobs: 42 • Rating: ⭐ 4.9', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Incoming & Active Jobs', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            Obx(() {
              final jobs = bookingCtrl.bookings;
              if (jobs.isEmpty) {
                return const Center(child: Text('No job requests assigned.'));
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: jobs.length,
                itemBuilder: (ctx, i) {
                  final bk = jobs[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(bk.serviceTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Chip(label: Text(bk.status.name.toUpperCase()), backgroundColor: Colors.blue.shade50),
                            ],
                          ),
                          Text('Customer: ${bk.userName} (${bk.userPhone})'),
                          Text('Address: ${bk.userAddress}'),
                          Text('Date: ${bk.scheduledDate} at ${bk.scheduledTime}'),
                          Text('Estimated Payout (85%): \$${(bk.estimatedPrice * 0.85).toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chat),
                                onPressed: () => Get.to(() => ChatScreen(booking: bk)),
                              ),
                              if (bk.status == BookingStatus.pending) ...[
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                  child: const Text('Accept Job'),
                                  onPressed: () => bookingCtrl.updateStatus(bk.id, BookingStatus.accepted),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  child: const Text('Decline'),
                                  onPressed: () => bookingCtrl.updateStatus(bk.id, BookingStatus.rejected, reason: 'Worker busy'),
                                ),
                              ],
                              if (bk.status == BookingStatus.accepted)
                                ElevatedButton(
                                  child: const Text('Start Work'),
                                  onPressed: () => bookingCtrl.updateStatus(bk.id, BookingStatus.inProgress),
                                ),
                              if (bk.status == BookingStatus.inProgress)
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                  child: const Text('Complete Job'),
                                  onPressed: () => bookingCtrl.updateStatus(bk.id, BookingStatus.completed),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class WorkerEarningsTab extends StatelessWidget {
  const WorkerEarningsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final PayoutController payoutCtrl = Get.find();
    final bankCtrl = TextEditingController(text: 'Chase Bank (**** 4829)');
    final amountCtrl = TextEditingController(text: '200');

    return Scaffold(
      appBar: AppBar(title: const Text('Earnings & Payouts')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.green.shade800,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Available Balance', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 4),
                  const Text('\$1,840.00', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.green.shade900),
                    child: const Text('Request Payout Withdrawal'),
                    onPressed: () {
                      Get.dialog(
                        AlertDialog(
                          title: const Text('Request Payout'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(controller: amountCtrl, decoration: const InputDecoration(labelText: 'Amount (\$)')),
                              TextField(controller: bankCtrl, decoration: const InputDecoration(labelText: 'Bank Account')),
                            ],
                          ),
                          actions: [
                            TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                            ElevatedButton(
                              onPressed: () {
                                payoutCtrl.requestPayout('wrk_alex', double.tryParse(amountCtrl.text) ?? 100, bankCtrl.text);
                                Get.back();
                              },
                              child: const Text('Submit Request'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Payout Withdrawal History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Obx(() => ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: payoutCtrl.payouts.length,
                itemBuilder: (ctx, i) {
                  final p = payoutCtrl.payouts[i];
                  return Card(
                    child: ListTile(
                      title: Text('\$${p.amount.toInt()} • ${p.bankDetails}'),
                      subtitle: Text('Requested: ${p.requestDate}'),
                      trailing: Chip(
                        label: Text(p.status),
                        backgroundColor: p.status == 'Processed' ? Colors.green.shade100 : Colors.amber.shade100,
                      ),
                    ),
                  );
                },
              )),
        ],
      ),
    );
  }
}

class WorkerReviewsTab extends StatelessWidget {
  const WorkerReviewsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final ReviewController revCtrl = Get.find();
    final replyCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Client Reviews & Feedback')),
      body: Obx(() {
        final workerReviews = revCtrl.reviews.where((r) => r.workerId == 'wrk_alex').toList();
        if (workerReviews.isEmpty) {
          return const Center(child: Text('No reviews yet.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: workerReviews.length,
          itemBuilder: (ctx, i) {
            final r = workerReviews[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(r.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('⭐ ${r.rating.toStringAsFixed(1)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                      ],
                    ),
                    Text(r.date, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(r.comment),
                    if (r.workerReply != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                        child: Text('Your Reply: ${r.workerReply}', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                      ),
                    ] else ...[
                      const SizedBox(height: 8),
                      TextButton(
                        child: const Text('Reply to Review'),
                        onPressed: () {
                          Get.dialog(
                            AlertDialog(
                              title: const Text('Reply to Client'),
                              content: TextField(controller: replyCtrl, decoration: const InputDecoration(hintText: 'Thank you for your feedback...')),
                              actions: [
                                TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                                ElevatedButton(
                                  onPressed: () {
                                    revCtrl.replyToReview(r.id, replyCtrl.text);
                                    replyCtrl.clear();
                                    Get.back();
                                  },
                                  child: const Text('Post Reply'),
                                )
                              ],
                            ),
                          );
                        },
                      )
                    ]
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class WorkerDutyProfileTab extends StatelessWidget {
  const WorkerDutyProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController auth = Get.find();
    final WorkerController workerCtrl = Get.find();

    final worker = workerCtrl.workers.firstWhere((w) => w.id == 'wrk_alex');
    final bioCtrl = TextEditingController(text: worker.bio);
    final rateCtrl = TextEditingController(text: worker.hourlyRate.toInt().toString());
    final areaCtrl = TextEditingController(text: worker.serviceArea);

    return Scaffold(
      appBar: AppBar(title: const Text('Worker Duty Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: bioCtrl, decoration: const InputDecoration(labelText: 'Bio / Qualification', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: rateCtrl, decoration: const InputDecoration(labelText: 'Hourly Rate (\$)', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: areaCtrl, decoration: const InputDecoration(labelText: 'Service Area City', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          ElevatedButton(
            child: const Text('Save Duty Profile'),
            onPressed: () {
              workerCtrl.updateWorkerProfile('wrk_alex', bioCtrl.text, double.tryParse(rateCtrl.text) ?? 45.0, areaCtrl.text, ['cat_plumbing']);
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade50, foregroundColor: Colors.red),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            onPressed: () => auth.logout(),
          )
        ],
      ),
    );
  }
}

// ============================================================================
// 8. ADMIN MAIN SHELL & CONSOLE (4 TABS)
// ============================================================================

class AdminMainShell extends StatefulWidget {
  const AdminMainShell({super.key});

  @override
  State<AdminMainShell> createState() => _AdminMainShellState();
}

class _AdminMainShellState extends State<AdminMainShell> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const AdminOverviewTab(),
    const AdminPendingApprovalsTab(),
    const AdminCategoriesTab(),
    const AdminUsersTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final AuthController auth = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Management Console'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => auth.logout()),
        ],
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: Colors.blue.shade900,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Overview'),
          BottomNavigationBarItem(icon: Icon(Icons.verified_user), label: 'Approvals'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Categories'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users & Disputes'),
        ],
      ),
    );
  }
}

class AdminOverviewTab extends StatelessWidget {
  const AdminOverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    final BookingController bkCtrl = Get.find();
    final WorkerController wrkCtrl = Get.find();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Card(
                  color: Colors.blue.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text('Total Bookings', style: TextStyle(fontSize: 12)),
                        Text('${bkCtrl.bookings.length}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  color: Colors.green.shade100,
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text('Platform Revenue (15%)', style: TextStyle(fontSize: 12)),
                        Text('\$1,867', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Card(
                  color: Colors.purple.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text('Active Service Pros', style: TextStyle(fontSize: 12)),
                        Text('${wrkCtrl.workers.length}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AdminPendingApprovalsTab extends StatelessWidget {
  const AdminPendingApprovalsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminController adminCtrl = Get.find();

    return Obx(() {
      if (adminCtrl.pendingWorkers.isEmpty) {
        return const Center(child: Text('No pending worker approval applications.'));
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: adminCtrl.pendingWorkers.length,
        itemBuilder: (ctx, i) {
          final w = adminCtrl.pendingWorkers[i];
          return Card(
            child: ListTile(
              title: Text(w.name),
              subtitle: Text('Area: ${w.serviceArea} • Rate: \$${w.hourlyRate.toInt()}/hr\n${w.bio}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.check_circle, color: Colors.green), onPressed: () => adminCtrl.approveWorker(w)),
                  IconButton(icon: const Icon(Icons.cancel, color: Colors.red), onPressed: () => adminCtrl.rejectWorker(w)),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}

class AdminCategoriesTab extends StatelessWidget {
  const AdminCategoriesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final CategoryController catCtrl = Get.find();
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController(text: '40');

    return Scaffold(
      body: Obx(() => ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: catCtrl.categories.length,
            itemBuilder: (ctx, i) {
              final cat = catCtrl.categories[i];
              return Card(
                child: ListTile(
                  title: Text(cat.name),
                  subtitle: Text('${cat.description} • Base Fee: \$${cat.basePrice.toInt()}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => catCtrl.deleteCategory(cat.id),
                  ),
                ),
              );
            },
          )),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Get.dialog(
            AlertDialog(
              title: const Text('Add Service Category'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Category Name')),
                  TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
                  TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Base Price (\$)')),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    catCtrl.addCategory(nameCtrl.text, 'build', descCtrl.text, double.tryParse(priceCtrl.text) ?? 40);
                    Get.back();
                  },
                  child: const Text('Create'),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class AdminUsersTab extends StatelessWidget {
  const AdminUsersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminController adminCtrl = Get.find();
    final ComplaintController cmpCtrl = Get.find();
    final resolutionCtrl = TextEditingController();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: const TabBar(
          tabs: [
            Tab(text: 'Registered Users'),
            Tab(text: 'Dispute Tickets'),
          ],
        ),
        body: TabBarView(
          children: [
            Obx(() => ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: adminCtrl.allRegisteredUsers.length,
                  itemBuilder: (ctx, i) {
                    final u = adminCtrl.allRegisteredUsers[i];
                    return Card(
                      child: ListTile(
                        title: Text(u.name),
                        subtitle: Text('${u.email} • ${u.phone}'),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: u.isDisabled ? Colors.green : Colors.red),
                          child: Text(u.isDisabled ? 'Enable' : 'Disable'),
                          onPressed: () => adminCtrl.toggleDisableUser(u.id),
                        ),
                      ),
                    );
                  },
                )),
            Obx(() => ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cmpCtrl.complaints.length,
                  itemBuilder: (ctx, i) {
                    final cmp = cmpCtrl.complaints[i];
                    return Card(
                      child: ListTile(
                        title: Text('${cmp.issueCategory} (${cmp.status})'),
                        subtitle: Text('By: ${cmp.userName} against ${cmp.workerName}\n"${cmp.description}"'),
                        trailing: cmp.status == 'Open'
                            ? ElevatedButton(
                                child: const Text('Resolve'),
                                onPressed: () {
                                  Get.dialog(
                                    AlertDialog(
                                      title: const Text('Resolve Ticket'),
                                      content: TextField(controller: resolutionCtrl, decoration: const InputDecoration(hintText: 'Resolution note / refund info')),
                                      actions: [
                                        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                                        ElevatedButton(
                                          onPressed: () {
                                            cmpCtrl.resolveComplaint(cmp.id, resolutionCtrl.text);
                                            Get.back();
                                          },
                                          child: const Text('Confirm Resolution'),
                                        )
                                      ],
                                    ),
                                  );
                                },
                              )
                            : const Icon(Icons.check_circle, color: Colors.green),
                      ),
                    );
                  },
                )),
          ],
        ),
      ),
    );
  }
}


class WorkerDetailScreen extends StatelessWidget {
  final WorkerModel worker;
  const WorkerDetailScreen({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    final CategoryController catCtrl = Get.find();
    final ReviewController revCtrl = Get.find();

    return Scaffold(
      appBar: AppBar(title: Text(worker.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(radius: 40, child: Text(worker.name[0], style: const TextStyle(fontSize: 28))),
                  const SizedBox(height: 8),
                  Text(worker.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('${worker.serviceArea} • \$${worker.hourlyRate.toInt()}/hr', style: const TextStyle(color: Colors.grey)),
                  Text('⭐ ${worker.rating.toStringAsFixed(1)} (${worker.reviewCount} Reviews)', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Professional Bio', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(worker.bio),
            const SizedBox(height: 20),
            const Text('Client Reviews', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Obx(() {
              final workerReviews = revCtrl.reviews.where((r) => r.workerId == worker.id).toList();
              if (workerReviews.isEmpty) {
                return const Text('No reviews yet for this worker.', style: TextStyle(color: Colors.grey));
              }
              final reviewCards = workerReviews.map((r) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text('${r.userName} • ⭐ ${r.rating.toStringAsFixed(1)}'),
                      subtitle: Text('"${r.comment}"'),
                    ),
                  );
                }).toList();
              return Column(children: reviewCards);
            }),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: const Color(0xFF1E88E5),
                foregroundColor: Colors.white,
              ),
              child: const Text('Proceed to Booking'),
              onPressed: () {
                Get.to(() => BookingCheckoutScreen(worker: worker, category: catCtrl.categories.first));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class BookingCheckoutScreen extends StatefulWidget {
  final WorkerModel worker;
  final CategoryModel category;
  const BookingCheckoutScreen({super.key, required this.worker, required this.category});

  @override
  State<BookingCheckoutScreen> createState() => _BookingCheckoutScreenState();
}

class _BookingCheckoutScreenState extends State<BookingCheckoutScreen> {
  final dateCtrl = TextEditingController(text: '2026-08-16');
  final timeCtrl = TextEditingController(text: '10:00 AM');
  final addressCtrl = TextEditingController(text: '742 Evergreen Terrace, Downtown');
  final notesCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final AddressController addrCtrl = Get.find();

    return Scaffold(
      appBar: AppBar(title: const Text('Book Service Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Booking ${widget.worker.name} for ${widget.category.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'Scheduled Date')),
            TextField(controller: timeCtrl, decoration: const InputDecoration(labelText: 'Scheduled Time')),
            const SizedBox(height: 8),
            Obx(() {
              return DropdownButtonFormField<String>(
                initialValue: addrCtrl.addresses.firstOrNull?.addressLine ?? addressCtrl.text,
                decoration: const InputDecoration(labelText: 'Select Service Address'),
                items: addrCtrl.addresses.map((a) {
                  return DropdownMenuItem(value: a.addressLine, child: Text('${a.label}: ${a.addressLine}'));
                }).toList(),
                onChanged: (val) {
                  if (val != null) addressCtrl.text = val;
                },
              );
            }),
            TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Problem Notes / Instructions')),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              child: const Text('Confirm & Place Request'),
              onPressed: () {
                Get.find<BookingController>().createBooking(
                  worker: widget.worker,
                  category: widget.category,
                  date: dateCtrl.text,
                  time: timeCtrl.text,
                  address: addressCtrl.text,
                  notes: notesCtrl.text,
                );
                Get.back();
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ChatScreen extends StatelessWidget {
  final BookingModel booking;
  const ChatScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final ChatController chatCtrl = Get.find();
    final msgCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text('Chat: ${booking.workerName}')),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final msgs = chatCtrl.messages.where((m) => m.bookingId == booking.id).toList();
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: msgs.length,
                itemBuilder: (ctx, i) {
                  final m = msgs[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('${m.senderName}: ${m.text}'),
                  );
                },
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: TextField(controller: msgCtrl, decoration: const InputDecoration(hintText: 'Type message...'))),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    chatCtrl.sendMessage(booking.id, msgCtrl.text);
                    msgCtrl.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
