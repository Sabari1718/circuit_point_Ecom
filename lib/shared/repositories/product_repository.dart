import '../models/banner_model.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

abstract class ProductRepository {
  Future<List<ProductModel>> getAllProducts();
  Future<ProductModel?> getProductById(String id);
  Future<List<ProductModel>> getFeaturedProducts();
  Future<List<ProductModel>> getHotDeals();
  Future<List<ProductModel>> getBestSellers();
  Future<List<ProductModel>> getRecommendedProducts();
  Future<List<ProductModel>> getProductsByCategory(String categoryId);
  Future<List<ProductModel>> searchProducts(String query);
  Future<List<CategoryModel>> getCategories();
  Future<List<BannerModel>> getBanners();
  Future<List<ProductModel>> getRelatedProducts(String productId, String categoryId);
}

