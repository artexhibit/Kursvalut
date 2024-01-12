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
    
    struct Notifications {
        static let networkNotification = "ru.igorcodes.makeNetworkRequest" as CFString
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
        static let updateRequestFromCurrencyDataSourceKey = "updateRequestFromCurrencyDataSource"
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
    }
    struct PopupTexts {
        struct Titles {
           static let onlyPro = "Только для Pro"
            static let forbidden = "Пока нельзя"
            static let error = "Ошибка"
            static let updated = "Обновлено"
            static let oneSecond = "Секунду"
            static let maxThreeCurrenciesFree = "Максимум 3 валюты"
            static let allIsGood = "Всё в порядке"
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
}
