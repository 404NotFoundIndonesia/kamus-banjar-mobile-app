import 'package:flutter/material.dart';
import 'package:kamus_banjar_mobile_app/repository/dictionary_repository.dart';
import 'package:kamus_banjar_mobile_app/service/dictionary_service.dart';
import 'package:kamus_banjar_mobile_app/view/alphabets_view.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter/services.dart';

void main() {
  const DictionaryService dictionaryService =
      DictionaryService(baseUrl: 'http://kamus-banjar.404notfound.fun');
  const DictionaryRepository dictionaryRepository =
      DictionaryRepository(dictionaryService: dictionaryService);

  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const MyApp(dictionaryRepository: dictionaryRepository));
  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  final DictionaryRepository dictionaryRepository;

  const MyApp({super.key, required this.dictionaryRepository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.blue.shade800,
          selectionColor: Colors.blue.shade200,
          selectionHandleColor: Colors.blue.shade700,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: AlphabetsView(dictionaryRepository: dictionaryRepository),
    );
  }
}
