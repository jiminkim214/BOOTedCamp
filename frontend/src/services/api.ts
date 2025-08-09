import { 
  User, 
  UserProfile, 
  Skill, 
  Achievement, 
  Comment, 
  Rating, 
  LeaderboardEntry,
  SkillStatus,
  RankInfo
} from '../types';

// Mock API service - This would connect to your OCaml backend
class ApiService {
  private baseUrl = 'http://localhost:8080/api'; // Your OCaml server URL
  private users: User[] = [
    { name: 'demo', password: 'demo' },
    { name: 'john', password: 'john123' },
    { name: 'sarah', password: 'sarah456' }
  ];

  private mockSkills = {
    'Cooking': [
      {
        name: 'Pasta',
        description: 'Learn to cook perfect pasta',
        steps: ['Boil water', 'Add salt', 'Cook pasta al dente', 'Drain and serve'],
        video_links: ['https://youtube.com/pasta-tutorial']
      },
      {
        name: 'Salad',
        description: 'Make a fresh garden salad',
        steps: ['Wash vegetables', 'Chop ingredients', 'Mix dressing', 'Combine and serve'],
        video_links: ['https://youtube.com/salad-tutorial']
      },
      {
        name: 'Soup',
        description: 'Prepare a hearty vegetable soup',
        steps: ['Chop vegetables', 'Sauté aromatics', 'Add broth', 'Simmer until tender'],
        video_links: ['https://youtube.com/soup-tutorial']
      }
    ],
    'Exercise': [
      {
        name: 'Pushups',
        description: 'Master the perfect pushup form',
        steps: ['Start in plank position', 'Lower chest to ground', 'Push back up', 'Maintain straight line'],
        video_links: ['https://youtube.com/pushup-tutorial']
      },
      {
        name: 'Running',
        description: 'Learn proper running technique',
        steps: ['Warm up', 'Start with short distances', 'Focus on breathing', 'Cool down and stretch'],
        video_links: ['https://youtube.com/running-tutorial']
      }
    ],
    'Technology': [
      {
        name: 'Git Basics',
        description: 'Learn version control with Git',
        steps: ['Initialize repo', 'Add files', 'Commit changes', 'Push to remote'],
        video_links: ['https://youtube.com/git-tutorial']
      },
      {
        name: 'React Components',
        description: 'Build reusable React components',
        steps: ['Create functional component', 'Add props', 'Handle state', 'Export component'],
        video_links: ['https://youtube.com/react-tutorial']
      }
    ]
  };

  private currentUser: string | null = null;
  private profiles: { [username: string]: UserProfile } = {};

  // Authentication
  async login(username: string, password: string): Promise<{ success: boolean; user?: User }> {
    await this.delay(500); // Simulate network delay
    
    const user = this.users.find(u => u.name === username && u.password === password);
    if (user) {
      this.currentUser = username;
      return { success: true, user };
    }
    return { success: false };
  }

  async signup(username: string, password: string): Promise<{ success: boolean; user?: User; error?: string }> {
    await this.delay(500);
    
    if (this.users.find(u => u.name === username)) {
      return { success: false, error: 'Username already exists' };
    }
    
    if (!/^[a-z]+$/.test(password)) {
      return { success: false, error: 'Password must contain only lowercase letters' };
    }
    
    const newUser = { name: username, password };
    this.users.push(newUser);
    this.currentUser = username;
    return { success: true, user: newUser };
  }

  logout(): void {
    this.currentUser = null;
  }

  getCurrentUser(): string | null {
    return this.currentUser;
  }

  // Skills and Categories
  async getCategories(): Promise<string[]> {
    await this.delay(300);
    return Object.keys(this.mockSkills);
  }

  async getSkillsByCategory(category: string): Promise<Skill[]> {
    await this.delay(300);
    return this.mockSkills[category as keyof typeof this.mockSkills] || [];
  }

  async getSkill(category: string, skillName: string): Promise<Skill | null> {
    await this.delay(300);
    const skills = this.mockSkills[category as keyof typeof this.mockSkills] || [];
    return skills.find(skill => skill.name === skillName) || null;
  }

