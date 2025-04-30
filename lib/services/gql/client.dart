import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:qoo_quote/services/rest_services/auth_service.dart';

// This class has ai generated code for refrsh tokens 
// may has issues

class GraphQLService {
  static final HttpLink _httpLink = HttpLink(
    '${dotenv.env['API_BASE_URL']}/graphql',
  );

  static final AuthLink _authLink = AuthLink(
    getToken: () async {
      final token =
          await const FlutterSecureStorage().read(key: 'access-token');
      return 'Bearer $token';
    },
  );

  static final ErrorLink _errorLink = ErrorLink(
    onGraphQLError: (request, forward, response) async* {
      // If there are no errors, just forward the response
      if (response.errors == null || response.errors!.isEmpty) {
        yield response;
        return;
      }

      // Check for authorization errors
      final hasAuthError = response.errors!.any((error) =>
          error.extensions?['code'] == 'FORBIDDEN' ||
          error.extensions?['code'] == 'UNAUTHENTICATED' ||
          error.message.toLowerCase().contains('forbidden') ||
          error.message.toLowerCase().contains('unauthorized'));

      if (hasAuthError) {
        try {
          // Attempt to refresh the token
          final tokens = await AuthService().refreshToken();
          await const FlutterSecureStorage().write(
            key: 'access-token',
            value: tokens['accessToken'],
          );
          await const FlutterSecureStorage().write(
            key: 'refresh-token',
            value: tokens['refreshToken'],
          );

          // Retry the original request
          yield* forward(request);
          return;
        } catch (e) {
          // If token refresh fails, rethrow the original error
          yield response;
          return;
        }
      }

      // For other errors, forward the response
      yield response;
    },
    onException: (request, forward, exception) async* {
      if (exception is HttpLinkServerException &&
          exception.response.statusCode == 403) {
        try {
          // Attempt to refresh the token
          final tokens = await AuthService().refreshToken();
          await const FlutterSecureStorage().write(
            key: 'access-token',
            value: tokens['accessToken'],
          );
          await const FlutterSecureStorage().write(
            key: 'refresh-token',
            value: tokens['refreshToken'],
          );

          // Retry the original request
          yield* forward(request);
          return;
        } catch (e) {
          // If token refresh fails, rethrow the original exception
          throw exception;
        }
      }
      // For other exceptions, rethrow
      throw exception;
    },
  );

  static late final GraphQLClient client;

  static void init() {
    final Link link = Link.from([_errorLink, _authLink, _httpLink]);

    client = GraphQLClient(
      link: link,
      cache: GraphQLCache(store: InMemoryStore()),
    );
  }
}
