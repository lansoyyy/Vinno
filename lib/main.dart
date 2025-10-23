import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:smart_cb_1/auth/auth_wrapper.dart';
import 'package:smart_cb_1/IntroAndRegistration/initial_setup.dart';
import 'package:smart_cb_1/IntroAndRegistration/intro_screen.dart';
import 'package:smart_cb_1/IntroAndRegistration/new_pin.dart';
import 'package:smart_cb_1/IntroAndRegistration/note.dart';
import 'package:smart_cb_1/IntroAndRegistration/otp_page.dart';
import 'package:smart_cb_1/IntroAndRegistration/pin_success.dart';
import 'package:smart_cb_1/IntroAndRegistration/privacy_policy.dart';
import 'package:smart_cb_1/IntroAndRegistration/registration.dart';
import 'package:smart_cb_1/IntroAndRegistration/terms_policy.dart';
import 'package:smart_cb_1/IntroAndRegistration/Owner/owner_registration_step1.dart';
import 'package:smart_cb_1/IntroAndRegistration/Owner/owner_registration_step2.dart';
import 'package:smart_cb_1/IntroAndRegistration/Owner/owner_registration_success.dart';
import 'package:smart_cb_1/Login_ForgotPass/ForgotPassword/forgot_change_pin.dart';
import 'package:smart_cb_1/Login_ForgotPass/ForgotPassword/forgot_pin_otp.dart';
import 'package:smart_cb_1/Login_ForgotPass/Login/login.dart';
import 'package:smart_cb_1/Owner_Side/Owner_About/about.dart';
import 'package:smart_cb_1/Owner_Side/Owner_ActivityLogs/activity_log.dart';
import 'package:smart_cb_1/Owner_Side/Owner_AddCB/add_new_cb.dart';
import 'package:smart_cb_1/Owner_Side/Owner_AddCB/cb_connection_success.dart';
import 'package:smart_cb_1/Owner_Side/Owner_AddCB/search_connection.dart';
import 'package:smart_cb_1/Owner_Side/Owner_AddCB/wifi_connection_list.dart';
import 'package:smart_cb_1/Owner_Side/Owner_CircuitBreakerOption/bracket_option_page.dart';
import 'package:smart_cb_1/Owner_Side/Owner_ConnectedDevices/connected_devices.dart';
import 'package:smart_cb_1/Owner_Side/Owner_ConnectedDevices/admin_staff_registration_step1.dart';
import 'package:smart_cb_1/Owner_Side/Owner_ConnectedDevices/admin_staff_registration_step2.dart';
import 'package:smart_cb_1/Owner_Side/Owner_ConnectedDevices/admin_staff_registration_success.dart';
import 'package:smart_cb_1/Owner_Side/Owner_LandingPage/circuit_breaker_list.dart';
import 'package:smart_cb_1/Owner_Side/Owner_LandingPage/nav_home.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Location/geolocation_screen.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Location/pin_location_screen.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Navigation/navigation_page.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Settings/settings_page.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Settings/edit_profile.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Settings/change_password.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Statistics/Consumption/consumption_main.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Statistics/statistics_menu.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Thresholds/voltage_settings.dart';
import 'package:smart_cb_1/Owner_Side/Owner_TripHistory/nav_history.dart';
import 'package:smart_cb_1/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'vinno-52914',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GetStorage.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => AuthWrapper(),
        '/otp_page': (context) => OtpPage(),
        '/new_pin': (context) => NewPin(),
        '/pin_success': (context) => PinSuccess(),
        '/privacy': (context) => PrivacyPage(),
        '/terms': (context) => TermsPage(),
        '/registration': (context) => RegistrationPage(),
        '/owner_registration_step1': (context) => OwnerRegistrationStep1(),
        '/owner_registration_step2': (context) => OwnerRegistrationStep2(),
        '/owner_registration_success': (context) => OwnerRegistrationSuccess(),
        '/intro_screen': (context) => IntroScreen(),
        '/login': (context) => LoginPage(),

        '/forgot_pin_otp': (context) => ForgotPassOTP(),
        '/forgot_change_pin': (context) => ForgotChangePin(),
        '/note': (context) => Note(),

        // OWNER SIDE
        '/navigationpage': (context) => NavigationPage(),
        '/cblist': (context) => CircuitBreakerList(),
        '/settingspage': (context) => SettingsPage(),
        '/edit_profile': (context) => EditProfile(),
        '/change_password': (context) => ChangePassword(),
        '/addnewcb': (context) => AddNewCb(),
        '/wifi_connection_list': (context) => WifiConnectionList(),
        '/search_connection': (context) => SearchConnection(),
        '/bracketoption': (context) => BracketOptionPage(),
        '/voltagesetting': (context) => VoltageSettingsPage(),
        '/history': (context) => History(),
        '/connectedDevices': (context) => ConnectedDevices(),
        '/admin_staff_registration_step1': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          return AdminStaffRegistrationStep1(
              accountType: args?['accountType'] ?? 'Admin');
        },
        '/admin_staff_registration_step2': (context) =>
            AdminStaffRegistrationStep2(),
        '/admin_staff_registration_success': (context) =>
            AdminStaffRegistrationSuccess(),
        '/nav_history': (context) => NavHistory(),
        '/about': (context) => About(),
        '/nav_home': (context) => NavHome(),
        '/geolocation': (context) => GeolocationScreen(),
        '/pin_location': (context) => PinLocationScreen(),
        '/cbsuccess': (context) => CBConnectionSuccess(),
        '/statistic_menu': (context) => StatisticsMenu(),
        '/consumption': (context) => ConsumptionMain(),
      },
    );
  }
}
