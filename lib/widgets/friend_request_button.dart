import 'package:flutter/material.dart';
import 'package:qoo_quote/core/theme/colors.dart';
import 'package:qoo_quote/services/friendship_service.dart';

class FriendRequestButton extends StatefulWidget {
  final String userId;
  final bool isRequested;
  final Function(bool)? onRequestStatusChanged;

  const FriendRequestButton({
    super.key,
    required this.userId,
    this.isRequested = false,
    this.onRequestStatusChanged,
  });

  @override
  State<FriendRequestButton> createState() => _FriendRequestButtonState();
}

class _FriendRequestButtonState extends State<FriendRequestButton> {
  late bool _isRequested;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isRequested = widget.isRequested;
    _checkExistingRequest();
  }

  Future<void> _checkExistingRequest() async {
    try {
      final sentRequests = await FriendshipService.getSentFriendRequests();
      if (sentRequests != null) {
        final hasExistingRequest = sentRequests
            .any((request) => request['addressee']['id'] == widget.userId);

        if (hasExistingRequest && mounted) {
          setState(() {
            _isRequested = true;
          });
          widget.onRequestStatusChanged?.call(true);
        }
      }
    } catch (e) {
      debugPrint('Error checking existing friend request: $e');
    }
  }

  Future<void> _handleFriendRequest() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await FriendshipService.sendFriendRequest(widget.userId);
      if (success) {
        setState(() {
          _isRequested = true;
        });
        widget.onRequestStatusChanged?.call(true);
      }
    } catch (e) {
      debugPrint('Error sending friend request: $e');
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Arkadaşlık isteği gönderilirken bir hata oluştu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: _isRequested ? null : _handleFriendRequest,
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: _isRequested ? Colors.grey : AppColors.secondary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
              ),
            )
          : Text(
              _isRequested ? 'İstek Gönderildi' : 'Arkadaş Ekle',
              style: TextStyle(
                color: _isRequested ? Colors.grey : AppColors.secondary,
              ),
            ),
    );
  }
}
