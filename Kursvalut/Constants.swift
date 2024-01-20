import Foundation

struct K {
    static let proPurchasedKey = "kursvalutPro"
    static let baseSourceKey = "baseSource"
    static let userHasOnboardedKey = "userHasOnboarded"
    static let pickDateSwitchIsOnKey = "pickDateSwitchIsOn"
    static let confirmedDateKey = "confirmedDate"
    static let permissionScreenWasShownKey = "permissionScreenWasShown"
    static let pickedStartViewKey = "startView"
    static let appColorKey = "appColor"
    static let pickedThemeKey = "pickedTheme"
    static let roundFlagsKey = "roundFlags"
    static let baseCurrencyKey = "baseCurrency"
    static let pickCurrencyRequestKey = "pickCurrencyRequest"
    static let isFirstLaunchTodayKey = "isFirstLaunchToday"
    static let maxCalendarDateKey = "maxCalendarDate"
    static let newCurrencyDataReadyKey = "newCurrencyDataReady"
    
    struct Images {
        static let defaultImage = "notFound"
        static let defaultRoundImage = "notFoundRound"
        static let rubleSignSquare = "rublesign.square"
        static let rubleSignCircle = "rublesign.circle"
        static let euroSign = "eurosign.square"
        static let circle = "circle"
        static let checkmarkCircleFill = "checkmark.circle.fill"
        static let checkmarkCircle = "checkmark.circle"
        static let line = "line.3.horizontal"
        static let trash = "trash"
        static let xCircle = "x.circle"
        static let thumbsUp = "hand.thumbsup.circle"
        static let heart = "heart.fill"
        static let envelope = "envelope.circle"
        static let lock = "lock.circle"
        static let questionMark = "questionmark.circle"
        static let arrowUpDown = "arrow.up.arrow.down"
        static let circleLeftHalfFilled = "circle.lefthalf.filled"
        static let sparklesSquare = "sparkles.square.filled.on.square"
        static let chevronBackward = "chevron.backward.circle.fill"
        static let chevronLeftCircle = "chevron.left.circle"
        static let iPhone = "apps.iphone"
        static let closingQuote = "quote.closing"
        static let infinity = "infinity"
        static let euroImage = "EUR"
        static let usdImage = "USD"
        static let circleOne = "1.circle"
        static let circleTwo = "2.circle"
        static let circleThree = "3.circle"
        static let circleFour = "4.circle"
    }
    
    struct Notifications {
        static let makeDarwinNetworkRequest = "ru.igorcodes.makeNetworkRequest" as CFString
        static let hideKeyboardButtonPressed = "hideKeyboardButtonPressed"
        static let refreshData = "refreshData"
        static let makeNetworkRequest = "makeNetworkRequest"
        static let customSortSwitchIsTurnedOn = "customSortSwitchIsTurnedOn"
        static let customSortSwitchIsTurnedOff = "customSortSwitchIsTurnedOff"
        static let reloadSortingVCTableView = "reloadSortingVCTableView"
        static let stopActivityIndicatorInDataSourceVC = "stopActivityIndicatorInDataSourceVC"
        static let refreshConverterFRC = "refreshConverterFRC"
        static let refreshBaseCurrency = "refreshBaseCurrency"
        static let updateCells = "updateCells"
        static let pro = "pro"
        static let loadNotificationsSwitchState = "loadNotificationsSwitchState"
        static let refreshDataFromDataSourceVC = "refreshDataFromDataSourceVC"
        
