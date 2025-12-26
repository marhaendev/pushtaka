import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/user_controller.dart';
import '../../domain/entities/user.dart';
import '../../../../core/widgets/app_loading.dart';

class UserFormPage extends StatefulWidget {
  final User? user;
  const UserFormPage({super.key, this.user});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  String? _role;
  bool _isVerified = false;

  final controller = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _passwordController = TextEditingController();
    _role = widget.user?.role ?? 'user';
    _isVerified = widget.user?.isVerified ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.user != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEdit ? "Edit User" : "Tambah User",
                style: GoogleFonts.merriweather(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A4D2E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isEdit
                    ? "Perbarui informasi akun user ini."
                    : "Lengkapi data di bawah untuk menambahkan user baru.",
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              _buildInputField(
                label: "Nama Lengkap",
                hintText: "Masukkan nama lengkap user",
                icon: Icons.person_outline,
                controller: _nameController,
                validator: (v) => v!.isEmpty ? "Nama wajib diisi" : null,
              ),
              const SizedBox(height: 12),
              _buildInputField(
                label: "Email",
                hintText: "contoh@email.com",
                icon: Icons.email_outlined,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: [AutofillHints.email],
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'\s')),
                ],
                validator:
                    (v) =>
                        v!.isEmpty || !v.contains('@')
                            ? "Email tidak valid"
                            : null,
              ),
              if (!isEdit) ...[
                const SizedBox(height: 12),
                _buildInputField(
                  label: "Password",
                  hintText: "Min. 6 karakter",
                  icon: Icons.lock_outline,
                  controller: _passwordController,
                  obscureText: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  ],
                  validator:
                      (v) =>
                          v!.isEmpty || v.length < 6
                              ? "Password min 6 karakter"
                              : null,
                ),
              ],
              if (isEdit) ...[
                const SizedBox(height: 20),
                Text(
                  "Pengaturan Akun",
                  style: GoogleFonts.merriweather(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A4D2E),
                  ),
                ),
                const SizedBox(height: 10),
                _buildDropdownField(
                  label: "Role User",
                  icon: Icons.admin_panel_settings_outlined,
                  value: _role,
                  items: const [
                    DropdownMenuItem(value: 'user', child: Text("User Biasa")),
                    DropdownMenuItem(
                      value: 'admin',
                      child: Text("Administrator"),
                    ),
                  ],
                  onChanged: (v) => setState(() => _role = v),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: SwitchListTile(
                    title: Text(
                      "Status Verifikasi",
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      "Aktifkan agar user bisa login",
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    value: _isVerified,
                    activeColor: const Color(0xFF1A4D2E),
                    onChanged: (v) => setState(() => _isVerified = v),
                  ),
                ),
              ],
              const SizedBox(height: 48),
              Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A4D2E),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child:
                      controller.isLoading.value
                          ? const AppLoading(
                            size: 20,
                            isCircular: true,
                            color: Colors.white,
                          )
                          : Text(
                            isEdit ? "Simpan Perubahan" : "Simpan User",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      if (widget.user != null) {
        controller.updateUser(
          widget.user!.id,
          _nameController.text,
          _emailController.text,
          role: _role,
          isVerified: _isVerified,
        );
      } else {
        controller.addUser(
          _nameController.text,
          _emailController.text,
          _passwordController.text,
        );
      }
    }
  }

  Widget _buildInputField({
    required String label,
    required String hintText,
    required IconData icon,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    List<String>? autofillHints,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          autofillHints: autofillHints,
          inputFormatters: inputFormatters,
          style: GoogleFonts.quicksand(fontSize: 13),
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.quicksand(
              fontSize: 12,
              color: Colors.grey.shade400,
            ),
            prefixIcon: Icon(icon, size: 18, color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.grey.shade50,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF1A4D2E),
                width: 1.5,
              ),
            ),
            errorStyle: const TextStyle(fontSize: 11),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        DropdownButtonFormField<String>(
          value: value,
          items: items,
          onChanged: onChanged,
          iconSize: 18,
          style: GoogleFonts.quicksand(fontSize: 13, color: Colors.black87),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.grey.shade50,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF1A4D2E),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
