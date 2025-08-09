import { useState, useEffect } from 'react';

export const useCounter = (end: number, duration: number = 2000, start: number = 0) => {
  const [count, setCount] = useState(start);
  
  useEffect(() => {
    let startTime: number;
    let animationFrame: number;
    
    const animation = (currentTime: number) => {
      if (!startTime) startTime = currentTime;
      const progress = Math.min((currentTime - startTime) / duration, 1);
      
      const easeOutQuart = 1 - Math.pow(1 - progress, 4);
      const currentCount = Math.floor(easeOutQuart * (end - start) + start);
      
      setCount(currentCount);
      
      if (progress < 1) {
        animationFrame = requestAnimationFrame(animation);
      }
    };
    
    animationFrame = requestAnimationFrame(animation);
    
    return () => cancelAnimationFrame(animationFrame);
  }, [end, duration, start]);
  
  return count;
};
