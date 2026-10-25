import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

const associationName = 'Land Bangla Orchid';
const associationAddress = '৮৯/২/৯, আর কে মিশন রোড, গোপীবাগ সপ্তম গলি, ঢাকা';
const monthlyFee = 3000;
bool firebaseReady = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(); // Configure with: flutterfire configure
    firebaseReady = true;
  } catch (_) {
    // Without Firebase credentials, launch a clearly labelled offline demo.
    firebaseReady = false;
  }
  runApp(const OrchidApp());
}

class OrchidApp extends StatelessWidget {
  const OrchidApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: associationName,
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff176b43)), useMaterial3: true, fontFamily: 'Roboto'),
    home: firebaseReady ? const AuthGate() : const OfflineDemoPage(),
  );
}

class OfflineDemoPage extends StatelessWidget {
  const OfflineDemoPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text(associationName), backgroundColor: const Color(0xff176b43), foregroundColor: Colors.white),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      const Text(associationAddress, textAlign: TextAlign.center),
      const SizedBox(height: 18),
      const Card(child: Padding(padding: EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('পরীক্ষামূলক ডেমো মোড', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('Firebase সংযুক্ত নেই। নিচের তথ্যগুলো নমুনা; এখানে কোনো বাস্তব পেমেন্ট বা বাসিন্দার তথ্য সংরক্ষণ হচ্ছে না.'),
      ]))),
      const SizedBox(height: 10),
      const Row(children: [Expanded(child: _DemoStat(title: 'মোট ফ্ল্যাট', value: '২৪', icon: Icons.apartment)), SizedBox(width: 10), Expanded(child: _DemoStat(title: 'মাসিক ফি', value: '৳৩,০০০', icon: Icons.payments))]),
      const SizedBox(height: 10),
      const Row(children: [Expanded(child: _DemoStat(title: 'গ্যারেজ', value: '১৪', icon: Icons.garage)), SizedBox(width: 10), Expanded(child: _DemoStat(title: 'নোটিশ', value: 'ডেমো', icon: Icons.campaign))]),
      const SizedBox(height: 18),
      const Text('মেনু', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const ListTile(leading: Icon(Icons.people), title: Text('ফ্ল্যাট ও মালিক/ভাড়াটিয়ার তথ্য'), subtitle: Text('Firebase সংযোগের পরে চালু হবে')),
      const ListTile(leading: Icon(Icons.receipt_long), title: Text('মাসিক ফি ও বকেয়া'), subtitle: Text('নমুনা স্ক্রিন; বাস্তব হিসাব নয়')),
      const ListTile(leading: Icon(Icons.garage), title: Text('১৪টি গ্যারেজ'), subtitle: Text('বরাদ্দের তথ্য Firebase-এ সংরক্ষণ হবে')),
      const ListTile(leading: Icon(Icons.notifications_active), title: Text('SMS ও ইমেইল রিমাইন্ডার'), subtitle: Text('সেবা সংযুক্ত ও কনফিগার করা বাকি')),
      const SizedBox(height: 12),
      const Text('অনলাইন লগইন, তথ্য সংরক্ষণ, ছবি আপলোড এবং রিমাইন্ডার চালাতে অ্যাডমিনের Firebase কনফিগারেশন প্রয়োজন।', style: TextStyle(color: Colors.black54)),
    ]),
  );
}

class _DemoStat extends StatelessWidget {
  final String title; final String value; final IconData icon;
  const _DemoStat({required this.title, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(children: [Icon(icon, size: 28, color: const Color(0xff176b43)), const SizedBox(height: 8), Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), Text(title)])));
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) return const Scaffold(body: Center(child: CircularProgressIndicator()));
      if (snapshot.data == null) return const LoginPage();
      return const RoleGate();
    },
  );
}

class RoleGate extends StatelessWidget {
  const RoleGate({super.key});
  @override
  Widget build(BuildContext context) => FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
    future: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get(),
    builder: (context, snap) {
      if (snap.connectionState == ConnectionState.waiting) return const Scaffold(body: Center(child: CircularProgressIndicator()));
      if (!snap.hasData || !snap.data!.exists) return Scaffold(appBar: AppBar(title: const Text(associationName)), body: const Padding(padding: EdgeInsets.all(24), child: Text('আপনার অ্যাকাউন্টের ভূমিকা নির্ধারিত হয়নি। সমিতির অ্যাডমিনের সঙ্গে যোগাযোগ করুন।')));
      final data = snap.data!.data()!;
      return HomePage(isAdmin: data['role'] == 'admin', userData: data);
    },
  );
}

