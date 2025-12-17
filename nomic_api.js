const axios = require('axios');

const fetchDataFromNomic = async () => {
    try {
        const response = await axios.get('https://api.nomic.ai/v1/data', {
            headers: {
                'Authorization': `Bearer ${process.env.NOMIC_API_KEY}`
            }
        });
        console.log(response.data);
    } catch (error) {
        console.error(error);
    }
};

fetchDataFromNomic();
