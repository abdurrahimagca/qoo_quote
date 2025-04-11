import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qoo_quote/core/theme/colors.dart';
import 'package:qoo_quote/screens/profile.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Icon(Icons.camera_alt), // Uygulama ikonu
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
            ), // Ayarlar butonu
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Anasayfa'),
            Tab(text: 'Sayfa 2'),
            Tab(text: 'Sayfa 3'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Anasayfa Sayfası
          ListView(
            children: [
              buildPost('photo4.jpeg', 'Kullanıcı1', 125),
              buildPost('photo2.jpeg', 'Kullanıcı2', 80),
              buildPost('photo3.jpeg', 'Kullanıcı3', 150),
            ],
          ),
          // Sayfa 2 (örnek sayfa)
          Profile(),
          // Sayfa 3 (örnek sayfa)
          Center(child: Text('Örnek Sayfa 3')),
        ],
      ),
    );
  }

  // Fotoğraf ve beğenme butonları içeren postlar için widget
  Widget buildPost(String imageName, String username, int likes) {
    return Card(
      color: Colors.white10,
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          // Kullanıcı Adı
          Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                children: [
                  Icon(
                    Icons.account_circle,
                    size: 40,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    username,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              )),
          // Fotoğraf
          Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width,
              child: Image.asset('assets/$imageName', fit: BoxFit.cover)),
          // Beğenme sayısı ve beğenme butonu
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.thumb_up_alt_outlined,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    // Beğenme işlemi yapılacak
                  },
                ),
                Text('$likes',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                Spacer(),
                Text(
                  "21 saat önce",
                  style: TextStyle(color: Colors.white54),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
