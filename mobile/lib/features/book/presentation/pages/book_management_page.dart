import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/book_controller.dart';

class BookManagementPage extends GetView<BookController> {
  const BookManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manajemen Buku (Admin)")),
      body: const Center(child: Text("List Buku & CRUD")),
    );
  }
}
