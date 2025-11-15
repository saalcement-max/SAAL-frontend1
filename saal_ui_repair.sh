#!/bin/bash
echo "=== SAAL UI REPAIR SCRIPT ==="

# ---------------------------------------------------
# 1. CLEAN PROJECT
# ---------------------------------------------------
echo "--- CLEANING PROJECT ---"
rm -rf node_modules package-lock.json dist
npm cache clean --force

# ---------------------------------------------------
# 2. INSTALL CORRECT PACKAGES
# ---------------------------------------------------
echo "--- INSTALLING REQUIRED PACKAGES ---"
npm install aws-amplify@6 react react-dom vite

# ---------------------------------------------------
# 3. ENSURE SRC FOLDER EXISTS
# ---------------------------------------------------
mkdir -p src

# ---------------------------------------------------
# 4. FIX aws-exports.js
# ---------------------------------------------------
echo "--- WRITING aws-exports.js ---"
cat > src/aws-exports.js <<'EOF'
const awsExports = {
  Auth: {
    region: "us-west-2",
    userPoolId: "us-west-2_GW0n4A2xc",
    userPoolWebClientId: "23ns3k2juhn130jdfkseritqpm",
    authenticationFlowType: "USER_PASSWORD_AUTH"
  }
};

export default awsExports;
EOF

# ---------------------------------------------------
# 5. FIX App.jsx (CLEAN, NO # COMMENTS)
# ---------------------------------------------------
echo "--- WRITING App.jsx ---"
cat > src/App.jsx <<'EOF'
import React, { useState } from "react";
import { Amplify } from "aws-amplify";
import { signIn } from "aws-amplify/auth";
import awsExports from "./aws-exports";

Amplify.configure(awsExports);

function App() {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");

  const doSignIn = async () => {
    try {
      const result = await signIn({ username, password });
      console.log("Login Success:", result);
      alert("SIGNED IN SUCCESSFULLY");
    } catch (err) {
      console.error("Login Error:", err);
      alert("ERROR: " + err.message);
    }
  };

  return (
    <div style={{ padding: 40 }}>
      <h2>SAAL Login</h2>
      <input
        placeholder="Username"
        value={username}
        onChange={(e) => setUsername(e.target.value)}
      /><br /><br />
      <input
        placeholder="Password"
        type="password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
      /><br /><br />
      <button onClick={doSignIn}>Sign In</button>
    </div>
  );
}

export default App;
EOF

# ---------------------------------------------------
# 6. FIX main.jsx
# ---------------------------------------------------
echo "--- WRITING main.jsx ---"
cat > src/main.jsx <<'EOF'
import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App";

ReactDOM.createRoot(document.getElementById("root")).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
EOF

# ---------------------------------------------------
# 7. BUILD
# ---------------------------------------------------
echo "--- BUILDING FRONTEND ---"
npm run build

if [ $? -ne 0 ]; then
  echo "BUILD FAILED. CHECK ABOVE ERRORS."
  exit 1
fi

echo "=== SAAL UI REPAIR COMPLETE ==="
EOF

