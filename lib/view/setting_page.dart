import 'package:flutter/material.dart';
import 'package:kamus_banjar_mobile_app/view/components/custom_app_bar.dart';
import 'package:kamus_banjar_mobile_app/view/components/gradient_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  final Function(ThemeMode) updateTheme;

  const SettingPage({super.key, required this.updateTheme});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  ThemeMode currentTheme = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    int index = prefs.getInt('themeMode') ?? 0;

    setState(() {
      currentTheme = _getThemeFromIndex(index);
    });
  }

  ThemeMode _getThemeFromIndex(int index) {
    switch (index) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> _saveTheme(ThemeMode theme) async {
    final prefs = await SharedPreferences.getInstance();
    int index;

    switch (theme) {
      case ThemeMode.light:
        index = 1;
        break;
      case ThemeMode.dark:
        index = 2;
        break;
      default:
        index = 0;
        break;
    }

    await prefs.setInt('themeMode', index);
    setState(() {
      currentTheme = theme;
    });

    widget.updateTheme(theme);
  }

  @override
  Widget build(BuildContext context) {
    bool isClipped = MediaQuery.of(context).viewPadding.top == 0.0;

    return Scaffold(
      appBar: CustomAppBar(
        title: "Pengaturan",
        isClipped: isClipped,
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: Stack(
            children: [
              const GradientBackground(),
              SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  child: Column(
                    spacing: 8,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _saveTheme(ThemeMode.light);
                            },
                            child: Column(
                              spacing: 4,
                              children: [
                                Container(
                                  height: 160,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8)),
                                    border: Border.all(
                                        color: currentTheme == ThemeMode.light
                                            ? Colors.blue
                                            : Colors.grey.shade500,
                                        width: 4),
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const Text(
                                    "Kamus Banjar Online",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const Text("Terang"),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _saveTheme(ThemeMode.dark);
                            },
                            child: Column(
                              spacing: 4,
                              children: [
                                Container(
                                  height: 160,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade800,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8)),
                                    border: Border.all(
                                        color: currentTheme == ThemeMode.dark
                                            ? Colors.blue
                                            : Colors.grey.shade500,
                                        width: 4),
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const Text(
                                    "Kamus Banjar Online",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const Text("Gelap"),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _saveTheme(ThemeMode.system);
                            },
                            child: Column(
                              spacing: 4,
                              children: [
                                Container(
                                  height: 160,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade500,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8)),
                                    border: Border.all(
                                        color: currentTheme == ThemeMode.system
                                            ? Colors.blue
                                            : Colors.grey.shade500,
                                        width: 4),
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const Text(
                                    "Kamus Banjar Online",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const Text("Sistem"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
