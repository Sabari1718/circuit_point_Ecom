import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/banner_model.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../repositories/mock_product_repository.dart';
import '../repositories/product_repository.dart';

// Repository Provider (allows dependency injection)
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return MockProductRepository();
});

// Categories Provider
final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getCategories();
});

// Banners Provider
final bannersProvider = FutureProvider<List<BannerModel>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getBanners();
});

// All Products Provider
final allProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getAllProducts();
});

// Home Page Sections Providers
final featuredProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getFeaturedProducts();
});

final hotDealsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getHotDeals();
});

final bestSellersProvider = FutureProvider<List<ProductModel>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getBestSellers();
});

final recommendedProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getRecommendedProducts();
});

// Dynamic Product Details Provider (By ID)
final productDetailsProvider = FutureProvider.family<ProductModel?, String>((ref, id) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getProductById(id);
});

// Related Products Provider
class RelatedProductsParams {
  final String productId;
  final String categoryId;

  const RelatedProductsParams({required this.productId, required this.categoryId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RelatedProductsParams &&
          runtimeType == other.runtimeType &&
          productId == other.productId &&
          categoryId == other.categoryId;

  @override
  int get hashCode => productId.hashCode ^ categoryId.hashCode;
}

final relatedProductsProvider =
    FutureProvider.family<List<ProductModel>, RelatedProductsParams>((ref, params) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getRelatedProducts(params.productId, params.categoryId);
});

// Filter & Sort State
enum ProductSortOption {
  newest('Newest First'),
  popularity('Popularity'),
  priceLowToHigh('Price: Low to High'),
  priceHighToLow('Price: High to Low'),
  rating('Customer Rating');

  final String label;
  const ProductSortOption(this.label);
}

class ProductFilterState {
  final String? categoryId;
  final String? brand;
  final double minPrice;
  final double maxPrice;
  final double minRating;
  final String searchQuery;
  final ProductSortOption sortOption;
  final bool inStockOnly;

  const ProductFilterState({
    this.categoryId,
    this.brand,
    this.minPrice = 0,
    this.maxPrice = 50000,
    this.minRating = 0,
    this.searchQuery = '',
    this.sortOption = ProductSortOption.newest,
    this.inStockOnly = false,
  });

  ProductFilterState copyWith({
    String? categoryId,
    bool clearCategory = false,
    String? brand,
    bool clearBrand = false,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? searchQuery,
    ProductSortOption? sortOption,
    bool? inStockOnly,
  }) {
    return ProductFilterState(
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      brand: clearBrand ? null : (brand ?? this.brand),
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: minRating ?? this.minRating,
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
      inStockOnly: inStockOnly ?? this.inStockOnly,
    );
  }

  bool get hasActiveFilters =>
      categoryId != null ||
      brand != null ||
      minPrice > 0 ||
      maxPrice < 50000 ||
      minRating > 0 ||
      inStockOnly;
}

class ProductFilterNotifier extends StateNotifier<ProductFilterState> {
  ProductFilterNotifier() : super(const ProductFilterState());

  void setCategory(String? categoryId) {
    if (categoryId == null || categoryId == 'all') {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(categoryId: categoryId);
    }
  }

  void setBrand(String? brand) {
    if (brand == null || brand == 'all') {
      state = state.copyWith(clearBrand: true);
    } else {
      state = state.copyWith(brand: brand);
    }
  }

  void setPriceRange(double min, double max) {
    state = state.copyWith(minPrice: min, maxPrice: max);
  }

  void setMinRating(double rating) {
    state = state.copyWith(minRating: rating);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSortOption(ProductSortOption sort) {
    state = state.copyWith(sortOption: sort);
  }

  void setInStockOnly(bool value) {
    state = state.copyWith(inStockOnly: value);
  }

  void clearFilters() {
    state = ProductFilterState(
      searchQuery: state.searchQuery,
      sortOption: state.sortOption,
    );
  }

  void resetAll() {
    state = const ProductFilterState();
  }
}

final productFilterProvider =
    StateNotifierProvider<ProductFilterNotifier, ProductFilterState>((ref) {
  return ProductFilterNotifier();
});

// Grid vs List view toggle provider
final isGridViewProvider = StateProvider<bool>((ref) => true);

// Filtered and Sorted Products Provider
final filteredProductsProvider = Provider<AsyncValue<List<ProductModel>>>((ref) {
  final allProductsAsync = ref.watch(allProductsProvider);
  final filter = ref.watch(productFilterProvider);

  return allProductsAsync.whenData((products) {
    var list = products.toList();

    // 1. Search Query
    if (filter.searchQuery.trim().isNotEmpty) {
      final q = filter.searchQuery.toLowerCase().trim();
      list = list.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.brand.toLowerCase().contains(q) ||
            p.model.toLowerCase().contains(q) ||
            p.categoryName.toLowerCase().contains(q) ||
            p.subCategory.toLowerCase().contains(q) ||
            p.tags.any((t) => t.toLowerCase().contains(q));
      }).toList();
    }

    // 2. Category
    if (filter.categoryId != null && filter.categoryId!.isNotEmpty) {
      list = list.where((p) => p.categoryId == filter.categoryId).toList();
    }

    // 3. Brand
    if (filter.brand != null && filter.brand!.isNotEmpty) {
      list = list.where((p) => p.brand.toLowerCase() == filter.brand!.toLowerCase()).toList();
    }

    // 4. Price range
    list = list.where((p) => p.price >= filter.minPrice && p.price <= filter.maxPrice).toList();

    // 5. Min Rating
    if (filter.minRating > 0) {
      list = list.where((p) => p.rating >= filter.minRating).toList();
    }

    // 6. In stock
    if (filter.inStockOnly) {
      list = list.where((p) => p.inStock).toList();
    }

    // 7. Sorting
    switch (filter.sortOption) {
      case ProductSortOption.newest:
        // Keep order or sort by id desc
        list.sort((a, b) => b.id.compareTo(a.id));
        break;
      case ProductSortOption.popularity:
        list.sort((a, b) => b.soldCount.compareTo(a.soldCount));
        break;
      case ProductSortOption.priceLowToHigh:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ProductSortOption.priceHighToLow:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case ProductSortOption.rating:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }

    return list;
  });
});

