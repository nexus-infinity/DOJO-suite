const axios = require('axios');

const saveToKeyMateMemory = async (data) => {
    try {
        const response = await axios.post('https://api.keymate.ai/v1/insert', data, {
            headers: {
                'Authorization': `Bearer ${process.env.KEYMATE_API_KEY}`,
                'Content-Type': 'application/json'
            }
        });
        console.log('Data saved to KeyMate:', response.data);
    } catch (error) {
        console.error('Error saving data to KeyMate:', error);
    }
};

saveToKeyMateMemory({ data: 'Sample Data' });