class LoginPage extends StatefulWidget { const LoginPage({super.key}); @override State<LoginPage> createState() => _LoginPageState(); }
class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController(); final password = TextEditingController(); bool busy = false; String? error;
  Future<void> login() async {
    if (email.text.trim().isEmpty || password.text.isEmpty) { setState(() => error = 'ইমেইল ও পাসওয়ার্ড লিখুন।'); return; }
    setState(() { busy = true; error = null; });
    try { await FirebaseAuth.instance.signInWithEmailAndPassword(email: email.text.trim(), password: password.text); }
    on FirebaseAuthException catch (e) { setState(() => error = e.code == 'user-not-found' || e.code == 'invalid-credential' ? 'লগইন তথ্য সঠিক নয়।' : 'লগইন করা যায়নি: ${e.message ?? e.code}'); }
    finally { if (mounted) setState(() => busy = false); }
  }
  @override void dispose() { email.dispose(); password.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Scaffold(body: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    const Icon(Icons.apartment_rounded, size: 72, color: Color(0xff176b43)), const SizedBox(height: 12), Text(associationName, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)), const SizedBox(height: 8), const Text(associationAddress, textAlign: TextAlign.center), const SizedBox(height: 28), const Text('অ্যাকাউন্টে প্রবেশ করুন', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)), const SizedBox(height: 16), TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'ইমেইল', prefixIcon: Icon(Icons.email_outlined), border: OutlineInputBorder())), const SizedBox(height: 12), TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'পাসওয়ার্ড', prefixIcon: Icon(Icons.lock_outline), border: OutlineInputBorder()), onSubmitted: (_) => login()), if (error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(error!, style: const TextStyle(color: Colors.red))), const SizedBox(height: 16), FilledButton(onPressed: busy ? null : login, child: Padding(padding: const EdgeInsets.all(12), child: busy ? const CircularProgressIndicator() : const Text('লগইন'))), const SizedBox(height: 12), const Text('নতুন অ্যাকাউন্ট খুলতে সমিতির অ্যাডমিনের সঙ্গে যোগাযোগ করুন।', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54))
  ])))));
}

class HomePage extends StatefulWidget { final bool isAdmin; final Map<String, dynamic> userData; const HomePage({super.key, required this.isAdmin, required this.userData}); @override State<HomePage> createState() => _HomePageState(); }
class _HomePageState extends State<HomePage> {
  int tab = 0;
  @override Widget build(BuildContext context) {
    final pages = <Widget>[
      Dashboard(isAdmin: widget.isAdmin),
      OwnersPage(isAdmin: widget.isAdmin, userData: widget.userData),
      PaymentsPage(isAdmin: widget.isAdmin, userData: widget.userData),
      NoticesPage(isAdmin: widget.isAdmin),
      GaragesPage(isAdmin: widget.isAdmin),
    ];
    return Scaffold(appBar: AppBar(title: const Text(associationName), actions: [IconButton(tooltip: 'লগআউট', onPressed: () => FirebaseAuth.instance.signOut(), icon: const Icon(Icons.logout))]), body: Column(children: [Container(width: double.infinity, padding: const EdgeInsets.fromLTRB(16, 4, 16, 12), color: Theme.of(context).colorScheme.surfaceContainerLow, child: const Text(associationAddress, textAlign: TextAlign.center)), Expanded(child: pages[tab])]), bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (v) => setState(() => tab = v), destinations: const [NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'ড্যাশবোর্ড'), NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'ফ্ল্যাট মালিক'), NavigationDestination(icon: Icon(Icons.payments_outlined), selectedIcon: Icon(Icons.payments), label: 'চাঁদা'), NavigationDestination(icon: Icon(Icons.campaign_outlined), selectedIcon: Icon(Icons.campaign), label: 'নোটিশ'), NavigationDestination(icon: Icon(Icons.garage_outlined), selectedIcon: Icon(Icons.garage), label: 'গ্যারেজ')]),
    );
  }
}

