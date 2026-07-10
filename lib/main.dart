import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

const appName = 'Catatan Keuangan PRO';
const appVersion = '1.1.25';
const brandRed = Color(0xFFE9433D);
const brandDark = Color(0xFF132F3A);
const brandSoft = Color(0xFFFFF2F1);
const incomeGreen = Color(0xFF08A345);
const expenseRed = Color(0xFFD7473F);
const pageBg = Color(0xFFF6F7F9);
const surface = Color(0xFFFFFFFF);
const lineColor = Color(0xFFE3E7EC);
const textPrimary = Color(0xFF17212B);
const textMuted = Color(0xFF6A737D);
const storageTransactionsKey = 'transactions_v1';
const storageExpenseCategoriesKey = 'expense_categories_v1';
const storageIncomeCategoriesKey = 'income_categories_v1';
const storageLanguageKey = 'language_code_v1';
const storageThemeKey = 'theme_color_v1';
const storageCurrencyKey = 'currency_code_v1';

const themeVariants = [
  AppThemeVariant('redAmber', 'Red Amber', Color(0xFFE9433D), Color(0xFFFFF2F1)),
  AppThemeVariant('emerald', 'Emerald', Color(0xFF059669), Color(0xFFEAFBF3)),
  AppThemeVariant('ocean', 'Ocean Blue', Color(0xFF0EA5E9), Color(0xFFEAF7FF)),
  AppThemeVariant('indigo', 'Indigo', Color(0xFF4F46E5), Color(0xFFF0EFFF)),
  AppThemeVariant('violet', 'Violet', Color(0xFF7C3AED), Color(0xFFF5EEFF)),
  AppThemeVariant('rose', 'Rose', Color(0xFFE11D48), Color(0xFFFFEEF3)),
  AppThemeVariant('orange', 'Orange', Color(0xFFF97316), Color(0xFFFFF4E8)),
  AppThemeVariant('teal', 'Teal', Color(0xFF0F766E), Color(0xFFEAF8F6)),
  AppThemeVariant('slate', 'Slate', Color(0xFF334155), Color(0xFFF1F5F9)),
];

const currencyVariants = [
  CurrencyVariant('IDR', 'Indonesian rupiah (Rp)', 'id_ID', 'Rp', 0),
  CurrencyVariant('USD', 'US dollar (\$)', 'en_US', r'$', 2),
  CurrencyVariant('EUR', 'Euro (€)', 'de_DE', '€', 2),
  CurrencyVariant('JPY', 'Japanese yen (¥)', 'ja_JP', '¥', 0),
  CurrencyVariant('MYR', 'Malaysian ringgit (RM)', 'ms_MY', 'RM', 2),
  CurrencyVariant('SGD', 'Singapore dollar (S\$)', 'en_SG', r'S$', 2),
  CurrencyVariant('AUD', 'Australian dollar (A\$)', 'en_AU', r'A$', 2),
  CurrencyVariant('GBP', 'Pound sterling (£)', 'en_GB', '£', 2),
];

const supportedLanguages = [
  AppLanguage('system', 'System', 'Sistem'),
  AppLanguage('id', 'Indonesia', 'Indonesia'),
  AppLanguage('en', 'English', 'English'),
  AppLanguage('ms', 'Melayu', 'Malay'),
  AppLanguage('ar', 'العربية', 'Arabic'),
  AppLanguage('de', 'Deutsch', 'German'),
  AppLanguage('es', 'Español', 'Spanish'),
  AppLanguage('fr', 'Français', 'French'),
  AppLanguage('hi', 'हिन्दी', 'Hindi'),
  AppLanguage('it', 'Italiano', 'Italian'),
  AppLanguage('ja', '日本語', 'Japanese'),
  AppLanguage('ko', '한국어', 'Korean'),
  AppLanguage('nl', 'Nederlands', 'Dutch'),
  AppLanguage('pt', 'Português', 'Portuguese'),
  AppLanguage('ru', 'Русский', 'Russian'),
  AppLanguage('th', 'ไทย', 'Thai'),
  AppLanguage('tr', 'Türkçe', 'Turkish'),
  AppLanguage('vi', 'Tiếng Việt', 'Vietnamese'),
  AppLanguage('zh', '中文', 'Chinese'),
];

const appText = {
  'id': {
    'daily': 'Harian',
    'weekly': 'Mingguan',
    'monthly': 'Bulanan',
    'yearly': 'Tahunan',
    'income': 'Pemasukan',
    'expense': 'Pengeluaran',
    'balance': 'Saldo',
    'noData': 'Data tidak tersedia',
    'createTransaction': 'Buat Transaksi',
    'date': 'Tanggal',
    'category': 'Kategori',
    'amount': 'Jumlah',
    'note': 'Keterangan',
    'save': 'SIMPAN',
    'settings': 'Pengaturan',
    'selectLanguage': 'Pilih Bahasa',
    'language': 'Bahasa',
    'search': 'Pencarian',
    'chart': 'Grafik',
    'rate': 'Beri Penilaian',
    'help': 'Bantuan',
    'about': 'Tentang',
    'export': 'Ekspor',
    'allCategories': 'Semua Kategori',
    'keyword': 'Kata Kunci',
    'min': 'Min',
    'max': 'Max',
    'cancel': 'BATAL',
    'confirmExport': 'EKSPOR',
    'backupDrive': 'Backup/Restore di Google Drive',
    'backupStorage': 'Backup/Restore di Device Storage',
    'shareDatabase': 'Kirim File Database',
    'resetData': 'Setel Ulang Data',
    'inactive': 'Tidak Aktif',
    'themeColor': 'Atur Warna Tema',
    'currencyFormat': 'Format Mata Uang',
    'openingBalance': 'Atur Saldo Bawaan',
    'removeAds': 'Hapus Iklan',
    'transactionTime': 'Waktu/Jam Transaksi',
    'firstWeekday': 'Hari Pertama Mingguan',
    'firstMonthDate': 'Tanggal Pertama Bulanan',
    'reminder': 'Pengingat',
    'pin': 'Atur PIN',
    'quickOpen': 'Buka Cepat',
    'systemLanguage': 'Sistem',
    'backupSaved': 'Backup tersimpan.',
    'backupCancelled': 'Backup dibatalkan.',
    'restoreDone': 'Data berhasil dipulihkan.',
    'amountRequired': 'Jumlah harus diisi.',
    'deleteTransaction': 'Hapus transaksi ini?',
    'deleteCategory': 'Hapus kategori ini?',
    'addCategory': 'Tambah Kategori',
    'editCategory': 'Edit Kategori',
  },
  'en': {
    'daily': 'Daily',
    'weekly': 'Weekly',
    'monthly': 'Monthly',
    'yearly': 'Yearly',
    'income': 'Income',
    'expense': 'Expense',
    'balance': 'Balance',
    'noData': 'No data available',
    'createTransaction': 'Create Transaction',
    'date': 'Date',
    'category': 'Category',
    'amount': 'Amount',
    'note': 'Note',
    'save': 'SAVE',
    'settings': 'Settings',
    'selectLanguage': 'Select Language',
    'language': 'Language',
    'search': 'Search',
    'chart': 'Chart',
    'rate': 'Rate App',
    'help': 'Help',
    'about': 'About',
    'export': 'Export',
    'allCategories': 'All Categories',
    'keyword': 'Keyword',
    'min': 'Min',
    'max': 'Max',
    'cancel': 'CANCEL',
    'confirmExport': 'EXPORT',
    'backupDrive': 'Backup/Restore on Google Drive',
    'backupStorage': 'Backup/Restore on Device Storage',
    'shareDatabase': 'Send Database File',
    'resetData': 'Reset Data',
    'inactive': 'Inactive',
    'themeColor': 'Theme Color',
    'currencyFormat': 'Currency Format',
    'openingBalance': 'Opening Balance',
    'removeAds': 'Remove Ads',
    'transactionTime': 'Transaction Time',
    'firstWeekday': 'First Day of Week',
    'firstMonthDate': 'First Day of Month',
    'reminder': 'Reminder',
    'pin': 'Set PIN',
    'quickOpen': 'Quick Open',
    'systemLanguage': 'System',
    'backupSaved': 'Backup saved.',
    'backupCancelled': 'Backup cancelled.',
    'restoreDone': 'Data restored.',
    'amountRequired': 'Amount is required.',
    'deleteTransaction': 'Delete this transaction?',
    'deleteCategory': 'Delete this category?',
    'addCategory': 'Add Category',
    'editCategory': 'Edit Category',
  },
  'ms': {
    'income': 'Pendapatan',
    'expense': 'Perbelanjaan',
    'save': 'SIMPAN',
    'settings': 'Tetapan',
    'selectLanguage': 'Pilih Bahasa',
  },
  'es': {
    'income': 'Ingresos',
    'expense': 'Gastos',
    'save': 'GUARDAR',
    'settings': 'Ajustes',
    'selectLanguage': 'Idioma',
  },
  'fr': {
    'income': 'Revenus',
    'expense': 'Depenses',
    'save': 'ENREGISTRER',
    'settings': 'Parametres',
    'selectLanguage': 'Langue',
  },
  'de': {
    'income': 'Einnahmen',
    'expense': 'Ausgaben',
    'save': 'SPEICHERN',
    'settings': 'Einstellungen',
    'selectLanguage': 'Sprache',
  },
  'pt': {
    'income': 'Receitas',
    'expense': 'Despesas',
    'save': 'SALVAR',
    'settings': 'Configuracoes',
    'selectLanguage': 'Idioma',
  },
  'ar': {
    'income': 'الدخل',
    'expense': 'المصروفات',
    'save': 'حفظ',
    'settings': 'الإعدادات',
    'selectLanguage': 'اللغة',
  },
  'ja': {
    'income': '収入',
    'expense': '支出',
    'save': '保存',
    'settings': '設定',
    'selectLanguage': '言語',
  },
  'ko': {
    'income': '수입',
    'expense': '지출',
    'save': '저장',
    'settings': '설정',
    'selectLanguage': '언어',
  },
  'zh': {
    'income': '收入',
    'expense': '支出',
    'save': '保存',
    'settings': '设置',
    'selectLanguage': '语言',
  },
};

