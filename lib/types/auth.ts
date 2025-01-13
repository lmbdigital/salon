export type UserType = 'owner' | 'staff' | 'customer';

export interface RegisterData {
  email: string;
  password: string;
  firstName: string;
  lastName: string;
  userType: UserType;
  phone?: string;
  businessName?: string;
}

export interface LoginData {
  email: string;
  password: string;
}