class Dashboard extends StatelessWidget {
  final bool isAdmin; const Dashboard({super.key, required this.isAdmin});
  @override Widget build(BuildContext context) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: FirebaseFirestore.instance.collection('flats').snapshots(),
    builder: (context, snap) {
      final flats = snap.data?.docs ?? [];
      final total = flats.length * monthlyFee;
      final due = flats.fold<int>(0, (sum, d) => sum + ((d.data()['arrears'] as num?)?.toInt() ?? 0));
      return ListView(padding: const EdgeInsets.all(16), children: [Text('সমিতির সারসংক্ষেপ', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 14), GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: MediaQuery.sizeOf(context).width > 600 ? 4 : 2, childAspectRatio: 1.45, crossAxisSpacing: 12, mainAxisSpacing: 12, children: [MetricCard(title: 'মোট ফ্ল্যাট', value: '${flats.length}', icon: Icons.apartment), MetricCard(title: 'মাসিক নির্ধারিত চাঁদা', value: money(total), icon: Icons.account_balance_wallet_outlined), MetricCard(title: 'বকেয়া (রেকর্ডকৃত)', value: money(due), icon: Icons.pending_actions), MetricCard(title: 'মাসিক চাঁদা/ফ্ল্যাট', value: money(monthlyFee), icon: Icons.payments)]), const SizedBox(height: 18), Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('সমিতির তথ্য', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), const SizedBox(height: 8), const Text('মাসিক চাঁদা: ৳৩,০০০ প্রতি ফ্ল্যাট'), const SizedBox(height: 4), const Text('বকেয়ার হিসাব ফ্ল্যাটের arrears রেকর্ড থেকে দেখানো হয়।'), if (!isAdmin) const Text('আপনার অ্যাকাউন্টে অনুমোদিত তথ্যই দেখানো হবে।')]))), if (snap.hasError) const Text('তথ্য লোড করা যায়নি। Firebase Rules ও সংযোগ পরীক্ষা করুন.')]);
    });
}
class MetricCard extends StatelessWidget { final String title, value; final IconData icon; const MetricCard({super.key, required this.title, required this.value, required this.icon}); @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Icon(icon, color: Theme.of(context).colorScheme.primary), Text(title, style: const TextStyle(fontSize: 12)), FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)))]))); }
String money(num n) => '৳${NumberFormat('#,##0', 'en_US').format(n)}';

class OwnersPage extends StatelessWidget {
  final bool isAdmin; final Map<String, dynamic> userData; const OwnersPage({super.key, required this.isAdmin, required this.userData});
  @override Widget build(BuildContext context) => Column(children: [
    if (isAdmin) Padding(padding: const EdgeInsets.all(12), child: Wrap(spacing: 8, children: [FilledButton.icon(onPressed: () => showDialog(context: context, builder: (_) => const OwnerDialog()), icon: const Icon(Icons.add), label: const Text('ফ্ল্যাট যোগ করুন')), OutlinedButton.icon(onPressed: () => seedFlats(context), icon: const Icon(Icons.playlist_add), label: const Text('২৪টি ফ্ল্যাটের খালি রেকর্ড তৈরি'))])),
    Expanded(child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(stream: FirebaseFirestore.instance.collection('flats').orderBy('flatNumber').snapshots(), builder: (context, snap) {
      if (snap.hasError) return const Center(child: Text('তথ্য দেখা যাচ্ছে না। Rules/permissions পরীক্ষা করুন।')); if (!snap.hasData) return const Center(child: CircularProgressIndicator());
      var docs = snap.data!.docs; if (!isAdmin) docs = docs.where((d) => d.id == userData['flatId']).toList();
      if (docs.isEmpty) return const Center(child: Text('এখনও কোনো ফ্ল্যাটের তথ্য নেই।'));
      return ListView.builder(itemCount: docs.length, itemBuilder: (context, i) { final d = docs[i]; final m = d.data(); final ownerPhoto = (m['ownerPhotoUrl'] ?? m['photoUrl']) as String?; final tenantPhoto = m['tenantPhotoUrl'] as String?; final ownerName = (m['ownerName'] ?? m['name'] ?? 'নাম নেই').toString(); final tenantName = (m['tenantName'] ?? '').toString();
        return Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5), child: ListTile(
          leading: CircleAvatar(backgroundImage: ownerPhoto != null && ownerPhoto.isNotEmpty ? NetworkImage(ownerPhoto) : null, child: ownerPhoto == null || ownerPhoto.isEmpty ? Text(ownerName.characters.first) : null),
          title: Text('${m['flatNumber'] ?? '—'} · $ownerName'),
          subtitle: Text('মালিক: ${m['ownerPhone'] ?? m['phone'] ?? '—'} · ${m['ownerEmail'] ?? m['email'] ?? '—'}\n${tenantName.isNotEmpty ? 'ভাড়াটিয়া: $tenantName · ${m['tenantPhone'] ?? 'মোবাইল নেই'}' : 'অবস্থা: ${m['occupancy'] == 'rented' ? 'ভাড়ার জন্য নির্ধারিত' : 'মালিক নিজে থাকেন'}'}\nবকেয়া: ${money((m['arrears'] as num?) ?? 0)}', maxLines: 3), isThreeLine: true,
          trailing: isAdmin ? PopupMenuButton<String>(onSelected: (v) { if (v == 'edit') showDialog(context: context, builder: (_) => OwnerDialog(docId: d.id, initial: m)); if (v == 'delete') confirmDelete(context, d.id); }, itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('সম্পাদনা')), PopupMenuItem(value: 'delete', child: Text('মুছুন'))]) : null)); }); }))]);
}

