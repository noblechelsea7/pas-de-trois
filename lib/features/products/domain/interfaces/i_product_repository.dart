import '../models/category.dart';
import '../models/product.dart';

abstract class IProductRepository {
  Future<List<Category>> getCategories();
  Future<List<Product>> getProducts({String? categoryId, String? query});
  Future<Product> getProductById(String id);
  Future<Map<String, String>> getSettings();
}
