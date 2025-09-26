import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:uuid/uuid.dart';
import 'package:confetti/confetti.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

/* =====================  I18N ===================== */

enum AppLang { pl, en, pt }

const _kLangKey = 'lang_v1';

String flagOf(AppLang l) {
  switch (l) {
    case AppLang.pl:
      return '🇵🇱';
    case AppLang.en:
      return '🇬🇧';
    case AppLang.pt:
      return '🇵🇹';
  }
}

const Map<AppLang, Map<String, String>> translations = {
  AppLang.pl: {
    'appTitle': 'Tablica głosów 🥳',
    'participants': 'Uczestnicy',
    'reset': 'Resetuj',
    'reset_q': 'Zresetować?',
    'reset_body': 'Usunie wszystkie głosy zapisane na tym iPadzie.',
    'cancel': 'Anuluj',
    'reset_btn': 'Resetuj',
    'boys_lead': '👦 Chłopcy prowadzą!',
    'girls_lead': '👧 Dziewczynki wyszły na prowadzenie!',
    'tie': 'Remis… pełen suspensu!',
    'total_votes': 'Łączna liczba głosów: {n}',
    'legend_boy': 'Chłopiec',
    'legend_girl': 'Dziewczynka',
    'abs_compare': 'Porównanie bezwzględne',
    'timeline': 'Ewolucja w czasie',
    'no_timeline': 'Brak danych do wykresu liniowego',
    'greet_named': 'Cześć, {name} 👋',
    'ask_name': 'Jak masz na imię?',
    'question': 'Jak obstawiasz płeć maluszka?',
    'hint_named': 'Zaufaj swojej intuicji…',
    'hint_no_name': 'Dotknij „Nowa odpowiedź”, aby podać imię.',
    'boy': 'Chłopiec',
    'girl': 'Dziewczynka',
    'boy_tag': 'Drużyna autek i dinozaurów',
    'girl_tag': 'Drużyna kokardek i brokatu',
    'cta_tap': 'Dotknij, aby zagłosować',
    'new_answer': 'Nowa odpowiedź',
    'name_arrow': 'Imię → wybierz opcję 👆',
    'dup_name': 'Ta osoba już głosowała. Użyj innego imienia.',
    'thanks_boy': 'Dziękujemy! Twój głos: Chłopiec',
    'thanks_girl': 'Dziękujemy! Twój głos: Dziewczynka',
    'dlg_new': 'Nowa odpowiedź',
    'name_label': 'Imię',
    'name_empty': 'Podaj swoje imię.',
    'name_toolong': 'Imię jest za długie.',
    'continue': 'Kontynuuj',
    'details': 'Szczegóły',
    'voted_at': 'Głos oddany: {stamp}',
  },
  AppLang.en: {
    'appTitle': 'Voting Board 🥳',
    'participants': 'Participants',
    'reset': 'Reset',
    'reset_q': 'Reset all?',
    'reset_body': 'This will delete all votes stored on this iPad.',
    'cancel': 'Cancel',
    'reset_btn': 'Reset',
    'boys_lead': '👦 Boys are leading!',
    'girls_lead': '👧 Girls took the lead!',
    'tie': 'It’s a tie… suspense!',
    'total_votes': 'Total votes: {n}',
    'legend_boy': 'Boy',
    'legend_girl': 'Girl',
    'abs_compare': 'Absolute comparison',
    'timeline': 'Timeline',
    'no_timeline': 'No timeline data yet',
    'greet_named': 'Hi, {name} 👋',
    'ask_name': 'What’s your name?',
    'question': 'What do you guess the baby’s gender is?',
    'hint_named': 'Trust your sixth sense…',
    'hint_no_name': 'Tap “New answer” to enter your name.',
    'boy': 'Boy',
    'girl': 'Girl',
    'boy_tag': 'Team cars & dinossaurs',
    'girl_tag': 'Team bows & glitter',
    'cta_tap': 'Tap to vote',
    'new_answer': 'New answer',
    'name_arrow': 'Name → choose an option 👆',
    'dup_name': 'This name already voted. Use a different one.',
    'thanks_boy': 'Thanks! Your vote: Boy',
    'thanks_girl': 'Thanks! Your vote: Girl',
    'dlg_new': 'New answer',
    'name_label': 'Name',
    'name_empty': 'Type your name.',
    'name_toolong': 'Name is too long.',
    'continue': 'Continue',
    'details': 'Details',
    'voted_at': 'Voted at: {stamp}',
  },
  AppLang.pt: {
    'appTitle': 'Quadro de votos 🥳',
    'participants': 'Participantes',
    'reset': 'Repor',
    'reset_q': 'Repor tudo?',
    'reset_body': 'Apaga todos os votos guardados neste iPad.',
    'cancel': 'Cancelar',
    'reset_btn': 'Repor',
    'boys_lead': '👦 Rapazes na frente!',
    'girls_lead': '👧 Raparigas passaram à frente!',
    'tie': 'Empate… suspense!',
    'total_votes': 'Total de votos: {n}',
    'legend_boy': 'Rapaz',
    'legend_girl': 'Rapariga',
    'abs_compare': 'Comparação absoluta',
    'timeline': 'Evolução temporal',
    'no_timeline': 'Ainda sem dados na linha temporal',
    'greet_named': 'Olá, {name} 👋',
    'ask_name': 'Como te chamas?',
    'question': 'Qual achas que será o sexo do bebé?',
    'hint_named': 'Confia no sexto sentido…',
    'hint_no_name': 'Toca em “Nova resposta” para escreveres o teu nome.',
    'boy': 'Rapaz',
    'girl': 'Rapariga',
    'boy_tag': 'Team carrinhos & dinossauros',
    'girl_tag': 'Team laços & purpurina',
    'cta_tap': 'Toca para votar',
    'new_answer': 'Nova resposta',
    'name_arrow': 'Nome → escolhe uma opção 👆',
    'dup_name': 'Esse nome já votou. Usa um diferente.',
    'thanks_boy': 'Obrigado! Voto: Rapaz',
    'thanks_girl': 'Obrigado! Voto: Rapariga',
    'dlg_new': 'Nova resposta',
    'name_label': 'Nome',
    'name_empty': 'Escreve o teu nome.',
    'name_toolong': 'Nome demasiado comprido.',
    'continue': 'Continuar',
    'details': 'Detalhe',
    'voted_at': 'Votou em: {stamp}',
  },
};

