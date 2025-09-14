const { StrictMode } = React;

const App = () => {
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

    return (
        <div className="app">
            <header className="header">
                <h1>Link2App</h1>
                <p className="subtitle">Convert any website into an iOS app using AI</p>
            </header>
            
            <main className="main">
                <form onSubmit={handleSubmit} className="form">
                    <div className="input-group">
                        <label htmlFor="url" className="label">Website URL</label>
                        <input
                            id="url"
                            type="url"
                            value={url}
                            onChange={(e) => setUrl(e.target.value)}
                            placeholder="https://example.com"
                            className="input"
                            disabled={loading}
                        />
                    </div>
                    
                    <div className="button-group">
                        <button
                            type="submit"
                            disabled={loading || !url.trim()}
                            className="button button-primary"
                        >
                            {loading ? 'Converting...' : 'Convert to iOS App'}
                        </button>
                        
                        <button
                            type="button"
                            onClick={handleClear}
                            disabled={loading}
                            className="button button-secondary"
                        >
                            Clear
                        </button>
                    </div>
                </form>

                {error && (
                    <div className="alert alert-error">
                        <strong>Error: </strong>
                        {error}
                    </div>
                )}

                {result && (
                    <div className="result">
                        {result.type === 'download' ? (
                            <div className="alert alert-success">
                                <h3>🎉 Success!</h3>
                                <p>{result.message}</p>
                                <a
                                    href={result.url}
                                    download
                                    className="download-link"
                                >
                                    📱 Download iOS App (.ipa)
                                </a>
                            </div>
                        ) : (
                            <div className="alert alert-info">
                                <h3>ℹ️ Information</h3>
                                <p>{result.message}</p>
                            </div>
                        )}
                    </div>
                )}
            </main>

            <footer className="footer">
                <p>Powered by NVIDIA AI • Built with React</p>
            </footer>
        </div>
    );
};

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(<App />);