import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/transaction_controller.dart';
import '../../data/models/transaction_settings_model.dart';
import '../../../../core/widgets/app_loading.dart';

class TransactionSettingsPage extends StatefulWidget {
  const TransactionSettingsPage({super.key});

  @override
  State<TransactionSettingsPage> createState() =>
      _TransactionSettingsPageState();
}

class _TransactionSettingsPageState extends State<TransactionSettingsPage> {
  final TransactionController controller = Get.find<TransactionController>();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _durationController;
  late TextEditingController _fineController;
  late TextEditingController _fineDurationController;
  late TextEditingController _limitController;
  String _selectedUnit = 'day';
  String _selectedFineUnit = 'day';

  @override
  void initState() {
    super.initState();
    final s = controller.settings.value;
    _durationController = TextEditingController(
      text: s?.borrowDuration.toString() ?? '7',
    );
    _selectedUnit = s?.borrowDurationUnit ?? 'day';
    _fineController = TextEditingController(
      text: s?.fineAmount.toString() ?? '1000',
    );
    _fineDurationController = TextEditingController(
      text: s?.fineDuration.toString() ?? '1',
    );
    _selectedFineUnit = s?.fineUnit ?? 'day';
    _limitController = TextEditingController(
      text: s?.maxBorrowLimit.toString() ?? '3',
    );
  }

  @override
  void dispose() {
    _durationController.dispose();
    _fineController.dispose();
    _fineDurationController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final newSettings = TransactionSettingsModel(
        borrowDuration: int.parse(_durationController.text),
        borrowDurationUnit: _selectedUnit,
        fineAmount: int.parse(_fineController.text),
        fineUnit: _selectedFineUnit,
        fineDuration: int.parse(_fineDurationController.text),
        maxBorrowLimit: int.parse(_limitController.text),
      );
      controller.updateSettings(newSettings);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Pengaturan Transaksi",
          style: GoogleFonts.merriweather(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Obx(() {
        if (controller.isSettingsLoading.value &&
            controller.settings.value == null) {
          return const Center(child: AppLoading());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("Durasi Pinjam", Icons.calendar_today),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildTextField(
                        _durationController,
                        "Durasi",
                        "Contoh: 7",
                        isNumber: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDropdown(
                        value: _selectedUnit,
                        items: const [
                          DropdownMenuItem(
                            value: 'minute',
                            child: Text('Menit'),
                          ),
                          DropdownMenuItem(value: 'hour', child: Text('Jam')),
                          DropdownMenuItem(value: 'day', child: Text('Hari')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedUnit = val);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSectionHeader("Tarif Denda", Icons.payments_outlined),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildTextField(
                        _fineController,
                        "Nominal Denda",
                        "Contoh: 1000",
                        isNumber: true,
                        prefixText: "Rp ",
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "/",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: _buildTextField(
                        _fineDurationController,
                        "Per",
                        "1",
                        isNumber: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: _buildDropdown(
                        value: _selectedFineUnit,
                        items: const [
                          DropdownMenuItem(
                            value: 'minute',
                            child: Text('Menit'),
                          ),
                          DropdownMenuItem(value: 'hour', child: Text('Jam')),
                          DropdownMenuItem(value: 'day', child: Text('Hari')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedFineUnit = val);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSectionHeader("Batas Pinjam", Icons.book_outlined),
                const SizedBox(height: 8),
                _buildTextField(
                  _limitController,
                  "Maksimal buku per user",
                  "Contoh: 3",
                  isNumber: true,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A4D2E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child:
                        controller.isLoading.value
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : Text(
                              "Simpan Perubahan",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF1A4D2E)),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    bool isNumber = false,
    String? prefixText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefixText,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1A4D2E)),
        ),
      ),
      validator: (val) {
        if (val == null || val.isEmpty) return "Wajib diisi";
        if (isNumber && int.tryParse(val) == null) return "Harus angka";
        return null;
      },
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF1A4D2E)),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