String t(AppLang lang, String key, {Map<String, String> vars = const {}}) {
  var s = translations[lang]![key] ?? key;
  vars.forEach((k, v) => s = s.replaceAll('{$k}', v));
  return s;
}

/* =====================  APP  ====================== */

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RevealProApp());
}

class RevealProApp extends StatelessWidget {
  const RevealProApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFFFD63A3));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gender Reveal Pro',
      theme: ThemeData(useMaterial3: true, colorScheme: scheme),
      home: const SplitHome(),
    );
  }
}

/* =====================  MODELOS & STORE (local only)  ===================== */

enum Choice { boy, girl }

class VoteEntry {
  final String id;
  final String name;
  final Choice choice;
  final DateTime createdAt;

  VoteEntry({
    required this.id,
    required this.name,
    required this.choice,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'choice': choice.name,
        'createdAt': createdAt.toIso8601String(),
      };

  static VoteEntry fromMap(Map<String, dynamic> m) => VoteEntry(
        id: m['id'] as String,
        name: m['name'] as String,
        choice: (m['choice'] as String) == 'boy' ? Choice.boy : Choice.girl,
        createdAt: DateTime.parse(m['createdAt'] as String),
      );
}

String normalizeName(String raw) =>
    raw.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');

class VoteStore extends ChangeNotifier {
  static const _kKey = 'votes_v1';
  final _uuid = const Uuid();
  final List<VoteEntry> _items = [];

