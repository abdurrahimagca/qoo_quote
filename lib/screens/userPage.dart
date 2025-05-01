import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:qoo_quote/core/theme/colors.dart';

//please do not use these kind of wrong types
//it is not a bad practice
//what we're building is NOT A KINDLE
class UserPost {
  final String imageUrl;
  final String quote;
  //what's the purpose of this?
  final String bookTitle;
  // author is only the user it self
  final String author;

  UserPost({
    //we do not take imageUrl never what u have to do is completely
    //different a base64 string should be given
    required this.imageUrl,
    required this.quote,
    required this.bookTitle,
    required this.author,
  });
}

class UserItem {
  final String username;
  final String profileImage;
  bool isFollowing;

  UserItem({
    required this.username,
    required this.profileImage,
    this.isFollowing = false,
  });
}

class Userpage extends StatefulWidget {
  const Userpage({super.key});

  @override
  State<Userpage> createState() => _UserpageState();
}

class _UserpageState extends State<Userpage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  final List<UserItem> users = List.generate(
    10,
    (index) => UserItem(
      username: "user.${index + 1}",
      profileImage: "https://picsum.photos/200",
    ),
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: 1, // POSTS sekmesinden başlaması için
    );
    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        // Removed DefaultTabController
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: AppColors.background,
              expandedHeight: 220,
              floating: false,
              pinned: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.end, // Aşağıda hizalama
                    children: [
                      CircleAvatar(
                        radius: 45, // Biraz küçültüldü
                        backgroundImage: CachedNetworkImageProvider(
                          "https://picsum.photos/200",
                        ),
                      ),
                      const SizedBox(height: 20), // Azaltıldı
                      const Text(
                        "Loremipsum02",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18, // Biraz küçültüldü
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TabBar(
                        controller: _tabController,
                        dividerColor: Colors.transparent,
                        indicatorColor: AppColors.primary,
                        labelColor: AppColors.primary, // Seçili tab rengi

                        tabs: const [
                          Tab(text: "TAKİP"),
                          Tab(text: "PROFİL"),
                          Tab(text: "TAKİPÇİ"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildUserList(users),
            _buildPostsList(),
            _buildUserList(users),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildUserList(List<UserItem> users) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 0),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(user.profileImage),
            ),
            title: Text(
              user.username,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: OutlinedButton(
              onPressed: () {
                setState(() {
                  user.isFollowing = !user.isFollowing;
                });
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: user.isFollowing ? Colors.grey : AppColors.secondary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                user.isFollowing ? 'Following' : 'Follow',
                style: TextStyle(
                  color: user.isFollowing ? Colors.grey : AppColors.secondary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInteractionButton(IconData icon, String count, Color color) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        if (count.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(
            count,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPostsList() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: 10, // Example post count
      itemBuilder: (context, index) {
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
                      child: const CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(
                            "https://picsum.photos/200"),
                        radius: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
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
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.9)),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          child: Row(
                            children: [
                              const Icon(Icons.flag_outlined,
                                  color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                "Şikayet Et",
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.9)),
                              ),
                            ],
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
                        CachedNetworkImage(
                          imageUrl: 'https://picsum.photos/400',
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

              // Interaction Buttons
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
      },
    );
  }
}
