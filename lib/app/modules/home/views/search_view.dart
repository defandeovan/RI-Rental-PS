import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SearchView extends StatefulWidget {
  const SearchView({Key? key}) : super(key: key);

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<ProductData> _searchResults = [];
  bool _isSearching = false;

  // Data produk lengkap untuk pencarian
  final List<ProductData> _allProducts = [
    ProductData(
      name: 'PS5 Digital Edition',
      price: 'Rp 50K/hari',
      image: 'assets/images/ps5_digital.png',
      category: 'PS 5',
      description: 'PlayStation 5 Digital Edition - Gaming console terbaru',
    ),
    ProductData(
      name: 'Playstation 4',
      price: 'Rp 45K/hari',
      image: 'assets/images/ps4_console.png',
      category: 'PS 4',
      description: 'PlayStation 4 Standard - Console gaming populer',
    ),
    ProductData(
      name: 'PS4 Slim',
      price: 'Rp 40K/hari',
      image: 'assets/images/ps4_slim.png',
      category: 'PS 4',
      description: 'PlayStation 4 Slim - Versi lebih ringkas',
    ),
    ProductData(
      name: 'PS4 Pro',
      price: 'Rp 50K/hari',
      image: 'assets/images/ps4_pro.png',
      category: 'PS 4',
      description: 'PlayStation 4 Pro - Enhanced performance',
    ),
    ProductData(
      name: 'PS5 Standard',
      price: 'Rp 55K/hari',
      image: 'assets/images/ps5_digital.png',
      category: 'PS 5',
      description: 'PlayStation 5 Standard Edition dengan disc drive',
    ),
    ProductData(
      name: 'PS3 Slim',
      price: 'Rp 30K/hari',
      image: 'assets/images/ps3.png',
      category: 'PS 3',
      description: 'PlayStation 3 Slim - Classic gaming',
    ),
    ProductData(
      name: 'PS3 Super Slim',
      price: 'Rp 25K/hari',
      image: 'assets/images/ps3.png',
      category: 'PS 3',
      description: 'PlayStation 3 Super Slim - Compact version',
    ),
    ProductData(
      name: 'PS2 Slim',
      price: 'Rp 20K/hari',
      image: 'assets/images/ps2.png',
      category: 'PS 2',
      description: 'PlayStation 2 Slim - Retro gaming',
    ),
  ];

  final List<String> _recentSearches = [
    'PS5',
    'PS4 Pro',
    'PS3',
  ];

  @override
  void initState() {
    super.initState();
    _searchFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults = _allProducts.where((product) {
        final productName = product.name.toLowerCase();
        final productCategory = product.category.toLowerCase();
        final productDescription = product.description.toLowerCase();
        final searchQuery = query.toLowerCase();

        return productName.contains(searchQuery) ||
            productCategory.contains(searchQuery) ||
            productDescription.contains(searchQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(),
            Expanded(
              child: _isSearching
                  ? _buildSearchResults()
                  : _buildRecentSearches(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            color: AppColors.textPrimary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: _performSearch,
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 15,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[400],
                    size: 22,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      _performSearch('');
                    },
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () {
              // Filter action
            },
            icon: const Icon(Icons.tune),
            color: AppColors.textPrimary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Text(
              'Recent Searches',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentSearches.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(
                  Icons.history,
                  color: AppColors.textSecondary,
                  size: 22,
                ),
                title: Text(
                  _recentSearches[index],
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                trailing: const Icon(
                  Icons.north_west,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
                onTap: () {
                  _searchController.text = _recentSearches[index];
                  _performSearch(_recentSearches[index]);
                },
              );
            },
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Text(
              'Popular Categories',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _buildPopularCategories(),
        ],
      ),
    );
  }

  Widget _buildPopularCategories() {
    final categories = ['PS 5', 'PS 4', 'PS 3', 'PS 2'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: categories.map((category) {
          return InkWell(
            onTap: () {
              _searchController.text = category;
              _performSearch(category);
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: Text(
                category,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return _buildSearchResultItem(_searchResults[index]);
      },
    );
  }

  Widget _buildSearchResultItem(ProductData product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Navigate to product detail
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Product Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      product.image,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.videogame_asset_rounded,
                            size: 40,
                            color: Colors.grey[300],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.category,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.price,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow Icon
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Data Model
class ProductData {
  final String name;
  final String price;
  final String image;
  final String category;
  final String description;

  ProductData({
    required this.name,
    required this.price,
    required this.image,
    required this.category,
    required this.description,
  });
}
