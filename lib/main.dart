import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Import Pages
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/intro_page.dart'; // Giả định đường dẫn trang intro
import 'features/place/presentation/pages/place_search_page.dart';

// Import Logic/Data
import 'features/auth/data/datasources/auth_remote_data_source.dart'; // Thêm mới
import 'features/auth/presentation/bloc/auth_bloc.dart'; // Thêm mới
import 'features/place/data/datasources/mapbox_place_remote.dart';
import 'features/place/data/repository/place_repository_impl.dart';
import 'features/place/domain/usecase/search_place_usecase.dart';
import 'features/place/presentation/bloc/place_search_placeholder_bloc.dart';
import 'package:http/http.dart' as http;
import 'features/home/presentation/pages/home_page.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFirebase();

  // Khởi tạo Client của thư viện http
  final httpClient = http.Client();

  // ĐÚNG: Khởi tạo lớp Implementation (có đuôi Impl)
  // Và truyền 'client' thay vì 'dio'
  final authRemoteDataSource = AuthRemoteDataSourceImpl(client: httpClient);

  // Giữ nguyên Dio cho Mapbox nếu bên đó dùng Dio
  final dio = Dio();
  final remoteDataSource = MapboxPlaceRemoteDataSource(dio: dio);
  final repository = PlaceRepositoryImpl(remoteDataSource: remoteDataSource);
  final searchPlaceUseCase = SearchPlaceUseCase(repository);

  runApp(MyApp(
    searchPlaceUseCase: searchPlaceUseCase,
    authRemoteDataSource: authRemoteDataSource,
  ));
}

/// Hàm hỗ trợ khởi tạo Firebase (Giữ nguyên)
Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp();
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    messaging.requestPermission(alert: true, badge: true, sound: true);
    messaging.getToken().then((token) {
      debugPrint("FCM TOKEN: $token");
    }).catchError((e) => debugPrint("Lỗi lấy FCM Token: $e"));
  } catch (e) {
    debugPrint("Lỗi khởi tạo Firebase: $e");
  }
}

class MyApp extends StatelessWidget {
  final SearchPlaceUseCase searchPlaceUseCase;
  final AuthRemoteDataSource authRemoteDataSource; // Thêm mới

  const MyApp({
    super.key,
    required this.searchPlaceUseCase,
    required this.authRemoteDataSource, // Thêm mới
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => PlaceSearchBloc(searchPlaceUseCase: searchPlaceUseCase),
        ),
        // Khởi tạo AuthBloc và kích hoạt kiểm tra token ngay lập tức
        BlocProvider(
          create: (context) => AuthBloc(authRemoteDataSource: authRemoteDataSource)..add(AppStarted()),
        ),
      ],
      child: MaterialApp(
        title: 'Ghep Xe App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: const Color(0xFF4A64FE),
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A64FE)),
        ),

        // Thay đổi sang trang Intro làm khởi đầu
        initialRoute: '/intro',

        routes: {
          '/intro': (context) => const IntroPage(), // Trang mới
          '/login': (context) => const LoginPage(),
          '/search': (context) => const PlaceSearchPage(),
          '/home': (context) => const HomePage(), // Thêm dòng này
        },
      ),
    );
  }
}