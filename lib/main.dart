import 'package:flutter/material.dart';
import 'package:smart_cb_1/IntroAndRegistration/account_activity.dart';
import 'package:smart_cb_1/IntroAndRegistration/initial_setup.dart';
import 'package:smart_cb_1/IntroAndRegistration/intro_screen.dart';
import 'package:smart_cb_1/IntroAndRegistration/mobile_num.dart';
import 'package:smart_cb_1/IntroAndRegistration/new_pin.dart';
import 'package:smart_cb_1/IntroAndRegistration/otp_page.dart';
import 'package:smart_cb_1/IntroAndRegistration/pin_success.dart';
import 'package:smart_cb_1/IntroAndRegistration/privacy_policy.dart';
import 'package:smart_cb_1/IntroAndRegistration/registration.dart';
import 'package:smart_cb_1/IntroAndRegistration/terms_policy.dart';
import 'package:smart_cb_1/MainFunctions/About/about.dart';
import 'package:smart_cb_1/MainFunctions/ActivityLogs/activity_log.dart';
import 'package:smart_cb_1/MainFunctions/AddCB/add_new_cb.dart';
import 'package:smart_cb_1/MainFunctions/AddCB/search_connection.dart';
import 'package:smart_cb_1/MainFunctions/CircuitBreakerOption/bracket_option_page.dart';
import 'package:smart_cb_1/MainFunctions/ConnectedDevices/connected_devices.dart';
import 'package:smart_cb_1/MainFunctions/ForgotPassword/forgot_change_pin.dart';
import 'package:smart_cb_1/MainFunctions/ForgotPassword/forgot_pin_otp.dart';
import 'package:smart_cb_1/MainFunctions/LandingPage/circuit_breaker_list.dart';
import 'package:smart_cb_1/MainFunctions/LandingPage/nav_home.dart';
import 'package:smart_cb_1/MainFunctions/Login/login.dart';
import 'package:smart_cb_1/MainFunctions/Navigation/navigation_page.dart';
import 'package:smart_cb_1/MainFunctions/Settings/settings_page.dart';
import 'package:smart_cb_1/MainFunctions/Thresholds/voltage_settings.dart';
import 'package:smart_cb_1/MainFunctions/TripHistory/nav_history.dart';

void main() {
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
        '/navigationpage': (context) => NavigationPage(),
        '/cblist': (context) => CircuitBreakerList(),
        '/settingspage': (context) => SettingsPage(),
        '/addnewcb': (context) => AddNewCb(),
        '/search_connection': (context) => SearchConnection(),
        '/bracketoption': (context) => BracketOptionPage(),
        '/voltagesetting': (context) => VoltageSettingsPage(),
        '/history': (context) => History(),
        '/connectedDevices': (context) => ConnectedDevices(),
        '/nav_history': (context) => NavHistory(),
        '/about': (context) => About(),
        '/': (context) => InitialSetup(),
        '/mobile_num': (context) => const MobileSetup(),
        '/otp_page': (context) => OtpPage(),
        '/new_pin': (context) => NewPin(),
        '/pin_success': (context) => PinSuccess(),
        '/privacy': (context) => PrivacyPage(),
        '/terms': (context) => TermsPage(),
        '/registration': (context) => RegistrationPage(),
        '/intro_screen': (context) => IntroScreen(),
        '/login': (context) => LoginPage(),
        '/accountactivity': (context) => AccountActivity(),
        '/forgot_pin_otp': (context) => ForgotPassOTP(),
        '/forgot_change_pin': (context) => ForgotChangePin(),
        '/nav_home': (context) => NavHome(),
      },
    );
  }
}
