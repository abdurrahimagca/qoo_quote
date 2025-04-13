// Diğer importlar...
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qoo_quote/core/theme/colors.dart';
import 'package:qoo_quote/screens/createPage.dart';
import 'package:qoo_quote/screens/homePage.dart';
import 'package:qoo_quote/screens/userPage.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final TextEditingController _searchController = TextEditingController();
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    Createpage(),
    Userpage(),
  ];

  AnimationController? _animationController;
  Animation<double>? _animation;
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    );

    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _searchController.dispose();
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
                  colors: <Color>[
                    Color(0xFFFF416C),
                    Color(0xFFFF4B2B),
                  ],
                ).createShader(const Rect.fromLTWH(0.0, 0.0, 100.0, 20.0)),
            )
          : const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.grey,
            ),
    );
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
    });

    if (_showSearch) {
      _animationController?.forward();
    } else {
      _animationController?.reverse();
    }
  }

  Widget _buildSearchOverlay() {
    final bool isSearching = _searchController.text.isNotEmpty;

    return FadeTransition(
      opacity: _animation!,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              top: isSearching
                  ? MediaQuery.of(context).padding.top +
                      20 // SafeArea'yı dikkate al
                  : MediaQuery.of(context).size.height / 2 - 30,
              left: 24,
              right: 24,
              child: Material(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white.withOpacity(0.1),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "arama yap",
                    hintStyle: const TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        _searchController.clear();
                        FocusScope.of(context).unfocus();
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ),
            ),
            if (isSearching)
              Positioned(
                top: 140,
                left: 0,
                right: 0,
                bottom: 0,
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.all(12),
                      color: Colors.grey[900],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: const CircleAvatar(
                              backgroundImage: AssetImage("assets/photo4.jpeg"),
                              radius: 18,
                            ),
                            title: const Text(
                              "Bacıganırtan31",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            subtitle: const Text(
                              "21 saat önce",
                              style: TextStyle(color: Colors.white38),
                            ),
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(child: Text("Şikayet Et")),
                                const PopupMenuItem(child: Text("Kaydet")),
                              ],
                              icon: const Icon(Icons.more_vert,
                                  color: Colors.white),
                            ),
                          ),
                          AspectRatio(
                            aspectRatio: 1,
                            child: Image.asset(
                              'assets/photo2.jpeg',
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(15),
                            child: Row(
                              children: [
                                Icon(Icons.favorite_border,
                                    color: Colors.white),
                                SizedBox(width: 8),
                                Text("128",
                                    style: TextStyle(color: Colors.white)),
                                Spacer(),
                                Text("21 saat önce",
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
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
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.settings),
                color: Colors.white,
              )
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => _onNavTapped(0),
                      child: _buildNavText("HOME", _currentIndex == 0),
                    ),
                    GestureDetector(
                      onTap: () => _onNavTapped(1),
                      child: _buildNavText("CREATE", _currentIndex == 1),
                    ),
                    GestureDetector(
                      onTap: () => _onNavTapped(2),
                      child: _buildNavText("USR", _currentIndex == 2),
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
          floatingActionButton: FloatingActionButton(
            onPressed: _toggleSearch,
            backgroundColor: Colors.white,
            child: const Icon(Icons.search, color: Colors.black),
          ),
        ),
        if (_showSearch) _buildSearchOverlay(),
      ],
    );
  }
}