  List<VoteEntry> get items => List.unmodifiable(_items);
  int get boy => _items.where((e) => e.choice == Choice.boy).length;
  int get girl => _items.where((e) => e.choice == Choice.girl).length;
  int get total => _items.length;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_kKey);
    if (s != null && s.isNotEmpty) {
      final list = (json.decode(s) as List).cast<Map<String, dynamic>>();
      _items
        ..clear()
        ..addAll(list.map(VoteEntry.fromMap));
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kKey,
      json.encode(_items.map((e) => e.toMap()).toList()),
    );
  }

  /// 1 voto por nome (case-insensitive, espaços normalizados).
  Future<bool> addUnique({required String name, required Choice choice}) async {
    final norm = normalizeName(name);
    final exists = _items.any((e) => normalizeName(e.name) == norm);
    if (exists) return false;

    _items.add(VoteEntry(
      id: _uuid.v4(),
      name: name.trim(),
      choice: choice,
      createdAt: DateTime.now(),
    ));
    await _persist();
    notifyListeners();
    return true;
  }

  Future<void> resetAll() async {
    _items.clear();
    await _persist();
    notifyListeners();
  }
}

/* =====================  HOME SPLIT — iPad layout ===================== */

class SplitHome extends StatefulWidget {
  const SplitHome({super.key});
  @override
  State<SplitHome> createState() => _SplitHomeState();
}

class _SplitHomeState extends State<SplitHome> {
  final store = VoteStore();
  String? pendingName;
  late ConfettiController confetti;
  Choice? lastLeader;
  String headline = '';
  AppLang currentLang = AppLang.pl;

  @override
  void initState() {
    super.initState();
    store.addListener(_onStore);
    confetti = ConfettiController(duration: const Duration(milliseconds: 900));
    store.load();
    _loadLang();
    WidgetsBinding.instance.addPostFrameCallback((_) => _openNameDialog());
  }

  Future<void> _loadLang() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kLangKey);
    if (saved != null) {
      setState(() => currentLang = AppLang.values
          .firstWhere((l) => l.name == saved, orElse: () => AppLang.pl));
    }
    headline = t(currentLang, 'tie'); // inicial
    setState(() {});
  }

  @override
  void dispose() {
    store.removeListener(_onStore);
    confetti.dispose();
    super.dispose();
  }

  void _onStore() {
    final leader = store.boy == store.girl
        ? null
        : (store.boy > store.girl ? Choice.boy : Choice.girl);
    if (leader != lastLeader && leader != null) {
      lastLeader = leader;
      setState(() {
        headline =
            t(currentLang, leader == Choice.boy ? 'boys_lead' : 'girls_lead');
      });
    } else if (leader == null) {
      setState(() => headline = t(currentLang, 'tie'));
    }
  }

  Future<void> _openNameDialog() async {
    await Future.delayed(const Duration(milliseconds: 30));
    final res = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (_) => NameGlassDialog(lang: currentLang),
    );
    if (res != null && res.trim().isNotEmpty) {
      setState(() => pendingName = res.trim());
    }
  }

  Future<void> _vote(Choice c) async {
    if ((pendingName ?? '').trim().isEmpty) {
      await _openNameDialog();
      if ((pendingName ?? '').trim().isEmpty) return;
    }
    final ok = await store.addUnique(name: pendingName!, choice: c);
    if (!mounted) return;

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(t(currentLang, 'dup_name')),
      ));
      return;
    }

    confetti.play();
    setState(() => pendingName = null);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      content:
          Text(t(currentLang, c == Choice.boy ? 'thanks_boy' : 'thanks_girl')),
    ));
  }

  Future<void> _changeLang(AppLang lang) async {
    setState(() => currentLang = lang);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLangKey, lang.name);
    // refrescar headline com a nova língua:
    _onStore();
  }

  @override
  Widget build(BuildContext context) {
    final total = store.total;
    return AnimatedBuilder(
      animation: store,
      builder: (_, __) {
        return Stack(
          children: [
            const _GradientBackground(),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                title: Text(t(currentLang, 'appTitle')),
                leadingWidth: 64,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _LangButton(
                    current: currentLang,
                    onSelected: _changeLang,
                  ),
                ),
                actions: [
                  IconButton(
                    tooltip: t(currentLang, 'participants'),
                    icon: const Icon(Icons.people_alt_rounded),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ParticipantsPage(
                          store: store,
                          lang: currentLang,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: t(currentLang, 'reset'),
                    icon: const Icon(Icons.cached_rounded),
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(t(currentLang, 'reset_q')),
                          content: Text(t(currentLang, 'reset_body')),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(t(currentLang, 'cancel'))),
                            FilledButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(t(currentLang, 'reset_btn'))),
                          ],
                        ),
                      );
                      if (ok == true) await store.resetAll();
                    },
                  ),
                ],
              ),
              body: Row(
                children: [
                  SizedBox(
                    width: 520,
                    child: _GlassPanel(
                      child: _ResultsPanel(
                        store: store,
                        headline: headline,
                        lang: currentLang,
                      ),
                    ),
                  ),
                  const VerticalDivider(width: 1, thickness: 0),
                  Expanded(
                    child: _GlassPanel(
                      margin: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      child: _VotePanel(
                        lang: currentLang,
                        pendingName: pendingName,
                        onNew: _openNameDialog,
                        onBoy: () => _vote(Choice.boy),
                        onGirl: () => _vote(Choice.girl),
                        total: total,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: confetti,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 28,
                maxBlastForce: 30,
                minBlastForce: 8,
                gravity: 0.25,
                shouldLoop: false,
              ),
            ),
          ],
        );
      },
    );
  }
}

