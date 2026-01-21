# CSMF Planning - Application Flutter

Application mobile pour consulter le planning du CSMF Paris.

## Fonctionnalités

- 📅 Consultation du planning par semaine et par site
- 🔍 Recherche d'activités et de coachs
- 🔔 Notifications push pour les cours sélectionnés
- 📰 Actualités du club
- ⚙️ Personnalisation des préférences

## Installation

### Prérequis

1. **Flutter SDK** (3.0+) : https://docs.flutter.dev/get-started/install
2. **Xcode** (pour iOS) : Mac App Store
3. **Android Studio** (pour Android) : https://developer.android.com/studio

### Configuration

```bash
# 1. Extraire le projet
unzip planning_csmf_flutter.zip -d planning_csmf
cd planning_csmf

# 2. Installer les dépendances
flutter pub get

# 3. Vérifier la configuration
flutter doctor

# 4. Lancer sur iOS (simulateur)
flutter run -d ios

# 5. Ou lancer sur Android
flutter run -d android
```

## Configuration Firebase (pour les notifications)

1. Créer un projet Firebase : https://console.firebase.google.com
2. Ajouter une app iOS et Android
3. Télécharger les fichiers de configuration :
   - `GoogleService-Info.plist` → `ios/Runner/`
   - `google-services.json` → `android/app/`
4. Décommenter le code Firebase dans :
   - `lib/main.dart`
   - `lib/services/notification_service.dart`

## Structure du projet

```
lib/
├── main.dart                    # Point d'entrée
├── models/
│   └── activity.dart            # Modèles de données
├── screens/
│   ├── home_screen.dart         # Écran principal (planning)
│   ├── news_screen.dart         # Actualités
│   ├── search_screen.dart       # Recherche
│   └── settings_screen.dart     # Paramètres
├── services/
│   ├── api_service.dart         # Appels API
│   ├── notification_service.dart # Notifications push
│   └── preferences_service.dart  # Stockage local
└── widgets/
    └── activity_card.dart       # Carte d'activité
```

## API

L'application utilise l'API : `https://planning-csmf.azurewebsites.net/api`

Endpoints utilisés :
- `GET /planning` - Planning par semaine/site
- `GET /planning/current` - Planning de la semaine en cours
- `GET /sites` - Liste des sites
- `GET /activites` - Liste des activités
- `GET /search?q=...` - Recherche
- `GET /news` - Actualités (à implémenter côté serveur)

## Build pour production

### iOS
```bash
flutter build ios --release
```
Puis ouvrir `ios/Runner.xcworkspace` dans Xcode pour archiver et publier.

### Android
```bash
flutter build apk --release
# ou pour le Play Store
flutter build appbundle --release
```

## Personnalisation

### Couleurs
Modifier dans `lib/main.dart` :
```dart
colorScheme: ColorScheme.fromSeed(
  seedColor: const Color(0xFF1E3A8A), // Bleu CSMF
),
```

### API URL
Modifier dans `lib/services/api_service.dart` :
```dart
static const String baseUrl = 'https://planning-csmf.azurewebsites.net/api';
```
