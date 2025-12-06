import 'dart:typed_data';

import 'package:ephor/data/services/shared_prefs/prefs_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ephor/domain/models/employee/employee.dart'; // Ensure this model is available

/// Supabase service for handling low-level database, auth, and application-specific
/// data (like Employee CRUD) calls, serving as a single source of truth.
class SupabaseService {
  
  // Use a nullable static client, initialized only once.
  static SupabaseClient? _staticClient;
  
  // --- Static Initialization ---
  
  /// Initializes the Supabase client instance. Must be called once before use.
  static Future<void> initialize({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    final sharedPrefs = PrefsService.getInstance();
    bool keepLoggedIn = sharedPrefs.getBool("keep_logged_in") ?? false;

    if (_staticClient == null) {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        authOptions: FlutterAuthClientOptions(
          authFlowType: AuthFlowType.implicit,
          localStorage: keepLoggedIn
            ? null
            : EmptyLocalStorage()
        )
      );
      _staticClient = Supabase.instance.client;
    }
  }

  // Get the Supabase auth instance (used by the Repository for listening)
  static GoTrueClient get auth {
    if (_staticClient == null) {
      throw Exception('Supabase not initialized. Call SupabaseService.initialize() first.');
    }
    return _staticClient!.auth;
  }

  // --- Client Access ---

  /// Provides access to the initialized SupabaseClient instance.
  SupabaseClient get _client {
    if (_staticClient == null) {
      throw Exception(
        'Supabase not initialized. Call SupabaseService.initialize() first.',
      );
    }
    return _staticClient!;
  }

  // -----------------------------------------------------------
  // --- Authentication/User Actions (from original SupabaseService) ---
  // -----------------------------------------------------------

  Future<FunctionResponse> signUpWithEmail(String email) async {
    final FunctionResponse response = await _client.functions.invoke(
      'create-employee',
      body: {
        'email': email,
        'password': 'ephor_app', // Default Password
        'role': 'employee',
      },
    );
    return response;
  }

  Future<AuthResponse> loginWithEmail(String email, String password) async {
    final authResponse = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return authResponse;
  }

  Future<UserResponse> changePassword(String password) async {
    final userResponse = await _client.auth.updateUser(
      UserAttributes(
        password: password
      )
    );
    return userResponse;
  }

  Future<AuthResponse> checkPassword(String password) async {
    final email = _client.auth.currentUser?.email;
    final response = await loginWithEmail(email!, password);
    return response;
  }

  Future<void> resetPasswordForEmail(String email) async {
    await _client.auth.resetPasswordForEmail(
      email,
      redirectTo: dotenv.env['REDIRECT_URL'] ?? 'http://localhost:3000/', 
    );
  }
  
  Future<Map<String, dynamic>?> validateEmployeeCode(String employeeCode) async {
    final employeeResponse = await _client
        .from('employees') 
        .select('email, role, employee_code, id, first_name, last_name')
        .eq('employee_code', employeeCode)
        .maybeSingle();
    
    return employeeResponse;
  }

  Future<Map<String, dynamic>?> getEmployeeData(String userId) async {
    final response = await _client
        .from('employees')
        .select()
        .eq('id', userId)
        .maybeSingle();

    return response;
  }
  
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // -----------------------------------------------------------
  // --- Employee CRUD Actions (from original EmployeeSupabaseService) ---
  // -----------------------------------------------------------

  Future<EmployeeModel> addEmployee(EmployeeModel employee) async {
    final List<Map<String, dynamic>> response = await _client
        .from('employees')
        .insert(employee.toJson())
        .select()
        .limit(1);

    return EmployeeModel.fromJson(response.first);
  }

  Future<EmployeeModel> editEmployee(EmployeeModel employee) async {
    final Map<String, dynamic> updates = employee.toJson();

    updates.remove('id'); 
    updates.remove('employee_code');

    final List<Map<String, dynamic>> response = await _client
        .from('employees')
        .update(updates)        // Pass the map of fields to change
        .eq('employee_code', employee.employeeCode)  // CRITICAL: WHERE id = employee.id
        .select();              // Ask Supabase to return the updated row

    return EmployeeModel.fromJson(response.first);
  }

  /// Fetches all employees from the 'employees' table.
  Future<List<EmployeeModel>> fetchAllEmployees() async {
    final List<Map<String, dynamic>> response = await _client
        .from('employees')
        .select();

    return response.map(EmployeeModel.fromJson).toList();
  }

