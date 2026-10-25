# Land Bangla Orchid — শুরু করার নির্দেশনা (বাংলা)

## এই ZIP-এ কী আছে
- `lib/main.dart`: Flutter অ্যাপের স্ক্রিন ও ফাংশনের সোর্স কোড
- `pubspec.yaml`: Flutter package/dependency
- `.github/workflows/android-apk.yml`: GitHub Actions দিয়ে APK তৈরির workflow
- `firestore/`: Firestore ও Storage security rules-এর খসড়া
- `functions/`: বকেয়া ফি রিমাইন্ডারের Cloud Functions সোর্স
- `README_BN.md`: অ্যাপের বিস্তারিত নোট

## GitHub-এ সঠিকভাবে আপলোড
1. এই ZIP ডাউনলোড করে Extract করুন।
2. Extract করা `land_bangla_orchid_flutter` ফোল্ডারের ভেতরের সব ফাইল/ফোল্ডার repository-এর root-এ আপলোড করবেন। বাইরের ফোল্ডারটি নিজে আপলোড করবেন না।
3. বিশেষ করে `.github/workflows/android-apk.yml` অবশ্যই এই সঠিক পথে থাকতে হবে। Android-এর hidden `.github` ফোল্ডার আপলোড না হলে GitHub ওয়েবসাইটে আলাদা করে তৈরি করুন।
4. `lib/main.dart`, `pubspec.yaml`, `functions`, `firestore` ফাইলগুলোও root-এ থাকতে হবে। শুধু `.html` ফাইল আপলোড করলে Flutter APK হবে না।
5. GitHub → Actions → Build Android APK → Run workflow চালান। সবুজ Success হলে run-এর পেজে Artifacts → `land-bangla-orchid-apk` ডাউনলোড করুন। ZIP extract করে `app-release.apk` ইনস্টল করুন।

## গুরুত্বপূর্ণ সীমাবদ্ধতা
- এই workflow APK তৈরি করার চেষ্টা করে; Flutter build সফল হয়েছে বলে ZIP-টিকে যাচাইকৃত APK ভাববেন না। GitHub Actions-এ সফল রান না হওয়া পর্যন্ত APK তৈরি হয়েছে বলা যাবে না।
- Firebase কনফিগার না করা থাকলে অ্যাপটি Offline Demo স্ক্রিন দেখাবে। আসল login/database চালাতে Firebase project ও app configuration লাগবে।
- SMS/email reminder চালাতে Cloud Functions deploy এবং SMS/email provider credentials লাগবে। এগুলো এখনও স্বয়ংক্রিয়ভাবে সক্রিয় নয়।
- কোনো বাস্তব মালিকের ব্যক্তিগত তথ্য বা পাসওয়ার্ড পাবলিক repository-তে দেবেন না।
