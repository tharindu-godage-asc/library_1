import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'api_client.dart';

part 'api_providers.g.dart';

@riverpod
ApiClient apiClient(Ref ref) => ApiClient(http.Client());
