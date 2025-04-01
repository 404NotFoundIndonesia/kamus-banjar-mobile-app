import 'package:flutter/material.dart';
import 'package:kamus_banjar_mobile_app/repository/dictionary_repository.dart';
import 'package:kamus_banjar_mobile_app/service/dictionary_service.dart';
import 'package:kamus_banjar_mobile_app/view/info_view.dart';
import 'package:kamus_banjar_mobile_app/view/saved_words_page.dart';
import 'package:kamus_banjar_mobile_app/view/alphabets_view.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter/services.dart';
import 'package:kamus_banjar_mobile_app/view/setting_page.dart';
import 'package:kamus_banjar_mobile_app/view/word_type_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  const DictionaryService dictionaryService =
      DictionaryService(baseUrl: 'http://kamus-banjar.404notfound.fun');
  const DictionaryRepository dictionaryRepository =
      DictionaryRepository(dictionaryService: dictionaryService);

  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black,
    ),
  );

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  ThemeMode savedThemeMode = await _getSavedThemeMode();
  runApp(MyApp(
    dictionaryRepository: dictionaryRepository,
    initialThemeMode: savedThemeMode,
  ));
  FlutterNativeSplash.remove();
}

Future<ThemeMode> _getSavedThemeMode() async {
  final prefs = await SharedPreferences.getInstance();
  int index = prefs.getInt('themeMode') ?? 0;
  switch (index) {
    case 1:
      return ThemeMode.light;
    case 2:
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}

class MyApp extends StatefulWidget {
  final ThemeMode initialThemeMode;
  final DictionaryRepository dictionaryRepository;

  const MyApp({
    super.key,
    required this.dictionaryRepository,
    required this.initialThemeMode,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeMode themeMode;

  @override
  void initState() {
    super.initState();
    themeMode = widget.initialThemeMode;
  }

  int _themeModeToIndex(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 1;
      case ThemeMode.dark:
        return 2;
      case ThemeMode.system:
        return 0;
    }
  }

  void updateTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', _themeModeToIndex(mode));
    setState(() {
      themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: themeMode,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.blue.shade800,
          selectionColor: Colors.blue.shade200,
          selectionHandleColor: Colors.blue.shade700,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: MainScreen(
        dictionaryRepository: widget.dictionaryRepository,
        updateTheme: updateTheme,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final DictionaryRepository dictionaryRepository;
  final Function(ThemeMode) updateTheme;

  const MainScreen({
    super.key,
    required this.dictionaryRepository,
    required this.updateTheme,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  NavigationRailLabelType labelType = NavigationRailLabelType.all;
  bool showLeading = false;
  bool showTrailing = false;
  double groupAlignment = 0;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      AlphabetsView(dictionaryRepository: widget.dictionaryRepository),
      const WordTypeView(),
      SavedWordsPage(dictionaryRepository: widget.dictionaryRepository),
      const InfoView(),
      SettingPage(updateTheme: widget.updateTheme),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Row(
        children: [
          if (width > 600) ...[
            NavigationRail(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              indicatorColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.blue.shade700
                  : Colors.blue.shade100,
              selectedIndex: _selectedIndex,
              groupAlignment: groupAlignment,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: labelType,
              leading: showLeading
                  ? FloatingActionButton(
                      elevation: 0,
                      onPressed: () {},
                      child: const Icon(Icons.add),
                    )
                  : const SizedBox(),
              trailing: showTrailing
                  ? IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_horiz_rounded),
                    )
                  : const SizedBox(),
              destinations: const <NavigationRailDestination>[
                NavigationRailDestination(
                  icon: Icon(Icons.book_outlined),
                  selectedIcon: Icon(Icons.book),
                  label: Text('Kamus'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.library_books_outlined),
                  selectedIcon: Icon(Icons.library_books),
                  label: Text('Kata'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.bookmark_outline),
                  selectedIcon: Icon(Icons.bookmark),
                  label: Text('Markah'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.info_outlined),
                  selectedIcon: Icon(Icons.info),
                  label: Text('Tentang'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: Text('Pengaturan'),
                ),
              ],
            ),
            const SafeArea(child: VerticalDivider(thickness: 1, width: 1)),
          ],
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: width <= 600
          ? NavigationBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              indicatorColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.blue.shade700
                  : Colors.blue.shade100,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.book_outlined),
                  selectedIcon: Icon(Icons.book),
                  label: "Kamus",
                ),
                NavigationDestination(
                  icon: Icon(Icons.library_books_outlined),
                  selectedIcon: Icon(Icons.library_books),
                  label: "Kata",
                ),
                NavigationDestination(
                  icon: Icon(Icons.bookmark_outline),
                  selectedIcon: Icon(Icons.bookmark),
                  label: "Markah",
                ),
                NavigationDestination(
                  icon: Icon(Icons.info_outlined),
                  selectedIcon: Icon(Icons.info),
                  label: "Tentang",
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: "Pengaturan",
                ),
              ],
              selectedIndex: _selectedIndex,
            )
          : null,
    );
  }
}
