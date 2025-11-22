# TheSecretJuice Documentation Website

This is the official documentation website for TheSecretJuice - PowerShell steroids for CLI tools.

## 📁 Structure

```
docs/
├── index.html              # Homepage
├── modules.html            # Module browser
├── module.html             # Dynamic module detail page
├── installation.html       # Installation guide
├── contribute.html         # Contribution guidelines
├── changelog.html          # Version history and roadmap
├── assets/
│   ├── css/
│   │   ├── main.css       # Core styles and variables
│   │   ├── components.css # Component-specific styles
│   │   └── scrollbar.css  # Custom scrollbar
│   ├── js/
│   │   └── app.js         # Main application logic
│   └── data/
│       └── modules.json   # Module metadata
└── README.md              # This file
```

## 🎨 Design System

### Colors
- **Primary:** `#e91e63` (Pink)
- **Secondary:** `#00bcd4` (Cyan)
- **Accent:** `#ff4081` (Pink Accent)
- **Success:** `#10b981` (Green)
- **Warning:** `#f59e0b` (Orange)
- **Error:** `#ef4444` (Red)

### Components
- Glass effect panels with backdrop blur
- Gradient text for headings
- Interactive cards with hover effects
- Responsive grid layouts
- Custom scrollbars

## 🚀 Features

- **Dynamic Module Loading:** Modules loaded from JSON
- **Search Functionality:** Real-time search across modules, commands, and keywords
- **Responsive Design:** Works on mobile, tablet, and desktop
- **Dark Theme:** Optimized for developer experience
- **No Build Required:** Pure HTML/CSS/JS, ready for GitHub Pages

## 🛠️ Local Development

Simply open any HTML file in your browser:

```bash
# Open homepage
open index.html

# Or start a local server
python -m http.server 8000
# Then visit http://localhost:8000
```

## 📝 Adding New Modules

To add a new module to the documentation:

1. Update `assets/data/modules.json`:
   ```json
   {
     "name": "new-tool-enhance",
     "description": "Description of what it does",
     "path": "Steroids/new-tool-enhance.ps1",
     "category": "Category Name",
     "keywords": ["keyword1", "keyword2"],
     "icon": "fa-icon-name",
     "commands": ["command1", "command2"],
     "features": ["Feature 1", "Feature 2"]
   }
   ```

2. Create a markdown file: `new-tool-enhance.md`

3. Module will automatically appear on the website!

## 🌐 GitHub Pages Deployment

This site is designed for zero-config deployment to GitHub Pages:

1. Push to `main` branch
2. Enable GitHub Pages in repository settings
3. Set source to `/docs` folder
4. Done! Site will be live at `https://username.github.io/TheSecretJuice/`

## 🎯 Technologies Used

- **Tailwind CSS** - Utility-first CSS framework (CDN)
- **Font Awesome** - Icon library (CDN)
- **Vanilla JavaScript** - No frameworks, pure JS
- **Custom CSS** - Dark theme and glassmorphism effects

## 📄 License

MIT License - Same as the main project

## 🤝 Contributing

To improve the documentation:

1. Edit HTML/CSS/JS files
2. Update `modules.json` for module changes
3. Test locally before committing
4. Submit a PR with clear description

---

Built with ❤️ by [mini-page](https://github.com/mini-page)
