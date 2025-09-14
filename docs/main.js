// Mobile Navigation Toggle
const hamburger = document.getElementById('hamburger');
const navMenu = document.getElementById('nav-menu');

hamburger.addEventListener('click', () => {
  hamburger.classList.toggle('active');
  navMenu.classList.toggle('active');
});

// Close mobile menu when clicking on a link
document.querySelectorAll('.nav-link').forEach(link => {
  link.addEventListener('click', () => {
    hamburger.classList.remove('active');
    navMenu.classList.remove('active');
  });
});

// Smooth scrolling for navigation links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
  anchor.addEventListener('click', function (e) {
    e.preventDefault();
    const target = document.querySelector(this.getAttribute('href'));
    if (target) {
      target.scrollIntoView({
        behavior: 'smooth',
        block: 'start'
      });
    }
  });
});

// Navbar background change on scroll
window.addEventListener('scroll', () => {
  const navbar = document.querySelector('.navbar');
  if (window.scrollY > 50) {
    navbar.style.background = 'rgba(255, 255, 255, 0.98)';
    navbar.style.boxShadow = '0 2px 20px rgba(0, 0, 0, 0.1)';
  } else {
    navbar.style.background = 'rgba(255, 255, 255, 0.95)';
    navbar.style.boxShadow = 'none';
  }
});

// Demo Form Functionality
const conversionForm = document.getElementById('conversionForm');
const resultContainer = document.getElementById('result');
const appPreview = document.getElementById('appPreview');

// Sample app previews for different types of websites
const appPreviews = {
  'news': {
    header: 'News App',
    content: `
      <div class="news-item">
        <div class="news-title">Breaking News</div>
        <div class="news-excerpt">Latest updates from around the world...</div>
      </div>
      <div class="news-item">
        <div class="news-title">Technology</div>
        <div class="news-excerpt">AI and machine learning advances...</div>
      </div>
    `
  },
  'ecommerce': {
    header: 'Shop App',
    content: `
      <div class="product-item">
        <div class="product-image"></div>
        <div class="product-info">
          <div class="product-name">Premium Product</div>
          <div class="product-price">$99.99</div>
        </div>
      </div>
    `
  },
  'portfolio': {
    header: 'Portfolio',
    content: `
      <div class="portfolio-item">
        <div class="portfolio-image"></div>
        <div class="portfolio-title">Creative Project</div>
      </div>
    `
  },
  'default': {
    header: 'Web App',
    content: `
      <div class="content-line"></div>
      <div class="content-line short"></div>
      <div class="content-line"></div>
      <div class="content-line medium"></div>
    `
  }
};

// Function to detect website type from URL
function detectWebsiteType(url) {
  const domain = url.toLowerCase();
  if (domain.includes('news') || domain.includes('cnn') || domain.includes('bbc')) {
    return 'news';
  } else if (domain.includes('shop') || domain.includes('store') || domain.includes('ecommerce')) {
    return 'ecommerce';
  } else if (domain.includes('portfolio') || domain.includes('creative')) {
    return 'portfolio';
  }
  return 'default';
}

// Function to update app preview
function updateAppPreview(url, appName) {
  const websiteType = detectWebsiteType(url);
  const preview = appPreviews[websiteType] || appPreviews.default;
  
  appPreview.innerHTML = `
    <div class="app-header">
      <div class="app-title">${appName || preview.header}</div>
      <div class="app-controls">
        <div class="control"></div>
        <div class="control"></div>
        <div class="control"></div>
      </div>
    </div>
    <div class="app-content">
      ${preview.content}
    </div>
  `;
}

// Function to show loading state
function showLoading() {
  resultContainer.innerHTML = `
    <div class="spinner"></div>
    <p style="text-align: center; margin-top: 1rem; color: #666;">
      Analyzing website and generating iOS app...
    </p>
  `;
}