Future<void> seedFlats(BuildContext context) async {
  final db = FirebaseFirestore.instance; final existing = await db.collection('flats').get(); final known = existing.docs.map((d) => d.data()['flatNumber'].toString()).toSet();
  final batch = db.batch(); int added = 0;
  for (int i = 1; i <= 24; i++) { final number = 'ফ্ল্যাট-${i.toString().padLeft(2, '0')}'; if (!known.contains(number)) { final ref = db.collection('flats').doc('flat_${i.toString().padLeft(2, '0')}'); batch.set(ref, {'flatNumber': number, 'ownerName': '', 'ownerPhone': '', 'ownerEmail': '', 'ownerPhotoUrl': '', 'tenantName': '', 'tenantPhone': '', 'tenantEmail': '', 'tenantPhotoUrl': '', 'occupancy': i <= 13 ? 'owner_occupied' : 'rented', 'arrears': 0, 'monthlyFee': monthlyFee, 'address': associationAddress, 'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()}); added++; } }
  if (added > 0) await batch.commit(); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(added == 0 ? '২৪টি ফ্ল্যাটের রেকর্ড আগে থেকেই আছে।' : '$addedটি ফ্ল্যাটের খালি রেকর্ড তৈরি হয়েছে।')));
}

Future<void> confirmDelete(BuildContext context, String id) async { final yes = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('ফ্ল্যাটের তথ্য মুছবেন?'), content: const Text('এই কাজটি ফিরিয়ে নেওয়া যাবে না।'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('বাতিল')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('মুছুন'))])); if (yes == true) await FirebaseFirestore.instance.collection('flats').doc(id).delete(); }