class AppLanguage {
  const AppLanguage(this.code, this.nativeName, this.englishName);

  final String code;
  final String nativeName;
  final String englishName;
}

class AppThemeVariant {
  const AppThemeVariant(this.key, this.name, this.primary, this.soft);

  final String key;
  final String name;
  final Color primary;
  final Color soft;
}

class CurrencyVariant {
  const CurrencyVariant(this.code, this.name, this.locale, this.symbol, this.decimalDigits);

  final String code;
  final String name;
  final String locale;
  final String symbol;
  final int decimalDigits;
}

const monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

const defaultExpenseCategories = [
  'Asuransi',
  'Bayi',
  'Belanja',
  'Buah-buahan',
  'Cemilan',
  'Elektronik',
  'Hadiah',
  'Hewan Peliharaan',
  'Hiburan',
  'Kantor',
  'Kecantikan',
  'Kesehatan',
  'Makanan',
  'Pendidikan',
  'Transportasi',
];

const defaultIncomeCategories = [
  'Gaji',
  'Bonus',
  'Hadiah',
  'Investasi',
  'Penjualan',
  'Tabungan',
  'Lainnya',
];

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: brandRed,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const FinanceApp());
}

class FinanceApp extends StatefulWidget {
  const FinanceApp({super.key});

  @override
  State<FinanceApp> createState() => _FinanceAppState();
}

class _FinanceAppState extends State<FinanceApp> {
  String _languageCode = 'id';
  String _themeKey = 'redAmber';
  String _currencyCode = 'IDR';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _languageCode = prefs.getString(storageLanguageKey) ?? 'id';
      _themeKey = prefs.getString(storageThemeKey) ?? 'redAmber';
      _currencyCode = prefs.getString(storageCurrencyKey) ?? 'IDR';
    });
  }

  Future<void> _setLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageLanguageKey, code);
    setState(() => _languageCode = code);
  }

  Future<void> _setTheme(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageThemeKey, key);
    setState(() => _themeKey = key);
  }

  Future<void> _setCurrency(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageCurrencyKey, code);
    setState(() => _currencyCode = code);
  }

  @override
  Widget build(BuildContext context) {
    final locale = _languageCode == 'system' ? null : Locale(_languageCode);
    final appTheme = themeVariant(_themeKey);
    final currency = currencyVariant(_currencyCode);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: appTheme.primary,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    return AppLocaleScope(
      languageCode: _languageCode,
      setLanguage: _setLanguage,
      themeKey: _themeKey,
      setTheme: _setTheme,
      currencyCode: _currencyCode,
      setCurrency: _setCurrency,
      primaryColor: appTheme.primary,
      softColor: appTheme.soft,
      currency: currency,
      child: MaterialApp(
        title: appName,
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: supportedLanguages
            .where((language) => language.code != 'system')
            .map((language) => Locale(language.code))
            .toList(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: appTheme.primary,
            primary: appTheme.primary,
            secondary: brandDark,
            surface: surface,
          ),
          scaffoldBackgroundColor: pageBg,
          fontFamily: 'Roboto',
          appBarTheme: AppBarTheme(
            backgroundColor: appTheme.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: false,
            titleTextStyle: const TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
            iconTheme: const IconThemeData(color: Colors.white, size: 26),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: appTheme.primary,
            foregroundColor: Colors.white,
            elevation: 4,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: lineColor),
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: lineColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: appTheme.primary, width: 1.4),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: appTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: surface,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
          ),
          useMaterial3: true,
        ),
        home: const SplashPage(),
      ),
    );
  }
}

class AppLocaleScope extends InheritedWidget {
  const AppLocaleScope({
    super.key,
    required this.languageCode,
    required this.setLanguage,
    required this.themeKey,
    required this.setTheme,
    required this.currencyCode,
    required this.setCurrency,
    required this.primaryColor,
    required this.softColor,
    required this.currency,
    required super.child,
  });

  final String languageCode;
  final Future<void> Function(String code) setLanguage;
  final String themeKey;
  final Future<void> Function(String key) setTheme;
  final String currencyCode;
  final Future<void> Function(String code) setCurrency;
  final Color primaryColor;
  final Color softColor;
  final CurrencyVariant currency;

  static AppLocaleScope of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppLocaleScope>()!;
  }

  @override
  bool updateShouldNotify(AppLocaleScope oldWidget) {
    return oldWidget.languageCode != languageCode ||
        oldWidget.themeKey != themeKey ||
        oldWidget.currencyCode != currencyCode;
  }
}

AppThemeVariant themeVariant(String key) {
  return themeVariants.firstWhere(
    (theme) => theme.key == key,
    orElse: () => themeVariants.first,
  );
}

