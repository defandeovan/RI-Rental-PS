import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../models/RentalDuration.dart';
import '../models/product_model.dart';
import '../services/supabase_service.dart';
import 'BookingView.dart';

class CatalogDetailView extends StatefulWidget {
  final String productId;

  const CatalogDetailView({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  State<CatalogDetailView> createState() => _CatalogDetailViewState();
}

class _CatalogDetailViewState extends State<CatalogDetailView> {
  late Product product;
  bool isFavorite = false;
  int _selectedDuration = 0;
  final _supabaseService = SupabaseService.instance;

  final List<RentalDuration> _durations = [
    RentalDuration(days: 1, label: '1 Hari', price: 0), // Base price
    RentalDuration(days: 3, label: '3 Hari', price: 0), // Will be calculated
    RentalDuration(days: 7, label: '1 Minggu', price: 0), // Will be calculated
  ];
  
  // Example data for available games (could be fetched or part of product model later)
  final List<GameItem> _games = [
    GameItem(name: 'Spider-man 2', isAvailable: true, image: 'assets/images/spiderman_cover.png'),
    GameItem(name: 'FIFA 24', isAvailable: true, image: 'assets/images/fifa_cover.png'),
    GameItem(name: 'God of War Ragnarok', isAvailable: true, image: 'assets/images/gow_cover.png'),
    GameItem(name: 'The Last of Us Part II', isAvailable: false, image: 'assets/images/disc.png'),
  ];


  @override
  void initState() {
    super.initState();
    _loadProduct();
    _checkFavoriteStatus();
  }

  void _loadProduct() {
      // Find product by ID
      product = Product.allProducts.firstWhere(
        (p) => p.id == widget.productId,
        orElse: () => Product.allProducts[0], // Fallback
      );

      // Update durations based on product price
      _durations[0] = RentalDuration(days: 1, label: '1 Hari', price: product.price);
      _durations[1] = RentalDuration(days: 3, label: '3 Hari', price: product.price * 3); // Simple logic
      _durations[2] = RentalDuration(days: 7, label: '1 Minggu', price: product.price * 7); // Simple logic
  }

  Future<void> _checkFavoriteStatus() async {
      final userId = _supabaseService.userId;
      if (userId != null) {
          final isFav = await _supabaseService.isFavorite(userId, widget.productId);
          if (mounted) {
              setState(() {
                  isFavorite = isFav;
              });
          }
      }
  }

  Future<void> _toggleFavorite() async {
      final userId = _supabaseService.userId;
      if (userId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Silakan login untuk menambahkan favorit')),
          );
          return;
      }

      final newStatus = await _supabaseService.toggleFavorite(userId, widget.productId);
      if (mounted) {
          setState(() {
              isFavorite = newStatus;
          });
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(newStatus ? 'Ditambahkan ke favorit' : 'Dihapus dari favorit'),
                  duration: const Duration(seconds: 1),
              ),
          );
      }
  }

  String _formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      _buildProductInfo(),
                      const SizedBox(height: 32),
                      _buildRentalDuration(),
                      const SizedBox(height: 32),
                      _buildSpecifications(),
                      if (product.category.contains('PS')) ...[
                        const SizedBox(height: 32),
                        _buildAvailableGames(),
                      ],
                      const SizedBox(height: 32),
                      _buildPriceBreakdown(),
                      const SizedBox(height: 160), // Increased bottom padding to prevent overlap
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  )
                ]
              ),
              child: const Icon(
                Icons.arrow_back_rounded, 
                color: AppColors.textPrimary,
                size: 22,
              ),
            ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF3E5F5), // Light purple background
                    Colors.white,
                  ],
                ),
              ),
            ),
            Center(
              child: Hero(
                tag: product.image, // Use product image as tag
                child: Image.asset(
                  product.image,
                  height: 280,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                     return const Icon(
                        Icons.videogame_asset_rounded,
                        size: 100,
                        color: Colors.grey,
                     );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: _toggleFavorite,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    )
                  ]
              ),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border_rounded,
                size: 20,
                color: isFavorite ? Colors.red : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                product.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: product.isAvailable ? AppColors.success : Colors.red,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (product.isAvailable ? AppColors.success : Colors.red).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                product.isAvailable ? 'Tersedia' : 'Disewa',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            Text(
              product.rating.toString(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(${product.reviews} Reviews)',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          product.description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildRentalDuration() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Durasi Sewa',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120, // Height for the horizontal list
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _durations.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final duration = _durations[index];
              final isSelected = _selectedDuration == index;
              
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedDuration = index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 110,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : Colors.grey[200]!,
                      width: 1,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                      else
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        duration.label,
                         textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatCurrency(duration.price),
                         textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white.withOpacity(0.8) : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                       Text(
                        '/total',
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected ? Colors.white.withOpacity(0.6) : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSpecifications() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Spesifikasi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: product.specs.map((spec) {
              final isLast = spec == product.specs.last;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        spec,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableGames() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             const Text(
              'Game Termasuk',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
             Text(
                'Lihat Semua',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
             ),
           ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _games.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final game = _games[index];
              return Container(
                width: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: game.image == 'assets/images/disc.png' 
                            ? Container(
                                color: Colors.grey[100],
                                child: Icon(Icons.disc_full_rounded, size: 40, color: Colors.grey[400])
                              )
                            : Image.asset(
                                game.image, 
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Container(
                                  color: Colors.grey[100],
                                  child: Icon(Icons.broken_image_rounded, color: Colors.grey[400])
                                ),
                              ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        game.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildPriceBreakdown() {
     final selectedPrice = _durations[_selectedDuration].price;
     final tax = (selectedPrice * 0.1).toInt();
     final total = selectedPrice + tax;
     
     return Container(
       padding: const EdgeInsets.all(20),
       decoration: BoxDecoration(
         color: AppColors.primary.withOpacity(0.05),
         borderRadius: BorderRadius.circular(24),
         border: Border.all(color: AppColors.primary.withOpacity(0.1)),
       ),
       child: Column(
         children: [
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Text('Harga Sewa', style: TextStyle(color: Colors.grey[600])),
               Text(_formatCurrency(selectedPrice), style: const TextStyle(fontWeight: FontWeight.w600)),
             ],
           ),
           const SizedBox(height: 10),
            Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Text('Layanan & Pajak', style: TextStyle(color: Colors.grey[600])),
               Text(_formatCurrency(tax), style: const TextStyle(fontWeight: FontWeight.w600)),
             ],
           ),
           const Padding(
             padding: EdgeInsets.symmetric(vertical: 16),
             child: Divider(),
           ),
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               const Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
               Text(_formatCurrency(total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
             ],
           ),
         ],
       ),
     );
  }

  Widget _buildBottomButton() {
     if (!product.isAvailable) {
         return Container(
             padding: const EdgeInsets.all(24),
             decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                 boxShadow: [
                     BoxShadow(
                         color: Colors.black.withOpacity(0.05),
                         blurRadius: 20,
                         offset: const Offset(0, -5),
                     ),
                 ],
             ),
             child: SafeArea(
                 child: ElevatedButton(
                     onPressed: null,
                     style: ElevatedButton.styleFrom(
                         backgroundColor: Colors.grey,
                         foregroundColor: Colors.white,
                         padding: const EdgeInsets.symmetric(vertical: 16),
                         shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(16),
                         ),
                     ),
                     child: const Text('Sedang Disewa'),
                 ),
             ),
         );
     }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
             Expanded(
               child: Column(
                 mainAxisSize: MainAxisSize.min,
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(
                     'Total',
                     style: TextStyle(
                       fontSize: 12,
                       color: Colors.grey[600],
                     ),
                   ),
                   const SizedBox(height: 4),
                   Text(
                     _formatCurrency(_durations[_selectedDuration].price),
                     style: const TextStyle(
                       fontSize: 20,
                       fontWeight: FontWeight.bold,
                       color: AppColors.primary,
                     ),
                   ),
                 ],
               ),
             ),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                   Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingView(
                          productName: product.name,
                          productImage: product.image,
                          rentalDuration: _durations[_selectedDuration],
                        ),
                      ),
                    );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: const Text(
                  'Sewa Sekarang',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GameItem {
  final String name;
  final bool isAvailable;
  final String image;

  GameItem({
    required this.name,
    required this.isAvailable,
    required this.image,
  });
}