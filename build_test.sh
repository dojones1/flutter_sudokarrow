set -ex
flutter upgrade
flutter doctor
dart format --output=write .
flutter analyze
flutter test
flutter build web --wasm
flutter run -d chrome --wasm