#!/bin/bash
echo "🚀 Starting SAAL UI full fix..."

# 1. Remove old node_modules & lockfile
rm -rf node_modules package-lock.json

# 2. Clear npm cache
npm cache clean --force

# 3. Install fresh dependencies
npm install react react-dom @aws-amplify/core @aws-amplify/auth

# 4. Re-create App.jsx with correct imports
cat > src/App.jsx << 'EOF'
import React, { useState } from "react";
import { Amplify } from "@aws-amplify/core";
import Auth from "@aws-amplify/auth";
import awsconfig from "./aws-exports";

Amplify.configure(awsconfig);

export default function App() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const signUp = async () => {
    try {
      const { user } = await Auth.signUp({
        username: email,
        password,
        attributes: { email },
      });
      console.log("Signed up user:", user);
      alert("Signed up! Check your email to confirm.");
    } catch (err) {
      console.error(err);
      alert(err.message);
    }
  };

  const signIn = async () => {
    try {
      const user = await Auth.signIn(email, password);
      console.log("Signed in user:", user);
      alert("Signed in!");
    } catch (err) {
      console.error(err);
      alert(err.message);
    }
  };

  return (
    <div style={{ padding: "2rem" }}>
      <h1>SAAL Sign In / Sign Up</h1>
      <input
        placeholder="Email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
      />
      <input
        placeholder="Password"
        type="password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
      />
      <button onClick={signUp}>Sign Up</button>
      <button onClick={signIn}>Sign In</button>
    </div>
  );
}
EOF

# 5. Rebuild frontend
npm run build

# 6. Start dev server
npm run dev

