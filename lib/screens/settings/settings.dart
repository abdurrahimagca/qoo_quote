import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qoo_quote/core/theme/colors.dart';
import 'package:qoo_quote/screens/login.dart';
import 'package:qoo_quote/screens/patch_user_page.dart';
import 'package:qoo_quote/screens/settings/test.dart';
import 'package:qoo_quote/screens/settings/username_update.dart';
import 'package:qoo_quote/services/graphql_service.dart';
import 'package:qoo_quote/services/rest_services/auth_service.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _navigateToUpdateProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PatchUserPage()),
    );
  }

  void _handleLogout() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Çıkış Yap',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text('Çıkış yapmak istediğinize emin misiniz?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await AuthService.logout(context);
            },
            child: Text('Çıkış Yap', style: TextStyle(color: Colors.red[300])),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProfilePhoto() async {
    final ImagePicker picker = ImagePicker();

    // Galeriden fotoğraf seç
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    // Fotoğrafı kırp
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Profil Fotoğrafını Düzenle',
          toolbarColor: AppColors.background,
          toolbarWidgetColor: Colors.white,
          backgroundColor: AppColors.background,
          activeControlsWidgetColor: AppColors.primary,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Profil Fotoğrafını Düzenle',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );

    if (croppedFile == null) return;

    // Kırpılmış fotoğrafı yükle
    await GraphQLService.updateProfilePhoto(await croppedFile.readAsBytes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.chevronLeft,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: AppColors.background,
        title: const Text(
          'Ayarlar',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSettingItem(
              icon: Icons.photo_camera,
              title: 'Profil Fotoğrafı Güncelle',
              onTap: _updateProfilePhoto,
            ),
            _buildSettingItem(
              icon: Icons.text_fields,
              title: 'Kullanıcı Adı Güncelle',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateUsername(),
                  ),
                );
              },
            ),
            _buildSettingItem(
              icon: Icons.error,
              title: 'Test Sayfasına git',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TestPage(),
                  ),
                );
              },
              isDestructive: true,
            ),
            const SizedBox(height: 16),
            _buildSettingItem(
              icon: Icons.logout,
              title: 'Çıkış Yap',
              onTap: _handleLogout,
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : AppColors.primary,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : Colors.white,
            fontSize: 16,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.grey,
        ),
      ),
    );
  }
}
