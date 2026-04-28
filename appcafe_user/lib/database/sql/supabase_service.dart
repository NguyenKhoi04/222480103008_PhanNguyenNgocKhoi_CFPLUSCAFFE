import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // ==========================================
  // 1. QUẢN LÝ DANH MỤC & SẢN PHẨM (Categories & Products)
  // ==========================================

  // Lấy danh sách danh mục (Realtime)
  Stream<List<Map<String, dynamic>>> streamCategories() {
    return _client
        .from('categories')
        .stream(primaryKey: ['id'])
        .order('id', ascending: true);
  }

  // Lấy sản phẩm theo danh mục (Lọc theo category_id kiểu int)
  Stream<List<Map<String, dynamic>>> streamProductsByCategory(int categoryId) {
    return _client
        .from('products')
        .stream(primaryKey: ['id'])
        .eq('category_id', categoryId)
        .order('name');
  }

  // Thêm sản phẩm mới
  Future<void> addProduct(Map<String, dynamic> data) async {
    await _client.from('products').insert(data);
  }

  // Thêm vào trong class SupabaseService ở file supabase_service.dart
  // Trong SupabaseService, thêm hàm này:
Future<List<Map<String, dynamic>>> getStaffScheduleOnce() async {
  final response = await _client.from('staff_schedule').select();
  return List<Map<String, dynamic>>.from(response);
}

  // Hàm cập nhật toàn bộ thông tin sản phẩm
  Future<void> updateProduct(int id, Map<String, dynamic> data) async {
    await _client.from('products').update(data).eq('id', id);
  }

  // Hàm xóa sản phẩm
  Future<void> deleteProduct(int id) async {
    await _client.from('products').delete().eq('id', id);
  }

  // ==========================================
  // 2. QUẢN LÝ BÀN & ĐƠN HÀNG (Tables & Orders)
  // ==========================================

  // Lấy danh sách bàn
  Stream<List<Map<String, dynamic>>> streamTables() {
    return _client
        .from('tables')
        .stream(primaryKey: ['id'])
        .order('table_name');
  }

  // Cập nhật trạng thái bàn (available, occupied, reserved)
  Future<void> updateTableStatus(int tableId, String status) async {
    await _client.from('tables').update({'status': status}).eq('id', tableId);
  }

  // Tạo đơn hàng mới
  Future<void> createOrder(Map<String, dynamic> orderData) async {
    await _client.from('orders').insert(orderData);
  }

  // ==========================================
  // 3. QUẢN LÝ KHO (Inventory)
  // ==========================================

  // Theo dõi tồn kho Realtime
  Stream<List<Map<String, dynamic>>> streamInventory() {
    return _client
        .from('inventory')
        .stream(primaryKey: ['id'])
        .order('item_name');
  }

  // Cập nhật số lượng tồn kho (Ví dụ khi nhập hàng)
  Future<void> updateStock(int itemId, double quantity) async {
    await _client
        .from('inventory')
        .update({'quantity_in_stock': quantity})
        .eq('id', itemId);
  }

  // ==========================================
  // 4. NGƯỜI DÙNG & LỊCH TRÌNH (Users & Schedule)
  // ==========================================

  // Lấy thông tin nhân viên/khách hàng
  Future<Map<String, dynamic>?> getUserProfile(String uuid) async {
    return await _client.from('users').select().eq('id', uuid).maybeSingle();
  }

  // Lấy lịch làm việc của nhân viên
  Stream<List<Map<String, dynamic>>> streamStaffSchedule(String userId) {
    return _client
        .from('staff_schedule')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId);
  }

  // ==========================================
  // 5. BÁO CÁO & AI (Revenue & AI Notes)
  // ==========================================

  // Lấy báo cáo doanh thu theo ngày
  Future<List<Map<String, dynamic>>> getRevenueReports() async {
    final response = await _client
        .from('revenue_reports')
        .select()
        .order('report_date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  // ==========================================
  // 6. TƯƠNG TÁC (Chats & Reviews)
  // ==========================================

  // Lấy tin nhắn chat Realtime
  Stream<List<Map<String, dynamic>>> streamChats(String customerId) {
    return _client
        .from('chats')
        .stream(primaryKey: ['id'])
        .eq('customer_id', customerId)
        .order('updated_at', ascending: true);
  }

  // Thêm đánh giá mới
  Future<void> addReview(Map<String, dynamic> reviewData) async {
    await _client.from('reviews').insert(reviewData);
  }

  // ==========================================
  // 7. DANH MỤC (Categories)
  // ==========================================

  Stream<List<Map<String, dynamic>>> streamAllCategories() {
    return _client.from('categories').stream(primaryKey: ['id']).order('name');
  }

  Future<void> addCategory(Map<String, dynamic> data) async {
    await _client.from('categories').insert(data);
  }

  Future<void> updateCategory(int id, Map<String, dynamic> data) async {
    await _client.from('categories').update(data).eq('id', id);
  }

  Future<void> deleteCategory(int id) async {
    await _client.from('categories').delete().eq('id', id);
  }

  // ==========================================
  // 8. KHUYẾN Mại (Discounts)
  // ==========================================

  Stream<List<Map<String, dynamic>>> streamAllDiscounts() {
    return _client
        .from('discounts')
        .stream(primaryKey: ['id'])
        .order('updated_at', ascending: false);
  }

  Future<void> addDiscount(Map<String, dynamic> data) async {
    await _client.from('discounts').insert(data);
  }

  Future<void> updateDiscount(int id, Map<String, dynamic> data) async {
    await _client.from('discounts').update(data).eq('id', id);
  }

  Future<void> deleteDiscount(int id) async {
    await _client.from('discounts').delete().eq('id', id);
  }

  // ==========================================
  // 9. NHÂN VIÊN (Staff/Users)
  // ==========================================

  Stream<List<Map<String, dynamic>>> streamAllStaff() {
    return _client
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('role', 'staff')
        .order('full_name');
  }

  Future<void> addStaff(Map<String, dynamic> data) async {
    await _client.from('users').insert(data);
  }

  Future<void> updateStaff(String id, Map<String, dynamic> data) async {
    await _client.from('users').update(data).eq('id', id);
  }

  Future<void> deleteStaff(String id) async {
    await _client.from('users').delete().eq('id', id);
  }

  // ==========================================
  // 10. KHO HÀNG (Inventory)
  // ==========================================

  Future<void> addInventory(Map<String, dynamic> data) async {
    await _client.from('inventory').insert(data);
  }

  Future<void> updateInventory(int id, Map<String, dynamic> data) async {
    await _client.from('inventory').update(data).eq('id', id);
  }

  Future<void> deleteInventory(int id) async {
    await _client.from('inventory').delete().eq('id', id);
  }

  // ==========================================
  // 11. CÔNG THỨC (Product Recipes)
  // ==========================================

  Stream<List<Map<String, dynamic>>> streamAllProductRecipes() {
    return _client
        .from('product_recipes')
        .stream(primaryKey: ['id'])
        .order('recipe_name');
  }

  Future<void> addProductRecipe(Map<String, dynamic> data) async {
    await _client.from('product_recipes').insert(data);
  }

  Future<void> updateProductRecipe(int id, Map<String, dynamic> data) async {
    await _client.from('product_recipes').update(data).eq('id', id);
  }

  Future<void> deleteProductRecipe(int id) async {
    await _client.from('product_recipes').delete().eq('id', id);
  }

  // ==========================================
  // 12. ĐÁNH GIÁ (Ratings/Reviews)
  // ==========================================

  Stream<List<Map<String, dynamic>>> streamAllreviews() {
    return _client
        .from('reviews')
        .stream(primaryKey: ['id'])
        .order('updated_at', ascending: false);
  }

  Future<void> addRating(Map<String, dynamic> data) async {
    await _client.from('reviews').insert(data);
  }

  Future<void> updateRating(int id, Map<String, dynamic> data) async {
    await _client.from('reviews').update(data).eq('id', id);
  }

  Future<void> deleteRating(int id) async {
    await _client.from('reviews').delete().eq('id', id);
  }

  // ==========================================
  // 13. BÁO CÁO DOANH THU (Revenue Reports)
  // ==========================================

  Stream<List<Map<String, dynamic>>> streamRevenueReports() {
    return _client
        .from('revenue_reports')
        .stream(primaryKey: ['id'])
        .order('report_date', ascending: false);
  }

  Future<void> addRevenueReport(Map<String, dynamic> data) async {
    await _client.from('revenue_reports').insert(data);
  }

  Future<void> updateRevenueReport(int id, Map<String, dynamic> data) async {
    await _client.from('revenue_reports').update(data).eq('id', id);
  }

  Future<void> deleteRevenueReport(int id) async {
    await _client.from('revenue_reports').delete().eq('id', id);
  }

  // ==========================================
  // 14. ĐƠN HÀNG (Orders)
  // ==========================================

  Stream<List<Map<String, dynamic>>> streamAllOrders() {
    return _client
        .from('orders')
        .stream(primaryKey: ['id'])
        .order('updated_at', ascending: false);
  }

  Future<void> updateOrder(int id, Map<String, dynamic> data) async {
    await _client.from('orders').update(data).eq('id', id);
  }

  Future<void> deleteOrder(int id) async {
    await _client.from('orders').delete().eq('id', id);
  }

  // 1. Hàm lấy danh sách nhân viên (để hiện tên thay vì ID)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final response = await _client.from('users').select();
    return List<Map<String, dynamic>>.from(response);
  }

  // 2. Hàm lấy luồng dữ liệu lịch làm việc (Stream) để cập nhật tự động
  Stream<List<Map<String, dynamic>>> streamAllStaffSchedule() {
    return _client
        .from('staff_schedule')
        .stream(primaryKey: ['id'])
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  // Nếu bạn muốn dùng tên 'getAllData' cho tổng quát:
  Future<List<Map<String, dynamic>>> getAllData(String table) async {
    final response = await _client.from(table).select();
    return List<Map<String, dynamic>>.from(response);
  }
}

Stream<List<Map<String, dynamic>>> streamStaffSchedule() {
  // Đảm bảo chữ 'staff_schedule' viết đúng, không dư khoảng trắng
  return Supabase.instance.client
      .from('staff_schedule') 
      .stream(primaryKey: ['id'])
      .map((data) => List<Map<String, dynamic>>.from(data));
}
