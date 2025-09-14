const { useState } = React;

function App() {
    const [url, setUrl] = useState('');
    const [loading, setLoading] = useState(false);
    const [result, setResult] = useState(null);
    const [error, setError] = useState(null);

    const handleSubmit = async (e) => {
        e.preventDefault();
        if (!url.trim()) {
            setError('Please enter a valid URL');
            return;
        }

        setLoading(true);
        setError(null);
        setResult(null);

        try {
            const response = await fetch('https://integrate.api.nvidia.com/v1/chat/completions', {
                method: 'POST',
                headers: {
                    'Authorization': 'Bearer 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',
                    'Accept': 'application/json',
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    model: 'meta/llama-3.1-405b-instruct',
                    messages: [
                        {
                            role: 'system',
                            content: 'You are an AI assistant that converts websites into iOS apps. When given a URL, analyze it and either provide a download link for an iOS .ipa file or explain what you found. If you can provide an .ipa file, respond with "DOWNLOAD: [URL]" where [URL] is the direct download link. Otherwise, provide informational text about the website.'
                        },
                        {
                            role: 'user',
                            content: `Convert this website to an iOS app: ${url}`
                        }
                    ],
                    max_tokens: 1024,
                    temperature: 0.7
                })
            });

            if (!response.ok) {
                throw new Error(`API request failed: ${response.status} ${response.statusText}`);
            }

            const data = await response.json();
            const aiResponse = data.choices?.[0]?.message?.content || 'No response received';
            
            // Check if the response contains a download link
            if (aiResponse.startsWith('DOWNLOAD:')) {
                const downloadUrl = aiResponse.replace('DOWNLOAD:', '').trim();
                setResult({
                    type: 'download',
                    url: downloadUrl,
                    message: 'iOS app generated successfully!'
                });
            } else {
                setResult({
                    type: 'info',
                    message: aiResponse
                });
            }

        } catch (err) {
            console.error('Error:', err);
            setError(err.message || 'An error occurred while processing your request');
        } finally {
            setLoading(false);
        }
    };

    const handleClear = () => {
        setUrl('');
        setResult(null);
        setError(null);
    };

    return React.createElement('div', { className: 'app' },
        React.createElement('header', { className: 'header' },
            React.createElement('h1', null, 'Link2App'),
            React.createElement('p', { className: 'subtitle' }, 'Convert any website into an iOS app using AI')
        ),
        
        React.createElement('main', { className: 'main' },
            React.createElement('form', { onSubmit: handleSubmit, className: 'form' },
                React.createElement('div', { className: 'input-group' },
                    React.createElement('label', { htmlFor: 'url', className: 'label' }, 'Website URL'),
                    React.createElement('input', {
                        id: 'url',
                        type: 'url',
                        value: url,
                        onChange: (e) => setUrl(e.target.value),
                        placeholder: 'https://example.com',
                        className: 'input',
                        disabled: loading
                    })
                ),
                
                React.createElement('div', { className: 'button-group' },
                    React.createElement('button', {
                        type: 'submit',
                        disabled: loading || !url.trim(),
                        className: 'button button-primary'
                    }, loading ? 'Converting...' : 'Convert to iOS App'),
                    
                    React.createElement('button', {
                        type: 'button',
                        onClick: handleClear,
                        disabled: loading,
                        className: 'button button-secondary'
                    }, 'Clear')
                )
            ),

            error && React.createElement('div', { className: 'alert alert-error' },
                React.createElement('strong', null, 'Error: '),
                error
            ),

            result && React.createElement('div', { className: 'result' },
                result.type === 'download' 
                    ? React.createElement('div', { className: 'alert alert-success' },
                        React.createElement('h3', null, '🎉 Success!'),
                        React.createElement('p', null, result.message),
                        React.createElement('a', {
                            href: result.url,
                            download: true,
                            className: 'download-link'
                        }, '📱 Download iOS App (.ipa)')
                    )
                    : React.createElement('div', { className: 'alert alert-info' },
                        React.createElement('h3', null, 'ℹ️ Information'),
                        React.createElement('p', null, result.message)
                    )
            )
        ),

        React.createElement('footer', { className: 'footer' },
            React.createElement('p', null, 'Powered by NVIDIA AI • Built with React')
        )
    );
}

ReactDOM.render(React.createElement(App), document.getElementById('root'));