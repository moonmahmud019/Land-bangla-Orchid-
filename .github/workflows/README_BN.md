# Land Bangla Orchid — Flutter + Firebase

বাংলা ইন্টারফেসসহ অ্যাসোসিয়েশন ব্যবস্থাপনা অ্যাপের সোর্স প্রকল্প।

- ভবনের ঠিকানা: ৮৯/২/৯, আর কে মিশন রোড, গোপীবাগ সপ্তম গলি, ঢাকা
- মাসিক চাঁদা: প্রতি ফ্ল্যাট ৳৩,০০০
- ভূমিকা: `admin` ও `owner`
- মডিউল: লগইন, ড্যাশবোর্ড, ফ্ল্যাট/মালিকের রেকর্ড, চাঁদা পেমেন্ট লেজার, নোটিশ, মাসের ১০ তারিখে SMS ও ইমেইল বকেয়া রিমাইন্ডার

## গুরুত্বপূর্ণ সীমা
এই ফোল্ডারটি **সোর্স কোড ও সেটআপ কিট**, ইতিমধ্যে তৈরি/সাইন করা APK নয়। এই পরিবেশে Flutter SDK/Android build chain নেই এবং আপনার Firebase প্রজেক্টের credentials-ও নেই। তাই প্রকৃত অনলাইন ডেটাবেস চালু বা APK compile করা হয়নি। `flutterfire configure` চালিয়ে নিজস্ব Firebase প্রজেক্ট যুক্ত করতে হবে।

## ১. যা লাগবে
1. Flutter SDK ও Android Studio ইনস্টল করুন।
2. Firebase Console-এ নতুন Firebase project খুলুন: https://console.firebase.google.com/
3. Authentication → Sign-in method → Email/Password চালু করুন।
4. Firestore Database তৈরি করুন; Storage চালু করুন যদি মালিকের ছবি আপলোড যোগ করেন।
5. Node/npm ও Firebase CLI ইনস্টল করে `firebase login` করুন।
6. FlutterFire CLI ইনস্টল করুন: `dart pub global activate flutterfire_cli`

## ২. Firebase সংযোগ
প্রকল্পের ফোল্ডারে (এই প্যাকেজে মূল Dart সোর্স ও Firebase rules আছে; Flutter-এর generated platform scaffolding সম্পূর্ণ নেই):

```bash
flutter create . --platforms=android,web
flutter pub get
flutterfire configure
```

এটি `lib/firebase_options.dart` তৈরি করবে। বর্তমান `main.dart`-এ `Firebase.initializeApp()` রাখা আছে; চাইলে generated options সহ `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` ব্যবহার করুন এবং `firebase_options.dart` import করুন।

Firebase Console → Firestore → Rules-এ `firestore/firestore.rules`-এর নিয়ম প্রকাশ করুন। Storage Rules-এ `firestore/storage.rules` প্রকাশ করুন। Production-এ Rules ভালোভাবে পরীক্ষা না করে প্রকাশ করবেন না।

## ৩. প্রথম অ্যাডমিন তৈরি
1. Authentication → Users-এ অ্যাডমিনের Email/Password account তৈরি করুন।
2. Firestore-এ `users` collection তৈরি করুন। Document ID হবে Auth-এর ওই ব্যবহারকারীর UID।
3. ওই document-এ লিখুন:

```json
{
  "name": "সমিতির অ্যাডমিন",
  "role": "admin"
}
```

4. প্রত্যেক ফ্ল্যাট মালিকের Auth account তৈরি করে `users/{uid}`-এ লিখুন:

```json
{
  "name": "মালিকের নাম",
  "role": "owner",
  "flatId": "flats collection-এর document ID"
}
```

**গুরুত্বপূর্ণ:** `users`-এর role/flatId ব্যবহারকারী নিজে বদলাতে পারবে না—Rules তাই admin-only রেখেছে। কখনোই অ্যাপের ভিতরে Firebase Admin SDK/service-account key রাখবেন না।

## ৪. রান ও APK তৈরি

```bash
flutter run
flutter analyze
flutter build apk --release
```

APK পাওয়া যায় `build/app/outputs/flutter-apk/app-release.apk`-এ। Play Store বা অন্যত্র বিতরণের আগে Android application ID, app icon, privacy notice, signed release এবং বাস্তব ডিভাইসে পরীক্ষা সম্পন্ন করুন।

## ৫. অনলাইন ওয়েব সংস্করণ (ঐচ্ছিক)
একই Flutter code web-এ চালাতে:

```bash
flutter config --enable-web
flutter create . --platforms=android,web
flutter build web
```

Firebase Hosting-এর জন্য Firebase CLI দিয়ে `firebase init hosting` চালিয়ে public directory `build/web` নির্বাচন করুন, তারপর `firebase deploy`। Web Authentication-এর authorized domains সেট করুন।

