import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qoo_quote/core/theme/colors.dart';
import 'package:qoo_quote/features/auth/components/select_username.dart';
import 'package:qoo_quote/screens/main_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qoo_quote/services/graphql_service.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:image_cropper/image_cropper.dart';

class UpdatePhoto extends StatefulWidget {
  const UpdatePhoto({super.key});

  @override
  State<UpdatePhoto> createState() => _UpdatePhotoState();
}

class _UpdatePhotoState extends State<UpdatePhoto> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  int? _age;
  String? _gender;
  String? _id;
  bool? _isPrivate;
  String? _name;
  String? _profilePictureUrl;
  String? _username;

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Kırpma işlemi için CroppedFile döndürür
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), // 1:1 oran
        // Dairesel kırpma özelliği kaldırıldı
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Fotoğrafı Düzenle',
            toolbarColor: AppColors.background,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: 'Fotoğrafı Düzenle',
            aspectRatioLockEnabled: true,
            minimumAspectRatio: 1.0,
            aspectRatioPickerButtonHidden: true,
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _imageFile = File(croppedFile.path);
        });
      }
    }
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
  }

  Future<void> _updateUserSettings() async {
    if (_imageFile == null || _username == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Profil fotoğrafı ve kullanıcı adı gerekli')),
      );
      return;
    }

    try {
      // Fotoğrafı base64'e çevir ve format prefix'i ekle
      final bytes = await _imageFile!.readAsBytes();
      final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';

      const String mutation = r'''
        mutation UpdateUserSettings($name: String, $age: Float, $gender: String, $isPrivate: Boolean, $username: String, $deprecatedPofilePicture: String) {
          deprecatedPatchUser(name: $name, age: $age, gender: $gender, isPrivate: $isPrivate, username: $username, deprecatedPofilePicture: $deprecatedPofilePicture) {
            age
            gender
            id
            isPrivate
            name
            profilePictureUrl
            username
          }
        }
      ''';

      final client = await GraphQLService.initializeClient();

      final MutationOptions options = MutationOptions(
        document: gql(mutation),
        variables: {
          'name': _name,
          'age': _age?.toDouble(),
          'gender': _gender,
          'isPrivate': _isPrivate ?? false,
          'username': _username,
          'deprecatedPofilePicture': base64Image, // Değişen parametre adı
        },
      );

      final result = await client.value.mutate(options);

      if (result.hasException) {
        throw result.exception!;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil başarıyla güncellendi')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage()),
      );
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
        title: const Text(
          'Hesap Oluştur',
          style: TextStyle(color: Colors.white),
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
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                      image: _imageFile != null
                          ? DecorationImage(
                              image: FileImage(_imageFile!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _imageFile == null
                        ? const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey,
                          )
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Profil Fotoğrafı Seç',
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
                  'Kaydet ve devam et',
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