CurrencyVariant currencyVariant(String code) {
  return currencyVariants.firstWhere(
    (currency) => currency.code == code,
    orElse: () => currencyVariants.first,
  );
}

Color appPrimary(BuildContext context) => AppLocaleScope.of(context).primaryColor;

Color appSoft(BuildContext context) => AppLocaleScope.of(context).softColor;

String t(BuildContext context, String key) {
  final code = AppLocaleScope.of(context).languageCode;
  final activeCode = code == 'system'
      ? Localizations.localeOf(context).languageCode
      : code;
  return appText[activeCode]?[key] ?? appText['en']?[key] ?? appText['id']?[key] ?? key;
}

String languageName(String code) {
  return supportedLanguages
      .firstWhere((language) => language.code == code, orElse: () => supportedLanguages.first)
      .nativeName;
}

String themeName(String key) => themeVariant(key).name;

String currencyName(String code) => currencyVariant(code).name;

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
    )..forward();
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    Future.delayed(const Duration(milliseconds: 1700), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const AppShell(),
          transitionDuration: const Duration(milliseconds: 450),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = appPrimary(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primary, brandDark],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: Column(
              children: [
                const Spacer(),
                ScaleTransition(
                  scale: _scale,
                  child: Container(
                    width: 142,
                    height: 142,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 30,
                          offset: Offset(0, 16),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset('assets/icons/app_icon.png', fit: BoxFit.cover),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  appName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Smart money tracker',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 150,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      minHeight: 5,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      backgroundColor: Colors.white.withValues(alpha: 0.22),
                    ),
                  ),
                ),
                const SizedBox(height: 34),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final List<MoneyTransaction> _transactions = [];
  List<String> _expenseCategories = [...defaultExpenseCategories];
  List<String> _incomeCategories = [...defaultIncomeCategories];
  bool _loaded = false;
  bool _descending = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final rawTransactions = prefs.getString(storageTransactionsKey);
    final rawExpenseCategories = prefs.getStringList(storageExpenseCategoriesKey);
    final rawIncomeCategories = prefs.getStringList(storageIncomeCategoriesKey);

    setState(() {
      _transactions
        ..clear()
        ..addAll(_decodeTransactions(rawTransactions));
      _expenseCategories = rawExpenseCategories?.isNotEmpty == true
          ? rawExpenseCategories!
          : [...defaultExpenseCategories];
      _incomeCategories = rawIncomeCategories?.isNotEmpty == true
          ? rawIncomeCategories!
          : [...defaultIncomeCategories];
      _loaded = true;
    });
  }

  List<MoneyTransaction> _decodeTransactions(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => MoneyTransaction.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      storageTransactionsKey,
      jsonEncode(_transactions.map((tx) => tx.toJson()).toList()),
    );
    await prefs.setStringList(storageExpenseCategoriesKey, _expenseCategories);
    await prefs.setStringList(storageIncomeCategoriesKey, _incomeCategories);
  }

  Future<void> _upsertTransaction(MoneyTransaction transaction) async {
    final index = _transactions.indexWhere((tx) => tx.id == transaction.id);
    setState(() {
      if (index == -1) {
        _transactions.add(transaction);
      } else {
        _transactions[index] = transaction;
      }
    });
    await _saveData();
  }

  Future<void> _deleteTransaction(String id) async {
    setState(() => _transactions.removeWhere((tx) => tx.id == id));
    await _saveData();
  }

  Future<void> _saveCategories(String type, List<String> categories) async {
    setState(() {
      if (type == 'expense') {
        _expenseCategories = categories;
      } else {
        _incomeCategories = categories;
      }
    });
    await _saveData();
  }

  Future<void> _restoreBackup(Map<String, dynamic> backup) async {
    final transactions = (backup['transactions'] as List<dynamic>? ?? [])
        .map((item) => MoneyTransaction.fromJson(item as Map<String, dynamic>))
        .toList();
    final expenseCategories = (backup['expenseCategories'] as List<dynamic>?)
            ?.map((item) => item.toString())
            .toList() ??
        [...defaultExpenseCategories];
    final incomeCategories = (backup['incomeCategories'] as List<dynamic>?)
            ?.map((item) => item.toString())
            .toList() ??
        [...defaultIncomeCategories];

    setState(() {
      _transactions
        ..clear()
        ..addAll(transactions);
      _expenseCategories = expenseCategories;
      _incomeCategories = incomeCategories;
    });
    await _saveData();
  }

  Future<Map<String, dynamic>> _backupPayload() async {
    return {
      'app': appName,
      'version': appVersion,
      'createdAt': DateTime.now().toIso8601String(),
      'transactions': _transactions.map((tx) => tx.toJson()).toList(),
      'expenseCategories': _expenseCategories,
      'incomeCategories': _incomeCategories,
    };
  }

  void _openEntry({MoneyTransaction? transaction}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TransactionPage(
          transaction: transaction,
          expenseCategories: _expenseCategories,
          incomeCategories: _incomeCategories,
          onSave: _upsertTransaction,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return HomePage(
      transactions: List.unmodifiable(_transactions),
      expenseCategories: _expenseCategories,
      incomeCategories: _incomeCategories,
      descending: _descending,
      onToggleSort: () => setState(() => _descending = !_descending),
      onCreate: () => _openEntry(),
      onEdit: (tx) => _openEntry(transaction: tx),
      onDelete: _deleteTransaction,
      onSaveCategories: _saveCategories,
      onBackupPayload: _backupPayload,
      onRestoreBackup: _restoreBackup,
    );
  }
}

class MoneyTransaction {
  const MoneyTransaction({
    required this.id,
    required this.type,
    required this.date,
    required this.category,
    required this.amount,
    required this.note,
  });

  final String id;
  final String type;
  final DateTime date;
  final String category;
  final int amount;
  final String note;

