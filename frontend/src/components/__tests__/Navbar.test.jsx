import { describe, it, expect, vi } from 'vitest';
import { render, screen } from '@testing-library/react';
import { BrowserRouter } from 'react-router-dom';
import Navbar from '../common/Navbar';
import { AuthProvider } from '../../context/Auth-Context';

const MockNavbar = () => (
  <BrowserRouter>
    <AuthProvider>
      <Navbar />
    </AuthProvider>
  </BrowserRouter>
);

describe('Navbar', () => {
  it('renders without crashing', () => {
    render(<MockNavbar />);
    expect(screen.getByRole('navigation')).toBeInTheDocument();
  });

  it('renders language switcher', () => {
    render(<MockNavbar />);
    const languageSwitcher = screen.getByText(/ENG|РУС/i);
    expect(languageSwitcher).toBeInTheDocument();
  });
});