  Future<String> removeEmployee(String id) async {
    try {
      // 1. Fetch the 'role' first to decide how to delete them
      final Map<String, dynamic> record = await _client
          .from('employees')
          .select('role') 
          .eq('id', id)
          .single();

      final String role = record['role'].toString();

      final bool hasLoginAccount = 
          role == 'supervisor' || role == 'humanResource'; 

      if (hasLoginAccount) {
        // --- PATH A: Privileged User ---
        // Call Edge Function to delete Auth User + DB Record
        final result = await _deleteViaEdgeFunction(id);
        return result;
      } else {
        // --- PATH B: Regular Staff ---
        // Delete directly from the table (Client-Side)
        await _client
            .from('employees')
            .delete()
            .eq('id', id);
        return "Removed employee successfully";
      }
    } catch (e) {
      return 'Failed to remove employee: $e';
    }
  }

  Future<String> _deleteViaEdgeFunction(String tableId) async {
    final FunctionResponse response = await _client.functions.invoke(
      'delete-employee',
      body: {'employeeId': tableId}, // Pass the Table ID
    );

    final data = response.data;
    
    if (response.status != 200 || (data is Map && data['error'] != null)) {
      return 'Failed to remove employee: Server deletion failed';
    }

    return 'Removed employee successfully!';
  }

  /// Fetches employee by ID.
  Future<EmployeeModel?> getEmployeeById(String id) async {
    final Map<String, dynamic>? response = await _client
        .from('employees')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return EmployeeModel.fromJson(response);
  }

  Future<EmployeeModel?> getEmployeeByCode(String code) async {
    final Map<String, dynamic>? response = await _client
        .from('employees')
        .select()
        .eq('employee_code', code)
        .maybeSingle();

    if (response == null) return null;
    return EmployeeModel.fromJson(response);
  }

  Future<EmployeeModel?> getEmployeeByEmail(String? email) async {
    if (email == null) {
      return null;
    }

    final Map<String, dynamic>? response = await _client
        .from('employees')
        .select()
        .eq('email', email)
        .maybeSingle();
    
    if (response == null) return null;
    return EmployeeModel.fromJson(response);
  }

  // Upload employee photos
  Future<String> uploadEmployeePhoto(String fileName, Uint8List fileBytes) async {
    
    // Upload the file
    final _ = await _client.storage.from('employee-photos').uploadBinary(
      fileName,
      fileBytes,
      fileOptions: const FileOptions(
        upsert: true, // Overwrite if the file already exists
        contentType: 'image/jpeg',
      ),
    );
    
    // Get the public URL for the uploaded file
    final String publicUrl = _client.storage.from('employee-photos').getPublicUrl(fileName);
    
    return publicUrl;
  }

  Future<bool> deleteOldPhoto(String publicUrl) async {
    try {
      final uri = Uri.parse(publicUrl);

      final String bucketName = 'employee-photos';
      
      final pathSegments = uri.pathSegments;
      final bucketIndex = pathSegments.indexOf(bucketName);
      
      if (bucketIndex == -1) {
        throw Exception('Invalid Supabase URL: Bucket not found');
      }

      final String filePath = pathSegments.sublist(bucketIndex + 1).join('/');

      final List<FileObject> result = await _client.storage
          .from(bucketName)
          .remove([filePath]); // remove takes a List of strings

      if (result.isEmpty) {
        return false;
      } else {
        return true;
      }

    } catch (e) {
      return false;
    }
  }

  Future<String?> getSignedEmployeePhotoUrl(String? path) async {
    if (path != null) {
      String correctRelativePath = Uri.parse(path)
        .path 
        .split('/')
        .skipWhile((segment) => segment != "employee-photos")
        .skip(1)
        .join('/');

      final response = await _client.storage.from('employee-photos').createSignedUrl(
        correctRelativePath,
        60,
      );

      return response; // response contains the full signed URL string
    }

    return null;
  }

  // CATNA THINGS

  Future<void> insertCatnaAssessment(Map<String, dynamic> payload) async {
    await _client.from('catna_assessments').insert(payload);
  }

  Future<void> insertImpactAssessment(Map<String, dynamic> payload) async {
    await _client.from('impact_assessments').insert(payload);
  }

