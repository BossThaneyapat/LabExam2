import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:isar/isar.dart';
import '../../data/datasources/ml_kit_datasource.dart';
import '../../data/datasources/gemini_remote_datasource.dart';

final locator = GetIt.instance;

Future<void> init(Isar isar) async {
  // 1. ลงทะเบียน Isar ที่รับมาจาก main.dart
  locator.registerSingleton<Isar>(isar);

  // 2. ลงทะเบียน ML Kit
  locator.registerLazySingleton(() => MLKitDataSource());

  // 3. ลงทะเบียน Dio (สำหรับต่อเน็ต)
  locator.registerLazySingleton(
    () => Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    ),
  );

  // 4. ลงทะเบียน Gemini
  locator.registerLazySingleton(() => GeminiRemoteDataSource(locator<Dio>()));
}
