// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get appName => 'Smart Surveillance';

  @override
  String get commonRetry => 'Qayta urinish';

  @override
  String get commonCancel => 'Bekor qilish';

  @override
  String get commonSave => 'Saqlash';

  @override
  String get commonSaved => 'Saqlandi';

  @override
  String get commonDone => 'Tayyor';

  @override
  String get commonNext => 'Keyingisi';

  @override
  String get commonBack => 'Orqaga';

  @override
  String get commonContinue => 'Davom etish';

  @override
  String get commonClose => 'Yopish';

  @override
  String get commonDelete => 'Oʻchirish';

  @override
  String get commonRemove => 'Olib tashlash';

  @override
  String get commonEdit => 'Tahrirlash';

  @override
  String get commonApply => 'Qoʻllash';

  @override
  String get commonClear => 'Tozalash';

  @override
  String get commonReset => 'Asliga qaytarish';

  @override
  String get commonSkip => 'Hozircha oʻtkazib yuborish';

  @override
  String get commonAll => 'Hammasi';

  @override
  String get commonNone => 'Yoʻq';

  @override
  String get commonOn => 'Yoqilgan';

  @override
  String get commonOff => 'Oʻchiq';

  @override
  String get commonBeta => 'Beta';

  @override
  String get commonDemo => 'Demo maʼlumotlar';

  @override
  String get commonLoading => 'Yuklanmoqda';

  @override
  String get commonSeeAll => 'Hammasini koʻrish';

  @override
  String get commonOnline => 'Tarmoqda';

  @override
  String get commonOffline => 'Tarmoqda emas';

  @override
  String get commonUnknown => 'Nomaʼlum';

  @override
  String get commonToday => 'Bugun';

  @override
  String get commonYesterday => 'Kecha';

  @override
  String get commonJustNow => 'Hozirgina';

  @override
  String commonMinutesAgo(int count) {
    return '$count daqiqa oldin';
  }

  @override
  String commonHoursAgo(int count) {
    return '$count soat oldin';
  }

  @override
  String commonDaysAgo(int count) {
    return '$count kun oldin';
  }

  @override
  String commonSeconds(int count) {
    return '$count s';
  }

  @override
  String commonMinutesSeconds(int minutes, int seconds) {
    return '$minutes daqiqa $seconds s';
  }

  @override
  String commonPercent(String value) {
    return '$value%';
  }

  @override
  String get commonPermissionNeeded => 'Rolingiz buning uchun ruxsat bermaydi.';

  @override
  String get errorNetwork => 'Serverga ulanib boʻlmadi. Ulanish va server manzilini tekshiring.';

  @override
  String get errorUnauthorised => 'Email yoki parol notoʻgʻri.';

  @override
  String get errorForbidden => 'Rolingiz buning uchun ruxsat bermaydi.';

  @override
  String get errorNotFound => 'Bu endi mavjud emas.';

  @override
  String get errorConflict => 'Bu allaqachon mavjud.';

  @override
  String get errorInvalid => 'Belgilangan maydonlarni tekshiring.';

  @override
  String get errorExpired => 'Kodning muddati tugadi. Yangisini soʻrang.';

  @override
  String get errorServer => 'Serverda muammo yuz berdi. Birozdan keyin qayta urining.';

  @override
  String get errorUnknown => 'Nimadir xato ketdi.';

  @override
  String get errorTitle => 'Yuklab boʻlmadi';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldPassword => 'Parol';

  @override
  String get fieldName => 'Ismingiz';

  @override
  String get fieldNewPassword => 'Yangi parol';

  @override
  String get fieldCode => 'Xatdagi kod';

  @override
  String get validationEmail => 'Yaroqli email manzilini kiriting';

  @override
  String get validationPassword => 'Kamida 8 ta belgi kiriting';

  @override
  String get validationRequired => 'Majburiy';

  @override
  String get validationCode => '6 xonali kodni kiriting';

  @override
  String get welcomeTitle => 'Obyektingizdagi barcha kameralar choʻntagingizda';

  @override
  String get welcomeBody =>
      'Jonli videoni koʻring, muhim signallarni oling va uyda, doʻkonda, ofisda yoki omborda kim kelib-ketayotganini sanang.';

  @override
  String get welcomeCreate => 'Hisob yaratish';

  @override
  String get welcomeSignIn => 'Hisobim bor';

  @override
  String get welcomeFeatureLive => 'Har bir kameradan jonli video';

  @override
  String get welcomeFeatureAlerts => 'Odamlar, transport va aralashuv haqida signallar';

  @override
  String get welcomeFeatureCounts => 'Soatlar boʻyicha sanoq va band joylar';

  @override
  String get signInTitle => 'Kirish';

  @override
  String get signInSubtitle => 'Xush kelibsiz.';

  @override
  String get signInAction => 'Kirish';

  @override
  String get signInForgot => 'Parolni unutdingizmi?';

  @override
  String get signInNoAccount => 'Yangimisiz? Hisob yarating';

  @override
  String get serverTitle => 'Server';

  @override
  String get serverHint => 'Smart Surveillance serveringiz manzili';

  @override
  String get serverField => 'Server manzili';

  @override
  String get serverDemo =>
      'Demo rejim namunaviy maʼlumotlarni koʻrsatadi va serverni talab qilmaydi.';

  @override
  String get signUpTitle => 'Hisob yaratish';

  @override
  String get signUpSubtitle => 'Kuzatadigan barcha obyektlaringiz uchun bitta hisob.';

  @override
  String get signUpAction => 'Hisob yaratish';

  @override
  String get signUpTerms =>
      'Hisob yaratish orqali kameralaringiz videosi siz ulangan serverda qayta ishlanishiga rozilik bildirasiz.';

  @override
  String get signUpHaveAccount => 'Hisobingiz bormi? Kiring';

  @override
  String get passwordWeak => 'Zaif';

  @override
  String get passwordFair => 'Oʻrtacha';

  @override
  String get passwordStrong => 'Kuchli';

  @override
  String get verifyTitle => 'Emailingizni tekshiring';

  @override
  String verifyBody(String email) {
    return '$email manziliga 6 xonali kod yubordik. Manzilni tasdiqlash uchun uni shu yerga kiriting.';
  }

  @override
  String get verifyAction => 'Emailni tasdiqlash';

  @override
  String get verifyResend => 'Yangi kod yuborish';

  @override
  String get verifyResent => 'Yangi kod yoʻlda.';

  @override
  String get verifyWrongEmail => 'Boshqa email ishlatish';

  @override
  String get forgotTitle => 'Parolni tiklash';

  @override
  String get forgotBody => 'Emailingizni kiriting, yangi parol oʻrnatish uchun kod yuboramiz.';

  @override
  String get forgotAction => 'Kod yuborish';

  @override
  String get resetTitle => 'Yangi parol oʻrnatish';

  @override
  String resetBody(String email) {
    return '$email manziliga yuborilgan kodni kiriting va yangi parol tanlang.';
  }

  @override
  String get resetAction => 'Parolni saqlash';

  @override
  String get resetDone => 'Parol oʻzgartirildi. Yangi parol bilan kiring.';

  @override
  String get inviteTitle => 'Siz taklif qilindingiz';

  @override
  String inviteBody(String inviter, String organisation, String role) {
    return '$inviter sizni $organisation tashkilotiga $role roli bilan taklif qildi.';
  }

  @override
  String inviteSites(String sites) {
    return 'Obyektlar: $sites';
  }

  @override
  String get inviteAllSites => 'Tashkilotning barcha obyektlari';

  @override
  String inviteExpires(String date) {
    return 'Taklif $date gacha amal qiladi.';
  }

  @override
  String get inviteAccept => 'Taklifni qabul qilish';

  @override
  String get inviteSignInFirst => 'Avval kiring yoki hisob yarating, keyin havolani qayta oching.';

  @override
  String inviteAccepted(String organisation) {
    return 'Siz $organisation tashkilotiga qoʻshildingiz.';
  }

  @override
  String onboardingStep(int step, int total) {
    return '$step-qadam, jami $total ta';
  }

  @override
  String get onboardingSiteTitle => 'Birinchi obyektni sozlang';

  @override
  String get onboardingSiteBody =>
      'Obyekt - kameralar bor bitta joy: uyingiz, doʻkon, ofis yoki ombor. Keyinroq boshqa obyektlar qoʻshishingiz mumkin.';

  @override
  String get fieldOrganisation => 'Tashkilot nomi';

  @override
  String get fieldOrganisationHint => 'Oilangiz yoki kompaniyangiz';

  @override
  String get fieldSiteName => 'Obyekt nomi';

  @override
  String get fieldSiteNameHint => 'Masalan, Uy yoki Asosiy koʻchadagi doʻkon';

  @override
  String get fieldSiteKind => 'Obyekt turi';

  @override
  String get fieldTimezone => 'Vaqt mintaqasi';

  @override
  String get onboardingConnectorTitle => 'Konnektorni ulang';

  @override
  String get onboardingConnectorBody =>
      'Konnektor - obyektdagi doimo yoqilgan istalgan kompyuterda, masalan mini-kompyuter yoki Raspberry Pi da ishlaydigan kichik dastur. U kameralarni topadi va ularni serverga xavfsiz ulaydi.';

  @override
  String get onboardingConnectorStep1 =>
      'Obyektda doim yoniq turadigan kompyuterga Docker oʻrnating.';

  @override
  String get onboardingConnectorStep2 =>
      'Konnektorni server hujjatlaridagi buyruq bilan ishga tushiring.';

  @override
  String get onboardingConnectorStep3 =>
      'Konnektor QR kod va 8 belgili kodni koʻrsatadi. Uni skanerlang yoki shu yerga kiriting.';

  @override
  String get onboardingScan => 'QR kodni skanerlash';

  @override
  String get onboardingTypeCode => 'Kodni kiritish';

  @override
  String get fieldConnectorCode => 'Konnektor kodi';

  @override
  String get fieldConnectorName => 'Konnektor nomi';

  @override
  String get onboardingPair => 'Konnektorni ulash';

  @override
  String onboardingPaired(String name, String site) {
    return '$name $site obyektiga ulandi.';
  }

  @override
  String get scanTitle => 'Konnektor kodini skanerlang';

  @override
  String get scanHint => 'Kamerani konnektor ekranidagi QR kodga qarating.';

  @override
  String get scanNoPermission =>
      'Skanerlash uchun kameraga ruxsat bering yoki kodni qoʻlda kiriting.';

  @override
  String get scanAllow => 'Kameraga ruxsat berish';

  @override
  String get onboardingCamerasTitle => 'Tarmoqdagi kameralar';

  @override
  String get onboardingCamerasBody =>
      'Konnektor oʻz tarmogʻida kameralarni qidirdi. Qoʻshish uchun birini tanlang.';

  @override
  String get onboardingSearching => 'Kameralar qidirilmoqda';

  @override
  String get onboardingRescan => 'Qayta qidirish';

  @override
  String get onboardingNoCameras => 'Hozircha kamera topilmadi';

  @override
  String get onboardingNoCamerasBody =>
      'Kameralar yoqilganini va konnektor bilan bir tarmoqda ekanini tekshiring, keyin qayta qidiring.';

  @override
  String get onboardingAdded => 'Qoʻshilgan';

  @override
  String get onboardingAddCamera => 'Qoʻshish';

  @override
  String get onboardingFinish => 'Sozlashni tugatish';

  @override
  String get onboardingCameraTitle => 'Kamera qoʻshish';

  @override
  String get onboardingCameraBody =>
      'Kamera video uchun ishlatadigan loginni kiriting. U konnektorda shifrlangan holda saqlanadi va serverga yetib bormaydi.';

  @override
  String get fieldCameraUser => 'Kamera foydalanuvchi nomi';

  @override
  String get fieldCameraPassword => 'Kamera paroli';

  @override
  String get fieldCameraName => 'Kamera nomi';

  @override
  String get fieldCameraNameHint => 'Masalan, Kirish eshigi';

  @override
  String get fieldLenses => 'Bitta oqimdagi tasvirlar';

  @override
  String get lensesOne => 'Bitta tasvir';

  @override
  String get lensesTwo => 'Ustma-ust ikki obyektiv';

  @override
  String get onboardingTest => 'Oqimni tekshirish';

  @override
  String get onboardingTesting => 'Kameraga ulanilmoqda';

  @override
  String onboardingTestOk(String codec, int width, int height) {
    return 'Oqim ishlayapti: $codec, $width x $height';
  }

  @override
  String get onboardingTestFailed =>
      'Kamera kirishni rad etdi. Foydalanuvchi nomi va parolni tekshiring.';

  @override
  String get onboardingSaveCamera => 'Kamerani saqlash';

  @override
  String get onboardingAnalyticsTitle => 'Bu kamera nimani kuzatsin?';

  @override
  String onboardingAnalyticsBody(String camera) {
    return '$camera uchun boshlangʻich variantni tanlang. Hududlar va chiziqlarni chizishingiz hamda har bir sozlamani keyinroq oʻzgartirishingiz mumkin.';
  }

  @override
  String get presetPerimeter => 'Perimetr';

  @override
  String get presetPerimeterBody =>
      'Odamlar yoki transport kechasi yoki siz yoʻq paytda kadrga kirsa, signal beradi.';

  @override
  String get presetEntrance => 'Kirish';

  @override
  String get presetEntranceBody => 'Eshik yoki darvoza orqali kim kirib-chiqqanini sanaydi.';

  @override
  String get presetCounting => 'Sanash';

  @override
  String get presetCountingBody =>
      'Doʻkon va ofislar uchun odamlar va band joylarni signalsiz sanaydi.';

  @override
  String get presetTamper => 'Faqat aralashuv';

  @override
  String get presetTamperBody =>
      'Faqat kamera yopilgani, xiralashgani, siljigani yoki juda qorongʻi boʻlib qolgani haqida xabar beradi.';

  @override
  String get onboardingNotificationsTitle => 'Shu telefonda signallar oling';

  @override
  String get onboardingNotificationsBody =>
      'Ilova yopiq paytda ham signallar haqida xabar berishi uchun bildirishnomalarga ruxsat bering. Bildirishnomalarda tasvir boʻlmaydi: ilova uni bildirishnomani ochganingizda xavfsiz yuklaydi.';

  @override
  String get onboardingNotificationsAllow => 'Bildirishnomalarga ruxsat berish';

  @override
  String get onboardingDoneTitle => 'Obyektingiz tayyor';

  @override
  String get onboardingDoneBody =>
      'Kameralar ishlayapti. Signallar qoʻriqlash rejimiga bogʻliq, uni Bosh sahifa yorligʻida oʻzgartirishingiz mumkin.';

  @override
  String get onboardingOpenHome => 'Bosh sahifani ochish';

  @override
  String get navHome => 'Bosh sahifa';

  @override
  String get navLive => 'Jonli';

  @override
  String get navEvents => 'Hodisalar';

  @override
  String get navSearch => 'Qidiruv';

  @override
  String get navMore => 'Yana';

  @override
  String get siteKindHome => 'Uy';

  @override
  String get siteKindStore => 'Doʻkon';

  @override
  String get siteKindOffice => 'Ofis';

  @override
  String get siteKindWarehouse => 'Ombor';

  @override
  String get siteKindOther => 'Boshqa';

  @override
  String get siteSwitcherTitle => 'Obyektlar';

  @override
  String get siteSwitcherAdd => 'Obyekt qoʻshish';

  @override
  String siteCameras(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta kamera',
      zero: 'Kamera yoʻq',
    );
    return '$_temp0';
  }

  @override
  String get armDisarmed => 'Qoʻriqlash oʻchiq';

  @override
  String get armHome => 'Uyda';

  @override
  String get armAway => 'Uyda emas';

  @override
  String get armSchedule => 'Jadval boʻyicha';

  @override
  String get armDisarmedBody => 'Signallar yoʻq. Hodisalar baribir yozib boriladi.';

  @override
  String get armHomeBody =>
      'Faqat siz uyda boʻlganda signal beradigan hudud va chiziqlardan signal keladi.';

  @override
  String get armAwayBody => 'Barcha hudud va chiziqlar signal beradi.';

  @override
  String get armScheduleBody => 'Har bir hudud va chiziq oʻz jadvali boʻyicha signal beradi.';

  @override
  String get armTitle => 'Qoʻriqlash rejimi';

  @override
  String armChanged(String mode) {
    return 'Qoʻriqlash rejimi: $mode';
  }

  @override
  String get homeAlertsToday => 'Bugungi signallar';

  @override
  String homeUnacknowledged(int count) {
    return 'Koʻrib chiqish kerak: $count';
  }

  @override
  String get homeAllReviewed => 'Hammasi koʻrib chiqilgan';

  @override
  String get homeEventsToday => 'Bugungi hodisalar';

  @override
  String get homeCamerasOnline => 'Tarmoqdagi kameralar';

  @override
  String homeCamerasValue(int online, int total) {
    return '$total tadan $online tasi';
  }

  @override
  String get homeOccupancy => 'Hozir ichkarida';

  @override
  String get homeRecent => 'Oxirgi hodisalar';

  @override
  String get homeAttention => 'Eʼtibor talab qiladi';

  @override
  String get homeAllGood => 'Barcha kameralar va konnektorlar tarmoqda';

  @override
  String homeCameraOffline(String camera) {
    return '$camera tarmoqda emas';
  }

  @override
  String homeConnectorOffline(String connector, String when) {
    return '$connector tarmoqda emas, oxirgi marta: $when';
  }

  @override
  String homeConnectorOnline(String connector, String version) {
    return '$connector tarmoqda, versiya $version';
  }

  @override
  String get homeCountsToday => 'Bugungi tashrifchilar';

  @override
  String get homeCountsIn => 'Kirdi';

  @override
  String get homeCountsOut => 'Chiqdi';

  @override
  String get homeNoSite => 'Hozircha obyekt yoʻq';

  @override
  String get homeNoSiteBody =>
      'Kuzatuvni boshlash uchun obyektni sozlang va uning konnektorini ulang.';

  @override
  String get homeSetUp => 'Obyektni sozlash';

  @override
  String get homeNoEvents => 'Bugun hozircha tinch';

  @override
  String get liveTitle => 'Jonli';

  @override
  String get liveLayoutAuto => 'Avtomatik';

  @override
  String get liveLayoutOne => 'Bitta ustun';

  @override
  String get liveLayoutTwo => 'Ikkiga ikki';

  @override
  String get liveLayoutThree => 'Uchga uch';

  @override
  String get liveLayout => 'Joylashuv';

  @override
  String get liveNoCameras => 'Hozircha kamera yoʻq';

  @override
  String get liveNoCamerasBody =>
      'Kameralarni ulangan konnektor orqali qoʻshing, ular shu yerda koʻrinadi.';

  @override
  String get liveAddCamera => 'Kamera qoʻshish';

  @override
  String get liveConnecting => 'Ulanmoqda';

  @override
  String get liveFailed => 'Video mavjud emas';

  @override
  String get liveCameraOffline => 'Kamera tarmoqda emas';

  @override
  String get liveBadge => 'Jonli';

  @override
  String liveLens(int lens) {
    return 'Obyektiv $lens';
  }

  @override
  String get cameraMain => 'Asosiy';

  @override
  String get cameraSub => 'Qoʻshimcha';

  @override
  String get cameraQuality => 'Oqim';

  @override
  String get cameraSound => 'Tovush';

  @override
  String get cameraBoxes => 'Aniqlanganlarni koʻrsatish';

  @override
  String get cameraFullscreen => 'Butun ekran';

  @override
  String get cameraSnapshot => 'Suratga olish';

  @override
  String get cameraSnapshotSaved => 'Surat saqlandi';

  @override
  String get cameraPtz => 'Burish va egish';

  @override
  String get cameraSpeed => 'Tezlik';

  @override
  String get cameraZoomIn => 'Yaqinlashtirish';

  @override
  String get cameraZoomOut => 'Uzoqlashtirish';

  @override
  String get cameraHome => 'Boshlangʻich holat';

  @override
  String get cameraPresets => 'Presetlar';

  @override
  String get cameraNoPresets => 'Hozircha preset yoʻq';

  @override
  String get cameraSavePreset => 'Holatni saqlash';

  @override
  String get cameraPresetName => 'Preset nomi';

  @override
  String get cameraLight => 'Yorugʻlik';

  @override
  String get cameraSiren => 'Sirena';

  @override
  String get cameraSirenConfirm => 'Sirenani 10 soniyaga yoqasizmi?';

  @override
  String get cameraSirenOn => 'Sirena yangramoqda';

  @override
  String get cameraRecent => 'Bu kameradagi oxirgilar';

  @override
  String get cameraSettings => 'Kamera sozlamalari';

  @override
  String get cameraAnalytics => 'Analitika';

  @override
  String get ptzUp => 'Yuqoriga egish';

  @override
  String get ptzDown => 'Pastga egish';

  @override
  String get ptzLeft => 'Chapga burish';

  @override
  String get ptzRight => 'Oʻngga burish';

  @override
  String get eventsTitle => 'Hodisalar';

  @override
  String get eventsAlertsOnly => 'Faqat signallar';

  @override
  String get eventsFilters => 'Filtrlar';

  @override
  String eventsFilterCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count ta filtr');
    return '$_temp0';
  }

  @override
  String eventsNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta yangi hodisa',
    );
    return '$_temp0';
  }

  @override
  String get eventsEmpty => 'Hodisalar yoʻq';

  @override
  String get eventsEmptyBody =>
      'Hech narsa topilmadi. Boshqa kunni tanlang yoki filtrlarni kamaytiring.';

  @override
  String get eventsEmptyToday =>
      'Hozircha hech narsa boʻlmadi. Hodisalar kameralar koʻrgan zahoti shu yerda paydo boʻladi.';

  @override
  String get eventsAckAll => 'Hammasini koʻrib chiqilgan deb belgilash';

  @override
  String eventsAckAllDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta signal koʻrib chiqildi',
      zero: 'Koʻrib chiqadigan narsa yoʻq',
    );
    return '$_temp0';
  }

  @override
  String eventsTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta hodisa',
      zero: 'Hodisalar yoʻq',
    );
    return '$_temp0';
  }

  @override
  String get eventsLoadMore => 'Yana yuklash';

  @override
  String get filterDay => 'Kun';

  @override
  String get filterAnyDay => 'Istalgan kun';

  @override
  String get filterCameras => 'Kameralar';

  @override
  String get filterViews => 'Koʻrinishlar';

  @override
  String get filterKinds => 'Turlar';

  @override
  String get filterLabels => 'Obyektlar';

  @override
  String get filterZones => 'Hududlar';

  @override
  String get filterLines => 'Chiziqlar';

  @override
  String get filterPerson => 'Odam';

  @override
  String get filterPlate => 'Raqam';

  @override
  String get filterTime => 'Vaqt';

  @override
  String get filterShow => 'Natijalarni koʻrsatish';

  @override
  String get eventAlert => 'Signal';

  @override
  String get eventReviewed => 'Koʻrib chiqilgan';

  @override
  String get eventOngoing => 'Davom etmoqda';

  @override
  String get eventAcknowledge => 'Koʻrib chiqilgan deb belgilash';

  @override
  String get eventAcknowledged => 'Koʻrib chiqilgan deb belgilandi';

  @override
  String get eventShareClip => 'Klipni ulashish';

  @override
  String get eventClip => 'Klip';

  @override
  String get eventNoClip => 'Bu hodisada klip yoʻq.';

  @override
  String get eventSnapshot => 'Surat';

  @override
  String get eventDetails => 'Tafsilotlar';

  @override
  String get eventCamera => 'Kamera';

  @override
  String get eventView => 'Koʻrinish';

  @override
  String get eventZone => 'Hudud';

  @override
  String get eventLine => 'Chiziq';

  @override
  String get eventDirection => 'Yoʻnalish';

  @override
  String get eventDirectionIn => 'Kirdi';

  @override
  String get eventDirectionOut => 'Chiqdi';

  @override
  String get eventObjects => 'Obyektlar';

  @override
  String get eventDuration => 'Davomiyligi';

  @override
  String get eventStarted => 'Boshlandi';

  @override
  String get eventSource => 'Manba';

  @override
  String get eventSourceCamera => 'Kamera';

  @override
  String get eventSourceAnalytics => 'Analitika';

  @override
  String get eventFace => 'Yuz';

  @override
  String eventConfidence(int value) {
    return '$value% mos keldi';
  }

  @override
  String get eventPlate => 'Davlat raqami';

  @override
  String eventPlateReads(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count ta oʻqish');
    return '$_temp0';
  }

  @override
  String get plateInfrared => 'Kechasi oʻqilmadi: infraqizil yorugʻlik raqamda yaltiraydi.';

  @override
  String get plateNone => 'Transportda raqam topilmadi.';

  @override
  String get plateSmall => 'Raqam oʻqish uchun juda kichik edi.';

  @override
  String get plateUnreadable => 'Raqamni oʻqib boʻlmadi.';

  @override
  String get platePending => 'Raqam oʻqilmoqda.';

  @override
  String get eventJourney => 'Yoʻl';

  @override
  String get eventFindPerson => 'Bu odamni topish';

  @override
  String get eventWhoIsThis => 'Bu kim?';

  @override
  String get eventDemoClip => 'Demo klip';

  @override
  String get kindMotion => 'Harakat';

  @override
  String get kindPerson => 'Odam';

  @override
  String get kindVehicle => 'Transport';

  @override
  String get kindIntrusion => 'Bosib kirish';

  @override
  String get kindLineCrossing => 'Chiziqni kesib oʻtish';

  @override
  String get kindLoitering => 'Aylanib yurish';

  @override
  String get kindCrowd => 'Gavjumlik';

  @override
  String get kindFaceKnown => 'Tanish yuz';

  @override
  String get kindFaceUnknown => 'Notanish yuz';

  @override
  String get kindTamper => 'Aralashuv';

  @override
  String get kindStorage => 'Xotira';

  @override
  String get kindReboot => 'Qayta ishga tushish';

  @override
  String get kindAnimal => 'Hayvon';

  @override
  String get kindObjectLeft => 'Qoldirilgan buyum';

  @override
  String get kindObjectTaken => 'Olib ketilgan buyum';

  @override
  String get kindFall => 'Yiqilish';

  @override
  String titleMotion(String camera) {
    return '$camera: harakat';
  }

  @override
  String titlePerson(String camera) {
    return '$camera: odam';
  }

  @override
  String titleVehicle(String label, String camera) {
    return '$camera: $label';
  }

  @override
  String titleIntrusion(String label, String zone) {
    return '$label $zone hududiga kirdi';
  }

  @override
  String titleLineCrossing(String label, String line) {
    return '$label $line chizigʻini kesib oʻtdi';
  }

  @override
  String titleLoitering(String label, String zone) {
    return '$label $zone hududida aylanib yuribdi';
  }

  @override
  String titleCrowd(String zone) {
    return '$zone hududida gavjumlik';
  }

  @override
  String titleFaceKnown(String name) {
    return '$name koʻrindi';
  }

  @override
  String titleFaceUnknown(String label) {
    return '$label koʻrindi';
  }

  @override
  String titleTamper(String camera, String how) {
    return '$camera koʻrinishi $how';
  }

  @override
  String titleAnimal(String label, String camera) {
    return '$camera: $label';
  }

  @override
  String titleObjectLeft(String label, String zone) {
    return '$zone hududida $label qoldirildi';
  }

  @override
  String titleObjectTaken(String label, String zone) {
    return '$zone hududidan $label olib ketildi';
  }

  @override
  String titleFall(String camera) {
    return '$camera: yiqilish ehtimoli';
  }

  @override
  String titleStorage(String camera) {
    return '$camera: xotira muammosi';
  }

  @override
  String titleReboot(String camera) {
    return '$camera qayta ishga tushdi';
  }

  @override
  String get tamperCovered => 'yopilgan';

  @override
  String get tamperBlurred => 'xiralashgan';

  @override
  String get tamperDark => 'juda qorongʻi';

  @override
  String get tamperMoved => 'siljigan';

  @override
  String get tamperDisturbed => 'buzilgan';

  @override
  String get labelPerson => 'Odam';

  @override
  String get labelCar => 'Yengil mashina';

  @override
  String get labelTruck => 'Yuk mashinasi';

  @override
  String get labelBus => 'Avtobus';

  @override
  String get labelMotorcycle => 'Mototsikl';

  @override
  String get labelBicycle => 'Velosiped';

  @override
  String get labelDog => 'It';

  @override
  String get labelCat => 'Mushuk';

  @override
  String get labelBird => 'Qush';

  @override
  String get labelBackpack => 'Ryukzak';

  @override
  String get labelHandbag => 'Sumka';

  @override
  String get labelSuitcase => 'Chamadon';

  @override
  String get labelVehicle => 'Transport';

  @override
  String get labelAnimal => 'Hayvon';

  @override
  String get labelSomething => 'Nimadir';

  @override
  String get labelObject => 'Buyum';

  @override
  String get searchTitle => 'Qidiruv';

  @override
  String get searchEvents => 'Hodisalar';

  @override
  String get searchPeople => 'Odamlar';

  @override
  String get searchFaces => 'Yuzlar';

  @override
  String get searchPlates => 'Raqamlar';

  @override
  String get searchFrom => 'Dan';

  @override
  String get searchUntil => 'Gacha';

  @override
  String get searchLast24h => 'Oxirgi 24 soat';

  @override
  String get searchLast7d => 'Oxirgi 7 kun';

  @override
  String get searchLast30d => 'Oxirgi 30 kun';

  @override
  String get searchRun => 'Qidirish';

  @override
  String searchResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta natija',
      zero: 'Natija yoʻq',
    );
    return '$_temp0';
  }

  @override
  String get searchHint => 'Vaqt, kameralar, turlar va obyektlar boʻyicha soʻrov tuzing.';

  @override
  String get searchFacesTitle => 'Yuzni topish';

  @override
  String get searchFacesBody =>
      'Bitta yuzli suratni tanlang yoki kameralar koʻrgan yuzga bosing, u qayerda paydo boʻlganini topamiz.';

  @override
  String get searchFacesPhoto => 'Surat tanlash';

  @override
  String get searchFacesCamera => 'Suratga olish';

  @override
  String get searchFacesResults => 'Oʻxshash yuzlar';

  @override
  String get searchPlatesTitle => 'Transportni raqami boʻyicha topish';

  @override
  String get searchPlatesHint => 'Raqam matni, masalan 01 A 123 BC';

  @override
  String get searchPlatesBody => 'Raqamlar kunduzi raqam oʻqish yoqilgan koʻrinishlarda oʻqiladi.';

  @override
  String get facesOffTitle => 'Yuzni aniqlash oʻchiq';

  @override
  String get facesOffBody =>
      'Egasi yoki administrator uni tashkilot uchun Yana, Yuzlar boʻlimida yoqishi mumkin.';

  @override
  String get facesTurnOn => 'Yuz sozlamalarini ochish';

  @override
  String get peopleKnown => 'Tanish odamlar';

  @override
  String get peopleUnknown => 'Notanish yuzlar';

  @override
  String get peopleAdd => 'Odam qoʻshish';

  @override
  String get peopleEmpty => 'Hozircha odam yoʻq';

  @override
  String get peopleEmptyBody =>
      'Tanishlaringizni qoʻshing yoki kameralar toʻplagan notanish yuzlarga ism bering.';

  @override
  String peopleSeen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count marta koʻrilgan',
      one: 'Bir marta koʻrilgan',
    );
    return '$_temp0';
  }

  @override
  String peopleLastSeen(String when) {
    return 'Oxirgi marta: $when';
  }

  @override
  String get peopleNeverSeen => 'Hali koʻrilmagan';

  @override
  String get peopleSamples => 'Yuzlar';

  @override
  String get peopleSightings => 'Koʻrinishlar';

  @override
  String get peopleNoSightings => 'Hozircha koʻrinish yoʻq';

  @override
  String get peopleAddPhotos => 'Surat qoʻshish';

  @override
  String peoplePhotosAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta surat qoʻshildi',
      zero: 'Surat qoʻshilmadi',
    );
    return '$_temp0';
  }

  @override
  String peoplePhotosRejected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta suratda bitta aniq yuz yoʻq edi',
    );
    return '$_temp0';
  }

  @override
  String get peopleMerge => 'Boshqa odam bilan birlashtirish';

  @override
  String peopleMergeTitle(String name) {
    return '$name ni quyidagi bilan birlashtirish';
  }

  @override
  String get peopleDelete => 'Odamni oʻchirish';

  @override
  String peopleDeleteBody(String name) {
    return '$name barcha yuz namunalari va kadrlari bilan oʻchiriladi. Oldingi hodisalar suratlarini saqlab qoladi.';
  }

  @override
  String get peopleNotes => 'Izohlar';

  @override
  String get peopleName => 'Ism';

  @override
  String get clusterWhoTitle => 'Bu kim?';

  @override
  String get clusterWhoBody =>
      'Yangi odamga ism bering yoki tanishingizni tanlang. Uning oldingi hodisalari qayta nomlanadi.';

  @override
  String get clusterNewPerson => 'Yangi odam';

  @override
  String get clusterExisting => 'Tanishlardan biri';

  @override
  String clusterNamed(String name) {
    return 'Ismi: $name';
  }

  @override
  String get clusterDelete => 'Bu yuzlarni unutish';

  @override
  String get clusterDeleteBody =>
      'Notanish yuz namunalari oʻchiriladi. Oldingi hodisalar suratlarini saqlab qoladi.';

  @override
  String get findPersonTitle => 'Bu odamni topish';

  @override
  String get findPersonBody =>
      'Boshqa kameralardagi, kiyimi va gavdasi boʻyicha shu odamga oʻxshash koʻrinishlar. Kunduzgi va tungi kadrlar bir-biriga mos kelmaydi.';

  @override
  String get findPersonEmpty => 'Oʻxshash koʻrinish topilmadi';

  @override
  String findPersonMatch(int value) {
    return '$value% oʻxshash';
  }

  @override
  String get moreTitle => 'Yana';

  @override
  String get moreSite => 'Shu obyekt';

  @override
  String get moreOrganisation => 'Tashkilot';

  @override
  String get moreYou => 'Siz';

  @override
  String get moreCounts => 'Sanoq va band joylar';

  @override
  String get moreSiteSettings => 'Obyekt sozlamalari';

  @override
  String get moreCameras => 'Kameralar';

  @override
  String get moreAnalytics => 'Analitika';

  @override
  String get moreConnectors => 'Konnektorlar';

  @override
  String get moreHealth => 'Holat';

  @override
  String get moreMembers => 'Aʼzolar';

  @override
  String get moreFaces => 'Yuzlar';

  @override
  String get moreNotifications => 'Bildirishnomalar';

  @override
  String get moreAccount => 'Hisob';

  @override
  String get moreAppearance => 'Til va mavzu';

  @override
  String get moreAbout => 'Ilova haqida';

  @override
  String get moreSignOut => 'Chiqish';

  @override
  String get moreSignOutConfirm => 'Shu telefondan chiqasizmi?';

  @override
  String get countsTitle => 'Sanoq';

  @override
  String get countsHourly => 'Soatlar boʻyicha';

  @override
  String get countsDaily => 'Kunlar boʻyicha';

  @override
  String get countsIn => 'Kirdi';

  @override
  String get countsOut => 'Chiqdi';

  @override
  String countsTotalIn(int count) {
    return 'Kirdi: $count';
  }

  @override
  String countsTotalOut(int count) {
    return 'Chiqdi: $count';
  }

  @override
  String get countsNoLines => 'Sanash chiziqlari yoʻq';

  @override
  String get countsNoLinesBody =>
      'Chiziqni kesib oʻtayotgan odam va transportni sanash uchun Analitikada koʻrinishga chiziq chizing.';

  @override
  String get countsAreas => 'Joylar';

  @override
  String countsOccupancy(int count) {
    return 'Ichkarida: $count';
  }

  @override
  String countsCapacity(int count) {
    return '$count dan';
  }

  @override
  String countsSince(int entered, int exited, String time) {
    return '$time dan beri kirdi: $entered, chiqdi: $exited';
  }

  @override
  String get countsReset => 'Bandlikni belgilash';

  @override
  String get countsResetTitle => 'Hozir ichkarida nechta odam bor?';

  @override
  String countsResetDone(int count) {
    return 'Bandlik: $count';
  }

  @override
  String countsDailyReset(String time) {
    return 'Har kuni soat $time da nolga tushadi';
  }

  @override
  String countsPeak(String hour) {
    return 'Eng gavjum soat: $hour';
  }

  @override
  String get siteSettingsTitle => 'Obyekt sozlamalari';

  @override
  String get siteRetention => 'Hodisalarni saqlash muddati';

  @override
  String siteRetentionDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count kun');
    return '$_temp0';
  }

  @override
  String get siteArmHelp =>
      'Qoʻriqlash rejimi qaysi hodisalar signal berishini belgilaydi. Jadval boʻyicha rejimida har bir hudud va chiziq Analitikada belgilangan oʻz signal soatlariga amal qiladi.';

  @override
  String get camerasTitle => 'Kameralar';

  @override
  String get camerasReorder => 'Jonli koʻrinish tartibini oʻzgartirish uchun sudrang.';

  @override
  String get camerasAdd => 'Kamera qoʻshish';

  @override
  String get camerasDelete => 'Kamerani oʻchirish';

  @override
  String camerasDeleteBody(String camera) {
    return '$camera kamerasi koʻrinishlari, hududlari va chiziqlari bilan olib tashlanadi. Uning oldingi hodisalari muddati tugaguncha saqlanadi.';
  }

  @override
  String get camerasEnabled => 'Yoqilgan';

  @override
  String get camerasNoConnector => 'Avval konnektorni ulang';

  @override
  String get camerasNoConnectorBody =>
      'Kameralar obyektdagi konnektor orqali topiladi va qoʻshiladi.';

  @override
  String get settingsDevice => 'Qurilma';

  @override
  String get settingsManufacturer => 'Ishlab chiqaruvchi';

  @override
  String get settingsModel => 'Model';

  @override
  String get settingsFirmware => 'Proshivka';

  @override
  String get settingsVideo => 'Video';

  @override
  String get settingsImage => 'Tasvir';

  @override
  String get settingsBrightness => 'Yorqinlik';

  @override
  String get settingsContrast => 'Kontrast';

  @override
  String get settingsSaturation => 'Toʻyinganlik';

  @override
  String get settingsSharpness => 'Aniqlik';

  @override
  String get settingsIrCut => 'Tungi rejim filtri';

  @override
  String get settingsMotion => 'Kameradagi harakat aniqlash';

  @override
  String get settingsSensitivity => 'Sezgirlik';

  @override
  String get settingsClock => 'Soat';

  @override
  String settingsClockOffset(String value) {
    return 'Serverdan $value s farq';
  }

  @override
  String get settingsSyncClock => 'Soatni sinxronlash';

  @override
  String get settingsClockSynced => 'Soat sinxronlandi';

  @override
  String get settingsReboot => 'Kamerani qayta ishga tushirish';

  @override
  String get settingsRebootBody => 'Kamera videosi taxminan bir daqiqaga uziladi.';

  @override
  String get settingsRebooting => 'Kamera qayta ishga tushmoqda';

  @override
  String get settingsUnsupported => 'Bu kamerada bunday sozlama yoʻq.';

  @override
  String get analyticsTitle => 'Analitika';

  @override
  String get analyticsViewsBody =>
      'Har bir obyektiv bitta koʻrinish. U nimani kuzatishini tanlang va hudud hamda chiziqlarini chizing.';

  @override
  String analyticsZonesLines(int zones, int lines) {
    String _temp0 = intl.Intl.pluralLogic(
      zones,
      locale: localeName,
      other: '$zones ta hudud',
      zero: 'Hudud yoʻq',
    );
    String _temp1 = intl.Intl.pluralLogic(
      lines,
      locale: localeName,
      other: '$lines ta chiziq',
      zero: 'chiziq yoʻq',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String get analyticsDisabled => 'Analitika oʻchiq';

  @override
  String analyticsFps(String value) {
    return '$value fps';
  }

  @override
  String get analyticsSuspended => 'Obyektiv oʻz hududlaridan burilgan';

  @override
  String get analyticsEnabled => 'Bu koʻrinishni tahlil qilish';

  @override
  String get analyticsProfile => 'Profil';

  @override
  String get profilePerimeter => 'Perimetr';

  @override
  String get profileVehicle => 'Transport';

  @override
  String get profileIdentity => 'Shaxs';

  @override
  String get profileTamper => 'Faqat aralashuv';

  @override
  String get analyticsStream => 'Tahlil qilinadigan oqim';

  @override
  String get analyticsStreamSub => 'Qoʻshimcha oqim, aniqlash va sanash uchun';

  @override
  String get analyticsStreamMain => 'Asosiy oqim, yuz va raqamlar uchun';

  @override
  String get analyticsFeatures => 'Imkoniyatlar';

  @override
  String get featureTamper => 'Aralashuvni kuzatish';

  @override
  String get featureTamperBody => 'Yopilgan, xiralashgan, siljigan va juda qorongʻi';

  @override
  String get featureFaces => 'Yuzlar';

  @override
  String get featureFacesBody => 'Tanishlarga ism berish, notanish yuzlarni yigʻish';

  @override
  String get featureFacesLocked => 'Avval tashkilot uchun yuzlarni yoqing';

  @override
  String get featureAppearance => 'Yoʻllar';

  @override
  String get featureAppearanceBody =>
      'Odamni kameralar oʻrtasida tashqi koʻrinishi boʻyicha bogʻlash';

  @override
  String get featureFalls => 'Yiqilishlar';

  @override
  String get featureFallsBody => 'Kimdir yiqilib, turmasa signal berish';

  @override
  String get featurePlates => 'Davlat raqamlari';

  @override
  String get featurePlatesBody => 'Kunduzi transport hodisalarida raqamlarni oʻqish';

  @override
  String get featureFollow => 'Avto kuzatish';

  @override
  String get featureFollowBody =>
      'Odamni kadrda ushlab turish uchun obyektivni burish, keyin qaytish';

  @override
  String get featureMoving => 'Harakatlanuvchi obyektiv';

  @override
  String get featureMovingBody => 'Hududlar chizilgan tasvirda qoladi';

  @override
  String get analyticsRules => 'Hudud va chiziqlar';

  @override
  String get analyticsEdit => 'Hudud va chiziqlarni chizish';

  @override
  String get analyticsNoRules => 'Hozircha hudud va chiziq yoʻq';

  @override
  String get analyticsWholeView => 'Butun koʻrinish';

  @override
  String get editorTitle => 'Hudud va chiziqlar';

  @override
  String get editorZone => 'Hudud';

  @override
  String get editorLine => 'Chiziq';

  @override
  String get editorAddZone => 'Yangi hudud';

  @override
  String get editorAddLine => 'Yangi chiziq';

  @override
  String get editorHintZone =>
      'Burchaklarni qoʻyish uchun tasvirga bosing. Burchakni siljitish uchun sudrang.';

  @override
  String get editorHintLine =>
      'Chiziq uchun ikki nuqtaga bosing. Strelka ichkari tomonni koʻrsatadi.';

  @override
  String get editorUndo => 'Nuqtani bekor qilish';

  @override
  String get editorFlip => 'Yoʻnalishni almashtirish';

  @override
  String get editorDelete => 'Shaklni oʻchirish';

  @override
  String get editorDiscard => 'Oʻzgarishlar bekor qilinsinmi?';

  @override
  String get editorDiscardBody => 'Hudud va chiziqlaringiz hali saqlanmagan.';

  @override
  String get editorKeepEditing => 'Tahrirlashni davom ettirish';

  @override
  String get editorSaved => 'Hudud va chiziqlar saqlandi. Ular bir necha soniyada qoʻllanadi.';

  @override
  String get editorNameZone => 'Hudud nomi';

  @override
  String get editorNameLine => 'Chiziq nomi';

  @override
  String get editorObjects => 'Kuzatiladiganlar';

  @override
  String get editorDwell => 'Ichkarida minimal vaqt';

  @override
  String get editorLoiter => 'Aylanib yurish: kechikish';

  @override
  String get editorCrowd => 'Gavjumlik: kamida';

  @override
  String editorCrowdPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kishi',
      zero: 'Oʻchiq',
    );
    return '$_temp0';
  }

  @override
  String get editorLeft => 'Buyum qoldirilishi: kechikish';

  @override
  String get editorTaken => 'Buyum olib ketilishi: kechikish';

  @override
  String get editorAlerts => 'Signallar';

  @override
  String get editorAlertOff => 'Hech qachon';

  @override
  String get editorAlertAlways => 'Doimo';

  @override
  String get editorAlertSchedule => 'Jadval boʻyicha';

  @override
  String editorAlertHours(String start, String end) {
    return '$start dan $end gacha signal berish';
  }

  @override
  String get editorAnimals => 'Hayvonlar';

  @override
  String get editorAnimalsInclude => 'Signal berish';

  @override
  String get editorAnimalsRecord => 'Faqat yozish';

  @override
  String get editorAnimalsExclude => 'Eʼtiborsiz qoldirish';

  @override
  String get editorDirection => 'Sanash yoʻnalishi';

  @override
  String get editorDirectionIn => 'Ichkariga';

  @override
  String get editorDirectionOut => 'Tashqariga';

  @override
  String get editorDirectionBoth => 'Ikki tomonga';

  @override
  String get editorDurationOff => 'Oʻchiq';

  @override
  String get editorEnabled => 'Faol';

  @override
  String get editorTooFewPoints => 'Hududda kamida 3 ta burchak boʻlishi kerak.';

  @override
  String get connectorsTitle => 'Konnektorlar';

  @override
  String get connectorsPair => 'Konnektorni ulash';

  @override
  String get connectorsEmpty => 'Hozircha konnektor yoʻq';

  @override
  String get connectorsEmptyBody =>
      'Obyektdagi konnektor kameralarni topadi va ularni serverga bogʻlaydi.';

  @override
  String connectorsVersion(String version) {
    return 'Versiya $version';
  }

  @override
  String connectorsSeen(String when) {
    return 'Tarmoqda: $when';
  }

  @override
  String get connectorsRemove => 'Konnektorni olib tashlash';

  @override
  String get connectorsRemoveBody =>
      'Obyektga boshqa konnektor ulanmaguncha uning kameralari ishlamaydi.';

  @override
  String get connectorsMode => 'Toʻgʻridan-toʻgʻri ulanish';

  @override
  String get connectorsFind => 'Kameralarni topish';

  @override
  String get membersTitle => 'Aʼzolar';

  @override
  String get membersInvite => 'Taklif qilish';

  @override
  String get membersInvited => 'Taklif qilingan';

  @override
  String get membersYou => 'Siz';

  @override
  String get membersAllSites => 'Barcha obyektlar';

  @override
  String membersSomeSites(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count ta obyekt');
    return '$_temp0';
  }

  @override
  String get membersPending => 'Kutilayotgan takliflar';

  @override
  String membersExpires(String date) {
    return '$date gacha amal qiladi';
  }

  @override
  String get membersRevoke => 'Taklifni bekor qilish';

  @override
  String get membersRemove => 'Tashkilotdan chiqarish';

  @override
  String membersRemoveBody(String name) {
    return '$name tashkilotning barcha obyektlariga kirish huquqini birdan yoʻqotadi.';
  }

  @override
  String get membersRole => 'Rol';

  @override
  String get membersSites => 'Obyektlar';

  @override
  String get membersInviteTitle => 'Aʼzoni taklif qilish';

  @override
  String get membersInviteBody => 'U 7 kun davomida bir marta ishlaydigan havolali xat oladi.';

  @override
  String membersInviteSent(String email) {
    return 'Taklif $email manziliga yuborildi';
  }

  @override
  String get roleOwner => 'Egasi';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get roleOperator => 'Operator';

  @override
  String get roleViewer => 'Kuzatuvchi';

  @override
  String get roleOwnerBody => 'Hamma narsa, jumladan tashkilotni oʻchirish';

  @override
  String get roleAdminBody => 'Kameralar, analitika, odamlar va aʼzolar';

  @override
  String get roleOperatorBody =>
      'Koʻrish, kameralarni boshqarish, qoʻriqlashni yoqish va oʻchirish';

  @override
  String get roleViewerBody => 'Jonli video va hodisalarni koʻrish';

  @override
  String get facesTitle => 'Yuzni aniqlash';

  @override
  String get facesBody =>
      'Yuzlar shu tashkilot serverida solishtiriladi. Buni faqat suratga olinayotgan odamlar xabardor qilingan va rozi boʻlgan joyda, mamlakatingiz qonuni talab qilganidek yoqing.';

  @override
  String get facesConsentTitle => 'Yuzni aniqlash yoqilsinmi?';

  @override
  String get facesConsentBody =>
      'Yuzni aniqlash yuzlar yoqilgan koʻrinishlarda kameralar koʻrgan har bir kishining yuz suratlari va yuz oʻlchamlarini saqlaydi. Yuz oʻlchamlari biometrik maʼlumotdir. Siz suratga olinayotgan odamlar xabardor qilinganini, yuzlarini qayta ishlash uchun qonuniy asosingiz borligini va maʼlumot faqat kerakli muddatgacha saqlanishini tasdiqlaysiz. Buni istalgan vaqtda oʻchirishingiz mumkin; tanish odamlar va ularning yuzlari siz oʻchirmaguningizcha saqlanib qoladi.';

  @override
  String get facesConsentConfirm => 'Tushundim, yoqish';

  @override
  String get facesEnabled => 'Yuzni aniqlash yoqilgan';

  @override
  String get facesDisabled => 'Yuzni aniqlash oʻchiq';

  @override
  String get facesOwnerOnly => 'Buni faqat egasi yoki administrator oʻzgartira oladi.';

  @override
  String get notificationsTitle => 'Bildirishnomalar';

  @override
  String notificationsSite(String site) {
    return '$site signallari';
  }

  @override
  String get notificationsAlertsOnly => 'Faqat signallar';

  @override
  String get notificationsAlertsOnlyBody =>
      'Oʻchiq boʻlsa, barcha hodisalar keladi, ular koʻp boʻlishi mumkin.';

  @override
  String get notificationsKinds => 'Turlar';

  @override
  String get notificationsQuiet => 'Tinch soatlar';

  @override
  String notificationsQuietBody(String from, String until) {
    return '$from dan $until gacha ovozsiz';
  }

  @override
  String get notificationsQuietOff => 'Tinch soatlar yoʻq';

  @override
  String get notificationsPermissionOff => 'Bu ilova uchun bildirishnomalar bloklangan.';

  @override
  String get notificationsOpenSettings => 'Sozlamalarni ochish';

  @override
  String get notificationsChannel => 'Yetkazish';

  @override
  String get notificationsChannelFcm => 'Firebase Cloud Messaging orqali push';

  @override
  String get notificationsChannelNone => 'Ilova ochiq paytda. Bu versiyada push xizmati yoʻq.';

  @override
  String get healthTitle => 'Holat';

  @override
  String healthUptime(String value) {
    return 'Tarmoqda: $value%';
  }

  @override
  String healthLatency(String value) {
    return '$value ms';
  }

  @override
  String get healthOutages => 'Uzilishlar';

  @override
  String get healthNoOutages => 'Oxirgi 24 soatda uzilish boʻlmadi';

  @override
  String healthOngoing(String duration) {
    return 'Davom etmoqda: $duration';
  }

  @override
  String healthLasted(String duration) {
    return 'Davomiyligi: $duration';
  }

  @override
  String healthCause(String name) {
    return 'Sababi: $name';
  }

  @override
  String get healthLast24h => 'Oxirgi 24 soat';

  @override
  String get healthUp => 'Ishlayapti';

  @override
  String get healthDegraded => 'Nosoz';

  @override
  String get healthDown => 'Ishlamayapti';

  @override
  String get accountTitle => 'Hisob';

  @override
  String get accountProfile => 'Profil';

  @override
  String get accountSessions => 'Kirilgan qurilmalar';

  @override
  String get accountThisDevice => 'Shu qurilma';

  @override
  String accountLastUsed(String when) {
    return 'Oxirgi marta: $when';
  }

  @override
  String get accountRevoke => 'Shu qurilmadan chiqish';

  @override
  String accountRevoked(String device) {
    return 'Chiqildi: $device';
  }

  @override
  String get accountAppLock => 'Ilova qulfi';

  @override
  String get accountAppLockBody => 'Ilova ochilganda barmoq izi, yuz yoki ekran qulfini soʻrash';

  @override
  String get accountAppLockUnavailable => 'Bu telefonda ekran qulfi sozlanmagan.';

  @override
  String get accountDelete => 'Hisobni oʻchirish';

  @override
  String get accountDeleteTitle => 'Hisobingizni oʻchirish';

  @override
  String get accountDeleteBody =>
      'Hisobingiz oʻchiriladi va hamma joyda chiqib ketasiz. Egasi boʻlgan tashkilotlaringizni avval boshqa egaga topshirish yoki oʻchirish kerak. Buni bekor qilib boʻlmaydi.';

  @override
  String get accountDeleteConfirm => 'Hisobimni oʻchirish';

  @override
  String get accountDeletePassword => 'Tasdiqlash uchun parolni kiriting';

  @override
  String get accountDeleted => 'Hisobingiz oʻchirildi.';

  @override
  String get appearanceTitle => 'Til va mavzu';

  @override
  String get appearanceLanguage => 'Til';

  @override
  String get appearanceSystem => 'Telefon sozlamasi';

  @override
  String get appearanceTheme => 'Mavzu';

  @override
  String get themeSystem => 'Telefon sozlamasi';

  @override
  String get themeLight => 'Yorugʻ';

  @override
  String get themeDark => 'Qorongʻi';

  @override
  String get aboutTitle => 'Ilova haqida';

  @override
  String aboutVersion(String version) {
    return 'Versiya $version';
  }

  @override
  String aboutBuild(String flavor) {
    return '$flavor build';
  }

  @override
  String get aboutServer => 'Server';

  @override
  String get aboutLicences => 'Ochiq manbali litsenziyalar';

  @override
  String get aboutPrivacy =>
      'Video, suratlar va yuzlar siz ulangan serverda qoladi. Bildirishnomalarda faqat identifikatorlar boʻladi; tasvirni ilovaning oʻzi yuklaydi.';

  @override
  String get lockTitle => 'Smart Surveillance qulflangan';

  @override
  String get lockUnlock => 'Qulfni ochish';

  @override
  String get lockReason => 'Kameralaringizni koʻrish uchun qulfni oching';

  @override
  String notificationAlertTitle(String site) {
    return 'Signal: $site';
  }

  @override
  String get notificationChannelName => 'Signallar';

  @override
  String get notificationChannelBody => 'Kameralaringizdan signallar';

  @override
  String commonHoursMinutes(int hours, int minutes) {
    return '$hours soat $minutes daqiqa';
  }

  @override
  String get commonShowPassword => 'Parolni koʻrsatish';

  @override
  String get commonHidePassword => 'Parolni yashirish';

  @override
  String get countsInside => 'ichkarida';

  @override
  String get editorAddPoints => 'Burchaklar qoʻshish';

  @override
  String get connectorsVersionLabel => 'Versiya';

  @override
  String get connectorsLastSeen => 'Oxirgi faollik';

  @override
  String get connectorsConnection => 'Ulanish';

  @override
  String get connectorsTunnel => 'Xavfsiz tunnel';

  @override
  String get fieldCodeHelp => 'Xatdagi havolani yoki undagi kodni qoʻying';

  @override
  String get verifyDone => 'Email tasdiqlandi. Davom etish uchun kiring.';

  @override
  String get resetLinkBody => 'Hisobingiz uchun yangi parol tanlang.';

  @override
  String get pairingAddTitle => 'Qanday qoʻshmoqchisiz?';

  @override
  String get pairingAddBody =>
      'Kameraga mos usulni tanlang. Shu obyekt uchun eng yaxshisi birinchi turadi.';

  @override
  String get pairingRecommended => 'Tavsiya etiladi';

  @override
  String get pairingPermissionDenied =>
      'Buning uchun telefon bermagan ruxsat kerak. Uni telefon sozlamalarida yoqing yoki boshqa usulni tanlang.';

  @override
  String get pairingDemoCode => 'Demo koddan foydalanish';

  @override
  String get pairingWaiting => 'Konnektor tasdiqlashi kutilmoqda';

  @override
  String pairingCamerasAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta kamera qoʻshildi',
      one: 'Kamera qoʻshildi',
    );
    return '$_temp0';
  }

  @override
  String get validationConnectorCode => '8 belgili kodni kiriting, masalan ABCD-1234';

  @override
  String get methodConnectorDiscovery => 'Tarmoqdagi kameralar';

  @override
  String get methodConnectorDiscoveryBody => 'Konnektor topgan kameralardan birini tanlang';

  @override
  String get methodLabelQr => 'Kamera yorligʻini skanerlash';

  @override
  String get methodLabelQrBody => 'Kamera yorligʻidagi QR kodga qarating';

  @override
  String get methodManualHost => 'Manzilni kiritish';

  @override
  String get methodManualHostBody => 'Kameraning IP manzilini kiriting, konnektor uni aniqlaydi';

  @override
  String get methodNvrImport => 'Registratordan import qilish';

  @override
  String get methodNvrImportBody => 'NVR yoki DVR kanallarini birdan qoʻshing';

  @override
  String get methodRtspUrl => 'RTSP havolasini qoʻyish';

  @override
  String get methodRtspUrlBody => 'Oqim manzilini beradigan kameralar uchun';

  @override
  String get methodConnectorQr => 'Konnektorning QR kodini skanerlash';

  @override
  String get methodConnectorQrBody => 'Konnektor uni ekranida yoki veb-sahifasida koʻrsatadi';

  @override
  String get methodConnectorMdns => 'Shu Wi-Fi tarmogʻida topish';

  @override
  String get methodConnectorMdnsBody => 'Telefon ulangan tarmoqdagi konnektorlarni qidirish';

  @override
  String get methodConnectorCode => 'Kodni kiritish';

  @override
  String get methodConnectorCodeBody => 'Konnektor koʻrsatadigan 8 belgili kod';

  @override
  String get mdnsTitle => 'Shu Wi-Fi tarmogʻidagi konnektorlar';

  @override
  String get mdnsSearching => 'Bu tarmoqdagi konnektorlar qidirilmoqda';

  @override
  String get mdnsNone =>
      'Konnektor hali topilmadi. Telefon va konnektor bir Wi-Fi tarmogʻida ekanini tekshiring.';

  @override
  String get labelTitle => 'Yorliqni skanerlash';

  @override
  String get labelHint => 'Telefon kamerasini kamera yorligʻidagi QR kodga qarating.';

  @override
  String get labelUnknown => 'Bu yorliq bizga notanish. Kamerani boshqa usul bilan qoʻshing.';

  @override
  String get manualTitle => 'Kamera manzili';

  @override
  String get manualBody =>
      'Konnektor kameradan u qanday model ekanini soʻraydi. Login keyingi bosqichda kiritiladi.';

  @override
  String get manualHost => 'IP manzil yoki host nomi';

  @override
  String get manualPort => 'ONVIF porti, agar odatdagisi boʻlmasa';

  @override
  String get manualIdentify => 'Kamerani aniqlash';

  @override
  String get manualIdentifying => 'Kameradan soʻralmoqda';

  @override
  String get manualNotFound => 'Bu manzilda kamera javob bermadi. Uni tekshirib, qayta urining.';

  @override
  String get rtspTitle => 'RTSP havolasi';

  @override
  String get rtspBody =>
      'Oqim havolasini kameraning qoʻllanmasi yoki ilovasidan qoʻying. Havoladagi login konnektorda saqlanadi.';

  @override
  String get rtspField => 'Oqim havolasi';

  @override
  String get rtspInvalid => 'Bu RTSP havolasi emas.';

  @override
  String get nvrPick => 'Registratorni tanlang';

  @override
  String get nvrNone => 'Registratorlar topilmadi';

  @override
  String get nvrTitle => 'Kanallarni import qilish';

  @override
  String get nvrLogin => 'Registrator logini';

  @override
  String get nvrLoad => 'Kanallarni koʻrsatish';

  @override
  String get nvrChannels => 'Kanallar';

  @override
  String nvrAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta kamera qoʻshish',
      one: '1 ta kamera qoʻshish',
      zero: 'Kanallarni tanlang',
    );
    return '$_temp0';
  }

  @override
  String get nvrOffline => 'Tasvir yoʻq';

  @override
  String get onboardingTestPassed => 'Oqim ishlayapti';

  @override
  String get presetZoneName => 'Butun koʻrinish';

  @override
  String get presetLineName => 'Kirish';

  @override
  String get morePlan => 'Tarif va foydalanish';

  @override
  String get moreActivity => 'Faollik';

  @override
  String get planTitle => 'Tarif va foydalanish';

  @override
  String get planInternal => 'Cheklovsiz ichki tarif';

  @override
  String get planUnlimited => 'Cheklovsiz';

  @override
  String get planLimits => 'Limitlar';

  @override
  String get planUsage => 'Shu oyda';

  @override
  String get planFeatures => 'Imkoniyatlar';

  @override
  String get planIncluded => 'Tarifga kiritilgan';

  @override
  String get planNotIncluded => 'Tarifingizga kirmaydi';

  @override
  String get planUnavailable => 'Tarifingizga kirmaydi. Egasi tarifni oʻzgartira oladi.';

  @override
  String get planSites => 'Obyektlar';

  @override
  String get planCameras => 'Kameralar';

  @override
  String get planMembers => 'Aʼzolar';

  @override
  String get planEventRetention => 'Hodisalarni saqlash';

  @override
  String get planClipRetention => 'Kliplarni saqlash';

  @override
  String get planCameraHours => 'Kameralarning tarmoqdagi soatlari';

  @override
  String get planAnalyticsHours => 'Koʻrinishlarni tahlil qilish soatlari';

  @override
  String get planEvents => 'Hodisalar';

  @override
  String get planClipStorage => 'Kliplar xotirasi';

  @override
  String get planNotifications => 'Yuborilgan bildirishnomalar';

  @override
  String planOf(String used, String limit) {
    return '$used / $limit';
  }

  @override
  String planSince(String date) {
    return '$date dan';
  }

  @override
  String planGigabytes(String value) {
    return '$value GB';
  }

  @override
  String get featureObjects => 'Qoldirilgan va olib ketilgan buyumlar';

  @override
  String get featureJourneys => 'Marshrutlar';

  @override
  String get featureAppearanceSearch => 'Shu odamni topish';

  @override
  String get featureTelegram => 'Telegram signallari';

  @override
  String get telegramTitle => 'Telegram';

  @override
  String get telegramBody => 'Signallarni surat bilan Telegram chatiga yoki guruhiga yuboring.';

  @override
  String get telegramLink => 'Chatni bogʻlash';

  @override
  String get telegramLinkBody =>
      'Telegram botni ochadi. Shaxsiy chatda Start tugmasini bosing yoki botni guruhga qoʻshing, chat shu yerda paydo boʻladi.';

  @override
  String get telegramOpened => 'Telegramda yakunlang va shu yerga qayting.';

  @override
  String get telegramChats => 'Bogʻlangan chatlar';

  @override
  String get telegramNone => 'Hozircha chat bogʻlanmagan';

  @override
  String get telegramGroup => 'Guruh';

  @override
  String get telegramPrivate => 'Shaxsiy chat';

  @override
  String telegramLinked(String when) {
    return 'Bogʻlangan: $when';
  }

  @override
  String get telegramUnlink => 'Uzish';

  @override
  String telegramUnlinkBody(String chat) {
    return 'Signallar $chat ga yuborilmay qoʻyadi.';
  }

  @override
  String get telegramTest => 'Sinov yuborish';

  @override
  String telegramTestSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sinov $count ta chatga yuborildi',
      one: 'Sinov 1 ta chatga yuborildi',
      zero: 'Yuboriladigan chat yoʻq',
    );
    return '$_temp0';
  }

  @override
  String get telegramCannotOpen => 'Bu telefonda Telegramni ochib boʻlmadi.';

  @override
  String get activityTitle => 'Faollik';

  @override
  String get activityEmpty => 'Hozircha faollik yoʻq';

  @override
  String get activityAll => 'Hammasi';

  @override
  String get auditSignIn => 'Kirishlar';

  @override
  String get auditMembers => 'Aʼzolar';

  @override
  String get auditCameras => 'Kameralar';

  @override
  String get auditRules => 'Qoidalar';

  @override
  String get auditArm => 'Qoʻriqlash rejimi';

  @override
  String get auditViews => 'Koʻrish';

  @override
  String get auditExports => 'Eksport';

  @override
  String get auditFaces => 'Yuzlar';

  @override
  String get auditAdmin => 'Platforma';

  @override
  String get actionAuthSignIn => 'Hisobga kirdi';

  @override
  String get actionMemberInvite => 'Aʼzoni taklif qildi';

  @override
  String get actionMemberRole => 'Rolni oʻzgartirdi';

  @override
  String get actionMemberRemove => 'Aʼzoni chiqardi';

  @override
  String get actionCameraAdd => 'Kamera qoʻshdi';

  @override
  String get actionCameraUpdate => 'Kamerani oʻzgartirdi';

  @override
  String get actionCameraDelete => 'Kamerani oʻchirdi';

  @override
  String get actionRulesUpdate => 'Hudud va chiziqlarni oʻzgartirdi';

  @override
  String get actionArmChange => 'Qoʻriqlash rejimini oʻzgartirdi';

  @override
  String get actionLiveView => 'Jonli koʻrdi';

  @override
  String get actionClipView => 'Klipni koʻrdi';

  @override
  String get actionClipExport => 'Klipni ulashdi';

  @override
  String get actionFaceEnrol => 'Yuz suratlarini qoʻshdi';

  @override
  String get actionFaceDelete => 'Yuzlarni oʻchirdi';

  @override
  String get actionOrgPlan => 'Tarifni oʻzgartirdi';

  @override
  String get capabilityNone => 'Bu kamerada koʻrsatiladigan boshqaruv yoʻq.';

  @override
  String eventsAlertCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count ta signal');
    return '$_temp0';
  }

  @override
  String get discoveredImport => 'Import';
}
