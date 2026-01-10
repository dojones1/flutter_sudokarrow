set -ex
flutter upgrade
flutter doctor
dart format --output=write --show=changed --set-exit-if-changed .
flutter analyze
flutter test --coverage
flutter build web --wasm
flutter run -d chrome --wasm