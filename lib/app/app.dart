import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../features/admin/admin_screens.dart';
import '../features/auth/auth_screens.dart';
import '../features/doctor/doctor_screens.dart';
import '../features/owner/owner_screens.dart';
import '../features/owner/pet_detail_tabs_screen.dart';
import '../features/owner/pet_diseases_screen.dart';
import '../features/owner/pet_vaccinations_screen.dart';
import '../features/owner/pet_add_wizard_screen.dart';
import '../features/owner/screens/emergency_clinic_screen.dart';
import '../features/owner/screens/notification_settings_screen.dart';
import '../features/owner/consultation_wizard_screen.dart';
import '../features/owner/monitoring_log_screen.dart';
import '../features/owner/telemedicine_result_screens.dart';
import '../features/owner/state_demo_screen.dart';
import '../features/owner/telemedicine_flow_screens.dart';
import '../features/owner/review_form_screen.dart';
import '../features/owner/help_center_screen.dart';
import '../features/profile/screens/edit_profile_screen.dart';
import '../features/doctor/doctor_notification_settings_screen.dart';
import '../features/doctor/doctor_daily_schedule_screen.dart';
import '../features/doctor/doctor_add_schedule_screen.dart';
import '../features/admin/admin_inventory_screens.dart';
import '../features/admin/admin_consultations_screen.dart';
import '../features/admin/admin_filtered_list_screens.dart';
import '../features/admin/admin_tickets_screen.dart';
import '../features/admin/admin_notification_settings_screen.dart';
import '../core/widgets/common_widgets.dart';
import 'routes.dart';
import 'theme.dart';

