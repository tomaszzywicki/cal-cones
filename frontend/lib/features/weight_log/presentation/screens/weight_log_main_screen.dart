import 'package:flutter/material.dart';
import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/features/dashboard/presentation/screens/weight_history_chart.dart';
import 'package:frontend/features/weight_log/presentation/widgets/add_weight_entry_bottom_sheet.dart';
import 'package:frontend/features/weight_log/presentation/widgets/weight_entry_list.dart';
import 'package:frontend/features/weight_log/presentation/widgets/current_weight_card.dart';

class WeightLogMainScreen extends StatefulWidget {
  const WeightLogMainScreen({super.key});

  @override
  State<WeightLogMainScreen> createState() => _WeightLogMainScreenState();
}

class _WeightLogMainScreenState extends State<WeightLogMainScreen> {
  // Kontroler do śledzenia pozycji przewinięcia
  final ScrollController _scrollController = ScrollController();

  // Flaga określająca, który przycisk pokazać (true = Dodaj, false = W górę)
  bool _showAddButton = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // Jeśli przewinęliśmy więcej niż 150 pikseli (mniej więcej wysokość wykresu), zmień przycisk
    if (_scrollController.offset > 150 && _showAddButton) {
      setState(() => _showAddButton = false);
    } else if (_scrollController.offset <= 150 && !_showAddButton) {
      setState(() => _showAddButton = true);
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  Future<void> _showAddWeightModal() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
      builder: (context) => const AddWeightEntryBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Tło zgodne z resztą aplikacji
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          controller: _scrollController,
          // Usunęliśmy reverse: true, aby układ był naturalny (góra -> dół)
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              title: const Text('Weight Log'),
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.grey[50],
            ),
            // 1. WYKRES (Na samej górze)
            // Umieszczony w SliverToBoxAdapter, więc przy scrollowaniu "ucieknie" do góry.
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: AspectRatio(
                  aspectRatio: 16 / 10, // Nieco niższy wykres, żeby szybciej znikał
                  child: const WeightHistoryChart(),
                ),
              ),
            ),

            // 2. AKTUALNA WAGA (Przyklejona)
            // Używamy SliverAppBar z pinned: true.
            // Gdy wykres wyjedzie poza ekran, ten element przyklei się do góry.
            SliverAppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.grey[50],
              elevation: 0,
              pinned: true, // Kluczowe dla efektu przyklejania
              toolbarHeight: 200, // Wysokość karty wagi
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: const CurrentWeightCard(),
                ),
              ),
            ),

            // 3. LISTA WPISÓW (Na dole)
            // SliverToBoxAdapter otaczający listę.
            // Lista wewnątrz musi mieć physics: NeverScrollableScrollPhysics,
            // bo scrollowaniem zarządza główny CustomScrollView.
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 80.0), // Padding na dole dla FABa
                child: const WeightEntryList(),
              ),
            ),
          ],
        ),
      ),

      // Przycisk na dole
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddButton ? _showAddWeightModal : _scrollToTop,
        backgroundColor: Colors.black,
        icon: Icon(_showAddButton ? Icons.add : Icons.arrow_upward, color: Colors.white),
        label: Text(
          _showAddButton ? "New Entry" : "Top",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
