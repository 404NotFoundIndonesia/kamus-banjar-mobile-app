import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:kamus_banjar_mobile_app/core/repositories/admin_repository.dart';
import 'package:kamus_banjar_mobile_app/core/repositories/auth_repository.dart';
import 'package:kamus_banjar_mobile_app/core/repositories/contribution_repository.dart';
import 'package:kamus_banjar_mobile_app/core/repositories/dictionary_repository.dart';
import 'package:kamus_banjar_mobile_app/core/repositories/saved_words_repository.dart';
import 'package:kamus_banjar_mobile_app/core/services/admin_service.dart';
import 'package:kamus_banjar_mobile_app/core/services/auth_service.dart';
import 'package:kamus_banjar_mobile_app/core/services/community_service.dart';
import 'package:kamus_banjar_mobile_app/core/services/contribution_service.dart';
import 'package:kamus_banjar_mobile_app/core/services/dictionary_service.dart';
import 'package:kamus_banjar_mobile_app/features/admin/admin_dashboard_view.dart';
import 'package:kamus_banjar_mobile_app/features/auth/account_view.dart';
import 'package:kamus_banjar_mobile_app/features/bookmarks/saved_words_page.dart';
import 'package:kamus_banjar_mobile_app/features/dictionary/views/words_view.dart';
import 'package:kamus_banjar_mobile_app/features/info/info_view.dart';
import 'package:kamus_banjar_mobile_app/features/settings/setting_page.dart';
import 'package:kamus_banjar_mobile_app/features/word_types/word_type_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  const String baseUrl = String.fromEnvironment('API_BASE_URL');
  const DictionaryService dictionaryService =
      DictionaryService(baseUrl: baseUrl);
  const DictionaryRepository dictionaryRepository =
      DictionaryRepository(dictionaryService: dictionaryService);

  const AuthService authService = AuthService(baseUrl: baseUrl);
  final AuthRepository authRepository =
      AuthRepository(authService: authService);

  const CommunityService communityService = CommunityService(baseUrl: baseUrl);
  final SavedWordsRepository savedWordsRepository = SavedWordsRepository(
    communityService: communityService,
    authRepository: authRepository,
  );

  const ContributionService contributionService =
      ContributionService(baseUrl: baseUrl);
  final ContributionRepository contributionRepository = ContributionRepository(
    service: contributionService,
    authRepository: authRepository,
  );

  const AdminService adminService = AdminService(baseUrl: baseUrl);
  final AdminRepository adminRepository = AdminRepository(
    service: adminService,
    authRepository: authRepository,
  );

  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black,
    ),
  );

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  ThemeMode savedThemeMode = await _getSavedThemeMode();
  await authRepository.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<CommunityService>.value(value: communityService),
        ChangeNotifierProvider.value(value: authRepository),
        ChangeNotifierProvider.value(value: savedWordsRepository),
        Provider<ContributionRepository>.value(value: contributionRepository),
        Provider<AdminRepository>.value(value: adminRepository),
      ],
      child: MyApp(
        dictionaryRepository: dictionaryRepository,
        initialThemeMode: savedThemeMode,
      ),
    ),
  );
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

// ignore: must_be_immutable
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
  bool _isInitialized = false;
  String initialAlphabet = "A";

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    initialAlphabet = prefs.getString('selectedAlphabet') ?? 'A';
    if (mounted) setState(() => _isInitialized = true);
  }

  List<Widget> _buildPages(bool isAdmin) {
    return [
      WordsView(
        alphabet: initialAlphabet,
        dictionaryRepository: widget.dictionaryRepository,
        pageToRefresh: MainScreen(
          dictionaryRepository: widget.dictionaryRepository,
          updateTheme: widget.updateTheme,
        ),
      ),
      const WordTypeView(),
      SavedWordsPage(dictionaryRepository: widget.dictionaryRepository),
      const AccountView(),
      const InfoView(),
      SettingPage(updateTheme: widget.updateTheme),
      if (isAdmin) const AdminDashboardView(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (!_isInitialized) {
      return const Scaffold(
          body: Center(
        child: CircularProgressIndicator(
          color: Color.fromARGB(113, 33, 149, 243),
          backgroundColor: Color.fromARGB(41, 33, 149, 243),
        ),
      ));
    }

    return Consumer<AuthRepository>(
      builder: (context, auth, _) {
        final isAdmin = auth.isAdmin;
        final pages = _buildPages(isAdmin);
        final safeIndex = _selectedIndex.clamp(0, pages.length - 1);

        final List<NavigationRailDestination> railDestinations = [
          const NavigationRailDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: Text('Kamus'),
          ),
          const NavigationRailDestination(
            icon: Icon(Icons.library_books_outlined),
            selectedIcon: Icon(Icons.library_books),
            label: Text('Kata'),
          ),
          const NavigationRailDestination(
            icon: Icon(Icons.bookmark_outline),
            selectedIcon: Icon(Icons.bookmark),
            label: Text('Markah'),
          ),
          const NavigationRailDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: Text('Akun'),
          ),
          const NavigationRailDestination(
            icon: Icon(Icons.info_outlined),
            selectedIcon: Icon(Icons.info),
            label: Text('Tentang'),
          ),
          const NavigationRailDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: Text('Pengaturan'),
          ),
          if (isAdmin)
            const NavigationRailDestination(
              icon: Icon(Icons.admin_panel_settings_outlined),
              selectedIcon: Icon(Icons.admin_panel_settings),
              label: Text('Admin'),
            ),
        ];

        final List<NavigationDestination> bottomDestinations = [
          const NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: "Kamus",
          ),
          const NavigationDestination(
            icon: Icon(Icons.library_books_outlined),
            selectedIcon: Icon(Icons.library_books),
            label: "Kata",
          ),
          const NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            selectedIcon: Icon(Icons.bookmark),
            label: "Markah",
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: "Akun",
          ),
          const NavigationDestination(
            icon: Icon(Icons.info_outlined),
            selectedIcon: Icon(Icons.info),
            label: "Tentang",
          ),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: "Pengaturan",
          ),
          if (isAdmin)
            const NavigationDestination(
              icon: Icon(Icons.admin_panel_settings_outlined),
              selectedIcon: Icon(Icons.admin_panel_settings),
              label: "Admin",
            ),
        ];

        return Scaffold(
      body: Row(
        children: [
          if (width > 600) ...[
            NavigationRail(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              indicatorColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.blue.shade700
                  : Colors.blue.shade100,
              selectedIndex: safeIndex,
              groupAlignment: 0,
              onDestinationSelected: (int index) async {
                final prefs = await SharedPreferences.getInstance();
                setState(() {
                  initialAlphabet = prefs.getString('selectedAlphabet') ?? 'A';
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              leading: const SizedBox(),
              trailing: const SizedBox(),
              destinations: railDestinations,
            ),
            const SafeArea(child: VerticalDivider(thickness: 1, width: 1)),
          ],
          Expanded(child: pages[safeIndex]),
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
              destinations: bottomDestinations,
              selectedIndex: _selectedIndex,
            )
          : null,
        );
      },
    );
  }
}
