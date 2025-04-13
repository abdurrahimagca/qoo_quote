import 'package:flutter/material.dart';

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
    return Card(
      margin: const EdgeInsets.all(12),
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst Bilgi
          ListTile(
            leading: const CircleAvatar(
              backgroundImage: AssetImage("assets/photo4.jpeg"),
              radius: 18,
            ),
            title: const Text("Bacıganırtan31",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
            subtitle: const Text(
              "21 saat önce",
              style: TextStyle(color: Colors.white38),
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(child: Text("Şikayet Et")),
                const PopupMenuItem(child: Text("Kaydet")),
              ],
              icon: const Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
            ),
          ),

          // Fotoğraf
          AspectRatio(
            aspectRatio: 1, // Kare oranı
            child: Image.asset(
              'assets/photo2.jpeg',
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),

          // Alt Bilgiler
          const Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: const [
                Icon(Icons.favorite_border, color: Colors.white),
                SizedBox(width: 8),
                Text("128", style: TextStyle(color: Colors.white)),
                Spacer(),
                Text("21 saat önce", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
