-- Sample data for development and testing
-- Run after setting up the main schema

-- Insert sample profiles (these will be linked to actual auth.users when they sign up)
-- For now, we'll use UUIDs that can be replaced with real user IDs later

-- Sample words for testing search and conflict detection
INSERT INTO public.words (word, definition, usage_example, origin_location, status, category, tags, cultural_context, submitted_at) VALUES
  ('bussin', 'Extremely good, excellent, or delicious', 'This pizza is absolutely bussin!', 'Atlanta, GA', 'approved', 'food', ARRAY['food', 'praise'], 'Popular among Gen Z, especially on TikTok', '2023-01-15 10:00:00+00'),
  
  ('salty', 'Being bitter or upset about something', 'He''s still salty about losing the game', 'Los Angeles, CA', 'approved', 'emotion', ARRAY['emotion', 'attitude'], 'Gaming and sports communities', '2023-02-01 14:30:00+00'),
  
  ('periodt', 'End of discussion, no argument', 'I''m the best at this game, periodt!', 'New York, NY', 'approved', 'emphasis', ARRAY['emphasis', 'finality'], 'AAVE influence, widespread on social media', '2023-02-15 09:45:00+00'),
  
  ('fire', 'Something that is really good or awesome', 'That new song is fire!', 'Chicago, IL', 'approved', 'praise', ARRAY['music', 'praise'], 'Hip-hop culture, now mainstream', '2023-03-01 16:20:00+00'),
  
  ('mid', 'Average, mediocre, not impressive', 'The movie was pretty mid, not worth watching', 'Austin, TX', 'approved', 'criticism', ARRAY['criticism', 'quality'], 'Gaming communities, now broader usage', '2023-03-10 11:15:00+00'),
  
  ('no cap', 'No lie, telling the truth', 'This burger is amazing, no cap!', 'Miami, FL', 'approved', 'truth', ARRAY['truth', 'emphasis'], 'Hip-hop culture, widespread adoption', '2023-03-20 13:00:00+00'),
  
  ('bet', 'Yes, okay, sounds good', 'Want to go to the movies? Bet!', 'Detroit, MI', 'approved', 'agreement', ARRAY['agreement', 'confirmation'], 'Urban communities, now mainstream', '2023-04-01 08:30:00+00'),
  
  -- Pending words for testing review system
  ('chefs_kiss', 'Perfect, exactly right', 'That comeback was *chef''s kiss*', 'San Francisco, CA', 'pending', 'praise', ARRAY['praise', 'perfection'], 'Food culture meets social media', '2023-11-01 10:00:00+00'),
  
  ('lowkey', 'Somewhat, kind of, secretly', 'I''m lowkey excited for this', 'Portland, OR', 'under_review', 'modifier', ARRAY['modifier', 'secrecy'], 'Youth slang, widespread usage', '2023-11-15 14:20:00+00'),
  
  ('slaps', 'Something that is really good, especially music', 'This new album absolutely slaps!', 'Nashville, TN', 'pending', 'music', ARRAY['music', 'praise'], 'Music communities, TikTok influence', '2023-12-01 16:45:00+00');

-- Sample word encounters (first heard reports)
INSERT INTO public.word_encounters (word_id, encounter_date, encounter_location, context, confidence_level, notes) 
SELECT 
  w.id,
  '2023-06-01'::date,
  'Denver, CO',
  'TikTok video',
  5,
  'Saw it in a viral cooking video'
FROM public.words w WHERE w.word = 'bussin';

INSERT INTO public.word_encounters (word_id, encounter_date, encounter_location, context, confidence_level, notes)
SELECT 
  w.id,
  '2023-07-15'::date,
  'Phoenix, AZ',
  'Friend conversation',
  4,
  'Friend used it when talking about a restaurant'
FROM public.words w WHERE w.word = 'bussin';

