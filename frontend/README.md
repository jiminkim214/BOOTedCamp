# BOOTedCamp Frontend

A modern React frontend for the BOOTedCamp micro-skills learning platform.

## Features

- **User Authentication**: Login and signup with secure password handling
- **Skill Browsing**: Browse skills organized by categories (Cooking, Exercise, Technology, etc.)
- **Progress Tracking**: Track your learning progress with visual progress bars
- **Ranking System**: Earn ranks from Bronze to Champion based on completed skills
- **Achievements**: Unlock achievements as you progress
- **Leaderboard**: Compare your progress with other learners
- **Responsive Design**: Works on desktop, tablet, and mobile devices

## Tech Stack

- **React 18** with TypeScript
- **Tailwind CSS** for styling
- **Lucide React** for icons
- **React Router** for navigation
- **Mock API Service** (ready to connect to your OCaml backend)

## Getting Started

### Prerequisites

- Node.js 16 or higher
- npm or yarn

### Installation

1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Start the development server:
   ```bash
   npm start
   ```

4. Open [http://localhost:3000](http://localhost:3000) to view it in the browser.

### Demo Credentials

- **Username**: demo
- **Password**: demo

## Project Structure

```
src/
├── components/          # React components
│   ├── auth/           # Authentication components
│   ├── dashboard/      # Dashboard and main app components
│   └── ui/             # Reusable UI components
├── services/           # API service layer
├── types/              # TypeScript type definitions
├── App.tsx             # Main app component
├── index.tsx           # App entry point
└── index.css           # Global styles
```

## Key Components

### Authentication
- `LoginForm`: User login with username/password
- `SignupForm`: User registration with validation

### Dashboard
- `Dashboard`: Main application layout with navigation
- `BrowseView`: Browse skills by category
- `ProfileView`: User profile and progress overview
- `AchievementsView`: Display unlocked achievements
- `LeaderboardView`: Show top learners

### UI Components
- `ProgressBar`: Animated progress visualization
- `RankBadge`: User rank display with emoji
- `Button`: Consistent button styling with loading states

## API Integration

The frontend uses a mock API service (`src/services/api.ts`) that simulates the OCaml backend functionality. To connect to your real backend:

1. Update the `baseUrl` in `api.ts` to point to your OCaml server
2. Replace mock methods with actual HTTP requests
3. Ensure your OCaml backend provides the expected JSON API endpoints

### Expected API Endpoints

- `POST /api/auth/login` - User authentication
- `POST /api/auth/signup` - User registration
- `GET /api/profile/:username` - Get user profile
- `PUT /api/profile/:username/skill` - Update skill status
- `GET /api/skills/:category` - Get skills by category
- `GET /api/achievements/:username` - Get user achievements
- `GET /api/leaderboard` - Get leaderboard data
- `GET /api/comments/:category/:skill` - Get skill comments
- `POST /api/comments` - Add skill comment
- `POST /api/ratings` - Add skill rating

## Styling

The app uses Tailwind CSS with a custom design system:

- **Primary Colors**: Blue tones for main actions
- **Secondary Colors**: Green tones for success states
- **Progress Bars**: Gradient fills with smooth animations
- **Rank Badges**: Color-coded badges for different ranks
- **Cards**: Consistent shadow and hover effects

## Features in Detail

### User Ranks
- **Bronze** 🥉: 0 completed skills
- **Silver** 🥈: 1 completed skill
- **Gold** 🥇: 2 completed skills
- **Master** 🏆: 3 completed skills
- **Champion** 👑: 4+ completed skills

### Skill Status
- **Not Started**: Default state for new skills
- **In Progress**: User has started learning
- **Completed**: User has finished the skill

### Achievements
- **First Steps**: Complete your first skill
- **Skill Explorer**: Complete 5 skills
- **Renaissance Person**: Complete skills in 3 different categories

## Development

### Available Scripts

- `npm start`: Start development server
- `npm test`: Run test suite
- `npm run build`: Build for production
- `npm run eject`: Eject from Create React App (use with caution)

### Code Style

The project uses TypeScript with strict type checking. Key conventions:

- Use functional components with hooks
- Define proper TypeScript interfaces for all props
- Use Tailwind classes for styling
- Keep components small and focused
- Use the mock API service for data operations

## Production Deployment

1. Build the production version:
   ```bash
   npm run build
   ```

2. The `build` folder contains the optimized static files ready for deployment.

3. Deploy to your preferred hosting service (Netlify, Vercel, AWS S3, etc.)

4. Ensure your OCaml backend is configured to serve API requests and handle CORS for the frontend domain.

## Future Enhancements

- **Real-time Updates**: WebSocket integration for live leaderboard updates
- **Video Player**: Embedded video player for tutorial links
- **Search**: Search functionality for skills and categories
- **Notifications**: Achievement unlock notifications
- **Social Features**: User following and skill sharing
- **Mobile App**: React Native version for mobile devices

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is part of the BOOTedCamp learning platform.
