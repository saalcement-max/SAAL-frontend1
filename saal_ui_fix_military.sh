#!/bin/bash
echo "=== SAAL UI Military Fix Script ==="

# Step 1: Clean node_modules and cache
echo "Step 1: Cleaning node_modules and npm cache..."
rm -rf node_modules package-lock.json
npm cache clean --force

# Step 2: Install correct packages
echo "Step 2: Installing Amplify, React, Vite..."
npm install aws-amplify react react-dom vite

# Step 3: Create/update aws-exports.js
echo "Step 3: Creating aws-exports.js..."
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

# Step 4: Create/update App.jsx
echo "Step 4: Creating App.jsx..."
cat > src/App.jsx <<EOL
import React, { useState } from 'react';
import * as AmplifyModules from 'aws-amplify';
import { Auth } from 'aws-amplify';
import awsExports from './aws-exports';

AmplifyModules.Amplify.configure(awsExports);

function App() {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');

  const handleSignIn = async () => {
    try {
      const user = await Auth.signIn(username, password);
      console.log('Signed in', user);
      alert('Sign-in successful');
    } catch (err) {
      console.error('Sign in error', err);
      alert('Sign-in failed: ' + err.message);
    }
  };

  return (
    <div>
      <input value={username} onChange={e => setUsername(e.target.value)} placeholder="Username" />
      <input type="password" value={password} onChange={e => setPassword(e.target.value)} placeholder="Password" />
      <button onClick={handleSignIn}>Sign In</button>
    </div>
  );
}

export default App;
EOL

# Step 5: Create/update main.jsx
echo "Step 5: Creating main.jsx..."
cat > src/main.jsx <<EOL
import React from 'react';
import ReactDOM from 'react-dom';
import App from './App';

ReactDOM.render(<App />, document.getElementById('root'));
EOL

# Step 6: Build frontend
echo "Step 6: Building frontend..."
npm run build
if [ $? -ne 0 ]; then
  echo "Build failed. Fix errors above and rerun the script."
  exit 1
fi

# Step 7: Sync to S3
echo "Step 7: Syncing build to S3..."
aws s3 sync ./dist s3://saal-frontend-bucket --delete

# Step 8: CloudFront invalidation
if [ ! -f cloudfront-id.txt ]; then
  echo "ERROR: cloudfront-id.txt missing. Paste your distribution ID into it."
  exit 1
fi
CLOUDFRONT_ID=$(cat cloudfront-id.txt)
echo "Step 8: Creating CloudFront invalidation..."
aws cloudfront create-invalidation --distribution-id $CLOUDFRONT_ID --paths "/*"

echo "=== SAAL UI Military Fix Completed ==="