        struct UserInfoKeys {
            static let currencyWasAdded = "currencyWasAdded"
        }
    }
    struct CurrencyVC {
        static let needToRefreshFRCForCustomSortKey = "needToRefreshFRCForCustomSort"
        static let needToScrollUpViewControllerKey = "needToScrollUpViewController"
        static let decimalsNumberChangedKey = "decimalsNumberChanged"
        static let bankOfRussiaPickedOrderKey = "bankOfRussiaPickedOrder"
        static let forexPickedOrderKey = "forexPickedOrder"
        static let bankOfRussiaPickedSectionKey = "bankOfRussiaPickedSection"
        static let forexPickedSectionKey = "forexPickedSection"
        static let yPortraitKey = "yPortrait"
        static let yLandscapeKey = "yLandscape"
        static let isActiveCurrencyVCKey = "isActiveCurrencyVC"
        static let customSortSwitchIsOnForBankOfRussiaKey = "customSortSwitchIsOnForBankOfRussia"
        static let customSortSwitchIsOnForForexKey = "customSortSwitchIsOnForForex"
        static let showCustomSortForBankOfRussiaKey = "showCustomSortForBankOfRussia"
        static let showCustomSortForForexKey = "showCustomSortForForex"
        static let currencyScreenDecimalsKey = "currencyScreenDecimals"
        static let currencyScreenPercentageDecimalsKey = "currencyScreenPercentageDecimals"
    }
    struct ConverterVC {
        static let converterScreenDecimalsKey = "converterScreenDecimals"
        static let savedAmountForBankOfRussiaKey = "savedAmountForBankOfRussia"
        static let savedAmountForForexKey = "savedAmountForForex"
        static let setTextFieldToZeroKey = "setTextFieldToZero"
        static let canResetValuesInActiveTextFieldKey = "canResetValuesInActiveTextField"
        static let canSaveConverterValuesKey = "canSaveConverterValues"
        static let bankOfRussiaPickedCurrencyKey = "bankOfRussiaPickedCurrency"
        static let forexPickedCurrencyKey = "forexPickedCurrency"
    }
    struct SettingsVC {
        static let keyboardWithSoundKey = "keyboardWithSound"
    }
    struct SortingVC {
        static let bankOfRussiaPickedSectionNumberKey = "bankOfRussiaPickedSectionNumber"
        static let forexPickedSectionNumberKey = "forexPickedSectionNumber"
        static let previousBankOfRussiaPickedOrderKey = "previousBankOfRussiaPickedOrder"
        static let previousForexPickedOrderKey = "previousForexPickedOrder"
        static let previousLastBankOfRussiaPickedSectionKey = "previousLastBankOfRussiaPickedSection"
        static let previousForexPickedSectionKey = "previousForexPickedSection"
    }
    struct Segues {
        static let showOnboardingKey = "showOnboarding"
        static let goToNotificationPermissonKey = "goToNotificationPermisson"
        static let goToCurrencyListKey = "goToCurrencyList"
        static let decimalsSegueKey = "decimalsSegue"
        static let startViewSegueKey = "startViewSegue"
        static let themeSegueKey = "themeSegue"
        static let goToTutorialKey = "goToTutorial"
        static let unwindToAppKey = "unwindToApp"
    }
    struct Cells {
        static let menuTableViewCellKey = "menuTableViewCell"
        static let currencyCellKey = "currencyCell"
        static let converterCellKey = "converterCell"
        static let pickCurrencyCellKey = "pickCurrencyCell"
        static let decimalsCellKey = "decimalsCell"
        static let currencyPreviewCellKey = "currencyPreviewCell"
        static let converterPreviewCellKey = "converterPreviewCell"
        static let startViewCellKey = "startViewCell"
        static let themeCellKey = "themeCell"
        static let permissionsCellKey = "permissionsCell"
        static let privacyPolicyCellKey = "privacyPolicyCell"
        static let aboutAppDeveloperCellKey = "aboutAppDeveloperCell"
        static let aboutAppDataProvidersCellKey = "aboutAppDataProvidersCell"
        static let tipJarCellKey = "tipJarCell"
        static let proCellKey = "proCell"
        static let customSortCellKey = "customSortCell"
        static let mainSortCellKey = "mainSortCell"
        static let subSortCellKey = "subSortCell"
        static let tutorialImageCellKey = "tutorialImageCell"
        static let tutorialDescriptionCellKey = "tutorialDescriptionCell"
        static let concreteDateCellKey = "concreteDateCell"
        static let datePickerCellKey = "datePickerCell"
        static let dataSourceCellKey = "dataSourceCell"
        static let pickedBaseCurrencyCellKey = "pickedBaseCurrencyCell"
        static let baseCurrencyCellKey = "baseCurrencyCell"
        static let notificationPermissionCellKey = "notificationPermissionCell"
        static let onboardingTableCellKey = "onboardingTableCell"
        static let onboardingCellKey = "onboardingCell"
        static let welcomeOnboardingCellKey = "welcomeOnboardingCell"
    }
    struct PopupTexts {
        struct Titles {
           static let onlyPro = "Только для Pro"
            static let forbidden = "Пока нельзя"
            static let error = "Ошибка"
            static let updated = "Обновлено"
            static let oneSecond = "Секунду"
            static let maxThreeCurrenciesFree = "Максимум 3 валюты"
            static let allGood = "Всё в порядке"
            static let closed = "Закрыто"
            static let success = "Успешно"
            static let mailSent = "Письмо отправлено"
            static let thankYou = "Спасибо"
        }
        struct Messages {
            static let onlyProSwitch = "Переключение с этого экрана доступно в Pro-версии"
            static let onlyProDate = "Выбор даты с этого экрана доступен в Pro-версии"
            static let ownSearchInPro = "Своя сортировка доступна в Pro-версии"
            static let endSearchFirst = "Сначала завершите поиск"
            static let dataUpdated = "Курсы актуальны"
            static let dataDownloaded = "Курсы загружены"
            static let download = "Загружаем"
            static let unlimitedInPro = "Безлимит доступен в Pro"
            static let proAlreadyRecovered = "Pro уже восстановлен"
            static let onlyInPro = "Доступно только в Pro"
            static let failureToOpenAppStore = "Не получается открыть App Store"
            static let proNotPurchased = "Pro ранее не покупался"
            static let proRecovered = "Покупка восстановлена"
            static let willReply = "Скоро вам отвечу!"
            static let couldntSend = "Не удалось отправить:"
            static let noAppStorePurchasePermission = "У вас нет разрешения на покупки в App Store"
            static let thankYou = "Спасибо! Ты - супер!"
            static let couldntPay = "Не удалось оплатить:"
            static let haveProNow = "Теперь у тебя есть Pro!"
            static let noData = "Нет данных на выбранную дату. Попробуйте другую"
        }
    }
    struct Sections {
        static let byName = "По имени"
        static let byShortName = "По короткому имени"
        static let byValue = "По значению"
        static let custom = "Своя"
        static let ascendingOrderByWord = "По возрастанию (А→Я)"
        static let descendingOrderByWord = "По убыванию (Я→А)"
        static let ascendingOrderByNum = "По возрастанию (1→2)"
        static let descendingOrderByNum = "По убыванию (2→1)"
    }
}
