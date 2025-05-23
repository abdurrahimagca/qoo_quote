import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qoo_quote/services/models/me_model.dart';
import 'package:qoo_quote/services/models/signed_url_response.dart';
import 'package:http/http.dart' as http;

class GraphQLService {
  static ValueNotifier<GraphQLClient>? _client;
  static const String BASE_IMAGE_URL =
      'https://qq-bucket.homelab-kaleici.space/';

  static Future<ValueNotifier<GraphQLClient>> initializeClient() async {
    if (_client != null) return _client!;

    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'refresh-token');
    final apiKey = dotenv.env['API_KEY'];

    final httpLink =
        HttpLink('https://qq-api-test-v0.homelab-kaleici.space/graphql');

    final authLink = Link.from([
      AuthLink(
        headerKey: 'Authorization',
        getToken: () async => 'Bearer $token',
      ),
      AuthLink(
        headerKey: 'qq-api-key',
        getToken: () async => apiKey,
      ),
    ]);

    final link = authLink.concat(httpLink);

    _client = ValueNotifier(
      GraphQLClient(
        cache: GraphQLCache(),
        link: link,
      ),
    );

    return _client!;
  }

  static Future<UserMe?> getMe() async {
    const String query = r'''
      query GetMe {
        me {
          id
          age
          gender
          isPrivate
          name
          profilePictureUrl
          username
        }
      }
    ''';

    try {
      final client =
          (_client?.value ?? await initializeClient().then((c) => c.value));

      final result = await client!.query(
        QueryOptions(
          document: gql(query),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw result.exception!;
      }

      if (result.data == null || result.data!['me'] == null) {
        return null;
      }

      final userData =
          UserMe.fromJson(result.data!['me'] as Map<String, dynamic>);

      // Debug konsola yazdırma

      return userData;
    } catch (e) {
      debugPrint('Error fetching me data: $e');
      return null;
    }
  }

  static Future<SignedUrlResponse?> getSignedImageUploadUrl() async {
    const String query = r'''
      query GetSignedImageUploadPutUrl {
        getSignedImageUploadPutUrl {
          url
          key
        }
      }
    ''';

    try {
      final client =
          (_client?.value ?? await initializeClient().then((c) => c.value));

      final result = await client!.query(
        QueryOptions(
          document: gql(query),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        debugPrint('Error getting signed URL: ${result.exception}');
        throw result.exception!;
      }

      if (result.data == null ||
          result.data!['getSignedImageUploadPutUrl'] == null) {
        return null;
      }

      return SignedUrlResponse.fromJson(
          result.data!['getSignedImageUploadPutUrl'] as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Error getting signed URL: $e');
      return null;
    }
  }

  static Future<String?> uploadImage(List<int> imageBytes) async {
    try {
      // 1. Signed URL al
      final signedUrlResponse = await getSignedImageUploadUrl();
      if (signedUrlResponse == null) {
        debugPrint('Signed URL alınamadı');
        return null;
      }

      // 2. Image'i PUT request ile yükle
      final response = await http.put(
        Uri.parse(signedUrlResponse.url),
        body: imageBytes,
        headers: {
          'Content-Type': 'image/jpeg',
        },
      );

      if (response.statusCode != 200) {
        debugPrint('Image yükleme hatası: ${response.statusCode}');
        return null;
      }

      // Use the key directly from the response
      final key = signedUrlResponse.key;

      // 4. Tam image URL'ini oluştur
      final fullImageUrl = BASE_IMAGE_URL + key;
      debugPrint('Image başarıyla yüklendi: $fullImageUrl');
      return fullImageUrl;
    } catch (e) {
      debugPrint('Image yükleme hatası: $e');
      return null;
    }
  }

  static Future<bool> updateProfilePhoto(List<int> imageBytes) async {
    try {
      // 1. Önce resmi yükle
      final uploadedImageUrl = await uploadImage(imageBytes);
      if (uploadedImageUrl == null) {
        debugPrint('Resim yüklenemedi');
        return false;
      }

      // 2. Mutation tanımla
      const String mutation = r'''
        mutation PatchUser($input: UpdateUserInput!) {
          patchUser(input: $input) {
            profilePictureUrl
            isPrivate
            id
            username
          }
        }
      ''';

      // 3. Mutation'ı çalıştır
      final client =
          (_client?.value ?? await initializeClient().then((c) => c.value));

      final result = await client!.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {
            'input': {
              'profilePictureUrl': uploadedImageUrl,
            },
          },
        ),
      );

      if (result.hasException) {
        debugPrint('Profil fotoğrafı güncelleme hatası: ${result.exception}');
        return false;
      }

      debugPrint('Profil fotoğrafı başarıyla güncellendi');
      return true;
    } catch (e) {
      debugPrint('Profil fotoğrafı güncelleme hatası: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> searchBooks(String query) async {
    const String searchQuery = r'''
      query SearchBooks($query: String!) {
        searchBooks(query: $query) {
          items {
            contributors {
              id
              name
            }
            imageUrls
            title
            postSourceIdentifier
            type
          }
        }
      }
    ''';

    try {
      final client =
          (_client?.value ?? await initializeClient().then((c) => c.value));

      final result = await client!.query(
        QueryOptions(
          document: gql(searchQuery),
          variables: {'query': query},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        debugPrint('Error searching books: ${result.exception}');
        throw result.exception!;
      }

      if (result.data == null || result.data!['searchBooks'] == null) {
        debugPrint('No books found');
        return null;
      }

      // Debug konsola yazdırma
      final searchResults =
          result.data!['searchBooks']['items'] as List<dynamic>;

      for (var book in searchResults) {
        if (book['contributors'] != null) {
          for (var contributor in book['contributors'] as List<dynamic>) {}
        }
        debugPrint('-------------------------');
      }

      return result.data!['searchBooks'] as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error in book search: $e');
      return null;
    }
  }

  static Future<bool> createPost({
    required List<int> imageBytes,
    required String postText,
    required String title,
    required String postType,
    required String contributorId,
    required String contributorName,
    required String postSourceIdentifier,
    List<Map<String, dynamic>>? contributors,
  }) async {
    try {
      // 1. Upload image and get URL
      final imageUrl = await uploadImage(imageBytes);
      if (imageUrl == null) {
        debugPrint('Image upload failed');
        return false;
      }

      // 2. Create post mutation
      const String mutation = r'''
        mutation CreatePost($input: CreatePostInput!) {
          createPost(input: $input) {
            id
            title
            postText
            imageUrl
            postType
            contributors {
              id
              name
            }
         
          }
        }
      ''';

      // 3. Execute mutation
      final client =
          (_client?.value ?? await initializeClient().then((c) => c.value));

      final result = await client!.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {
            'input': {
              'contributors': contributors ??
                  [
                    {
                      'name': contributorName,
                      'id': contributorId,
                      'description': null
                    }
                  ],
              'imageUrl': imageUrl,
              'postText': postText,
              'postType': postType,
              'title': title,
              'postSourceIdentifier': postSourceIdentifier,
              'metaData': []
            }
          },
        ),
      );

      if (result.hasException) {
        debugPrint('Post creation error: ${result.exception}');
        return false;
      }

      final postData = result.data?['createPost'];
      debugPrint('Post created successfully:');
      debugPrint('ID: ${postData['id']}');
      debugPrint('Title: ${postData['title']}');
      debugPrint('Text: ${postData['postText']}');
      debugPrint('Type: ${postData['postType']}');
      debugPrint('Image URL: ${postData['imageUrl']}');
      debugPrint('Contributors: ${postData['contributors']}');
      debugPrint('-------------------------');

      return true;
    } catch (e) {
      debugPrint('Error creating post: $e');
      return false;
    }
  }

  static Future<List<dynamic>?> findUsers(String searchText) async {
    const String query = r'''
      query FindUsersByNameOrUsername($name: String!) {
        findUsersByNameOrUsername(name: $name) {
          id
          username
          name
          profilePictureUrl
          isPrivate
        }
      }
    ''';

    try {
      final client =
          (_client?.value ?? await initializeClient().then((c) => c.value));

      final result = await client!.query(
        QueryOptions(
          document: gql(query),
          variables: {'name': searchText},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        debugPrint('Error searching users: ${result.exception}');
        throw result.exception!;
      }

      if (result.data == null ||
          result.data!['findUsersByNameOrUsername'] == null) {
        debugPrint('No users found');
        return null;
      }

      final users = result.data!['findUsersByNameOrUsername'] as List<dynamic>;

      // Debug konsola yazdırma
      debugPrint('Found Users:');
      debugPrint('-------------------------');
      for (var user in users) {
        debugPrint('ID: ${user['id']}');
        debugPrint('Username: ${user['username']}');
        debugPrint('Name: ${user['name']}');
        debugPrint('Profile Picture: ${user['profilePictureUrl']}');
        debugPrint('Is Private: ${user['isPrivate']}');
        debugPrint('-------------------------');
      }

      return users;
    } catch (e) {
      debugPrint('Error searching users: $e');
      return null;
    }
  }

  static Future<List<dynamic>?> profilePosts() async {
    try {
      // Önce kullanıcı bilgilerini al
      final userData = await getMe();
      if (userData == null) {
        debugPrint('User data not found');
        return null;
      }

      const String query = r'''
        query Author {
          userPosts {
            author {
              username
              profilePictureUrl
            }
            postText
            title
            updatedAt
            postType
            imageUrl
            id
            createdAt
            contributors {
              name
              id
            }
          }
        }
      ''';

      final client =
          (_client?.value ?? await initializeClient().then((c) => c.value));

      final result = await client!.query(
        QueryOptions(
          document: gql(query),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        debugPrint('Error fetching user posts: ${result.exception}');
        throw result.exception!;
      }

      if (result.data == null || result.data!['userPosts'] == null) {
        debugPrint('No posts found');
        return null;
      }
      debugPrint('User ID: ${userData.id}');
      debugPrint('User Posts:');
      debugPrint('-------------------------');
      for (var post in result.data!['userPosts'] as List<dynamic>) {
        debugPrint('Post ID: ${post['id']}');
        debugPrint('Post Text: ${post['postText']}');
        debugPrint('Title: ${post['title']}');
        debugPrint('Updated At: ${post['updatedAt']}');
        debugPrint('Post Type: ${post['postType']}');
        debugPrint('Image URL: ${post['imageUrl']}');
        debugPrint('Contributors: ${post['contributors']}');
        debugPrint('-------------------------');
      }

      final posts = result.data!['userPosts'] as List<dynamic>;

      return posts;
    } catch (e) {
      debugPrint('Error fetching user posts: $e');
      return null;
    }
  }

  static Future<bool> deletePost(String postId) async {
    try {
      const String mutation = r'''
        mutation DeletePost($deletePostId: String!) {
          deletePost(id: $deletePostId)
        }
      ''';

      final client =
          (_client?.value ?? await initializeClient().then((c) => c.value));

      final result = await client!.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {
            'deletePostId': postId,
          },
        ),
      );

      if (result.hasException) {
        debugPrint('Post deletion error: ${result.exception}');
        return false;
      }

      debugPrint('Post deleted successfully');
      return result.data?['deletePost'] ?? false;
    } catch (e) {
      debugPrint('Error deleting post: $e');
      return false;
    }
  }

  static Future<int> getLikesCount(String postId) async {
    const String query = r'''
      query GetPostLikes($postId: String!) {
        getLikesCount(postId: $postId)
      }
    ''';

    try {
      final client =
          (_client?.value ?? await initializeClient().then((c) => c.value));

      final result = await client!.query(
        QueryOptions(
          document: gql(query),
          variables: {'postId': postId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        debugPrint('Error fetching likes count: ${result.exception}');
        throw result.exception!;
      }

      return result.data?['getLikesCount'] as int? ?? 0;
    } catch (e) {
      debugPrint('Error getting likes count: $e');
      return 0;
    }
  }

  static Future<List<dynamic>?> getLastPosts(
      {int skip = 0, int take = 10}) async {
    const String query = r'''
      query Posts($skip: Int, $take: Int) {
        posts(skip: $skip, take: $take) {
          author {
            profilePictureUrl
            username
            id
            isPrivate
          }
          id
          imageUrl
          isFriendsOnly
          postSourceIdentifier
          postType
          title
          updatedAt
          postText
        }
      }
    ''';

    try {
      final client =
          (_client?.value ?? await initializeClient().then((c) => c.value));

      final result = await client!.query(
        QueryOptions(
          document: gql(query),
          variables: {
            'skip': skip,
            'take': take,
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        debugPrint('Error fetching posts: ${result.exception}');
        throw result.exception!;
      }

      if (result.data == null || result.data!['posts'] == null) {
        debugPrint('No posts found');
        return null;
      }

      final posts = result.data!['posts'] as List<dynamic>;

      // Debug output for monitoring
      debugPrint('Fetched ${posts.length} posts');
      debugPrint('-------------------------');

      return posts;
    } catch (e) {
      debugPrint('Error fetching posts: $e');
      return null;
    }
  }

  // Add this new method to the GraphQLService class
  static Future<bool> createLike(String postId) async {
    const String mutation = r'''
      mutation CreateLike($postId: String!) {
        createLike(postId: $postId) {
          message
          success
        }
      }
    ''';

    try {
      final client =
          (_client?.value ?? await initializeClient().then((c) => c.value));

      final result = await client!.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {
            'postId': postId,
          },
        ),
      );

      if (result.hasException) {
        debugPrint('Like creation error: ${result.exception}');
        return false;
      }

      final success = result.data?['createLike']['success'] as bool? ?? false;
      debugPrint(
          'Like creation message: ${result.data?['createLike']['message']}');

      return success;
    } catch (e) {
      debugPrint('Error creating like: $e');
      return false;
    }
  }

  static Future<bool> removeLike(String postId) async {
    const String mutation = r'''
      mutation RemoveLike($postId: String!) {
        removeLike(postId: $postId) {
          message
          success
        }
      }
    ''';

    try {
      final client =
          (_client?.value ?? await initializeClient().then((c) => c.value));

      final result = await client!.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {
            'postId': postId,
          },
        ),
      );

      if (result.hasException) {
        debugPrint('Like removal error: ${result.exception}');
        return false;
      }

      final success = result.data?['removeLike']['success'] as bool? ?? false;
      debugPrint(
          'Like removal message: ${result.data?['removeLike']['message']}');

      return success;
    } catch (e) {
      debugPrint('Error removing like: $e');
      return false;
    }
  }
}
