/// Central configuration for BrowsingApp
class AppConfig {
  /// Unique App ID
  static const String appId = 'BROWSINGAPP-88392';

  /// Unique App Key
  static const String appKey = 'BROWSINGAPP-GEBDH5431';

  /// App Name
  static const String appName = 'browsingapp';

  /// App Version
  static const String appVersion = '1.0.0';

  /// Software Version
  static const String softwareVersion = '1.0.1';

  /// Phone verification API to check registered mobile numbers
  static const String idsPhoneApiUrl = 'https://managelogin.jobes24x7.com/api/user/ids-phone';

  /// Businesses API to fetch registered businesses for User Main ID
  static const String myBusinessesApiUrl = 'https://billing.srivagroups.in/api/businesses/my-businesses';

  /// Backward-compatible alias
  static const String propagatorBusinessApiUrl = myBusinessesApiUrl;
}

