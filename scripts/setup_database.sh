#!/bin/bash

# HellaFresh Database Setup Script
# This script helps you initialize your Supabase database

echo "🚀 HellaFresh Database Setup"
echo "================================"

# Check if .env exists
if [ ! -f .env ]; then
    echo "❌ .env file not found!"
    echo "📝 Please copy .env.example to .env and configure your Supabase credentials"
    echo "   cp .env.example .env"
    exit 1
fi

# Load environment variables
source .env

# Check required variables
if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_SERVICE_ROLE_KEY" ]; then
    echo "❌ Missing required environment variables!"
    echo "📝 Please configure SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY in your .env file"
    exit 1
fi

echo "📋 Database setup options:"
echo "1. Initialize schema only"
echo "2. Initialize schema + sample data"
echo "3. Reset database (drop all tables and recreate)"
echo ""
read -p "Choose option (1-3): " option

case $option in
    1)
        echo "📊 Setting up database schema..."
        ;;
    2)
        echo "📊 Setting up database schema with sample data..."
        ;;
    3)
        echo "⚠️  WARNING: This will delete ALL data in your database!"
        read -p "Are you sure? (type 'yes' to confirm): " confirm
        if [ "$confirm" != "yes" ]; then
            echo "❌ Operation cancelled"
            exit 1
        fi
        echo "🗑️  Resetting database..."
        ;;
    *)
        echo "❌ Invalid option"
        exit 1
        ;;
esac

# Function to execute SQL file
execute_sql() {
    local file=$1
    echo "📄 Executing $file..."
    
    # Use curl to execute SQL via Supabase REST API
    # Note: In production, you'd use proper database client
    curl -X POST \
        "$SUPABASE_URL/rest/v1/rpc/execute_sql" \
        -H "apikey: $SUPABASE_SERVICE_ROLE_KEY" \
        -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
        -H "Content-Type: application/json" \
        --data "{\"sql_content\": \"$(cat $file | sed 's/"/\\"/g' | tr -d '\n')\"}" \
        --silent --output /dev/null
    
    if [ $? -eq 0 ]; then
        echo "✅ $file executed successfully"
    else
        echo "❌ Failed to execute $file"
        echo "💡 Manual setup required:"
        echo "   1. Go to your Supabase dashboard"
        echo "   2. Open the SQL Editor"
        echo "   3. Copy and paste the contents of $file"
        echo "   4. Run the query"
    fi
}

# Reset database if option 3
if [ $option -eq 3 ]; then
    echo "🗑️  Dropping existing tables..."
    cat > /tmp/reset.sql << 'EOF'
-- Drop all custom tables (in dependency order)
DROP TABLE IF EXISTS public.search_conflicts CASCADE;
DROP TABLE IF EXISTS public.nft_metadata CASCADE;
DROP TABLE IF EXISTS public.word_encounters CASCADE;
DROP TABLE IF EXISTS public.reviews CASCADE;
DROP TABLE IF EXISTS public.words CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;

-- Drop custom functions
DROP FUNCTION IF EXISTS update_user_reputation() CASCADE;
DROP FUNCTION IF EXISTS update_user_stats_on_word_approval() CASCADE;
DROP FUNCTION IF EXISTS check_word_review_completion() CASCADE;
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;
DROP FUNCTION IF EXISTS get_word_stats() CASCADE;
DROP FUNCTION IF EXISTS get_trending_words_by_location(TEXT) CASCADE;
DROP FUNCTION IF EXISTS search_words_fuzzy(TEXT) CASCADE;
EOF
    execute_sql "/tmp/reset.sql"
    rm /tmp/reset.sql
fi

# Execute main schema
execute_sql "database/schema.sql"

# Execute sample data if option 2
if [ $option -eq 2 ]; then
    execute_sql "database/sample_data.sql"
fi

echo ""
echo "🎉 Database setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Verify tables were created in your Supabase dashboard"
echo "2. Configure Row Level Security policies if needed"
echo "3. Start the development servers with 'npm run dev'"
echo ""
echo "🔧 Useful SQL commands to test:"
echo "   SELECT * FROM get_word_stats();"
echo "   SELECT * FROM search_words_fuzzy('bussin');"
echo "   SELECT * FROM get_trending_words_by_location('CA');"
