import 'package:flutter/material.dart';
import 'package:qoo_quote/core/theme/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserPost {
  final String imageUrl;
  final String quote;
  final String bookTitle;
  final String author;

  UserPost({
    required this.imageUrl,
    required this.quote,
    required this.bookTitle,
    required this.author,
  });
}

class Userpage extends StatefulWidget {
  const Userpage({super.key});

  @override
  State<Userpage> createState() => _UserpageState();
}

class _UserpageState extends State<Userpage> {
  // Örnek veriler
  final String username = "John Doe";
  final String profileImage =
      "https://picsum.photos/200"; // Örnek profil fotoğrafı
  final int followers = 1234;
  final int following = 567;

  // Örnek gönderiler
  final List<UserPost> posts = [
    UserPost(
      imageUrl: "assets/photo2.jpeg", // Local asset olarak
      quote: "Hayat kısa, kuşlar uçuyor.",
      bookTitle: "Martı",
      author: "Richard Bach",
    ),
    UserPost(
      imageUrl: "assets/photo2.jpeg",
      quote: "Yaşamak bir ağaç gibi tek ve hür...",
      bookTitle: "Kuvâyi Milliye",
      author: "Nazım Hikmet",
    ),
    UserPost(
      imageUrl: "assets/photo2.jpeg", // Local asset olarak
      quote: "Hayat kısa, kuşlar uçuyor.",
      bookTitle: "Martı",
      author: "Richard Bach",
    ),
    UserPost(
      imageUrl: "assets/photo2.jpeg",
      quote: "Yaşamak bir ağaç gibi tek ve hür...",
      bookTitle: "Kuvâyi Milliye",
      author: "Nazım Hikmet",
    ),
    UserPost(
      imageUrl: "assets/photo2.jpeg", // Local asset olarak
      quote: "Hayat kısa, kuşlar uçuyor.",
      bookTitle: "Martı",
      author: "Richard Bach",
    ),
    UserPost(
      imageUrl: "assets/photo2.jpeg",
      quote: "Yaşamak bir ağaç gibi tek ve hür...",
      bookTitle: "Kuvâyi Milliye",
      author: "Nazım Hikmet",
    ),
    UserPost(
      imageUrl: "assets/photo2.jpeg", // Local asset olarak
      quote: "Hayat kısa, kuşlar uçuyor.",
      bookTitle: "Martı",
      author: "Richard Bach",
    ),
    UserPost(
      imageUrl: "assets/photo2.jpeg",
      quote: "Yaşamak bir ağaç gibi tek ve hür...",
      bookTitle: "Kuvâyi Milliye",
      author: "Nazım Hikmet",
    ),
    // Daha fazla post eklenebilir
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.background,
            expandedHeight: 300,
            pinned: false, // AppBar'ın sabit kalmaması için false yapıldı
            floating: true, // Aşağı kaydırırken hemen görünmesi için
            snap: true, // Yarım kaydırmada tam açılması için
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) {
                  if (value == 'change_photo') {
                    // TODO: Profil fotoğrafı değiştirme işlemi
                  } else if (value == 'logout') {
                    // TODO: Çıkış yapma işlemi
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'change_photo',
                    child: Text('Profil Fotoğrafını Değiştir'),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Text('Çıkış Yap'),
                  ),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: CachedNetworkImageProvider(profileImage),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      username,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStatColumn('Takipçiler', followers),
                        Container(
                          height: 30,
                          width: 1,
                          color: Colors.white30,
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        _buildStatColumn('Takip Edilenler', following),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // Gönderiler
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final post = posts[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        post.imageUrl,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.quote,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${post.bookTitle} - ${post.author}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: posts.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, int count) {
    return GestureDetector(
      onTap: () {
        // TODO: İlgili sayfaya yönlendirme
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
