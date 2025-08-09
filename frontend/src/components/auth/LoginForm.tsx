import React, { useState } from 'react';
import { apiService } from '../../services/api';
import { Button } from '../ui/Button';

interface LoginFormProps {
  onLoginSuccess: (username: string) => void;
  onSwitchToSignup: () => void;
  onBackToHome?: () => void;
}

export const LoginForm: React.FC<LoginFormProps> = ({ onLoginSuccess, onSwitchToSignup, onBackToHome }) => {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      const result = await apiService.login(username, password);
      if (result.success) {
        onLoginSuccess(username);
      } else {
        setError('Invalid username or password');
      }
    } catch (err) {
      setError('An error occurred. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="max-w-md mx-auto bg-white rounded-lg shadow-md p-6">
      {/* Back button */}
      {onBackToHome && (
        <div className="mb-4">
          <button
            onClick={onBackToHome}
            className="text-sm text-gray-600 hover:text-gray-800 flex items-center"
          >
            ← Back to Home
          </button>
        </div>
      )}
      
      <h2 className="text-2xl font-bold text-center mb-6 text-gray-800">Welcome Back</h2>
      
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label htmlFor="username" className="block text-sm font-medium text-gray-700 mb-2">
            Username
          </label>
          <input
            id="username"
            type="text"
            value={username}
            onChange={(e) => setUsername(e.target.value)}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent"
            required
          />
        </div>

        <div>
          <label htmlFor="password" className="block text-sm font-medium text-gray-700 mb-2">
            Password
          </label>
          <input
            id="password"
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent"
            required
          />
        </div>

        {error && (
          <div className="text-red-600 text-sm">{error}</div>
        )}

        <Button
          type="submit"
          variant="primary"
          loading={loading}
          className="w-full"
        >
          {loading ? 'Signing In...' : 'Sign In'}
        </Button>
      </form>

      <div className="mt-6 text-center">
        <p className="text-sm text-gray-600">
          Don't have an account?{' '}
          <button
            onClick={onSwitchToSignup}
            className="text-primary-600 hover:text-primary-500 font-medium"
          >
            Sign up
          </button>
        </p>
      </div>

      <div className="mt-4 text-center">
        <p className="text-xs text-gray-500">
          Demo credentials: username: "demo", password: "demo"
        </p>
      </div>
    </div>
  );
};
