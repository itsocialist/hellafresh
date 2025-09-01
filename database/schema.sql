-- HellaFresh Database Schema
-- Run these commands in your Supabase SQL Editor

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- Users table (extends Supabase auth.users)
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  username TEXT UNIQUE,
  display_name TEXT,
  bio TEXT,
  avatar_url TEXT,
  location_lat DECIMAL(10, 8),
  location_lng DECIMAL(11, 8),
  location_name TEXT,
  reputation_score INTEGER DEFAULT 0,
  is_reviewer BOOLEAN DEFAULT FALSE,
  reviewer_since TIMESTAMP WITH TIME ZONE,
  total_words_submitted INTEGER DEFAULT 0,
  total_words_approved INTEGER DEFAULT 0,
  total_reviews_completed INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Words table - core entity for slang terms
CREATE TABLE public.words (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  word TEXT NOT NULL,
  definition TEXT NOT NULL,
  usage_example TEXT,
  pronunciation_audio_url TEXT,
  submitter_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  
  -- Geographic data
  origin_lat DECIMAL(10, 8),
  origin_lng DECIMAL(11, 8),
  origin_location TEXT,
  
  -- Status tracking
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'under_review', 'approved', 'rejected', 'minted')),
  
  -- Blockchain data
  nft_token_id TEXT UNIQUE,
  xrpl_transaction_hash TEXT,
  mint_date TIMESTAMP WITH TIME ZONE,
  
  -- Metadata
  category TEXT,
  tags TEXT[],
  cultural_context TEXT,
  alternative_spellings TEXT[],
  
  -- Timestamps
  submitted_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  reviewed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Reviews table - community voting system
CREATE TABLE public.reviews (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  word_id UUID REFERENCES public.words(id) ON DELETE CASCADE NOT NULL,
  reviewer_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  
  -- Review decision
  decision TEXT NOT NULL CHECK (decision IN ('approve', 'reject')),
  reasoning TEXT,
  
  -- Review criteria scores (1-5 scale)
  originality_score INTEGER CHECK (originality_score >= 1 AND originality_score <= 5),
  clarity_score INTEGER CHECK (clarity_score >= 1 AND clarity_score <= 5),
  cultural_relevance_score INTEGER CHECK (cultural_relevance_score >= 1 AND cultural_relevance_score <= 5),
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  
  -- Ensure one review per reviewer per word
  UNIQUE(word_id, reviewer_id)
);

-- Word encounters - tracking "first heard" reports
CREATE TABLE public.word_encounters (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  word_id UUID REFERENCES public.words(id) ON DELETE CASCADE NOT NULL,
  reporter_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  
  -- Encounter details
  encounter_date DATE NOT NULL,
  encounter_lat DECIMAL(10, 8),
  encounter_lng DECIMAL(11, 8),
  encounter_location TEXT,
  context TEXT, -- Where they heard it (social media, friend, TV, etc.)
  
  -- Metadata
  confidence_level INTEGER DEFAULT 5 CHECK (confidence_level >= 1 AND confidence_level <= 5),
  notes TEXT,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  
  -- Prevent duplicate encounters from same user for same word
  UNIQUE(word_id, reporter_id)
);

