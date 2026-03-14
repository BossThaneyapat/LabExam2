import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'core/di/injection.dart' as di;
import 'presentation/pages/home_page.dart'; // ไฟล์นี้มี MainNavigation อยู่ข้างใน
import 'data/models/expense_model.dart';

void main() async {
  // 1. เตรียมพร้อม Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // 2. โหลดไฟล์ .env
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Warning: .env file not found");
  }

  // 3. เริ่มต้นฐานข้อมูล Isar
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open([ExpenseSchema], directory: dir.path);

  // 4. รันระบบ Dependency Injection
  await di.init(isar);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Smart Expense',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // แก้จาก HomePage() เป็น MainNavigation() เพื่อให้ระบบสลับหน้าทำงานครับ
      home: const MainNavigation(),
    );
  }
}