-- Sample search conflicts for testing conflict detection
INSERT INTO public.search_conflicts (submitted_word_id, conflicting_word_id, similarity_score, conflict_type, resolved)
SELECT 
  w1.id as submitted_word_id,
  w2.id as conflicting_word_id,
  0.85,
  'semantic',
  true
FROM public.words w1, public.words w2 
WHERE w1.word = 'fire' AND w2.word = 'bussin';

-- Sample NFT metadata for approved words
INSERT INTO public.nft_metadata (word_id, token_id, xrpl_transaction_hash, owner_wallet_address, name, description, attributes)
SELECT 
  w.id,
  'HF-' || w.word || '-001',
  '1234567890ABCDEF' || w.id,
  'rTestWalletAddress123456789',
  'HellaFresh: ' || w.word,
  'Origin NFT for the slang term "' || w.word || '" - ' || w.definition,
  jsonb_build_object(
    'word', w.word,
    'origin_location', w.origin_location,
    'category', w.category,
    'submitted_date', w.submitted_at,
    'cultural_context', w.cultural_context
  )
FROM public.words w 
WHERE w.status = 'approved';

-- Update words to reference their NFT tokens
UPDATE public.words SET 
  nft_token_id = nft.token_id,
  xrpl_transaction_hash = nft.xrpl_transaction_hash,
  mint_date = nft.minted_at,
  status = 'minted'
FROM public.nft_metadata nft
WHERE public.words.id = nft.word_id AND public.words.status = 'approved';

-- Create some test functions for development

-- Function to get word statistics
CREATE OR REPLACE FUNCTION get_word_stats()
RETURNS TABLE (
  total_words BIGINT,
  pending_words BIGINT,
  approved_words BIGINT,
  minted_words BIGINT,
  total_encounters BIGINT,
  total_reviews BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    (SELECT COUNT(*) FROM public.words) as total_words,
    (SELECT COUNT(*) FROM public.words WHERE status = 'pending') as pending_words,
    (SELECT COUNT(*) FROM public.words WHERE status = 'approved') as approved_words,
    (SELECT COUNT(*) FROM public.words WHERE status = 'minted') as minted_words,
    (SELECT COUNT(*) FROM public.word_encounters) as total_encounters,
    (SELECT COUNT(*) FROM public.reviews) as total_reviews;
END;
$$ LANGUAGE plpgsql;

-- Function to get trending words by region
CREATE OR REPLACE FUNCTION get_trending_words_by_location(location_name TEXT DEFAULT NULL)
RETURNS TABLE (
  word TEXT,
  definition TEXT,
  encounter_count BIGINT,
  latest_encounter DATE
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    w.word,
    w.definition,
    COUNT(we.id) as encounter_count,
    MAX(we.encounter_date) as latest_encounter
  FROM public.words w
  LEFT JOIN public.word_encounters we ON w.id = we.word_id
  WHERE (location_name IS NULL OR we.encounter_location ILIKE '%' || location_name || '%')
    AND w.status IN ('approved', 'minted')
  GROUP BY w.word, w.definition
  HAVING COUNT(we.id) > 0
  ORDER BY encounter_count DESC, latest_encounter DESC
  LIMIT 20;
END;
$$ LANGUAGE plpgsql;

-- Function to search words with fuzzy matching
CREATE OR REPLACE FUNCTION search_words_fuzzy(search_term TEXT)
RETURNS TABLE (
  id UUID,
  word TEXT,
  definition TEXT,
  status TEXT,
  similarity_score REAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    w.id,
    w.word,
    w.definition,
    w.status,
    GREATEST(
      similarity(w.word, search_term),
      similarity(w.definition, search_term)
    ) as similarity_score
  FROM public.words w
  WHERE 
    w.word ILIKE '%' || search_term || '%' OR
    w.definition ILIKE '%' || search_term || '%' OR
    similarity(w.word, search_term) > 0.3 OR
    similarity(w.definition, search_term) > 0.2
  ORDER BY similarity_score DESC, w.created_at DESC
  LIMIT 50;
END;
$$ LANGUAGE plpgsql;
