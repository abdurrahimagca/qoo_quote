import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qoo_quote/core/theme/colors.dart';
import 'package:qoo_quote/features/auth/components/select_username.dart';
import 'package:qoo_quote/screens/main_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qoo_quote/services/graphql_service.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:image_cropper/image_cropper.dart';

class UpdateUsername extends StatefulWidget {
  const UpdateUsername({super.key});

  @override
  State<UpdateUsername> createState() => _UpdateUsernameState();
}

class _UpdateUsernameState extends State<UpdateUsername> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  int? _age;
  String? _gender;
  String? _id;
  bool? _isPrivate;
  String? _name;
  String? _profilePictureUrl;
  String? _username;

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
  }

  Future<void> _updateUserSettings() async {
    // Kullanıcı adı boş kontrolü
    if (_username == null || _username!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kullanıcı adı gerekli')),
      );
      return;
    }

    // Kullanıcı adı uzunluk kontrolü
    if (_username!.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Kullanıcı adı en az 4 karakter olmalıdır')),
      );
      return;
    }

    // Kullanıcı adında boşluk kontrolü
    if (_username!.contains(' ')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kullanıcı adı boşluk içeremez')),
      );
      return;
    }

    try {
      const String mutation = r'''
        mutation UpdateUserSettings($username: String!) {
          deprecatedPatchUser(username: $username) {
            id
            username
          }
        }
      ''';

      final client = await GraphQLService.initializeClient();

      final MutationOptions options = MutationOptions(
        document: gql(mutation),
        variables: {
          'username': _username,
        },
      );

      final result = await client.value.mutate(options);

      if (result.hasException) {
        throw result.exception!;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kullanıcı adı başarıyla güncellendi')),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error updating user settings: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Güncelleme hatası: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.chevronLeft,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            const Text(
              'Yeni bir kullanıcı adı seçin',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            SelectUsername(
              onUsernameChanged: (String username) {
                setState(() {
                  _username = username;
                });
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateUserSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Kaydet',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
