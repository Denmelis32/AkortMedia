module.exports.handler = async function (event, context) {
    const headers = {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type,Authorization'
    };

    if (event.httpMethod === 'OPTIONS') {
        return { statusCode: 200, headers, body: '' };
    }

    try {
        const queryParams = event.queryStringParameters || {};
        const path = queryParams.path || '';
        const httpMethod = event.httpMethod;

        console.log('Request received:', { path, httpMethod });

        const BUCKET_NAME = 'my-app-media-1739788506000';

        // Получить URL для загрузки файла
        if (httpMethod === 'GET' && path === 'get-upload-url') {
            const fileName = `media/${Date.now()}-${Math.random().toString(36).substring(7)}.jpg`;

            return {
                statusCode: 200,
                headers,
                body: JSON.stringify({
                    uploadUrl: `https://storage.yandexcloud.net/${BUCKET_NAME}/${fileName}`,
                    fileUrl: `https://${BUCKET_NAME}.storage.yandexcloud.net/${fileName}`,
                    success: true
                })
            };
        }

        // Получить список медиа - ВАЖНО: добавим демо-данные
        if (httpMethod === 'GET' && path === 'list-media') {
            return {
                statusCode: 200,
                headers,
                body: JSON.stringify({
                    media: [
                        {
                            id: 'demo-1',
                            url: 'https://picsum.photos/400/300?random=1',
                            fileName: 'landscape.jpg',
                            uploadTime: new Date().toISOString(),
                            author: 'Demo User'
                        },
                        {
                            id: 'demo-2',
                            url: 'https://picsum.photos/400/300?random=2',
                            fileName: 'portrait.jpg',
                            uploadTime: new Date().toISOString(),
                            author: 'Demo User'
                        },
                        {
                            id: 'demo-3',
                            url: 'https://picsum.photos/400/300?random=3',
                            fileName: 'nature.jpg',
                            uploadTime: new Date().toISOString(),
                            author: 'Demo User'
                        }
                    ],
                    success: true
                })
            };
        }

        // Тестовый endpoint
        if (httpMethod === 'GET' && path === 'test') {
            return {
                statusCode: 200,
                headers,
                body: JSON.stringify({
                    message: 'Function is working correctly!',
                    timestamp: new Date().toISOString(),
                    success: true
                })
            };
        }

        return {
            statusCode: 200,
            headers,
            body: JSON.stringify({
                message: 'Media API is working!',
                success: true
            })
        };

    } catch (error) {
        console.error('Error:', error);
        return {
            statusCode: 500,
            headers,
            body: JSON.stringify({
                error: error.message,
                success: false
            })
        };
    }
};