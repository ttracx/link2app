import Foundation
import WebKit

struct WebsiteAnalysis: Codable {
    let url: String
    let title: String
    let description: String?
    let keywords: [String]
    let structure: WebsiteStructure
    let styles: StyleAnalysis
    let scripts: [ScriptInfo]
    let images: [ImageInfo]
    let forms: [FormInfo]
    let navigation: NavigationInfo
    let mobileCompatibility: MobileCompatibility
    let performance: PerformanceMetrics
    let accessibility: AccessibilityInfo
    let createdAt: Date
    
    init(url: String, title: String, description: String? = nil) {
        self.url = url
        self.title = title
        self.description = description
        self.keywords = []
        self.structure = WebsiteStructure()
        self.styles = StyleAnalysis()
        self.scripts = []
        self.images = []
        self.forms = []
        self.navigation = NavigationInfo()
        self.mobileCompatibility = MobileCompatibility()
        self.performance = PerformanceMetrics()
        self.accessibility = AccessibilityInfo()
        self.createdAt = Date()
    }
}

struct WebsiteStructure: Codable {
    let mainSections: [SectionInfo]
    let header: SectionInfo?
    let footer: SectionInfo?
    let sidebar: SectionInfo?
    let content: SectionInfo?
    let layout: LayoutType
    
    init() {
        self.mainSections = []
        self.header = nil
        self.footer = nil
        self.sidebar = nil
        self.content = nil
        self.layout = .unknown
    }
}

struct SectionInfo: Codable {
    let id: String?
    let className: String?
    let tagName: String
    let content: String
    let children: [SectionInfo]
    let attributes: [String: String]
}

enum LayoutType: String, Codable {
    case singleColumn = "single_column"
    case twoColumn = "two_column"
    case threeColumn = "three_column"
    case grid = "grid"
    case masonry = "masonry"
    case unknown = "unknown"
}

struct StyleAnalysis: Codable {
    let primaryColors: [String]
    let fonts: [FontInfo]
    let spacing: SpacingInfo
    let borderRadius: Double?
    let shadows: [ShadowInfo]
    let animations: [AnimationInfo]
}

struct FontInfo: Codable {
    let family: String
    let size: Double
    let weight: String
    let style: String
}

struct SpacingInfo: Codable {
    let padding: Double
    let margin: Double
    let gap: Double
}

struct ShadowInfo: Codable {
    let color: String
    let offset: CGPoint
    let radius: Double
    let opacity: Double
}

struct AnimationInfo: Codable {
    let type: String
    let duration: Double
    let easing: String
}

struct ScriptInfo: Codable {
    let src: String?
    let type: String
    let content: String?
    let isExternal: Bool
}

struct ImageInfo: Codable {
    let src: String
    let alt: String?
    let width: Double?
    let height: Double?
    let isResponsive: Bool
}

struct FormInfo: Codable {
    let action: String?
    let method: String
    let fields: [FormField]
    let validation: ValidationInfo?
}

struct FormField: Codable {
    let name: String
    let type: String
    let placeholder: String?
    let required: Bool
    let validation: String?
}

struct ValidationInfo: Codable {
    let rules: [String: String]
    let messages: [String: String]
}

struct NavigationInfo: Codable {
    let mainMenu: [MenuItem]
    let breadcrumbs: [MenuItem]
    let pagination: PaginationInfo?
    let search: SearchInfo?
}

struct MenuItem: Codable {
    let text: String
    let url: String
    let children: [MenuItem]
}

struct PaginationInfo: Codable {
    let currentPage: Int
    let totalPages: Int
    let hasNext: Bool
    let hasPrevious: Bool
}

struct SearchInfo: Codable {
    let placeholder: String
    let action: String
    let method: String
}

struct MobileCompatibility: Codable {
    let isResponsive: Bool
    let viewport: String?
    let touchFriendly: Bool
    let mobileNavigation: Bool
    let performanceScore: Double
}

