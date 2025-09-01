# HellaFresh - Slang Registry Platform

A blockchain-backed platform for tracking the origin and evolution of slang words and cultural terminology. Built on XRP Ledger with community-based verification.

## 🎯 Mission
Track when and where slang terms originate, allowing users to claim ownership of new words and trace the cultural evolution of language across communities.

## 🏗️ Architecture

```
hellafresh/
├── frontend/          # React + Vite web application
├── backend/           # Python FastAPI server
├── blockchain/        # XRP Ledger integration
├── database/          # Supabase schema and migrations
├── docs/             # Project documentation
└── scripts/          # Development and deployment scripts
```

## 🚀 Tech Stack

- **Frontend**: React with Vite
- **Backend**: Python FastAPI
- **Database**: Supabase (PostgreSQL with auth)
- **Blockchain**: XRP Ledger (testnet)
- **Authentication**: Email/password + optional wallet for minting
- **Hosting**: Vercel (frontend) + Serverless functions

## 👥 Target Audience

Gen Z and millennials - the primary drivers of slang evolution and cultural trends.

## ⚡ Core Features

1. **Real-time Search & Conflict Detection**: Check for existing similar terms before submission
2. **Community Verification**: 3-person review system for word approval
3. **Geographic Tracking**: Map the spread of words across regions
4. **Custodial NFTs**: Platform manages blockchain assets for users
5. **Social Integration**: Share word discoveries across social platforms
6. **Ad-Driven Monetization**: Revenue through targeted advertising

## 🔧 Development Setup

```bash
# Clone repository
git clone https://github.com/[username]/hellafresh.git
cd hellafresh

# Setup frontend
cd frontend
npm install
npm run dev

# Setup backend
cd ../backend
pip install -r requirements.txt
uvicorn main:app --reload

# Setup environment variables
cp .env.example .env
# Configure Supabase, XRP testnet, and API keys
```

## 📋 Project Status

**Current Phase**: Initial development
**Status**: Active development
**Timeline**: MVP target Q1 2025

## 🔄 Workflow

1. User searches for slang term
2. System checks for conflicts/similar terms
3. If clear → pending review queue
4. Community reviews (3 approvers needed)
5. Approved words minted as NFTs on XRP Ledger
6. Geographic and usage tracking begins

## 🎪 Coming Soon

- AI-powered validation system
- Mobile app (React Native)
- Celebrity partnerships
- Regional slang maps
- API for researchers

---

Built with ❤️ for the culture.
