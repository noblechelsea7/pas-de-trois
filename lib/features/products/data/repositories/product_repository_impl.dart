import '../../domain/interfaces/i_product_repository.dart';
import '../../domain/models/category.dart';
import '../../domain/models/product.dart';
import '../datasources/supabase_product_datasource.dart';

class ProductRepositoryImpl implements IProductRepository {
  const ProductRepositoryImpl(this._datasource);
  final SupabaseProductDatasource _datasource;

  @override
  Future<List<Category>> getCategories() => _datasource.getCategories();

  @override
  Future<List<Product>> getProducts({String? categoryId, String? query}) =>
      _datasource.getProducts(categoryId: categoryId, query: query);

  @override
  Future<Product> getProductById(String id) =>
      _datasource.getProductById(id);

  @override
  Future<Map<String, String>> getSettings() => _datasource.getSettings();
}
