import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/foundation.dart';

class FriendshipService {
  static GraphQLClient? _client;
  static const String _apiKey =
      'OBDvpIP4aayVRqlAuO4rC6BV6Pv693mOGtFtsTUYVwzx7apfMYx/2CWMn+tE66c42kjDOiAKRHL+8zP7bnvIk/HekE906SACLjZ/gRDJgd7hz/ESM+CbwWDFhFtaaAmTpuu9IyflPssj0kAgxVnrnvR1jsCYUEI3p3qk3Wt+ds8';

  static Future<List<dynamic>?> getFriends() async {
    const String query = r'''
      query Addressee {
        getFriends {
          addressee {
            age
            gender
            id
            username
            profilePictureUrl
          }
        }
      }
    ''';

    debugPrint('Fetching friends list...');

    try {
      // Token'ı secure storage'dan al
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'refresh-token');

      // API endpointi için HttpLink oluştur
      final httpLink =
          HttpLink('https://qq-api-test-v0.homelab-kaleici.space/graphql');

      // Auth headers oluştur
      final authLink = Link.from([
        AuthLink(
          headerKey: 'Authorization',
          getToken: () async => 'Bearer $token',
        ),
        AuthLink(
          headerKey: 'qq-api-key',
          getToken: () async => _apiKey,
        ),
      ]);

      // Link'leri birleştir
      final link = authLink.concat(httpLink);

      // GraphQL client oluştur
      _client = GraphQLClient(
        cache: GraphQLCache(),
        link: link,
      );

      final result = await _client!.query(
        QueryOptions(
          document: gql(query),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        debugPrint('Error fetching friends:');
        debugPrint('Exception type: ${exception.runtimeType}');
        debugPrint('Error message: ${exception.toString()}');

        if (exception.linkException != null) {
          debugPrint('Network error: ${exception.linkException}');
        }

        if (exception.graphqlErrors.isNotEmpty) {
          debugPrint('GraphQL Errors:');
          for (var error in exception.graphqlErrors) {
            debugPrint('- Message: ${error.message}');
            debugPrint('- Location: ${error.locations}');
            debugPrint('- Path: ${error.path}');
          }
        }
        return null;
      }

      if (result.data == null || result.data!['getFriends'] == null) {
        debugPrint('No friends data found in response');
        return null;
      }

      final friends = result.data!['getFriends'] as List<dynamic>;
      debugPrint('Successfully fetched ${friends.length} friends');

      return friends;
    } catch (e, stackTrace) {
      debugPrint('Unexpected error in getFriends:');
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      return null;
    }
  }

  static Future<List<dynamic>?> getPendingFriendRequests() async {
    const String query = r'''
      query Addressee {
        getPendingFriendRequests {
          id
          addressee {
            profilePictureUrl
            username
            id
          }
        }
      }
    ''';

    debugPrint('Fetching pending friend requests...');

    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'refresh-token');

      final httpLink =
          HttpLink('https://qq-api-test-v0.homelab-kaleici.space/graphql');

      final authLink = Link.from([
        AuthLink(
          headerKey: 'Authorization',
          getToken: () async => 'Bearer $token',
        ),
        AuthLink(
          headerKey: 'qq-api-key',
          getToken: () async => _apiKey,
        ),
      ]);

      final link = authLink.concat(httpLink);

      _client = GraphQLClient(
        cache: GraphQLCache(),
        link: link,
      );