class OwnerDialog extends StatefulWidget { final String? docId; final Map<String, dynamic>? initial; const OwnerDialog({super.key, this.docId, this.initial}); @override State<OwnerDialog> createState() => _OwnerDialogState(); }
class _OwnerDialogState extends State<OwnerDialog> {
 final form = GlobalKey<FormState>(); late final TextEditingController flat, ownerName, ownerPhone, ownerEmail, tenantName, tenantPhone, tenantEmail, arrears, address; String occupancy = 'owner_occupied'; String ownerPhotoUrl = '', tenantPhotoUrl = ''; bool busy = false;
 @override void initState() { super.initState(); final m = widget.initial ?? {}; flat = TextEditingController(text: m['flatNumber'] ?? ''); ownerName = TextEditingController(text: m['ownerName'] ?? m['name'] ?? ''); ownerPhone = TextEditingController(text: m['ownerPhone'] ?? m['phone'] ?? ''); ownerEmail = TextEditingController(text: m['ownerEmail'] ?? m['email'] ?? ''); tenantName = TextEditingController(text: m['tenantName'] ?? ''); tenantPhone = TextEditingController(text: m['tenantPhone'] ?? ''); tenantEmail = TextEditingController(text: m['tenantEmail'] ?? ''); arrears = TextEditingController(text: '${m['arrears'] ?? 0}'); address = TextEditingController(text: m['address'] ?? associationAddress); occupancy = m['occupancy'] ?? 'owner_occupied'; ownerPhotoUrl = m['ownerPhotoUrl'] ?? m['photoUrl'] ?? ''; tenantPhotoUrl = m['tenantPhotoUrl'] ?? ''; }
 @override void dispose() { for (final c in [flat, ownerName, ownerPhone, ownerEmail, tenantName, tenantPhone, tenantEmail, arrears, address]) { c.dispose(); } super.dispose(); }
 Future<void> choosePhoto(bool isOwner) async { try { final x = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 78, maxWidth: 1200); if (x == null) return; final bytes = await x.readAsBytes(); final key = '${widget.docId ?? flat.text.trim().replaceAll('/', '_')}_${isOwner ? 'owner' : 'tenant'}_${DateTime.now().millisecondsSinceEpoch}.jpg'; final ref = FirebaseStorage.instance.ref('owner_photos/$key'); await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg')); final url = await ref.getDownloadURL(); if (!mounted) return; setState(() { if (isOwner) { ownerPhotoUrl = url; } else { tenantPhotoUrl = url; } }); } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ছবি আপলোড হয়নি। Storage সেটিং পরীক্ষা করুন: $e'))); } }
 Future<void> save() async { if (!form.currentState!.validate() || busy) return; setState(() => busy = true); try { final data = <String, dynamic>{'flatNumber': flat.text.trim(), 'name': ownerName.text.trim(), 'phone': ownerPhone.text.trim(), 'email': ownerEmail.text.trim(), 'ownerName': ownerName.text.trim(), 'ownerPhone': ownerPhone.text.trim(), 'ownerEmail': ownerEmail.text.trim(), 'ownerPhotoUrl': ownerPhotoUrl, 'tenantName': tenantName.text.trim(), 'tenantPhone': tenantPhone.text.trim(), 'tenantEmail': tenantEmail.text.trim(), 'tenantPhotoUrl': tenantPhotoUrl, 'occupancy': occupancy, 'arrears': int.tryParse(arrears.text) ?? 0, 'address': address.text.trim(), 'monthlyFee': monthlyFee, 'updatedAt': FieldValue.serverTimestamp()}; final ref = FirebaseFirestore.instance.collection('flats'); if (widget.docId == null) { data['createdAt'] = FieldValue.serverTimestamp(); await ref.add(data); } else { await ref.doc(widget.docId).update(data); } if (mounted) Navigator.pop(context); } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('তথ্য সংরক্ষণ হয়নি: $e'))); } finally { if (mounted) setState(() => busy = false); } }
 Widget photoButton(String label, String url, bool isOwner) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [CircleAvatar(radius: 28, backgroundImage: url.isNotEmpty ? NetworkImage(url) : null, child: url.isEmpty ? const Icon(Icons.person) : null), const SizedBox(width: 12), Expanded(child: Text(label)), OutlinedButton.icon(onPressed: busy ? null : () => choosePhoto(isOwner), icon: const Icon(Icons.upload), label: Text(url.isEmpty ? 'ছবি আপলোড' : 'ছবি পরিবর্তন'))]));
 @override Widget build(BuildContext context) => AlertDialog(title: Text(widget.docId == null ? 'নতুন ফ্ল্যাট যোগ করুন' : 'ফ্ল্যাট ও বাসিন্দার তথ্য সম্পাদনা'), content: SizedBox(width: 480, child: SingleChildScrollView(child: Form(key: form, child: Column(mainAxisSize: MainAxisSize.min, children: [field(flat, 'ফ্ল্যাট নম্বর'), DropdownButtonFormField<String>(value: occupancy, decoration: const InputDecoration(labelText: 'ফ্ল্যাটের অবস্থা', border: OutlineInputBorder()), items: const [DropdownMenuItem(value: 'owner_occupied', child: Text('মালিক নিজে থাকেন')), DropdownMenuItem(value: 'rented', child: Text('ভাড়া দেওয়া'))], onChanged: (v) => setState(() => occupancy = v ?? 'owner_occupied')), const SizedBox(height: 12), const Align(alignment: Alignment.centerLeft, child: Text('ফ্ল্যাট মালিকের তথ্য', style: TextStyle(fontWeight: FontWeight.bold))), photoButton('মালিকের ছবি', ownerPhotoUrl, true), field(ownerName, 'মালিকের নাম'), field(ownerPhone, 'মালিকের মোবাইল নম্বর', keyboard: TextInputType.phone), field(ownerEmail, 'মালিকের ইমেইল', keyboard: TextInputType.emailAddress), const Divider(), const Align(alignment: Alignment.centerLeft, child: Text('ভাড়াটিয়ার তথ্য (ভাড়া দেওয়া হলে)', style: TextStyle(fontWeight: FontWeight.bold))), photoButton('ভাড়াটিয়ার ছবি', tenantPhotoUrl, false), field(tenantName, 'ভাড়াটিয়ার নাম', requiredField: false), field(tenantPhone, 'ভাড়াটিয়ার মোবাইল নম্বর', keyboard: TextInputType.phone, requiredField: false), field(tenantEmail, 'ভাড়াটিয়ার ইমেইল', keyboard: TextInputType.emailAddress, requiredField: false), const Divider(), field(arrears, 'মোট বকেয়া (টাকা)', keyboard: TextInputType.number), field(address, 'ঠিকানা', maxLines: 2), const ListTile(leading: Icon(Icons.payments), title: Text('মাসিক চাঁদা'), trailing: Text('৳৩,০০০'))])))), actions: [TextButton(onPressed: busy ? null : () => Navigator.pop(context), child: const Text('বাতিল')), FilledButton(onPressed: busy ? null : save, child: Text(busy ? 'সংরক্ষণ হচ্ছে…' : 'সংরক্ষণ'))]);
 Widget field(TextEditingController c, String label, {TextInputType? keyboard, int maxLines = 1, bool requiredField = true}) => Padding(padding: const EdgeInsets.only(bottom: 10), child: TextFormField(controller: c, keyboardType: keyboard, maxLines: maxLines, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()), validator: (v) => requiredField && (v == null || v.trim().isEmpty) ? 'এই ঘরটি পূরণ করুন' : null));
}

