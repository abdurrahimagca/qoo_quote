import 'package:flutter/material.dart';
import 'package:qoo_quote/core/theme/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

// ignore this file best thing u can do is start from scratch
// what we expect ? :
/*export const CreatePostSchema = z.object({
  image: z.string().min(1).refine(validateBase64Image, {
    message:
      'Invalid image. Must be a base64 encoded JPEG, PNG, or WebP under 10MB',
  }),
  title: z.string().min(1),
  description: z.string().optional(),
  postText: z.string(),
  textInformation: TextInformationSchema.optional(),
  backgroundInformation: BackgroundInformationSchema.optional(),
  authorId: z.string().uuid(),
  isFriendsOnly: z.boolean().optional(),
  metaData: z.array(MetaDataSchema).optional().default([]),
});*/
// this is a very bad practice and should be avoided

class Book {
  final String title;
  final String author;
  //no!
  final String imageUrl;

  Book({required this.title, required this.author, required this.imageUrl});
}

class Createpage extends StatefulWidget {
  const Createpage({super.key});

  @override
  State<Createpage> createState() => _CreatepageState();
}

class _CreatepageState extends State<Createpage> {
  List<Book> searchResults = [];
  bool isLoading = false;
  //we do not have ANY KIND OF BOOK LIMIT ON POSTS NEVER
  //ONLY THING WE HAVE IS A MASSIVE AMOUNT OF TYPE ENUMS

  Book? selectedBook;
  File? selectedImage;
  final TextEditingController quoteController = TextEditingController();
  double fontSize = 40.0; // Varsayılan yazı boyutu
  double opacity = 0.3; // Karartma opaklığı için yeni değişken

  Future<void> searchBooks(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          'https://www.googleapis.com/books/v1/volumes?q=$query&langRestrict=tr'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List<dynamic>;

        setState(() {
          searchResults = items.map((item) {
            final volumeInfo = item['volumeInfo'];
            //we would never took this information only if user gives
            //this information to us
            //we do not have any kind of book limit on posts
            return Book(
              title: volumeInfo['title'] ?? 'Başlık Bulunamadı',
              author: (volumeInfo['authors'] as List<dynamic>?)?.first ??
                  'Yazar Bilinmiyor',
              imageUrl: volumeInfo['imageLinks']?['thumbnail'] ?? '',
            );
          }).toList();
        });
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _pickAndCropImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        //u would never want to compress exact same image
        
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            //never use Turkish if u want to support many languages
            //pls use i18n provider
            toolbarTitle: 'Fotoğrafı Kırp',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Fotoğrafı Kırp',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          selectedImage = File(croppedFile.path);
        });
      }
    }
  }

  Future<void> _saveImageWithQuote() async {
    if (selectedImage == null || quoteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen fotoğraf ve alıntı ekleyin')),
      );
      return;
    }

    // İzin kontrolü
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Galeriye kaydetmek için izin gerekiyor')),
      );
      return;
    }

    try {
      // Fotoğrafı yükle
      final ui.Image image =
          await decodeImageFromList(selectedImage!.readAsBytesSync());

      // Canvas oluştur
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final size = Size(image.width.toDouble(), image.height.toDouble());

      // Fotoğrafı çiz
      canvas.drawImage(image, Offset.zero, Paint());

      // Karartma katmanı ekle
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = Colors.black.withOpacity(opacity),
      );

      // Metni hazırla
      final textPainter = TextPainter(
        text: TextSpan(
          text: quoteController.text,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      // Metin boyutunu hesapla ve ortala
      textPainter.layout(maxWidth: size.width * 0.8);
      final textPos = Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      );

      // Metni çiz
      textPainter.paint(canvas, textPos);

      // Son görüntüyü oluştur
      final picture = recorder.endRecording();
      final img = await picture.toImage(image.width, image.height);
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      // Galeriye kaydet
      final result = await ImageGallerySaver.saveImage(
        buffer,
        quality: 100,
        name: "quote_${DateTime.now().millisecondsSinceEpoch}",
      );

      if (result['isSuccess']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fotoğraf galeriye kaydedildi')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bir hata oluştu')),
      );
      print(e);
    }
  }

  Future<void> _showPreview() async {
    if (selectedImage == null || quoteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen fotoğraf ve alıntı ekleyin')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Önizleme Resmi
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    selectedImage!,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(opacity),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        quoteController.text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Ayarlar Bölümü
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.black54,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Yazı Boyutu',
                    style: TextStyle(color: Colors.white),
                  ),
                  Slider(
                    value: fontSize,
                    min: 20,
                    max: 60,
                    divisions: 40,
                    label: fontSize.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        fontSize = value;
                      });
                    },
                  ),
                  const Text(
                    'Karartma',
                    style: TextStyle(color: Colors.white),
                  ),
                  Slider(
                    value: opacity,
                    min: 0.0,
                    max: 0.8,
                    divisions: 16,
                    label: (opacity * 100).round().toString() + '%',
                    onChanged: (value) {
                      setState(() {
                        opacity = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Butonlar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Düzenle',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _saveImageWithQuote();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('Kaydet'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    quoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 16),

            // Fotoğraf Ekleme
            GestureDetector(
              onTap: _pickAndCropImage,
              child: Container(
                height: MediaQuery.of(context).size.width - 32,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(16),
                  image: selectedImage != null
                      ? DecorationImage(
                          image: FileImage(selectedImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: selectedImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.add_a_photo,
                            size: 50,
                            color: Colors.white38,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Fotoğraf Seç',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),

            // Açıklama Alanı
            TextField(
              controller: quoteController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Alıntı yaz...",
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Paylaş Butonu
            ElevatedButton(
              onPressed: _showPreview,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text("Kaydet"),
            ),
          ],
        ),
      ),
    );
  }
}
