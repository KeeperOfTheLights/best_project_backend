import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../providers/language_provider.dart';

/// Very lightweight localization helper.
/// We use the English text as the key and provide Russian translations here.
class AppLocalizations {
  AppLocalizations(this._languageCode);

  final String _languageCode;

  static AppLocalizations of(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context, listen: true);
    return AppLocalizations(lang.languageCode);
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'ru': {
      // Login
      'Welcome Back': 'С возвращением',
      'Log in to continue': 'Войдите, чтобы продолжить',
      'Email Address': 'Электронная почта',
      'Please enter your email': 'Пожалуйста, введите электронную почту',
      'Please enter a valid email': 'Пожалуйста, введите корректный адрес',
      'Password': 'Пароль',
      'Please enter your password': 'Пожалуйста, введите пароль',
      'Log In': 'Войти',
      "Don't have an account yet? ": 'Еще нет аккаунта? ',
      'Sign Up': 'Зарегистрироваться',
      'Login failed': 'Ошибка входа',

      // Signup
      'Create an Account': 'Создать аккаунт',
      'Join Daivinvhik today': 'Присоединяйтесь к Daivinvhik уже сегодня',
      'Full Name': 'Полное имя',
      'Enter your full name': 'Введите полное имя',
      'Please enter your full name': 'Пожалуйста, введите полное имя',
      'Username': 'Имя пользователя',
      'Enter your username': 'Введите имя пользователя',
      'Please enter a username': 'Пожалуйста, введите имя пользователя',
      'Enter your email': 'Введите электронную почту',
      'Please enter a password': 'Пожалуйста, введите пароль',
      'Repeat Password': 'Повторите пароль',
      'Re-enter your password': 'Введите пароль еще раз',
      'Please confirm your password': 'Пожалуйста, подтвердите пароль',
      'Select your role:': 'Выберите вашу роль:',
      'Consumer': 'Покупатель',
      'Owner': 'Владелец',
      'Manager': 'Менеджер',
      'Sales Rep': 'Менеджер по продажам',
      'Do you have an account? ': 'Уже есть аккаунт? ',
      'Login': 'Войти',
      'Passwords do not match!': 'Пароли не совпадают!',
      'Password is too short (minimum 6 characters)':
          'Пароль слишком короткий (минимум 6 символов)',
      'Password must contain at least one uppercase letter':
          'Пароль должен содержать хотя бы одну заглавную букву',
      'Password must contain at least one number':
          'Пароль должен содержать хотя бы одну цифру',
      'Password must contain at least one special character':
          'Пароль должен содержать хотя бы один спецсимвол',
      'Signup failed': 'Ошибка регистрации',

      // Consumer dashboard
      'Welcome back!': 'С возвращением!',
      "Here's an overview of your order activity.":
          'Краткий обзор вашей активности по заказам.',
      'Completed Orders': 'Завершенные заказы',
      'Orders in Process': 'Заказы в процессе',
      'Cancelled Orders': 'Отмененные заказы',
      'Total Expenses': 'Общие расходы',
      'Quick Actions': 'Быстрые действия',
      'Catalog': 'Каталог',
      'My Orders': 'Мои заказы',
      'Search': 'Поиск',
      'Chat': 'Чат',
      'My Complaints': 'Мои жалобы',
      'Sign Out': 'Выход',

      // Supplier dashboard and stats
      'Hello, Owner!': 'Здравствуйте, владелец!',
      'Hello, Manager!': 'Здравствуйте, менеджер!',
      'Hello, Sales Representative!': 'Здравствуйте, менеджер по продажам!',
      "Manage your communications and handle customer inquiries.":
          'Управляйте коммуникациями и обрабатывайте запросы клиентов.',
      "Here's an overview of your performance and current activity.":
          'Краткий обзор вашей эффективности и текущей активности.',
      'Active Orders': 'Активные заказы',
      'Pending Deliveries': 'Ожидаемые доставки',
      'Total Revenue': 'Общая выручка',
      'My Catalog': 'Мой каталог',
      'Products': 'Товары',
      'Order Management': 'Управление заказами',
      'Company Management': 'Управление компанией',
      'Chats': 'Чаты',
      'Complaints': 'Жалобы',

      // Cart
      'Shopping Cart': 'Корзина',
      'Your cart is empty': 'Ваша корзина пуста',
      'Total:': 'Итого:',
      'Proceed to Checkout': 'Перейти к оформлению',

      // Link requests
      'Link Requests': 'Запросы на связь',
      'My Catalog': 'Мой каталог',
      'Access Denied': 'Доступ запрещен',
      'Only Owners and Managers can view link requests.':
          'Только владельцы и менеджеры могут просматривать запросы на связь.',
      'Go to Dashboard': 'Перейти на панель',
      'Consumer Link Requests': 'Запросы потребителей на связь',
      'Manage consumer connections and access':
          'Управляйте связями с потребителями и их доступом',
      'Pending Requests': 'Ожидающие запросы',
      'Linked Consumers': 'Связанные потребители',
      'Rejected': 'Отклоненные',
      'Blocked': 'Заблокированные',
      'No requests found': 'Запросы не найдены',

      // Company management
      'Company Management': 'Управление компанией',
      'Only owners can access Company Management':
          'Только владельцы могут получать доступ к управлению компанией',
      'Current Employees': 'Текущие сотрудники',
      'No employees assigned to your company yet.':
          'К вашей компании пока не привязаны сотрудники.',
      'Available to Assign': 'Доступны для назначения',
      'Managers and Sales Representatives who are not yet assigned to any company.':
          'Менеджеры и представители по продажам, которые еще не прикреплены ни к одной компании.',
      'No unassigned users available.':
          'Нет пользователей, доступных для назначения.',
      'Assign to Company': 'Назначить',
      'Remove': 'Удалить',
      'Refresh': 'Обновить',

      // Catalog / products
      'Product Catalog': 'Каталог товаров',
      'Add New Product': 'Добавить',
      'No products yet': 'Пока нет товаров',
      'Add your first product to get started':
          'Добавьте первый товар, чтобы начать работу',

      // Orders / order management
      'My Orders': 'Мои заказы',
      'Order Management': 'Управление заказами',
      'Pending Orders': 'Ожидающие заказы',
      'Processing': 'В обработке',
      'Completed': 'Завершенные',
      'Total Orders': 'Всего заказов',
      'Approved': 'Одобрено',
      'Delivered': 'Доставленные',
      'Total Revenue': 'Общая выручка',
      "You haven't placed any orders yet.":
          'Вы еще не оформляли заказы.',
      'No orders found.': 'Заказы не найдены.',

      // Messages / chat
      'Messages': 'Сообщения',
      'Search conversations...': 'Поиск бесед...',
      'Retry': 'Повторить',
      'No chats yet': 'Пока нет чатов',
      'Start chatting with your linked suppliers':
          'Начните переписку с вашими связанными поставщиками',
      'Start chatting with your linked consumers':
          'Начните переписку с вашими связанными покупателями',

      // Complaints management
      'Complaints Management': 'Управление жалобами',
      'Handle customer complaints and escalate when manager review is needed.':
          'Обрабатывайте жалобы клиентов и передавайте их на рассмотрение менеджеру при необходимости.',
      'Review escalated complaints and manage order-related issues.':
          'Просматривайте эскалированные жалобы и управляйте проблемами, связанными с заказами.',
      'Refresh': 'Обновить',
      'Pending': 'В ожидании',
      'Resolved': 'Решенные',
      'Escalated': 'Эскалированные',
      'No complaints found for this status.':
          'Для данного статуса жалобы не найдены.',

      // Generic filter labels
      'All': 'Все',
      'Linked': 'Связанные',

      // Generic / other
      'Loading...': 'Загрузка...',
      'Error': 'Ошибка',

      // Language switcher labels
      'ENG': 'АНГ',
      'English': 'Английский',
      'RU': 'РУ',
      'Russian': 'Русский',

      // Supplier Connections screen
      'Supplier Connections': 'Связи с поставщиками',
      'Manage your supplier relationships': 'Управляйте связями с поставщиками',
      'Linked': 'Связанные',
      'Pending': 'В ожидании',
      'Available': 'Доступные',
      'not linked': 'не связаны',
      'rejected': 'отклонено',
      'No suppliers found': 'Поставщики не найдены',
      'Send Link Request': 'Отправить запрос на связь',
      'View Catalog': 'Посмотреть каталог',
      'Link request sent successfully': 'Запрос на связь успешно отправлен',
      'Failed to send link request: ': 'Не удалось отправить запрос на связь: ',

      // Search screen
      'Search suppliers, products...': 'Поиск поставщиков, товаров...',
      'Please enter a search query': 'Пожалуйста, введите поисковый запрос',
      'No Linked Suppliers': 'Нет связанных поставщиков',
      'You need to have at least one accepted link request to search for products and suppliers.': 'Вам нужно иметь хотя бы один принятый запрос на связь для поиска товаров и поставщиков.',
      'Search for products and suppliers': 'Поиск товаров и поставщиков',
      'No results found': 'Результаты не найдены',
      'Suppliers (': 'Поставщики (',
      'Categories (': 'Категории (',
      'Products (': 'Товары (',
      'No email': 'Нет электронной почты',
      'by ': 'от ',
      'Supplier': 'Поставщик',
      'Could not find supplier for this product. Supplier: ': 'Не удалось найти поставщика для этого товара. Поставщик: ',
      'Unknown': 'Неизвестно',

      // My Complaints screen
      'New Complaint': 'Новая жалоба',
      'Cancel': 'Отмена',
      'Submit a New Complaint': 'Подать новую жалобу',
      'Select Order': 'Выберите заказ',
      '-- Select an order --': '-- Выберите заказ --',
      'Please select an order': 'Пожалуйста, выберите заказ',
      'Complaint Title': 'Заголовок жалобы',
      'e.g., Late delivery, Wrong product, etc.': 'Например, Поздняя доставка, Неправильный товар и т.д.',
      'Please enter a complaint title': 'Пожалуйста, введите заголовок жалобы',
      'Description': 'Описание',
      'Describe your complaint in detail...': 'Опишите вашу жалобу подробно...',
      'Please enter a description': 'Пожалуйста, введите описание',
      'Submit Complaint': 'Подать жалобу',
      'Complaint submitted successfully': 'Жалоба успешно подана',
      'Failed to submit complaint': 'Не удалось подать жалобу',
      'Create a complaint by clicking "New Complaint" above.': 'Создайте жалобу, нажав "Новая жалоба" выше.',
      'Open Chat': 'Открыть чат',
      'Type: ': 'Тип: ',
      'Requested: ': 'Запрошено: ',
      'Reason: ': 'Причина: ',
      'Created: ': 'Создано: ',

      // Consumer Catalog screen
      "'s Catalog": ' каталог',
      'No products available in this catalog': 'В этом каталоге нет доступных товаров',
      'Stock: ': 'Наличие: ',
      'Min Order: ': 'Мин. заказ: ',
      'Pickup': 'Самовывоз',
      'Pickup/Delivery': 'Самовывоз/Доставка',
      'Out of Stock': 'Нет в наличии',
      'Add to Cart': 'Добавить в корзину',
      'In Cart: ': 'В корзине: ',
      'Cart (': 'Корзина (',
      ' items)': ' товаров)',
      'No items from this supplier yet.': 'Пока нет товаров от этого поставщика.',
      'Total:': 'Итого:',
      'Proceed to Checkout': 'Перейти к оформлению',
      'Cart is empty': 'Корзина пуста',
      'Order #': 'Заказ №',
      ' placed successfully.': ' успешно размещен.',
      'Added ': 'Добавлено ',
      ' of ': ' ',
      ' to cart.': ' в корзину.',
      'Order ID': 'ID заказа',
      'name not available': 'название недоступно',
    },
  };

  String text(String key) {
    if (_languageCode == 'en') return key;
    return _localizedValues[_languageCode]?[key] ?? key;
  }
}


