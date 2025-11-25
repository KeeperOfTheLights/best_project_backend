# Daivinvhik Frontend

React-based frontend for the Daivinvhik B2B Supplier-Consumer Platform.

## 🚀 Quick Start (10 minutes or less)

### Prerequisites
- Node.js 18+ and npm
- Backend API running on `http://localhost:8000`

### Setup Steps

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Create environment file:**
   ```bash
   cp .env.example .env
   ```
   
   Update `.env` with your backend API URL:
   ```env
   VITE_API_BASE_URL=http://localhost:8000/api/accounts
   VITE_APP_NAME=Daivinvhik
   VITE_ENV=development
   ```

3. **Start development server:**
   ```bash
   npm run dev
   ```
   
   The app will open at `http://localhost:5173`

## 📦 Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build
- `npm run lint` - Run ESLint
- `npm test` - Run tests
- `npm run test:ui` - Run tests with UI
- `npm run test:coverage` - Run tests with coverage report

## 🧪 Testing

Tests are set up using Vitest and React Testing Library.

```bash
# Run tests once
npm test

# Run tests in watch mode
npm test -- --watch

# Run tests with coverage
npm run test:coverage
```

## 🐳 Docker

### Development
```bash
docker build -f Dockerfile.dev -t daivinvhik-frontend-dev .
docker run -p 5173:5173 daivinvhik-frontend-dev
```

### Production
```bash
docker build -t daivinvhik-frontend .
docker run -p 80:80 daivinvhik-frontend
```

## 🌍 Internationalization (i18n)

The application supports English (EN) and Russian (RU) languages.

- Language switcher is available in the navbar
- All UI text is translatable
- Language preference is saved in localStorage

### Adding New Translations

1. Add keys to `src/locales/en.json`
2. Add corresponding translations to `src/locales/ru.json`
3. Use `t()` function in components:
   ```jsx
   import { useTranslation } from 'react-i18next';
   
   const { t } = useTranslation();
   <h1>{t('common.welcome')}</h1>
   ```

## 🏗️ Project Structure

```
frontend/
├── src/
│   ├── components/      # Reusable components
│   │   ├── common/      # Common components (Navbar, Modal, etc.)
│   │   └── __tests__/   # Component tests
│   ├── pages/           # Page components
│   │   ├── Consumer/    # Consumer-specific pages
│   │   ├── Supplier/     # Supplier-specific pages
│   │   └── Shared/      # Shared pages (Login, Chat, etc.)
│   ├── context/         # React Context providers
│   ├── locales/         # Translation files (en.json, ru.json)
│   ├── utils/           # Utility functions
│   └── test/            # Test setup files
├── public/              # Static assets
├── Dockerfile           # Production Docker image
├── Dockerfile.dev       # Development Docker image
└── vitest.config.js     # Test configuration
```

## 🔧 Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `VITE_API_BASE_URL` | Backend API base URL | `http://localhost:8000/api/accounts` |
| `VITE_APP_NAME` | Application name | `Daivinvhik` |
| `VITE_ENV` | Environment (development/production) | `development` |

## 📱 Features

- **Authentication**: Login/Signup with role-based access
- **Role-Based Access Control**: Consumer, Owner, Manager, Sales roles
- **Order Management**: Create, view, and manage orders
- **Product Catalog**: Browse and manage products
- **Chat System**: Real-time messaging between suppliers and consumers
- **Complaints Management**: File and manage complaints
- **Company Management**: Manage company employees (Owner only)
- **Search**: Search for suppliers, products, and categories
- **Internationalization**: English and Russian support

## 🛠️ Tech Stack

- **React 19** - UI library
- **React Router 7** - Routing
- **Vite** - Build tool
- **i18next & react-i18next** - Internationalization
- **Vitest** - Testing framework
- **React Testing Library** - Component testing
- **Tailwind CSS** - Styling

## 🚢 Production Build

1. **Build the application:**
   ```bash
   npm run build
   ```
   
   This creates an optimized production build in the `dist/` directory.

2. **Preview the build:**
   ```bash
   npm run preview
   ```

3. **Deploy:**
   - The `dist/` folder contains all static files
   - Serve with any static file server (nginx, Apache, etc.)
   - Or use the provided Dockerfile for containerized deployment

## 🔍 Development Workflow

1. Create feature branch
2. Make changes
3. Write/update tests
4. Run tests: `npm test`
5. Run linter: `npm run lint`
6. Build to verify: `npm run build`
7. Commit and push

## 📝 Notes

- API calls are made to `http://127.0.0.1:8000/api/accounts` by default
- Language preference is persisted in `localStorage` under key `i18nextLng`
- All routes are protected with role-based access control

## 🤝 Contributing

1. Follow the existing code style
2. Write tests for new features
3. Update translations for new UI text
4. Run linter before committing

## 📄 License

[Your License Here]
