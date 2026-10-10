#!/bin/bash
set -e

echo "==> Setting up Flutter for Vercel build..."

if ! command -v flutter &> /dev/null
then
    echo "==> Flutter not found in PATH. Downloading Flutter SDK..."
    git clone https://github.com/flutter/flutter.git -b stable --depth 1 flutter_sdk
    export PATH="$PATH:`pwd`/flutter_sdk/bin"
fi

flutter --version
flutter config --enable-web
flutter pub get
flutter build web --release

echo "==> Flutter web build successful!"
