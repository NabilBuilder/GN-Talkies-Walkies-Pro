import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'Gestion de Matériel'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In fr, this message translates to:
  /// **'SE CONNECTER'**
  String get login;

  /// No description provided for @createAccount.
  ///
  /// In fr, this message translates to:
  /// **'CRÉER UN COMPTE'**
  String get createAccount;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @search.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un matériel'**
  String get search;

  /// No description provided for @transfer.
  ///
  /// In fr, this message translates to:
  /// **'Transférer'**
  String get transfer;

  /// No description provided for @logout.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get logout;

  /// No description provided for @error.
  ///
  /// In fr, this message translates to:
  /// **'Erreur'**
  String get error;

  /// No description provided for @editMaterial.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le matériel'**
  String get editMaterial;

  /// No description provided for @newMaterial.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau matériel'**
  String get newMaterial;

  /// No description provided for @createMaterial.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get createMaterial;

  /// No description provided for @updateMaterial.
  ///
  /// In fr, this message translates to:
  /// **'Mettre à jour'**
  String get updateMaterial;

  /// No description provided for @dashboardTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord'**
  String get dashboardTitle;

  /// No description provided for @dashboardSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Vue d\'ensemble du matériel'**
  String get dashboardSubtitle;

  /// No description provided for @totalEquipment.
  ///
  /// In fr, this message translates to:
  /// **'Total'**
  String get totalEquipment;

  /// No description provided for @operational.
  ///
  /// In fr, this message translates to:
  /// **'Actifs'**
  String get operational;

  /// No description provided for @inRepair.
  ///
  /// In fr, this message translates to:
  /// **'En panne'**
  String get inRepair;

  /// No description provided for @lost.
  ///
  /// In fr, this message translates to:
  /// **'Perdus'**
  String get lost;

  /// No description provided for @sites.
  ///
  /// In fr, this message translates to:
  /// **'Sites'**
  String get sites;

  /// No description provided for @markets.
  ///
  /// In fr, this message translates to:
  /// **'Marchés'**
  String get markets;

  /// No description provided for @statusDistribution.
  ///
  /// In fr, this message translates to:
  /// **'Répartition par état'**
  String get statusDistribution;

  /// No description provided for @statusActive.
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get statusActive;

  /// No description provided for @statusInRepair.
  ///
  /// In fr, this message translates to:
  /// **'En panne'**
  String get statusInRepair;

  /// No description provided for @statusLost.
  ///
  /// In fr, this message translates to:
  /// **'Perdu'**
  String get statusLost;

  /// No description provided for @none.
  ///
  /// In fr, this message translates to:
  /// **'Aucun'**
  String get none;

  /// No description provided for @undefined.
  ///
  /// In fr, this message translates to:
  /// **'Non défini'**
  String get undefined;

  /// No description provided for @noEquipmentToDisplay.
  ///
  /// In fr, this message translates to:
  /// **'Aucun matériel à afficher'**
  String get noEquipmentToDisplay;

  /// No description provided for @equipmentBySite.
  ///
  /// In fr, this message translates to:
  /// **'Matériels par site'**
  String get equipmentBySite;

  /// No description provided for @recentTransfers.
  ///
  /// In fr, this message translates to:
  /// **'Transferts récents'**
  String get recentTransfers;

  /// No description provided for @noTransfersRecorded.
  ///
  /// In fr, this message translates to:
  /// **'Aucun transfert enregistré'**
  String get noTransfersRecorded;

  /// No description provided for @transferSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Transfert effectué avec succès'**
  String get transferSuccess;

  /// No description provided for @transferMaterialTitle.
  ///
  /// In fr, this message translates to:
  /// **'Transfert de matériel'**
  String get transferMaterialTitle;

  /// No description provided for @materialToTransfer.
  ///
  /// In fr, this message translates to:
  /// **'Matériel à transférer'**
  String get materialToTransfer;

  /// No description provided for @designation.
  ///
  /// In fr, this message translates to:
  /// **'Désignation'**
  String get designation;

  /// No description provided for @codeQR.
  ///
  /// In fr, this message translates to:
  /// **'Code QR'**
  String get codeQR;

  /// No description provided for @currentSite.
  ///
  /// In fr, this message translates to:
  /// **'Site actuel'**
  String get currentSite;

  /// No description provided for @market.
  ///
  /// In fr, this message translates to:
  /// **'Marché'**
  String get market;

  /// No description provided for @transferInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations de transfert'**
  String get transferInfo;

  /// No description provided for @destinationSite.
  ///
  /// In fr, this message translates to:
  /// **'Site de destination *'**
  String get destinationSite;

  /// No description provided for @selectDestination.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez sélectionner un site de destination'**
  String get selectDestination;

  /// No description provided for @transferReason.
  ///
  /// In fr, this message translates to:
  /// **'Motif du transfert *'**
  String get transferReason;

  /// No description provided for @enterReason.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer un motif'**
  String get enterReason;

  /// No description provided for @executeTransfer.
  ///
  /// In fr, this message translates to:
  /// **'Effectuer le transfert'**
  String get executeTransfer;

  /// No description provided for @profileNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Profil utilisateur non trouvé dans Firestore.'**
  String get profileNotFound;

  /// No description provided for @dataInitialized.
  ///
  /// In fr, this message translates to:
  /// **'Données initialisées'**
  String get dataInitialized;

  /// No description provided for @initError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur d\'initialisation'**
  String get initError;

  /// No description provided for @email.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @enterEmail.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer votre email'**
  String get enterEmail;

  /// No description provided for @invalidEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email invalide'**
  String get invalidEmail;

  /// No description provided for @password.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get password;

  /// No description provided for @enterPassword.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer votre mot de passe'**
  String get enterPassword;

  /// No description provided for @passwordTooShort.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe trop court'**
  String get passwordTooShort;

  /// No description provided for @rolesDescription.
  ///
  /// In fr, this message translates to:
  /// **'Rôles: Administrateur Général | Superviseur | Chef d\'équipe'**
  String get rolesDescription;

  /// No description provided for @initializing.
  ///
  /// In fr, this message translates to:
  /// **'Initialisation en cours...'**
  String get initializing;

  /// No description provided for @initDemoData.
  ///
  /// In fr, this message translates to:
  /// **'Initialiser les données de démonstration'**
  String get initDemoData;

  /// No description provided for @accountCreated.
  ///
  /// In fr, this message translates to:
  /// **'Compte créé avec succès !'**
  String get accountCreated;

  /// No description provided for @roleAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Administrateur Général'**
  String get roleAdmin;

  /// No description provided for @roleSupervisor.
  ///
  /// In fr, this message translates to:
  /// **'Superviseur'**
  String get roleSupervisor;

  /// No description provided for @roleChefEquipe.
  ///
  /// In fr, this message translates to:
  /// **'Chef d\'équipe'**
  String get roleChefEquipe;

  /// No description provided for @createAccountTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get createAccountTitle;

  /// No description provided for @fullName.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get fullName;

  /// No description provided for @enterName.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer votre nom'**
  String get enterName;

  /// No description provided for @passwordTooShortWithMin.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe trop court (minimum 6)'**
  String get passwordTooShortWithMin;

  /// No description provided for @selectRole.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez votre rôle'**
  String get selectRole;

  /// No description provided for @createAccountBtn.
  ///
  /// In fr, this message translates to:
  /// **'CRÉER LE COMPTE'**
  String get createAccountBtn;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In fr, this message translates to:
  /// **'Déjà un compte ? Se connecter'**
  String get alreadyHaveAccount;

  /// No description provided for @exportCreated.
  ///
  /// In fr, this message translates to:
  /// **'Export créé:'**
  String get exportCreated;

  /// No description provided for @exportInProgress.
  ///
  /// In fr, this message translates to:
  /// **'Export en cours'**
  String get exportInProgress;

  /// No description provided for @exportTitle.
  ///
  /// In fr, this message translates to:
  /// **'Exportation des données'**
  String get exportTitle;

  /// No description provided for @exportSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Exportez les données en format Excel ou PDF'**
  String get exportSubtitle;

  /// No description provided for @equipment.
  ///
  /// In fr, this message translates to:
  /// **'Matériels'**
  String get equipment;

  /// No description provided for @transferHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique des transferts'**
  String get transferHistory;

  /// No description provided for @noTransferHistory.
  ///
  /// In fr, this message translates to:
  /// **'Aucun historique de transfert'**
  String get noTransferHistory;

  /// No description provided for @reason.
  ///
  /// In fr, this message translates to:
  /// **'Motif'**
  String get reason;

  /// No description provided for @date.
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @details.
  ///
  /// In fr, this message translates to:
  /// **'Détails'**
  String get details;

  /// No description provided for @confirmReceipt.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer réception'**
  String get confirmReceipt;

  /// No description provided for @transferDetails.
  ///
  /// In fr, this message translates to:
  /// **'Détails du transfert'**
  String get transferDetails;

  /// No description provided for @material.
  ///
  /// In fr, this message translates to:
  /// **'Matériel'**
  String get material;

  /// No description provided for @siteOrigin.
  ///
  /// In fr, this message translates to:
  /// **'Site origine'**
  String get siteOrigin;

  /// No description provided for @siteDestination.
  ///
  /// In fr, this message translates to:
  /// **'Site destination'**
  String get siteDestination;

  /// No description provided for @transferredBy.
  ///
  /// In fr, this message translates to:
  /// **'Transféré par'**
  String get transferredBy;

  /// No description provided for @transferDate.
  ///
  /// In fr, this message translates to:
  /// **'Date transfert'**
  String get transferDate;

  /// No description provided for @status.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get status;

  /// No description provided for @confirmed.
  ///
  /// In fr, this message translates to:
  /// **'Confirmé'**
  String get confirmed;

  /// No description provided for @pending.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get pending;

  /// No description provided for @confirmedBy.
  ///
  /// In fr, this message translates to:
  /// **'Confirmé par'**
  String get confirmedBy;

  /// No description provided for @confirmationDate.
  ///
  /// In fr, this message translates to:
  /// **'Date confirmation'**
  String get confirmationDate;

  /// No description provided for @close.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get close;

  /// No description provided for @transferConfirmed.
  ///
  /// In fr, this message translates to:
  /// **'Transfert confirmé avec succès'**
  String get transferConfirmed;

  /// No description provided for @switchLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Changer la langue'**
  String get switchLanguage;

  /// No description provided for @switchTheme.
  ///
  /// In fr, this message translates to:
  /// **'Changer le thème'**
  String get switchTheme;

  /// No description provided for @lightMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode clair'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode sombre'**
  String get darkMode;

  /// No description provided for @arabic.
  ///
  /// In fr, this message translates to:
  /// **'Arabe'**
  String get arabic;

  /// No description provided for @french.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @confirmLogout.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous vous déconnecter ?'**
  String get confirmLogout;

  /// No description provided for @navDashboard.
  ///
  /// In fr, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navScanner.
  ///
  /// In fr, this message translates to:
  /// **'Scanner'**
  String get navScanner;

  /// No description provided for @navHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get navHistory;

  /// No description provided for @navExport.
  ///
  /// In fr, this message translates to:
  /// **'Exporter'**
  String get navExport;

  /// No description provided for @synced.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisé'**
  String get synced;

  /// No description provided for @offlineMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode hors ligne'**
  String get offlineMode;

  /// No description provided for @syncing.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation en cours...'**
  String get syncing;

  /// No description provided for @lastSync.
  ///
  /// In fr, this message translates to:
  /// **'Dernière synchronisation'**
  String get lastSync;

  /// No description provided for @pullToRefresh.
  ///
  /// In fr, this message translates to:
  /// **'Tirer pour actualiser'**
  String get pullToRefresh;

  /// No description provided for @somethingWentWrong.
  ///
  /// In fr, this message translates to:
  /// **'Quelque chose s\'est mal passé'**
  String get somethingWentWrong;

  /// No description provided for @tryAgain.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get tryAgain;

  /// No description provided for @emptyList.
  ///
  /// In fr, this message translates to:
  /// **'Aucune donnée disponible'**
  String get emptyList;

  /// No description provided for @loading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement...'**
  String get loading;

  /// No description provided for @appName.
  ///
  /// In fr, this message translates to:
  /// **'Gestion de Matériel'**
  String get appName;

  /// No description provided for @welcomeMessage.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue sur l\'application'**
  String get welcomeMessage;

  /// No description provided for @registrationFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec de l\'inscription'**
  String get registrationFailed;

  /// No description provided for @emailAlreadyUsed.
  ///
  /// In fr, this message translates to:
  /// **'Email déjà utilisé'**
  String get emailAlreadyUsed;

  /// No description provided for @weakPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe trop faible'**
  String get weakPassword;

  /// No description provided for @networkError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur réseau'**
  String get networkError;

  /// No description provided for @firestorePermissionError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de permissions Firestore'**
  String get firestorePermissionError;

  /// No description provided for @connectionRequired.
  ///
  /// In fr, this message translates to:
  /// **'Connexion Internet requise'**
  String get connectionRequired;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
