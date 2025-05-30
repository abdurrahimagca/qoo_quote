import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:qoo_quote/core/theme/colors.dart';
import 'package:qoo_quote/screens/search_screen.dart';
import 'package:qoo_quote/widgets/button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qoo_quote/services/graphql_service.dart';
import 'package:qoo_quote/widgets/friend_request_button.dart';
import 'package:qoo_quote/widgets/list_builders/user_posts.dart';

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

class UserPage extends StatefulWidget {
  final String userId;
  final String? username;
  final String? profilePictureUrl;
  const UserPage({
    super.key,
    required this.userId,
    this.username,
    this.profilePictureUrl,
  });

  @override
  State<UserPage> createState() => _UserpageState();
}

class _UserpageState extends State<UserPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  List<Map<String, dynamic>>? userData;
  bool isLoading = true;

  final List<UserItem> users = List.generate(
    10,
    (index) => UserItem(
      userid: "user_id_${index + 1}",
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
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      //final data = await GraphQLService.getUserComments(widget.userId);
      setState(() {
        // userData = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final user =
        userData != null && userData!.isNotEmpty ? userData![0]['user'] : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                leading: IconButton(
                  icon: const FaIcon(
                    FontAwesomeIcons.chevronLeft,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [
                  FriendRequestButton(userId: widget.userId),
                ],
                backgroundColor: AppColors.background,
                expandedHeight:
                    300, // TabBar'ın bittiği yerde kalması için düşürüldü
                floating: false,
                pinned: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 15.0),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.end, // Aşağıda hizalama
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: CachedNetworkImageProvider(
                            widget.profilePictureUrl ??
                                "https://picsum.photos/200",
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          widget.username ?? "USERNAME",
                          style: const TextStyle(
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
                            Tab(text: "PAYLAŞIMLAR"),
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
              BuildUserPosts(
                  userId: widget.userId,
                  username: widget.username,
                  profileImage: widget.profilePictureUrl),
              _buildUserList(users),
            ],
          ),
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
                        backgroundImage:
                            NetworkImage("https://picsum.photos/200"),
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
                        Image.network(
                          'https://picsum.photos/400',
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
