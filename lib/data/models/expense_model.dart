import 'package:isar/isar.dart';

part 'expense_model.g.dart';

@collection
class Expense {
  Id id = Isar.autoIncrement;

  late String title;
  late double totalAmount;
  late String category;
  late DateTime date;

  // เก็บรายการสินค้าและราคา
  List<String> itemNames = [];
  List<double> itemPrices = [];
}
