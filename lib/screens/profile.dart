import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:qoo_quote/core/theme/colors.dart';
import 'package:qoo_quote/screens/search_screen.dart';
import 'package:qoo_quote/services/graphql_service.dart';
import 'package:qoo_quote/widgets/list_builders/profile_posts.dart';

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

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _UserpageState();
}

class _UserpageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  bool _isready = false;
  bool _refreshPosts = false;

  // Me değişkenleri
  int? _age;
  String? _gender;
  String? _id;
  bool? _isPrivate;
  String? _name;
  String? _profilePictureUrl;
  String? _username;

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

    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final me = await GraphQLService.getMe();
    if (me != null) {
      setState(() {
        _age = me.age;
        _gender = me.gender;
        _id = me.id;
        _isPrivate = me.isPrivate;
        _name = me.name;
        _profilePictureUrl = me.profilePictureUrl;
        _username = me.username;

        // Veriler yüklendiğinde durumu güncelle
      });
    }
    _isready = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.background,
        body: _isready
            ? DefaultTabController(
                length: 3,
                child: NestedScrollView(
                  controller: _scrollController,
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    return [
                      SliverAppBar(
                        backgroundColor: AppColors.background,
                        expandedHeight:
                            250, // TabBar'ın bittiği yerde kalması için düşürüldü
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
                                  radius: 60, // Biraz küçültüldü
                                  backgroundImage: CachedNetworkImageProvider(
                                    _profilePictureUrl ??
                                        "https://picsum.photos/200",
                                  ),
                                ),
                                const SizedBox(height: 20), // Azaltıldı
                                Text(
                                  _username ?? "USERNAME",
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
                                  labelColor:
                                      AppColors.primary, // Seçili tab rengi

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
                      BuildProfilePosts(),
                      _buildUserList(users),
                    ],
                  ),
                ),
              )
            : Center(child: CircularProgressIndicator()));
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
}
