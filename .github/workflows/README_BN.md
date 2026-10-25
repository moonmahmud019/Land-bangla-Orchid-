# Scheduled Reminder Function (বাংলা)

- সময়: প্রতি মাসের ১১ তারিখ, সকাল ৯:০০, `Asia/Dhaka`
- যোগ্যতা: Firestore `flats` document-এ `arrears > 0`
- প্রাপক: সংশ্লিষ্ট ফ্ল্যাট মালিক
- চ্যানেল: SMS (Twilio) + Email (SMTP)
- SMS/ইমেইল প্রতিটি আলাদা মাসিক log ID দিয়ে idempotent করা হয়েছে।

রুট README_BN.md-এর `মাসের ১০ তারিখে SMS + ইমেইল রিমাইন্ডার` অংশ অনুসারে secrets সেট করে deploy করুন। Provider account, verified sender/recipient requirements, delivery support in Bangladesh, এবং billing আলাদাভাবে যাচাই করতে হবে।
