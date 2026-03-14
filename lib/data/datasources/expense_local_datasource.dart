import 'package:isar/isar.dart';
import '../models/expense_model.dart';

class ExpenseLocalDataSource {
  final Isar isar;
  ExpenseLocalDataSource(this.isar);

  Future<void> saveExpense(Expense expense) async {
    await isar.writeTxn(() async {
      await isar.expenses.put(expense);
    });
  }
}
