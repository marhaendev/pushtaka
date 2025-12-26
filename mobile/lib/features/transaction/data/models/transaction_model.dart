import '../../domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.bookId,
    required super.userId,
    required super.action,
    required super.status,
    super.dueDate,
    super.returnDate,
    required super.fine,
    super.paidAt,
    super.paymentMethod,
    required super.createdAt,
    super.bookTitle,
    super.author,
    super.image,
    super.userName,
    super.userEmail,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      bookId: int.tryParse(json['book_id']?.toString() ?? '0') ?? 0,
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      action: json['action']?.toString() ?? 'borrow',
      status: json['status']?.toString() ?? 'unknown',
      dueDate:
          json['due_date'] != null
              ? DateTime.tryParse(json['due_date'].toString())
              : null,
      returnDate:
          json['return_date'] != null
              ? DateTime.tryParse(json['return_date'].toString())
              : null,
      fine: int.tryParse(json['fine']?.toString() ?? '0') ?? 0,
      paidAt:
          json['paid_at'] != null
              ? DateTime.tryParse(json['paid_at'].toString())
              : null,
      paymentMethod: json['payment_method']?.toString(),
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString()) ??
                  DateTime.now()
              : DateTime.now(),
      // Map nested book object
      bookTitle: json['book']?['title']?.toString() ?? 'Unknown Title',
      author: json['book']?['author']?.toString() ?? 'Unknown Author',
      image: json['book']?['image']?.toString(),
      userName: json['user']?['name']?.toString() ?? 'Unknown User',
      userEmail: json['user']?['email']?.toString() ?? '',
    );
  }
}
