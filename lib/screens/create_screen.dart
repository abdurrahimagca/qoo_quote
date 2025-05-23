import 'package:flutter/material.dart';
import 'package:qoo_quote/core/theme/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';

import 'package:qoo_quote/services/graphql_service.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _TestPageState();
}

class _TestPageState extends State<CreateScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _postTextController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  File? _selectedImage;
  List<Map<String, dynamic>> _searchResults = [];
  Map<String, dynamic>? _selectedBook;
  bool _isLoading = false;

  Future<void> _searchBooks(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await GraphQLService.searchBooks(query);
      if (results != null) {
        setState(() {
          _searchResults = (results['items'] as List<dynamic>)
              .map((item) => item as Map<String, dynamic>)
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error searching books: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Fotoğrafı Düzenle',
          toolbarColor: AppColors.background,
          toolbarWidgetColor: Colors.white,
          backgroundColor: AppColors.background,
          activeControlsWidgetColor: AppColors.primary,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Fotoğrafı Düzenle',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        _selectedImage = File(croppedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Kitap ara...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : null,
              ),
              onChanged: (value) {
                if (value.length >= 3) {
                  _searchBooks(value);
                } else {
                  setState(() {
                    _searchResults = [];
                  });
                }
              },
            ),

            // Selected Book
            if (_selectedBook != null)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary, width: 1),
                ),
                child: Row(
                  children: [
                    if (_selectedBook!['imageUrls']?.isNotEmpty ?? false)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _selectedBook!['imageUrls'][0],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedBook!['title'] ?? 'Bilinmeyen Kitap',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_selectedBook!['contributors']?.isNotEmpty ??
                              false)
                            Text(
                              _selectedBook!['contributors'][0]['name'] ?? '',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          _selectedBook = null;
                        });
                      },
                    ),
                  ],
                ),
              ),

            // Search Results
            if (_searchResults.isNotEmpty && _selectedBook == null)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final book = _searchResults[index];
                    return ListTile(
                      leading: book['imageUrls']?.isNotEmpty ?? false
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                book['imageUrls'][0],
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.book, color: Colors.grey),
                      title: Text(
                        book['title'] ?? 'Bilinmeyen Kitap',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: book['contributors']?.isNotEmpty ?? false
                          ? Text(
                              book['contributors'][0]['name'] ?? '',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            )
                          : null,
                      onTap: () {
                        final authorName =
                            book['contributors']?[0]?['name'] ?? '';
                        final bookTitle = book['title'] ?? '';
                        final titleText = '$authorName / $bookTitle';

                        setState(() {
                          _selectedBook = book;
                          _searchResults = [];
                          _searchController.clear();
                          _titleController.text =
                              titleText; // Otomatik olarak title field'ını doldur
                        });
                      },
                    );
                  },
                ),
              ),

            const SizedBox(height: 20),

            // Image Selection Area
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 50,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Fotoğraf Yükle',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Post Text Field
            TextField(
              controller: _postTextController,
              style: const TextStyle(color: Colors.white),
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Gönderi metni...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title Field
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Açıklama...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Share Button
            ElevatedButton(
              onPressed: () async {
                if (_selectedImage == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lütfen bir fotoğraf seçin')),
                  );
                  return;
                }

                if (_postTextController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lütfen gönderi metni girin')),
                  );
                  return;
                }

                if (_titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lütfen bir açıklama girin')),
                  );
                  return;
                }

                try {
                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  if (_selectedBook == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Lütfen bir kitap seçin')),
                    );
                    return;
                  }

                  final contributors = [
                    {
                      'id': _selectedBook!['contributors']?[0]?['id'] ?? '',
                      'name': _selectedBook!['contributors']?[0]?['name'] ?? '',
                      'description': null
                    }
                  ];

                  final success = await GraphQLService.createPost(
                      imageBytes: await _selectedImage!.readAsBytes(),
                      postText: _postTextController.text,
                      title: _titleController.text,
                      postType: _selectedBook!['type'] ?? '',
                      contributorId:
                          _selectedBook!['contributors']?[0]?['id'] ?? '',
                      contributorName:
                          _selectedBook!['contributors']?[0]?['name'] ?? '',
                      postSourceIdentifier:
                          _selectedBook!['postSourceIdentifier'] ?? '',
                      contributors: contributors);

                  // Hide loading indicator
                  Navigator.of(context).pop();

                  if (success) {
                    // Clear form and show success message
                    setState(() {
                      _searchController.clear();
                      _postTextController.clear();
                      _titleController.clear();
                      _selectedImage = null;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Gönderi başarıyla oluşturuldu')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Gönderi oluşturulurken bir hata oluştu')),
                    );
                  }
                } catch (e) {
                  // Hide loading indicator if visible
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Hata: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Paylaş',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _postTextController.dispose();
    _titleController.dispose();
    super.dispose();
  }
}
