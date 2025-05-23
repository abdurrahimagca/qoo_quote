import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qoo_quote/core/theme/colors.dart';
import 'package:qoo_quote/screens/user_screen.dart';
import 'package:qoo_quote/services/graphql_service.dart';

class SearchPage extends StatefulWidget {
  final String initialQuery;

  const SearchPage({
    super.key,
    required this.initialQuery,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
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

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late TabController _tabController;

  List<UserItem> users = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.text = widget.initialQuery;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
      if (widget.initialQuery.isNotEmpty) {
        _searchUsers(widget.initialQuery);
      }
    });

    // Add listener to search controller
    _searchController.addListener(() {
      final query = _searchController.text;
      if (query.isNotEmpty) {
        _searchUsers(query);
      } else {
        setState(() {
          users = [];
        });
      }
    });
  }

  Future<void> _searchUsers(String query) async {
    setState(() {
      isLoading = true;
    });

    try {
      final results = await GraphQLService.findUsers(query);
      if (results != null) {
        setState(() {
          users = results
              .map((user) => UserItem(
                    username: user['username'] as String,
                    profileImage: user['profilePictureUrl'] as String? ??
                        'https://picsum.photos/200',
                  ))
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error searching users: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Widget _buildUserList(List<UserItem> users) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 0),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return InkWell(
          onTap: () {
            // Navigate to user profile
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserPage(),
                ));
          },
          child: Container(
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
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
              _searchFocusNode.unfocus();
              _searchController.clear();
            },
            icon: FaIcon(FontAwesomeIcons.chevronLeft, color: Colors.white)),
        title: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'keyword',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide:
                  BorderSide(color: AppColors.secondary.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: AppColors.secondary),
            ),
            prefixIcon:
                Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
            filled: true,
            fillColor: Colors.grey[900],
          ),
        ),
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar

            // TabBar
            TabBar(
              controller: _tabController,
              indicatorColor: AppColors.secondary,
              labelColor: AppColors.secondary,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: "USERS"),
                Tab(text: "POSTS"),
              ],
            ),

            // TabBarView
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.secondary,
                          ),
                        )
                      : _buildUserList(users),
                  // Posts Tab
                  const Center(
                    child: Text(
                      'POSTS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