  bool get isIncome => type == 'income';

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'date': date.toIso8601String(),
        'category': category,
        'amount': amount,
        'note': note,
      };

  factory MoneyTransaction.fromJson(Map<String, dynamic> json) {
    return MoneyTransaction(
      id: json['id']?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
      type: json['type']?.toString() == 'income' ? 'income' : 'expense',
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      category: json['category']?.toString() ?? 'Lainnya',
      amount: int.tryParse(json['amount'].toString()) ?? 0,
      note: json['note']?.toString() ?? '',
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.transactions,
    required this.expenseCategories,
    required this.incomeCategories,
    required this.descending,
    required this.onToggleSort,
    required this.onCreate,
    required this.onEdit,
    required this.onDelete,
    required this.onSaveCategories,
    required this.onBackupPayload,
    required this.onRestoreBackup,
  });

  final List<MoneyTransaction> transactions;
  final List<String> expenseCategories;
  final List<String> incomeCategories;
  final bool descending;
  final VoidCallback onToggleSort;
  final VoidCallback onCreate;
  final ValueChanged<MoneyTransaction> onEdit;
  final ValueChanged<String> onDelete;
  final Future<void> Function(String type, List<String> categories) onSaveCategories;
  final Future<Map<String, dynamic>> Function() onBackupPayload;
  final Future<void> Function(Map<String, dynamic> backup) onRestoreBackup;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  DateTime _anchor = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final periodTransactions = _transactionsForCurrentPeriod();
    final income = totalAmount(periodTransactions, 'income');
    final expense = totalAmount(periodTransactions, 'expense');
    final balance = income - expense;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => setState(() => _anchor = shiftDate(_anchor, _tabController.index, -1)),
        ),
        title: Text(periodTitle(_anchor, _tabController.index)),
        actions: [
          IconButton(
            tooltip: t(context, 'export'),
            onPressed: () => showExportDialog(context, widget.transactions),
            icon: const Icon(Icons.file_download),
          ),
          IconButton(
            tooltip: 'Urutkan',
            onPressed: widget.onToggleSort,
            icon: const Icon(Icons.sort),
          ),
          IconButton(
            tooltip: t(context, 'search'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SearchPage(
                  transactions: widget.transactions,
                  categories: [...widget.expenseCategories, ...widget.incomeCategories],
                  onEdit: widget.onEdit,
                ),
              ),
            ),
            icon: const Icon(Icons.filter_alt),
          ),
          Builder(
            builder: (context) => IconButton(
              tooltip: 'Menu',
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              icon: const Icon(Icons.more_vert),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          tabs: [
            Tab(text: t(context, 'daily')),
            Tab(text: t(context, 'weekly')),
            Tab(text: t(context, 'monthly')),
            Tab(text: t(context, 'yearly')),
          ],
        ),
      ),
      endDrawer: AppMenu(
        onNavigate: (page) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page)),
        expenseCategories: widget.expenseCategories,
        incomeCategories: widget.incomeCategories,
        onSaveCategories: widget.onSaveCategories,
        onBackupPayload: widget.onBackupPayload,
        onRestoreBackup: widget.onRestoreBackup,
        transactions: widget.transactions,
      ),
      body: Column(
        children: [
          SummaryStrip(income: income, expense: expense, balance: balance),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                DailyView(
                  transactions: periodTransactions,
                  descending: widget.descending,
                  onEdit: widget.onEdit,
                  onDelete: widget.onDelete,
                ),
                WeeklyView(
                  anchor: _anchor,
                  transactions: widget.transactions,
                ),
                MonthlyView(
                  anchor: _anchor,
                  transactions: widget.transactions,
                ),
                YearlyView(
                  anchor: _anchor,
                  transactions: widget.transactions,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 62,
        height: 62,
        child: FloatingActionButton(
          shape: const CircleBorder(),
          onPressed: widget.onCreate,
          child: const Icon(Icons.add, size: 32),
        ),
      ),
    );
  }

  List<MoneyTransaction> _transactionsForCurrentPeriod() {
    final filtered = widget.transactions.where((tx) {
      return switch (_tabController.index) {
        0 => isSameDay(tx.date, _anchor),
        1 => isSameWeek(tx.date, _anchor),
        2 => tx.date.year == _anchor.year && tx.date.month == _anchor.month,
        _ => tx.date.year == _anchor.year,
      };
    }).toList();
    filtered.sort((a, b) => widget.descending ? b.date.compareTo(a.date) : a.date.compareTo(b.date));
    return filtered;
  }
}

class SummaryStrip extends StatelessWidget {
  const SummaryStrip({
    super.key,
    required this.income,
    required this.expense,
    required this.balance,
  });

  final int income;
  final int expense;
  final int balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: lineColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          SummaryItem(title: t(context, 'income'), value: income, color: incomeGreen, icon: Icons.south_west),
          SummaryItem(title: t(context, 'expense'), value: expense, color: expenseRed, icon: Icons.north_east),
          SummaryItem(title: t(context, 'balance'), value: balance, color: brandDark, icon: Icons.account_balance_wallet_outlined),
        ],
      ),
    );
  }
}

class SummaryItem extends StatelessWidget {
  const SummaryItem({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String title;
  final int value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13.5, color: textMuted, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 5),
          Text(
            value == 0 ? '0' : money(value, context),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class DailyView extends StatelessWidget {
  const DailyView({
    super.key,
    required this.transactions,
    required this.descending,
    required this.onEdit,
    required this.onDelete,
  });

  final List<MoneyTransaction> transactions;
  final bool descending;
  final ValueChanged<MoneyTransaction> onEdit;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const EmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 120),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final tx = transactions[index];
        return Dismissible(
          key: ValueKey(tx.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: expenseRed,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (_) => confirm(context, t(context, 'deleteTransaction')),
          onDismissed: (_) => onDelete(tx.id),
          child: Material(
            color: surface,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => onEdit(tx),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: lineColor),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: (tx.isIncome ? incomeGreen : expenseRed).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        tx.isIncome ? Icons.south_west : Icons.north_east,
                        color: tx.isIncome ? incomeGreen : expenseRed,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tx.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700, color: textPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${formatDate(tx.date)}${tx.note.isEmpty ? '' : ' - ${tx.note}'}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13.5, color: textMuted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      money(tx.amount, context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: tx.isIncome ? incomeGreen : expenseRed,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.description_outlined, size: 72, color: Color(0xFFD5D5D5)),
          SizedBox(height: 16),
          Text(t(context, 'noData'), style: const TextStyle(fontSize: 20, color: Color(0xFFB0B0B0))),
        ],
      ),
    );
  }
}

class WeeklyView extends StatelessWidget {
  const WeeklyView({
    super.key,
    required this.anchor,
    required this.transactions,
  });

  final DateTime anchor;
  final List<MoneyTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    final weeks = monthWeeks(anchor);
    return PeriodRows(
      rows: weeks.reversed.map((week) {
        final filtered = transactions.where((tx) => !tx.date.isBefore(week.start) && tx.date.isBefore(week.end)).toList();
        return PeriodRowData(
          label: 'Minggu ${week.index}',
          badge: '${two(week.start.day)}.${two(week.start.month)} ~ ${two(week.end.subtract(const Duration(days: 1)).day)}.${two(week.end.subtract(const Duration(days: 1)).month)}',
          selected: isSameWeek(DateTime.now(), week.start),
          income: totalAmount(filtered, 'income'),
          expense: totalAmount(filtered, 'expense'),
        );
      }).toList(),
    );
  }
}

class MonthlyView extends StatelessWidget {
  const MonthlyView({
    super.key,
    required this.anchor,
    required this.transactions,
  });

  final DateTime anchor;
  final List<MoneyTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    final months = List.generate(anchor.month, (index) => anchor.month - index);
    return PeriodRows(
      rows: months.map((month) {
        final filtered = transactions.where((tx) => tx.date.year == anchor.year && tx.date.month == month).toList();
        return PeriodRowData(
          badge: monthNames[month - 1],
          selected: month == DateTime.now().month && anchor.year == DateTime.now().year,
          income: totalAmount(filtered, 'income'),
          expense: totalAmount(filtered, 'expense'),
        );
      }).toList(),
    );
  }
}

class YearlyView extends StatelessWidget {
  const YearlyView({
    super.key,
    required this.anchor,
    required this.transactions,
  });

  final DateTime anchor;
  final List<MoneyTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    final filtered = transactions.where((tx) => tx.date.year == anchor.year).toList();
    return PeriodRows(
      rows: [
        PeriodRowData(
          badge: anchor.year.toString(),
          selected: true,
          income: totalAmount(filtered, 'income'),
          expense: totalAmount(filtered, 'expense'),
        ),
      ],
    );
  }
}

class PeriodRows extends StatelessWidget {
  const PeriodRows({super.key, required this.rows});

