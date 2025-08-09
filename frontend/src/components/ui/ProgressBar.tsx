import React from 'react';

interface ProgressBarProps {
  current: number;
  total: number;
  className?: string;
  showText?: boolean;
}

export const ProgressBar: React.FC<ProgressBarProps> = ({ 
  current, 
  total, 
  className = '',
  showText = true 
}) => {
  const percentage = total > 0 ? (current / total) * 100 : 0;
  
  return (
    <div className={`progress-bar ${className}`}>
      <div 
        className="progress-fill"
        style={{ width: `${percentage}%` }}
      />
      {showText && (
        <div className="absolute inset-0 flex items-center justify-center text-xs font-medium text-gray-700">
          {current}/{total}
        </div>
      )}
    </div>
  );
};
