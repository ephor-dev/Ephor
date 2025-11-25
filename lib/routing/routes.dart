abstract final class Routes {
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const forgotPassword = '/forgot-password';
  static const updatePassword = '/update-password';

  static const dashboardOverview = 'overview';
  static const dashboardSchedules = 'schedules';
  static const dashboardAssessments = 'assessments';
  static const dashboardFinishedTrainings = 'finished-trainings';
  static const dashboardRecommendedTrainings = 'recommended-trainings';
  static const dashboardEmployeeList = 'employee-list';
  static const dashboardAddEmployee = 'add';
  static const dashboardEditEmployee = 'edit';
  static const dashboardCATNA1 = 'catna-form-1';
  static const dashboardCATNA2 = 'catna-form-2';
  static const dashboardCATNA3 = 'catna-form-3';

  static String getOverviewPath() => '$dashboard/$dashboardOverview';
  static String getSchedulesPath() => '$dashboard/$dashboardSchedules';
  static String getAssessmentsPath() => '$dashboard/$dashboardAssessments';
  static String getFinishedTrainingsPath() => '$dashboard/$dashboardFinishedTrainings';
  static String getRecommendedTrainingsPath() => '$dashboard/$dashboardRecommendedTrainings';
  static String getEmployeeListPath() => '$dashboard/$dashboardEmployeeList';
  static String getAddEmployeePath() => '$dashboard/$dashboardEmployeeList/$dashboardAddEmployee';
  static String getEditEmployeePath() => '$dashboard/$dashboardEmployeeList/$dashboardEditEmployee';
  static String getCATNAForm1Path() => '$dashboard/$dashboardCATNA1';
  static String getCATNAForm2Path() => '$dashboard/$dashboardCATNA2';
  static String getCATNAForm3Path() => '$dashboard/$dashboardCATNA3';
}