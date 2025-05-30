import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qoo_quote/core/theme/colors.dart';
import 'package:qoo_quote/services/graphql_service.dart';
import 'package:qoo_quote/widgets/like_button.dart';

class BuildUserPosts extends StatefulWidget {
  final String userId;
  final String? username;
  final String? profileImage;
  const BuildUserPosts({
    super.key,
    required this.userId,
    this.username,
    this.profileImage,
  });

  @override
  State<BuildUserPosts> createState() => _BuildProfilePostsState();
}

class _BuildProfilePostsState extends State<BuildUserPosts> {
  bool _refreshPosts = false;
  bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>?>(
      key: ValueKey(_refreshPosts),
      future: GraphQLService.getUserPosts(widget.userId)
          .then((value) => value?.cast<Map<String, dynamic>>()),
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
          padding: const EdgeInsets.symmetric(horizontal: 0),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return _buildPostsList(
              post: post,
              imageUrl: post['imageUrl'],
              title: post['title'],
              text: post['postText'],
              createdAt: DateTime.parse(post['createdAt']),
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
    required DateTime createdAt,
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
                    backgroundImage:
                        CachedNetworkImageProvider(widget.profileImage ?? ''),
                    radius: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.username.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
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
                        debugPrint(post['id']);

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
                    // Shadow overlay
                    Container(
                      color: Colors.black38,
                    ),
                    // Text container with centered text
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Center(
                        child: Text(
                          text,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            shadows: [
                              Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 3,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Like button
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: LikeButton(
                        postId: post["id"],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