class GaragesPage extends StatelessWidget { final bool isAdmin; const GaragesPage({super.key, required this.isAdmin});
 @override Widget build(BuildContext context) => Column(children: [if (isAdmin) Padding(padding: const EdgeInsets.all(12), child: Align(alignment: Alignment.centerRight, child: FilledButton.icon(onPressed: () => seedGarages(context), icon: const Icon(Icons.playlist_add), label: const Text('১৪টি গ্যারেজের রেকর্ড তৈরি')))), Expanded(child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(stream: FirebaseFirestore.instance.collection('garages').orderBy('garageNumber').snapshots(), builder: (context, snap) { if (snap.hasError) return const Center(child: Text('গ্যারেজের তথ্য লোড হয়নি।')); if (!snap.hasData) return const Center(child: CircularProgressIndicator()); final docs = snap.data!.docs; if (docs.isEmpty) return const Center(child: Text('গ্যারেজের রেকর্ড তৈরি করতে অ্যাডমিনের বোতাম চাপুন।')); return ListView(children: docs.map((d) { final m = d.data(); return Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5), child: ListTile(leading: const CircleAvatar(child: Icon(Icons.garage)), title: Text('${m['garageNumber']} · ${m['status'] == 'occupied' ? 'ব্যবহৃত' : 'খালি'}'), subtitle: Text('বরাদ্দ: ${m['assignedTo'] ?? '—'} · মোবাইল: ${m['phone'] ?? '—'}'), trailing: isAdmin ? IconButton(icon: const Icon(Icons.edit), tooltip: 'সম্পাদনা', onPressed: () => showDialog(context: context, builder: (_) => GarageDialog(docId: d.id, initial: m))) : null)); }).toList()); }))]);
}
Future<void> seedGarages(BuildContext context) async { final db = FirebaseFirestore.instance; final existing = await db.collection('garages').get(); final known = existing.docs.map((d) => d.data()['garageNumber'].toString()).toSet(); final batch = db.batch(); int added = 0; for (int i = 1; i <= 14; i++) { final n = 'গ্যারেজ-${i.toString().padLeft(2, '0')}'; if (!known.contains(n)) { batch.set(db.collection('garages').doc('garage_${i.toString().padLeft(2, '0')}'), {'garageNumber': n, 'status': 'vacant', 'assignedTo': '', 'phone': '', 'email': '', 'updatedAt': FieldValue.serverTimestamp()}); added++; } } if (added > 0) await batch.commit(); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$addedটি গ্যারেজের রেকর্ড তৈরি হয়েছে।'))); }
class GarageDialog extends StatefulWidget { final String docId; final Map<String, dynamic> initial; const GarageDialog({super.key, required this.docId, required this.initial}); @override State<GarageDialog> createState() => _GarageDialogState(); }
class _GarageDialogState extends State<GarageDialog> { late final TextEditingController assigned, phone, email; late String status; bool busy = false; @override void initState() { super.initState(); assigned = TextEditingController(text: widget.initial['assignedTo'] ?? ''); phone = TextEditingController(text: widget.initial['phone'] ?? ''); email = TextEditingController(text: widget.initial['email'] ?? ''); status = widget.initial['status'] ?? 'vacant'; } @override void dispose() { assigned.dispose(); phone.dispose(); email.dispose(); super.dispose(); } Future<void> save() async { setState(() => busy = true); try { await FirebaseFirestore.instance.collection('garages').doc(widget.docId).update({'assignedTo': assigned.text.trim(), 'phone': phone.text.trim(), 'email': email.text.trim(), 'status': status, 'updatedAt': FieldValue.serverTimestamp()}); if (mounted) Navigator.pop(context); } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('সংরক্ষণ হয়নি: $e'))); } finally { if (mounted) setState(() => busy = false); } } @override Widget build(BuildContext context) => AlertDialog(title: Text('${widget.initial['garageNumber']} সম্পাদনা'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [DropdownButtonFormField<String>(value: status, decoration: const InputDecoration(labelText: 'অবস্থা'), items: const [DropdownMenuItem(value: 'vacant', child: Text('খালি')), DropdownMenuItem(value: 'occupied', child: Text('ব্যবহৃত'))], onChanged: (v) => setState(() => status = v ?? 'vacant')), const SizedBox(height: 10), TextField(controller: assigned, decoration: const InputDecoration(labelText: 'বরাদ্দপ্রাপ্ত ব্যক্তি/ফ্ল্যাট')), const SizedBox(height: 10), TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'মোবাইল')), const SizedBox(height: 10), TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'ইমেইল'))])), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('বাতিল')), FilledButton(onPressed: busy ? null : save, child: const Text('সংরক্ষণ'))]); }

