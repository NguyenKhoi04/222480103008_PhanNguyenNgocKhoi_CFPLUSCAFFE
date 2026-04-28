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