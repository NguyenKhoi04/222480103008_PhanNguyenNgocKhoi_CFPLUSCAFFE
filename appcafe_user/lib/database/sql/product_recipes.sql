-- 14. Bảng Định mức nguyên vật liệu (Recipe_Ingredients)
-- Kết nối Sản phẩm với Nguyên vật liệu (Để khi bán 1 ly cafe sẽ tự trừ kho)
CREATE TABLE product_recipes (
    id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(id) ON DELETE CASCADE,
    inventory_id INT REFERENCES inventory(id),
    amount_needed DECIMAL,            -- Lượng cần dùng (VD: 0.02kg cafe cho 1 ly)
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);