class PaymentsPage extends StatelessWidget { final bool isAdmin; final Map<String, dynamic> userData; const PaymentsPage({super.key, required this.isAdmin, required this.userData});
 @override Widget build(BuildContext context) => Column(children: [if (isAdmin) Padding(padding: const EdgeInsets.all(12), child: Align(alignment: Alignment.centerRight, child: FilledButton.icon(onPressed: () => showDialog(context: context, builder: (_) => const PaymentDialog()), icon: const Icon(Icons.add), label: const Text('চাঁদা জমা নথিভুক্ত করুন')))), Expanded(child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(stream: FirebaseFirestore.instance.collection('payments').orderBy('paidAt', descending: true).snapshots(), builder: (context, snap) { if (snap.hasError) return const Center(child: Text('পেমেন্টের তথ্য লোড হয়নি।')); if (!snap.hasData) return const Center(child: CircularProgressIndicator()); var docs = snap.data!.docs; if (!isAdmin) docs = docs.where((d) => d.data()['flatId'] == userData['flatId']).toList(); if (docs.isEmpty) return const Center(child: Text('এখনও কোনো পেমেন্ট নথিভুক্ত হয়নি।')); return ListView(children: docs.map((d) { final m = d.data(); final dt = (m['paidAt'] as Timestamp?)?.toDate(); return ListTile(leading: const CircleAvatar(child: Icon(Icons.check)), title: Text('${m['flatNumber'] ?? ''} · ${money((m['amount'] as num?) ?? 0)}'), subtitle: Text('মালিক: ${m['ownerName'] ?? '—'} · ${dt == null ? 'তারিখ নেই' : DateFormat('dd-MM-yyyy').format(dt)}\nমাস: ${m['month'] ?? '—'}'), isThreeLine: true, trailing: Text(m['method'] ?? 'নগদ')); }).toList()); }))]);
}
class PaymentDialog extends StatefulWidget { const PaymentDialog({super.key}); @override State<PaymentDialog> createState() => _PaymentDialogState(); }
class _PaymentDialogState extends State<PaymentDialog> { final form = GlobalKey<FormState>(); final amount = TextEditingController(text: '$monthlyFee'); final month = TextEditingController(text: DateFormat('yyyy-MM').format(DateTime.now())); String? flatId; String method = 'নগদ'; bool busy = false;
 @override void dispose() { amount.dispose(); month.dispose(); super.dispose(); }
 Future<void> save() async { if (!form.currentState!.validate() || flatId == null) return; setState(() => busy = true); try { final db = FirebaseFirestore.instance; await db.runTransaction((tx) async { final ref = db.collection('flats').doc(flatId); final flatSnap = await tx.get(ref); if (!flatSnap.exists) throw Exception('ফ্ল্যাট পাওয়া যায়নি'); final f = flatSnap.data()!; final payRef = db.collection('payments').doc(); final paid = int.tryParse(amount.text) ?? monthlyFee; final oldDue = (f['arrears'] as num?)?.toInt() ?? 0; tx.set(payRef, {'flatId': flatId, 'flatNumber': f['flatNumber'], 'ownerName': f['name'], 'amount': paid, 'month': month.text.trim(), 'method': method, 'paidAt': FieldValue.serverTimestamp(), 'recordedBy': FirebaseAuth.instance.currentUser!.uid}); tx.update(ref, {'arrears': (oldDue - paid).clamp(0, 1 << 30), 'updatedAt': FieldValue.serverTimestamp()}); }); if (mounted) Navigator.pop(context); } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('সংরক্ষণ হয়নি: $e'))); } finally { if (mounted) setState(() => busy = false); } }
 @override Widget build(BuildContext context) => AlertDialog(title: const Text('চাঁদা জমা নথিভুক্ত করুন'), content: SizedBox(width: 420, child: Form(key: form, child: Column(mainAxisSize: MainAxisSize.min, children: [StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(stream: FirebaseFirestore.instance.collection('flats').orderBy('flatNumber').snapshots(), builder: (context, snap) { final docs = snap.data?.docs ?? []; return DropdownButtonFormField<String>(value: flatId, isExpanded: true, decoration: const InputDecoration(labelText: 'ফ্ল্যাট নির্বাচন', border: OutlineInputBorder()), items: docs.map((d) => DropdownMenuItem(value: d.id, child: Text('${d.data()['flatNumber']} · ${d.data()['name']}'))).toList(), onChanged: (v) => setState(() => flatId = v), validator: (v) => v == null ? 'ফ্ল্যাট নির্বাচন করুন' : null); }), const SizedBox(height: 10), TextFormField(controller: amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'জমার পরিমাণ (টাকা)', border: OutlineInputBorder()), validator: (v) => int.tryParse(v ?? '') == null || int.parse(v!) < 1 ? 'সঠিক পরিমাণ লিখুন' : null), const SizedBox(height: 10), TextFormField(controller: month, decoration: const InputDecoration(labelText: 'চাঁদার মাস (YYYY-MM)', border: OutlineInputBorder()), validator: (v) => v == null || !RegExp(r'^\d{4}-\d{2}$').hasMatch(v) ? 'যেমন: 2026-10 লিখুন' : null), const SizedBox(height: 10), DropdownButtonFormField<String>(value: method, decoration: const InputDecoration(labelText: 'পেমেন্ট পদ্ধতি', border: OutlineInputBorder()), items: const [DropdownMenuItem(value: 'নগদ', child: Text('নগদ')), DropdownMenuItem(value: 'ব্যাংক', child: Text('ব্যাংক')), DropdownMenuItem(value: 'মোবাইল ব্যাংকিং', child: Text('মোবাইল ব্যাংকিং'))], onChanged: (v) => setState(() => method = v ?? 'নগদ'))]))), actions: [TextButton(onPressed: busy ? null : () => Navigator.pop(context), child: const Text('বাতিল')), FilledButton(onPressed: busy ? null : save, child: Text(busy ? 'সংরক্ষণ হচ্ছে…' : 'সংরক্ষণ'))]); }

