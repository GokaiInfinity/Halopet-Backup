import '../../app/routes.dart';

String homeForRole(String role) {
  switch (role) {
    case 'admin':
      return AppRoutes.adminHome;
    case 'doctor':
      return AppRoutes.doctorHome;
    case 'owner':
    default:
      return AppRoutes.ownerHome;
  }
}
