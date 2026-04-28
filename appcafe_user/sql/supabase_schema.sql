-- =====================================================
-- CFPLUS CAFE - SUPABASE DATABASE SCHEMA
-- Tạo các bảng với khóa chính và khóa ngoại
-- =====================================================

-- 1. BẢNG USERS (Người dùng - Customer/Staff)
-- Role mặc định là 'customer', bắt buộc
CREATE TABLE public.users (
  id text NOT NULL DEFAULT auth.uid(),
  full_name text,
  email text,
  role text NOT NULL DEFAULT 'customer',
  position text,
  gender text,
  birthday date,
  updated_at timestamp with time zone DEFAULT now(),
  registration_date date DEFAULT CURRENT_DATE,
  avatar_url text,
  phone text,
  CONSTRAINT users_pkey PRIMARY KEY (id),
  CONSTRAINT users_email_key UNIQUE (email),
  CONSTRAINT users_role_check CHECK (
    role = ANY (ARRAY['customer'::text, 'staff'::text])
  )
);

-- Enable Row Level Security
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Policy cho phép đọc thông tin user
CREATE POLICY "Users can view their own profile" ON public.users
  FOR SELECT USING (auth.uid() = id);

-- Policy cho phép cập nhật thông tin cá nhân
CREATE POLICY "Users can update own profile" ON public.users
  FOR UPDATE USING (auth.uid() = id);

-- 2. BẢNG CATEGORIES (Danh mục sản phẩm)
CREATE TABLE public.categories (
  id serial NOT NULL,
  name text NOT NULL,
  description text,
  image_url text,
  is_active boolean DEFAULT true,
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT categories_pkey PRIMARY KEY (id)
);

-- Enable RLS
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read categories" ON public.categories FOR SELECT USING (true);
CREATE POLICY "Staff can manage categories" ON public.categories FOR ALL USING (
  EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'staff')
);

-- 3. BẢNG DISCOUNTS (Khuyến mãi)
CREATE TABLE public.discounts (
  id serial NOT NULL,
  discount_percent numeric NOT NULL,
  qr_code text UNIQUE,
  content text,
  start_date date,
  end_date date,
  is_active boolean DEFAULT true,
  min_order_amount numeric DEFAULT 0,
  max_discount_amount numeric,
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT discounts_pkey PRIMARY KEY (id),
  CONSTRAINT discount_percent_check CHECK (
    discount_percent >= 0 AND discount_percent <= 100
  )
);

-- Enable RLS
ALTER TABLE public.discounts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read active discounts" ON public.discounts 
  FOR SELECT USING (is_active = true);

-- 4. BẢNG REVIEWS (Đánh giá)
CREATE TABLE public.reviews (
  id serial NOT NULL,
  user_id text NOT NULL,
  product_id integer,
  image_url text,
  rating integer NOT NULL,
  customer_comment text,
  manager_reply text,
  customer_reply_at timestamp with time zone,
  manager_reply_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT reviews_pkey PRIMARY KEY (id),
  CONSTRAINT reviews_rating_check CHECK (
    rating >= 1 AND rating <= 5
  ),
  CONSTRAINT reviews_user_id_fkey FOREIGN KEY (user_id) 
    REFERENCES public.users(id) ON DELETE CASCADE
);

-- Enable RLS
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read reviews" ON public.reviews FOR SELECT USING (true);
CREATE POLICY "Users can create reviews" ON public.reviews 
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own reviews" ON public.reviews 
  FOR UPDATE USING (auth.uid() = user_id);

-- 5. BẢNG PRODUCTS (Sản phẩm)
CREATE TABLE public.products (
  id serial NOT NULL,
  name text NOT NULL,
  base_price numeric NOT NULL,
  image_url text,
  category_id integer,
  discount_id integer,
  final_price numeric,
  description text,
  is_available boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT products_pkey PRIMARY KEY (id),
  CONSTRAINT products_category_id_fkey FOREIGN KEY (category_id) 
    REFERENCES public.categories(id) ON DELETE SET NULL,
  CONSTRAINT products_discount_id_fkey FOREIGN KEY (discount_id) 
    REFERENCES public.discounts(id) ON DELETE SET NULL,
  CONSTRAINT products_base_price_check CHECK (base_price >= 0)
);

-- Enable RLS
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read products" ON public.products FOR SELECT USING (is_available = true);