class NoticesPage extends StatelessWidget { final bool isAdmin; const NoticesPage({super.key, required this.isAdmin}); @override Widget build(BuildContext context) => Column(children: [if (isAdmin) Padding(padding: const EdgeInsets.all(12), child: Align(alignment: Alignment.centerRight, child: FilledButton.icon(onPressed: () => showDialog(context: context, builder: (_) => const NoticeDialog()), icon: const Icon(Icons.add), label: const Text('নোটিশ লিখুন')))), Expanded(child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(stream: FirebaseFirestore.instance.collection('notices').orderBy('createdAt', descending: true).snapshots(), builder: (context, snap) { if (snap.hasError) return const Center(child: Text('নোটিশ লোড হয়নি।')); if (!snap.hasData) return const Center(child: CircularProgressIndicator()); if (snap.data!.docs.isEmpty) return const Center(child: Text('কোনো নোটিশ নেই।')); return ListView(children: snap.data!.docs.map((d) { final m = d.data(); return Card(margin: const EdgeInsets.all(10), child: ListTile(leading: const Icon(Icons.campaign), title: Text(m['title'] ?? ''), subtitle: Padding(padding: const EdgeInsets.only(top: 8), child: Text('${m['body'] ?? ''}\n\n${m['createdAt'] is Timestamp ? DateFormat('dd-MM-yyyy').format((m['createdAt'] as Timestamp).toDate()) : ''}')))); }).toList()); }))]); }
class NoticeDialog extends StatefulWidget { const NoticeDialog({super.key}); @override State<NoticeDialog> createState() => _NoticeDialogState(); }
class _NoticeDialogState extends State<NoticeDialog> { final title = TextEditingController(), body = TextEditingController(); bool busy = false; @override void dispose() { title.dispose(); body.dispose(); super.dispose(); } Future<void> save() async { if (title.text.trim().isEmpty || body.text.trim().isEmpty) return; setState(() => busy = true); await FirebaseFirestore.instance.collection('notices').add({'title': title.text.trim(), 'body': body.text.trim(), 'createdAt': FieldValue.serverTimestamp(), 'createdBy': FirebaseAuth.instance.currentUser!.uid}); if (mounted) Navigator.pop(context); } @override Widget build(BuildContext context) => AlertDialog(title: const Text('নতুন নোটিশ'), content: SizedBox(width: 420, child: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: title, decoration: const InputDecoration(labelText: 'শিরোনাম', border: OutlineInputBorder())), const SizedBox(height: 10), TextField(controller: body, maxLines: 5, decoration: const InputDecoration(labelText: 'নোটিশের বিবরণ', border: OutlineInputBorder()))])), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('বাতিল')), FilledButton(onPressed: busy ? null : save, child: const Text('প্রকাশ করুন'))]); }
