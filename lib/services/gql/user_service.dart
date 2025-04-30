// lib/services/user_service.dart
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:qoo_quote/services/gql/client.dart';

class UserService {
  final GraphQLClient _client = GraphQLService.client;

  Future<bool> checkUserNameAvailability(String username) async {
    const query = r'''
      query CheckUserNameAvailability($username: String!) {
        checkUserNameAvailability(username: $username)
      }
    ''';

    final result = await _client.query(
      QueryOptions(
        document: gql(query),
        variables: {'username': username},
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return result.data?['checkUserNameAvailability'] as bool;
  }
}
