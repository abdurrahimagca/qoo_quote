import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qoo_quote/core/theme/colors.dart';
import 'package:qoo_quote/services/graphql_service.dart';

class BuildLastPosts extends StatefulWidget {
  const BuildLastPosts({super.key});

  @override
  State<BuildLastPosts> createState() => _BuildLastPostsState();
}

class _BuildLastPostsState extends State<BuildLastPosts> {
  bool _refreshPosts = false;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>?>(
      key: ValueKey(_refreshPosts), // Yenileme için key ekledik
      future: GraphQLService.getLastPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return const Center(
              child: Text(
            'Henüz bir gönderi yayınlamadınız.',
            style: TextStyle(color: Colors.white),
          ));
        }

        final posts = snapshot.data!;
        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return _buildPostsList(
              post: post,
              imageUrl: post['imageUrl'],
              title: post['title'],
              text: post['postText'],
              author: post['author']['username'],
              authorImage: post['author']['profilePictureUrl'],
              createdAt: DateTime.parse("2025-05-17T21:10:19.017Z"),
            );
          },
        );
      },
    );
  }

  Widget _buildPostsList({
    required Map<String, dynamic> post,
    required String imageUrl,
    required String title,
    required String text,
    required String author,
    required String authorImage,
    required DateTime createdAt,
    bool isLiked = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.zero,
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
          // User Profile Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.secondary,
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(authorImage),
                    radius: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        author,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
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
                      onTap: () async {
                        // PopupMenuItem'ın onTap'i Navigator.pop'tan sonra çalıştığı için
                        // Future.delayed kullanıyoruz
                        Future.delayed(
                          Duration.zero,
                          () => showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Colors.grey[850],
                              title: const Text(
                                'Gönderiyi Sil',
                                style: TextStyle(color: Colors.white),
                              ),
                              content: const Text(
                                'Bu gönderiyi silmek istediğinize emin misiniz?',
                                style: TextStyle(color: Colors.white70),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    'İptal',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(context); // Dialog'u kapat
                                    final success =
                                        await GraphQLService.deletePost(
                                            post['id']);
                                    if (success) {
                                      setState(() {
                                        _refreshPosts =
                                            !_refreshPosts; // FutureBuilder'ı yenilemek için toggle
                                      });
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Gönderi başarıyla silindi'),
                                          ),
                                        );
                                      }
                                    } else {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Gönderi silinirken bir hata oluştu'),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: const Text(
                                    'Sil',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Text(
                        "Kaldır",
                        style: TextStyle(color: Colors.white.withOpacity(0.9)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Quote Image
          ClipRRect(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              child: AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[900],
                        child: const Icon(Icons.error, color: Colors.white),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
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
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Interaction Buttons
        ],
      ),
    );
  }
}
