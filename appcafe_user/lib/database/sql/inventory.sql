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