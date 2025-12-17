#!/bin/bash

# Step 1: Install necessary libraries
echo "Installing necessary libraries..."
npm install axios mongoose --save

# Step 2: Check if .env file exists, otherwise exit
if [ ! -f .env ]; then
    echo ".env file is missing. Please ensure you have a .env file with all required credentials."
    exit 1
fi
echo ".env file found."

# Step 3: Setup MongoDB Connection
echo "Creating MongoDB connection script..."
cat <<EOT > mongo.js
const mongoose = require('mongoose');
const connectDB = async () => {
    try {
        await mongoose.connect(process.env.MONGO_URI, {
            useNewUrlParser: true,
            useUnifiedTopology: true,
        });
        console.log('MongoDB connected...');
    } catch (err) {
        console.error(err.message);
        process.exit(1);
    }
};
module.exports = connectDB;
EOT

echo "MongoDB connection setup complete."

# Step 4: Create NOMIC API Integration
echo "Creating NOMIC API integration script..."
cat <<EOT > nomic_api.js
const axios = require('axios');

const fetchDataFromNomic = async () => {
    try {
        const response = await axios.get('https://api.nomic.ai/v1/data', {
            headers: {
                'Authorization': \`Bearer \${process.env.NOMIC_API_KEY}\`
            }
        });
        console.log(response.data);
    } catch (error) {
        console.error(error);
    }
};

fetchDataFromNomic();
EOT

echo "NOMIC API integration script created."

# Step 5: Create KeyMate API Integration
echo "Creating KeyMate API integration script..."
cat <<EOT > keymate_api.js
const axios = require('axios');

const saveToKeyMateMemory = async (data) => {
    try {
        const response = await axios.post('https://api.keymate.ai/v1/insert', data, {
            headers: {
                'Authorization': \`Bearer \${process.env.KEYMATE_API_KEY}\`,
                'Content-Type': 'application/json'
            }
        });
        console.log('Data saved to KeyMate:', response.data);
    } catch (error) {
        console.error('Error saving data to KeyMate:', error);
    }
};

saveToKeyMateMemory({ data: 'Sample Data' });
EOT

echo "KeyMate API integration script created."

# Step 6: Set up Google API Integration
echo "Setting up Google API integration..."
cat <<EOT > google_api.js
const { google } = require('googleapis');
const { OAuth2 } = google.auth;

const oAuth2Client = new OAuth2(
    process.env.GOOGLE_API_CLIENT_ID,
    process.env.GOOGLE_API_SECRET
);

oAuth2Client.setCredentials({
    refresh_token: process.env.GOOGLE_REFRESH_TOKEN
});

const drive = google.drive({ version: 'v3', auth: oAuth2Client });

const listFiles = async () => {
    const res = await drive.files.list({
        pageSize: 10,
        fields: 'files(id, name)',
    });
    console.log('Files:', res.data.files);
};

listFiles();
EOT

echo "Google API setup complete."

# Step 7: Vercel API Setup
echo "Setting up Vercel deployment script..."
cat <<EOT > deploy_vercel.sh
#!/bin/bash
vercel --token \$VERCEL_API_TOKEN
EOT

chmod +x deploy_vercel.sh
echo "Vercel deployment script created and made executable."

# Final message
echo "Universal Framework setup complete!"
