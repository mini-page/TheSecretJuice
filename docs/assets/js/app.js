// Main Application JavaScript

// Global state
let modulesData = [];
let currentFilter = 'all';

// Load modules data
async function loadModules() {
  try {
    // Try relative path first, then absolute from root
    let response;
    try {
      response = await fetch('assets/data/modules.json');
    } catch (e) {
      response = await fetch('/assets/data/modules.json');
    }
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    modulesData = await response.json();
    console.log('Modules loaded successfully:', modulesData.length);
    return modulesData;
  } catch (error) {
    console.error('Error loading modules:', error);
    // Try to show user-friendly error
    const container = document.getElementById('modulesContainer');
    if (container) {
      container.innerHTML = `
        <div style="grid-column: 1 / -1; padding: 4rem; text-align: center;">
          <i class="fas fa-exclamation-circle" style="font-size: 3rem; color: var(--error); margin-bottom: 1rem;"></i>
          <h3 style="color: var(--text);">Failed to Load Modules</h3>
          <p style="color: var(--text-dim); margin: 1rem 0;">Error: ${error.message}</p>
          <p style="color: var(--text-dimmer);">Please check the browser console for details.</p>
        </div>
      `;
    }
    return [];
  }
}

// Initialize app
document.addEventListener('DOMContentLoaded', async () => {
  // Show loading indicator
  const modulesContainer = document.getElementById('modulesContainer');
  if (modulesContainer) {
    modulesContainer.innerHTML = `
      <div style="grid-column: 1 / -1; padding: 4rem; text-align: center;">
        <i class="fas fa-spinner fa-spin" style="font-size: 3rem; color: var(--primary); margin-bottom: 1rem;"></i>
        <h3 style="color: var(--text);">Loading modules...</h3>
      </div>
    `;
  }
  
  // Load modules
  await loadModules();
  
  // Auto-display modules if on modules page
  if (modulesContainer && modulesData.length > 0) {
    console.log('Displaying modules:', modulesData.length);
    displayModules(modulesData);
  } else if (modulesContainer && modulesData.length === 0) {
    console.error('No modules data loaded!');
  }
  
  initSearch();
  initMobileMenu();
  highlightCurrentPage();
});

// Search functionality
function initSearch() {
  const searchInput = document.getElementById('searchInput');
  if (!searchInput) return;

  searchInput.addEventListener('input', (e) => {
    // Rate limiting check
    if (typeof rateLimiter !== 'undefined' && !rateLimiter.canMakeRequest()) {
      return;
    }
    
    // Sanitize and validate input
    const rawQuery = e.target.value;
    const query = typeof validateSearchInput !== 'undefined' 
      ? validateSearchInput(rawQuery).toLowerCase()
      : rawQuery.toLowerCase().replace(/[<>]/g, '');
    
    searchModules(query);
  });
}

function searchModules(query) {
  if (!query) {
    displayAllModules();
    return;
  }

  const filtered = modulesData.filter(module => {
    return (
      module.name.toLowerCase().includes(query) ||
      module.description.toLowerCase().includes(query) ||
      module.keywords.some(keyword => keyword.toLowerCase().includes(query)) ||
      module.commands.some(cmd => cmd.toLowerCase().includes(query))
    );
  });

  displayModules(filtered);
}

function displayModules(modules) {
  const container = document.getElementById('modulesContainer');
  if (!container) return;

  if (modules.length === 0) {
    container.innerHTML = `
      <div class="text-center" style="grid-column: 1 / -1; padding: 4rem;">
        <i class="fas fa-search" style="font-size: 3rem; color: var(--text-dimmer); margin-bottom: 1rem;"></i>
        <h3 style="color: var(--text-dim);">No modules found</h3>
        <p style="color: var(--text-dimmer);">Try different search terms</p>
      </div>
    `;
    return;
  }

  container.innerHTML = modules.map(module => createModuleCard(module)).join('');
}

function displayAllModules() {
  displayModules(modulesData);
}

function navigateToModule(moduleName, isPack = false) {
  // Sanitize module name before navigation
  const safeName = typeof sanitizeAttribute !== 'undefined'
    ? sanitizeAttribute(moduleName)
    : moduleName.replace(/['"<>&]/g, '');
  const typeParam = isPack ? '&type=pack' : '&type=module';
  window.location.href = `module.html?name=${encodeURIComponent(safeName)}${typeParam}`;
}

function createModuleCard(module) {
  const isPack = module.isPack === true;
  // Sanitize all user-facing content
  const safeName = typeof sanitizeHTML !== 'undefined' 
    ? sanitizeHTML(module.name)
    : module.name.replace(/[<>]/g, '');
  const safeDescription = typeof sanitizeHTML !== 'undefined'
    ? sanitizeHTML(module.description)
    : module.description.replace(/[<>]/g, '');
  const safeCategory = typeof sanitizeHTML !== 'undefined'
    ? sanitizeHTML(module.category)
    : module.category.replace(/[<>]/g, '');
  const safeIcon = typeof sanitizeAttribute !== 'undefined'
    ? sanitizeAttribute(module.icon)
    : module.icon.replace(/['"<>]/g, '');
    
  const cmdCount = isPack 
    ? module.modules.reduce((sum, m) => sum + (m.commands ? m.commands.length : 0), 0)
    : (module.commands ? module.commands.length : 0);

  return `
    <div class="module-card fade-in ${isPack ? 'pack-card' : ''}" onclick="navigateToModule('${safeName}', ${isPack})">
      <div class="module-icon">
        <i class="fas ${safeIcon}"></i>
      </div>
      <h3 class="module-title">${safeName}${isPack ? ' <span class="badge-pack">Pack</span>' : ''}</h3>
      <p class="module-description">${safeDescription}</p>
      <div class="module-meta">
        <span class="module-category">
          <i class="fas fa-tag"></i>
          ${safeCategory}
        </span>
        <span class="badge badge-outline" style="color: var(--secondary);">
          ${cmdCount} commands
        </span>
      </div>
    </div>
  `;
}

// Mobile menu toggle
function initMobileMenu() {
  const menuToggle = document.getElementById('mobileMenuToggle');
  const sidebar = document.getElementById('sidebar');

  if (menuToggle && sidebar) {
    menuToggle.addEventListener('click', () => {
      sidebar.classList.toggle('open');
    });
  }
}

// Highlight current page in navigation
function highlightCurrentPage() {
  const currentPath = window.location.pathname.split('/').pop() || 'index.html';
  const navLinks = document.querySelectorAll('.navbar-nav a, .sidebar-link');

  navLinks.forEach(link => {
    const href = link.getAttribute('href');
    if (href === currentPath || (currentPath === '' && href === 'index.html')) {
      link.classList.add('active');
    }
  });
}

// Copy code to clipboard
function copyCode(button) {
  const codeBlock = button.parentElement.querySelector('code');
  const text = codeBlock.textContent;

  navigator.clipboard.writeText(text).then(() => {
    const originalText = button.innerHTML;
    button.innerHTML = '<i class="fas fa-check"></i> Copied!';
    button.style.background = 'var(--success)';

    setTimeout(() => {
      button.innerHTML = originalText;
      button.style.background = '';
    }, 2000);
  });
}

// Smooth scroll for anchor links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
  anchor.addEventListener('click', function (e) {
    e.preventDefault();
    const target = document.querySelector(this.getAttribute('href'));
    if (target) {
      target.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
  });
});
