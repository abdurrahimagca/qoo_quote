import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class DeepLinkHandler {
  static const platform = MethodChannel('app/deep_links');
  
  static Future<void> handleInitialLink(BuildContext context) async {
    try {
      final initialLink = await platform.invokeMethod<String>('getInitialLink');
      if (initialLink != null) {
        _handleLink(context, initialLink);
      }
    } on PlatformException catch (e) {
      print('Failed to get initial link: ${e.message}');
    }
  }

  static void _handleLink(BuildContext context, String link) {
    // Handle your deep link here
    print('Received deep link: $link');
    // Add your navigation logic based on the link
  }

  static void initDeepLinkListener(BuildContext context) {
    platform.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onDeepLink') {
        final String link = call.arguments as String;
        _handleLink(context, link);
      }
    });
  }
} 