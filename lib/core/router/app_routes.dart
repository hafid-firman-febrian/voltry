abstract final class AppRoutes {
  static const home = '/';
  static const history = '/history';
  static const analyze = '/analyze';
  static const mealPattern = '/meal/:id';

  static String meal(String id) => '/meal/$id';
}
