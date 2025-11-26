![Coverage](https://img.shields.io/badge/Coverage-66%25-brightgreen)
![Tests](https://img.shields.io/badge/Tests-Passing-success)

| Test Area          | Description                                                                 | Files                |
| ------------------ | --------------------------------------------------------------------------- | -------------------- |
| **Authentication** | Register and login validation                                               | `test_auth.py`       |
| **Products**       | Owner/Manager product CRUD, status toggle, RBAC                             | `test_products.py`   |
| **Cart**           | Add, update, remove cart items                                              | `test_cart.py`       |
| **Link Requests**  | Consumer-to-Owner linking, accept/reject logic                              | `test_links.py`      |
| **Orders**         | Checkout flow, order creation, stock handling                               | `test_orders.py`     |
| **Complaints**     | Create, escalate, resolve, supplier restrictions                            | `test_complaints.py` |
| **Chats**          | Chat room creation, sending messages, history                               | `test_chat.py`       |
| **RBAC**           | All negative access tests (sales, manager, consumer, supplier restrictions) | `test_rbac.py`       |


Full Coverage Report could be found here [htmlcov/index.html](htmlcov/index.html)

Firstly to run the project you need to install all plugins in requirements.txt. 
Then we need to run npm install to install the needed plugins for frontend part.
We need to run the command "python manage.py seed" to create demo data in database.
Then we open two terminals. One will start the backend part - server using command " python manage.py runserver", 
while in the second terminal we firstly write "cd frontend" and then "npm run dev".
You will see something like this: 
npm run dev                                                     

> nuprojectfront@0.0.0 dev
> vite


  VITE v7.2.1  ready in 320 ms

  ➜  Local:   http://localhost:5173/
  ➜  Network: use --host to expose
  ➜  press h + enter to show help
  
Using the link "http://localhost:5173/" we could open our website. Good luck!


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

## Available Scripts

- `npm run dev` - Start development server
- `npm test` - Run tests


## Testing

Tests are set up using Vitest and React Testing Library.

```bash
npm test

npm test -- --watch

npm run test:coverage


## I18n

The application supports English and Russian languages.

- Language switcher is available in the navbar

1. Add keys to `src/locales/en.json`
2. Add corresponding translations to `src/locales/ru.json`
3. Use `t()` function in components:
   ```jsx
   import { useTranslation } from 'react-i18next';
   
   const { t } = useTranslation();
   <h1>{t('common.welcome')}</h1>
   ```

## Tech Specifications

- **React 19**
- **React Router 7**
- **Vite**
- **i18next & react-i18next**
- **Vitest**
- **Tailwind CSS**
