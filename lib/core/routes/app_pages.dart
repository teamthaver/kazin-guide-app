import 'package:get/get.dart';
import 'package:kazin_guide_app/controllers/auth_controller.dart';
import 'package:kazin_guide_app/controllers/splash_controller.dart';
import 'package:kazin_guide_app/core/bindings/navigation_binding.dart';
import 'package:kazin_guide_app/screens/assignments/assignment_review_screen.dart';
import 'package:kazin_guide_app/screens/document/document_wallet_screen.dart';
import 'package:kazin_guide_app/screens/execution/live_active_service_screen.dart';
import 'package:kazin_guide_app/screens/navigation/main_navigation_shell.dart';

import '../../controllers/app_controller.dart';

import '../../screens/auth/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/dashboard/home_dashboard_screen.dart';
import '../../screens/assignments/assignments_list_screen.dart';
import '../../screens/assignments/assignment_details_screen.dart';
import '../../screens/assignments/decline_assignment_screen.dart';
import '../../screens/assignments/itinerary_change_screen.dart';
import '../../screens/execution/readiness_checklist_screen.dart';
import '../../screens/execution/service_execution_screen.dart';
import '../../screens/execution/airport_workflow_screen.dart';
import '../../screens/execution/map_navigation_screen.dart';
import '../../screens/execution/welcome_placard_screen.dart';
import '../../screens/operations/incident_reporting_screen.dart';
import '../../screens/operations/emergency_sos_screen.dart';
import '../../screens/finance/expense_submission_screen.dart';
import '../../screens/finance/cash_reconciliation_screen.dart';
import '../../screens/closure/service_closure_screen.dart';
import '../../screens/closure/guest_feedback_qr_screen.dart';
import '../../screens/notifications/notifications_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/profile/sop_handbook_screen.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashScreen(),
      binding: BindingsBuilder(() {
        Get.put<SplashController>(SplashController());
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginScreen(),
      binding: BindingsBuilder(() {
        Get.put<AuthController>(AuthController());
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.NAVIGATION_SHELL,
      page: () => MainNavigationShell(),
      binding: BindingsBuilder(() {
        Get.lazyPut<KazinController>(() => KazinController());
      }),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: _Paths.HOME,
      page: () => const HomeDashboardScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.ASSIGNMENTS,
      page: () => const AssignmentListScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.NOTIFICATIONS,
      page: () => const NotificationsScreen(),
      transition: Transition.fadeIn,
      binding: NavigationBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileScreen(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: _Paths.ASSIGNMENT_DETAILS,
      page: () => const AssignmentDetailsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.DECLINE_ASSIGNMENT,
      page: () => const DeclineAssignmentScreen(),
      transition: Transition.downToUp,
      fullscreenDialog: true,
    ),
    GetPage(
      name: _Paths.ITINERARY_CHANGE,
      page: () => const ItineraryChangeScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.READINESS_CHECKLIST,
      page: () => const ReadinessChecklistScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.SERVICE_EXECUTION,
      page: () => const ServiceExecutionScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.AIRPORT_WORKFLOW,
      page: () => const AirportWorkflowScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.MAP_NAVIGATION,
      page: () => const MapNavigationScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.WELCOME_PLACARD,
      page: () => const WelcomePlacardScreen(),
      transition: Transition.zoom,
      fullscreenDialog: true,
    ),

    GetPage(
      name: _Paths.INCIDENT_REPORTING,
      page: () => const IncidentReportingScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.EMERGENCY_SOS,
      page: () => const EmergencySosScreen(),
      transition: Transition.downToUp,
      fullscreenDialog: true,
    ),

    GetPage(
      name: _Paths.EXPENSE_SUBMISSION,
      page: () => const ExpenseSubmissionScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.CASH_RECONCILIATION,
      page: () => const CashReconciliationScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.SERVICE_CLOSURE,
      page: () => const ServiceClosureScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.GUEST_FEEDBACK_QR,
      page: () => const GuestFeedbackQrScreen(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: _Paths.DOCUMENT_WALLET,
      page: () => const DocumentWalletScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.SOP_HANDBOOK,
      page: () => const SopHandbookScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.LIVE_SERVICE,
      page: () => const LiveActiveServiceScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.ASSIGNMENT_REVIEW,
      page: () => const AssignmentReviewScreen(),
    ),
  ];
}

abstract class Routes {
  Routes._();
  static const SPLASH = _Paths.SPLASH;
  static const LOGIN = _Paths.LOGIN;
  static const NAVIGATION_SHELL = _Paths.NAVIGATION_SHELL;
  static const HOME = _Paths.HOME;
  static const ASSIGNMENTS = _Paths.ASSIGNMENTS;
  static const NOTIFICATIONS = _Paths.NOTIFICATIONS;
  static const PROFILE = _Paths.PROFILE;
  static const ASSIGNMENT_DETAILS = _Paths.ASSIGNMENT_DETAILS;
  static const DECLINE_ASSIGNMENT = _Paths.DECLINE_ASSIGNMENT;
  static const ITINERARY_CHANGE = _Paths.ITINERARY_CHANGE;
  static const READINESS_CHECKLIST = _Paths.READINESS_CHECKLIST;
  static const SERVICE_EXECUTION = _Paths.SERVICE_EXECUTION;
  static const AIRPORT_WORKFLOW = _Paths.AIRPORT_WORKFLOW;
  static const MAP_NAVIGATION = _Paths.MAP_NAVIGATION;
  static const WELCOME_PLACARD = _Paths.WELCOME_PLACARD;
  static const INCIDENT_REPORTING = _Paths.INCIDENT_REPORTING;
  static const EMERGENCY_SOS = _Paths.EMERGENCY_SOS;
  static const EXPENSE_SUBMISSION = _Paths.EXPENSE_SUBMISSION;
  static const CASH_RECONCILIATION = _Paths.CASH_RECONCILIATION;
  static const SERVICE_CLOSURE = _Paths.SERVICE_CLOSURE;
  static const GUEST_FEEDBACK_QR = _Paths.GUEST_FEEDBACK_QR;
  static const DOCUMENT_WALLET = _Paths.DOCUMENT_WALLET;
  static const SOP_HANDBOOK = _Paths.SOP_HANDBOOK;
  static const LIVE_SERVICE = _Paths.LIVE_SERVICE;
  static const ASSIGNMENT_REVIEW = _Paths.ASSIGNMENT_REVIEW;
}

abstract class _Paths {
  _Paths._();
  static const SPLASH = '/splash';
  static const LOGIN = '/login';
  static const NAVIGATION_SHELL = '/shell';
  static const HOME = '/home';
  static const ASSIGNMENTS = '/assignments';
  static const NOTIFICATIONS = '/notifications';
  static const PROFILE = '/profile';
  static const ASSIGNMENT_DETAILS = '/assignment-details';
  static const DECLINE_ASSIGNMENT = '/decline-assignment';
  static const ITINERARY_CHANGE = '/itinerary-change';
  static const READINESS_CHECKLIST = '/readiness-checklist';
  static const SERVICE_EXECUTION = '/service-execution';
  static const AIRPORT_WORKFLOW = '/airport-workflow';
  static const MAP_NAVIGATION = '/map-navigation';
  static const WELCOME_PLACARD = '/welcome-placard';
  static const INCIDENT_REPORTING = '/incident-reporting';
  static const EMERGENCY_SOS = '/emergency-sos';
  static const EXPENSE_SUBMISSION = '/expense-submission';
  static const CASH_RECONCILIATION = '/cash-reconciliation';
  static const SERVICE_CLOSURE = '/service-closure';
  static const GUEST_FEEDBACK_QR = '/guest-feedback-qr';
  static const DOCUMENT_WALLET = '/document-wallet';
  static const SOP_HANDBOOK = '/sop-handbook';
  static const LIVE_SERVICE = '/live-service';
  static const ASSIGNMENT_REVIEW = '/assignment-review';
}
