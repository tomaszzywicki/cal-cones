import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:frontend/features/weight_log/presentation/widgets/add_weight_entry_bottom_sheet.dart';
import 'package:frontend/features/weight_log/presentation/widgets/weight_entry_list.dart';
import 'package:frontend/features/weight_log/presentation/screens/weight_log_header_delegate.dart';

class WeightLogMainScreen extends StatefulWidget {
  const WeightLogMainScreen({super.key});

  @override
  State<WeightLogMainScreen> createState() => _WeightLogMainScreenState();
}

class _WeightLogMainScreenState extends State<WeightLogMainScreen> {
  late ScrollController _scrollController;
  bool _showAddButton = true;

  // Zmienna do śledzenia ostatniego ruchu (kierunku i prędkości)
  double _lastScrollDelta = 0.0;

  // Konfiguracja wysokości
  final double _expandedHeight = 450.0; // Waga + Wykres
  final double _collapsedHeight = 180.0; // Tylko ściśnięta Waga

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // Logika zmiany przycisku (zależna od pozycji scrolla)
    if (!_scrollController.hasClients) return;

    final threshold = _expandedHeight - _collapsedHeight;
    if (_scrollController.offset > threshold && _showAddButton) {
      setState(() => _showAddButton = false);
    } else if (_scrollController.offset <= threshold && !_showAddButton) {
      setState(() => _showAddButton = true);
    }
  }

  // LOGIKA MAGNETYCZNA (Wywoływana przy puszczeniu palca)
  void _onPointerUp(PointerUpEvent event) {
    if (!_scrollController.hasClients) return;

    final currentOffset = _scrollController.offset;
    // Punkt, w którym nagłówek jest całkowicie zwinięty

    final double appBarHeight = kToolbarHeight;
    final snapThreshold = (_expandedHeight - _collapsedHeight) + appBarHeight;

    // Działamy tylko wtedy, gdy jesteśmy w strefie nagłówka (pomiędzy 0 a zwinięciem)
    if (currentOffset > 0 && currentOffset < snapThreshold) {
      double? targetOffset;

      // Czułość gestu (jak szybki musi być ruch, by uznać go za "rzut")
      const double velocityThreshold = 1.0;

      if (_lastScrollDelta > velocityThreshold) {
        // 1. Szybki ruch w DÓŁ (zwijanie) -> Zwiń do końca
        targetOffset = snapThreshold;
      } else if (_lastScrollDelta < -velocityThreshold) {
        // 2. Szybki ruch w GÓRĘ (rozwijanie) -> Rozwiń do zera
        targetOffset = 0.0;
      } else {
        // 3. Ruch powolny/zatrzymany -> Decyduje pozycja (bliżej której krawędzi?)
        if (currentOffset > snapThreshold / 2) {
          targetOffset = snapThreshold; // Bliżej zwinięcia
        } else {
          targetOffset = 0.0; // Bliżej rozwinięcia
        }
      }

      // Wykonaj animację (to przerywa naturalne momentum scrolla)
      if (targetOffset != null) {
        _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic, // Płynne hamowanie
        );
      }
    }
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 600), curve: Curves.easeOut);
    }
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
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        // LISTENER: Wykrywa surowe zdarzenia dotyku (w tym podniesienie palca)
        child: Listener(
          onPointerUp: _onPointerUp,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              // Śledzimy kierunek ruchu (delta > 0 to ruch w dół listy/zwijanie)
              if (notification is ScrollUpdateNotification) {
                _lastScrollDelta = notification.scrollDelta ?? 0.0;
              }
              return false;
            },
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.grey[50],
                  title: const Text(
                    "Weight Log",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
                // 1. NAGŁÓWEK (Waga + Wykres)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: WeightLogHeaderDelegate(
                    expandedHeight: _expandedHeight,
                    collapsedHeight: _collapsedHeight,
                  ),
                ),

                // 2. LISTA WPISÓW
                SliverToBoxAdapter(
                  // Zachowałem Twoje 500 paddingu, jeśli potrzebujesz tego do testów,
                  // ale docelowo pewnie wystarczy ok. 100 na FABa.
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 500.0),
                    child: const WeightEntryList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddButton ? _showAddWeightModal : _scrollToTop,
        backgroundColor: Colors.black,
        icon: Icon(_showAddButton ? Icons.add : Icons.arrow_upward, color: Colors.white),
        label: Text(
          _showAddButton ? "Add Weight" : "Top",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
