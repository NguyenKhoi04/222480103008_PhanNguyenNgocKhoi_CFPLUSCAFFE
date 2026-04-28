-- 2. Bảng Giảm giá
CREATE TABLE discounts (
    id SERIAL PRIMARY KEY,
    discount_percent DECIMAL,
    qr_code TEXT,
    content TEXT,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);