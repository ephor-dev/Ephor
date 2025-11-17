abstract final class Routes {
  static const login = '/login';
  static const dashboard = '/dashboard';

  static const dashboardOverview = 'overview';
  static const dashboardSchedules = 'schedules';
  static const dashboardAssessments = 'assessments';
  static const dashboardFinishedTrainings = 'finished-trainings';
  static const dashboardRecommendedTrainings = 'recommended-trainings';
  static const dashboardDarkMode = 'dark-mode';

  static String getOverviewPath() => '$dashboard/$dashboardOverview';
  static String getSchedulesPath() => '$dashboard/$dashboardSchedules';
  static String getAssessmentsPath() => '$dashboard/$dashboardAssessments';
  static String getFinishedTrainingsPath() => '$dashboard/$dashboardFinishedTrainings';
  static String getRecommendedTrainingsPath() => '$dashboard/$dashboardRecommendedTrainings';
  static String getDarkModePath() => '$dashboard/$dashboardDarkMode';
}