-- NFT metadata for blockchain records
CREATE TABLE public.nft_metadata (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  word_id UUID REFERENCES public.words(id) ON DELETE CASCADE NOT NULL,
  token_id TEXT UNIQUE NOT NULL,
  
  -- XRPL specific data
  xrpl_transaction_hash TEXT NOT NULL,
  xrpl_ledger_index INTEGER,
  owner_wallet_address TEXT,
  
  -- NFT metadata following standard format
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  image_url TEXT,
  attributes JSONB, -- Flexible metadata storage
  
  -- Timestamps
  minted_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Search conflicts - track similar words found during submission
CREATE TABLE public.search_conflicts (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  submitted_word_id UUID REFERENCES public.words(id) ON DELETE CASCADE NOT NULL,
  conflicting_word_id UUID REFERENCES public.words(id) ON DELETE CASCADE NOT NULL,
  similarity_score DECIMAL(3, 2), -- 0.00 to 1.00
  conflict_type TEXT CHECK (conflict_type IN ('phonetic', 'semantic', 'spelling', 'definition')),
  resolved BOOLEAN DEFAULT FALSE,
  resolution_notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Indexes for performance
CREATE INDEX idx_words_status ON public.words(status);
CREATE INDEX idx_words_submitter ON public.words(submitter_id);
CREATE INDEX idx_words_word_text ON public.words USING gin(to_tsvector('english', word));
CREATE INDEX idx_words_definition_text ON public.words USING gin(to_tsvector('english', definition));
CREATE INDEX idx_words_tags ON public.words USING gin(tags);
CREATE INDEX idx_words_created_at ON public.words(created_at);
CREATE INDEX idx_reviews_word_id ON public.reviews(word_id);
CREATE INDEX idx_reviews_reviewer_id ON public.reviews(reviewer_id);
CREATE INDEX idx_word_encounters_word_id ON public.word_encounters(word_id);
CREATE INDEX idx_word_encounters_date ON public.word_encounters(encounter_date);

-- Row Level Security (RLS) policies
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.words ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.word_encounters ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.nft_metadata ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.search_conflicts ENABLE ROW LEVEL SECURITY;

-- Profiles: Users can read all profiles, but only update their own
CREATE POLICY "Public profiles are viewable by everyone" ON public.profiles
  FOR SELECT USING (true);

CREATE POLICY "Users can update their own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile" ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Words: Public read, authenticated users can submit
CREATE POLICY "Words are viewable by everyone" ON public.words
  FOR SELECT USING (true);

CREATE POLICY "Authenticated users can submit words" ON public.words
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Users can update their own submitted words" ON public.words
  FOR UPDATE USING (auth.uid() = submitter_id AND status = 'pending');

-- Reviews: Only reviewers can create, public can read approved reviews
CREATE POLICY "Approved reviews are viewable by everyone" ON public.reviews
  FOR SELECT USING (true);

CREATE POLICY "Reviewers can create reviews" ON public.reviews
  FOR INSERT WITH CHECK (
    auth.role() = 'authenticated' AND 
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_reviewer = true)
  );

-- Word encounters: Users can add their own, public can read all
CREATE POLICY "Word encounters are viewable by everyone" ON public.word_encounters
  FOR SELECT USING (true);

CREATE POLICY "Authenticated users can add encounters" ON public.word_encounters
  FOR INSERT WITH CHECK (auth.role() = 'authenticated' AND auth.uid() = reporter_id);

-- NFT metadata: Public read only (managed by system)
CREATE POLICY "NFT metadata is viewable by everyone" ON public.nft_metadata
  FOR SELECT USING (true);

-- Search conflicts: System managed, public read
CREATE POLICY "Search conflicts are viewable by everyone" ON public.search_conflicts
  FOR SELECT USING (true);

-- Functions for common operations

-- Function to update reputation score
CREATE OR REPLACE FUNCTION update_user_reputation()
RETURNS TRIGGER AS $$
BEGIN
  -- Update reputation based on approved words and completed reviews
  UPDATE public.profiles SET
    reputation_score = (
      (total_words_approved * 10) + -- 10 points per approved word
      (total_reviews_completed * 2) -- 2 points per review completed
    ),
    updated_at = NOW()
  WHERE id = NEW.submitter_id OR id = NEW.reviewer_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update user stats when words are approved
CREATE OR REPLACE FUNCTION update_user_stats_on_word_approval()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'approved' AND OLD.status != 'approved' THEN
    UPDATE public.profiles SET
      total_words_approved = total_words_approved + 1,
      updated_at = NOW()
    WHERE id = NEW.submitter_id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_user_stats_on_word_approval
  AFTER UPDATE ON public.words
  FOR EACH ROW
  EXECUTE FUNCTION update_user_stats_on_word_approval();

-- Function to check if a word has enough reviews for approval
CREATE OR REPLACE FUNCTION check_word_review_completion()
RETURNS TRIGGER AS $$
DECLARE
  review_count INTEGER;
  approve_count INTEGER;
BEGIN
  -- Count total reviews and approvals for this word
  SELECT COUNT(*), COUNT(*) FILTER (WHERE decision = 'approve')
  INTO review_count, approve_count
  FROM public.reviews
  WHERE word_id = NEW.word_id;
  
  -- If we have 3 reviews, update word status
  IF review_count >= 3 THEN
    IF approve_count >= 2 THEN
      -- 2+ approvals = approved
      UPDATE public.words SET
        status = 'approved',
        reviewed_at = NOW(),
        updated_at = NOW()
      WHERE id = NEW.word_id;
    ELSE
      -- Less than 2 approvals = rejected
      UPDATE public.words SET
        status = 'rejected',
        reviewed_at = NOW(),
        updated_at = NOW()
      WHERE id = NEW.word_id;
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_word_review_completion
  AFTER INSERT ON public.reviews
  FOR EACH ROW
  EXECUTE FUNCTION check_word_review_completion();

-- Function to update timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at triggers to all tables
CREATE TRIGGER trigger_profiles_updated_at BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_words_updated_at BEFORE UPDATE ON public.words
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_reviews_updated_at BEFORE UPDATE ON public.reviews
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_nft_metadata_updated_at BEFORE UPDATE ON public.nft_metadata
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