// Function to show result
function showResult(success, message, downloadLink = null) {
  if (success) {
    resultContainer.innerHTML = `
      <div style="text-align: center; padding: 2rem; background: #f0f8ff; border-radius: 15px; border: 2px solid #007aff;">
        <div style="font-size: 3rem; color: #25c685; margin-bottom: 1rem;">
          <i class="fas fa-check-circle"></i>
        </div>
        <h3 style="color: #333; margin-bottom: 1rem;">Conversion Successful!</h3>
        <p style="color: #666; margin-bottom: 1.5rem;">${message}</p>
        ${downloadLink ? `
          <a href="${downloadLink}" class="download-link" download>
            <i class="fas fa-download"></i>
            Download iOS App (.ipa)
          </a>
        ` : `
          <div style="background: #e8f5e8; padding: 1rem; border-radius: 10px; color: #2d5a2d;">
            <i class="fas fa-info-circle"></i>
            This is a demo. In the full app, you would get a downloadable Xcode project.
          </div>
        `}
      </div>
    `;
  } else {
    resultContainer.innerHTML = `
      <div style="text-align: center; padding: 2rem; background: #fff5f5; border-radius: 15px; border: 2px solid #ff6b6b;">
        <div style="font-size: 3rem; color: #ff6b6b; margin-bottom: 1rem;">
          <i class="fas fa-exclamation-triangle"></i>
        </div>
        <h3 style="color: #333; margin-bottom: 1rem;">Conversion Failed</h3>
        <p style="color: #666;">${message}</p>
      </div>
    `;
  }
}

// Form submission handler
conversionForm.addEventListener('submit', async (e) => {
  e.preventDefault();
  
  const url = document.getElementById('urlInput').value;
  const appName = document.getElementById('appName').value;
  const aiModel = document.getElementById('aiModel').value;
  
  // Update preview immediately
  updateAppPreview(url, appName);
  
  // Show loading state
  showLoading();
  
  // Simulate processing time
  setTimeout(() => {
    // Simulate API call
    simulateConversion(url, appName, aiModel);
  }, 2000);
});

// Simulate conversion process
function simulateConversion(url, appName, aiModel) {
  // Simulate different outcomes based on URL
  const isSuccess = Math.random() > 0.2; // 80% success rate for demo
  
  if (isSuccess) {
    const websiteType = detectWebsiteType(url);
    const messages = {
      'news': 'Your news website has been successfully converted into a native iOS app with article views, categories, and search functionality.',
      'ecommerce': 'Your e-commerce store has been converted into a native iOS app with product listings, shopping cart, and checkout flow.',
      'portfolio': 'Your portfolio website has been transformed into a native iOS app with image galleries and project showcases.',
      'default': 'Your website has been successfully converted into a native iOS app with native navigation and optimized UI components.'
    };
    
    showResult(true, messages[websiteType] || messages.default);
  } else {
    const errorMessages = [
      'Unable to access the website. Please check the URL and try again.',
      'The website structure is too complex for automatic conversion. Try a simpler website.',
      'Network error occurred during analysis. Please try again later.',
      'The website requires authentication or has restricted access.'
    ];
    
    const randomError = errorMessages[Math.floor(Math.random() * errorMessages.length)];
    showResult(false, randomError);
  }
}

// Real-time preview update as user types
document.getElementById('urlInput').addEventListener('input', (e) => {
  const url = e.target.value;
  const appName = document.getElementById('appName').value;
  
  if (url.length > 10) {
    updateAppPreview(url, appName);
  } else {
    appPreview.innerHTML = `
      <div class="preview-placeholder">
        <i class="fas fa-mobile-alt"></i>
        <p>Enter a URL to see preview</p>
      </div>
    `;
  }
});

// App name change handler
document.getElementById('appName').addEventListener('input', (e) => {
  const url = document.getElementById('urlInput').value;
  const appName = e.target.value;
  
  if (url.length > 10) {
    updateAppPreview(url, appName);
  }
});

// Intersection Observer for animations
const observerOptions = {
  threshold: 0.1,
  rootMargin: '0px 0px -50px 0px'
};

const observer = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      entry.target.style.opacity = '1';
      entry.target.style.transform = 'translateY(0)';
    }
  });
}, observerOptions);

// Observe elements for animation
document.addEventListener('DOMContentLoaded', () => {
  const animatedElements = document.querySelectorAll('.feature-card, .gallery-item, .doc-card');
  
  animatedElements.forEach(el => {
    el.style.opacity = '0';
    el.style.transform = 'translateY(30px)';
    el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
    observer.observe(el);
  });
});

