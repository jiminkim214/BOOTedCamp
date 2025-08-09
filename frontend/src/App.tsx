import React, { useState, useEffect } from 'react';
import { LoginForm } from './components/auth/LoginForm';
import { SignupForm } from './components/auth/SignupForm';
import { Dashboard } from './components/dashboard/Dashboard';
import { LandingPage } from './components/landing/LandingPage';
import { apiService } from './services/api';
import './index.css';

type AuthView = 'landing' | 'login' | 'signup';

const App: React.FC = () => {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [currentUser, setCurrentUser] = useState<string | null>(null);
  const [authView, setAuthView] = useState<AuthView>('landing');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Check if user is already logged in
    const user = apiService.getCurrentUser();
    if (user) {
      setCurrentUser(user);
      setIsAuthenticated(true);
    }
    setLoading(false);
  }, []);

  const handleLoginSuccess = (username: string) => {
    setCurrentUser(username);
    setIsAuthenticated(true);
  };

  const handleSignupSuccess = (username: string) => {
    setCurrentUser(username);
    setIsAuthenticated(true);
  };

  const handleLogout = () => {
    apiService.logout();
    setCurrentUser(null);
    setIsAuthenticated(false);
    setAuthView('landing');
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
      </div>
    );
  }

  if (isAuthenticated && currentUser) {
    return <Dashboard username={currentUser} onLogout={handleLogout} />;
  }

  if (authView === 'landing') {
    return <LandingPage onGetStarted={() => setAuthView('login')} />;
  }

  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
      <div className="w-full max-w-md">
        {/* Header */}
        <div className="text-center mb-8">
          <h1 className="text-4xl font-bold text-primary-600 mb-2">BOOTedCamp</h1>
          <p className="text-gray-600">Master micro-skills one achievement at a time</p>
        </div>

        {/* Auth Forms */}
        {authView === 'login' ? (
          <LoginForm
            onLoginSuccess={handleLoginSuccess}
            onSwitchToSignup={() => setAuthView('signup')}
            onBackToHome={() => setAuthView('landing')}
          />
        ) : (
          <SignupForm
            onSignupSuccess={handleSignupSuccess}
            onSwitchToLogin={() => setAuthView('login')}
            onBackToHome={() => setAuthView('landing')}
          />
        )}

        {/* Footer */}
        <div className="mt-8 text-center">
          <p className="text-xs text-gray-500">
            © 2024 BOOTedCamp. Learn practical skills in minutes, not hours.
          </p>
        </div>
      </div>
    </div>
  );
};

export default App;
