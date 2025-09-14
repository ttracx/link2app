# Link2App Web Interface

A modern web interface for converting websites to iOS apps using NVIDIA AI.

## Features

- **Clean, Modern UI**: Responsive design with gradient background
- **NVIDIA AI Integration**: Uses NVIDIA's chat completions API
- **Dual Response Handling**: 
  - Download links for .ipa files (when AI provides them)
  - Informational messages for analysis results
- **Error Handling**: Comprehensive error display and user feedback
- **GitHub Pages Ready**: Deployed directly from repository root

## API Integration

The web app sends prompts to the NVIDIA API endpoint:
- **Endpoint**: `https://integrate.api.nvidia.com/v1/chat/completions`
- **Model**: `meta/llama-3.1-405b-instruct`
- **Authentication**: Bearer token included in headers

### Response Handling

The AI is instructed to respond in two ways:
1. **Download Response**: `DOWNLOAD: [URL]` - Creates a download link
2. **Info Response**: Any other text - Displays as informational message

## Files Structure

```
/
├── index.html          # Main web app (root for GitHub Pages)
├── .nojekyll          # GitHub Pages compatibility
├── public/
│   └── index.html     # Alternative React version
└── src/
    ├── App.jsx        # React component (reference)
    ├── index.js       # React entry point (reference)  
    └── style.css      # Responsive CSS styles
```

## Local Development

1. Start a local server:
   ```bash
   python3 -m http.server 8000
   ```

2. Open in browser:
   ```
   http://localhost:8000
   ```

## Deployment

The app is configured for GitHub Pages deployment:
- Main file: `index.html` in repository root
- No build process required
- Uses `.nojekyll` for compatibility
- All resources are self-contained

## Browser Compatibility

- Modern browsers with ES6+ support
- Fetch API support required
- Responsive design for mobile/desktop

## Security Notes

- API key is included in the client-side code
- Consider server-side proxy for production use
- CORS handling depends on NVIDIA API configuration