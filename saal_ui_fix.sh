#!/bin/bash
# saal_ui_fix.sh
# Fix Amplify Auth imports, rebuild, and deploy frontend

set -e

echo "=== Step 1: Clean node_modules and reinstall dependencies ==="
rm -rf node_modules package-lock.json
npm install

echo "=== Step 2: Ensure correct Amplify packages ==="
npm uninstall aws-amplify @aws-amplify/auth || true
npm install aws-amplify @aws-amplify/auth@latest

echo "=== Step 3: Create/fix aws-exports.js ==="
mkdir -p src
cat > src/aws-exports.js <<EOL
const awsExports = {
  Auth: {
    region: "us-west-2",
    userPoolId: "us-west-2_GW0n4A2xc",
    userPoolWebClientId: "23ns3k2juhn130jdfkseritqpm",
    authenticationFlowType: "USER_PASSWORD_AUTH"
  }
};
export default awsExports;
EOL

echo "=== Step 4: Fix App.jsx imports ==="
cat > src/App.jsx <<EOL
import React, { useState } from 'react';
import Amplify from 'aws-amplify';
import Auth from '@aws-amplify/auth';  // default import for v7+
import awsExports from './aws-exports';

Amplify.configure(awsExports);

function App() {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [message, setMessage] = useState('');

  const handleSignUp = async () => {
    try {
      await Auth.signUp({
        username,
        password,
        attributes: { email: username }
      });
      setMessage('Sign-up successful! Check email to confirm.');
    } catch (err) {
      setMessage(\`Error: \${err.message}\`);
    }
  };

  const handleSignIn = async () => {
    try {
      await Auth.signIn(username, password);
      setMessage('Sign-in successful!');
    } catch (err) {
      setMessage(\`Error: \${err.message}\`);
    }
  };

  return (
    <div>
      <h1>SAAL Auth Test</h1>
      <input type="email" placeholder="Email" value={username} onChange={e => setUsername(e.target.value)} />
      <input type="password" placeholder="Password" value={password} onChange={e => setPassword(e.target.value)} />
      <button onClick={handleSignUp}>Sign Up</button>
      <button onClick={handleSignIn}>Sign In</button>
      <p>{message}</p>
    </div>
  );
}

export default App;
EOL

echo "=== Step 5: Fix main.jsx ==="
cat > src/main.jsx <<EOL
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App.jsx';

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
EOL

echo "=== Step 6: Build frontend ==="
npm run build

echo "=== Step 7: Sync to S3 ==="
aws s3 sync ./dist s3://saal-frontend-bucket --delete

echo "=== Step 8: Invalidate CloudFront cache ==="
echo "Run the following command manually (replace with your CloudFront ID):"
echo "aws cloudfront create-invalidation --distribution-id <your-cloudfront-id> --paths '/*'"

echo "=== DONE: If build fails, copy the above commands manually ==="

