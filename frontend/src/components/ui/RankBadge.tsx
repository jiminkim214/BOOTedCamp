import React from 'react';
import { Rank } from '../../types';

interface RankBadgeProps {
  rank: Rank;
  emoji: string;
  className?: string;
}

export const RankBadge: React.FC<RankBadgeProps> = ({ rank, emoji, className = '' }) => {
  const getRankStyles = (rank: Rank): string => {
    switch (rank) {
      case 'Bronze':
        return 'rank-bronze';
      case 'Silver':
        return 'rank-silver';
      case 'Gold':
        return 'rank-gold';
      case 'Master':
        return 'rank-master';
      case 'Champion':
        return 'rank-champion';
      default:
        return 'rank-bronze';
    }
  };

  return (
    <span className={`rank-badge ${getRankStyles(rank)} ${className}`}>
      <span className="mr-1">{emoji}</span>
      {rank}
    </span>
  );
};
