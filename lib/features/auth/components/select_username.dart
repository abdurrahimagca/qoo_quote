import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:qoo_quote/core/theme/colors.dart';
import 'package:qoo_quote/services/gql/user_service.dart';

class SelectUsername extends StatefulWidget {
  final Function(String) onUsernameChanged;

  SelectUsername({
    Key? key,
    required this.onUsernameChanged,
  }) : super(key: key);

  final _logger = Logger();
  @override
  State<SelectUsername> createState() => _SelectUsernameState();
}

class _SelectUsernameState extends State<SelectUsername> {
  final _controller = TextEditingController();
  final _logger = Logger();
  Timer? _debounce;
  bool? _isAvailable;

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      final text = _controller.text.trim();
      widget.onUsernameChanged(text);

      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () async {
        if (text.isNotEmpty) {
          try {
            final result = await UserService().checkUserNameAvailability(text);
            _logger.d("Username availability check: $text -> $result");

            setState(() => _isAvailable = result);
          } catch (e) {
            setState(() => _isAvailable = null); // error case
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 50,
          child: TextField(
            controller: _controller,
            style: const TextStyle(
                color: Colors.white), // Metin rengi beyaz olacak
            decoration: InputDecoration(
              hintText: ' Kullanıcı adı',
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
              filled: true,
              fillColor: Colors.grey[900],
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (_isAvailable != null)
          Text(
            _isAvailable! ? '✅ Username available' : '❌ Username taken',
            style: TextStyle(
              color: _isAvailable! ? Colors.green : Colors.red,
              fontSize: 14,
            ),
          ),
      ],
    );
  }
}