  final List<PeriodRowData> rows;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 120),
      itemCount: rows.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (_, index) {
        final row = rows[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: lineColor),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 135,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (row.label != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 2, bottom: 5),
                        child: Text(row.label!, style: const TextStyle(fontSize: 13, color: textMuted, fontWeight: FontWeight.w600)),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                      decoration: BoxDecoration(
                        color: row.selected ? appSoft(context) : const Color(0xFFF0F2F5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: row.selected ? appPrimary(context) : lineColor),
                      ),
                      child: Text(
                        row.badge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14.5, color: row.selected ? appPrimary(context) : textMuted, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Text(
                  money(row.income, context),
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: incomeGreen, fontSize: 15.5, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 24),
              Text(money(row.expense, context), textAlign: TextAlign.right, style: const TextStyle(color: expenseRed, fontSize: 15.5, fontWeight: FontWeight.w700)),
            ],
          ),
        );
      },
    );
  }
}

class PeriodRowData {
  const PeriodRowData({
    this.label,
    required this.badge,
    required this.selected,
    required this.income,
    required this.expense,
  });

  final String? label;
  final String badge;
  final bool selected;
  final int income;
  final int expense;
}

class WeekRange {
  const WeekRange(this.index, this.start, this.end);
  final int index;
  final DateTime start;
  final DateTime end;
}

class TransactionPage extends StatefulWidget {
  const TransactionPage({
    super.key,
    required this.expenseCategories,
    required this.incomeCategories,
    required this.onSave,
    this.transaction,
  });

  final MoneyTransaction? transaction;
  final List<String> expenseCategories;
  final List<String> incomeCategories;
  final Future<void> Function(MoneyTransaction transaction) onSave;

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _type = 'expense';
  late DateTime _date;
  late String _category;
  bool _formattedInitialAmount = false;

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;
    _type = transaction?.type ?? 'expense';
    _date = transaction?.date ?? DateTime.now();
    _category = transaction?.category ?? _categories.first;
    _amountController.text = transaction == null ? '' : transaction.amount.toString();
    _noteController.text = transaction?.note ?? '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_formattedInitialAmount && _amountController.text.isNotEmpty) {
      _amountController.text = formatMoneyInput(_amountController.text, context);
      _formattedInitialAmount = true;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  List<String> get _categories => _type == 'expense' ? widget.expenseCategories : widget.incomeCategories;

  InputDecoration get _compactInput => const InputDecoration(
        isDense: true,
        filled: true,
        fillColor: surface,
        contentPadding: EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: Text(t(context, 'createTransaction')),
        actions: const [Padding(padding: EdgeInsets.only(right: 16), child: Icon(Icons.copy_outlined, size: 26))],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 30),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: lineColor),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x10000000),
                  blurRadius: 12,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                SegmentedChoice(
                  left: t(context, 'expense'),
                  right: t(context, 'income'),
                  selectedLeft: _type == 'expense',
                  onLeft: () => _changeType('expense'),
                  onRight: () => _changeType('income'),
                ),
                const SizedBox(height: 18),
                FormRow(
                  label: t(context, 'date'),
                  child: InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: _compactInput,
                      child: Text(formatDate(_date), style: const TextStyle(fontSize: 17)),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                FormRow(
                  label: t(context, 'category'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF8B8B8B), size: 24),
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => CategoryPage(
                        expenseCategories: widget.expenseCategories,
                        incomeCategories: widget.incomeCategories,
                        initialType: _type,
                        onSaveCategories: (type, categories) async {},
                      ),
                    )),
                  ),
                  child: DropdownButtonFormField<String>(
                    initialValue: _categories.contains(_category) ? _category : _categories.first,
                    items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                    onChanged: (value) => setState(() => _category = value ?? _category),
                    iconEnabledColor: appPrimary(context),
                    style: const TextStyle(fontSize: 17, color: Colors.black87),
                    decoration: _compactInput,
                  ),
                ),
                const SizedBox(height: 14),
                FormRow(
                  label: t(context, 'amount'),
                  trailing: const Icon(Icons.calculate, color: Color(0xFF8B8B8B), size: 25),
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [MoneyInputFormatter(context)],
                    style: const TextStyle(fontSize: 17),
                    decoration: _compactInput,
                  ),
                ),
                const SizedBox(height: 14),
                FormRow(
                  label: t(context, 'note'),
                  child: TextField(
                    controller: _noteController,
                    style: const TextStyle(fontSize: 17),
                    decoration: _compactInput,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: appPrimary(context), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: _save,
                child: Text(t(context, 'save'), style: const TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _changeType(String type) {
    setState(() {
      _type = type;
      _category = _categories.first;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: _date,
      builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: Theme.of(context).colorScheme.copyWith(primary: appPrimary(context))), child: child!),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final amount = parseMoneyInput(_amountController.text);
    if (amount <= 0) {
      showSnack(context, t(context, 'amountRequired'));
      return;
    }
    await widget.onSave(
      MoneyTransaction(
        id: widget.transaction?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        type: _type,
        date: _date,
        category: _category,
        amount: amount,
        note: _noteController.text.trim(),
      ),
    );
    if (mounted) Navigator.pop(context);
  }
}

class FormRow extends StatelessWidget {
  const FormRow({
    super.key,
    required this.label,
    required this.child,
    this.trailing,
  });

  final String label;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final labelWidth = constraints.maxWidth < 390 ? 96.0 : 118.0;
        return Row(
          children: [
            SizedBox(
              width: labelWidth,
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15.5, color: textMuted, fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(child: child),
            if (trailing != null) SizedBox(width: 40, child: Center(child: trailing!)),
          ],
        );
      },
    );
  }
}

class SegmentedChoice extends StatelessWidget {
  const SegmentedChoice({
    super.key,
    required this.left,
    required this.right,
    required this.selectedLeft,
    required this.onLeft,
    required this.onRight,
  });

  final String left;
  final String right;
  final bool selectedLeft;
  final VoidCallback onLeft;
  final VoidCallback onRight;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: lineColor),
      ),
      child: Row(
        children: [
          Expanded(child: _button(context, left, selectedLeft, onLeft)),
          Expanded(child: _button(context, right, !selectedLeft, onRight)),
        ],
      ),
    );
  }

  Widget _button(BuildContext context, String text, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? appPrimary(context) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              text,
              style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700, color: selected ? Colors.white : textMuted),
            ),
          ),
        ),
      ),
    );
  }
}

class AppMenu extends StatelessWidget {
  const AppMenu({
    super.key,
    required this.onNavigate,
    required this.expenseCategories,
    required this.incomeCategories,
    required this.onSaveCategories,
    required this.onBackupPayload,
    required this.onRestoreBackup,
    required this.transactions,
  });

