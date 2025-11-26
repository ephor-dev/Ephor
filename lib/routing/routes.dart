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
  static const dashboardIAForm = 'impact-assessment-form';
  static const dashboardCatnaFormCreator = 'catna-form-creator';

  static String getOverviewPath() => '$dashboard/$dashboardOverview';
  static String getSchedulesPath() => '$dashboard/$dashboardSchedules';
  static String getAssessmentsPath() => '$dashboard/$dashboardAssessments';
  static String getFinishedTrainingsPath() => '$dashboard/$dashboardFinishedTrainings';
  static String getRecommendedTrainingsPath() => '$dashboard/$dashboardRecommendedTrainings';
  static String getEmployeeListPath() => '$dashboard/$dashboardEmployeeList';
  static String getAddEmployeePath() => '$dashboard/$dashboardEmployeeList/$dashboardAddEmployee';
  static String getEditEmployeePath() => '$dashboard/$dashboardEmployeeList/$dashboardEditEmployee';
  static String getImpactAssessmentPath() => '$dashboard/$dashboardIAForm';
  static String getCatnaFormCreatorPath() => '$dashboard/$dashboardCatnaFormCreator';
}