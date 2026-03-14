AI Smart Expense Tracker 🚀
Smart Personal Finance Assistant powered by Gemini AI
แอปพลิเคชันบันทึกและจัดการค่าใช้จ่ายอัจฉริยะ พัฒนาด้วยเทคโนโลยี Flutter และ Gemini AI (Multimodal) ที่สามารถวิเคราะห์รูปภาพใบเสร็จเพื่อแยกหมวดหมู่และบันทึกข้อมูลได้โดยอัตโนมัติ พร้อมระบบจัดการข้อมูลแบบแยกรายเดือน

คุณสมบัติเด่น (Features)
Multimodal AI Scanning: ใช้ Gemini 2.0 Flash ในการวิเคราะห์รูปภาพใบเสร็จโดยตรง (Image-to-JSON) ทำให้มีความแม่นยำสูงกว่าระบบ OCR ทั่วไป
Thai Language Support: รองรับการอ่านชื่อร้านค้าและรายการสินค้าภาษาไทยจากใบเสร็จ 7-Eleven, CP Axtra และร้านค้าทั่วไป
Automatic Monthly Grouping: จัดกลุ่มรายการใช้จ่ายตามเดือนและปีอัตโนมัติ พร้อมสรุปยอดรวมของแต่ละเดือน
Local Database: ใช้ Isar Database ในการจัดเก็บข้อมูลแบบ NoSQL ภายในเครื่อง ทำให้แอปทำงานได้รวดเร็วและปลอดภัย
Material 3 Design: ส่วนต่อประสานกับผู้ใช้ (UI) ที่ทันสมัย สะอาดตา และใช้งานง่าย (User-Friendly)

สถาปัตยกรรมระบบ (Architecture)
โปรเจกต์นี้เลือกใช้โครงสร้างแบบ Layered Architecture เพื่อให้ง่ายต่อการขยายระบบ (Scalability) และการทดสอบโค้ด (Maintainability):
Presentation Layer: จัดการส่วนของหน้าจอ (MainNavigation, HomePage, SummaryPage) และการตอบสนองต่อผู้ใช้
Data Layer: รับผิดชอบการติดต่อสื่อสารกับภายนอก
GeminiRemoteDataSource: เชื่อมต่อกับ Gemini AI API
Isar: จัดการฐานข้อมูลภายในเครื่อง
ExpenseModel: โครงสร้างข้อมูล (Schema) ของระบบ
Core Layer: ส่วนของระบบจัดการส่วนกลาง เช่น Dependency Injection (GetIt) เพื่อจัดการ Lifecycle ของ Service ต่างๆ

เทคโนโลยีที่ใช้ (Tech Stack)
Frontend: Flutter (Dart)
AI Engine: Google Gemini AI API
Database: Isar Database (Local NoSQL)
Network: Dio (HTTP Client)
State & DI: GetIt & Stateful Widgets

วิธีการติดตั้งและรันโปรเจกต์ (Setup Instructions)
1.ติดตั้ง Dependencies:
2.flutter pub get
3.จัดการ API Key (ความปลอดภัย):
สร้างไฟล์ชื่อ .env ไว้ที่โฟลเดอร์นอกสุด (Root)
เพิ่ม API Key ของคุณลงในไฟล์ดังนี้:
GEMINI_API_KEY=ใส่_API_KEY_ของคุณที่นี่
4.สร้าง Database Schema (Build Runner):
flutter pub run build_runner build --delete-conflicting-outputs
5.รันแอปพลิเคชัน:
flutter run

นโยบายความปลอดภัย (Security Policy)
โปรเจกต์นี้ปฏิบัติตามมาตรฐานความปลอดภัยอย่างเคร่งครัด โดย ห้าม นำ API Key หรือความลับของระบบฝังลงใน Source Code โดยตรง แต่จะใช้การจัดการผ่านระบบ Environment Variables (.env) และมีการตั้งค่า .gitignore เพื่อไม่ให้ข้อมูลสำคัญหลุดไปยัง Repository สาธารณะ

พัฒนาโดย
Thaneyapat Jaruspachaskul Computer Engineering Student!!!!!

Thxyou