  // User Profile
  async getUserProfile(username: string): Promise<UserProfile> {
    await this.delay(300);
    
    if (!this.profiles[username]) {
      // Initialize profile for new user
      this.profiles[username] = {
        username,
        categories: (Object.keys(this.mockSkills) as Array<keyof typeof this.mockSkills>).map(categoryName => ({
          category_name: categoryName,
          skills: this.mockSkills[categoryName].map((skill: Skill) => ({
            skill_name: skill.name,
            description: skill.description,
            status: 'NotStarted' as SkillStatus
          }))
        }))
      };
    }
    
    return this.profiles[username];
  }

  async updateSkillStatus(username: string, category: string, skillName: string, status: SkillStatus): Promise<boolean> {
    await this.delay(300);
    
    const profile = await this.getUserProfile(username);
    const categoryIndex = profile.categories.findIndex(cat => cat.category_name === category);
    
    if (categoryIndex !== -1) {
      const skillIndex = profile.categories[categoryIndex].skills.findIndex(skill => skill.skill_name === skillName);
      if (skillIndex !== -1) {
        profile.categories[categoryIndex].skills[skillIndex].status = status;
        return true;
      }
    }
    
    return false;
  }

  // Achievements
  async getAchievements(username: string): Promise<Achievement[]> {
    await this.delay(300);
    
    const profile = await this.getUserProfile(username);
    const completedCount = this.getTotalCompleted(profile);
    
    return [
      {
        id: 'first_skill',
        name: 'First Steps',
        description: 'Complete your first skill',
        unlocked: completedCount >= 1,
        progress: Math.min(completedCount, 1),
        target: 1
      },
      {
        id: 'skill_explorer',
        name: 'Skill Explorer',
        description: 'Complete 5 skills',
        unlocked: completedCount >= 5,
        progress: Math.min(completedCount, 5),
        target: 5
      },
      {
        id: 'multi_category',
        name: 'Renaissance Person',
        description: 'Complete skills in 3 different categories',
        unlocked: this.getCategoriesWithCompletedSkills(profile) >= 3,
        progress: this.getCategoriesWithCompletedSkills(profile),
        target: 3
      }
    ];
  }

  // Rankings and Leaderboard
  getRankInfo(completedCount: number): RankInfo {
    if (completedCount === 0) return { rank: 'Bronze', emoji: '🥉' };
    if (completedCount === 1) return { rank: 'Silver', emoji: '🥈' };
    if (completedCount === 2) return { rank: 'Gold', emoji: '🥇' };
    if (completedCount === 3) return { rank: 'Master', emoji: '🏆' };
    return { rank: 'Champion', emoji: '👑' };
  }

  async getLeaderboard(): Promise<LeaderboardEntry[]> {
    await this.delay(300);
    
    const entries: LeaderboardEntry[] = [];
    
    for (const username of Object.keys(this.profiles)) {
      const profile = this.profiles[username];
      const completedCount = this.getTotalCompleted(profile);
      const { rank } = this.getRankInfo(completedCount);
      
      entries.push({
        username,
        completed_skills: completedCount,
        rank
      });
    }
    
    return entries.sort((a, b) => b.completed_skills - a.completed_skills);
  }

  // Comments and Ratings
  async getComments(category: string, skillName: string): Promise<Comment[]> {
    await this.delay(300);
    // Mock comments - in real app, load from backend
    return [
      { username: 'john', comment: 'Great tutorial! Very helpful.' },
      { username: 'sarah', comment: 'Clear instructions, easy to follow.' }
    ];
  }

  async addComment(username: string, category: string, skillName: string, comment: string): Promise<boolean> {
    await this.delay(300);
    // In real app, save to backend
    return true;
  }

  async addRating(username: string, category: string, skillName: string, rating: number): Promise<boolean> {
    await this.delay(300);
    // In real app, save to backend
    return true;
  }

  async getMeanRating(category: string, skillName: string): Promise<number | null> {
    await this.delay(300);
    // Mock rating - in real app, calculate from backend data
    return Math.random() * 2 + 3; // Random rating between 3-5
  }

  // Helper methods
  private getTotalCompleted(profile: UserProfile): number {
    return profile.categories.reduce((total, category) => {
      return total + category.skills.filter(skill => skill.status === 'Completed').length;
    }, 0);
  }

  private getCategoriesWithCompletedSkills(profile: UserProfile): number {
    return profile.categories.filter(category => 
      category.skills.some(skill => skill.status === 'Completed')
    ).length;
  }

  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}

export const apiService = new ApiService();
