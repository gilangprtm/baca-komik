const fs = require("fs");
const path = require("path");

const envContent = `# Supabase configuration
NEXT_PUBLIC_SUPABASE_URL=https://owiowqcpkksbuuoyhplm.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im93aW93cWNwa2tzYnV1b3locGxtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYwNzc5MTEsImV4cCI6MjA2MTY1MzkxMX0.T230qvftj_LATF2tg1zKdHpMRjr0tqyIsP-zcMxVlco

# API Configuration
NEXT_PUBLIC_API_URL=http://localhost:3000/api
`;

const envPath = path.join(__dirname, "..", ".env.local");

try {
  fs.writeFileSync(envPath, envContent);
  console.log("✅ .env.local file has been created successfully");
} catch (error) {
  console.error("❌ Error creating .env.local file:", error);
}
