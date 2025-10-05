// lib/pages/items_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/supabase_service.dart';
import '../../models/item.dart';

class ItemsPage extends StatefulWidget {
  const ItemsPage({super.key});
  @override
  ItemsPageState createState() => ItemsPageState();
}

class ItemsPageState extends State<ItemsPage> {
  late Future<List<Item>> _fetchFuture;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() {
    final svc = Provider.of<SupabaseService>(context, listen: false);
    _fetchFuture = svc.fetchItems().then((_) => svc.items);
  }

  Future<void> _refresh() async {
    _loadItems();
    await _fetchFuture;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final svc          = Provider.of<SupabaseService>(context, listen: false);
    final currentEmail = Supabase.instance.client.auth.currentUser?.email;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF213a57), Color(0xFF0ad1c8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Text(
                      '🛒 Tindahan ni Angel 🚀',
                      style: GoogleFonts.bebasNeue(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: () async {
                        await svc.signOut();
                        Navigator.of(context)
                            .pushNamedAndRemoveUntil('/signin', (_) => false);
                      },
                    ),
                  ],
                ),
              ),

              // Content grid
              Expanded(
                child: RefreshIndicator(
                  color: Colors.white,
                  onRefresh: _refresh,
                  child: FutureBuilder<List<Item>>(
                    future: _fetchFuture,
                    builder: (context, snap) {
                      if (snap.connectionState != ConnectionState.done) {
                        return const Center(
                          child: CircularProgressIndicator(color: Color(0xFF45dfb1)),
                        );
                      }
                      if (snap.hasError) {
                        return Center(
                          child: Text(
                            'Oops! ${snap.error}',
                            style: GoogleFonts.archivo(color: Colors.redAccent),
                          ),
                        );
                      }
                      final items = snap.data!;
                      if (items.isEmpty) {
                        return Center(
                          child: Text(
                            'No treasures yet 🧐',
                            style: GoogleFonts.archivo(
                              color: Colors.white70,
                              fontSize: 18,
                            ),
                          ),
                        );
                      }
                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, i) {
                          final item    = items[i];
                          final isOwner = item.uploaderEmail == currentEmail;

                          return Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFf5f5f5),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              children: [
                                // Image
                                Expanded(
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Image.network(
                                          item.imageUrl,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      if (isOwner)
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.black38,
                                              shape: BoxShape.circle,
                                            ),
                                            child: IconButton(
                                              icon: const Icon(
                                                  Icons.delete, size: 20),
                                              color: Color(0xFFf5f5f5),
                                              onPressed: () async {
                                                await svc.deleteItem(item.id);
                                                await _refresh();
                                              },
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                // Details section
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.archivo(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF213a57)
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Php ${item.price.toStringAsFixed(2)}',
                                        style: GoogleFonts.archivo(
                                          fontSize: 14,
                                          color: const Color(0xFF0b6477),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'By ${item.uploadedBy}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.archivo(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                            const Color(0xFF14919b),
                                            padding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.pushNamed(
                                              context,
                                              '/detail',
                                              arguments: item.id,
                                            );
                                          },
                                          child: Text(
                                            'Details'.toUpperCase(),
                                            style: GoogleFonts.archivo(
                                                color: Color(0xFFf5f5f5),
                                              fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              // Add New button
              Padding(
                padding: const EdgeInsets.all(16),
                child: FloatingActionButton.extended(
                  backgroundColor: Color(0xFFf5f5f5),
                  foregroundColor: const Color(0xFF14919B),
                  icon: const Icon(Icons.add),
                  label: Text(
                    'Add New',
                    style: GoogleFonts.archivo(fontWeight: FontWeight.w600),
                  ),
                  onPressed: () async {
                    await Navigator.pushNamed(context, '/add');
                    await _refresh();
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
