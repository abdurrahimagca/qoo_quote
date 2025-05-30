import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qoo_quote/services/friendship_service.dart';
import 'package:qoo_quote/core/theme/colors.dart';

class FriendReq extends StatefulWidget {
  const FriendReq({super.key});

  @override
  State<FriendReq> createState() => _FriendReqState();
}

class _FriendReqState extends State<FriendReq> {
  List<dynamic>? _friendRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFriendRequests();
  }

  Future<void> _fetchFriendRequests() async {
    try {
      final requests = await FriendshipService.getPendingFriendRequests();
      if (mounted) {
        setState(() {
          _friendRequests = requests;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching friend requests: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.chevronLeft, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: AppColors.background,
        title: const Text(
          'Arkadaşlık İstekleri',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildRequestsList(),
    );
  }

  Widget _buildRequestsList() {
    if (_friendRequests == null || _friendRequests!.isEmpty) {
      return const Center(
        child: Text(
          'Bekleyen arkadaşlık isteği yok',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: _friendRequests!.length,
      itemBuilder: (context, index) {
        final request = _friendRequests![index];
        final requester = request['addressee'];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(
                requester['profilePictureUrl'] ?? 'https://picsum.photos/200',
              ),
            ),
            title: Text(
              requester['username'] ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () async {
                    await FriendshipService.acceptFriendRequest(request['id']);
                    _fetchFriendRequests();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () async {
                    await FriendshipService.rejectFriendRequest(request['id']);
                    _fetchFriendRequests();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
