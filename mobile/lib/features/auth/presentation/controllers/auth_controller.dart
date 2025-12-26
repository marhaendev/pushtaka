import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/controllers/app_notification_controller.dart';
import '../../../../core/routes/app_pages.dart';

class AuthController extends GetxController {
  final AuthRepository repository;

  AuthController({required this.repository});

  var isLoading = false.obs;
  var isLoggedIn = false.obs;
  var isAdmin = false.obs; // Default false, set to true on admin login
  var userName = "User".obs;
  var userEmail = "".obs;
  var userId = "".obs;
  var isVerified = false.obs;

  var isPasswordVisible = false.obs;
  var resetEmail = "".obs;
  var resetToken = "".obs;
  var otpErrorMessage = "".obs;
  var currentPasswordErrorMessage = "".obs;
  var loginErrorMessage = "".obs;
  var errorMessage = "".obs;
  var isRememberMe = false.obs;
  var savedAccounts = <Map<String, String>>[].obs;
  var selectedEmail = "".obs;
  var selectedPassword = "".obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleRememberMe() {
    isRememberMe.value = !isRememberMe.value;
  }

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
    loadSavedAccounts();
  }

  Future<void> loadSavedAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? accountsJson = prefs.getStringList('saved_accounts');
    print("DEBUG: Loading accounts: $accountsJson");
    if (accountsJson != null) {
      savedAccounts.value =
          accountsJson
              .map((item) {
                final parts = item.split('|');
                if (parts.length == 2) {
                  return {'email': parts[0], 'password': parts[1]};
                }
                return <String, String>{};
              })
              .where((e) => e.isNotEmpty)
              .toList();
    }
  }

  Future<void> saveAccount(String email, String password) async {
    print("DEBUG: Saving account: $email");
    final prefs = await SharedPreferences.getInstance();
    List<String> accounts = prefs.getStringList('saved_accounts') ?? [];

    // Remove if already exists to update or just avoid duplicate
    accounts.removeWhere((item) => item.startsWith('$email|'));
    accounts.add('$email|$password');

    await prefs.setStringList('saved_accounts', accounts);
    await loadSavedAccounts();
  }

  Future<void> removeAccount(String email) async {
    print("DEBUG: Removing account: $email");
    final prefs = await SharedPreferences.getInstance();
    List<String> accounts = prefs.getStringList('saved_accounts') ?? [];
    accounts.removeWhere((item) => item.startsWith('$email|'));
    await prefs.setStringList('saved_accounts', accounts);
    await loadSavedAccounts();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token != null && token.isNotEmpty) {
      isLoggedIn.value = true;
      userName.value = prefs.getString('user_name') ?? "User";
      userEmail.value = prefs.getString('user_email') ?? "";
      userId.value = prefs.getString('user_id') ?? "";
      isVerified.value = prefs.getBool('user_is_verified') ?? false;
      final role = prefs.getString('user_role') ?? "member";

      if (role == "admin") {
        isAdmin.value = true;
      } else {
        isAdmin.value = false;
      }
    }
  }

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = ""; // Clear previous error
    final result = await repository.login(email, password);
    isLoading.value = false;

    result.fold(
      (failure) {
        errorMessage.value = _mapFailureToMessage(failure);
        AppNotificationController.to.showError(
          "Gagal memuat pengguna: ${errorMessage.value}",
        );
      },
      (user) async {
        isLoggedIn.value = true;
        userName.value = user.name;
        userEmail.value = user.email;
        userId.value = user.id.toString();
        isVerified.value = user.isVerified ?? false;

        // Save to Prefs
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', user.name);
        await prefs.setString('user_email', user.email);
        await prefs.setString('user_id', user.id.toString());
        await prefs.setString('user_role', user.role);
        await prefs.setBool('user_is_verified', user.isVerified ?? false);

        await prefs.setString('access_token', user.token);

        if (user.role == "admin") {
          isAdmin.value = true;
        } else {
          isAdmin.value = false;
        }
        if (isRememberMe.value) {
          await saveAccount(email, password);
        }

        Get.offAllNamed(Routes.HOME);
      },
    );
  }

  Future<void> verifyCurrentPasswordAndSendOtp(String currentPassword) async {
    isLoading.value = true;
    currentPasswordErrorMessage.value = ""; // Clear previous error
    final result = await repository.login(userEmail.value, currentPassword);
    isLoading.value = false;

    result.fold(
      (failure) {
        currentPasswordErrorMessage.value = "Password saat ini salah";
        AppNotificationController.to.showError(
          currentPasswordErrorMessage.value,
        );
      },
      (user) {
        // Password verified, send OTP using existing forgot password flow
        forgotPassword(userEmail.value);
      },
    );
  }

  Future<void> register(String name, String email, String password) async {
    isLoading.value = true;
    final result = await repository.register(name, email, password);
    isLoading.value = false;

    result.fold(
      (failure) =>
          AppNotificationController.to.showError(_mapFailureToMessage(failure)),
      (_) {
        AppNotificationController.to.showSuccess(
          "Registrasi berhasil! Silakan verifikasi email Anda.",
        );
      },
    );
  }

  Future<void> verifyAndRegister(String email, String otp) async {
    isLoading.value = true;
    final result = await repository.verifyOtp(email, otp, 'register');
    isLoading.value = false;

    result.fold(
      (failure) =>
          AppNotificationController.to.showError(_mapFailureToMessage(failure)),
      (_) {
        AppNotificationController.to.showSuccess(
          "Verifikasi berhasil! Silakan login.",
        );
        Get.offNamed(Routes.LOGIN);
      },
    );
  }

  Future<void> forgotPassword(String email) async {
    isLoading.value = true;
    resetEmail.value = email;
    final result = await repository.forgotPassword(email);
    isLoading.value = false;

    result.fold(
      (failure) =>
          AppNotificationController.to.showError(_mapFailureToMessage(failure)),
      (_) {
        otpErrorMessage.value = ""; // Clear any previous error
        AppNotificationController.to.showSuccess(
          "Kode OTP telah dikirim ke email Anda.",
        );
        Get.toNamed(Routes.FORGOT_OTP);
      },
    );
  }

  Future<void> verifyResetOtp(String otp) async {
    isLoading.value = true;
    otpErrorMessage.value = ""; // Clear previous error
    final result = await repository.verifyResetOtp(resetEmail.value, otp);
    isLoading.value = false;

    result.fold(
      (failure) {
        otpErrorMessage.value = "Kode OTP salah atau kadaluarsa";
        AppNotificationController.to.showError(otpErrorMessage.value);
      },
      (token) {
        resetToken.value = token;
        otpErrorMessage.value = ""; // Clear error on success
        AppNotificationController.to.showSuccess("Verifikasi OTP berhasil.");
        Get.toNamed(Routes.RESET_PWD);
      },
    );
  }

  var isResetSuccess = false.obs;
  var resetCountdown = 7.obs;

  Future<void> resetPassword(String newPassword) async {
    isLoading.value = true;
    final result = await repository.resetPassword(
      resetToken.value,
      newPassword,
    );
    isLoading.value = false;

    result.fold(
      (failure) =>
          AppNotificationController.to.showError(_mapFailureToMessage(failure)),
      (_) {
        isResetSuccess.value = true;
        resetCountdown.value = 7;
        AppNotificationController.to.showSuccess("Password berhasil direset.");

        // Start countdown
        Future.doWhile(() async {
          await Future.delayed(const Duration(seconds: 1));
          resetCountdown.value--;
          if (resetCountdown.value == 0) {
            finishReset();
            return false;
          }
          return true;
        });
      },
    );
  }

  void finishReset() {
    isResetSuccess.value = false; // Reset flag
    if (isLoggedIn.value) {
      Get.until((route) => route.settings.name == Routes.HOME);
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  Future<void> updateProfile(String name, String email) async {
    isLoading.value = true;
    final result = await repository.updateProfile(name, email);
    isLoading.value = false;

    result.fold(
      (failure) {
        AppNotificationController.to.showError(_mapFailureToMessage(failure));
      },
      (_) async {
        // Update local state and persistence
        userName.value = name;
        userEmail.value = email;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', name);
        await prefs.setString('user_email', email);

        Get.back();
        AppNotificationController.to.showSuccess("Profil berhasil diperbarui");
      },
    );
  }

  Future<void> logout() async {
    if (!isLoggedIn.value) return;

    try {
      await repository.logout();
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_id');
    await prefs.remove('user_role');
    await prefs.remove('user_is_verified');
    await prefs.remove('access_token');

    isLoggedIn.value = false;
    userName.value = "User";
    userEmail.value = "";
    userId.value = "";
    isVerified.value = false;
    isAdmin.value = false;

    Get.offAllNamed(Routes.LOGIN);
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure.message.isNotEmpty) return failure.message;
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server Error: Silakan coba lagi nanti.';
      case CacheFailure:
        return 'Cache Error: Gagal memuat data dari cache.';
      default:
        return 'Terjadi kesalahan tidak terduga';
    }
  }
}
