Livsstil

Livsstil is a mobile app built with Flutter that helps users track habits, log meals, write daily reflections, and monitor weight and progress. The project is intended as a practical local app for personal use or as a starting point for further development.

What the project does

The app provides core features to create and track habits, record meals and reflections, present monthly overviews, and offer simple insights over time. Data is handled locally within the app; no external API keys are required for the main functionality.

Quick start

Make sure you have the Flutter SDK installed and your environment is set up to run Flutter apps.

Run the following to install dependencies and start the app:

```bash
flutter pub get
flutter run
```

Project structure (brief)

lib/ - main application code
	main.dart - app entry point
	models/ - data models (for example habits, meals, weight entries)
	providers/ - app state and state management
	screens/ - UI screens
	services/ - background services and notifications
	theme/ - theme files
	widgets/ - reusable widgets

android/ and ios/ - platform-specific configuration and build files

build/ and .dart_tool/ - local build artifacts (do not commit)

Testing

There is a simple widget test in the test/ folder. Run tests with:

```bash
flutter test
```


