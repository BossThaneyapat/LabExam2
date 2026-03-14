import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/di/injection.dart';
import '../../data/models/expense_model.dart';
import '../../data/datasources/gemini_remote_datasource.dart';

// --- [ ส่วนที่ 1: ตัวควบคุมการสลับหน้าหลัก ] ---
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  void _changeTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      HomePage(onSummaryTap: () => _changeTab(1)), // ส่ง callback ไปหน้า Home
      const SummaryPage(),
    ];

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        indicatorColor: Colors.deepPurple.withOpacity(0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long, color: Colors.deepPurple),
            label: 'ประวัติ',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics, color: Colors.deepPurple),
            label: 'สรุปผล',
          ),
        ],
      ),
    );
  }
}

// --- [ ส่วนที่ 2: หน้าประวัติการใช้จ่าย (แบบจัดกลุ่มรายเดือน) ] ---
class HomePage extends StatefulWidget {
  final VoidCallback onSummaryTap;
  const HomePage({super.key, required this.onSummaryTap});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final isar = locator<Isar>();

  Future<void> _deleteExpense(int id) async {
    await isar.writeTxn(() => isar.expenses.delete(id));
  }

  // ฟังก์ชันจัดกลุ่มข้อมูลตาม เดือน/ปี
  Map<String, List<Expense>> _groupExpenses(List<Expense> list) {
    Map<String, List<Expense>> grouped = {};
    for (var item in list) {
      // สร้าง Key เช่น "มีนาคม 2569"
      String key = "${_getMonthName(item.date.month)} ${item.date.year + 543}";
      if (grouped[key] == null) grouped[key] = [];
      grouped[key]!.add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // ปรับพื้นหลังให้ดูสะอาดตา
      appBar: AppBar(
        title: const Text(
          'ประวัติการใช้จ่าย',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        surfaceTintColor: Colors.transparent,
        actions: [
          // ปุ่มสรุปรายเดือนที่มุมขวาบนตามต้องการ
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: widget.onSummaryTap,
              icon: const Icon(Icons.pie_chart_rounded, size: 20),
              label: const Text('สรุปรายเดือน'),
              style: TextButton.styleFrom(foregroundColor: Colors.deepPurple),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Expense>>(
        stream: isar.expenses.where().sortByDateDesc().watch(
          fireImmediately: true,
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const Text(
                    'ยังไม่มีรายการบันทึก',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final grouped = _groupExpenses(snapshot.data!);

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: grouped.keys.length,
            itemBuilder: (context, index) {
              String monthYear = grouped.keys.elementAt(index);
              List<Expense> items = grouped[monthYear]!;
              double monthTotal = items.fold(
                0,
                (sum, item) => sum + item.totalAmount,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- ส่วนหัวกลุ่มเดือน + ยอดรวมเดือน ---
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          monthYear,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'รวม ${monthTotal.toStringAsFixed(2)} ฿',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // --- รายการใบเสร็จในเดือนนั้น ---
                  ...items.map((item) => _buildExpenseCard(item)),
                  const SizedBox(height: 8),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showPickerOptions,
        label: const Text('สแกนใบเสร็จ'),
        icon: const Icon(Icons.add_a_photo_rounded),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildExpenseCard(Expense item) {
    return Dismissible(
      key: Key(item.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete_sweep_rounded,
          color: Colors.white,
          size: 30,
        ),
      ),
      onDismissed: (direction) => _deleteExpense(item.id),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: CircleAvatar(
            backgroundColor: _getCategoryColor(item.category).withOpacity(0.1),
            child: Icon(
              _getCategoryIcon(item.category),
              color: _getCategoryColor(item.category),
            ),
          ),
          title: Text(
            item.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '${item.date.day} ${_getMonthName(item.date.month)} ${item.date.year + 543}',
          ),
          trailing: Text(
            '${item.totalAmount.toStringAsFixed(2)} ฿',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          onTap: () => _showDetail(item),
        ),
      ),
    );
  }

  // --- ฟังก์ชันเสริม (Picker, Image Processing, Detail) ---
  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Wrap(
            children: [
              const Center(
                child: Text(
                  'เพิ่มข้อมูลค่าใช้จ่าย',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 40),
              ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.camera_alt_rounded),
                ),
                title: const Text('ถ่ายรูปใบเสร็จใหม่'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.photo_library_rounded),
                ),
                title: const Text('เลือกจากคลังภาพ / รูปแคปหน้าจอ'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);
    if (image == null) return;

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final Uint8List imageBytes = await image.readAsBytes();
      final aiResponse = await locator<GeminiRemoteDataSource>()
          .analyzeReceiptImage(imageBytes);
      final data = jsonDecode(aiResponse['raw']);

      if (mounted) Navigator.pop(context);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(data['title'] ?? 'สรุปรายการ'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💰 ยอดรวม: ${data['amount']} ฿',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const Divider(),
                  ...((data['items'] as List).map(
                    (item) => Text('• ${item['name']} (${item['price']} ฿)'),
                  )),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ยกเลิก'),
              ),
              FilledButton(
                onPressed: () {
                  _saveExpense(data);
                  Navigator.pop(context);
                },
                child: const Text('บันทึก'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _saveExpense(Map<String, dynamic> data) async {
    final newExpense = Expense()
      ..title = data['title'] ?? 'ร้านค้าทั่วไป'
      ..totalAmount = (data['amount'] ?? 0.0).toDouble()
      ..category = data['category'] ?? 'Other'
      ..date = data['date'] != null
          ? DateTime.parse(data['date'])
          : DateTime.now()
      ..itemNames = List<String>.from(
        data['items'].map((i) => i['name'] ?? 'ไม่ระบุชื่อ'),
      )
      ..itemPrices = List<double>.from(
        data['items'].map((i) => (i['price'] ?? 0.0).toDouble()),
      );

    await isar.writeTxn(() => isar.expenses.put(newExpense));
  }

  void _showDetail(Expense expense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    expense.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _deleteExpense(expense.id);
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ],
            ),
            const Divider(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: expense.itemNames.length,
                itemBuilder: (context, i) => ListTile(
                  leading: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 20,
                  ),
                  title: Text(expense.itemNames[i]),
                  trailing: Text(
                    '${expense.itemPrices[i].toStringAsFixed(2)} ฿',
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'รวมสุทธิ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${expense.totalAmount.toStringAsFixed(2)} ฿',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'ม.ค.',
      'ก.พ.',
      'มี.ค.',
      'เม.ย.',
      'พ.ค.',
      'มิ.ย.',
      'ก.ค.',
      'ส.ค.',
      'ก.ย.',
      'ต.ค.',
      'พ.ย.',
      'ธ.ค.',
    ];
    return months[month - 1];
  }
}

// --- [ ส่วนที่ 3: หน้าสรุปรายเดือน ] ---
class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isar = locator<Isar>();
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    return Scaffold(
      appBar: AppBar(title: const Text('สรุปรายเดือน'), centerTitle: true),
      body: StreamBuilder<List<Expense>>(
        stream: isar.expenses
            .filter()
            .dateGreaterThan(startOfMonth)
            .watch(fireImmediately: true),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final list = snapshot.data!;
          double total = list.fold(0, (sum, item) => sum + item.totalAmount);
          Map<String, double> categoryMap = {};
          for (var item in list) {
            categoryMap[item.category] =
                (categoryMap[item.category] ?? 0) + item.totalAmount;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(35),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.deepPurple, Color(0xFF9575CD)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'เดือนนี้ใช้ไปแล้ว',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      Text(
                        '${total.toStringAsFixed(2)} ฿',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                ...categoryMap.entries.map(
                  (e) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getCategoryColor(
                          e.key,
                        ).withOpacity(0.1),
                        child: Icon(
                          _getCategoryIcon(e.key),
                          color: _getCategoryColor(e.key),
                        ),
                      ),
                      title: Text(
                        e.key,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Text(
                        '${e.value.toStringAsFixed(2)} ฿',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// --- [ ส่วนที่ 4: Helpers ] ---
IconData _getCategoryIcon(String category) {
  switch (category) {
    case 'Food':
      return Icons.restaurant_rounded;
    case 'Travel':
      return Icons.directions_car_filled_rounded;
    default:
      return Icons.local_mall_rounded;
  }
}

Color _getCategoryColor(String category) {
  switch (category) {
    case 'Food':
      return Colors.orange.shade700;
    case 'Travel':
      return Colors.blue.shade700;
    default:
      return Colors.purple.shade700;
  }
}
