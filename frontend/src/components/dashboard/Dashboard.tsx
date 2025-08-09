import React, { useState, useEffect } from 'react';
import { UserProfile, CategoryProgress } from '../../types';
import { apiService } from '../../services/api';
import { ProgressBar } from '../ui/ProgressBar';
import { RankBadge } from '../ui/RankBadge';
import { LoadingSpinner } from '../ui/Button';

interface DashboardProps {
  username: string;
  onLogout: () => void;
}

export const Dashboard: React.FC<DashboardProps> = ({ username, onLogout }) => {
  const [profile, setProfile] = useState<UserProfile | null>(null);
  const [loading, setLoading] = useState(true);
  const [activeView, setActiveView] = useState<'browse' | 'profile' | 'achievements' | 'leaderboard'>('browse');

  useEffect(() => {
    loadProfile();
  }, [username]);

  const loadProfile = async () => {
    try {
      const userProfile = await apiService.getUserProfile(username);
      setProfile(userProfile);
    } catch (error) {
      console.error('Failed to load profile:', error);
    } finally {
      setLoading(false);
    }
  };

  const getTotalCompleted = (profile: UserProfile): number => {
    return profile.categories.reduce((total, category) => {
      return total + category.skills.filter(skill => skill.status === 'Completed').length;
    }, 0);
  };

  const getTotalSkills = (profile: UserProfile): number => {
    return profile.categories.reduce((total, category) => total + category.skills.length, 0);
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  if (!profile) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <h2 className="text-xl font-semibold text-gray-800">Failed to load profile</h2>
          <button 
            onClick={loadProfile}
            className="mt-4 btn-primary"
          >
            Try Again
          </button>
        </div>
      </div>
    );
  }

  const completedCount = getTotalCompleted(profile);
  const totalSkills = getTotalSkills(profile);
  const { rank, emoji } = apiService.getRankInfo(completedCount);

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center">
              <h1 className="text-2xl font-bold text-primary-600">BOOTedCamp</h1>
            </div>
            
            <nav className="hidden md:flex space-x-8">
              <button
                onClick={() => setActiveView('browse')}
                className={`px-3 py-2 text-sm font-medium ${
                  activeView === 'browse'
                    ? 'text-primary-600 border-b-2 border-primary-600'
                    : 'text-gray-500 hover:text-gray-700'
                }`}
              >
                Browse Skills
              </button>
              <button
                onClick={() => setActiveView('profile')}
                className={`px-3 py-2 text-sm font-medium ${
                  activeView === 'profile'
                    ? 'text-primary-600 border-b-2 border-primary-600'
                    : 'text-gray-500 hover:text-gray-700'
                }`}
              >
                My Profile
              </button>
              <button
                onClick={() => setActiveView('achievements')}
                className={`px-3 py-2 text-sm font-medium ${
                  activeView === 'achievements'
                    ? 'text-primary-600 border-b-2 border-primary-600'
                    : 'text-gray-500 hover:text-gray-700'
                }`}
              >
                Achievements
              </button>
              <button
                onClick={() => setActiveView('leaderboard')}
                className={`px-3 py-2 text-sm font-medium ${
                  activeView === 'leaderboard'
                    ? 'text-primary-600 border-b-2 border-primary-600'
                    : 'text-gray-500 hover:text-gray-700'
                }`}
              >
                Leaderboard
              </button>
            </nav>

            <div className="flex items-center space-x-4">
              <div className="text-right hidden sm:block">
                <p className="text-sm font-medium text-gray-800">{username}</p>
                <div className="flex items-center justify-end mt-1">
                  <RankBadge rank={rank} emoji={emoji} />
                </div>
              </div>
              <button
                onClick={onLogout}
                className="btn-secondary text-sm"
              >
                Logout
              </button>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {activeView === 'browse' && (
          <BrowseView profile={profile} onProfileUpdate={loadProfile} />
        )}
        {activeView === 'profile' && (
          <ProfileView profile={profile} />
        )}
        {activeView === 'achievements' && (
          <AchievementsView username={username} />
        )}
        {activeView === 'leaderboard' && (
          <LeaderboardView />
        )}
      </main>
    </div>
  );
};

