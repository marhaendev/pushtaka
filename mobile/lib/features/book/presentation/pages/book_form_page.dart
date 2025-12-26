import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/book_controller.dart';
import '../../data/models/google_book_model.dart';
import '../../data/models/open_library_model.dart';
import '../../domain/entities/book.dart';
import '../../../../core/controllers/app_notification_controller.dart';
import '../../../../core/widgets/app_loading.dart';

class BookFormPage extends StatefulWidget {
  final Book? book;
  const BookFormPage({super.key, this.book});

  @override
  State<BookFormPage> createState() => _BookFormPageState();
}

class _BookFormPageState extends State<BookFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _yearController;
  late TextEditingController _stockController;
  late TextEditingController _isbnController;
  late TextEditingController _publisherController;
  late TextEditingController _descriptionController;

  // Search API State
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  String _importSource = "Google Books";
  bool _isStockValid = true;

  final controller = Get.find<BookController>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book?.title ?? '');
    _authorController = TextEditingController(text: widget.book?.author ?? '');
    _yearController = TextEditingController(
      text: widget.book != null ? widget.book!.year.toString() : '',
    );
    _stockController = TextEditingController(
      text: widget.book != null ? widget.book!.stock.toString() : '',
    );
    _isbnController = TextEditingController(text: widget.book?.isbn ?? '');
    _publisherController = TextEditingController(
      text: widget.book?.publisher ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.book?.description ?? '',
    );
    _imageController.text = widget.book?.image ?? '';
    _validateStock();
    _stockController.addListener(_validateStock);
  }

  void _validateStock() {
    final stock = int.tryParse(_stockController.text) ?? 0;
    setState(() {
      _isStockValid = stock > 0;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _yearController.dispose();
    _stockController.dispose();
    _isbnController.dispose();
    _publisherController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.book != null;
    final currentYear = DateTime.now().year;
    final years = List.generate(
      100,
      (index) => (currentYear - index).toString(),
    );

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
                isEdit ? "Edit Buku" : "Tambah Buku",
                style: GoogleFonts.merriweather(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A4D2E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isEdit
                    ? "Perbarui informasi buku ini."
                    : "Lengkapi data di bawah untuk menambahkan buku baru ke katalog.",
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),

              // Import Section
              if (!isEdit) ...[
                Text(
                  "Import Data Buku",
                  style: GoogleFonts.merriweather(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A4D2E),
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 48,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _importSource,
                          isExpanded: true,
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 20,
                            color: Colors.grey.shade600,
                          ),
                          style: GoogleFonts.quicksand(
                            fontSize: 12,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: "Google Books",
                              child: Text(
                                "Google Books",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DropdownMenuItem(
                              value: "Open Library",
                              child: Text(
                                "Open Library",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _importSource = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Search Input
                    TextField(
                      controller: _searchController,
                      style: GoogleFonts.quicksand(fontSize: 13),
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: "Cari judul / ISBN...",
                        hintStyle: GoogleFonts.quicksand(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 0,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
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
                        suffixIcon: Material(
                          color: const Color(0xFF1A4D2E),
                          borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(10),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: _performSearch,
                            child: const SizedBox(
                              width: 50,
                              height: 50,
                              child: Icon(
                                Icons.search,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _performSearch(),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(),
                ),
              ],

              _buildInputField(
                label: "URL Cover Buku",
                hintText: "https://...",
                icon: Icons.image_outlined,
                controller: _imageController,
                onChanged:
                    (_) => setState(() {}), // Trigger rebuild for preview
              ),
              const SizedBox(height: 12),

              if (_imageController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Container(
                        height: 100,
                        width: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(_imageController.text),
                            fit: BoxFit.cover,
                            onError:
                                (_, __) {}, // Handle error silently in preview
                          ),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Preview Cover Buku",
                          style: GoogleFonts.quicksand(
                            color: Colors.green[800],
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _imageController.clear();
                          });
                        },
                        icon: const Icon(Icons.close, color: Colors.red),
                        tooltip: "Hapus URL",
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 8),
              _buildInputField(
                label: "Judul Buku",
                hintText: "Masukkan judul lengkap buku",
                icon: Icons.book_outlined,
                controller: _titleController,
                validator: (v) => v!.isEmpty ? "Judul wajib diisi" : null,
                isRequired: true,
              ),
              const SizedBox(height: 12),
              _buildInputField(
                label: "Penulis",
                hintText: "Nama pengarang/penulis",
                icon: Icons.person_outline,
                controller: _authorController,
                validator: (v) => v!.isEmpty ? "Penulis wajib diisi" : null,
                isRequired: true,
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 4),
                          child: RichText(
                            text: TextSpan(
                              text: "Tahun Terbit",
                              style: GoogleFonts.quicksand(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                              children: [
                                TextSpan(
                                  text: ' *',
                                  style: GoogleFonts.quicksand(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        DropdownButtonFormField<String>(
                          value:
                              years.contains(_yearController.text)
                                  ? _yearController.text
                                  : null,
                          isExpanded: true,
                          menuMaxHeight: 200,
                          items:
                              years.map((year) {
                                return DropdownMenuItem(
                                  value: year,
                                  child: Text(
                                    year,
                                    style: GoogleFonts.quicksand(fontSize: 10),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              _yearController.text = val;
                            }
                          },
                          validator:
                              (v) => v == null || v.isEmpty ? "Wajib" : null,
                          decoration: InputDecoration(
                            hintText: "Pilih Tahun",
                            hintStyle: GoogleFonts.quicksand(
                              fontSize: 10,
                              color: Colors.grey.shade400,
                            ),
                            prefixIcon: Icon(
                              Icons.calendar_today_outlined,
                              size: 18,
                              color: Colors.grey.shade400,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
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
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInputField(
                      label: "Stok",
                      hintText: "Jumlah buku",
                      icon: Icons.inventory_2_outlined,
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      isRequired: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInputField(
                label: "ISBN",
                hintText: "978-x-xxx-xxxx-x",
                icon: Icons.tag,
                controller: _isbnController,
              ),
              const SizedBox(height: 12),
              _buildInputField(
                label: "Penerbit",
                hintText: "Nama perusahaan penerbit",
                icon: Icons.business_outlined,
                controller: _publisherController,
              ),
              const SizedBox(height: 12),
              _buildInputField(
                label: "Deskripsi",
                hintText: "Tuliskan deskripsi singkat atau sinopsis buku...",
                icon: Icons.description_outlined,
                controller: _descriptionController,
                maxLines: 4,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 48),
              Obx(
                () => ElevatedButton(
                  onPressed:
                      (controller.isLoading.value || !_isStockValid)
                          ? null
                          : _save,
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
                            isEdit ? "Simpan Perubahan" : "Simpan Buku",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      if (widget.book != null) {
        // Edit mode
        await controller.editBook(
          widget.book!.id,
          _titleController.text,
          _authorController.text,
          int.tryParse(_yearController.text) ?? 0,
          int.tryParse(_stockController.text) ?? 0,
          isbn: _isbnController.text,
          publisher: _publisherController.text,
          description: _descriptionController.text,
          image:
              _imageController.text.isNotEmpty ? _imageController.text : null,
          onSuccess: () {
            Get.back(result: true);
          },
        );
      } else {
        // Add mode
        await controller.addBook(
          _titleController.text,
          _authorController.text,
          int.tryParse(_yearController.text) ?? 0,
          int.tryParse(_stockController.text) ?? 0,
          isbn: _isbnController.text,
          publisher: _publisherController.text,
          description: _descriptionController.text,
          image:
              _imageController.text.isNotEmpty ? _imageController.text : null,
          onSuccess: () {
            Get.back();
          },
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
    int? maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool isRequired = false,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: RichText(
            text: TextSpan(
              text: label,
              style: GoogleFonts.quicksand(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
              children: [
                if (isRequired)
                  TextSpan(
                    text: ' *',
                    style: GoogleFonts.quicksand(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: GoogleFonts.quicksand(fontSize: 13),
          validator: validator,
          onChanged: onChanged,
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

  void _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      AppNotificationController.to.showError("Masukkan kata kunci pencarian");
      return;
    }

    // Show Loading Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: AppLoading()),
    );

    final List<dynamic> results;
    if (_importSource == "Google Books") {
      results = await controller.searchGoogleBooks(query);
    } else {
      results = await controller.searchOpenLibrary(query);
    }

    Get.back();

    if (results.isEmpty) {
      AppNotificationController.to.showError("Buku tidak ditemukan");
      return;
    }

    if (mounted) {
      showDialog(
        context: context,
        builder:
            (context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                height: MediaQuery.of(context).size.height * 0.6,
                child: Column(
                  children: [
                    Text(
                      "Pilih Buku",
                      style: GoogleFonts.merriweather(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A4D2E),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        itemCount: results.length,
                        separatorBuilder: (ctx, i) => const Divider(),
                        itemBuilder: (ctx, i) {
                          final item = results[i];
                          final String title;
                          final String author;
                          final String year;
                          final String? thumb;

                          if (_importSource == "Google Books") {
                            final info = item.volumeInfo;
                            title = info.title;
                            author = info.authors?.join(", ") ?? "Unknown";
                            year = info.publishedDate?.split("-")[0] ?? "-";
                            thumb = info.imageLinks?.thumbnail;
                          } else {
                            final doc = item as OpenLibraryDoc;
                            title = doc.title;
                            author = doc.authorName?.join(", ") ?? "Unknown";
                            year = doc.firstPublishYear?.toString() ?? "-";
                            thumb = doc.coverUrl;
                          }

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              width: 40,
                              height: 60,
                              color: Colors.grey.shade200,
                              child:
                                  thumb != null
                                      ? Image.network(
                                        thumb,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (c, e, s) =>
                                                const Icon(Icons.broken_image),
                                      )
                                      : const Icon(
                                        Icons.book,
                                        color: Colors.grey,
                                      ),
                            ),
                            title: Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.quicksand(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            subtitle: Text(
                              "$author • $year",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.quicksand(fontSize: 12),
                            ),
                            onTap: () {
                              _fillForm(item);
                              Get.back();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
      );
    }
  }

  void _fillForm(dynamic item) {
    setState(() {
      if (_importSource == "Google Books") {
        final info = (item as GoogleBookItem).volumeInfo;
        _titleController.text = info.title;
        _authorController.text = info.authors?.join(", ") ?? "";
        _publisherController.text = info.publisher ?? "";
        _descriptionController.text = info.description ?? "";
        if (info.imageLinks?.thumbnail != null) {
          _imageController.text = info.imageLinks!.thumbnail!;
        }
        if (info.publishedDate != null && info.publishedDate!.isNotEmpty) {
          _yearController.text = info.publishedDate!.split("-")[0];
        }
        if (info.industryIdentifiers != null) {
          final List<dynamic> identifiers = info.industryIdentifiers!;
          if (identifiers.isNotEmpty) {
            var found = "";
            for (var id in identifiers) {
              if (id.type == "ISBN_13") found = id.identifier;
            }
            if (found.isEmpty) found = identifiers.first.identifier;
            _isbnController.text = found;
          }
        }
      } else {
        final doc = item as OpenLibraryDoc;
        _titleController.text = doc.title;
        _authorController.text = doc.authorName?.join(", ") ?? "";
        _publisherController.text = doc.publisher?.join(", ") ?? "";
        _descriptionController.text =
            ""; // Open Library search usually doesn't have description in docs
        if (doc.coverUrl != null) {
          _imageController.text = doc.coverUrl!;
        }
        if (doc.firstPublishYear != null) {
          _yearController.text = doc.firstPublishYear.toString();
        }
        if (doc.isbn != null && doc.isbn!.isNotEmpty) {
          _isbnController.text = doc.isbn!.first;
        }
      }
    });

    AppNotificationController.to.showSuccess(
      "Data buku berhasil diisi otomatis!",
    );
  }
}
