import 'package:ecommerce_app/app/translations/ar_sa.dart';
import 'package:ecommerce_app/app/translations/en_us.dart';
import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': enUS,
    'ar_SA': arSA,
  };
}