# HellaFresh Development Guide

## Quick Start

### Prerequisites
- Node.js 18+ 
- Python 3.9+
- Git
- Supabase account
- XRP Testnet faucet access

### Initial Setup

1. **Clone and Setup Environment**
```bash
git clone https://github.com/[your-username]/hellafresh.git
cd hellafresh
cp .env.example .env
# Edit .env with your actual credentials
```

2. **Install Dependencies**
```bash
# Install root dependencies
npm install

# Setup frontend
cd frontend
npm install

# Setup backend
cd ../backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

3. **Database Setup**
- Create a new Supabase project
- Copy your project URL and anon key to `.env`
- Run database migrations (coming soon)

4. **XRP Ledger Setup**
- Get testnet XRP from faucet: https://xrpl.org/xrp-testnet-faucet.html
- Generate platform wallet and add seed to `.env`

### Development Workflow

1. **Start Development Servers**
```bash
# Option 1: Start both servers
npm run dev

# Option 2: Start individually
npm run dev:frontend  # React app on :5173
npm run dev:backend   # FastAPI on :8000
```

2. **Key Development URLs**
- Frontend: http://localhost:5173
- Backend API: http://localhost:8000
- API Docs: http://localhost:8000/docs

## Project Structure

### Frontend (`/frontend`)
```
frontend/
├── src/
│   ├── components/     # Reusable UI components
│   ├── pages/         # Route components
│   ├── hooks/         # Custom React hooks
│   ├── stores/        # Zustand state management
│   ├── services/      # API calls and external services
│   ├── utils/         # Helper functions
│   └── styles/        # CSS and Tailwind config
├── public/            # Static assets
└── package.json
```

### Backend (`/backend`)
```
backend/
├── app/
│   ├── api/           # API route handlers
│   ├── core/          # Configuration and security
│   ├── db/            # Database models and operations
│   ├── services/      # Business logic
│   └── utils/         # Helper functions
├── tests/             # Test files
├── alembic/           # Database migrations
├── main.py            # FastAPI app entry point
└── requirements.txt
```

### Blockchain (`/blockchain`)
```
blockchain/
├── xrpl/              # XRP Ledger integration
├── contracts/         # Smart contract logic
├── tests/             # Blockchain tests
└── utils/             # Blockchain utilities
```

## Development Guidelines

### Git Workflow
1. Create feature branches: `git checkout -b feature/search-system`
2. Make atomic commits with clear messages
3. Push to GitHub and create pull requests
4. Merge after review

### Code Standards
- **Frontend**: ESLint + Prettier, React hooks patterns
- **Backend**: Black formatter, FastAPI async patterns
- **Testing**: Jest (frontend), Pytest (backend)

### API Development
- All endpoints under `/api/` prefix
- Use Pydantic models for request/response validation
- Include proper HTTP status codes
- Document with FastAPI automatic docs

### Database Design
- Use Supabase Row Level Security (RLS)
- Separate tables for: users, words, reviews, votes, nft_metadata
- Include proper indexes for search performance

## Key Features Implementation

### 1. Search & Conflict Detection
**Frontend**: Real-time search with debouncing
**Backend**: Elasticsearch integration for fuzzy matching
**Database**: Word index with phonetic similarity scoring

### 2. Community Review System
**Workflow**: Submit → Queue → 3 Reviews → Mint
**Database**: Review tracking with vote records
**Blockchain**: NFT minting after approval

### 3. XRP Ledger Integration
**Testnet**: Development and testing
**Custodial**: Platform manages user NFTs
**Transactions**: Word minting, ownership records

### 4. Geographic Tracking
**Frontend**: Interactive maps showing word spread
**Backend**: Location data processing and aggregation
**Privacy**: Opt-in location sharing with anonymization

## Environment Configuration

### Required Environment Variables
```bash
# Supabase
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key

# XRP Ledger
XRPL_SERVER=wss://s.altnet.rippletest.net:51233
PLATFORM_WALLET_SEED=your_wallet_seed

# API
JWT_SECRET=your_jwt_secret
DEBUG=true
```

## Testing Strategy

### Frontend Testing
```bash
cd frontend
npm run test
```
- Component testing with React Testing Library
- Hook testing for custom functionality
- Integration tests for user flows

### Backend Testing
```bash
cd backend
python -m pytest
```
- Unit tests for business logic
- API endpoint testing
- Database operation testing
- XRP Ledger integration testing

## Deployment

### Frontend (Vercel)
1. Connect GitHub repository to Vercel
2. Configure environment variables
3. Deploy automatically on push to main

### Backend (Serverless Functions)
1. Configure Vercel serverless functions
2. Or use Railway/Render for dedicated hosting
3. Set up environment variables in hosting platform

## Contributing

1. Check existing issues or create new ones
2. Fork the repository
3. Create feature branches
4. Write tests for new functionality
5. Submit pull requests with detailed descriptions

## Troubleshooting

### Common Issues
- **CORS errors**: Check FastAPI middleware configuration
- **Database connection**: Verify Supabase credentials
- **XRP transactions**: Check testnet wallet balance
- **Search not working**: Ensure Elasticsearch is running

### Development Tools
- **API Testing**: Use `/docs` for interactive testing
- **Database**: Supabase dashboard for direct DB access
- **Blockchain**: XRP Ledger explorer for transaction verification

---

Need help? Check the issues on GitHub or create a new one with detailed information about your problem.
