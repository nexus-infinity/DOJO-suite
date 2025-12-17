const { google } = require('googleapis');
const { OAuth2 } = google.auth;

const oAuth2Client = new OAuth2(
    process.env.GOOGLE_API_CLIENT_ID,
    process.env.GOOGLE_API_SECRET
);

oAuth2Client.setCredentials({
    refresh_token: 'your-refresh-token'
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