  Future<List<Map<String, dynamic>>> getAllFinishedCATNA() async {
    final response = await _client.from('catna_assessments').select();

    return response;
  }

  Future<List<Map<String, dynamic>>> getAllFinishedIA() async {
    final response = await _client.from('impact_assessments').select();

    return response;
  }

  // Chatbot Things
  Future<String?> getGeminiKey() async {
    try {
      final response = await _client
          .from('app_config')
          .select('secret_value')
          .eq('id', 'gemini_api_key')
          .single();
      
      return response['secret_value'] as String;
    } catch (e) {
      return null;
    }
  }

  // Form Things
  Future<PostgrestMap> upsertForm(Map<String, dynamic> formData) async {
    final response = await _client
          .from('forms')
          .upsert(formData)
          .select() // Return the saved row
          .single();
    
    return response;
  }

  Future<PostgrestMap?> getFormById(String formId) async {
    final response = await _client
      .from('forms')
      .select()
      .eq('id', formId)
      .maybeSingle();
    
    return response;
  }

  Future<List<Map<String, dynamic>>> getAllForms() async {
    final response = await _client
      .from('forms')
      .select()
      .order('updated_at', ascending: false);
    
    return response;
  }

  Future<void> deleteForm(String formId) async {
    await _client.from('forms').delete().eq('id', formId);
  }

  Future<PostgrestMap?> fetchActiveCatnaForm() async {
    final response = await _client
      .from('forms')
      .select()
      .eq('id', 'bd1dd8c7-3524-4f2d-8508-9c416acb2be0')
      .maybeSingle();
    
    return response;
  }

  Future<PostgrestMap?> fetchActiveImpactAssessmentForm() async {
    final response = await _client
      .from('forms')
      .select()
      .eq('id', 'f6dcf61f-060d-4878-9d0e-96ad748a758c')
      .maybeSingle();
    
    return response;
  }