## ৬. মাসের ১০ তারিখে SMS + ইমেইল রিমাইন্ডার
এই সংস্করণে Firebase Cloud Functions-এর scheduled function যুক্ত করা হয়েছে। এটি প্রতি মাসের ১১ তারিখ বাংলাদেশ সময় সকাল ৯টায় চলে (১০ তারিখের পেমেন্টের শেষ সময় পার হওয়ার পর)। বর্তমান মাসের `payments` collection-এ ওই ফ্ল্যাটের মোট জমা ৳৩,০০০-এর কম হলে অথবা `flats` document-এ আগের বকেয়া (`arrears > 0`) থাকলে সংশ্লিষ্ট মালিককে SMS ও ইমেইল পাঠানোর চেষ্টা করে। বর্তমান মাসের পেমেন্ট যোগ করে হিসাব করা হয়। SMS ও ইমেইলের আলাদা লগ রাখা হয়, যাতে সফল চ্যানেলে একই মাসে পুনরায় মেসেজ না যায়।

### ফ্ল্যাটের রেকর্ডে যা দিতে হবে
- `phone`: দেশের কোডসহ মোবাইল নম্বর সবচেয়ে ভালো; যেমন `+8801XXXXXXXXX`। বাংলাদেশের ১১-সংখ্যার `01XXXXXXXXX` নম্বরও স্বয়ংক্রিয়ভাবে `+88` যোগ করে পাঠানো হয়।
- `email`: মালিকের কার্যকর ইমেইল ঠিকানা।
- `arrears`: বর্তমান মোট বকেয়া টাকা; বকেয়া না থাকলে `0`। এই প্রাথমিক সংস্করণে রিমাইন্ডার চালানোর ভিত্তি হলো এই `arrears` মান।

### SMS গেটওয়ে ও ইমেইল সংযোগ
এই প্রকল্পে SMS-এর জন্য Twilio REST API এবং ইমেইলের জন্য SMTP/Nodemailer adapter দেওয়া আছে। Twilio-তে অ্যাকাউন্ট/সেন্ডার নম্বর ও বাংলাদেশে SMS পাঠানোর অনুমতি/মূল্য যাচাই করুন। SMTP provider-এর credential তৈরি করুন। তারপর প্রকল্পের রুট থেকে:

```bash
cd functions
npm install
cd ..
firebase login
firebase use YOUR_FIREBASE_PROJECT_ID
firebase functions:secrets:set TWILIO_ACCOUNT_SID
firebase functions:secrets:set TWILIO_AUTH_TOKEN
firebase functions:secrets:set TWILIO_FROM_NUMBER
firebase functions:secrets:set SMTP_HOST
firebase functions:secrets:set SMTP_PORT
firebase functions:secrets:set SMTP_USER
firebase functions:secrets:set SMTP_PASS
firebase functions:secrets:set REMINDER_FROM_EMAIL
firebase deploy --only functions,firestore:rules
```

প্রতিটি `secrets:set` কমান্ডে প্রম্পট এলে সংশ্লিষ্ট গোপন মান দিন; কোনো API key বা password সোর্স কোডে লিখবেন না। `SMTP_PORT` সাধারণত `587` (STARTTLS) অথবা `465` (SSL/TLS)। প্রজেক্টে Cloud Functions deploy করার জন্য Firebase-এর প্রয়োজনীয় billing plan/Blaze এবং Google Cloud billing সক্রিয় থাকতে পারে; deploy-এর আগে বর্তমান Firebase pricing যাচাই করুন। SMTP/SMS provider অনুযায়ী আলাদা খরচ হবে।

### পরীক্ষা ও নিরাপত্তা
- প্রথমে test/staging Firebase project-এ পরীক্ষা করুন। Cloud Scheduler ও Functions deploy সফল হয়েছে কি না দেখুন।
- একটি test flat-এ `phone`, `email` এবং `arrears: 3000` দিয়ে test করুন। বাস্তব schedule-এর অপেক্ষা না করে প্রয়োজনে Functions Emulator বা আলাদা manual test function ব্যবহার করুন; এই প্যাকেজে public HTTP trigger রাখা হয়নি।
- `notificationLogs` ও `systemLogs` ক্লায়েন্ট থেকে লেখা বন্ধ; এগুলো Cloud Function-ই লিখবে।
- SMS/ইমেইল সরবরাহকারীর ব্যর্থতা হলে `notificationLogs`-এ `failed` status লেখা হয়। সংশ্লিষ্ট provider ঠিক করে পরবর্তী মাসের আগে পুনরায় পরীক্ষা করুন। সফল চ্যানেল ওই মাসে পুনরায় পাঠানো হয় না।
- রিমাইন্ডার শুধু `arrears > 0` দেখে; সঠিক ফলের জন্য অ্যাডমিনকে বকেয়ার পরিমাণ সঠিক রাখতে হবে। ভবিষ্যতে মাসভিত্তিক invoice/ledger যোগ করে অটোমেটিক বকেয়া হিসাব করা উচিত।

