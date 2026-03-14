import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../../core/di/injection.dart';
import '../../data/models/expense_model.dart';

class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isar = locator<Isar>();
    final now = DateTime.now();
    // หาวันที่ 1 ของเดือนปัจจุบัน
    final startOfMonth = DateTime(now.year, now.month, 1);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'สรุปค่าใช้จ่ายเดือนนี้',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Expense>>(
        // ดึงเฉพาะข้อมูลของเดือนปัจจุบันมาแสดง
        stream: isar.expenses
            .filter()
            .dateGreaterThan(startOfMonth)
            .watch(fireImmediately: true),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final list = snapshot.data!;
          double total = list.fold(0, (sum, item) => sum + item.totalAmount);

          // คำนวณแยกยอดรวมตามหมวดหมู่
          Map<String, double> categoryMap = {};
          for (var item in list) {
            categoryMap[item.category] =
                (categoryMap[item.category] ?? 0) + item.totalAmount;
          }

          return CustomScrollView(
            slivers: [
              // ส่วนหัวการ์ดสรุปยอดรวม
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.deepPurple, Colors.purple.shade300],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'ยอดใช้จ่ายรวมเดือนนี้',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${total.toStringAsFixed(2)} ฿',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // ส่วนแสดงหัวข้อหมวดหมู่
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    'สรุปตามหมวดหมู่',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              // ส่วนรายการหมวดหมู่
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final category = categoryMap.keys.elementAt(index);
                  final amount = categoryMap[category]!;
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getCategoryColor(
                          category,
                        ).withOpacity(0.2),
                        child: Icon(
                          _getCategoryIcon(category),
                          color: _getCategoryColor(category),
                        ),
                      ),
                      title: Text(
                        category,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Text(
                        '${amount.toStringAsFixed(2)} ฿',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                }, childCount: categoryMap.length),
              ),
            ],
          );
        },
      ),
    );
  }

  // ฟังก์ชันเลือก Icon ตามหมวดหมู่
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.fastfood_rounded;
      case 'Travel':
        return Icons.directions_car_rounded;
      default:
        return Icons.shopping_bag_rounded;
    }
  }

  // ฟังก์ชันเลือกสีตามหมวดหมู่
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return Colors.orange;
      case 'Travel':
        return Colors.blue;
      default:
        return Colors.purple;
    }
  }
}
