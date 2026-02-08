import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Import Pages
import 'features/auth/presentation/pages/login_page.dart';
import 'features/place/presentation/pages/place_search_page.dart';

// Import Logic/Data
import 'features/place/data/datasources/mapbox_place_remote.dart';
import 'features/place/data/repository/place_repository_impl.dart';
import 'features/place/domain/usecase/search_place_usecase.dart';
import 'features/place/presentation/bloc/place_search_placeholder_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase & FCM
  await _initializeFirebase();

  // Khởi tạo Dependencies (Sau này nên dùng GetIt để sạch hơn)
  final dio = Dio();
  final remoteDataSource = MapboxPlaceRemoteDataSource(dio: dio);
  final repository = PlaceRepositoryImpl(remoteDataSource: remoteDataSource);
  final searchPlaceUseCase = SearchPlaceUseCase(repository);

  runApp(MyApp(searchPlaceUseCase: searchPlaceUseCase));
}

/// Hàm hỗ trợ khởi tạo Firebase
Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp();
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Không cần await requestPermission nếu không cần xử lý kết quả ngay
    messaging.requestPermission(alert: true, badge: true, sound: true);

    // Lấy token nhưng không dùng await để tránh treo luồng main
    messaging.getToken().then((token) {
      debugPrint("FCM TOKEN: $token");
    }).catchError((e) => debugPrint("Lỗi lấy FCM Token: $e"));

  } catch (e) {
    debugPrint("Lỗi khởi tạo Firebase: $e");
  }
}

class MyApp extends StatelessWidget {
  final SearchPlaceUseCase searchPlaceUseCase;

  const MyApp({super.key, required this.searchPlaceUseCase});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      // Khởi tạo tất cả Bloc ở đây để dùng được ở mọi màn hình
      providers: [
        BlocProvider(
          create: (context) => PlaceSearchBloc(searchPlaceUseCase: searchPlaceUseCase),
        ),
        // BlocProvider(create: (context) => AuthBloc(...)), // Thêm AuthBloc vào đây khi xong
      ],
      child: MaterialApp(
        title: 'Ghep Xe App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: const Color(0xFF4A64FE),
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A64FE)),
        ),

        // Cấu hình Routes: Muốn chạy màn hình nào mặc định thì sửa ở initialRoute
        initialRoute: '/login',

        routes: {
          '/login': (context) => const LoginPage(),
          '/search': (context) => const PlaceSearchPage(),
          // '/forgot-password': (context) => const ForgotPasswordPage(),
        },
      ),
    );
  }
}