  final ValueChanged<Widget> onNavigate;
  final List<String> expenseCategories;
  final List<String> incomeCategories;
  final Future<void> Function(String type, List<String> categories) onSaveCategories;
  final Future<Map<String, dynamic>> Function() onBackupPayload;
  final Future<void> Function(Map<String, dynamic> backup) onRestoreBackup;
  final List<MoneyTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: min<double>(MediaQuery.of(context).size.width * 0.78, 340),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 18),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset('assets/icons/app_icon.png', width: 48, height: 48),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      appName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            DrawerItem(icon: Icons.search, color: Colors.orange, title: t(context, 'search'), onTap: () => onNavigate(SearchPage(transactions: transactions, categories: [...expenseCategories, ...incomeCategories], onEdit: (_) {}))),
            DrawerItem(icon: Icons.pie_chart_outline, color: Colors.purple.shade300, title: t(context, 'chart'), onTap: () => onNavigate(GraphPage(transactions: transactions))),
            DrawerItem(icon: Icons.assignment_outlined, color: Colors.red.shade300, title: t(context, 'category'), onTap: () => onNavigate(CategoryPage(expenseCategories: expenseCategories, incomeCategories: incomeCategories, onSaveCategories: onSaveCategories))),
            DrawerItem(icon: Icons.settings_outlined, color: Colors.lightBlue, title: t(context, 'settings'), onTap: () => onNavigate(SettingsPage(onBackupPayload: onBackupPayload, onRestoreBackup: onRestoreBackup))),
            DrawerItem(icon: Icons.star_border, color: Colors.amber, title: t(context, 'rate'), onTap: () => showSnack(context, 'Terima kasih atas penilaiannya.')),
            DrawerItem(icon: Icons.help_outline, color: Colors.green, title: t(context, 'help'), onTap: () => onNavigate(const HelpPage())),
            DrawerItem(icon: Icons.info_outline, color: Colors.teal.shade300, title: t(context, 'about'), onTap: () => onNavigate(const AboutPage())),
          ],
        ),
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  const DrawerItem({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            Navigator.pop(context);
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700, color: textPrimary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
    required this.transactions,
    required this.categories,
    required this.onEdit,
  });

  final List<MoneyTransaction> transactions;
  final List<String> categories;
  final ValueChanged<MoneyTransaction> onEdit;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _keyword = TextEditingController();
  final _min = TextEditingController();
  final _max = TextEditingController();
  String _type = 'total';
  String? _category;

  @override
  void dispose() {
    _keyword.dispose();
    _min.dispose();
    _max.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = widget.transactions.where(_matches).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: Text(t(context, 'search')),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _type,
                dropdownColor: appPrimary(context),
                iconEnabledColor: Colors.white,
                style: const TextStyle(color: Colors.white, fontSize: 20),
                items: [
                  const DropdownMenuItem(value: 'total', child: Text('Total')),
                  DropdownMenuItem(value: 'income', child: Text(t(context, 'income'))),
                  DropdownMenuItem(value: 'expense', child: Text(t(context, 'expense'))),
                ],
                onChanged: (value) => setState(() => _type = value ?? 'total'),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: lineColor),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x10000000),
                  blurRadius: 12,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _keyword,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: t(context, 'keyword'),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  items: [null, ...widget.categories.toSet()]
                      .map((cat) => DropdownMenuItem(value: cat, child: Text(cat ?? t(context, 'allCategories'))))
                      .toList(),
                  onChanged: (value) => setState(() => _category = value),
                  decoration: InputDecoration(
                    labelText: t(context, 'category'),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                Text(t(context, 'amount'), style: const TextStyle(fontSize: 13.5, color: textMuted, fontWeight: FontWeight.w700)),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Expanded(child: SearchAmount(controller: _min, hint: t(context, 'min'), onChanged: () => setState(() {}))),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('~', style: TextStyle(fontSize: 17, color: textMuted, fontWeight: FontWeight.w800)),
                    ),
                    Expanded(child: SearchAmount(controller: _max, hint: t(context, 'max'), onChanged: () => setState(() {}))),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? const EmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                    itemCount: results.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      final tx = results[index];
                      return Material(
                        color: surface,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => widget.onEdit(tx),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: lineColor),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(tx.category, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                                      const SizedBox(height: 4),
                                      Text('${formatDate(tx.date)}${tx.note.isEmpty ? '' : ' - ${tx.note}'}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: textMuted)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(money(tx.amount, context), style: TextStyle(color: tx.isIncome ? incomeGreen : expenseRed, fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            color: pageBg,
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: () => showExportDialog(context, results),
                icon: const Icon(Icons.file_download, size: 22),
                label: Text(t(context, 'export'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _matches(MoneyTransaction tx) {
    if (_type != 'total' && tx.type != _type) return false;
    if (_category != null && tx.category != _category) return false;
    final text = '${tx.category} ${tx.note}'.toLowerCase();
    if (_keyword.text.isNotEmpty && !text.contains(_keyword.text.toLowerCase())) return false;
    final min = parseMoneyInput(_min.text);
    final max = parseMoneyInput(_max.text);
    if (min > 0 && tx.amount < min) return false;
    if (max > 0 && tx.amount > max) return false;
    return true;
  }
}

class SearchAmount extends StatelessWidget {
  const SearchAmount({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [MoneyInputFormatter(context)],
      onChanged: (_) => onChanged(),
      textAlign: TextAlign.left,
      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      ),
    );
  }
}

class CategoryPage extends StatefulWidget {
  const CategoryPage({
    super.key,
    required this.expenseCategories,
    required this.incomeCategories,
    required this.onSaveCategories,
    this.initialType = 'expense',
  });

  final List<String> expenseCategories;
  final List<String> incomeCategories;
  final String initialType;
  final Future<void> Function(String type, List<String> categories) onSaveCategories;

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late String _type;
  late List<String> _expense;
  late List<String> _income;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _expense = [...widget.expenseCategories];
    _income = [...widget.incomeCategories];
  }

  List<String> get _current => _type == 'expense' ? _expense : _income;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: Text(t(context, 'category')),
        actions: [IconButton(onPressed: _addCategory, icon: const Icon(Icons.add, size: 36))],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: SegmentedChoice(
              left: t(context, 'expense'),
              right: t(context, 'income'),
              selectedLeft: _type == 'expense',
              onLeft: () => setState(() => _type = 'expense'),
              onRight: () => setState(() => _type = 'income'),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _current.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (_, index) {
                final category = _current[index];
                return ListTile(
                  tileColor: Colors.white,
                  contentPadding: const EdgeInsets.only(left: 30, right: 12, top: 13, bottom: 13),
                  title: Text(category, style: const TextStyle(fontSize: 22, color: Color(0xFF5C5C5C))),
                  trailing: Wrap(
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Color(0xFF8F8F8F)), onPressed: () => _editCategory(index)),
                      IconButton(icon: const Icon(Icons.delete, color: Color(0xFF8F8F8F)), onPressed: () => _deleteCategory(index)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addCategory() async {
    final value = await promptText(context, t(context, 'addCategory'));
    if (value == null || value.trim().isEmpty) return;
    setState(() => _current.add(value.trim()));
    await widget.onSaveCategories(_type, _current);
  }

  Future<void> _editCategory(int index) async {
    final value = await promptText(context, t(context, 'editCategory'), initial: _current[index]);
    if (value == null || value.trim().isEmpty) return;
    setState(() => _current[index] = value.trim());
    await widget.onSaveCategories(_type, _current);
  }

  Future<void> _deleteCategory(int index) async {
    if (!await confirm(context, t(context, 'deleteCategory'))) return;
    setState(() => _current.removeAt(index));
    await widget.onSaveCategories(_type, _current);
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.onBackupPayload,
    required this.onRestoreBackup,
  });

  final Future<Map<String, dynamic>> Function() onBackupPayload;
  final Future<void> Function(Map<String, dynamic> backup) onRestoreBackup;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: Text(t(context, 'settings')),
      ),
      body: ListView(
        children: [
          SettingsTile(
            title: t(context, 'themeColor'),
            subtitle: themeName(AppLocaleScope.of(context).themeKey),
            onTap: () => showThemePicker(context),
          ),
          SettingsTile(
            title: t(context, 'currencyFormat'),
            subtitle: currencyName(AppLocaleScope.of(context).currencyCode),
            onTap: () => showCurrencyPicker(context),
          ),
          SettingsTile(title: t(context, 'openingBalance'), subtitle: t(context, 'inactive')),
          SettingsTile(title: t(context, 'removeAds'), subtitle: t(context, 'inactive')),
          SettingsTile(title: t(context, 'transactionTime'), subtitle: t(context, 'inactive')),
          SettingsTile(
            title: t(context, 'selectLanguage'),
            subtitle: languageName(AppLocaleScope.of(context).languageCode),
            onTap: () => showLanguagePicker(context),
          ),
          SettingsTile(title: t(context, 'firstWeekday'), subtitle: 'Minggu'),
          SettingsTile(title: t(context, 'firstMonthDate'), subtitle: '1'),
          const Divider(thickness: 2),
          SettingsTile(title: t(context, 'reminder'), subtitle: t(context, 'inactive'), onTap: () => showSnack(context, '${t(context, 'reminder')} ${t(context, 'inactive').toLowerCase()}')),
          SettingsTile(title: t(context, 'pin'), subtitle: t(context, 'inactive'), onTap: () => showSnack(context, '${t(context, 'pin')} ${t(context, 'inactive').toLowerCase()}')),
          SettingsTile(title: t(context, 'quickOpen'), subtitle: t(context, 'inactive'), onTap: () => showSnack(context, '${t(context, 'quickOpen')} ${t(context, 'inactive').toLowerCase()}')),
          const Divider(thickness: 2),
          SettingsTile(title: t(context, 'backupDrive'), onTap: () => showBackupSheet(context, true)),
          SettingsTile(title: t(context, 'backupStorage'), onTap: () => showBackupSheet(context, false)),
          SettingsTile(title: t(context, 'shareDatabase'), onTap: () => shareBackup(context)),
          SettingsTile(title: t(context, 'resetData'), onTap: () => showSnack(context, 'Gunakan restore backup kosong untuk setel ulang.')),
          const SizedBox(height: 80),
          const Center(child: Text('Catatan Keuangan\nVersion $appVersion', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16))),
        ],
      ),
    );
  }

  Future<void> showLanguagePicker(BuildContext context) async {
    final scope = AppLocaleScope.of(context);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: supportedLanguages.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final language = supportedLanguages[index];
              final selected = language.code == scope.languageCode;
              return ListTile(
                leading: Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: selected ? appPrimary(context) : Colors.grey),
                title: Text(language.nativeName, style: const TextStyle(fontSize: 18)),
                subtitle: Text(language.englishName),
                onTap: () async {
                  await scope.setLanguage(language.code);
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<void> showThemePicker(BuildContext context) async {
    final scope = AppLocaleScope.of(context);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: GridView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.95,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: themeVariants.length,
            itemBuilder: (context, index) {
              final item = themeVariants[index];
              final selected = item.key == scope.themeKey;
              return InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () async {
                  await scope.setTheme(item.key);
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: selected ? item.soft : surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: selected ? item.primary : lineColor, width: selected ? 2 : 1),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(color: item.primary, shape: BoxShape.circle),
                        child: selected ? const Icon(Icons.check, color: Colors.white) : null,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> showCurrencyPicker(BuildContext context) async {
    final scope = AppLocaleScope.of(context);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: currencyVariants.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = currencyVariants[index];
              final selected = item.code == scope.currencyCode;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: selected ? scope.primaryColor : const Color(0xFFF0F2F5),
                  child: Text(
                    item.symbol,
                    style: TextStyle(color: selected ? Colors.white : textPrimary, fontWeight: FontWeight.w800),
                  ),
                ),
                title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(item.code),
                trailing: selected ? Icon(Icons.check_circle, color: scope.primaryColor) : null,
                onTap: () async {
                  await scope.setCurrency(item.code);
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<void> showBackupSheet(BuildContext context, bool googleDrive) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.backup, color: appPrimary(context)),
              title: Text(googleDrive ? 'Backup ke Google Drive' : 'Backup ke Device Storage'),
              onTap: () {
                Navigator.pop(context);
                googleDrive ? shareBackup(context) : saveBackup(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.restore, color: incomeGreen),
              title: Text(googleDrive ? 'Restore dari Google Drive' : 'Restore dari Device Storage'),
              onTap: () {
                Navigator.pop(context);
                restoreBackup(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _backupJson() async => const JsonEncoder.withIndent('  ').convert(await onBackupPayload());

  Future<void> shareBackup(BuildContext context) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/catatan-keuangan-pro-backup.json');
    await file.writeAsString(await _backupJson());
    await SharePlus.instance.share(
      ShareParams(
        text: 'Backup Catatan Keuangan PRO',
        files: [XFile(file.path, mimeType: 'application/json')],
      ),
    );
  }

  Future<void> saveBackup(BuildContext context) async {
    final bytes = utf8.encode(await _backupJson());
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan Backup Catatan Keuangan PRO',
      fileName: 'catatan-keuangan-pro-backup.json',
      type: FileType.custom,
      allowedExtensions: ['json'],
      bytes: bytes,
    );
    if (context.mounted) showSnack(context, path == null ? t(context, 'backupCancelled') : t(context, 'backupSaved'));
  }

  Future<void> restoreBackup(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
    if (result == null || result.files.single.path == null) return;
    final file = File(result.files.single.path!);
    final decoded = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    await onRestoreBackup(decoded);
    if (context.mounted) showSnack(context, t(context, 'restoreDone'));
  }
}

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: Material(
        color: surface,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: lineColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700, color: textPrimary),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14.5, color: appPrimary(context), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ],
                  ),
                ),
                if (onTap != null) const Icon(Icons.chevron_right, size: 24, color: textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GraphPage extends StatelessWidget {
  const GraphPage({super.key, required this.transactions});
  final List<MoneyTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    final totals = <String, int>{};
    for (final tx in transactions) {
      totals[tx.category] = (totals[tx.category] ?? 0) + tx.amount;
    }
    final rows = totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final chartRows = rows.take(8).toList();
    final maxValue = rows.isEmpty ? 1 : rows.map((e) => e.value).reduce(max);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: Text(t(context, 'chart')),
      ),
      body: rows.isEmpty
          ? const EmptyState()
          : ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
              children: [
                Container(
                  height: 290,
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: lineColor),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x10000000),
                        blurRadius: 12,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: chartRows.map((row) {
                          final barHeight = max(18.0, (row.value / maxValue) * (constraints.maxHeight - 66));
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    money(row.value, context),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 10.5, color: textMuted, fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 6),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    height: barHeight,
                                    decoration: BoxDecoration(
                                      color: appPrimary(context),
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    row.key,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 11, color: textPrimary, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                ...rows.map((row) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: lineColor),
                    ),
                    child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          row.key,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        money(row.value, context),
                        style: TextStyle(fontSize: 15, color: appPrimary(context), fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  );
                }),
              ],
            ),
    );
  }
}

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: const Text('Bantuan'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Gunakan tombol tambah untuk mencatat transaksi. Data tersimpan otomatis di perangkat. Backup dapat dibuat ke storage perangkat atau dibagikan ke Google Drive.',
          style: TextStyle(fontSize: 20, height: 1.5),
        ),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: const Text('Tentang'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 38),
              child: Column(
                children: [
                  ClipRRect(borderRadius: BorderRadius.circular(36), child: Image.asset('assets/icons/app_icon.png', width: 190, height: 190)),
                  const SizedBox(height: 22),
                  const Text('Version : $appVersion', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 32),
                  const Text(
                    'Catatan Keuangan PRO adalah aplikasi yang berfungsi untuk mencatat aktivitas keuangan anda baik aktivitas pengeluaran maupun pemasukan. Aplikasi ini dibuat simple dan ringan sehingga memudahkan user dalam pemakaiannya.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 21, height: 1.55, color: Color(0xFF5C5C5C)),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Harap kirimkan screenshot jika Anda menemukan kesalahan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 19, height: 1.45, color: Color(0xFF5C5C5C)),
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: appPrimary(context), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7))),
                    onPressed: () {},
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Text('support@catatankeuangan.pro', style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          TextButton(onPressed: () {}, child: const Text('Bagikan ke teman', style: TextStyle(fontSize: 20, decoration: TextDecoration.underline, color: expenseRed))),
          TextButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DonationPage())),
            child: const Text('Hadiah untuk developer', style: TextStyle(fontSize: 20, decoration: TextDecoration.underline, color: expenseRed)),
          ),
        ],
      ),
    );
  }
}