struct PerformanceMetrics: Codable {
    let loadTime: Double
    let size: Int
    let requests: Int
    let images: Int
    let scripts: Int
    let stylesheets: Int
}

struct AccessibilityInfo: Codable {
    let hasAltText: Bool
    let hasHeadings: Bool
    let hasLabels: Bool
    let contrastRatio: Double
    let keyboardNavigation: Bool
    let screenReaderSupport: Bool
}

class WebsiteAnalyzer: NSObject {
    private var webView: WKWebView?
    private var analysisCompletion: ((Result<WebsiteAnalysis, Error>) -> Void)?
    
    func analyzeWebsite(url: String) async throws -> WebsiteAnalysis {
        return try await withCheckedThrowingContinuation { continuation in
            analyzeWebsite(url: url) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    private func analyzeWebsite(url: String, completion: @escaping (Result<WebsiteAnalysis, Error>) -> Void) {
        self.analysisCompletion = completion
        
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView?.navigationDelegate = self
        
        guard let url = URL(string: url) else {
            completion(.failure(WebsiteAnalysisError.invalidURL))
            return
        }
        
        let request = URLRequest(url: url)
        webView?.load(request)
    }
    
    private func performAnalysis() {
        guard let webView = webView else { return }
        
        let analysisScript = """
        (function() {
            const analysis = {
                title: document.title,
                description: document.querySelector('meta[name="description"]')?.content || null,
                keywords: Array.from(document.querySelectorAll('meta[name="keywords"]')).map(meta => meta.content).join(',').split(',').filter(k => k.trim()),
                structure: analyzeStructure(),
                styles: analyzeStyles(),
                scripts: analyzeScripts(),
                images: analyzeImages(),
                forms: analyzeForms(),
                navigation: analyzeNavigation(),
                mobileCompatibility: analyzeMobileCompatibility(),
                performance: analyzePerformance(),
                accessibility: analyzeAccessibility()
            };
            
            function analyzeStructure() {
                const sections = [];
                const main = document.querySelector('main') || document.body;
                
                return {
                    mainSections: Array.from(main.children).map(el => ({
                        tagName: el.tagName.toLowerCase(),
                        className: el.className,
                        id: el.id,
                        content: el.textContent?.substring(0, 100) || '',
                        children: []
                    })),
                    layout: determineLayout()
                };
            }
            
            function analyzeStyles() {
                const styles = getComputedStyle(document.body);
                return {
                    primaryColors: extractColors(),
                    fonts: extractFonts(),
                    spacing: {
                        padding: parseFloat(styles.padding) || 0,
                        margin: parseFloat(styles.margin) || 0,
                        gap: parseFloat(styles.gap) || 0
                    }
                };
            }
            
            function analyzeScripts() {
                return Array.from(document.scripts).map(script => ({
                    src: script.src,
                    type: script.type,
                    isExternal: !!script.src
                }));
            }
            
            function analyzeImages() {
                return Array.from(document.images).map(img => ({
                    src: img.src,
                    alt: img.alt,
                    width: img.naturalWidth,
                    height: img.naturalHeight,
                    isResponsive: img.hasAttribute('srcset') || img.style.maxWidth === '100%'
                }));
            }
            
            function analyzeForms() {
                return Array.from(document.forms).map(form => ({
                    action: form.action,
                    method: form.method,
                    fields: Array.from(form.elements).map(field => ({
                        name: field.name,
                        type: field.type,
                        placeholder: field.placeholder,
                        required: field.required
                    }))
                }));
            }
            
            function analyzeNavigation() {
                const nav = document.querySelector('nav') || document.querySelector('[role="navigation"]');
                return {
                    mainMenu: nav ? Array.from(nav.querySelectorAll('a')).map(a => ({
                        text: a.textContent,
                        url: a.href,
                        children: []
                    })) : []
                };
            }
            
            function analyzeMobileCompatibility() {
                const viewport = document.querySelector('meta[name="viewport"]');
                return {
                    isResponsive: !!viewport,
                    viewport: viewport?.content,
                    touchFriendly: true, // Simplified
                    mobileNavigation: !!document.querySelector('[data-mobile-menu]'),
                    performanceScore: 0.8 // Simplified
                };
            }
            
            function analyzePerformance() {
                const navigation = performance.getEntriesByType('navigation')[0];
                return {
                    loadTime: navigation ? navigation.loadEventEnd - navigation.loadEventStart : 0,
                    size: document.documentElement.outerHTML.length,
                    requests: performance.getEntriesByType('resource').length,
                    images: document.images.length,
                    scripts: document.scripts.length,
                    stylesheets: document.styleSheets.length
                };
            }
            
            function analyzeAccessibility() {
                return {
                    hasAltText: Array.from(document.images).some(img => img.alt),
                    hasHeadings: document.querySelectorAll('h1, h2, h3, h4, h5, h6').length > 0,
                    hasLabels: document.querySelectorAll('label').length > 0,
                    contrastRatio: 4.5, // Simplified
                    keyboardNavigation: true, // Simplified
                    screenReaderSupport: true // Simplified
                };
            }
            
            function extractColors() {
                const colors = new Set();
                const elements = document.querySelectorAll('*');
                elements.forEach(el => {
                    const styles = getComputedStyle(el);
                    ['color', 'backgroundColor', 'borderColor'].forEach(prop => {
                        const color = styles[prop];
                        if (color && color !== 'rgba(0, 0, 0, 0)' && color !== 'transparent') {
                            colors.add(color);
                        }
                    });
                });
                return Array.from(colors).slice(0, 5);
            }
            
            function extractFonts() {
                const fonts = new Set();
                const elements = document.querySelectorAll('*');
                elements.forEach(el => {
                    const fontFamily = getComputedStyle(el).fontFamily;
                    if (fontFamily) {
                        fonts.add(fontFamily.split(',')[0].replace(/['"]/g, ''));
                    }
                });
                return Array.from(fonts).map(family => ({
                    family: family,
                    size: 16,
                    weight: 'normal',
                    style: 'normal'
                }));
            }
            
            function determineLayout() {
                const main = document.querySelector('main') || document.body;
                const children = Array.from(main.children);
                const hasSidebar = children.some(el => 
                    el.className.includes('sidebar') || 
                    el.className.includes('aside') ||
                    el.tagName.toLowerCase() === 'aside'
                );
                
                if (hasSidebar) return 'two_column';
                if (children.length > 3) return 'grid';
                return 'single_column';
            }
            
            return analysis;
        })();
        """
        
        webView.evaluateJavaScript(analysisScript) { [weak self] result, error in
            if let error = error {
                self?.analysisCompletion?(.failure(error))
                return
            }
            
            guard let analysisData = result as? [String: Any] else {
                self?.analysisCompletion?(.failure(WebsiteAnalysisError.invalidData))
                return
            }
            
            do {
                let analysis = try self?.parseAnalysisData(analysisData) ?? WebsiteAnalysis(url: "", title: "")
                self?.analysisCompletion?(.success(analysis))
            } catch {
                self?.analysisCompletion?(.failure(error))
            }
        }
    }
    
    private func parseAnalysisData(_ data: [String: Any]) throws -> WebsiteAnalysis {
        // This would parse the JavaScript analysis data into Swift structs
        // For now, return a basic analysis
        return WebsiteAnalysis(
            url: data["url"] as? String ?? "",
            title: data["title"] as? String ?? "",
            description: data["description"] as? String
        )
    }
}

extension WebsiteAnalyzer: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.performAnalysis()
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        analysisCompletion?(.failure(error))
    }
}

enum WebsiteAnalysisError: Error, LocalizedError {
    case invalidURL
    case invalidData
    case analysisFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid website URL"
        case .invalidData:
            return "Failed to parse website data"
        case .analysisFailed:
            return "Website analysis failed"
        }
    }
}