class HaloPetApp extends StatelessWidget {
  const HaloPetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HaloPet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'), // Indonesian
        Locale('en', 'US'), // English (fallback)
      ],
      locale: const Locale('id', 'ID'),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: (settings) {
        final args = settings.arguments;
        
        MaterialPageRoute<void> _page(Widget child) =>
            MaterialPageRoute(builder: (_) => child, settings: settings);

        switch (settings.name) {
          case AppRoutes.splash:
            return _page(const SplashScreen());
          case AppRoutes.welcome:
            return _page(const WelcomeScreen());
          case AppRoutes.authChoice:
            return _page(const AuthChoiceScreen());
          case AppRoutes.login:
            return _page(const LoginScreen());
          case AppRoutes.register:
            return _page(const RegisterScreen());
          case AppRoutes.forgot:
            return _page(const ForgotPasswordScreen());
          case AppRoutes.otp:
            final argsMap = args as Map<String, dynamic>?;
            final emailArgs = argsMap?['email'] as String? ?? '';
            final phoneArgs = argsMap?['phone'] as String? ?? '';
            final sentOtpArgs = argsMap?['sentOtp'] as String? ?? '';
            final nameArgs = argsMap?['name'] as String? ?? '';
            final passwordArgs = argsMap?['password'] as String? ?? '';
            return _page(OtpScreen(
              email: emailArgs,
              phone: phoneArgs,
              sentOtp: sentOtpArgs,
              name: nameArgs,
              password: passwordArgs,
            ));
          case AppRoutes.resetPassword:
            return _page(const ResetPasswordScreen());
          case AppRoutes.authSuccess:
            return _page(const AuthSuccessScreen());
          case AppRoutes.ownerHome:
            return _page(const OwnerDashboardScreen());
          case AppRoutes.ownerPets:
            return _page(const PetListScreen());
          case AppRoutes.petAdd:
            return _page(const PetAddWizardScreen());
          case AppRoutes.petEdit:
            return _page(PetFormScreen(pet: args as Map<String, Object?>?));
          case AppRoutes.petDetail:
            return _page(PetDashboardScreen(pet: args as Map<String, Object?>));
          case AppRoutes.petInfo:
            final map = args as Map<String, dynamic>;
            return _page(PetDetailTabsScreen(
                pet: map['pet'] as Map<String, Object?>,
                initialTabIndex: map['tabIndex'] as int? ?? 0));
          case AppRoutes.petDiseases:
            return _page(PetDiseasesScreen(pet: args as Map<String, Object?>));
          case AppRoutes.petVaccinations:
            return _page(
                PetVaccinationsScreen(pet: args as Map<String, Object?>));
          case AppRoutes.consultationWizard:
            return _page(const ConsultationWizardScreen());
          case AppRoutes.doctorList:
            return _page(DoctorListScreen(
                consultationArgs: args as Map<String, dynamic>?));
          case AppRoutes.doctorDetail:
            return _page(
                DoctorDetailScreen(doctor: args as Map<String, Object?>));
          case AppRoutes.booking:
            return _page(BookingScreen(doctor: args as Map<String, Object?>));
          case AppRoutes.emergencyVisit:
            return _page(EmergencyClinicScreen(args: args as Map<String, dynamic>));
          case AppRoutes.payment:
            return _page(PaymentScreen(args: args as Map<String, dynamic>));
          case AppRoutes.paymentSuccess:
            return _page(PaymentSuccessScreen(args: args as Map<String, dynamic>));

          case AppRoutes.medicineCheckout:
            return _page(
                MedicineCheckoutScreen(args: args as Map<String, dynamic>));
          case AppRoutes.medicinePayment:
            return _page(
                MedicinePaymentScreen(args: args as Map<String, dynamic>));
          case AppRoutes.medicineTracker:
            return _page(
                MedicineTrackerScreen(args: args as Map<String, dynamic>));
          case AppRoutes.consultationPrep:
            return _page(
                ConsultationPrepScreen(args: args as Map<String, dynamic>));
          case AppRoutes.ownerConsultations:
            return _page(const OwnerConsultationsScreen());
          case AppRoutes.reviewForm:
            return _page(ReviewFormScreen(args: args as Map<String, dynamic>));
          case AppRoutes.helpCenter:
            return _page(const HelpCenterScreen());
          case AppRoutes.consultationRoom:
            return _page(
                ConsultationRoomScreen(args: args as Map<String, dynamic>));
          case AppRoutes.videoCall:
            return _page(VideoCallScreen(args: args as Map<String, dynamic>));
          case AppRoutes.consultationFinished:
            return _page(
                ConsultationFinishedScreen(args: args as Map<String, dynamic>));
          case AppRoutes.consultationResult:
            return _page(
                ConsultationResultScreen(args: args as Map<String, dynamic>));
          case AppRoutes.electronicPrescription:
            return _page(ElectronicPrescriptionScreen(
                args: args as Map<String, dynamic>));
          case AppRoutes.pharmacySelection:
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            return _page(PharmacySelectionScreen(args: args));
          case AppRoutes.monitoringLog:
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            return _page(MonitoringLogScreen(args: args));
          case AppRoutes.stateDemo:
            return _page(const StateDemoScreen());
          case AppRoutes.chat:
            return _page(
                ChatScreen(consultation: args as Map<String, Object?>));
          case AppRoutes.ownerMedical:
            return _page(const OwnerMedicalRecordsScreen());
          case AppRoutes.ownerProfile:
            return _page(const OwnerProfileScreen());
          case AppRoutes.editProfile:
            return _page(const EditProfileScreen());
          case AppRoutes.notificationSettings:
            return _page(const NotificationSettingsScreen());
          case AppRoutes.doctorHome:
            return _page(const DoctorDashboardScreen());
          case AppRoutes.doctorNotifications:
            return _page(const DoctorNotificationScreen());
          case AppRoutes.doctorSchedule:
            return _page(const DoctorScheduleScreen());
          case AppRoutes.doctorConsultations:
            return _page(const DoctorConsultationsScreen());
          case AppRoutes.doctorAppointmentDetail:
            return _page(DoctorAppointmentDetailScreen(
                args: settings.arguments as Map<String, dynamic>));
          case AppRoutes.doctorPatients:
            return _page(const DoctorPatientListScreen());
          case AppRoutes.doctorPatientDetail:
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            return _page(DoctorPatientDetailScreen(patient: args));
          case AppRoutes.doctorMedicalHistory:
            return _page(const DoctorMedicalHistoryScreen());
          case AppRoutes.doctorMedicalNotes:
            return _page(const DoctorMedicalNotesScreen());
          case AppRoutes.doctorAddNote:
            return _page(const DoctorAddNoteScreen());
          case AppRoutes.doctorConsultationResultForm:
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            return _page(DoctorConsultationResultFormScreen(args: args));
          case AppRoutes.doctorProfile:
            return _page(const DoctorProfileScreen());
          case AppRoutes.doctorProfileDetail:
            return _page(
                const DoctorProfileScreen()); // Note: using DoctorProfileScreen for detail as well since mockup 17 is both Profile & Detail based on standard use
          case AppRoutes.doctorSettings:
            return _page(const DoctorSettingsScreen());
          case AppRoutes.doctorNotificationSettings:
            return _page(const DoctorNotificationSettingsScreen());
          case AppRoutes.doctorDailySchedule:
            final args = settings.arguments as Map<String, dynamic>;
            return _page(DoctorDailyScheduleScreen(
              date: args['date'] as DateTime,
              rawData: args['rawData'] as List<Map<String, dynamic>>,
            ));
          case AppRoutes.doctorAddSchedule:
            return _page(const DoctorAddScheduleScreen());
          case AppRoutes.doctorSupport:
            return _page(const DoctorSupportScreen());
          case AppRoutes.adminHome:
            return _page(const AdminDashboardScreen());
          case AppRoutes.adminNotifications:
            return _page(const AdminNotificationScreen());
          case AppRoutes.adminPatients:
            return _page(const AdminPatientManagementScreen());
          case AppRoutes.adminFilteredPatients:
            return _page(const AdminFilteredPatientsScreen());
          case AppRoutes.adminPatientDetail:
            return _page(const AdminPatientDetailScreen());
          case AppRoutes.adminDoctors:
            return _page(const AdminDoctorManagementScreen());
          case AppRoutes.adminFilteredDoctors:
            return _page(const AdminFilteredDoctorsScreen());
          case AppRoutes.adminAddDoctor:
            return _page(const AdminAddDoctorScreen());
          case AppRoutes.adminServices:
            return _page(const AdminServiceManagementScreen());
          case AppRoutes.adminServiceCategories:
            return _page(const AdminServiceCategoryScreen());
          case AppRoutes.adminMedicines:
            return _page(const AdminMedicineManagementScreen());
          case AppRoutes.adminAddMedicine:
            return _page(const AdminAddMedicineScreen());
          case AppRoutes.adminTransactions:
            return _page(const AdminTransactionScreen());
          case AppRoutes.adminFilteredTransactions:
            return _page(const AdminFilteredTransactionsScreen());
          case AppRoutes.adminReports:
            return _page(const AdminReportScreen());
          case AppRoutes.adminConsultations:
            final dateArgs = args as Map<String, dynamic>?;
            return _page(AdminConsultationsScreen(
              startDate: dateArgs?['startDate'] as DateTime?,
              endDate: dateArgs?['endDate'] as DateTime?,
            ));
          case AppRoutes.adminIntegration:
            return _page(const AdminIntegrationScreen());
          case AppRoutes.adminTickets:
            return _page(const AdminTicketsScreen());
          case AppRoutes.adminSettings:
            return _page(const AdminSettingsScreen());
          case AppRoutes.adminNotificationSettings:
            return _page(const AdminNotificationSettingsScreen());
          case AppRoutes.adminUsers:
            return _page(const AdminUserAccessScreen());
          default:
            return _page(const NotFoundScreen());
        }
      },
    );
  }
}
