// Main Application JavaScript

// Global state
let modulesData = [];
let currentFilter = 'all';

// Load modules data
async function loadModules() {
  try {
    const response = await fetch('assets/data/modules.json');
    modulesData = await response.json();
    return modulesData;
  } catch (error) {
    console.error('Error loading modules:', error);
    return [];
  }
}

// Initialize app
document.addEventListener('DOMContentLoaded', async () => {
  await loadModules();
  initSearch();
  initMobileMenu();
  highlightCurrentPage();
});

// Search functionality
function initSearch() {
  const searchInput = document.getElementById('searchInput');
  if (!searchInput) return;

  searchInput.addEventListener('input', (e) => {
    const query = e.target.value.toLowerCase();
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

function createModuleCard(module) {
  return `
    <div class="module-card fade-in" onclick="navigateToModule('${module.name}')">
      <div class="module-icon">
        <i class="fas ${module.icon}"></i>
      </div>
      <h3 class="module-title">${module.name}</h3>
      <p class="module-description">${module.description}</p>
      <div class="module-meta">
        <span class="module-category">
          <i class="fas fa-tag"></i>
          ${module.category}
        </span>
        <span class="badge badge-outline" style="color: var(--secondary);">
          ${module.commands.length} commands
        </span>
      </div>
    </div>
  `;
}

function navigateToModule(moduleName) {
  window.location.href = `module.html?name=${encodeURIComponent(moduleName)}`;
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
