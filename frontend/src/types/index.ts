export interface User {
  name: string;
  password: string;
}

export interface Skill {
  name: string;
  description: string;
  steps: string[];
  video_links: string[];
}

export type SkillStatus = 'NotStarted' | 'InProgress' | 'Completed';

export interface SkillProgress {
  skill_name: string;
  description: string;
  status: SkillStatus;
}

export interface CategoryProgress {
  category_name: string;
  skills: SkillProgress[];
}

export interface UserProfile {
  username: string;
  categories: CategoryProgress[];
}

export type Rank = 'Bronze' | 'Silver' | 'Gold' | 'Master' | 'Champion';

export interface RankInfo {
  rank: Rank;
  emoji: string;
}

export interface Achievement {
  id: string;
  name: string;
  description: string;
  unlocked: boolean;
  progress?: number;
  target?: number;
}

export interface Comment {
  username: string;
  comment: string;
  timestamp?: string;
}

export interface Rating {
  username: string;
  rating: number;
  category: string;
  skill_name: string;
}

export interface LeaderboardEntry {
  username: string;
  completed_skills: number;
  rank: Rank;
}
