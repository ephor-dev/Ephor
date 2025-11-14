import 'package:ephor/data/repositories/auth/auth_repository.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:ephor/data/services/supabase/supabase_service.dart';

List<SingleChildWidget> get providers {
  return [
    Provider(create: (context) => SupabaseService()),
    // Provider(create: (context) => ApiClient()),
    // Provider(create: (context) => SharedPreferencesService()),
    ChangeNotifierProvider(
      create: (context) =>
          AuthRepository(
            supabaseService: context.read(),
                // authApiClient: context.read(),
                // apiClient: context.read(),
                // sharedPreferencesService: context.read(),
          ),
    ),
  ];
}