// Browse View Component
const BrowseView: React.FC<{ profile: UserProfile; onProfileUpdate: () => void }> = ({ 
  profile, 
  onProfileUpdate 
}) => {
  const [selectedCategory, setSelectedCategory] = useState<string | null>(null);

  if (selectedCategory) {
    const category = profile.categories.find(cat => cat.category_name === selectedCategory);
    if (category) {
      return (
        <CategoryDetailView 
          category={category}
          profile={profile}
          onBack={() => setSelectedCategory(null)}
          onProfileUpdate={onProfileUpdate}
        />
      );
    }
  }

  return (
    <div>
      <div className="mb-8">
        <h2 className="text-3xl font-bold text-gray-900 mb-2">Browse Skills</h2>
        <p className="text-gray-600">Choose a category to start learning new skills</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {profile.categories.map((category) => {
          const completedSkills = category.skills.filter(skill => skill.status === 'Completed').length;
          const totalSkills = category.skills.length;
          
          return (
            <div
              key={category.category_name}
              className="category-card"
              onClick={() => setSelectedCategory(category.category_name)}
            >
              <h3 className="text-xl font-semibold text-gray-900 mb-3">
                {category.category_name}
              </h3>
              <div className="mb-4">
                <ProgressBar 
                  current={completedSkills} 
                  total={totalSkills}
                  className="relative"
                />
              </div>
              <p className="text-sm text-gray-600">
                {completedSkills} of {totalSkills} skills completed
              </p>
            </div>
          );
        })}
      </div>
    </div>
  );
};