/* =====================  LANG BUTTON (flags)  ===================== */

class _LangButton extends StatelessWidget {
  final AppLang current;
  final ValueChanged<AppLang> onSelected;
  const _LangButton({required this.current, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AppLang>(
      tooltip: 'Language',
      offset: const Offset(0, 40),
      icon: Text(flagOf(current), style: const TextStyle(fontSize: 22)),
      onSelected: onSelected,
      itemBuilder: (ctx) => const [
        PopupMenuItem(value: AppLang.pl, child: Text('🇵🇱 Polski')),
        PopupMenuItem(value: AppLang.en, child: Text('🇬🇧 English')),
        PopupMenuItem(value: AppLang.pt, child: Text('🇵🇹 Português')),
      ],
    );
  }
}

/* =====================  TŁO & PANEL GLASS  ===================== */

class _GradientBackground extends StatelessWidget {
  const _GradientBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF1F8), Color(0xFFEAF5FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      Positioned(
          left: -60,
          top: 80,
          child: _BlurBlob(size: 220, color: const Color(0xFFFFB3D0))),
      Positioned(
          right: -40,
          bottom: 60,
          child: _BlurBlob(size: 180, color: const Color(0xFFAED8FF))),
    ]);
  }
}

class _BlurBlob extends StatelessWidget {
  final double size;
  final Color color;
  const _BlurBlob({required this.size, required this.color});
  @override
  Widget build(BuildContext context) => ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
              color: color.withOpacity(.55), shape: BoxShape.circle),
        ),
      );
}

class _GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsets margin;
  const _GlassPanel(
      {required this.child, this.margin = const EdgeInsets.all(16)});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.58),
              border: Border.all(color: Colors.white.withOpacity(.45)),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(.06),
                    blurRadius: 24,
                    offset: const Offset(0, 8))
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/* =====================  PANEL WYNIKÓW  ===================== */

class _ResultsPanel extends StatelessWidget {
  final VoteStore store;
  final String headline;
  final AppLang lang;
  const _ResultsPanel(
      {required this.store, required this.headline, required this.lang});

