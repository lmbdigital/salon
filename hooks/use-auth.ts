"use client";

import { useRouter } from "next/navigation";
import { useState } from "react";
import { supabase } from "@/lib/supabase/client";
import { LoginData, RegisterData } from "@/lib/types/auth";
import { toast } from "@/components/ui/use-toast";

export function useAuth() {
  const router = useRouter();
  const [loading, setLoading] = useState(false);

  const login = async ({ email, password }: LoginData) => {
    try {
      setLoading(true);
      const { error } = await supabase.auth.signInWithPassword({
        email,
        password,
      });

      if (error) throw error;

      router.push("/dashboard");
      router.refresh();
    } catch (error: any) {
      toast({
        title: "Error",
        description: error.message,
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  const register = async ({
    email,
    password,
    firstName,
    lastName,
    userType,
    phone,
    businessName,
  }: RegisterData) => {
    try {
      setLoading(true);
      
      // Create auth user
      const { data: authData, error: authError } = await supabase.auth.signUp({
        email,
        password,
      });

      if (authError) throw authError;

      // Create profile
      const { error: profileError } = await supabase.from("profiles").insert({
        id: authData.user?.id,
        first_name: firstName,
        last_name: lastName,
        user_type: userType,
        phone,
      });

      if (profileError) throw profileError;

      // If registering as a salon owner, create salon
      if (userType === "owner" && businessName) {
        const { error: salonError } = await supabase.from("salons").insert({
          owner_id: authData.user?.id,
          business_name: businessName,
        });

        if (salonError) throw salonError;
      }

      router.push("/dashboard");
      router.refresh();
    } catch (error: any) {
      toast({
        title: "Error",
        description: error.message,
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  const logout = async () => {
    try {
      setLoading(true);
      await supabase.auth.signOut();
      router.push("/");
      router.refresh();
    } catch (error: any) {
      toast({
        title: "Error",
        description: error.message,
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  return {
    login,
    register,
    logout,
    loading,
  };
}
