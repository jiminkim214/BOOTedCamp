import React, { useState, useEffect } from 'react';
import { Play, Star, TrendingUp, Award, ChevronDown } from 'lucide-react';
import { Button } from '../ui/Button';

interface LandingPageProps {
  onGetStarted: () => void;
}

export const LandingPage: React.FC<LandingPageProps> = ({ onGetStarted }) => {
  const [isVisible, setIsVisible] = useState({
    hero: false,
    categories: false,
    skills: false,
    cta: false
  });
  const [scrollProgress, setScrollProgress] = useState(0);

  useEffect(() => {
    const handleScroll = () => {
      const scrollTop = window.scrollY;
      const docHeight = document.documentElement.scrollHeight - window.innerHeight;
      const scrollPercent = scrollTop / docHeight;
      setScrollProgress(scrollPercent);

      // Trigger animations based on scroll position
      const heroSection = document.getElementById('hero');
      const categoriesSection = document.getElementById('categories');
      const skillsSection = document.getElementById('skills');
      const ctaSection = document.getElementById('cta');

      const checkVisibility = (element: HTMLElement | null, key: keyof typeof isVisible) => {
        if (element) {
          const rect = element.getBoundingClientRect();
          const isInView = rect.top < window.innerHeight * 0.8;
          setIsVisible(prev => ({ ...prev, [key]: isInView }));
        }
      };

      checkVisibility(heroSection, 'hero');
      checkVisibility(categoriesSection, 'categories');
      checkVisibility(skillsSection, 'skills');
      checkVisibility(ctaSection, 'cta');
    };

    // Initial check
    handleScroll();
    
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  const scrollToSection = (sectionId: string) => {
    const element = document.getElementById(sectionId);
    element?.scrollIntoView({ behavior: 'smooth' });
  };
  const featuredSkills = [
    {
      title: "Pasta Making from Scratch",
      category: "Cooking",
      instructor: "BOOTedCamp Team",
      rating: 4.0,
      students: "3",
      image: "🍝",
      duration: "15 min"
    },
    {
      title: "Fresh Garden Salad",
      category: "Cooking", 
      instructor: "BOOTedCamp Team",
      rating: 0,
      students: "5",
      image: "🥗",
      duration: "10 min"
    },
    {
      title: "Basic Yoga Practice",
      category: "Exercise",
      instructor: "BOOTedCamp Team",
      rating: 3.7,
      students: "3", 
      image: "🧘‍♀️",
      duration: "20 min"
    },
    {
      title: "Swimming Fundamentals",
      category: "Exercise",
      instructor: "BOOTedCamp Team",
      rating: 2.0,
      students: "1",
      image: "🏊",
      duration: "25 min"
    }
  ];

  const categories = [
    { name: "Cooking", icon: "🍳", count: "2 skills" },
    { name: "Exercise", icon: "💪", count: "2 skills" },
    { name: "Technology", icon: "💻", count: "Coming Soon" },
    { name: "Creative", icon: "🎨", count: "Coming Soon" },
    { name: "DIY", icon: "🔧", count: "Coming Soon" },
    { name: "Business", icon: "📊", count: "Coming Soon" }
  ];

  return (
    <div className="min-h-screen bg-white">
      {/* Scroll Progress Bar */}
      <div className="fixed top-0 left-0 w-full h-1 bg-gray-200 z-50">
        <div 
          className="h-full bg-gradient-to-r from-blue-600 to-purple-600 transition-all duration-300"
          style={{ width: `${scrollProgress * 100}%` }}
        />
      </div>

      {/* Header */}
      <header className="bg-white/90 backdrop-blur-md shadow-sm border-b fixed w-full top-0 z-40 transition-all duration-300">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center">
              <h1 className="text-2xl font-bold text-gray-900">
                BOOTed<span className="text-blue-600">Camp</span>
              </h1>
            </div>
            <div className="flex items-center space-x-4">
              <Button variant="outline" onClick={onGetStarted}>
                Log In
              </Button>
              <Button variant="primary" onClick={onGetStarted}>
                Try for Free
              </Button>
            </div>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <section id="hero" className="bg-gradient-to-br from-blue-50 via-white to-purple-50 py-20 pt-32 min-h-screen flex items-center">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid lg:grid-cols-2 gap-12 items-center">
            <div className={`transform transition-all duration-1000 ${isVisible.hero ? 'translate-y-0 opacity-100' : 'translate-y-10 opacity-0'}`}>
              <h1 className="text-5xl lg:text-6xl font-bold text-gray-900 leading-tight mb-6">
                Learn real skills 
                <span className="text-blue-600"> in minutes</span>, 
                not hours
              </h1>
              <p className="text-xl text-gray-600 mb-8 leading-relaxed">
                Master practical micro-skills with bite-sized tutorials. From cooking perfect pasta to fixing your bike, unlock achievements one skill at a time.
              </p>
              <div className="flex flex-col sm:flex-row gap-4 mb-8">
                <Button 
                  variant="primary" 
                  size="lg"
                  onClick={onGetStarted}
                  className="text-lg px-8 py-4 transform hover:scale-105 transition-transform"
                >
                  Start Learning for Free
                </Button>
              </div>
            </div>
            
            {/* Hero Image/Video Placeholder */}
            <div className={`relative transform transition-all duration-1000 delay-300 ${isVisible.hero ? 'translate-x-0 opacity-100' : 'translate-x-10 opacity-0'}`}>
              <div className="bg-gradient-to-br from-blue-500 to-purple-600 rounded-2xl p-8 text-white shadow-2xl hover:shadow-3xl transition-shadow duration-300">
                <div className="space-y-4">
                  <div className="flex items-center space-x-3">
                    <div className="w-3 h-3 bg-red-400 rounded-full animate-pulse"></div>
                    <div className="w-3 h-3 bg-yellow-400 rounded-full animate-pulse" style={{ animationDelay: '0.2s' }}></div>
                    <div className="w-3 h-3 bg-green-400 rounded-full animate-pulse" style={{ animationDelay: '0.4s' }}></div>
                  </div>
                  <div className="text-center py-12">
                    <Play className="w-16 h-16 mx-auto mb-4 opacity-80 hover:opacity-100 cursor-pointer transform hover:scale-110 transition-all" />
                    <p className="text-lg font-medium">Perfect Pasta Tutorial</p>
                    <p className="text-sm opacity-80">15 minutes to mastery</p>
                  </div>
                </div>
              </div>
              {/* Floating cards with animations */}
              <div className="absolute -top-4 -right-4 bg-white rounded-lg shadow-lg p-3 border animate-float">
                <div className="flex items-center space-x-2">
                  <Award className="w-5 h-5 text-yellow-500" />
                  <span className="text-sm font-medium">Achievement Unlocked!</span>
                </div>
              </div>
              <div className="absolute -bottom-4 -left-4 bg-white rounded-lg shadow-lg p-3 border animate-float-delayed">
                <div className="flex items-center space-x-2">
                  <TrendingUp className="w-5 h-5 text-green-500" />
                  <span className="text-sm font-medium">Skill Level: Bronze → Silver</span>
                </div>
              </div>
            </div>
          </div>
          
          {/* Scroll indicator */}
          <div className="text-center mt-16">
            <button 
              onClick={() => scrollToSection('categories')}
              className="animate-bounce text-gray-400 hover:text-gray-600 transition-colors"
            >
              <ChevronDown className="w-8 h-8 mx-auto" />
              <p className="text-sm mt-2">Scroll to explore</p>
            </button>
          </div>
        </div>
      </section>

      {/* Categories Section */}
      <section id="categories" className="py-16 bg-gray-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className={`text-center mb-12 transform transition-all duration-1000 ${isVisible.categories ? 'translate-y-0 opacity-100' : 'translate-y-10 opacity-0'}`}>
            <h2 className="text-3xl font-bold text-gray-900 mb-4">Explore by Category</h2>
            <p className="text-lg text-gray-600">Discover skills that matter to you</p>
          </div>
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-6">
            {categories.map((category, index) => (
              <div 
                key={category.name}
                className={`bg-white rounded-xl p-6 text-center hover:shadow-lg hover:scale-105 transition-all duration-300 cursor-pointer border transform ${
                  isVisible.categories ? 'translate-y-0 opacity-100' : 'translate-y-10 opacity-0'
                }`}
                style={{ transitionDelay: `${index * 100}ms` }}
              >
                <div className="text-4xl mb-4 hover:animate-spin transition-transform">{category.icon}</div>
                <h3 className="font-semibold text-gray-900 mb-2">{category.name}</h3>
                <p className="text-sm text-gray-600">{category.count}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Featured Skills */}
      <section id="skills" className="py-16">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className={`text-center mb-12 transform transition-all duration-1000 ${isVisible.skills ? 'translate-y-0 opacity-100' : 'translate-y-10 opacity-0'}`}>
            <h2 className="text-3xl font-bold text-gray-900 mb-4">Trending Skills</h2>
            <p className="text-lg text-gray-600">Most popular micro-skills this week</p>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            {featuredSkills.map((skill, index) => (
              <div 
                key={index}
                className={`bg-white rounded-xl shadow-md hover:shadow-xl hover:scale-105 transition-all duration-300 border overflow-hidden group cursor-pointer transform ${
                  isVisible.skills ? 'translate-y-0 opacity-100' : 'translate-y-10 opacity-0'
                }`}
                style={{ transitionDelay: `${index * 150}ms` }}
              >
                <div className="aspect-video bg-gradient-to-br from-blue-100 to-purple-100 flex items-center justify-center text-6xl group-hover:scale-110 transition-transform duration-300">
                  {skill.image}
                </div>
                <div className="p-6">
                  <div className="text-sm text-blue-600 font-medium mb-2">{skill.category}</div>
                  <h3 className="font-semibold text-gray-900 mb-2 group-hover:text-blue-600 transition-colors">{skill.title}</h3>
                  <p className="text-sm text-gray-600 mb-4">by {skill.instructor}</p>
                  <div className="flex items-center justify-between text-sm">
                    <div className="flex items-center space-x-1">
                      <Star className="w-4 h-4 text-yellow-500 fill-current" />
                      <span className="font-medium">{skill.rating}</span>
                      <span className="text-gray-500">({skill.students})</span>
                    </div>
                    <span className="text-gray-600 bg-gray-100 px-2 py-1 rounded-full">{skill.duration}</span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section id="cta" className="bg-gradient-to-r from-blue-600 to-purple-600 py-16 relative overflow-hidden">
        {/* Animated background elements */}
        <div className="absolute inset-0">
          <div className="absolute top-1/4 left-1/4 w-64 h-64 bg-white opacity-5 rounded-full"></div>
          <div className="absolute bottom-1/4 right-1/4 w-32 h-32 bg-white opacity-5 rounded-full"></div>
        </div>
        
        <div className={`max-w-4xl mx-auto text-center px-4 sm:px-6 lg:px-8 relative z-10 transform transition-all duration-1000 ${isVisible.cta ? 'translate-y-0 opacity-100' : 'translate-y-10 opacity-0'}`}>
          <h2 className="text-3xl lg:text-4xl font-bold text-white mb-6">
            Ready to unlock your potential?
          </h2>
          <p className="text-xl text-blue-100 mb-8">
            Join thousands of learners mastering real skills, one micro-achievement at a time.
          </p>
          <Button 
            variant="secondary" 
            size="lg"
            onClick={onGetStarted}
            className="bg-white text-blue-600 hover:bg-gray-50 text-lg px-8 py-4 transform hover:scale-105 transition-all duration-300 hover:shadow-xl"
          >
            Start Your Journey Today
          </Button>
        </div>
      </section>
    </div>
  );
};