// Add some interactive features
document.addEventListener('DOMContentLoaded', () => {
  // Add hover effects to feature cards
  const featureCards = document.querySelectorAll('.feature-card');
  featureCards.forEach(card => {
    card.addEventListener('mouseenter', () => {
      card.style.transform = 'translateY(-10px) scale(1.02)';
    });
    
    card.addEventListener('mouseleave', () => {
      card.style.transform = 'translateY(0) scale(1)';
    });
  });
  
  // Add click effects to buttons
  const buttons = document.querySelectorAll('.btn');
  buttons.forEach(button => {
    button.addEventListener('click', (e) => {
      // Create ripple effect
      const ripple = document.createElement('span');
      const rect = button.getBoundingClientRect();
      const size = Math.max(rect.width, rect.height);
      const x = e.clientX - rect.left - size / 2;
      const y = e.clientY - rect.top - size / 2;
      
      ripple.style.width = ripple.style.height = size + 'px';
      ripple.style.left = x + 'px';
      ripple.style.top = y + 'px';
      ripple.classList.add('ripple');
      
      button.appendChild(ripple);
      
      setTimeout(() => {
        ripple.remove();
      }, 600);
    });
  });
});

// Add CSS for ripple effect
const style = document.createElement('style');
style.textContent = `
  .btn {
    position: relative;
    overflow: hidden;
  }
  
  .ripple {
    position: absolute;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.3);
    transform: scale(0);
    animation: ripple-animation 0.6s linear;
    pointer-events: none;
  }
  
  @keyframes ripple-animation {
    to {
      transform: scale(4);
      opacity: 0;
    }
  }
`;
document.head.appendChild(style);

// Add typing animation to hero title
document.addEventListener('DOMContentLoaded', () => {
  const titleElement = document.querySelector('.hero-title');
  const originalText = titleElement.innerHTML;
  
  // Split the text into parts
  const parts = originalText.split('<span class="gradient-text">Native iOS Apps</span>');
  
  if (parts.length === 2) {
    titleElement.innerHTML = parts[0];
    
    setTimeout(() => {
      const gradientSpan = document.createElement('span');
      gradientSpan.className = 'gradient-text';
      gradientSpan.textContent = 'Native iOS Apps';
      gradientSpan.style.opacity = '0';
      gradientSpan.style.transform = 'translateY(20px)';
      gradientSpan.style.transition = 'opacity 0.8s ease, transform 0.8s ease';
      
      titleElement.appendChild(gradientSpan);
      
      setTimeout(() => {
        gradientSpan.style.opacity = '1';
        gradientSpan.style.transform = 'translateY(0)';
      }, 100);
    }, 1000);
  }
});

// Add parallax effect to hero section
window.addEventListener('scroll', () => {
  const scrolled = window.pageYOffset;
  const hero = document.querySelector('.hero');
  const rate = scrolled * -0.5;
  
  if (hero) {
    hero.style.transform = `translateY(${rate}px)`;
  }
});

// Add counter animation for stats
function animateCounter(element, target, duration = 2000) {
  let start = 0;
  const increment = target / (duration / 16);
  
  function updateCounter() {
    start += increment;
    if (start < target) {
      element.textContent = Math.floor(start);
      requestAnimationFrame(updateCounter);
    } else {
      element.textContent = target;
    }
  }
  
  updateCounter();
}

// Animate stats when they come into view
const statsObserver = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      const statNumber = entry.target.querySelector('.stat-number');
      const text = statNumber.textContent;
      
      if (text === '100+') {
        animateCounter(statNumber, 100);
        statNumber.textContent = '100+';
      } else if (text === '2') {
        animateCounter(statNumber, 2);
      }
      
      statsObserver.unobserve(entry.target);
    }
  });
}, { threshold: 0.5 });

document.addEventListener('DOMContentLoaded', () => {
  const stats = document.querySelectorAll('.stat');
  stats.forEach(stat => {
    statsObserver.observe(stat);
  });
});