# Daivinvhik Frontend

React-based frontend for the Daivinvhik Supplier Consumer Platform.

## Setup

1. Install dependencies:
```bash
npm install
```

2. Create `.env` file:
```bash
cp .env.example .env
```

3. Update `.env` with your backend API URL:
```
REACT_APP_API_URL=http://localhost:8000/api
```

4. Start development server:
```bash
npm start
```

App will open at http://localhost:3000

## Build for Production
```bash
npm run build
```

## Tech Stack

- React 18
- React Router
- Axios
- Tailwind CSS (or your CSS framework)