class DonationPage extends StatelessWidget {
  const DonationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final values = [1000, 2000, 5000, 10000, 15000, 25000, 35000, 50000];
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: const Text('Hadiah untuk developer'),
      ),
      body: ListView.separated(
        itemCount: values.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (_, index) => ListTile(
          tileColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
          title: Text(money(values[index], context), style: const TextStyle(fontSize: 22, color: Color(0xFF5C5C5C))),
          trailing: const Icon(Icons.card_giftcard, color: Color(0xFF8F8F8F), size: 36),
          onTap: () => showSnack(context, 'Terima kasih. Fitur hadiah dapat disambungkan ke payment gateway.'),
        ),
      ),
    );
  }
}

Future<void> showExportDialog(BuildContext context, List<MoneyTransaction> transactions) async {
  String category = 'Semua Kategori';
  String format = 'CSV';
  await showDialog<void>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  color: const Color(0xFF555555),
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  child: const Text('EKSPOR', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w700)),
                ),
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Judul', style: TextStyle(fontSize: 22)),
                      const SizedBox(height: 12),
                      const Text('Laporan Keuangan', style: TextStyle(fontSize: 20, color: Color(0xFF5C5C5C))),
                      const Divider(height: 28),
                      Row(
                        children: [
                          Expanded(child: _exportText('Dari Tanggal', '01 ${monthNames[DateTime.now().month - 1]} ${DateTime.now().year}')),
                          Expanded(child: _exportText('Sampai Tanggal', '${two(DateUtils.getDaysInMonth(DateTime.now().year, DateTime.now().month))} ${monthNames[DateTime.now().month - 1]} ${DateTime.now().year}')),
                        ],
                      ),
                      const Divider(height: 28),
                      DropdownButtonFormField<String>(
                        initialValue: category,
                        decoration: const InputDecoration(labelText: 'Kategori', border: UnderlineInputBorder()),
                        items: const ['Semua Kategori', 'Pemasukan', 'Pengeluaran', 'Sesuaikan'].map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                        onChanged: (value) => setState(() => category = value ?? category),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: format,
                        decoration: const InputDecoration(labelText: 'Format', border: UnderlineInputBorder()),
                        items: const ['CSV', 'JSON'].map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                        onChanged: (value) => setState(() => format = value ?? format),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 64,
                        child: FilledButton(
                          style: FilledButton.styleFrom(backgroundColor: appPrimary(context), shape: const RoundedRectangleBorder()),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('BATAL', style: TextStyle(fontSize: 20, color: Colors.white)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 64,
                        child: FilledButton(
                          style: FilledButton.styleFrom(backgroundColor: incomeGreen, shape: const RoundedRectangleBorder()),
                          onPressed: () async {
                            await exportTransactions(transactions, format);
                            if (context.mounted) Navigator.pop(context);
                          },
                          child: const Text('EKSPOR', style: TextStyle(fontSize: 20, color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _exportText(String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 20)),
      const SizedBox(height: 12),
      Text(value, style: const TextStyle(fontSize: 20, color: Color(0xFF5C5C5C))),
    ],
  );
}

Future<void> exportTransactions(List<MoneyTransaction> transactions, String format) async {
  final content = format == 'JSON'
      ? const JsonEncoder.withIndent('  ').convert(transactions.map((tx) => tx.toJson()).toList())
      : [
          'tanggal,tipe,kategori,jumlah,keterangan',
          ...transactions.map((tx) => '${formatDate(tx.date)},${tx.type},${tx.category},${tx.amount},"${tx.note.replaceAll('"', '""')}"'),
        ].join('\n');
  final tempDir = await getTemporaryDirectory();
  final extension = format == 'JSON' ? 'json' : 'csv';
  final file = File('${tempDir.path}/laporan-keuangan.$extension');
  await file.writeAsString(content);
  await SharePlus.instance.share(ShareParams(text: 'Laporan Keuangan', files: [XFile(file.path)]));
}

Future<String?> promptText(BuildContext context, String title, {String initial = ''}) async {
  final controller = TextEditingController(text: initial);
  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(controller: controller, autofocus: true),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Simpan')),
      ],
    ),
  );
  controller.dispose();
  return result;
}

