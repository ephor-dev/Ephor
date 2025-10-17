import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_user_model.dart';

class AuthRepository {
  final _supabase = Supabase.instance.client;

  Future<void> loginWithEmployeeCode(String employeeCode, String password) async {
    try {
      // STEP 1: Securely get the user's email from their employee code.
      final emailResponse = await _supabase.functions.invoke(
        'login', // Call our simple function
        body: {'employee_code': employeeCode},
      );

      if (emailResponse.status != 200) {
        throw 'Invalid employee code.';
      }

      final email = emailResponse.data['email'] as String?;
      if (email == null) {
        throw 'Could not retrieve email for employee code.';
      }

      // STEP 2: Use the standard Supabase sign-in method.
      // This handles all session logic correctly and internally.
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

    } on FunctionException catch (e) {
      throw 'Error validating employee code: ${e.message}';
    } on AuthException catch (e) {
      // Catches incorrect password errors
      throw e.message;
    } catch (e) {
      rethrow;
    }
  }

  Future<AppUser> getAppUserProfile() async {
    final supabaseUser = _supabase.auth.currentUser;
    if (supabaseUser == null) {
      throw 'No authenticated user found.';
    }

    final response = await _supabase
        .from('employees')
        .select('name, employee_code')
        .eq('user_id', supabaseUser.id)
        .single();

    return AppUser(
      id: supabaseUser.id,
      email: supabaseUser.email!,
      name: response['name'],
      employeeCode: response['employee_code'],
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}

extension on FunctionException {
  get message => null;
}