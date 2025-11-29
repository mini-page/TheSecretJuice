// Security & Input Sanitization Module

// XSS Protection - Sanitize HTML input
function sanitizeHTML(str) {
  const temp = document.createElement('div');
  temp.textContent = str;
  return temp.innerHTML;
}

// Sanitize for use in HTML attributes
function sanitizeAttribute(str) {
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#x27;')
    .replace(/\//g, '&#x2F;');
}

// Sanitize URL to prevent javascript: and data: XSS
function sanitizeURL(url) {
  const sanitized = String(url).trim();
  
  // Block dangerous protocols
  const dangerousProtocols = /^(javascript|data|vbscript|file|about):/i;
  if (dangerousProtocols.test(sanitized)) {
    return '#';
  }
  
  // Only allow http, https, mailto, and relative URLs
  if (!/^(https?:\/\/|mailto:|\/|\.\/|#)/.test(sanitized)) {
    return '#';
  }
  
  return sanitized;
}

// SQL Injection Prevention - Validate search input
function validateSearchInput(input) {
  const sanitized = String(input).trim();
  
  // Block SQL keywords
  const sqlPattern = /(SELECT|INSERT|UPDATE|DELETE|DROP|CREATE|ALTER|EXEC|EXECUTE|UNION|SCRIPT|javascript:|<script)/gi;
  if (sqlPattern.test(sanitized)) {
    console.warn('Potentially malicious input detected and blocked');
    return '';
  }
  
  // Remove dangerous characters
  return sanitized
    .replace(/[<>]/g, '')
    .replace(/javascript:/gi, '')
    .replace(/on\w+\s*=/gi, '');
}

// Validate JSON data
function isValidJSON(str) {
  try {
    JSON.parse(str);
    return true;
  } catch (e) {
    return false;
  }
}

// Rate limiting for search to prevent abuse
const rateLimiter = {
  requests: [],
  maxRequests: 50,
  timeWindow: 60000, // 1 minute
  
  canMakeRequest() {
    const now = Date.now();
    
    // Remove old requests outside time window
    this.requests = this.requests.filter(time => now - time < this.timeWindow);
    
    // Check if under limit
    if (this.requests.length >= this.maxRequests) {
      console.warn('Rate limit exceeded');
      return false;
    }
    
    // Add current request
    this.requests.push(now);
    return true;
  }
};

// Export functions for use in other scripts
if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    sanitizeHTML,
    sanitizeAttribute,
    sanitizeURL,
    validateSearchInput,
    isValidJSON,
    rateLimiter
  };
}