      final result = await _client!.query(
        QueryOptions(
          document: gql(query),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        debugPrint('Error fetching pending requests:');
        debugPrint('Exception type: ${exception.runtimeType}');
        debugPrint('Error message: ${exception.toString()}');

        if (exception.linkException != null) {
          debugPrint('Network error: ${exception.linkException}');
        }

        if (exception.graphqlErrors.isNotEmpty) {
          debugPrint('GraphQL Errors:');
          for (var error in exception.graphqlErrors) {
            debugPrint('- Message: ${error.message}');
            debugPrint('- Location: ${error.locations}');
            debugPrint('- Path: ${error.path}');
          }
        }
        return null;
      }

      if (result.data == null ||
          result.data!['getPendingFriendRequests'] == null) {
        debugPrint('No pending friend requests found in response');
        return null;
      }

      final pendingRequests =
          result.data!['getPendingFriendRequests'] as List<dynamic>;
      debugPrint(
          'Successfully fetched ${pendingRequests.length} pending friend requests');

      return pendingRequests;
    } catch (e, stackTrace) {
      debugPrint('Unexpected error in getPendingFriendRequests:');
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      return null;
    }
  }

  static Future<List<dynamic>?> getSentFriendRequests() async {
    const String query = r'''
      query Addressee {
        getSentFriendRequests {
          addressee {
            profilePictureUrl
            username
            id
          }
          id
        }
      }
    ''';

    debugPrint('Fetching sent friend requests...');

    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'refresh-token');

      final httpLink =
          HttpLink('https://qq-api-test-v0.homelab-kaleici.space/graphql');

      final authLink = Link.from([
        AuthLink(
          headerKey: 'Authorization',
          getToken: () async => 'Bearer $token',
        ),
        AuthLink(
          headerKey: 'qq-api-key',
          getToken: () async => _apiKey,
        ),
      ]);

      final link = authLink.concat(httpLink);

      _client = GraphQLClient(
        cache: GraphQLCache(),
        link: link,
      );

      final result = await _client!.query(
        QueryOptions(
          document: gql(query),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        debugPrint('Error fetching sent requests:');
        debugPrint('Exception type: ${exception.runtimeType}');
        debugPrint('Error message: ${exception.toString()}');

        if (exception.linkException != null) {
          debugPrint('Network error: ${exception.linkException}');
        }

        if (exception.graphqlErrors.isNotEmpty) {
          debugPrint('GraphQL Errors:');
          for (var error in exception.graphqlErrors) {
            debugPrint('- Message: ${error.message}');
            debugPrint('- Location: ${error.locations}');
            debugPrint('- Path: ${error.path}');
          }
        }
        return null;
      }

      if (result.data == null ||
          result.data!['getSentFriendRequests'] == null) {
        debugPrint('No sent friend requests found in response');
        return null;
      }

      final sentRequests =
          result.data!['getSentFriendRequests'] as List<dynamic>;
      debugPrint(
          'Successfully fetched ${sentRequests.length} sent friend requests');

      return sentRequests;
    } catch (e, stackTrace) {
      debugPrint('Unexpected error in getSentFriendRequests:');
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      return null;
    }
  }

  static Future<bool> acceptFriendRequest(String friendshipId) async {
    const String mutation = r'''
      mutation AcceptFriendRequest($friendshipId: String!) {
        acceptFriendRequest(friendshipId: $friendshipId) {
          id
        }
      }
    ''';

    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'refresh-token');

      final httpLink =
          HttpLink('https://qq-api-test-v0.homelab-kaleici.space/graphql');

      final authLink = Link.from([
        AuthLink(
          headerKey: 'Authorization',
          getToken: () async => 'Bearer $token',
        ),
        AuthLink(
          headerKey: 'qq-api-key',
          getToken: () async => _apiKey,
        ),
      ]);

      final link = authLink.concat(httpLink);

      _client = GraphQLClient(
        cache: GraphQLCache(),
        link: link,
      );

      final result = await _client!.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {
            'friendshipId': friendshipId,
          },
        ),
      );

      if (result.hasException) {
        debugPrint('Error accepting friend request: ${result.exception}');
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Error accepting friend request: $e');
      return false;
    }
  }

  static Future<bool> rejectFriendRequest(String friendshipId) async {
    const String mutation = r'''
      mutation RejectFriendRequest($friendshipId: String!) {
        rejectFriendRequest(friendshipId: $friendshipId) {
          id
        }
      }
    ''';

    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'refresh-token');

      final httpLink =
          HttpLink('https://qq-api-test-v0.homelab-kaleici.space/graphql');

      final authLink = Link.from([
        AuthLink(
          headerKey: 'Authorization',
          getToken: () async => 'Bearer $token',
        ),
        AuthLink(
          headerKey: 'qq-api-key',
          getToken: () async => _apiKey,
        ),
      ]);

      final link = authLink.concat(httpLink);

      _client = GraphQLClient(
        cache: GraphQLCache(),
        link: link,
      );

      final result = await _client!.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {
            'friendshipId': friendshipId,
          },
        ),
      );

      if (result.hasException) {
        debugPrint('Error rejecting friend request: ${result.exception}');
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Error rejecting friend request: $e');
      return false;
    }
  }

  static Future<bool> sendFriendRequest(String addresseeId) async {
    const String mutation = r'''
      mutation Mutation($input: FriendRequestInput!) {
        sendFriendRequest(input: $input) {
          id
          status
        }
      }
    ''';

    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'refresh-token');

      final httpLink =
          HttpLink('https://qq-api-test-v0.homelab-kaleici.space/graphql');

      final authLink = Link.from([
        AuthLink(
          headerKey: 'Authorization',
          getToken: () async => 'Bearer $token',
        ),
        AuthLink(
          headerKey: 'qq-api-key',
          getToken: () async => _apiKey,
        ),
      ]);

      final link = authLink.concat(httpLink);

      _client = GraphQLClient(
        cache: GraphQLCache(),
        link: link,
      );

      final result = await _client!.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {
            'input': {
              'addresseeId': addresseeId,
            },
          },
        ),
      );

      if (result.hasException) {
        debugPrint('Error sending friend request: ${result.exception}');
        return false;
      }

      final response = result.data?['sendFriendRequest'];
      debugPrint(
          'Friend request sent successfully. Status: ${response['status']}');
      return true;
    } catch (e) {
      debugPrint('Error sending friend request: $e');
      return false;
    }
  }
}
