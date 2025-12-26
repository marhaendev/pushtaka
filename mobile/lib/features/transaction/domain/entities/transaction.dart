import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final int id;
  final int bookId;
  final int userId;
  final String action; // borrow, return
  final String status; // borrowed, returned, completed
  final DateTime? dueDate;
  final DateTime? returnDate;
  final int fine;
  final DateTime? paidAt;
  final String? paymentMethod;
  final DateTime createdAt;
  final String? bookTitle;
  final String? author;
  final String? image;
  final String? userName;
  final String? userEmail;

  const Transaction({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.action,
    required this.status,
    this.dueDate,
    this.returnDate,
    required this.fine,
    this.paidAt,
    this.paymentMethod,
    required this.createdAt,
    this.bookTitle,
    this.author,
    this.image,
    this.userName,
    this.userEmail,
  });

  @override
  List<Object?> get props => [
    id,
    bookId,
    userId,
    action,
    status,
    dueDate,
    returnDate,
    fine,
    paidAt,
    paymentMethod,
    createdAt,
    bookTitle,
    author,
    image,
    userName,
    userEmail,
  ];
}