-- 6. BẢNG TABLES (Bàn)
CREATE TABLE public.tables (
  id serial NOT NULL,
  table_name text NOT NULL,
  seats integer DEFAULT 4,
  status text DEFAULT 'available',
  position_x integer,
  position_y integer,
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT tables_pkey PRIMARY KEY (id),
  CONSTRAINT tables_status_check CHECK (
    status = ANY (ARRAY['available'::text, 'occupied'::text, 'reserved'::text])
  )
);

-- Enable RLS
ALTER TABLE public.tables ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read tables" ON public.tables FOR SELECT USING (true);

-- 7. BẢNG ORDERS (Đơn hàng)
CREATE TABLE public.orders (
  id serial NOT NULL,
  user_id text,
  product_id integer NOT NULL,
  discount_id integer,
  table_id integer,
  size text,
  ice_level text,
  sugar_level text,
  quantity integer DEFAULT 1,
  unit_price numeric NOT NULL,
  subtotal numeric NOT NULL,
  discount_amount numeric DEFAULT 0,
  total_amount numeric NOT NULL,
  note text,
  payment_status text DEFAULT 'unpaid',
  order_status text DEFAULT 'pending',
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT orders_pkey PRIMARY KEY (id),
  CONSTRAINT orders_product_id_fkey FOREIGN KEY (product_id) 
    REFERENCES public.products(id) ON DELETE RESTRICT,
  CONSTRAINT orders_discount_id_fkey FOREIGN KEY (discount_id) 
    REFERENCES public.discounts(id) ON DELETE SET NULL,
  CONSTRAINT orders_table_id_fkey FOREIGN KEY (table_id) 
    REFERENCES public.tables(id) ON DELETE SET NULL,
  CONSTRAINT orders_user_id_fkey FOREIGN KEY (user_id) 
    REFERENCES public.users(id) ON DELETE SET NULL,
  CONSTRAINT orders_quantity_check CHECK (quantity > 0),
  CONSTRAINT orders_payment_status_check CHECK (
    payment_status = ANY (ARRAY['unpaid'::text, 'paid'::text, 'refunded'::text])
  ),
  CONSTRAINT orders_order_status_check CHECK (
    order_status = ANY (ARRAY['pending'::text, 'confirmed'::text, 'preparing'::text, 'ready'::text, 'completed'::text, 'cancelled'::text])
  )
);

-- Enable RLS
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can read own orders" ON public.orders 
  FOR SELECT USING (user_id = auth.uid() OR EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'staff'));
CREATE POLICY "Authenticated users can create orders" ON public.orders 
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- 8. BẢNG CHATS (Tin nhắn chat)
CREATE TABLE public.chats (
  id serial NOT NULL,
  admin_id text,
  customer_id text NOT NULL,
  customer_name text,
  last_message text,
  last_message_at timestamp with time zone DEFAULT now(),
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT chats_pkey PRIMARY KEY (id),
  CONSTRAINT chats_customer_id_fkey FOREIGN KEY (customer_id) 
    REFERENCES public.users(id) ON DELETE CASCADE
);

-- Enable RLS
ALTER TABLE public.chats ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can read own chats" ON public.chats 
  FOR SELECT USING (customer_id = auth.uid() OR admin_id = auth.uid() OR EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'staff'));
CREATE POLICY "Users can create chats" ON public.chats 
  FOR INSERT WITH CHECK (auth.uid() = customer_id);

-- 9. BẢNG MESSAGES (Tin nhắn chi tiết trong chat)
CREATE TABLE public.messages (
  id serial NOT NULL,
  chat_id integer NOT NULL,
  sender_id text NOT NULL,
  sender_name text,
  content text NOT NULL,
  is_read boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT messages_pkey PRIMARY KEY (id),
  CONSTRAINT messages_chat_id_fkey FOREIGN KEY (chat_id) 
    REFERENCES public.chats(id) ON DELETE CASCADE,
  CONSTRAINT messages_sender_id_fkey FOREIGN KEY (sender_id) 
    REFERENCES public.users(id) ON DELETE CASCADE
);

-- Enable RLS
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can read messages in own chats" ON public.messages 
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.chats WHERE id = chat_id AND (customer_id = auth.uid() OR admin_id = auth.uid() OR EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'staff')))
  );
CREATE POLICY "Users can send messages" ON public.messages 
  FOR INSERT WITH CHECK (auth.uid() = sender_id);

