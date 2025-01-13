import { Button } from "@/components/ui/button";
import { Scissors } from "lucide-react";
import Link from "next/link";

export default function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-b from-background to-muted">
      <header className="container mx-auto px-4 py-6">
        <nav className="flex items-center justify-between">
          <div className="flex items-center space-x-2">
            <Scissors className="h-6 w-6" />
            <span className="text-xl font-bold">BeautySoft</span>
          </div>
          <div className="flex items-center space-x-4">
            <Button variant="ghost" asChild>
              <Link href="/login">Login</Link>
            </Button>
            <Button asChild>
              <Link href="/register">Get Started</Link>
            </Button>
          </div>
        </nav>
      </header>

      <main className="container mx-auto px-4 py-16">
        <div className="flex flex-col items-center text-center space-y-8">
          <h1 className="text-4xl sm:text-6xl font-bold tracking-tight">
            Transform Your Salon Business
            <br />
            <span className="text-primary">With Digital Excellence</span>
          </h1>
          <p className="text-xl text-muted-foreground max-w-2xl">
            Streamline operations, boost customer engagement, and grow your beauty business
            with our all-in-one salon management platform.
          </p>
          <div className="flex flex-col sm:flex-row gap-4">
            <Button size="lg" asChild>
              <Link href="/register">Start Free Trial</Link>
            </Button>
            <Button size="lg" variant="outline" asChild>
              <Link href="/demo">Request Demo</Link>
            </Button>
          </div>
        </div>

        <div className="mt-24 grid grid-cols-1 md:grid-cols-3 gap-8">
          {features.map((feature, index) => (
            <div
              key={index}
              className="p-6 rounded-lg border bg-card text-card-foreground"
            >
              <feature.icon className="h-12 w-12 text-primary mb-4" />
              <h3 className="text-xl font-semibold mb-2">{feature.title}</h3>
              <p className="text-muted-foreground">{feature.description}</p>
            </div>
          ))}
        </div>
      </main>
    </div>
  );
}

const features = [
  {
    title: "Multi-branch Management",
    description: "Efficiently manage multiple salon locations from a single dashboard with real-time insights and controls.",
    icon: Scissors,
  },
  {
    title: "Smart Scheduling",
    description: "Streamline appointments with intelligent booking system and staff management tools.",
    icon: Scissors,
  },
  {
    title: "Digital Payments",
    description: "Accept payments through multiple channels including UPI, cards, and digital wallets.",
    icon: Scissors,
  },
];
