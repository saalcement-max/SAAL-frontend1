#!/bin/bash
echo "======================================="
echo "=== SAAL UI FINAL REPAIR SCRIPT v3 ==="
echo "======================================="

# Step 0: Ensure we are in frontend directory
cd "$(dirname "$0")/.." || exit 1
echo "--- Working directory: $(pwd) ---"

# Step 1: Clean project
echo "--- Cleaning node_modules and cache ---"
rm -rf node_modules package-lock.json
npm cache clean --force

# Step 2: Install required packages
echo "--- Installing packages ---"
npm install aws-amplify @aws-amplify/auth react react-dom vite

# Step 3: Create aws-exports.js
echo "--- Writing aws-exports.js ---"
mkdir -p src
cat > src/aws-exports.js << 'EOF'
// aws-exports.js - SAAL React Frontend Config
const awsconfig = {
    aws_project_region: "us-west-2",
    aws_cognito_region: "us-west-2",
    aws_user_pools_id: "us-west-2_GW0n4A2xc",
    aws_user_pools_web_client_id: "23ns3k2juhn130jdfkseritqpm",
    oauth: {},
};
export default awsconfig;
EOF

# Step 4: Create App.jsx
echo "--- Writing App.jsx ---"
cat > src/App.jsx << 'EOF'
import React, { useState } from 'react';
import { Amplify } from 'aws-amplify';
import { Auth } from '@aws-amplify/auth';
import awsconfig from './aws-exports';
Amplify.configure(awsconfig);

function App() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [message, setMessage] = useState('');

  const signUp = async () => {
    try {
      const result = await Auth.signUp({ username: email, password });
      setMessage(`Sign-up successful! ${result.user.username}`);
    } catch (error) {
      setMessage(error.message);
    }
  };

  const signIn = async () => {
    try {
      const user = await Auth.signIn(email, password);
      setMessage(`Sign-in successful! Welcome ${user.username}`);
    } catch (error) {
      setMessage(error.message);
    }
  };

  return (
    <div style={{ maxWidth: 400, margin: '50px auto', fontFamily: 'Arial, sans-serif' }}>
      <h1 style={{ textAlign: 'center' }}>SAAL Auth</h1>
      <input
        type="email"
        placeholder="Email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        style={{ width: '100%', padding: 10, marginBottom: 10 }}
      />
      <input
        type="password"
        placeholder="Password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        style={{ width: '100%', padding: 10, marginBottom: 10 }}
      />
      <button onClick={signUp} style={{ width: '48%', padding: 10, marginRight: '4%' }}>Sign Up</button>
      <button onClick={signIn} style={{ width: '48%', padding: 10 }}>Sign In</button>
      {message && <p style={{ marginTop: 20 }}>{message}</p>}
    </div>
  );
}

export default App;
EOF

# Step 5: Create main.jsx
echo "--- Writing main.jsx ---"
cat > src/main.jsx << 'EOF'
import React from 'react';
import ReactDOM from 'react-dom';
import App from './App';

ReactDOM.render(<App />, document.getElementById('root'));
EOF

# Step 6: Build frontend
echo "--- Building frontend ---"
npm run build || { echo "Build failed"; exit 1; }

# Step 7: Sync to S3
echo "--- Syncing build to S3 ---"
aws s3 sync ./dist s3://saal-frontend-bucket --delete

# Step 8: CloudFront Invalidation
CLOUDFRONT_ID="E37DHY2S2KFG4F"
echo "--- Creating CloudFront invalidation ---"
aws cloudfront create-invalidation --distribution-id $CLOUDFRONT_ID --paths "/*"

echo "--- SAAL UI FINAL REPAIR COMPLETE ---"

