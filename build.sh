#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
SDK="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-$PWD/.android-sdk}}"
BT="$SDK/build-tools/35.0.0"
[ -f "$SDK/platforms/android-35/android.jar" ] || ./install.sh
mkdir -p build/classes dist
KEY="${QN_KEYSTORE:-$PWD/build/developer.jks}"
PASS="${QN_KEYSTORE_PASSWORD:-android}"
if [ ! -f "$KEY" ]; then
 if [ -n "${QN_KEYSTORE:-}" ]; then echo 'Configured signing key is missing.'; exit 1; fi
 keytool -genkeypair -keystore "$KEY" -storepass "$PASS" -keypass "$PASS" -alias quicknotes -keyalg RSA -keysize 3072 -validity 10000 -dname 'CN=QuickNotes Developer'
fi
python3 scripts/train_grocery.py
python3 scripts/create_alarm.py
GRADLE="$(command -v gradle || true)"
if [ -z "$GRADLE" ]; then [ -x .tools/gradle-8.9/bin/gradle ] || ./install.sh; GRADLE="$PWD/.tools/gradle-8.9/bin/gradle"; fi
"$GRADLE" --no-daemon :app:assembleRelease
cp -a app/build/intermediates/javac/release/compileReleaseJavaWithJavac/classes/. build/classes/
unzip -oq app/build/intermediates/compile_and_runtime_not_namespaced_r_class_jar/release/processReleaseResources/R.jar -d build/classes
"$BT/zipalign" -f -P 16 4 app/build/outputs/apk/release/app-release-unsigned.apk build/aligned.apk
"$BT/apksigner" sign --ks "$KEY" --ks-pass "pass:$PASS" --out dist/QuickNotes-v1.8.4.apk build/aligned.apk
"$BT/apksigner" verify --verbose dist/QuickNotes-v1.8.4.apk

python3 scripts/check_apk_alignment.py dist/QuickNotes-v1.8.4.apk
