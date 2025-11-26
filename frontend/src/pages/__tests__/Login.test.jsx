import { describe, it, expect, vi } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { BrowserRouter } from 'react-router-dom';
import Login from '../Shared/Login';
import { AuthProvider } from '../../context/Auth-Context';

// Test for login page. Most crucial one in my opinion. To check if the roles that were set to signed users are right saved.

global.fetch = vi.fn();

const MockLogin = () => (
  <BrowserRouter>
    <AuthProvider>
      <Login />
    </AuthProvider>
  </BrowserRouter>
);

describe('Login', () => {
  beforeEach(() => {
    fetch.mockClear();
  });

  it('renders login form', () => {
    render(<MockLogin />);
    expect(screen.getByPlaceholderText(/email|auth\.emailAddress/i)).toBeInTheDocument();
    expect(screen.getByPlaceholderText(/password|auth\.password/i)).toBeInTheDocument();
    const button = screen.getByRole('button');
    expect(button).toBeInTheDocument();
  });

  it('shows error message on failed login', async () => {
    fetch.mockResolvedValueOnce({
      ok: false,
      json: async () => ({ detail: 'Invalid credentials' }),
    });

    render(<MockLogin />);
    
    const emailInput = screen.getByPlaceholderText(/email|auth\.emailAddress/i);
    const passwordInput = screen.getByPlaceholderText(/password|auth\.password/i);
    const submitButton = screen.getByRole('button');

    fireEvent.change(emailInput, { target: { value: 'test@example.com' } });
    fireEvent.change(passwordInput, { target: { value: 'wrongpassword' } });
    fireEvent.click(submitButton);

    await waitFor(() => {
      expect(screen.getByText(/invalid/i)).toBeInTheDocument();
    });
  });
});

