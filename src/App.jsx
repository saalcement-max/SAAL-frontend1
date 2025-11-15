// src/App.jsx
import React, { useState } from "react";
import { Amplify } from "aws-amplify";
import * as AmplifyAuth from "@aws-amplify/auth";
import awsconfig from "./aws-exports";
import "./App.css";

Amplify.configure(awsconfig);

export default function App() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [message, setMessage] = useState("");
  const [loading, setLoading] = useState(false);

  const validateInputs = () => {
    if (!email || !password) {
      setMessage("❌ Email and password are required.");
      return false;
    }
    return true;
  };

  const signUp = async () => {
    if (!validateInputs()) return;
    setLoading(true);
    try {
      await AmplifyAuth.signUp({
        username: email,
        password,
        attributes: { email },
      });
      setMessage("✅ Signed up! Check your email to confirm.");
    } catch (err) {
      setMessage("❌ " + (err.message || JSON.stringify(err)));
    } finally {
      setLoading(false);
    }
  };

  const signIn = async () => {
    if (!validateInputs()) return;
    setLoading(true);
    try {
      await AmplifyAuth.signIn(email, password);
      setMessage("✅ Signed in successfully!");
    } catch (err) {
      setMessage("❌ " + (err.message || JSON.stringify(err)));
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="app-container">
      <h1>SAAL Authentication</h1>
      <input
        type="email"
        placeholder="Email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
      />
      <input
        type="password"
        placeholder="Password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
      />
      <div className="buttons">
        <button onClick={signUp} disabled={loading}>
          {loading ? "Signing Up..." : "Sign Up"}
        </button>
        <button onClick={signIn} disabled={loading}>
          {loading ? "Signing In..." : "Sign In"}
        </button>
      </div>
      {message && <p className="message">{message}</p>}
    </div>
  );
}

