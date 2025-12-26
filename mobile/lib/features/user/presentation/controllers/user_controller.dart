import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../../../../core/controllers/app_notification_controller.dart';

class UserController extends GetxController {
  final UserRepository repository;

  UserController({required this.repository});

  var users = <User>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  var searchQuery = ''.obs;
  var isSearchOpen = false.obs;

  var scrollOffset = 0.0.obs;
  var isSelectionMode = false.obs;
  var selectedIds = <int>[].obs;
  var selectedRole = 'Semua'.obs;
  var selectedSort = 'Nama (A-Z)'.obs;

  late ScrollController scrollController;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    fetchUsers();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void updateScroll(double offset) {
    scrollOffset.value = offset;
  }

  void toggleSelectionMode() {
    isSelectionMode.value = !isSelectionMode.value;
    if (!isSelectionMode.value) {
      selectedIds.clear();
    }
  }

  void toggleSelection(int id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
    if (selectedIds.isEmpty) {
      isSelectionMode.value = false;
    }
  }

  void scrollToTop() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  Future<void> fetchUsers() async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await repository.getUsers();
    result.fold(
      (failure) {
        errorMessage.value = _mapFailureToMessage(failure);
        AppNotificationController.to.showError(
          "Gagal memuat pengguna: ${errorMessage.value}",
        );
      },
      (data) {
        users.value = data;
      },
    );
    isLoading.value = false;
  }

  Future<void> refreshUsers() async {
    await fetchUsers();
  }

  void toggleSearch() {
    isSearchOpen.toggle();
    if (!isSearchOpen.value) {
      searchQuery.value = '';
    }
  }

  void search(String query) {
    searchQuery.value = query;
  }

  void setRoleFilter(String role) {
    selectedRole.value = role;
  }

  void setSortOption(String sort) {
    selectedSort.value = sort;
  }

  List<User> get displayedUsers {
    List<User> filtered = users;

    // 1. Search Filter
    if (searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where(
                (user) =>
                    user.name.toLowerCase().contains(
                      searchQuery.value.toLowerCase(),
                    ) ||
                    user.email.toLowerCase().contains(
                      searchQuery.value.toLowerCase(),
                    ),
              )
              .toList();
    }

    // 2. Role Filter
    if (selectedRole.value != 'Semua') {
      filtered =
          filtered
              .where(
                (user) =>
                    (user.role ?? '').toLowerCase() ==
                    selectedRole.value.toLowerCase(),
              )
              .toList();
    }

    // 3. Sorting
    List<User> sorted = List.from(filtered);
    if (selectedSort.value == 'Nama (A-Z)') {
      sorted.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    } else if (selectedSort.value == 'Nama (Z-A)') {
      sorted.sort(
        (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
      );
    } else if (selectedSort.value == 'Terbaru') {
      sorted.sort((a, b) => b.id.compareTo(a.id));
    } else if (selectedSort.value == 'Terlama') {
      sorted.sort((a, b) => a.id.compareTo(b.id));
    }

    return sorted;
  }

  Future<void> addUser(String name, String email, String password) async {
    isLoading.value = true;
    final result = await repository.createUser({
      'name': name,
      'email': email,
      'password': password,
    });
    result.fold(
      (failure) => AppNotificationController.to.showError(
        "Gagal menambah user: ${_mapFailureToMessage(failure)}",
      ),
      (_) {
        AppNotificationController.to.showSuccess("User berhasil ditambahkan");
        fetchUsers();
        Get.back();
      },
    );
    isLoading.value = false;
  }

  Future<void> updateUser(
    int id,
    String name,
    String email, {
    String? role,
    bool? isVerified,
  }) async {
    isLoading.value = true;
    final result = await repository.updateUser(id, {
      'name': name,
      'email': email,
      if (role != null) 'role': role,
      if (isVerified != null) 'is_verified': isVerified,
    });
    result.fold(
      (failure) => AppNotificationController.to.showError(
        "Gagal memperbarui user: ${_mapFailureToMessage(failure)}",
      ),
      (_) {
        AppNotificationController.to.showSuccess("User berhasil diperbarui");
        fetchUsers();
        Get.back();
      },
    );
    isLoading.value = false;
  }

  Future<void> deleteUser(int id) async {
    isLoading.value = true;
    final result = await repository.deleteUser(id);
    result.fold(
      (failure) => AppNotificationController.to.showError(
        "Gagal menghapus user: ${_mapFailureToMessage(failure)}",
      ),
      (_) {
        AppNotificationController.to.showSuccess("User berhasil dihapus");
        fetchUsers();
      },
    );
    isLoading.value = false;
  }

  Future<void> deleteSelectedUsers() async {
    if (selectedIds.isEmpty) return;

    isLoading.value = true;
    final idsToDelete = List<int>.from(selectedIds);
    final result = await repository.deleteUserBatch(idsToDelete);

    result.fold(
      (failure) => AppNotificationController.to.showError(
        "Gagal menghapus batch user: ${_mapFailureToMessage(failure)}",
      ),
      (_) {
        AppNotificationController.to.showSuccess(
          "${idsToDelete.length} user berhasil dihapus",
        );
        selectedIds.clear();
        isSelectionMode.value = false;
        fetchUsers();
      },
    );
    isLoading.value = false;
  }

  String _mapFailureToMessage(Failure failure) {
    return failure.message.isNotEmpty
        ? failure.message
        : 'Terjadi kesalahan sistem';
  }
}
