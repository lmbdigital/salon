/*
  # Initial Schema Setup for BeautySoft

  1. New Tables
    - `profiles`
      - Extends auth.users with additional user information
      - Stores user type (owner, staff, customer)
    - `salons`
      - Stores salon information
      - Links to profile (owner)
    - `branches`
      - Individual salon branches
      - Links to salon
    - `services`
      - Service catalog
      - Links to salon
    - `staff`
      - Staff profiles and specializations
      - Links to branch and auth.users
    - `bookings`
      - Appointment bookings
      - Links to customer, service, and staff

  2. Security
    - Enable RLS on all tables
    - Policies for owners, staff, and customers
*/

-- Create profiles table
CREATE TABLE profiles (
  id uuid REFERENCES auth.users ON DELETE CASCADE,
  first_name text,
  last_name text,
  user_type text CHECK (user_type IN ('owner', 'staff', 'customer')),
  phone text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  PRIMARY KEY (id)
);

-- Create salons table
CREATE TABLE salons (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  business_name text NOT NULL,
  business_type text DEFAULT 'salon',
  gst_number text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create branches table
CREATE TABLE branches (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  salon_id uuid REFERENCES salons(id) ON DELETE CASCADE,
  name text NOT NULL,
  address text NOT NULL,
  city text NOT NULL,
  state text NOT NULL,
  pincode text NOT NULL,
  phone text,
  email text,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create services table
CREATE TABLE services (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  salon_id uuid REFERENCES salons(id) ON DELETE CASCADE,
  name text NOT NULL,
  description text,
  duration integer NOT NULL, -- in minutes
  price decimal(10,2) NOT NULL,
  category text NOT NULL,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create staff table
CREATE TABLE staff (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  branch_id uuid REFERENCES branches(id) ON DELETE CASCADE,
  specializations text[],
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create bookings table
CREATE TABLE bookings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id uuid REFERENCES profiles(id),
  service_id uuid REFERENCES services(id),
  staff_id uuid REFERENCES staff(id),
  branch_id uuid REFERENCES branches(id),
  booking_date date NOT NULL,
  start_time time NOT NULL,
  end_time time NOT NULL,
  status text CHECK (status IN ('pending', 'confirmed', 'completed', 'cancelled')) DEFAULT 'pending',
  payment_status text CHECK (payment_status IN ('pending', 'paid', 'refunded')) DEFAULT 'pending',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE salons ENABLE ROW LEVEL SECURITY;
ALTER TABLE branches ENABLE ROW LEVEL SECURITY;
ALTER TABLE services ENABLE ROW LEVEL SECURITY;
ALTER TABLE staff ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view their own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

-- Salons policies
CREATE POLICY "Public can view active salons"
  ON salons FOR SELECT
  USING (true);

CREATE POLICY "Owners can manage their salons"
  ON salons FOR ALL
  USING (owner_id = auth.uid());

-- Branches policies
CREATE POLICY "Public can view active branches"
  ON branches FOR SELECT
  USING (is_active = true);

CREATE POLICY "Salon owners can manage branches"
  ON branches FOR ALL
  USING (EXISTS (
    SELECT 1 FROM salons
    WHERE salons.id = branches.salon_id
    AND salons.owner_id = auth.uid()
  ));

-- Services policies
CREATE POLICY "Public can view active services"
  ON services FOR SELECT
  USING (is_active = true);

CREATE POLICY "Salon owners can manage services"
  ON services FOR ALL
  USING (EXISTS (
    SELECT 1 FROM salons
    WHERE salons.id = services.salon_id
    AND salons.owner_id = auth.uid()
  ));

-- Staff policies
CREATE POLICY "Public can view active staff"
  ON staff FOR SELECT
  USING (is_active = true);

CREATE POLICY "Salon owners can manage staff"
  ON staff FOR ALL
  USING (EXISTS (
    SELECT 1 FROM branches
    JOIN salons ON branches.salon_id = salons.id
    WHERE branches.id = staff.branch_id
    AND salons.owner_id = auth.uid()
  ));

-- Bookings policies
CREATE POLICY "Customers can view their own bookings"
  ON bookings FOR SELECT
  USING (auth.uid() = customer_id);

CREATE POLICY "Staff can view their assigned bookings"
  ON bookings FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM staff
    WHERE staff.id = bookings.staff_id
    AND staff.profile_id = auth.uid()
  ));

CREATE POLICY "Salon owners can view all branch bookings"
  ON bookings FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM branches
    JOIN salons ON branches.salon_id = salons.id
    WHERE branches.id = bookings.branch_id
    AND salons.owner_id = auth.uid()
  ));
