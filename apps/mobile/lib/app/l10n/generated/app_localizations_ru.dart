// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Smart Surveillance';

  @override
  String get commonRetry => 'Повторить';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonSaved => 'Сохранено';

  @override
  String get commonDone => 'Готово';

  @override
  String get commonNext => 'Далее';

  @override
  String get commonBack => 'Назад';

  @override
  String get commonContinue => 'Продолжить';

  @override
  String get commonClose => 'Закрыть';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get commonRemove => 'Убрать';

  @override
  String get commonEdit => 'Изменить';

  @override
  String get commonApply => 'Применить';

  @override
  String get commonClear => 'Очистить';

  @override
  String get commonReset => 'Сбросить';

  @override
  String get commonSkip => 'Пока пропустить';

  @override
  String get commonAll => 'Все';

  @override
  String get commonNone => 'Нет';

  @override
  String get commonOn => 'Включено';

  @override
  String get commonOff => 'Выключено';

  @override
  String get commonBeta => 'Бета';

  @override
  String get commonDemo => 'Демо-данные';

  @override
  String get commonLoading => 'Загрузка';

  @override
  String get commonSeeAll => 'Показать все';

  @override
  String get commonOnline => 'В сети';

  @override
  String get commonOffline => 'Не в сети';

  @override
  String get commonUnknown => 'Неизвестно';

  @override
  String get commonToday => 'Сегодня';

  @override
  String get commonYesterday => 'Вчера';

  @override
  String get commonJustNow => 'Только что';

  @override
  String commonMinutesAgo(int count) {
    return '$count мин назад';
  }

  @override
  String commonHoursAgo(int count) {
    return '$count ч назад';
  }

  @override
  String commonDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня назад',
      many: '$count дней назад',
      few: '$count дня назад',
      one: '$count день назад',
    );
    return '$_temp0';
  }

  @override
  String commonSeconds(int count) {
    return '$count с';
  }

  @override
  String commonMinutesSeconds(int minutes, int seconds) {
    return '$minutes мин $seconds с';
  }

  @override
  String commonPercent(String value) {
    return '$value%';
  }

  @override
  String get commonPermissionNeeded => 'Ваша роль не позволяет это сделать.';

  @override
  String get errorNetwork => 'Нет связи с сервером. Проверьте подключение и адрес сервера.';

  @override
  String get errorUnauthorised => 'Неверная почта или пароль.';

  @override
  String get errorForbidden => 'Ваша роль не позволяет это сделать.';

  @override
  String get errorNotFound => 'Этого больше нет.';

  @override
  String get errorConflict => 'Такое уже есть.';

  @override
  String get errorInvalid => 'Проверьте выделенные поля.';

  @override
  String get errorExpired => 'Срок действия кода истек. Запросите новый.';

  @override
  String get errorServer => 'На сервере возникла проблема. Попробуйте через минуту.';

  @override
  String get errorUnknown => 'Что-то пошло не так.';

  @override
  String get errorTitle => 'Не удалось загрузить';

  @override
  String get fieldEmail => 'Электронная почта';

  @override
  String get fieldPassword => 'Пароль';

  @override
  String get fieldName => 'Ваше имя';

  @override
  String get fieldNewPassword => 'Новый пароль';

  @override
  String get fieldCode => 'Код из письма';

  @override
  String get validationEmail => 'Введите действительный адрес почты';

  @override
  String get validationPassword => 'Минимум 8 символов';

  @override
  String get validationRequired => 'Обязательное поле';

  @override
  String get validationCode => 'Введите 6-значный код';

  @override
  String get welcomeTitle => 'Все камеры вашего объекта в кармане';

  @override
  String get welcomeBody =>
      'Смотрите видео в реальном времени, получайте важные тревоги и считайте, кто приходит и уходит: дома, в магазине, офисе или на складе.';

  @override
  String get welcomeCreate => 'Создать аккаунт';

  @override
  String get welcomeSignIn => 'У меня есть аккаунт';

  @override
  String get welcomeFeatureLive => 'Видео в реальном времени с каждой камеры';

  @override
  String get welcomeFeatureAlerts => 'Тревоги о людях, транспорте и вмешательстве';

  @override
  String get welcomeFeatureCounts => 'Подсчет и заполненность по часам';

  @override
  String get signInTitle => 'Вход';

  @override
  String get signInSubtitle => 'С возвращением.';

  @override
  String get signInAction => 'Войти';

  @override
  String get signInForgot => 'Забыли пароль?';

  @override
  String get signInNoAccount => 'Впервые здесь? Создайте аккаунт';

  @override
  String get serverTitle => 'Сервер';

  @override
  String get serverHint => 'Адрес вашего сервера Smart Surveillance';

  @override
  String get serverField => 'Адрес сервера';

  @override
  String get serverDemo => 'Демо-режим показывает примеры данных и не требует сервера.';

  @override
  String get signUpTitle => 'Создать аккаунт';

  @override
  String get signUpSubtitle => 'Один аккаунт для всех ваших объектов.';

  @override
  String get signUpAction => 'Создать аккаунт';

  @override
  String get signUpTerms =>
      'Создавая аккаунт, вы соглашаетесь, что видео с ваших камер обрабатывается на сервере, к которому вы подключаетесь.';

  @override
  String get signUpHaveAccount => 'Уже есть аккаунт? Войдите';

  @override
  String get passwordWeak => 'Слабый';

  @override
  String get passwordFair => 'Средний';

  @override
  String get passwordStrong => 'Надежный';

  @override
  String get verifyTitle => 'Проверьте почту';

  @override
  String verifyBody(String email) {
    return 'Мы отправили 6-значный код на $email. Введите его здесь, чтобы подтвердить адрес.';
  }

  @override
  String get verifyAction => 'Подтвердить почту';

  @override
  String get verifyResend => 'Отправить новый код';

  @override
  String get verifyResent => 'Новый код уже в пути.';

  @override
  String get verifyWrongEmail => 'Другая почта';

  @override
  String get forgotTitle => 'Сброс пароля';

  @override
  String get forgotBody => 'Введите свою почту, и мы отправим код для нового пароля.';

  @override
  String get forgotAction => 'Отправить код';

  @override
  String get resetTitle => 'Новый пароль';

  @override
  String resetBody(String email) {
    return 'Введите код, отправленный на $email, и выберите новый пароль.';
  }

  @override
  String get resetAction => 'Сохранить пароль';

  @override
  String get resetDone => 'Пароль изменен. Войдите с новым паролем.';

  @override
  String get inviteTitle => 'Вас пригласили';

  @override
  String inviteBody(String inviter, String organisation, String role) {
    return '$inviter приглашает вас в $organisation в роли: $role.';
  }

  @override
  String inviteSites(String sites) {
    return 'Объекты: $sites';
  }

  @override
  String get inviteAllSites => 'Все объекты организации';

  @override
  String inviteExpires(String date) {
    return 'Приглашение действует до $date.';
  }

  @override
  String get inviteAccept => 'Принять приглашение';

  @override
  String get inviteSignInFirst =>
      'Сначала войдите или создайте аккаунт, затем откройте ссылку снова.';

  @override
  String inviteAccepted(String organisation) {
    return 'Вы присоединились к $organisation.';
  }

  @override
  String onboardingStep(int step, int total) {
    return 'Шаг $step из $total';
  }

  @override
  String get onboardingSiteTitle => 'Настройте первый объект';

  @override
  String get onboardingSiteBody =>
      'Объект - это одно место с камерами: ваш дом, магазин, офис или склад. Позже можно добавить другие объекты.';

  @override
  String get fieldOrganisation => 'Название организации';

  @override
  String get fieldOrganisationHint => 'Ваша семья или компания';

  @override
  String get fieldSiteName => 'Название объекта';

  @override
  String get fieldSiteNameHint => 'Например, Дом или Магазин на главной улице';

  @override
  String get fieldSiteKind => 'Тип объекта';

  @override
  String get fieldTimezone => 'Часовой пояс';

  @override
  String get onboardingConnectorTitle => 'Подключите коннектор';

  @override
  String get onboardingConnectorBody =>
      'Коннектор - это небольшая программа, которая работает на любом постоянно включенном компьютере на объекте, например на мини-ПК или Raspberry Pi. Она находит камеры и безопасно соединяет их с сервером.';

  @override
  String get onboardingConnectorStep1 =>
      'Установите Docker на компьютер, который на объекте всегда включен.';

  @override
  String get onboardingConnectorStep2 => 'Запустите коннектор командой из документации сервера.';

  @override
  String get onboardingConnectorStep3 =>
      'Коннектор покажет QR-код и 8-значный код. Отсканируйте его или введите здесь.';

  @override
  String get onboardingScan => 'Сканировать QR-код';

  @override
  String get onboardingTypeCode => 'Ввести код';

  @override
  String get fieldConnectorCode => 'Код коннектора';

  @override
  String get fieldConnectorName => 'Название коннектора';

  @override
  String get onboardingPair => 'Подключить коннектор';

  @override
  String onboardingPaired(String name, String site) {
    return '$name подключен к объекту $site.';
  }

  @override
  String get scanTitle => 'Сканирование кода коннектора';

  @override
  String get scanHint => 'Наведите камеру на QR-код на экране коннектора.';

  @override
  String get scanNoPermission =>
      'Разрешите доступ к камере для сканирования или введите код вручную.';

  @override
  String get scanAllow => 'Разрешить камеру';

  @override
  String get onboardingCamerasTitle => 'Камеры в сети';

  @override
  String get onboardingCamerasBody =>
      'Коннектор поискал камеры в своей сети. Выберите камеру, чтобы добавить ее.';

  @override
  String get onboardingSearching => 'Поиск камер';

  @override
  String get onboardingRescan => 'Искать снова';

  @override
  String get onboardingNoCameras => 'Камер пока нет';

  @override
  String get onboardingNoCamerasBody =>
      'Убедитесь, что камеры включены и находятся в одной сети с коннектором, затем повторите поиск.';

  @override
  String get onboardingAdded => 'Добавлена';

  @override
  String get onboardingAddCamera => 'Добавить';

  @override
  String get onboardingFinish => 'Завершить настройку';

  @override
  String get onboardingCameraTitle => 'Добавить камеру';

  @override
  String get onboardingCameraBody =>
      'Введите логин, который камера использует для видео. Он хранится на коннекторе в зашифрованном виде и не попадает на сервер.';

  @override
  String get fieldCameraUser => 'Имя пользователя камеры';

  @override
  String get fieldCameraPassword => 'Пароль камеры';

  @override
  String get fieldCameraName => 'Название камеры';

  @override
  String get fieldCameraNameHint => 'Например, Входная дверь';

  @override
  String get fieldLenses => 'Изображений в одном потоке';

  @override
  String get lensesOne => 'Одно изображение';

  @override
  String get lensesTwo => 'Два объектива друг над другом';

  @override
  String get onboardingTest => 'Проверить поток';

  @override
  String get onboardingTesting => 'Подключение к камере';

  @override
  String onboardingTestOk(String codec, int width, int height) {
    return 'Поток работает: $codec, $width на $height';
  }

  @override
  String get onboardingTestFailed => 'Камера отклонила вход. Проверьте имя пользователя и пароль.';

  @override
  String get onboardingSaveCamera => 'Сохранить камеру';

  @override
  String get onboardingAnalyticsTitle => 'За чем должна следить эта камера?';

  @override
  String onboardingAnalyticsBody(String camera) {
    return 'Выберите начальный вариант для камеры $camera. Зоны и линии можно нарисовать, а любые параметры изменить позже.';
  }

  @override
  String get presetPerimeter => 'Периметр';

  @override
  String get presetPerimeterBody =>
      'Тревога, когда люди или транспорт попадают в кадр ночью или в ваше отсутствие.';

  @override
  String get presetEntrance => 'Вход';

  @override
  String get presetEntranceBody => 'Считает, кто входит и выходит через дверь или ворота.';

  @override
  String get presetCounting => 'Подсчет';

  @override
  String get presetCountingBody =>
      'Считает людей и заполненность без тревог, для магазинов и офисов.';

  @override
  String get presetTamper => 'Только вмешательство';

  @override
  String get presetTamperBody =>
      'Сообщает только о том, что камеру закрыли, размыли, сдвинули или стало слишком темно.';

  @override
  String get onboardingNotificationsTitle => 'Тревоги на этом телефоне';

  @override
  String get onboardingNotificationsBody =>
      'Разрешите уведомления, чтобы приложение сообщало о тревогах, пока оно закрыто. В уведомлениях нет изображений: приложение безопасно загружает их, когда вы открываете уведомление.';

  @override
  String get onboardingNotificationsAllow => 'Разрешить уведомления';

  @override
  String get onboardingDoneTitle => 'Объект готов';

  @override
  String get onboardingDoneBody =>
      'Камеры работают. Тревоги зависят от режима охраны, который можно изменить на вкладке Главная.';

  @override
  String get onboardingOpenHome => 'Открыть главную';

  @override
  String get navHome => 'Главная';

  @override
  String get navLive => 'Эфир';

  @override
  String get navEvents => 'События';

  @override
  String get navSearch => 'Поиск';

  @override
  String get navMore => 'Еще';

  @override
  String get siteKindHome => 'Дом';

  @override
  String get siteKindStore => 'Магазин';

  @override
  String get siteKindOffice => 'Офис';

  @override
  String get siteKindWarehouse => 'Склад';

  @override
  String get siteKindOther => 'Другое';

  @override
  String get siteSwitcherTitle => 'Объекты';

  @override
  String get siteSwitcherAdd => 'Добавить объект';

  @override
  String siteCameras(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count камеры',
      many: '$count камер',
      few: '$count камеры',
      one: '$count камера',
      zero: 'Нет камер',
    );
    return '$_temp0';
  }

  @override
  String get armDisarmed => 'Снято с охраны';

  @override
  String get armHome => 'Дома';

  @override
  String get armAway => 'Нет дома';

  @override
  String get armSchedule => 'По расписанию';

  @override
  String get armDisarmedBody => 'Тревог нет. События по-прежнему записываются.';

  @override
  String get armHomeBody => 'Тревоги только из зон и линий, которые сигналят, пока вы дома.';

  @override
  String get armAwayBody => 'Сигналят все зоны и линии.';

  @override
  String get armScheduleBody => 'Каждая зона и линия сигналит по своему расписанию.';

  @override
  String get armTitle => 'Режим охраны';

  @override
  String armChanged(String mode) {
    return 'Режим охраны: $mode';
  }

  @override
  String get homeAlertsToday => 'Тревоги сегодня';

  @override
  String homeUnacknowledged(int count) {
    return 'К просмотру: $count';
  }

  @override
  String get homeAllReviewed => 'Все просмотрено';

  @override
  String get homeEventsToday => 'События сегодня';

  @override
  String get homeCamerasOnline => 'Камеры в сети';

  @override
  String homeCamerasValue(int online, int total) {
    return '$online из $total';
  }

  @override
  String get homeOccupancy => 'Сейчас внутри';

  @override
  String get homeRecent => 'Последние события';

  @override
  String get homeAttention => 'Требует внимания';

  @override
  String get homeAllGood => 'Все камеры и коннекторы в сети';

  @override
  String homeCameraOffline(String camera) {
    return '$camera не в сети';
  }

  @override
  String homeConnectorOffline(String connector, String when) {
    return '$connector не в сети, был в сети: $when';
  }

  @override
  String homeConnectorOnline(String connector, String version) {
    return '$connector в сети, версия $version';
  }

  @override
  String get homeCountsToday => 'Посетители сегодня';

  @override
  String get homeCountsIn => 'Вход';

  @override
  String get homeCountsOut => 'Выход';

  @override
  String get homeNoSite => 'Объектов пока нет';

  @override
  String get homeNoSiteBody =>
      'Настройте объект и подключите его коннектор, чтобы начать наблюдение.';

  @override
  String get homeSetUp => 'Настроить объект';

  @override
  String get homeNoEvents => 'Сегодня пока тихо';

  @override
  String get liveTitle => 'Эфир';

  @override
  String get liveLayoutAuto => 'Автоматически';

  @override
  String get liveLayoutOne => 'Один столбец';

  @override
  String get liveLayoutTwo => 'Два на два';

  @override
  String get liveLayoutThree => 'Три на три';

  @override
  String get liveLayout => 'Сетка';

  @override
  String get liveNoCameras => 'Камер пока нет';

  @override
  String get liveNoCamerasBody =>
      'Добавьте камеры через подключенный коннектор, и они появятся здесь.';

  @override
  String get liveAddCamera => 'Добавить камеру';

  @override
  String get liveConnecting => 'Подключение';

  @override
  String get liveFailed => 'Видео недоступно';

  @override
  String get liveCameraOffline => 'Камера не в сети';

  @override
  String get liveBadge => 'Эфир';

  @override
  String liveLens(int lens) {
    return 'Объектив $lens';
  }

  @override
  String get cameraMain => 'Основной';

  @override
  String get cameraSub => 'Второй поток';

  @override
  String get cameraQuality => 'Поток';

  @override
  String get cameraSound => 'Звук';

  @override
  String get cameraBoxes => 'Показывать обнаружения';

  @override
  String get cameraFullscreen => 'На весь экран';

  @override
  String get cameraSnapshot => 'Снимок';

  @override
  String get cameraSnapshotSaved => 'Снимок сохранен';

  @override
  String get cameraPtz => 'Поворот и наклон';

  @override
  String get cameraSpeed => 'Скорость';

  @override
  String get cameraZoomIn => 'Приблизить';

  @override
  String get cameraZoomOut => 'Отдалить';

  @override
  String get cameraHome => 'Исходное положение';

  @override
  String get cameraPresets => 'Пресеты';

  @override
  String get cameraNoPresets => 'Пресетов пока нет';

  @override
  String get cameraSavePreset => 'Сохранить положение';

  @override
  String get cameraPresetName => 'Название пресета';

  @override
  String get cameraLight => 'Свет';

  @override
  String get cameraSiren => 'Сирена';

  @override
  String get cameraSirenConfirm => 'Включить сирену на 10 секунд?';

  @override
  String get cameraSirenOn => 'Сирена звучит';

  @override
  String get cameraRecent => 'Недавнее на этой камере';

  @override
  String get cameraSettings => 'Настройки камеры';

  @override
  String get cameraAnalytics => 'Аналитика';

  @override
  String get ptzUp => 'Наклон вверх';

  @override
  String get ptzDown => 'Наклон вниз';

  @override
  String get ptzLeft => 'Поворот влево';

  @override
  String get ptzRight => 'Поворот вправо';

  @override
  String get eventsTitle => 'События';

  @override
  String get eventsAlertsOnly => 'Только тревоги';

  @override
  String get eventsFilters => 'Фильтры';

  @override
  String eventsFilterCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count фильтра',
      many: '$count фильтров',
      few: '$count фильтра',
      one: '$count фильтр',
    );
    return '$_temp0';
  }

  @override
  String eventsNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count новых события',
      many: '$count новых событий',
      few: '$count новых события',
      one: '$count новое событие',
    );
    return '$_temp0';
  }

  @override
  String get eventsEmpty => 'Нет событий';

  @override
  String get eventsEmptyBody => 'Ничего не найдено. Выберите другой день или уберите фильтры.';

  @override
  String get eventsEmptyToday =>
      'Пока ничего не произошло. События появятся здесь, как только их заметят камеры.';

  @override
  String get eventsAckAll => 'Отметить все просмотренными';

  @override
  String eventsAckAllDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Просмотрено $count тревоги',
      many: 'Просмотрено $count тревог',
      few: 'Просмотрено $count тревоги',
      one: 'Просмотрена $count тревога',
      zero: 'Просматривать нечего',
    );
    return '$_temp0';
  }

  @override
  String eventsTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count события',
      many: '$count событий',
      few: '$count события',
      one: '$count событие',
      zero: 'Нет событий',
    );
    return '$_temp0';
  }

  @override
  String get eventsLoadMore => 'Загрузить еще';

  @override
  String get filterDay => 'День';

  @override
  String get filterAnyDay => 'Любой день';

  @override
  String get filterCameras => 'Камеры';

  @override
  String get filterViews => 'Обзоры';

  @override
  String get filterKinds => 'Типы';

  @override
  String get filterLabels => 'Объекты';

  @override
  String get filterZones => 'Зоны';

  @override
  String get filterLines => 'Линии';

  @override
  String get filterPerson => 'Человек';

  @override
  String get filterPlate => 'Номер';

  @override
  String get filterTime => 'Время';

  @override
  String get filterShow => 'Показать результаты';

  @override
  String get eventAlert => 'Тревога';

  @override
  String get eventReviewed => 'Просмотрено';

  @override
  String get eventOngoing => 'Продолжается';

  @override
  String get eventAcknowledge => 'Отметить просмотренным';

  @override
  String get eventAcknowledged => 'Отмечено просмотренным';

  @override
  String get eventShareClip => 'Поделиться клипом';

  @override
  String get eventClip => 'Клип';

  @override
  String get eventNoClip => 'У этого события нет клипа.';

  @override
  String get eventSnapshot => 'Снимок';

  @override
  String get eventDetails => 'Подробности';

  @override
  String get eventCamera => 'Камера';

  @override
  String get eventView => 'Обзор';

  @override
  String get eventZone => 'Зона';

  @override
  String get eventLine => 'Линия';

  @override
  String get eventDirection => 'Направление';

  @override
  String get eventDirectionIn => 'Вход';

  @override
  String get eventDirectionOut => 'Выход';

  @override
  String get eventObjects => 'Объекты';

  @override
  String get eventDuration => 'Длительность';

  @override
  String get eventStarted => 'Начало';

  @override
  String get eventSource => 'Источник';

  @override
  String get eventSourceCamera => 'Камера';

  @override
  String get eventSourceAnalytics => 'Аналитика';

  @override
  String get eventFace => 'Лицо';

  @override
  String eventConfidence(int value) {
    return 'Совпадение $value%';
  }

  @override
  String get eventPlate => 'Номерной знак';

  @override
  String eventPlateReads(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count считывания',
      many: '$count считываний',
      few: '$count считывания',
      one: '$count считывание',
    );
    return '$_temp0';
  }

  @override
  String get plateInfrared => 'Ночью не считан: инфракрасный свет бликует на номере.';

  @override
  String get plateNone => 'Номер на транспорте не найден.';

  @override
  String get plateSmall => 'Номер слишком мелкий для считывания.';

  @override
  String get plateUnreadable => 'Номер не удалось считать.';

  @override
  String get platePending => 'Считывание номера.';

  @override
  String get eventJourney => 'Маршрут';

  @override
  String get eventFindPerson => 'Найти этого человека';

  @override
  String get eventWhoIsThis => 'Кто это?';

  @override
  String get eventDemoClip => 'Демо-клип';

  @override
  String get kindMotion => 'Движение';

  @override
  String get kindPerson => 'Человек';

  @override
  String get kindVehicle => 'Транспорт';

  @override
  String get kindIntrusion => 'Проникновение';

  @override
  String get kindLineCrossing => 'Пересечение линии';

  @override
  String get kindLoitering => 'Задержка';

  @override
  String get kindCrowd => 'Скопление';

  @override
  String get kindFaceKnown => 'Знакомое лицо';

  @override
  String get kindFaceUnknown => 'Незнакомое лицо';

  @override
  String get kindTamper => 'Вмешательство';

  @override
  String get kindStorage => 'Хранилище';

  @override
  String get kindReboot => 'Перезапуск';

  @override
  String get kindAnimal => 'Животное';

  @override
  String get kindObjectLeft => 'Оставленный предмет';

  @override
  String get kindObjectTaken => 'Забранный предмет';

  @override
  String get kindFall => 'Падение';

  @override
  String titleMotion(String camera) {
    return '$camera: движение';
  }

  @override
  String titlePerson(String camera) {
    return '$camera: человек';
  }

  @override
  String titleVehicle(String label, String camera) {
    return '$camera: $label';
  }

  @override
  String titleIntrusion(String label, String zone) {
    return '$label: вход в зону $zone';
  }

  @override
  String titleLineCrossing(String label, String line) {
    return '$label: пересечение линии $line';
  }

  @override
  String titleLoitering(String label, String zone) {
    return '$label: задержка в зоне $zone';
  }

  @override
  String titleCrowd(String zone) {
    return 'Скопление в зоне $zone';
  }

  @override
  String titleFaceKnown(String name) {
    return 'В кадре: $name';
  }

  @override
  String titleFaceUnknown(String label) {
    return 'В кадре: $label';
  }

  @override
  String titleTamper(String camera, String how) {
    return 'Обзор камеры $camera: $how';
  }

  @override
  String titleAnimal(String label, String camera) {
    return '$camera: $label';
  }

  @override
  String titleObjectLeft(String label, String zone) {
    return 'В зоне $zone оставлено: $label';
  }

  @override
  String titleObjectTaken(String label, String zone) {
    return 'Из зоны $zone взято: $label';
  }

  @override
  String titleFall(String camera) {
    return '$camera: возможное падение';
  }

  @override
  String titleStorage(String camera) {
    return '$camera: проблема с хранилищем';
  }

  @override
  String titleReboot(String camera) {
    return '$camera: перезапуск';
  }

  @override
  String get tamperCovered => 'закрыт';

  @override
  String get tamperBlurred => 'размыт';

  @override
  String get tamperDark => 'слишком темный';

  @override
  String get tamperMoved => 'сдвинут';

  @override
  String get tamperDisturbed => 'нарушен';

  @override
  String get labelPerson => 'Человек';

  @override
  String get labelCar => 'Легковой автомобиль';

  @override
  String get labelTruck => 'Грузовик';

  @override
  String get labelBus => 'Автобус';

  @override
  String get labelMotorcycle => 'Мотоцикл';

  @override
  String get labelBicycle => 'Велосипед';

  @override
  String get labelDog => 'Собака';

  @override
  String get labelCat => 'Кошка';

  @override
  String get labelBird => 'Птица';

  @override
  String get labelBackpack => 'Рюкзак';

  @override
  String get labelHandbag => 'Сумка';

  @override
  String get labelSuitcase => 'Чемодан';

  @override
  String get labelVehicle => 'Транспорт';

  @override
  String get labelAnimal => 'Животное';

  @override
  String get labelSomething => 'Что-то';

  @override
  String get labelObject => 'Предмет';

  @override
  String get searchTitle => 'Поиск';

  @override
  String get searchEvents => 'События';

  @override
  String get searchPeople => 'Люди';

  @override
  String get searchFaces => 'Лица';

  @override
  String get searchPlates => 'Номера';

  @override
  String get searchFrom => 'С';

  @override
  String get searchUntil => 'По';

  @override
  String get searchLast24h => 'Последние 24 часа';

  @override
  String get searchLast7d => 'Последние 7 дней';

  @override
  String get searchLast30d => 'Последние 30 дней';

  @override
  String get searchRun => 'Найти';

  @override
  String searchResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count результата',
      many: '$count результатов',
      few: '$count результата',
      one: '$count результат',
      zero: 'Нет результатов',
    );
    return '$_temp0';
  }

  @override
  String get searchHint => 'Составьте запрос по времени, камерам, типам и объектам.';

  @override
  String get searchFacesTitle => 'Найти лицо';

  @override
  String get searchFacesBody =>
      'Выберите фото с одним лицом или нажмите на лицо, которое видели камеры, чтобы найти, где оно появлялось.';

  @override
  String get searchFacesPhoto => 'Выбрать фото';

  @override
  String get searchFacesCamera => 'Сделать фото';

  @override
  String get searchFacesResults => 'Похожие лица';

  @override
  String get searchPlatesTitle => 'Найти транспорт по номеру';

  @override
  String get searchPlatesHint => 'Текст номера, например 01 A 123 BC';

  @override
  String get searchPlatesBody =>
      'Номера считываются днем на обзорах, где включено считывание номеров.';

  @override
  String get facesOffTitle => 'Распознавание лиц выключено';

  @override
  String get facesOffBody =>
      'Владелец или администратор может включить его для организации в разделе Еще, Лица.';

  @override
  String get facesTurnOn => 'Открыть настройки лиц';

  @override
  String get peopleKnown => 'Знакомые люди';

  @override
  String get peopleUnknown => 'Незнакомые лица';

  @override
  String get peopleAdd => 'Добавить человека';

  @override
  String get peopleEmpty => 'Людей пока нет';

  @override
  String get peopleEmptyBody =>
      'Добавьте знакомых людей или назовите незнакомые лица, которые собирают камеры.';

  @override
  String peopleSeen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Замечен $count раза',
      many: 'Замечен $count раз',
      few: 'Замечен $count раза',
      one: 'Замечен $count раз',
    );
    return '$_temp0';
  }

  @override
  String peopleLastSeen(String when) {
    return 'Последний раз: $when';
  }

  @override
  String get peopleNeverSeen => 'Пока не замечен';

  @override
  String get peopleSamples => 'Лица';

  @override
  String get peopleSightings => 'Появления';

  @override
  String get peopleNoSightings => 'Появлений пока нет';

  @override
  String get peopleAddPhotos => 'Добавить фото';

  @override
  String peoplePhotosAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Добавлено $count фото',
      many: 'Добавлено $count фото',
      few: 'Добавлено $count фото',
      one: 'Добавлено $count фото',
      zero: 'Фото не добавлено',
    );
    return '$_temp0';
  }

  @override
  String peoplePhotosRejected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'На $count фото нет одного четкого лица',
      many: 'На $count фото нет одного четкого лица',
      few: 'На $count фото нет одного четкого лица',
      one: 'На $count фото нет одного четкого лица',
    );
    return '$_temp0';
  }

  @override
  String get peopleMerge => 'Объединить с другим человеком';

  @override
  String peopleMergeTitle(String name) {
    return 'Объединить $name с';
  }

  @override
  String get peopleDelete => 'Удалить человека';

  @override
  String peopleDeleteBody(String name) {
    return 'Будет удален $name со всеми образцами и кадрами лица. Прошлые события сохранят свои снимки.';
  }

  @override
  String get peopleNotes => 'Заметки';

  @override
  String get peopleName => 'Имя';

  @override
  String get clusterWhoTitle => 'Кто это?';

  @override
  String get clusterWhoBody =>
      'Назовите нового человека или выберите знакомого. Его прошлые события получат новую подпись.';

  @override
  String get clusterNewPerson => 'Новый человек';

  @override
  String get clusterExisting => 'Кто-то из знакомых';

  @override
  String clusterNamed(String name) {
    return 'Назван: $name';
  }

  @override
  String get clusterDelete => 'Забыть эти лица';

  @override
  String get clusterDeleteBody =>
      'Образцы незнакомых лиц будут удалены. Прошлые события сохранят свои снимки.';

  @override
  String get findPersonTitle => 'Найти этого человека';

  @override
  String get findPersonBody =>
      'Появления на других камерах, похожие на этого человека по одежде и сложению. Дневные и ночные кадры друг с другом не сопоставляются.';

  @override
  String get findPersonEmpty => 'Похожих появлений не найдено';

  @override
  String findPersonMatch(int value) {
    return 'Сходство $value%';
  }

  @override
  String get moreTitle => 'Еще';

  @override
  String get moreSite => 'Этот объект';

  @override
  String get moreOrganisation => 'Организация';

  @override
  String get moreYou => 'Вы';

  @override
  String get moreCounts => 'Подсчет и заполненность';

  @override
  String get moreSiteSettings => 'Настройки объекта';

  @override
  String get moreCameras => 'Камеры';

  @override
  String get moreAnalytics => 'Аналитика';

  @override
  String get moreConnectors => 'Коннекторы';

  @override
  String get moreHealth => 'Состояние';

  @override
  String get moreMembers => 'Участники';

  @override
  String get moreFaces => 'Лица';

  @override
  String get moreNotifications => 'Уведомления';

  @override
  String get moreAccount => 'Аккаунт';

  @override
  String get moreAppearance => 'Язык и тема';

  @override
  String get moreAbout => 'О приложении';

  @override
  String get moreSignOut => 'Выйти';

  @override
  String get moreSignOutConfirm => 'Выйти на этом телефоне?';

  @override
  String get countsTitle => 'Подсчет';

  @override
  String get countsHourly => 'По часам';

  @override
  String get countsDaily => 'По дням';

  @override
  String get countsIn => 'Вход';

  @override
  String get countsOut => 'Выход';

  @override
  String countsTotalIn(int count) {
    return 'Вошли: $count';
  }

  @override
  String countsTotalOut(int count) {
    return 'Вышли: $count';
  }

  @override
  String get countsNoLines => 'Нет линий подсчета';

  @override
  String get countsNoLinesBody =>
      'Проведите линию на обзоре в разделе Аналитика, чтобы считать людей и транспорт, пересекающих ее.';

  @override
  String get countsAreas => 'Помещения';

  @override
  String countsOccupancy(int count) {
    return 'Внутри: $count';
  }

  @override
  String countsCapacity(int count) {
    return 'из $count';
  }

  @override
  String countsSince(int entered, int exited, String time) {
    return 'Вошли $entered, вышли $exited с $time';
  }

  @override
  String get countsReset => 'Задать заполненность';

  @override
  String get countsResetTitle => 'Сколько человек внутри сейчас?';

  @override
  String countsResetDone(int count) {
    return 'Заполненность: $count';
  }

  @override
  String countsDailyReset(String time) {
    return 'Сбрасывается каждый день в $time';
  }

  @override
  String countsPeak(String hour) {
    return 'Самый загруженный час: $hour';
  }

  @override
  String get siteSettingsTitle => 'Настройки объекта';

  @override
  String get siteRetention => 'Хранить события';

  @override
  String siteRetentionDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня',
      many: '$count дней',
      few: '$count дня',
      one: '$count день',
    );
    return '$_temp0';
  }

  @override
  String get siteArmHelp =>
      'Режим охраны определяет, какие события дают тревогу. В режиме По расписанию каждая зона и линия следует своим часам тревоги, которые задаются в разделе Аналитика.';

  @override
  String get camerasTitle => 'Камеры';

  @override
  String get camerasReorder => 'Перетащите, чтобы изменить порядок в эфире.';

  @override
  String get camerasAdd => 'Добавить камеру';

  @override
  String get camerasDelete => 'Удалить камеру';

  @override
  String camerasDeleteBody(String camera) {
    return 'Камера $camera будет удалена вместе с обзорами, зонами и линиями. Ее прошлые события хранятся до истечения срока.';
  }

  @override
  String get camerasEnabled => 'Включена';

  @override
  String get camerasNoConnector => 'Сначала подключите коннектор';

  @override
  String get camerasNoConnectorBody => 'Камеры находятся и добавляются через коннектор на объекте.';

  @override
  String get settingsDevice => 'Устройство';

  @override
  String get settingsManufacturer => 'Производитель';

  @override
  String get settingsModel => 'Модель';

  @override
  String get settingsFirmware => 'Прошивка';

  @override
  String get settingsVideo => 'Видео';

  @override
  String get settingsImage => 'Изображение';

  @override
  String get settingsBrightness => 'Яркость';

  @override
  String get settingsContrast => 'Контрастность';

  @override
  String get settingsSaturation => 'Насыщенность';

  @override
  String get settingsSharpness => 'Резкость';

  @override
  String get settingsIrCut => 'Фильтр ночного режима';

  @override
  String get settingsMotion => 'Детекция движения в камере';

  @override
  String get settingsSensitivity => 'Чувствительность';

  @override
  String get settingsClock => 'Часы';

  @override
  String settingsClockOffset(String value) {
    return '$value с от сервера';
  }

  @override
  String get settingsSyncClock => 'Синхронизировать часы';

  @override
  String get settingsClockSynced => 'Часы синхронизированы';

  @override
  String get settingsReboot => 'Перезапустить камеру';

  @override
  String get settingsRebootBody => 'Видео с камеры пропадет примерно на минуту.';

  @override
  String get settingsRebooting => 'Камера перезапускается';

  @override
  String get settingsUnsupported => 'Эта камера не поддерживает такую настройку.';

  @override
  String get analyticsTitle => 'Аналитика';

  @override
  String get analyticsViewsBody =>
      'Каждый объектив - это обзор. Выберите, за чем он следит, и нарисуйте его зоны и линии.';

  @override
  String analyticsZonesLines(int zones, int lines) {
    String _temp0 = intl.Intl.pluralLogic(
      zones,
      locale: localeName,
      other: '$zones зоны',
      many: '$zones зон',
      few: '$zones зоны',
      one: '$zones зона',
      zero: 'Нет зон',
    );
    String _temp1 = intl.Intl.pluralLogic(
      lines,
      locale: localeName,
      other: '$lines линии',
      many: '$lines линий',
      few: '$lines линии',
      one: '$lines линия',
      zero: 'линий нет',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String get analyticsDisabled => 'Аналитика выключена';

  @override
  String analyticsFps(String value) {
    return '$value fps';
  }

  @override
  String get analyticsSuspended => 'Объектив повернут от своих зон';

  @override
  String get analyticsEnabled => 'Анализировать этот обзор';

  @override
  String get analyticsProfile => 'Профиль';

  @override
  String get profilePerimeter => 'Периметр';

  @override
  String get profileVehicle => 'Транспорт';

  @override
  String get profileIdentity => 'Личность';

  @override
  String get profileTamper => 'Только вмешательство';

  @override
  String get analyticsStream => 'Анализируемый поток';

  @override
  String get analyticsStreamSub => 'Второй поток, для обнаружения и подсчета';

  @override
  String get analyticsStreamMain => 'Основной поток, для лиц и номеров';

  @override
  String get analyticsFeatures => 'Возможности';

  @override
  String get featureTamper => 'Контроль вмешательства';

  @override
  String get featureTamperBody => 'Закрыта, размыта, сдвинута и слишком темно';

  @override
  String get featureFaces => 'Лица';

  @override
  String get featureFacesBody => 'Называть знакомых, собирать незнакомые лица';

  @override
  String get featureFacesLocked => 'Сначала включите лица для организации';

  @override
  String get featureAppearance => 'Маршруты';

  @override
  String get featureAppearanceBody => 'Связывать человека между камерами по внешнему виду';

  @override
  String get featureFalls => 'Падения';

  @override
  String get featureFallsBody => 'Тревога, если человек упал и не встает';

  @override
  String get featurePlates => 'Номерные знаки';

  @override
  String get featurePlatesBody => 'Считывать номера при событиях с транспортом днем';

  @override
  String get featureFollow => 'Автослежение';

  @override
  String get featureFollowBody =>
      'Поворачивать объектив, чтобы держать человека в кадре, затем возвращаться';

  @override
  String get featureMoving => 'Подвижный объектив';

  @override
  String get featureMovingBody => 'Зоны остаются на том изображении, на котором были нарисованы';

  @override
  String get analyticsRules => 'Зоны и линии';

  @override
  String get analyticsEdit => 'Нарисовать зоны и линии';

  @override
  String get analyticsNoRules => 'Зон и линий пока нет';

  @override
  String get analyticsWholeView => 'Весь обзор';

  @override
  String get editorTitle => 'Зоны и линии';

  @override
  String get editorZone => 'Зона';

  @override
  String get editorLine => 'Линия';

  @override
  String get editorAddZone => 'Новая зона';

  @override
  String get editorAddLine => 'Новая линия';

  @override
  String get editorHintZone =>
      'Нажимайте на изображение, чтобы ставить углы. Перетащите угол, чтобы сдвинуть его.';

  @override
  String get editorHintLine => 'Нажмите две точки для линии. Стрелка показывает сторону внутрь.';

  @override
  String get editorUndo => 'Отменить точку';

  @override
  String get editorFlip => 'Сменить направление';

  @override
  String get editorDelete => 'Удалить фигуру';

  @override
  String get editorDiscard => 'Отменить изменения?';

  @override
  String get editorDiscardBody => 'Ваши зоны и линии еще не сохранены.';

  @override
  String get editorKeepEditing => 'Продолжить правку';

  @override
  String get editorSaved => 'Зоны и линии сохранены. Они применятся через несколько секунд.';

  @override
  String get editorNameZone => 'Название зоны';

  @override
  String get editorNameLine => 'Название линии';

  @override
  String get editorObjects => 'Следить за';

  @override
  String get editorDwell => 'Минимальное время внутри';

  @override
  String get editorLoiter => 'Задержка после';

  @override
  String get editorCrowd => 'Скопление от';

  @override
  String editorCrowdPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count человека',
      many: '$count человек',
      few: '$count человека',
      one: '$count человек',
      zero: 'Выключено',
    );
    return '$_temp0';
  }

  @override
  String get editorLeft => 'Предмет оставлен после';

  @override
  String get editorTaken => 'Предмет забран после';

  @override
  String get editorAlerts => 'Тревоги';

  @override
  String get editorAlertOff => 'Никогда';

  @override
  String get editorAlertAlways => 'Всегда';

  @override
  String get editorAlertSchedule => 'По расписанию';

  @override
  String editorAlertHours(String start, String end) {
    return 'Тревога с $start до $end';
  }

  @override
  String get editorAnimals => 'Животные';

  @override
  String get editorAnimalsInclude => 'Тревога';

  @override
  String get editorAnimalsRecord => 'Только запись';

  @override
  String get editorAnimalsExclude => 'Игнорировать';

  @override
  String get editorDirection => 'Направление подсчета';

  @override
  String get editorDirectionIn => 'Внутрь';

  @override
  String get editorDirectionOut => 'Наружу';

  @override
  String get editorDirectionBoth => 'В обе стороны';

  @override
  String get editorDurationOff => 'Выключено';

  @override
  String get editorEnabled => 'Активна';

  @override
  String get editorTooFewPoints => 'В зоне должно быть не менее 3 углов.';

  @override
  String get connectorsTitle => 'Коннекторы';

  @override
  String get connectorsPair => 'Подключить коннектор';

  @override
  String get connectorsEmpty => 'Коннекторов пока нет';

  @override
  String get connectorsEmptyBody =>
      'Коннектор на объекте находит камеры и связывает их с сервером.';

  @override
  String connectorsVersion(String version) {
    return 'Версия $version';
  }

  @override
  String connectorsSeen(String when) {
    return 'В сети: $when';
  }

  @override
  String get connectorsRemove => 'Удалить коннектор';

  @override
  String get connectorsRemoveBody =>
      'Его камеры перестанут работать, пока к объекту не подключат другой коннектор.';

  @override
  String get connectorsMode => 'Прямое подключение';

  @override
  String get connectorsFind => 'Найти камеры';

  @override
  String get membersTitle => 'Участники';

  @override
  String get membersInvite => 'Пригласить';

  @override
  String get membersInvited => 'Приглашен';

  @override
  String get membersYou => 'Вы';

  @override
  String get membersAllSites => 'Все объекты';

  @override
  String membersSomeSites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count объекта',
      many: '$count объектов',
      few: '$count объекта',
      one: '$count объект',
    );
    return '$_temp0';
  }

  @override
  String get membersPending => 'Ожидающие приглашения';

  @override
  String membersExpires(String date) {
    return 'Действует до $date';
  }

  @override
  String get membersRevoke => 'Отозвать приглашение';

  @override
  String get membersRemove => 'Убрать из организации';

  @override
  String membersRemoveBody(String name) {
    return '$name сразу теряет доступ ко всем объектам организации.';
  }

  @override
  String get membersRole => 'Роль';

  @override
  String get membersSites => 'Объекты';

  @override
  String get membersInviteTitle => 'Пригласить участника';

  @override
  String get membersInviteBody =>
      'Он получит письмо со ссылкой, которая работает один раз в течение 7 дней.';

  @override
  String membersInviteSent(String email) {
    return 'Приглашение отправлено на $email';
  }

  @override
  String get roleOwner => 'Владелец';

  @override
  String get roleAdmin => 'Администратор';

  @override
  String get roleOperator => 'Оператор';

  @override
  String get roleViewer => 'Наблюдатель';

  @override
  String get roleOwnerBody => 'Все, включая удаление организации';

  @override
  String get roleAdminBody => 'Камеры, аналитика, люди и участники';

  @override
  String get roleOperatorBody => 'Просмотр, управление камерами, постановка и снятие с охраны';

  @override
  String get roleViewerBody => 'Видео в реальном времени и события';

  @override
  String get facesTitle => 'Распознавание лиц';

  @override
  String get facesBody =>
      'Лица сопоставляются на сервере этой организации. Включайте это только там, где снимаемых людей уведомили и они согласны, как требует закон вашей страны.';

  @override
  String get facesConsentTitle => 'Включить распознавание лиц?';

  @override
  String get facesConsentBody =>
      'Распознавание лиц хранит изображения лиц и их измерения для всех, кого видят камеры на обзорах с включенными лицами. Измерения лица относятся к биометрическим данным. Вы подтверждаете, что снимаемых людей уведомили, что у вас есть законное основание обрабатывать их лица и что данные хранятся только столько, сколько нужно. Распознавание можно выключить в любой момент; знакомые люди и их лица тогда останутся, пока вы их не удалите.';

  @override
  String get facesConsentConfirm => 'Понимаю, включить';

  @override
  String get facesEnabled => 'Распознавание лиц включено';

  @override
  String get facesDisabled => 'Распознавание лиц выключено';

  @override
  String get facesOwnerOnly => 'Изменить это может только владелец или администратор.';

  @override
  String get notificationsTitle => 'Уведомления';

  @override
  String notificationsSite(String site) {
    return 'Тревоги объекта $site';
  }

  @override
  String get notificationsAlertsOnly => 'Только тревоги';

  @override
  String get notificationsAlertsOnlyBody =>
      'Если выключено, приходят все события, и их может быть много.';

  @override
  String get notificationsKinds => 'Типы';

  @override
  String get notificationsQuiet => 'Тихие часы';

  @override
  String notificationsQuietBody(String from, String until) {
    return 'Без звука с $from до $until';
  }

  @override
  String get notificationsQuietOff => 'Без тихих часов';

  @override
  String get notificationsPermissionOff => 'Уведомления для этого приложения заблокированы.';

  @override
  String get notificationsOpenSettings => 'Открыть настройки';

  @override
  String get notificationsChannel => 'Доставка';

  @override
  String get notificationsChannelFcm => 'Push через Firebase Cloud Messaging';

  @override
  String get notificationsChannelNone => 'Пока приложение открыто. В этой сборке нет push-службы.';

  @override
  String get healthTitle => 'Состояние';

  @override
  String healthUptime(String value) {
    return 'В сети $value%';
  }

  @override
  String healthLatency(String value) {
    return '$value мс';
  }

  @override
  String get healthOutages => 'Сбои';

  @override
  String get healthNoOutages => 'За последние 24 часа сбоев не было';

  @override
  String healthOngoing(String duration) {
    return 'Продолжается: $duration';
  }

  @override
  String healthLasted(String duration) {
    return 'Длился $duration';
  }

  @override
  String healthCause(String name) {
    return 'Причина: $name';
  }

  @override
  String get healthLast24h => 'Последние 24 часа';

  @override
  String get healthUp => 'Работает';

  @override
  String get healthDegraded => 'Со сбоями';

  @override
  String get healthDown => 'Не работает';

  @override
  String get accountTitle => 'Аккаунт';

  @override
  String get accountProfile => 'Профиль';

  @override
  String get accountSessions => 'Устройства с входом';

  @override
  String get accountThisDevice => 'Это устройство';

  @override
  String accountLastUsed(String when) {
    return 'Последний раз: $when';
  }

  @override
  String get accountRevoke => 'Выйти на этом устройстве';

  @override
  String accountRevoked(String device) {
    return 'Выход выполнен: $device';
  }

  @override
  String get accountAppLock => 'Блокировка приложения';

  @override
  String get accountAppLockBody =>
      'Запрашивать отпечаток, лицо или блокировку экрана при открытии приложения';

  @override
  String get accountAppLockUnavailable => 'На этом телефоне не настроена блокировка экрана.';

  @override
  String get accountDelete => 'Удалить аккаунт';

  @override
  String get accountDeleteTitle => 'Удаление аккаунта';

  @override
  String get accountDeleteBody =>
      'Ваш аккаунт будет удален, и вы выйдете из него везде. Организации, которыми вы владеете, нужно сначала передать другому владельцу или удалить. Это нельзя отменить.';

  @override
  String get accountDeleteConfirm => 'Удалить мой аккаунт';

  @override
  String get accountDeletePassword => 'Введите пароль для подтверждения';

  @override
  String get accountDeleted => 'Ваш аккаунт удален.';

  @override
  String get appearanceTitle => 'Язык и тема';

  @override
  String get appearanceLanguage => 'Язык';

  @override
  String get appearanceSystem => 'Как в телефоне';

  @override
  String get appearanceTheme => 'Тема';

  @override
  String get themeSystem => 'Как в телефоне';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Темная';

  @override
  String get aboutTitle => 'О приложении';

  @override
  String aboutVersion(String version) {
    return 'Версия $version';
  }

  @override
  String aboutBuild(String flavor) {
    return 'Сборка $flavor';
  }

  @override
  String get aboutServer => 'Сервер';

  @override
  String get aboutLicences => 'Лицензии открытого ПО';

  @override
  String get aboutPrivacy =>
      'Видео, снимки и лица остаются на сервере, к которому вы подключены. Уведомления содержат только идентификаторы; изображение приложение загружает само.';

  @override
  String get lockTitle => 'Smart Surveillance заблокирован';

  @override
  String get lockUnlock => 'Разблокировать';

  @override
  String get lockReason => 'Разблокируйте, чтобы смотреть камеры';

  @override
  String notificationAlertTitle(String site) {
    return 'Тревога: $site';
  }

  @override
  String get notificationChannelName => 'Тревоги';

  @override
  String get notificationChannelBody => 'Тревоги с ваших камер';

  @override
  String commonHoursMinutes(int hours, int minutes) {
    return '$hours ч $minutes мин';
  }

  @override
  String get commonShowPassword => 'Показать пароль';

  @override
  String get commonHidePassword => 'Скрыть пароль';

  @override
  String get countsInside => 'внутри';

  @override
  String get editorAddPoints => 'Добавить углы';

  @override
  String get connectorsVersionLabel => 'Версия';

  @override
  String get connectorsLastSeen => 'Последняя активность';

  @override
  String get connectorsConnection => 'Подключение';

  @override
  String get connectorsTunnel => 'Защищенный туннель';

  @override
  String get fieldCodeHelp => 'Вставьте ссылку из письма или код из нее';

  @override
  String get verifyDone => 'Почта подтверждена. Войдите, чтобы продолжить.';

  @override
  String get resetLinkBody => 'Выберите новый пароль для вашего аккаунта.';

  @override
  String get pairingAddTitle => 'Как вы хотите ее добавить?';

  @override
  String get pairingAddBody =>
      'Выберите способ, который подходит камере. Лучший для этого объекта указан первым.';

  @override
  String get pairingRecommended => 'Рекомендуется';

  @override
  String get pairingPermissionDenied =>
      'Нужно разрешение, которое телефон не получил. Разрешите его в настройках телефона или выберите другой способ.';

  @override
  String get pairingDemoCode => 'Использовать демо-код';

  @override
  String get pairingWaiting => 'Ждем подтверждения от коннектора';

  @override
  String pairingCamerasAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count камеры добавлено',
      many: '$count камер добавлено',
      few: '$count камеры добавлены',
      one: '$count камера добавлена',
    );
    return '$_temp0';
  }

  @override
  String get validationConnectorCode => 'Введите 8-значный код, например ABCD-1234';

  @override
  String get methodConnectorDiscovery => 'Камеры в сети';

  @override
  String get methodConnectorDiscoveryBody => 'Выберите одну из камер, найденных коннектором';

  @override
  String get methodLabelQr => 'Сканировать наклейку камеры';

  @override
  String get methodLabelQrBody => 'Наведите на QR-код на наклейке камеры';

  @override
  String get methodManualHost => 'Ввести адрес';

  @override
  String get methodManualHostBody => 'Введите IP-адрес камеры, и коннектор ее определит';

  @override
  String get methodNvrImport => 'Импорт с регистратора';

  @override
  String get methodNvrImportBody => 'Добавьте сразу каналы NVR или DVR';

  @override
  String get methodRtspUrl => 'Вставить RTSP-ссылку';

  @override
  String get methodRtspUrlBody => 'Для камер, которые дают адрес потока';

  @override
  String get methodConnectorQr => 'Сканировать QR-код коннектора';

  @override
  String get methodConnectorQrBody => 'Коннектор показывает его на экране или веб-странице';

  @override
  String get methodConnectorMdns => 'Найти в этой сети Wi-Fi';

  @override
  String get methodConnectorMdnsBody =>
      'Искать коннекторы в сети, к которой подключен этот телефон';

  @override
  String get methodConnectorCode => 'Ввести код';

  @override
  String get methodConnectorCodeBody => '8-значный код, который показывает коннектор';

  @override
  String get mdnsTitle => 'Коннекторы в этой сети Wi-Fi';

  @override
  String get mdnsSearching => 'Ищем коннекторы в этой сети';

  @override
  String get mdnsNone =>
      'Коннектор пока не найден. Убедитесь, что телефон и коннектор в одной сети Wi-Fi.';

  @override
  String get labelTitle => 'Сканирование наклейки';

  @override
  String get labelHint => 'Наведите камеру телефона на QR-код на наклейке камеры.';

  @override
  String get labelUnknown => 'Эта наклейка нам незнакома. Добавьте камеру другим способом.';

  @override
  String get manualTitle => 'Адрес камеры';

  @override
  String get manualBody =>
      'Коннектор спросит у камеры, что это за модель. Логин вводится на следующем шаге.';

  @override
  String get manualHost => 'IP-адрес или имя хоста';

  @override
  String get manualPort => 'Порт ONVIF, если не стандартный';

  @override
  String get manualIdentify => 'Определить камеру';

  @override
  String get manualIdentifying => 'Опрашиваем камеру';

  @override
  String get manualNotFound => 'По этому адресу камера не ответила. Проверьте его и повторите.';

  @override
  String get rtspTitle => 'RTSP-ссылка';

  @override
  String get rtspBody =>
      'Вставьте ссылку на поток из инструкции или приложения камеры. Логин в ссылке хранится на коннекторе.';

  @override
  String get rtspField => 'Ссылка на поток';

  @override
  String get rtspInvalid => 'Это не RTSP-ссылка.';

  @override
  String get nvrPick => 'Выберите регистратор';

  @override
  String get nvrNone => 'Регистраторы не найдены';

  @override
  String get nvrTitle => 'Импорт каналов';

  @override
  String get nvrLogin => 'Логин регистратора';

  @override
  String get nvrLoad => 'Показать каналы';

  @override
  String get nvrChannels => 'Каналы';

  @override
  String nvrAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Добавить $count камеры',
      many: 'Добавить $count камер',
      few: 'Добавить $count камеры',
      one: 'Добавить $count камеру',
      zero: 'Выберите каналы',
    );
    return '$_temp0';
  }

  @override
  String get nvrOffline => 'Нет сигнала';

  @override
  String get onboardingTestPassed => 'Поток работает';

  @override
  String get presetZoneName => 'Весь обзор';

  @override
  String get presetLineName => 'Вход';

  @override
  String get morePlan => 'Тариф и использование';

  @override
  String get moreActivity => 'Активность';

  @override
  String get planTitle => 'Тариф и использование';

  @override
  String get planInternal => 'Внутренний тариф без ограничений';

  @override
  String get planUnlimited => 'Без ограничений';

  @override
  String get planLimits => 'Лимиты';

  @override
  String get planUsage => 'В этом месяце';

  @override
  String get planFeatures => 'Возможности';

  @override
  String get planIncluded => 'Входит в тариф';

  @override
  String get planNotIncluded => 'Не входит в ваш тариф';

  @override
  String get planUnavailable => 'Не входит в ваш тариф. Владелец может сменить тариф.';

  @override
  String get planSites => 'Объекты';

  @override
  String get planCameras => 'Камеры';

  @override
  String get planMembers => 'Участники';

  @override
  String get planEventRetention => 'Хранение событий';

  @override
  String get planClipRetention => 'Хранение клипов';

  @override
  String get planCameraHours => 'Часы работы камер в сети';

  @override
  String get planAnalyticsHours => 'Часы анализа обзоров';

  @override
  String get planEvents => 'События';

  @override
  String get planClipStorage => 'Хранилище клипов';

  @override
  String get planNotifications => 'Отправлено уведомлений';

  @override
  String planOf(String used, String limit) {
    return '$used из $limit';
  }

  @override
  String planSince(String date) {
    return 'С $date';
  }

  @override
  String planGigabytes(String value) {
    return '$value ГБ';
  }

  @override
  String get featureObjects => 'Оставленные и забранные предметы';

  @override
  String get featureJourneys => 'Маршруты';

  @override
  String get featureAppearanceSearch => 'Найти этого человека';

  @override
  String get featureTelegram => 'Тревоги в Telegram';

  @override
  String get telegramTitle => 'Telegram';

  @override
  String get telegramBody => 'Отправляйте тревоги со снимком в чат или группу Telegram.';

  @override
  String get telegramLink => 'Привязать чат';

  @override
  String get telegramLinkBody =>
      'Telegram откроет бота. Нажмите Start в личном чате или добавьте бота в группу, и чат появится здесь.';

  @override
  String get telegramOpened => 'Завершите в Telegram и вернитесь сюда.';

  @override
  String get telegramChats => 'Привязанные чаты';

  @override
  String get telegramNone => 'Чат пока не привязан';

  @override
  String get telegramGroup => 'Группа';

  @override
  String get telegramPrivate => 'Личный чат';

  @override
  String telegramLinked(String when) {
    return 'Привязан $when';
  }

  @override
  String get telegramUnlink => 'Отвязать';

  @override
  String telegramUnlinkBody(String chat) {
    return 'Тревоги перестанут приходить в $chat.';
  }

  @override
  String get telegramTest => 'Отправить тест';

  @override
  String telegramTestSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Тест отправлен в $count чата',
      many: 'Тест отправлен в $count чатов',
      few: 'Тест отправлен в $count чата',
      one: 'Тест отправлен в $count чат',
      zero: 'Нет чата для отправки',
    );
    return '$_temp0';
  }

  @override
  String get telegramCannotOpen => 'Не удалось открыть Telegram на этом телефоне.';

  @override
  String get activityTitle => 'Активность';

  @override
  String get activityEmpty => 'Активности пока нет';

  @override
  String get activityAll => 'Все';

  @override
  String get auditSignIn => 'Входы';

  @override
  String get auditMembers => 'Участники';

  @override
  String get auditCameras => 'Камеры';

  @override
  String get auditRules => 'Правила';

  @override
  String get auditArm => 'Режим охраны';

  @override
  String get auditViews => 'Просмотр';

  @override
  String get auditExports => 'Экспорт';

  @override
  String get auditFaces => 'Лица';

  @override
  String get auditAdmin => 'Платформа';

  @override
  String get actionAuthSignIn => 'Вошел в аккаунт';

  @override
  String get actionMemberInvite => 'Пригласил участника';

  @override
  String get actionMemberRole => 'Изменил роль';

  @override
  String get actionMemberRemove => 'Убрал участника';

  @override
  String get actionCameraAdd => 'Добавил камеру';

  @override
  String get actionCameraUpdate => 'Изменил камеру';

  @override
  String get actionCameraDelete => 'Удалил камеру';

  @override
  String get actionRulesUpdate => 'Изменил зоны и линии';

  @override
  String get actionArmChange => 'Изменил режим охраны';

  @override
  String get actionLiveView => 'Смотрел эфир';

  @override
  String get actionClipView => 'Смотрел клип';

  @override
  String get actionClipExport => 'Поделился клипом';

  @override
  String get actionFaceEnrol => 'Добавил фото лиц';

  @override
  String get actionFaceDelete => 'Удалил лица';

  @override
  String get actionOrgPlan => 'Сменил тариф';

  @override
  String get capabilityNone => 'У этой камеры нет элементов управления.';

  @override
  String eventsAlertCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count тревоги',
      many: '$count тревог',
      few: '$count тревоги',
      one: '$count тревога',
    );
    return '$_temp0';
  }
}