// Category Detail View Component
const CategoryDetailView: React.FC<{
  category: CategoryProgress;
  profile: UserProfile;
  onBack: () => void;
  onProfileUpdate: () => void;
}> = ({ category, profile, onBack, onProfileUpdate }) => {
  const [selectedSkill, setSelectedSkill] = useState<string | null>(null);

  if (selectedSkill) {
    const skill = category.skills.find(s => s.skill_name === selectedSkill);
    if (skill) {
      return (
        <SkillDetailView
          skill={skill}
          category={category.category_name}
          profile={profile}
          onBack={() => setSelectedSkill(null)}
          onProfileUpdate={onProfileUpdate}
        />
      );
    }
  }

  return (
    <div>
      <div className="mb-6">
        <button
          onClick={onBack}
          className="btn-secondary mb-4"
        >
          ← Back to Categories
        </button>
        <h2 className="text-3xl font-bold text-gray-900 mb-2">{category.category_name}</h2>
        <p className="text-gray-600">Select a skill to get started</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {category.skills.map((skill) => {
          const statusColors = {
            'NotStarted': 'border-gray-200 bg-white',
            'InProgress': 'border-yellow-300 bg-yellow-50',
            'Completed': 'border-green-300 bg-green-50'
          };

          const statusText = {
            'NotStarted': 'Not Started',
            'InProgress': 'In Progress',
            'Completed': 'Completed'
          };

          return (
            <div
              key={skill.skill_name}
              className={`skill-card cursor-pointer ${statusColors[skill.status]}`}
              onClick={() => setSelectedSkill(skill.skill_name)}
            >
              <h3 className="text-lg font-semibold text-gray-900 mb-2">
                {skill.skill_name}
              </h3>
              <p className="text-gray-600 text-sm mb-4">{skill.description}</p>
              <div className="flex justify-between items-center">
                <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                  skill.status === 'Completed' ? 'bg-green-100 text-green-800' :
                  skill.status === 'InProgress' ? 'bg-yellow-100 text-yellow-800' :
                  'bg-gray-100 text-gray-800'
                }`}>
                  {statusText[skill.status]}
                </span>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
};

// Skill Detail View Component  
const SkillDetailView: React.FC<{
  skill: any;
  category: string;
  profile: UserProfile;
  onBack: () => void;
  onProfileUpdate: () => void;
}> = ({ skill, category, profile, onBack, onProfileUpdate }) => {
  const [loading, setLoading] = useState(false);
  const [skillData, setSkillData] = useState<any>(null);

  useEffect(() => {
    loadSkillData();
  }, [skill.skill_name, category]);

  const loadSkillData = async () => {
    try {
      const data = await apiService.getSkill(category, skill.skill_name);
      setSkillData(data);
    } catch (error) {
      console.error('Failed to load skill data:', error);
    }
  };

  const updateSkillStatus = async (status: any) => {
    setLoading(true);
    try {
      await apiService.updateSkillStatus(profile.username, category, skill.skill_name, status);
      onProfileUpdate();
    } catch (error) {
      console.error('Failed to update skill status:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      <button
        onClick={onBack}
        className="btn-secondary mb-6"
      >
        ← Back to Skills
      </button>

      <div className="bg-white rounded-lg shadow-sm p-6">
        <h2 className="text-3xl font-bold text-gray-900 mb-4">{skill.skill_name}</h2>
        <p className="text-gray-600 text-lg mb-6">{skill.description}</p>

        {skillData?.steps && skillData.steps.length > 0 && (
          <div className="mb-6">
            <h3 className="text-xl font-semibold text-gray-900 mb-3">Steps</h3>
            <ol className="list-decimal list-inside space-y-2">
              {skillData.steps.map((step: string, index: number) => (
                <li key={index} className="text-gray-700">{step}</li>
              ))}
            </ol>
          </div>
        )}

        {skillData?.video_links && skillData.video_links.length > 0 && (
          <div className="mb-6">
            <h3 className="text-xl font-semibold text-gray-900 mb-3">Video Resources</h3>
            <ul className="space-y-2">
              {skillData.video_links.map((link: string, index: number) => (
                <li key={index}>
                  <a 
                    href={link} 
                    target="_blank" 
                    rel="noopener noreferrer"
                    className="text-primary-600 hover:text-primary-500 underline"
                  >
                    Video Tutorial {index + 1}
                  </a>
                </li>
              ))}
            </ul>
          </div>
        )}

        <div className="flex space-x-4">
          {skill.status === 'NotStarted' && (
            <button
              onClick={() => updateSkillStatus('InProgress')}
              disabled={loading}
              className="btn-primary"
            >
              Start Learning
            </button>
          )}
          
          {skill.status === 'InProgress' && (
            <button
              onClick={() => updateSkillStatus('Completed')}
              disabled={loading}
              className="btn-success"
            >
              Mark as Completed
            </button>
          )}
          
          {skill.status === 'Completed' && (
            <span className="inline-flex items-center px-3 py-2 text-sm font-medium text-green-800 bg-green-100 rounded-lg">
              ✓ Completed
            </span>
          )}
        </div>
      </div>
    </div>
  );
};

// Profile View Component
const ProfileView: React.FC<{ profile: UserProfile }> = ({ profile }) => {
  const getTotalCompleted = (profile: UserProfile): number => {
    return profile.categories.reduce((total, category) => {
      return total + category.skills.filter(skill => skill.status === 'Completed').length;
    }, 0);
  };

  const getTotalSkills = (profile: UserProfile): number => {
    return profile.categories.reduce((total, category) => total + category.skills.length, 0);
  };

  const completedCount = getTotalCompleted(profile);
  const totalSkills = getTotalSkills(profile);
  const { rank, emoji } = apiService.getRankInfo(completedCount);

  return (
    <div>
      <div className="mb-8">
        <h2 className="text-3xl font-bold text-gray-900 mb-2">My Profile</h2>
        <p className="text-gray-600">Track your learning progress</p>
      </div>

      <div className="bg-white rounded-lg shadow-sm p-6 mb-8">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h3 className="text-2xl font-bold text-gray-900">{profile.username}</h3>
            <div className="mt-2">
              <RankBadge rank={rank} emoji={emoji} />
            </div>
          </div>
          <div className="text-right">
            <p className="text-3xl font-bold text-primary-600">{completedCount}</p>
            <p className="text-sm text-gray-600">Skills Completed</p>
          </div>
        </div>

        <div className="mb-6">
          <div className="flex justify-between items-center mb-2">
            <span className="text-sm font-medium text-gray-700">Overall Progress</span>
            <span className="text-sm text-gray-600">{completedCount}/{totalSkills}</span>
          </div>
          <ProgressBar current={completedCount} total={totalSkills} showText={false} />
        </div>
      </div>

      <div className="space-y-6">
        {profile.categories.map((category) => {
          const completedSkills = category.skills.filter(skill => skill.status === 'Completed').length;
          const inProgressSkills = category.skills.filter(skill => skill.status === 'InProgress').length;
          const totalSkills = category.skills.length;

          return (
            <div key={category.category_name} className="bg-white rounded-lg shadow-sm p-6">
              <div className="flex justify-between items-center mb-4">
                <h3 className="text-xl font-semibold text-gray-900">{category.category_name}</h3>
                <span className="text-sm text-gray-600">{completedSkills}/{totalSkills} completed</span>
              </div>
              
              <ProgressBar 
                current={completedSkills} 
                total={totalSkills} 
                className="mb-4 relative"
                showText={false}
              />

              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                {category.skills.map((skill) => (
                  <div key={skill.skill_name} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                    <span className="text-sm font-medium text-gray-900">{skill.skill_name}</span>
                    <span className={`text-xs px-2 py-1 rounded-full ${
                      skill.status === 'Completed' ? 'bg-green-100 text-green-800' :
                      skill.status === 'InProgress' ? 'bg-yellow-100 text-yellow-800' :
                      'bg-gray-100 text-gray-800'
                    }`}>
                      {skill.status === 'NotStarted' ? 'Not Started' : 
                       skill.status === 'InProgress' ? 'In Progress' : 'Completed'}
                    </span>
                  </div>
                ))}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
};

// Achievements View Component
const AchievementsView: React.FC<{ username: string }> = ({ username }) => {
  const [achievements, setAchievements] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadAchievements();
  }, [username]);

  const loadAchievements = async () => {
    try {
      const data = await apiService.getAchievements(username);
      setAchievements(data);
    } catch (error) {
      console.error('Failed to load achievements:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="flex justify-center py-8">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  return (
    <div>
      <div className="mb-8">
        <h2 className="text-3xl font-bold text-gray-900 mb-2">Achievements</h2>
        <p className="text-gray-600">Your learning milestones</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {achievements.map((achievement) => (
          <div
            key={achievement.id}
            className={`achievement-card ${achievement.unlocked ? 'achievement-unlocked' : ''}`}
          >
            <div className="flex items-start justify-between mb-3">
              <h3 className="text-lg font-semibold text-gray-900">{achievement.name}</h3>
              {achievement.unlocked && (
                <span className="text-2xl">🏆</span>
              )}
            </div>
            <p className="text-gray-600 text-sm mb-3">{achievement.description}</p>
            {achievement.target && (
              <div>
                <div className="flex justify-between items-center mb-1">
                  <span className="text-xs text-gray-500">Progress</span>
                  <span className="text-xs text-gray-500">
                    {achievement.progress}/{achievement.target}
                  </span>
                </div>
                <ProgressBar 
                  current={achievement.progress} 
                  total={achievement.target}
                  showText={false}
                />
              </div>
            )}
          </div>
        ))}
      </div>
    </div>
  );
};

// Leaderboard View Component
const LeaderboardView: React.FC = () => {
  const [leaderboard, setLeaderboard] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadLeaderboard();
  }, []);

  const loadLeaderboard = async () => {
    try {
      const data = await apiService.getLeaderboard();
      setLeaderboard(data);
    } catch (error) {
      console.error('Failed to load leaderboard:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="flex justify-center py-8">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  return (
    <div>
      <div className="mb-8">
        <h2 className="text-3xl font-bold text-gray-900 mb-2">Leaderboard</h2>
        <p className="text-gray-600">See how you rank against other learners</p>
      </div>

      <div className="bg-white rounded-lg shadow-sm overflow-hidden">
        <div className="px-6 py-4 border-b border-gray-200">
          <h3 className="text-lg font-semibold text-gray-900">Top Learners</h3>
        </div>
        <div className="divide-y divide-gray-200">
          {leaderboard.map((entry, index) => {
            const { rank, emoji } = apiService.getRankInfo(entry.completed_skills);
            
            return (
              <div key={entry.username} className="px-6 py-4 flex items-center justify-between">
                <div className="flex items-center">
                  <span className="text-xl font-bold text-gray-400 mr-4">#{index + 1}</span>
                  <div>
                    <p className="text-lg font-medium text-gray-900">{entry.username}</p>
                    <RankBadge rank={rank} emoji={emoji} />
                  </div>
                </div>
                <div className="text-right">
                  <p className="text-2xl font-bold text-primary-600">{entry.completed_skills}</p>
                  <p className="text-sm text-gray-600">skills completed</p>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
};
