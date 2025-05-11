// Diğer importlar...
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:qoo_quote/core/theme/colors.dart';
import 'package:qoo_quote/screens/create_screen.dart';
import 'package:qoo_quote/screens/home_page.dart';
import 'package:qoo_quote/screens/login.dart';
import 'package:qoo_quote/screens/profile.dart';
import 'package:qoo_quote/screens/search_screen.dart';
import 'package:qoo_quote/services/rest_services/auth_service.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    Createpage(),
    ProfilePage(),
  ];

  // Arama overlay kontrolü için
  bool _showSearchOverlay = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Add storage instance
  final _storage = const FlutterSecureStorage();
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuth();
    _checkTokens();
    _checkAccessToken();
  }

  Future<void> _checkAuth() async {
    try {
      final authCode = await _storage.read(key: 'auth_code');
      if (authCode != null) {
        debugPrint('Auth Code: $authCode');

        // Try to exchange the auth code
        try {
          final tokens = await _authService.exchangeToken(authCode);
          debugPrint(
              'Exchange successful - Access Token: ${tokens['accessToken']}');
          debugPrint(
              'Exchange successful - Refresh Token: ${tokens['refreshToken']}');
        } catch (e) {
          debugPrint('Token exchange error: $e');
        }
      } else {
        debugPrint('No auth code found in secure storage');
      }
    } catch (e) {
      debugPrint('Error checking auth: $e');
    }
  }

  Future<void> _checkTokens() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh-token');
      debugPrint('Refresh Token: $refreshToken');
    } catch (e) {
      debugPrint('Error reading refresh token: $e');
    }
  }

  Future<void> _checkAccessToken() async {
    try {
      final token = await _storage.read(key: 'access-token');
      if (token != null) {
        debugPrint('Access Token found: $token');
      } else {
        debugPrint('No access token found in secure storage');
      }
    } catch (e) {
      debugPrint('Error reading access token: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onNavTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Text _buildNavText(String text, bool isActive) {
    return Text(
      text,
      style: isActive
          ? TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              foreground: Paint()
                ..shader = const LinearGradient(
                  colors: <Color>[AppColors.tertiary, AppColors.tertiary],
                ).createShader(const Rect.fromLTWH(0.0, 0.0, 100.0, 20.0)),
            )
          : const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.grey,
            ),
    );
  }

  Future<void> _showLogoutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Çıkış Yap',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Çıkış yapmak istediğinize emin misiniz?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'İptal',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Çıkış Yap',
                style: TextStyle(color: Colors.red[300]),
              ),
              onPressed: () async {
                // Clear the access token
                await _storage.deleteAll();

                // Restart app from login page
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: SvgPicture.asset(
          "assets/appicon.svg",
          height: 50,
        ),
        centerTitle: false,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings, color: Colors.white),
            color: Colors.grey[900],
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red[300]),
                    const SizedBox(width: 8),
                    Text(
                      'Çıkış Yap',
                      style: TextStyle(color: Colors.red[300]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          // Ana içerik
          Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => _onNavTapped(0),
                      child: _buildNavText("ANASAYFA", _currentIndex == 0),
                    ),
                    GestureDetector(
                      onTap: () => _onNavTapped(1),
                      child: _buildNavText("POST PAYLAŞ", _currentIndex == 1),
                    ),
                    GestureDetector(
                      onTap: () => _onNavTapped(2),
                      child: _buildNavText("PROFİL", _currentIndex == 2),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  children: _pages,
                  onPageChanged: _onPageChanged,
                ),
              ),
            ],
          ),

          // Blur ve Search overlay
          if (_showSearchOverlay)
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 5.0,
                sigmaY: 5.0,
              ),
              child: Container(
                color: Colors.black.withOpacity(0.3),
                width: double.infinity,
                height: double.infinity,
              ),
            ),

          // Search TextField
          if (_showSearchOverlay)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.4,
              left: 24,
              right: 24,
              child: Material(
                color: Colors.transparent,
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      setState(() {
                        _showSearchOverlay = false;
                      });
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  SearchPage(
                            initialQuery: value,
                          ),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin = Offset(0.0, 1.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOutCubic;

                            var tween = Tween(begin: begin, end: end).chain(
                              CurveTween(curve: curve),
                            );

                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      );
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'keyword',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide:
                          BorderSide(color: Colors.pink.withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: AppColors.secondary),
                    ),
                    prefixIcon: Icon(Icons.search,
                        color: Colors.white.withOpacity(0.5)),
                    filled: true,
                    fillColor: Colors.grey[900],
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _showSearchOverlay = false;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _showSearchOverlay = true;
          });
          _searchFocusNode.requestFocus();
        },
        backgroundColor: Colors.black,
        shape: const CircleBorder(), // Yuvarlak şekil eklendi
        elevation: 4, // Opsiyonel: gölge efekti
        child: const Icon(
          Icons.search,
          color: AppColors.secondary,
        ),
      ),
    );
  }
}
