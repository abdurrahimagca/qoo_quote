import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GraphQLService {
  static ValueNotifier<GraphQLClient>? _client;

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
      debugPrint('User Data:');
      debugPrint('ID: ${userData.id}');
      debugPrint('Username: ${userData.username}');
      debugPrint('Name: ${userData.name}');
      debugPrint('Age: ${userData.age}');
      debugPrint('Gender: ${userData.gender}');
      debugPrint('Is Private: ${userData.isPrivate}');
      debugPrint('Profile Picture URL: ${userData.profilePictureUrl}');
      debugPrint('------------------------');

      return userData;
    } catch (e) {
      debugPrint('Error fetching me data: $e');
      return null;
    }
  }
}

class UserMe {
  final String id;
  final int? age;
  final String? gender;
  final bool isPrivate;
  final String? name;
  final String? profilePictureUrl;
  final String username;

  UserMe({
    required this.id,
    this.age,
    this.gender,
    required this.isPrivate,
    this.name,
    this.profilePictureUrl,
    required this.username,
  });

  factory UserMe.fromJson(Map<String, dynamic> json) {
    return UserMe(
      id: json['id'] as String,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      isPrivate: json['isPrivate'] as bool,
      name: json['name'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      username: json['username'] as String,
    );
  }
}