  @override
  Widget build(BuildContext context) {
    final boy = store.boy, girl = store.girl, total = boy + girl;
    final boyPct = total == 0 ? 0 : (boy / total * 100).round();
    final girlPct = total == 0 ? 0 : (girl / total * 100).round();

    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          const SizedBox(height: 6),
          SizedBox(
            height: 34,
            child: DefaultTextStyle(
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(fontWeight: FontWeight.w800),
              child: AnimatedTextKit(
                repeatForever: true,
                pause: const Duration(milliseconds: 2500),
                animatedTexts: [
                  FadeAnimatedText(headline),
                  FadeAnimatedText(
                      t(lang, 'total_votes', vars: {'n': '$total'})),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(height: 220, child: _DonutChart(boy: boy, girl: girl)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            children: [
              _legend(Colors.blue.shade600,
                  '${t(lang, 'legend_boy')} ($boy, $boyPct%)'),
              _legend(Colors.pink.shade400,
                  '${t(lang, 'legend_girl')} ($girl, $girlPct%)'),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _BarsChart(boy: boy, girl: girl, lang: lang)),
                const SizedBox(width: 12),
                Expanded(
                    child: _TimelineChart(entries: store.items, lang: lang)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legend(Color c, String t) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(t),
      ]);
}

class _DonutChart extends StatelessWidget {
  final int boy;
  final int girl;
  const _DonutChart({required this.boy, required this.girl});

  @override
  Widget build(BuildContext context) {
    final total = (boy + girl).toDouble();
    return PieChart(
      PieChartData(
        startDegreeOffset: -90,
        sectionsSpace: 3,
        centerSpaceColor: Colors.white.withOpacity(.92),
        centerSpaceRadius: 46,
        sections: [
          PieChartSectionData(
            value: boy.toDouble(),
            color: Colors.blue.shade600,
            title: total == 0 ? '' : '${((boy / total) * 100).round()}%',
            titleStyle: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
            radius: 70,
          ),
          PieChartSectionData(
            value: girl.toDouble(),
            color: Colors.pink.shade400,
            title: total == 0 ? '' : '${((girl / total) * 100).round()}%',
            titleStyle: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
            radius: 70,
          ),
        ],
      ),
    );
  }
}

class _BarsChart extends StatelessWidget {
  final int boy;
  final int girl;
  final AppLang lang;
  const _BarsChart({required this.boy, required this.girl, required this.lang});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white.withOpacity(.6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(t(lang, 'abs_compare'),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceEvenly,
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return Text(t(lang, 'legend_boy'));
                            case 1:
                              return Text(t(lang, 'legend_girl'));
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [
                      BarChartRodData(
                          toY: boy.toDouble(),
                          width: 26,
                          color: Colors.blue.shade600,
                          borderRadius: BorderRadius.circular(6))
                    ]),
                    BarChartGroupData(x: 1, barRods: [
                      BarChartRodData(
                          toY: girl.toDouble(),
                          width: 26,
                          color: Colors.pink.shade400,
                          borderRadius: BorderRadius.circular(6))
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineChart extends StatelessWidget {
  final List<VoteEntry> entries;
  final AppLang lang;
  const _TimelineChart({required this.entries, required this.lang});

  @override
  Widget build(BuildContext context) {
    final buckets = <DateTime, Map<Choice, int>>{};
    for (final e in entries) {
      final key = DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day,
          e.createdAt.hour, e.createdAt.minute);
      buckets.putIfAbsent(key, () => {Choice.boy: 0, Choice.girl: 0});
      buckets[key]![e.choice] = (buckets[key]![e.choice] ?? 0) + 1;
    }
    final keys = buckets.keys.toList()..sort();
    if (keys.isEmpty) {
      return Card(
        elevation: 0,
        color: Colors.white.withOpacity(.6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Center(child: Text(t(lang, 'no_timeline'))),
      );
    }

    final boySpots = <FlSpot>[];
    final girlSpots = <FlSpot>[];
    int cumBoy = 0, cumGirl = 0;
    for (var i = 0; i < keys.length; i++) {
      cumBoy += buckets[keys[i]]![Choice.boy] ?? 0;
      cumGirl += buckets[keys[i]]![Choice.girl] ?? 0;
      boySpots.add(FlSpot(i.toDouble(), cumBoy.toDouble()));
      girlSpots.add(FlSpot(i.toDouble(), cumGirl.toDouble()));
    }
    final totalMax = (cumBoy > cumGirl ? cumBoy : cumGirl).toDouble();
    final showCount = keys.length;
    final maxX = (keys.length - 1).toDouble();

    return Card(
      elevation: 0,
      color: Colors.white.withOpacity(.6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(t(lang, 'timeline'),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: maxX,
                  minY: 0,
                  maxY: (totalMax == 0 ? 1 : totalMax),
                  lineTouchData: LineTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (v, meta) =>
                            Text(v.toInt().toString()),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: (showCount / 4).clamp(1, 999).toDouble(),
                        getTitlesWidget: (value, meta) {
                          final i = value.round();
                          if (i < 0 || i >= keys.length)
                            return const SizedBox.shrink();
                          final dt = keys[i];
                          final hh = dt.hour.toString().padLeft(2, '0');
                          final mm = dt.minute.toString().padLeft(2, '0');
                          return Text('$hh:$mm',
                              style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      barWidth: 3,
                      spots: boySpots,
                      color: Colors.blue.shade600,
                      dotData: FlDotData(show: false),
                    ),
                    LineChartBarData(
                      isCurved: true,
                      barWidth: 3,
                      spots: girlSpots,
                      color: Colors.pink.shade400,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* =====================  PANEL GŁOSOWANIA  ===================== */

class _VotePanel extends StatelessWidget {
  final AppLang lang;
  final String? pendingName;
  final VoidCallback onNew;
  final VoidCallback onBoy;
  final VoidCallback onGirl;
  final int total;
  const _VotePanel({
    required this.lang,
    required this.pendingName,
    required this.onNew,
    required this.onBoy,
    required this.onGirl,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final hasName = (pendingName ?? '').isNotEmpty;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            hasName
                ? t(lang, 'greet_named', vars: {'name': pendingName ?? ''})
                : t(lang, 'ask_name'),
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            t(lang, 'question'),
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            hasName ? t(lang, 'hint_named') : t(lang, 'hint_no_name'),
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _FancyCard(
                    color: Colors.blue.shade600,
                    title: t(lang, 'boy'),
                    tagline: t(lang, 'boy_tag'),
                    onTap: hasName ? onBoy : onNew,
                    isBoy: true,
                  ),
                ),
                const SizedBox(width: 22),
                Expanded(
                  child: _FancyCard(
                    color: Colors.pink.shade400,
                    title: t(lang, 'girl'),
                    tagline: t(lang, 'girl_tag'),
                    onTap: hasName ? onGirl : onNew,
                    isBoy: false,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                textStyle:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onPressed: onNew,
              icon: const Icon(Icons.person_add_alt_1, size: 28),
              label: Text('➕ ${t(lang, 'new_answer')}'),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            t(lang, 'name_arrow'),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _FancyCard extends StatefulWidget {
  final Color color;
  final String title;
  final String tagline;
  final VoidCallback onTap;
  final bool isBoy;
  const _FancyCard({
    required this.color,
    required this.title,
    required this.tagline,
    required this.onTap,
    required this.isBoy,
  });
  @override
  State<_FancyCard> createState() => _FancyCardState();
}

class _FancyCardState extends State<_FancyCard> {
  bool _down = false;
  @override
  Widget build(BuildContext context) {
    final emoji = widget.isBoy ? '👦' : '👧';
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.98 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.color.withOpacity(.12),
                Colors.white.withOpacity(.6)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(.5)),
            boxShadow: [
              BoxShadow(
                  color: widget.color.withOpacity(.2),
                  blurRadius: 24,
                  offset: const Offset(0, 8)),
            ],
          ),
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: widget.color.withOpacity(.95),
                ),
              ),
              const SizedBox(height: 4),
              Text(widget.tagline,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium),
              const Spacer(),
              Text(emoji, style: const TextStyle(fontSize: 90)),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.touch_app,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(
                    // traduzido no contexto de cada língua
                    (translations[AppLang.pl]!['cta_tap'])!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* =====================  DIALOG “GLASS” Z IMIENIEM  ===================== */

class NameGlassDialog extends StatefulWidget {
  final AppLang lang;
  const NameGlassDialog({super.key, required this.lang});
  @override
  State<NameGlassDialog> createState() => _NameGlassDialogState();
}

class _NameGlassDialogState extends State<NameGlassDialog> {
  final _form = GlobalKey<FormState>();
  final _ctrl = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: bottom),
        child: SingleChildScrollView(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Material(
                color: Colors.white.withOpacity(.85),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        t(widget.lang, 'dlg_new'),
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      Form(
                        key: _form,
                        child: TextFormField(
                          controller: _ctrl,
                          focusNode: _focus,
                          autofocus: true,
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: t(widget.lang, 'name_label'),
                            border: const OutlineInputBorder(),
                          ),
                          onFieldSubmitted: (_) => _submit(),
                          validator: (v) {
                            final tval = v?.trim() ?? '';
                            if (tval.isEmpty)
                              return t(widget.lang, 'name_empty');
                            if (tval.length > 40)
                              return t(widget.lang, 'name_toolong');
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(t(widget.lang, 'cancel')),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _submit,
                              icon: const Icon(Icons.check_rounded),
                              label: Text(t(widget.lang, 'continue')),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_form.currentState!.validate()) {
      Navigator.pop(context, _ctrl.text.trim());
    }
  }
}

/* =====================  LISTA & SZCZEGÓŁY  ===================== */

class ParticipantsPage extends StatelessWidget {
  final VoteStore store;
  final AppLang lang;
  const ParticipantsPage({super.key, required this.store, required this.lang});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      const _GradientBackground(),
      Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(t(lang, 'participants')),
          backgroundColor: Colors.transparent,
        ),
        body: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: store.items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final p = store.items.reversed.elementAt(i);
            return _GlassPanel(
              child: ListTile(
                leading: CircleAvatar(
                    child: Text(p.name.isEmpty
                        ? '?'
                        : p.name.characters.first.toUpperCase())),
                title: Text(p.name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(p.choice == Choice.boy
                    ? t(lang, 'legend_boy')
                    : t(lang, 'legend_girl')),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => ParticipantDetail(entry: p, lang: lang)),
                ),
              ),
            );
          },
        ),
      ),
    ]);
  }
}

class ParticipantDetail extends StatelessWidget {
  final VoteEntry entry;
  final AppLang lang;
  const ParticipantDetail({super.key, required this.entry, required this.lang});

  @override
  Widget build(BuildContext context) {
    final chipColor = entry.choice == Choice.boy
        ? Colors.blue.shade600
        : Colors.pink.shade400;
    final dt = entry.createdAt;
    final stamp =
        '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    return Stack(children: [
      const _GradientBackground(),
      Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
            title: Text(t(lang, 'details')),
            backgroundColor: Colors.transparent),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: _GlassPanel(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  CircleAvatar(
                    radius: 70,
                    child: Text(
                      entry.name.isEmpty
                          ? '?'
                          : entry.name.characters.first.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 42, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(entry.name,
                      style: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Chip(
                    avatar: const Text('🎯'),
                    label: Text(entry.choice == Choice.boy
                        ? t(lang, 'legend_boy')
                        : t(lang, 'legend_girl')),
                    backgroundColor: chipColor.withOpacity(.12),
                    side: BorderSide(color: chipColor.withOpacity(.4)),
                    labelStyle: TextStyle(color: chipColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t(lang, 'voted_at', vars: {'stamp': stamp}),
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}
