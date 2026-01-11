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
    // Logika zmiany przycisku
    final threshold = _expandedHeight - _collapsedHeight;
    if (_scrollController.offset > threshold && _showAddButton) {
      setState(() => _showAddButton = false);
    } else if (_scrollController.offset <= threshold && !_showAddButton) {
      setState(() => _showAddButton = true);
    }
  }

  // Funkcja "Magnetycznego" dociągania
  void _handleScrollEnd(ScrollNotification notification) {
    if (notification is UserScrollNotification && notification.direction == ScrollDirection.idle) {
      final currentOffset = _scrollController.offset;

      final double appBarOffset = kToolbarHeight;
      final snapPoint = (_expandedHeight - _collapsedHeight) + appBarOffset;
      final snapThreshold = 20.0; // Próg czułości

      // Jeśli jesteśmy w "strefie pomiędzy" (nagłówek częściowo zwinięty)
      if (currentOffset > 0 && currentOffset < snapPoint) {
        final double targetOffset;
        if (currentOffset > snapThreshold) {
          // Bliżej do zwinięcia -> zwiń
          targetOffset = snapPoint;
        } else {
          // Bliżej do góry -> rozwiń
          targetOffset = 0.0;
        }

        _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
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
      // NotificationListener pozwala nam wykryć moment puszczenia palca (do efektu magnetycznego)
      body: SafeArea(
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            _handleScrollEnd(notification);
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
                pinned: true, // To sprawia, że waga zostaje na górze ("przykleja się")
                delegate: WeightLogHeaderDelegate(
                  expandedHeight: _expandedHeight,
                  collapsedHeight: _collapsedHeight,
                ),
              ),

              // 2. LISTA WPISÓW
              SliverToBoxAdapter(
                child: Padding(padding: const EdgeInsets.only(bottom: 500.0), child: const WeightEntryList()),
              ),
            ],
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