  // Overview
  Future<void> updateOverviewStatistics(Map<String, dynamic> analysisResult, bool hasImpact) async {
    // FIX: The API returns 'catna_analysis_summary', not 'catna_analysis'
    // We try both just to be safe.
    final result = analysisResult['catna_analysis_summary'] ?? analysisResult['catna_analysis'];

    if (result == null) {
      print("Warning: Could not find CATNA analysis data in payload.");
      return;
    }

    // FIX: Safe casting to List
    final individualPlans = (result['Individual_Training_Plans'] as List?) ?? [];
    final count = individualPlans.length;

    if (hasImpact) {
      final impactAssessmentResults = analysisResult['impact_assessment'];
      await updateIndividualAssessmentStatus(impactAssessmentResults);
    }

    // FIX: Map the plans safely
    final derivedActivity = individualPlans.map((plan) {
      // Ensure 'plan' is treated as a Map
      final p = plan as Map;
      String currentTime = DateTime.now().toIso8601String();
      updateEmployeeTrainingPlan(p['Name'], p['Training_Recommendation'], currentTime);
      return {
        'employeeName': p['Name'] ?? 'Unknown',
        'status': 'Identified',
        'timeAgo': currentTime,
        'description': p['Training_Recommendation'] ?? 'No recommendation',
      };
    }).toList();

    // 3. Update Supabase
    await _client.from('overview_stats').upsert({
      'id': 'university_wide_overview',
      'training_needs_count': count,
      'recent_activity': derivedActivity,
      'full_report': analysisResult, // Save the whole thing so you can read 'gemini_insights' later
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Stream<Map<String, dynamic>> getOverviewStatsStream(
    Map<String, dynamic> Function(List<Map<String, dynamic>>) convertFunction) {
  
    return _client
        .from('overview_stats') // Ensure this is the correct table name
        .stream(primaryKey: ['id'])
        .eq('id', 'university_wide_overview') // Filter for the specific row if needed
        .map((event) {
          // Convert the dynamic event to a typed list first
          final List<Map<String, dynamic>> typedList = List<Map<String, dynamic>>.from(event);
          // Apply the conversion function
          return convertFunction(typedList);
        });
  }

  Future<PostgrestList> getOverviewStats() async {
    final response = await _client
      .from('overview_stats') // Ensure this is the correct table name
      .select()
      .eq('id', 'university_wide_overview');
    
    return response;
  }

  Future<void> updateEmployeeCATNAStatus(String employeeCode) async {
    EmployeeModel? employee = await getEmployeeByCode(employeeCode);

    if (employee != null) {
      final Map<String, dynamic> updates = employee.toJson();
      updates.remove('id'); 
      updates.remove('employee_code');
      updates['catna_assessed'] = true;
      updates['impact_assessed'] = true;

      await _client
        .from('employees')
        .update(updates)
        .eq('employee_code', employeeCode)
        .select(); 
    }
  }

  Future<void> updateEmployeeIAStatus(String employeeCode) async {
    EmployeeModel? employee = await getEmployeeByCode(employeeCode);

    if (employee != null) {
      final Map<String, dynamic> updates = employee.toJson();
      updates.remove('id'); 
      updates.remove('employee_code');
      updates['catna_assessed'] = false;
      updates['impact_assessed'] = true;

      await _client
        .from('employees')
        .update(updates)
        .eq('employee_code', employeeCode)
        .select(); 
    }
  }
  
  Future<void> updateEmployeeTrainingPlan(String? employeeName, String? trainingRecommendation, String updateTime) async {
    if (employeeName == null || trainingRecommendation == null) return;

    final employeeList = await fetchAllEmployees();

    for (EmployeeModel employee in employeeList) {
      if (employee.fullName.trim().toLowerCase() == employeeName.trim().toLowerCase()) {
        Map<String, dynamic> currentHistory =Map<String, dynamic>.from(employee.assessmentHistory);

        final bool alreadyExists = currentHistory['result'].toString().toLowerCase() == trainingRecommendation.toLowerCase();

        if (alreadyExists) {
          print("Skipping: '$trainingRecommendation' already exists for ${employee.fullName}");
          break; 
        }

        // 4. Add the new recommendation since it is unique
        currentHistory = {
          'result': trainingRecommendation,
          'is_done': false,      // UI expects this boolean
          'action_date': null,   // UI expects this DateTime?
          'added_at': updateTime, // Optional: track when it was added
        };

        // 5. Update Supabase
        try {
          await _client.from('employees').update({
            'assessment_history': currentHistory
          }).eq('employee_code', employee.employeeCode);
          
          print("Successfully added '$trainingRecommendation' to ${employee.fullName}");
        } catch (e) {
          print("Failed to update training plan: $e");
        }

        // Stop the loop once we found and processed the employee
        break;
      }
    }
  }
  
  Future<void> updateIndividualAssessmentStatus(Map<String, dynamic> impactAssessmentResults) async {
    final rawList = impactAssessmentResults['Individual_Impact_Retake_Data'] as List?;;
    if (rawList == null) return;

    List<Map<String, dynamic>> individualImpactRetakeData = 
        rawList.map((e) => e as Map<String, dynamic>).toList();
    String geminiGroupAssessmentDetails = impactAssessmentResults['Gemini_Group_Assessment_Details'];
    List<EmployeeModel> employeeList = await fetchAllEmployees();

    print(individualImpactRetakeData);
    print(geminiGroupAssessmentDetails);

    for (Map<String, dynamic> retakeData in individualImpactRetakeData) {
      for (EmployeeModel employee in employeeList) {
        if (retakeData['name'] == employee.fullName && retakeData['retake_decision'] == "YES") {
          final Map<String, dynamic> updatedHistory = Map<String, dynamic>.from(employee.assessmentHistory);
          updatedHistory['is_done'] = false;
          updatedHistory['action_date'] = null;
  
          final EmployeeModel updatedEmployee = employee.copyWith(
            impactAssessmentNotes: geminiGroupAssessmentDetails,
            shallRetakeTraining: true,
            assessmentHistory: updatedHistory
          );

          await editEmployee(updatedEmployee);

          break;
        } else if (retakeData['name'] == employee.fullName && retakeData['retake_decision'] == 'NO') {
          final EmployeeModel updatedEmployee = employee.copyWith(
            impactAssessmentNotes: geminiGroupAssessmentDetails,
          );

          await editEmployee(updatedEmployee);
        }
      }
    }
  }

  // Chatbot Things
  Future<String?> getGeminiKey() async {
    try {
      final response = await _client
          .from('app_config')
          .select('secret_value')
          .eq('id', 'gemini_api_key')
          .single();
      
      return response['secret_value'] as String;
    } catch (e) {
      return null;
    }
  }
}