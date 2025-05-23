import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qoo_quote/services/graphql_service.dart';

class LikeButton extends StatefulWidget {
  final String postId;
  const LikeButton({
    super.key,
    required this.postId,
  });

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  bool _isLiked = false;
  int _likeCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchLikeCount();
  }

  Future<void> _fetchLikeCount() async {
    final count = await GraphQLService.getLikesCount(widget.postId);
    setState(() {
      _likeCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          _likeCount.toString(),
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        _isLiked
            ? IconButton(
                onPressed: () {
                  setState(() {
                    GraphQLService.removeLike(widget.postId);
                    _isLiked = false;
                    _likeCount--;
                  });
                },
                icon: FaIcon(
                  FontAwesomeIcons.solidHeart,
                  color: Colors.red.withOpacity(0.9),
                  size: 25,
                ),
              )
            : IconButton(
                onPressed: () {
                  setState(() {
                    GraphQLService.createLike(widget.postId);
                    _isLiked = true;
                    _likeCount++;
                  });
                },
                icon: FaIcon(
                  FontAwesomeIcons.heart,
                  color: Colors.white.withOpacity(0.9),
                  size: 25,
                ),
              ),
      ],
    );
  }
}