-- =====================================================
-- INDEXES ĐỂ TĂNG HIỆU SUẤT TRUY VẤN
-- =====================================================
CREATE INDEX idx_products_category ON public.products(category_id);
CREATE INDEX idx_products_discount ON public.products(discount_id);
CREATE INDEX idx_orders_user ON public.orders(user_id);
CREATE INDEX idx_orders_product ON public.orders(product_id);
CREATE INDEX idx_orders_status ON public.orders(order_status);
CREATE INDEX idx_reviews_product ON public.reviews(product_id);
CREATE INDEX idx_reviews_user ON public.reviews(user_id);
CREATE INDEX idx_chats_customer ON public.chats(customer_id);
CREATE INDEX idx_messages_chat ON public.messages(chat_id);
CREATE INDEX idx_messages_created ON public.messages(created_at);

-- =====================================================
-- FUNCTIONS & TRIGGERS
-- =====================================================

-- Function tính final_price tự động khi thêm/sửa sản phẩm
CREATE OR REPLACE FUNCTION calculate_final_price()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.discount_id IS NOT NULL THEN
    SELECT d.discount_percent INTO NEW.final_price
    FROM public.discounts d
    WHERE d.id = NEW.discount_id AND d.is_active = true;
    
    IF NEW.final_price IS NOT NULL THEN
      NEW.final_price = NEW.base_price * (1 - NEW.final_price / 100);
    ELSE
      NEW.final_price = NEW.base_price;
    END IF;
  ELSE
    NEW.final_price = NEW.base_price;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger cho products
CREATE TRIGGER trigger_calculate_final_price
  BEFORE INSERT OR UPDATE ON public.products
  FOR EACH ROW
  EXECUTE FUNCTION calculate_final_price();

-- Function tính total_amount cho orders
CREATE OR REPLACE FUNCTION calculate_order_total()
RETURNS TRIGGER AS $$
DECLARE
  discount_percent numeric := 0;
BEGIN
  -- Lấy phần trăm giảm giá nếu có
  IF NEW.discount_id IS NOT NULL THEN
    SELECT COALESCE(discount_percent, 0) INTO discount_percent
    FROM public.discounts
    WHERE id = NEW.discount_id AND is_active = true;
  END IF;
  
  -- Tính subtotal
  NEW.subtotal := NEW.unit_price * NEW.quantity;
  
  -- Tính discount amount
  NEW.discount_amount := NEW.subtotal * (discount_percent / 100);
  
  -- Tính total
  NEW.total_amount := NEW.subtotal - NEW.discount_amount;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger cho orders
CREATE TRIGGER trigger_calculate_order_total
  BEFORE INSERT OR UPDATE ON public.orders
  FOR EACH ROW
  EXECUTE FUNCTION calculate_order_total();

-- =====================================================
-- SEED DATA (Dữ liệu mẫu)
-- =====================================================

-- Thêm categories mẫu
INSERT INTO public.categories (name, description, image_url) VALUES
  ('Cà phê', 'Các loại cà phê thơm ngon', 'https://example.com/coffee.png'),
  ('Trà', 'Trà trái cây và trà sữa', 'https://example.com/tea.png'),
  ('Đá xay', 'Đá xay mát lạnh', 'https://example.com/frappe.png'),
  ('Bánh ngọt', 'Bánh và snack', 'https://example.com/cake.png');

-- Thêm discounts mẫu
INSERT INTO public.discounts (discount_percent, qr_code, content, is_active) VALUES
  (10, 'WELCOME10', 'Chào mừng khách hàng mới', true),
  (15, 'SUMMER15', 'Khuyến mãa mùa hè', true),
  (20, 'VIP20', 'Khách VIP', true);

-- Thêm tables mẫu
INSERT INTO public.tables (table_name, seats, status) VALUES
  ('Bàn 1', 4, 'available'),
  ('Bàn 2', 4, 'available'),
  ('Bàn 3', 6, 'available'),
  ('Bàn 4', 2, 'available'),
  ('Bàn 5', 8, 'available');

-- Thêm products mẫu
INSERT INTO public.products (name, base_price, category_id, image_url, description) VALUES
  ('Cà phê đen', 25000, 1, 'https://example.com/cfden.png', 'Cà phê đen truyền thống'),
  ('Cà phê sữa đá', 30000, 1, 'https://example.com/cfsua.png', 'Cà phê sữa đá thơm ngon'),
  ('Trà đá', 20000, 2, 'https://example.com/trada.png', 'Trà đá mát lạnh'),
  ('Trà sữa trân châu', 35000, 2, 'https://example.com/trasua.png', 'Trà sữa trân châu'),
  ('Đá xay cà phê', 40000, 3, 'https://example.com/daxay.png', 'Đá xay cà phê');