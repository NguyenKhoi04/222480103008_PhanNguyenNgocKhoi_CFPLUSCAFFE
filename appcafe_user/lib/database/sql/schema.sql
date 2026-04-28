-- Schema for QuanLy-CFPLUS Database

-- 1. Bảng Phân loại sản phẩm
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Bảng Giảm giá
CREATE TABLE discounts (
    id SERIAL PRIMARY KEY,
    discount_percent DECIMAL,
    qr_code TEXT,
    content TEXT,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Bảng Người dùng (Users)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT auth.uid(),
    full_name TEXT,
    email TEXT UNIQUE,
    role TEXT CHECK (role IN ('customer', 'staff')),
    position TEXT, -- Quản lý, Phục vụ, Pha chế, Vệ sinh...
    gender TEXT,
    birthday DATE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Bảng Đánh giá
CREATE TABLE reviews (
    id SERIAL PRIMARY KEY,
    image_url TEXT,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    customer_comment TEXT,
    manager_reply TEXT,
    customer_reply_at TIMESTAMP WITH TIME ZONE,
    manager_reply_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Bảng Sản phẩm
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    base_price DECIMAL NOT NULL,
    image_url TEXT,
    category_id INT REFERENCES categories(id),
    discount_id INT REFERENCES discounts(id),
    final_price DECIMAL,
    review_id INT REFERENCES reviews(id),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. Bảng Quản lý bàn
CREATE TABLE tables (
    id SERIAL PRIMARY KEY,
    table_name TEXT,
    seats INT, -- 2, 4, sofa
    status TEXT DEFAULT 'available', -- trống, có khách, đã đặt
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. Bảng Đơn hàng
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(id),
    discount_id INT REFERENCES discounts(id),
    table_id INT REFERENCES tables(id),
    size TEXT, -- M, L, XL
    ice_level TEXT, -- Bỏ đá, ít đá, nóng...
    quantity INT DEFAULT 1,
    subtotal DECIMAL,
    total_amount DECIMAL,
    note TEXT,
    payment_status TEXT DEFAULT 'unpaid',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. Bảng Lịch nhân viên
CREATE TABLE staff_schedule (
    id SERIAL PRIMARY KEY,
    shift_name TEXT,
    shift_details TEXT,
    work_time TEXT,
    user_id UUID REFERENCES users(id),
    registration_date DATE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9. Bảng Tin tức
CREATE TABLE news (
    id SERIAL PRIMARY KEY,
    title TEXT,
    summary TEXT,
    content TEXT,
    product_id INT REFERENCES products(id),
    discount_id INT REFERENCES discounts(id),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 10. Bảng Chat
CREATE TABLE chats (
    id SERIAL PRIMARY KEY,
    admin_id UUID REFERENCES users(id),
    customer_id UUID REFERENCES users(id),
    customer_name TEXT,
last_message TEXT,
    sender_id UUID,
    content TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 11. Bảng AI Gợi ý Nhân viên (Công thức & Hỗ trợ)
CREATE TABLE ai_staff_suggestions (
    id SERIAL PRIMARY KEY,
    question TEXT,
    ai_response TEXT,
    recipe_details TEXT, -- Công thức pha chế
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 13. Bảng Kho nguyên vật liệu (Inventory)
-- Dùng để quản lý: Cafe hạt, sữa tươi, đường, ly nhựa, ống hút...
CREATE TABLE inventory (
    id SERIAL PRIMARY KEY,
    item_name TEXT NOT NULL,           -- Tên nguyên liệu (VD: Cafe Arabica)
    unit TEXT,                        -- Đơn vị tính (Kg, Lít, Túi, Cái)
    quantity_in_stock DECIMAL DEFAULT 0, -- Số lượng tồn kho hiện tại
    min_stock_level DECIMAL DEFAULT 5,  -- Ngưỡng báo động (Dưới mức này AI sẽ nhắc nhập hàng)
    cost_per_unit DECIMAL,            -- Giá vốn nhập vào trên 1 đơn vị
    supplier_info TEXT,               -- Thông tin nhà cung cấp
    last_reorder_date TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 14. Bảng Định mức nguyên vật liệu (Recipe_Ingredients)
-- Kết nối Sản phẩm với Nguyên vật liệu (Để khi bán 1 ly cafe sẽ tự trừ kho)
CREATE TABLE product_recipes (
    id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(id) ON DELETE CASCADE,
    inventory_id INT REFERENCES inventory(id),
    amount_needed DECIMAL,            -- Lượng cần dùng (VD: 0.02kg cafe cho 1 ly)
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 15. Bảng Doanh thu (Revenue_Reports)
-- Lưu trữ dữ liệu tổng hợp theo ngày để AI phân tích xu hướng
CREATE TABLE revenue_reports (
    id SERIAL PRIMARY KEY,
    report_date DATE UNIQUE DEFAULT CURRENT_DATE,
    total_orders INT DEFAULT 0,       -- Tổng số đơn hàng trong ngày
    gross_revenue DECIMAL DEFAULT 0,  -- Tổng doanh thu (chưa trừ vốn)
    total_cost DECIMAL DEFAULT 0,     -- Tổng tiền vốn nguyên liệu
    net_profit DECIMAL DEFAULT 0,     -- Lợi nhuận ròng (Doanh thu - Vốn)
    best_selling_product_id INT REFERENCES products(id), -- Sản phẩm bán chạy nhất ngày
    ai_prediction_note TEXT,          -- Ghi chú dự báo từ AI cho ngày tiếp theo
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);