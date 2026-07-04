import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

const appName = 'Catatan Keuangan PRO';
const appVersion = '1.1.25';
const brandRed = Color(0xFFE9433D);
const incomeGreen = Color(0xFF08A345);
const expenseRed = Color(0xFFD7473F);
const pageBg = Color(0xFFF0F0F0);
const storageTransactionsKey = 'transactions_v1';
const storageExpenseCategoriesKey = 'expense_categories_v1';
const storageIncomeCategoriesKey = 'income_categories_v1';

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

class FinanceApp extends StatelessWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: brandRed),
        scaffoldBackgroundColor: pageBg,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: brandRed,
          foregroundColor: Colors.white,
          elevation: 1,
          centerTitle: false,
          titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
          iconTheme: IconThemeData(color: Colors.white, size: 30),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: brandRed,
          foregroundColor: Colors.white,
          elevation: 7,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: brandRed, width: 1.5),
          ),
        ),
        useMaterial3: true,
      ),
      home: const AppShell(),
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
            tooltip: 'Ekspor',
            onPressed: () => showExportDialog(context, widget.transactions),
            icon: const Icon(Icons.file_download),
          ),
          IconButton(
            tooltip: 'Urutkan',
            onPressed: widget.onToggleSort,
            icon: const Icon(Icons.sort),
          ),
          IconButton(
            tooltip: 'Pencarian',
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
          indicatorWeight: 5,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white,
          labelStyle: const TextStyle(fontSize: 20),
          tabs: const [
            Tab(text: 'Harian'),
            Tab(text: 'Mingguan'),
            Tab(text: 'Bulanan'),
            Tab(text: 'Tahunan'),
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
        width: 76,
        height: 76,
        child: FloatingActionButton(
          shape: const CircleBorder(),
          onPressed: widget.onCreate,
          child: const Icon(Icons.add, size: 40),
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
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          SummaryItem(title: 'Pemasukan', value: income, color: incomeGreen),
          SummaryItem(title: 'Pengeluaran', value: expense, color: expenseRed),
          SummaryItem(title: 'Saldo', value: balance, color: Colors.black87),
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
  });

  final String title;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 19, color: Color(0xFF555555))),
          const SizedBox(height: 4),
          Text(
            value == 0 ? '0' : money(value),
            style: TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.w500),
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
      padding: const EdgeInsets.only(bottom: 120),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
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
          confirmDismiss: (_) => confirm(context, 'Hapus transaksi ini?'),
          onDismissed: (_) => onDelete(tx.id),
          child: ListTile(
            tileColor: Colors.white,
            onTap: () => onEdit(tx),
            leading: CircleAvatar(
              backgroundColor: tx.isIncome ? incomeGreen : expenseRed,
              child: Icon(tx.isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: Colors.white),
            ),
            title: Text(tx.category, style: const TextStyle(fontSize: 18)),
            subtitle: Text('${formatDate(tx.date)}${tx.note.isEmpty ? '' : ' - ${tx.note}'}'),
            trailing: Text(
              money(tx.amount),
              style: TextStyle(
                color: tx.isIncome ? incomeGreen : expenseRed,
                fontSize: 18,
                fontWeight: FontWeight.w600,
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
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.description_outlined, size: 72, color: Color(0xFFD5D5D5)),
          SizedBox(height: 16),
          Text('Data tidak tersedia', style: TextStyle(fontSize: 20, color: Color(0xFFB0B0B0))),
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
      padding: const EdgeInsets.only(bottom: 120),
      itemCount: rows.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (_, index) {
        final row = rows[index];
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
          child: Row(
            children: [
              SizedBox(
                width: 190,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (row.label != null)
                      Center(
                        widthFactor: 1.8,
                        child: Text(row.label!, style: const TextStyle(fontSize: 17, color: Color(0xFF555555))),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: row.selected ? const Color(0xFFFFB154) : const Color(0xFF8C8C8C),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(row.badge, style: const TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Text(money(row.income), style: const TextStyle(color: incomeGreen, fontSize: 18)),
              ),
              Text(money(row.expense), style: const TextStyle(color: expenseRed, fontSize: 18)),
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
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  List<String> get _categories => _type == 'expense' ? widget.expenseCategories : widget.incomeCategories;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: const Text('Buat Transaksi'),
        actions: const [Padding(padding: EdgeInsets.only(right: 22), child: Icon(Icons.copy_outlined))],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(10, 12, 10, 30),
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                SegmentedChoice(
                  left: 'Pengeluaran',
                  right: 'Pemasukan',
                  selectedLeft: _type == 'expense',
                  onLeft: () => _changeType('expense'),
                  onRight: () => _changeType('income'),
                ),
                const SizedBox(height: 28),
                FormRow(
                  label: 'Tanggal',
                  child: InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(),
                      child: Text(formatDate(_date), style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FormRow(
                  label: 'Kategori',
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF8B8B8B), size: 32),
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
                    iconEnabledColor: brandRed,
                    style: const TextStyle(fontSize: 22, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 20),
                FormRow(
                  label: 'Jumlah',
                  trailing: const Icon(Icons.calculate, color: Color(0xFF8B8B8B), size: 34),
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(fontSize: 22),
                    decoration: const InputDecoration(),
                  ),
                ),
                const SizedBox(height: 20),
                FormRow(
                  label: 'Keterangan',
                  child: TextField(
                    controller: _noteController,
                    style: const TextStyle(fontSize: 22),
                    decoration: const InputDecoration(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          Center(
            child: SizedBox(
              width: 240,
              height: 64,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: brandRed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7))),
                onPressed: _save,
                child: const Text('SIMPAN', style: TextStyle(fontSize: 20, color: Colors.white)),
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
      builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: Theme.of(context).colorScheme.copyWith(primary: brandRed)), child: child!),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final amount = int.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      showSnack(context, 'Jumlah harus diisi.');
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
    return Row(
      children: [
        SizedBox(width: 220, child: Text(label, style: const TextStyle(fontSize: 22))),
        Expanded(child: child),
        if (trailing != null) SizedBox(width: 62, child: Center(child: trailing!)),
      ],
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
      height: 84,
      decoration: BoxDecoration(color: const Color(0xFFE8EAED), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Expanded(child: _button(left, selectedLeft, onLeft)),
          Expanded(child: _button(right, !selectedLeft, onRight)),
        ],
      ),
    );
  }

  Widget _button(String text, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: selected ? brandRed : Colors.transparent, borderRadius: BorderRadius.circular(8)),
        child: Text(text, style: TextStyle(fontSize: 22, color: selected ? Colors.white : Colors.black87)),
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
      width: MediaQuery.of(context).size.width * 0.7,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          children: [
            DrawerItem(icon: Icons.search, color: Colors.orange, title: 'Pencarian', onTap: () => onNavigate(SearchPage(transactions: transactions, categories: [...expenseCategories, ...incomeCategories], onEdit: (_) {}))),
            DrawerItem(icon: Icons.pie_chart_outline, color: Colors.purple.shade300, title: 'Grafik', onTap: () => onNavigate(GraphPage(transactions: transactions))),
            DrawerItem(icon: Icons.assignment_outlined, color: Colors.red.shade300, title: 'Kategori', onTap: () => onNavigate(CategoryPage(expenseCategories: expenseCategories, incomeCategories: incomeCategories, onSaveCategories: onSaveCategories))),
            DrawerItem(icon: Icons.settings_outlined, color: Colors.lightBlue, title: 'Pengaturan', onTap: () => onNavigate(SettingsPage(onBackupPayload: onBackupPayload, onRestoreBackup: onRestoreBackup))),
            DrawerItem(icon: Icons.star_border, color: Colors.amber, title: 'Beri Penilaian', onTap: () => showSnack(context, 'Terima kasih atas penilaiannya.')),
            DrawerItem(icon: Icons.help_outline, color: Colors.green, title: 'Bantuan', onTap: () => onNavigate(const HelpPage())),
            DrawerItem(icon: Icons.info_outline, color: Colors.teal.shade300, title: 'Tentang', onTap: () => onNavigate(const AboutPage())),
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
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 13),
      leading: Icon(icon, color: color, size: 38),
      title: Text(title, style: const TextStyle(fontSize: 22, color: Color(0xFF5A5A5A))),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
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
        title: const Text('Pencarian'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _type,
                dropdownColor: brandRed,
                iconEnabledColor: Colors.white,
                style: const TextStyle(color: Colors.white, fontSize: 20),
                items: const [
                  DropdownMenuItem(value: 'total', child: Text('Total')),
                  DropdownMenuItem(value: 'income', child: Text('Pemasukan')),
                  DropdownMenuItem(value: 'expense', child: Text('Pengeluaran')),
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
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(28, 18, 28, 18),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.search, size: 42, color: Color(0xFF4D4D4D)),
                    const SizedBox(width: 28),
                    Expanded(
                      child: TextField(
                        controller: _keyword,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(border: InputBorder.none, hintText: 'Kata Kunci', hintStyle: TextStyle(fontSize: 22)),
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  children: [
                    const SizedBox(width: 150, child: Text('Kategori', style: TextStyle(fontSize: 20, color: Color(0xFF555555)))),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _category,
                        items: [null, ...widget.categories.toSet()].map((cat) => DropdownMenuItem(value: cat, child: Text(cat ?? 'Semua Kategori'))).toList(),
                        onChanged: (value) => setState(() => _category = value),
                        decoration: const InputDecoration(fillColor: Color(0xFFE8E8EA), filled: true, border: InputBorder.none),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const SizedBox(width: 150, child: Text('Jumlah', style: TextStyle(fontSize: 20, color: Color(0xFF555555)))),
                    Expanded(child: SearchAmount(controller: _min, hint: 'Min', onChanged: () => setState(() {}))),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('~', style: TextStyle(fontSize: 22))),
                    Expanded(child: SearchAmount(controller: _max, hint: 'Max', onChanged: () => setState(() {}))),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? const EmptyState()
                : ListView.separated(
                    itemCount: results.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (_, index) {
                      final tx = results[index];
                      return ListTile(
                        tileColor: Colors.white,
                        onTap: () => widget.onEdit(tx),
                        title: Text(tx.category),
                        subtitle: Text('${formatDate(tx.date)} - ${tx.note}'),
                        trailing: Text(money(tx.amount), style: TextStyle(color: tx.isIncome ? incomeGreen : expenseRed)),
                      );
                    },
                  ),
          ),
          Container(
            height: 72,
            width: double.infinity,
            color: brandRed,
            child: IconButton(
              icon: const Icon(Icons.file_download, color: Colors.white, size: 42),
              onPressed: () => showExportDialog(context, results),
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
    final min = int.tryParse(_min.text);
    final max = int.tryParse(_max.text);
    if (min != null && tx.amount < min) return false;
    if (max != null && tx.amount > max) return false;
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
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (_) => onChanged(),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFE8E8EA),
        border: InputBorder.none,
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
        title: const Text('Kategori'),
        actions: [IconButton(onPressed: _addCategory, icon: const Icon(Icons.add, size: 36))],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: SegmentedChoice(
              left: 'Pengeluaran',
              right: 'Pemasukan',
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
    final value = await promptText(context, 'Tambah Kategori');
    if (value == null || value.trim().isEmpty) return;
    setState(() => _current.add(value.trim()));
    await widget.onSaveCategories(_type, _current);
  }

  Future<void> _editCategory(int index) async {
    final value = await promptText(context, 'Edit Kategori', initial: _current[index]);
    if (value == null || value.trim().isEmpty) return;
    setState(() => _current[index] = value.trim());
    await widget.onSaveCategories(_type, _current);
  }

  Future<void> _deleteCategory(int index) async {
    if (!await confirm(context, 'Hapus kategori ini?')) return;
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
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        children: [
          const SettingsTile(title: 'Atur Warna Tema', subtitle: 'Red Amber'),
          const SettingsTile(title: 'Format Mata Uang', subtitle: 'Indonesian rupiah(Rp)'),
          const SettingsTile(title: 'Atur Saldo Bawaan', subtitle: 'Tidak Aktif'),
          const SettingsTile(title: 'Hapus Iklan', subtitle: 'Tidak Aktif'),
          const SettingsTile(title: 'Waktu/Jam Transaksi', subtitle: 'Tidak Aktif'),
          const SettingsTile(title: 'Pilih Bahasa', subtitle: 'Indonesia'),
          const SettingsTile(title: 'Hari Pertama Mingguan', subtitle: 'Minggu'),
          const SettingsTile(title: 'Tanggal Pertama Bulanan', subtitle: '1'),
          const Divider(thickness: 2),
          SettingsTile(title: 'Pengingat', subtitle: 'Tidak Aktif', onTap: () => showSnack(context, 'Pengingat belum aktif.')),
          SettingsTile(title: 'Atur PIN', subtitle: 'Tidak Aktif', onTap: () => showSnack(context, 'PIN belum aktif.')),
          SettingsTile(title: 'Buka Cepat', subtitle: 'Tidak Aktif', onTap: () => showSnack(context, 'Buka cepat belum aktif.')),
          const Divider(thickness: 2),
          SettingsTile(title: 'Backup/Restore di Google Drive', onTap: () => showBackupSheet(context, true)),
          SettingsTile(title: 'Backup/Restore di Device Storage', onTap: () => showBackupSheet(context, false)),
          SettingsTile(title: 'Kirim File Database', onTap: () => shareBackup(context)),
          SettingsTile(title: 'Setel Ulang Data', onTap: () => showSnack(context, 'Gunakan restore backup kosong untuk setel ulang.')),
          const SizedBox(height: 80),
          const Center(child: Text('Catatan Keuangan\nVersion $appVersion', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16))),
        ],
      ),
    );
  }

  Future<void> showBackupSheet(BuildContext context, bool googleDrive) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.backup, color: brandRed),
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
    if (context.mounted) showSnack(context, path == null ? 'Backup dibatalkan.' : 'Backup tersimpan.');
  }

  Future<void> restoreBackup(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
    if (result == null || result.files.single.path == null) return;
    final file = File(result.files.single.path!);
    final decoded = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    await onRestoreBackup(decoded);
    if (context.mounted) showSnack(context, 'Data berhasil dipulihkan.');
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
    return ListTile(
      tileColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      title: Text(title, style: const TextStyle(fontSize: 21, color: Color(0xFF222222))),
      subtitle: subtitle == null ? null : Text(subtitle!, style: const TextStyle(fontSize: 20, color: expenseRed)),
      trailing: onTap == null ? null : const Icon(Icons.chevron_right, size: 34),
      onTap: onTap,
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
    final maxValue = rows.isEmpty ? 1 : rows.map((e) => e.value).reduce(max);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: const Text('Grafik'),
      ),
      body: rows.isEmpty
          ? const EmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: rows.length,
              itemBuilder: (_, index) {
                final row = rows[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(row.key, style: const TextStyle(fontSize: 18)),
                          Text(money(row.value), style: const TextStyle(fontSize: 16, color: brandRed)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: row.value / maxValue, minHeight: 12, color: brandRed, backgroundColor: Colors.white),
                    ],
                  ),
                );
              },
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
                    style: FilledButton.styleFrom(backgroundColor: brandRed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7))),
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
          title: Text(money(values[index]), style: const TextStyle(fontSize: 22, color: Color(0xFF5C5C5C))),
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
                          style: FilledButton.styleFrom(backgroundColor: brandRed, shape: const RoundedRectangleBorder()),
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

String money(int value) {
  return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(value);
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