Future<bool> confirm(BuildContext context, String title) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ya')),
          ],
        ),
      ) ??
      false;
}

void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

String money(int value, [BuildContext? context]) {
  final currency = context == null
      ? currencyVariants.first
      : AppLocaleScope.of(context).currency;
  return NumberFormat.currency(
    locale: currency.locale,
    symbol: currency.symbol,
    decimalDigits: currency.decimalDigits,
  ).format(value);
}

String formatMoneyInput(String raw, BuildContext context) {
  final amount = parseMoneyInput(raw);
  if (amount == 0) return '';
  return money(amount, context);
}

int parseMoneyInput(String raw) {
  final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
  return int.tryParse(digits) ?? 0;
}

class MoneyInputFormatter extends TextInputFormatter {
  MoneyInputFormatter(this.context);

  final BuildContext context;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final formatted = formatMoneyInput(newValue.text, context);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

String formatDate(DateTime date) => '${two(date.day)} ${monthNames[date.month - 1]} ${date.year}';

String periodTitle(DateTime date, int tabIndex) {
  return switch (tabIndex) {
    0 => '${monthNames[date.month - 1]} ${date.year}',
    1 => '${monthNames[date.month - 1]} ${date.year}',
    2 => '${date.year}',
    _ => 'Total',
  };
}

DateTime shiftDate(DateTime source, int tabIndex, int delta) {
  return switch (tabIndex) {
    0 => source.add(Duration(days: delta)),
    1 => source.add(Duration(days: delta * 7)),
    2 => DateTime(source.year, source.month + delta, 1),
    _ => DateTime(source.year + delta, 1, 1),
  };
}

String two(int value) => value.toString().padLeft(2, '0');

int totalAmount(List<MoneyTransaction> transactions, String type) {
  return transactions.where((tx) => tx.type == type).fold(0, (sum, tx) => sum + tx.amount);
}

bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

DateTime startOfWeek(DateTime date) {
  final start = DateTime(date.year, date.month, date.day);
  return start.subtract(Duration(days: start.weekday % 7));
}

bool isSameWeek(DateTime a, DateTime b) {
  return isSameDay(startOfWeek(a), startOfWeek(b));
}

List<WeekRange> monthWeeks(DateTime date) {
  final first = DateTime(date.year, date.month, 1);
  final last = DateTime(date.year, date.month + 1, 1);
  final ranges = <WeekRange>[];
  var start = startOfWeek(first);
  var index = 1;
  while (start.isBefore(last)) {
    final end = start.add(const Duration(days: 7));
    ranges.add(WeekRange(index, start, end));
    start = end;
    index++;
  }
  return ranges;
}
