# শুধু Android ফোন দিয়ে APK তৈরি (বাংলা নির্দেশিকা)

এই প্রকল্পে GitHub Actions-এর বিল্ড ওয়ার্কফ্লো যোগ করা আছে। GitHub-এর ফ্রি/অনুমোদিত Actions রান হলে APK-টি Artifact হিসেবে ডাউনলোড করা যাবে। বিল্ডের জন্য GitHub অ্যাকাউন্ট ও ইন্টারনেট দরকার।

## ধাপ
1. ZIP ফাইলটি ফোনে ডাউনলোড করে Extract করুন।
2. Chrome-এ https://github.com খুলে সাইন ইন করুন।
3. `New repository` চাপুন; নাম দিন `land-bangla-orchid`, Private বেছে `Create repository` করুন।
4. প্রকল্পের ভিতরের সব ফাইল/ফোল্ডার রিপোজিটরির root-এ আপলোড করুন। `land_bangla_orchid_flutter` ফোল্ডারটিকে পুরোটা root-এর ভিতরে না রেখে তার **ভিতরের** ফাইলগুলো root-এ রাখুন, যাতে `.github/workflows/android-apk.yml` সঠিক স্থানে থাকে। ফোনের ব্রাউজারে `Add file` → `Upload files` ব্যবহার করা যায়; hidden `.github` ফোল্ডার আপলোড করতে অসুবিধা হলে GitHub-এর web editor দিয়ে `.github/workflows/android-apk.yml` ফাইলটি তৈরি করতে হবে।
5. `Commit changes` করুন। তারপর রিপোজিটরির `Actions` ট্যাবে যান এবং `Build Android APK` workflow নির্বাচন করুন। `Run workflow` দেখা গেলে সেটি চাপুন। প্রথম push-এ workflow নিজে থেকেই চলতে পারে।
6. Build শেষ হলে সবুজ `Success` দেখুন; workflow run খুলে পৃষ্ঠার নিচের `Artifacts` অংশ থেকে `land-bangla-orchid-apk` ডাউনলোড করুন। ZIP artifact extract করে `app-release.apk` ফাইলটি ফোনে খুলে ইনস্টল করুন। Android চাইলে `Install unknown apps` অনুমতি দিতে হবে—শুধু নিজের তৈরি/বিশ্বস্ত APK-কে অনুমতি দিন।

## গুরুত্বপূর্ণ
- এই workflow APK বিল্ড করার চেষ্টা করে; এই পরিবেশে বিল্ড চালিয়ে যাচাই করা হয়নি। কোনো compile error হলে `Actions`-এর log দেখতে হবে।
- Firebase কনফিগারেশন না থাকলে অ্যাপটি নমুনা/অফলাইন ডেমো স্ক্রিন দেখাবে। এটি বাস্তব মালিকের তথ্য, পেমেন্ট বা ছবি সংরক্ষণ করবে না।
- অনলাইন লগইন/ডেটাবেস চালাতে Firebase Console-এ Android app যোগ করে `google-services.json` ও FlutterFire configuration সেট করতে হবে। SMS/ইমেইল রিমাইন্ডারের জন্য আলাদা provider ও credentials লাগবে।
- GitHub repository-তে বাস্তব বাসিন্দার ব্যক্তিগত তথ্য, পাসওয়ার্ড, Firebase service-account key বা SMS/email secret আপলোড করবেন না।