## ডেটা মডেল
- `users/{uid}`: `name`, `role` (`admin`/`owner`), `flatId`
- `flats/{flatId}`: `flatNumber`, `name`, `phone`, `address`, `monthlyFee` (3000), `arrears`, timestamps
- `payments/{paymentId}`: `flatId`, `flatNumber`, `ownerName`, `amount`, `month` (`YYYY-MM`), `method`, `paidAt`, `recordedBy`
- `notices/{noticeId}`: `title`, `body`, `createdAt`, `createdBy`
- `notificationLogs/{month_flatId_sms|email}`: `flatId`, `channel`, `recipient`, `status`, `sentAt`/`attemptedAt`
- `systemLogs/{logId}`: নির্ধারিত রিমাইন্ডার ফাংশনের রান-লগ

## বাস্তব ব্যবহারের আগে পর্যালোচনা
- এই প্রাথমিক সংস্করণে মালিকের ছবি নির্বাচন/আপলোড UI, স্বয়ংক্রিয় মাসিক invoice তৈরি, রসিদ PDF, বিকাশ/নগদ পেমেন্ট গেটওয়ে, Push Notification, CSV/Excel রিপোর্ট ও পূর্ণাঙ্গ audit log এখনও যুক্ত নয়।
- পেমেন্ট নথিভুক্ত করার সময় বর্তমান কোড `arrears` থেকে জমার টাকা বাদ দেয়; পূর্ণাঙ্গ বকেয়া হিসাবের জন্য মাসভিত্তিক invoice/ledger, আংশিক পেমেন্ট, অতিরিক্ত জমা, refund এবং duplicate-payment validation যোগ করা উচিত।
- Firebase Storage rules-এ `firestore.get` ব্যবহার করলে Storage Rules-এর Firebase/Firestore interoperability ও billing/configuration যাচাই করুন; প্রয়োজনে Firebase documentation অনুসারে উপযুক্ত rule pattern ব্যবহার করুন।
- অ্যাপটি হিসাবরক্ষণ/বাস্তব অর্থের রেকর্ডে ব্যবহার করার আগে staging Firebase project-এ Rules, concurrent transactions, data privacy, backup ও restore পরীক্ষা করুন।


## সংস্করণ ৩: ২৪টি ফ্ল্যাট, বাসিন্দা ও ১৪টি গ্যারেজ

- মোট ফ্ল্যাটের কাঠামো: ২৪টি।
- প্রাথমিক খালি রেকর্ড তৈরি করলে ফ্ল্যাট ১–১৩-কে “মালিক নিজে থাকেন” এবং ফ্ল্যাট ১৪–২৪-কে “ভাড়া দেওয়া” হিসেবে প্রাথমিকভাবে চিহ্নিত করা হয়। অ্যাডমিন এগুলো পরিবর্তন করতে পারবেন। এটি কেবল প্রাথমিক ডিফল্ট; প্রকৃত বাসিন্দার তথ্য দিয়ে যাচাই করে আপডেট করতে হবে।
- প্রতিটি ফ্ল্যাটে মালিকের নাম, ছবি, মোবাইল, ইমেইল এবং ভাড়াটিয়ার নাম, ছবি, মোবাইল, ইমেইল আলাদাভাবে সংরক্ষণ/পরিবর্তন করা যায়। ছবি Firebase Storage-এ আপলোড হয়।
- গ্রাউন্ড ফ্লোরের ১৪টি গ্যারেজের রেকর্ড তৈরি, অবস্থা (খালি/ব্যবহৃত), বরাদ্দপ্রাপ্ত ব্যক্তি/ফ্ল্যাট, মোবাইল ও ইমেইল সম্পাদনা করা যায়।
- অ্যাপ থেকে “২৪টি ফ্ল্যাটের খালি রেকর্ড তৈরি” এবং “১৪টি গ্যারেজের রেকর্ড তৈরি” বোতাম অ্যাডমিন হিসেবে একবার চালাতে হবে। আগে থাকা একই নম্বরের রেকর্ড ডুপ্লিকেট করা হয় না।
- ছবির আপলোডের জন্য Firebase Storage চালু ও `firestore/storage.rules`-এর নিয়ম deploy করতে হবে।
- ভাড়াটিয়ার তথ্য সংবেদনশীল; বাস্তব তথ্য যোগ করার আগে অনুমোদিত অ্যাডমিন অ্যাকাউন্ট ও নিরাপত্তা নিয়ম পরীক্ষা করুন। এই প্রাথমিক প্রকল্পে অ্যাডমিনই প্রোফাইল সম্পাদনা/ছবি আপলোড করতে পারবেন।

**গুরুত্বপূর্ণ তথ্য যাচাই:** আপনি বলেছেন ২৪টি ফ্ল্যাট, ১৪ জন মালিক, ১৩টি ফ্ল্যাটে মালিক থাকেন এবং বাকি ১১টি ভাড়া। প্রকল্পে এই ১৩/১১ অনুপাত প্রাথমিকভাবে বসানো হয়েছে; ১৪ জন মালিকের মধ্যে যৌথ মালিকানা/একই ফ্ল্যাটে একাধিক মালিক থাকলে প্রকৃত তথ্য অনুযায়ী মালিকের তথ্য পূরণ করুন।
