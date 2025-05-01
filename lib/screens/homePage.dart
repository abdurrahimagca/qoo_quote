import 'package:flutter/material.dart';
import 'package:qoo_quote/screens/userPage.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return PostCard(index: index);
      },
    );
  }
}

class PostCard extends StatelessWidget {
  final int index;
  const PostCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black, // Gradient yerine düz siyah renk
        borderRadius: BorderRadius.zero, // Köşeleri keskin yapar
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst Bilgi - Kullanıcı Profili
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    // Kullanıcı profil sayfasına git
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Userpage(),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.purple.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: const CircleAvatar(
                      backgroundImage: AssetImage("assets/photo4.jpeg"),
                      radius: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Kullanıcı profil sayfasına git
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Userpage(),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "USERNAME",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                    ),
                  ),
                ),
                PopupMenuButton(
                  icon: Icon(
                    Icons.more_horiz,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  color: Colors.grey[850],
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Row(
                        children: [
                          const Icon(Icons.bookmark_border,
                              color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            "Kaydet",
                            style:
                                TextStyle(color: Colors.white.withOpacity(0.9)),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          const Icon(Icons.flag_outlined, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            "Şikayet Et",
                            style:
                                TextStyle(color: Colors.white.withOpacity(0.9)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Alıntı Görseli
          ClipRRect(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              child: AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/photo2.jpeg',
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.5),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Alt Bilgiler
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildInteractionButton(
                  Icons.favorite_border,
                  "128",
                  Colors.pink[300]!,
                ),
                const SizedBox(width: 16),
                _buildInteractionButton(
                  Icons.chat_bubble_outline,
                  "24",
                  Colors.blue[300]!,
                ),
                const Spacer(),
                _buildInteractionButton(
                  Icons.bookmark_border,
                  "",
                  Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButton(IconData icon, String count, Color color) {
    return Row(
      children: [
        Icon(
          icon,
          color: color.withOpacity(0.9),
          size: 22,
        ),
        if (count.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(
            count,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
