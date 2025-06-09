-- Safe migration to avoid data redundancy
-- This migration adds external_id columns and handles existing data

-- Step 1: Add external_id columns (safe, won't affect existing data)
ALTER TABLE "mKomik" ADD COLUMN IF NOT EXISTS external_id VARCHAR(255);
ALTER TABLE "mChapter" ADD COLUMN IF NOT EXISTS external_id VARCHAR(255);
ALTER TABLE "mChapter" ADD COLUMN IF NOT EXISTS chapter_title VARCHAR(255);
ALTER TABLE "mChapter" ADD COLUMN IF NOT EXISTS pages_data JSONB;

-- Step 2: Add updated_at columns for tracking
ALTER TABLE "mKomik" ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT NOW();
ALTER TABLE "mChapter" ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT NOW();
ALTER TABLE "mGenre" ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT NOW();
ALTER TABLE "mGenre" ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT NOW();
ALTER TABLE "mFormat" ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT NOW();
ALTER TABLE "mFormat" ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT NOW();
ALTER TABLE "mAuthor" ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT NOW();
ALTER TABLE "mAuthor" ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT NOW();
ALTER TABLE "mArtist" ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT NOW();
ALTER TABLE "mArtist" ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT NOW();

-- Step 3: Create unique indexes (only after columns exist)
CREATE UNIQUE INDEX IF NOT EXISTS idx_mkomik_external_id ON "mKomik"(external_id) WHERE external_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS idx_mchapter_external_id ON "mChapter"(external_id) WHERE external_id IS NOT NULL;

-- Step 4: Create URL configuration table
CREATE TABLE IF NOT EXISTS "mUrlConfig" (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service_name VARCHAR(50) NOT NULL,
    url_type VARCHAR(30) NOT NULL,
    url_value TEXT NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(service_name, url_type)
);

-- Step 5: Insert URL configurations
INSERT INTO "mUrlConfig" (service_name, url_type, url_value) VALUES
('shinigami_storage', 'base_url', 'https://storage.shngm.id'),
('shinigami_storage', 'base_url_low', 'https://storage.shngm.id/low/unsafe/filters:format(webp):quality(70)'),
('shinigami_api', 'api_base', 'https://api.shngm.io/v1'),
('github_storage', 'base_url', 'https://raw.githubusercontent.com/edjavuofc'),
('local_storage', 'base_url', '/storage/images')
ON CONFLICT (service_name, url_type) DO NOTHING;

-- Step 6: Create mapping table for existing vs external data
CREATE TABLE IF NOT EXISTS "mDataMapping" (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    internal_id UUID NOT NULL,
    external_id VARCHAR(255) NOT NULL,
    table_name VARCHAR(50) NOT NULL,
    mapping_type VARCHAR(20) DEFAULT 'manual', -- 'manual', 'crawled', 'verified'
    confidence_score FLOAT DEFAULT 0.0, -- 0.0 to 1.0
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(internal_id, table_name),
    UNIQUE(external_id, table_name)
);

-- Step 7: Create indexes for mapping table
CREATE INDEX IF NOT EXISTS idx_mdatamapping_internal ON "mDataMapping"(internal_id);
CREATE INDEX IF NOT EXISTS idx_mdatamapping_external ON "mDataMapping"(external_id);
CREATE INDEX IF NOT EXISTS idx_mdatamapping_table ON "mDataMapping"(table_name);

-- Step 8: Add source tracking to existing tables
ALTER TABLE "mKomik" ADD COLUMN IF NOT EXISTS data_source VARCHAR(50) DEFAULT 'manual';
ALTER TABLE "mChapter" ADD COLUMN IF NOT EXISTS data_source VARCHAR(50) DEFAULT 'manual';

-- Step 9: Update existing data to mark as manual
UPDATE "mKomik" SET data_source = 'manual' WHERE data_source IS NULL;
UPDATE "mChapter" SET data_source = 'manual' WHERE data_source IS NULL;

-- Step 10: Create view for unified manga data
CREATE OR REPLACE VIEW "vMangaUnified" AS
SELECT 
    k.id,
    k.title,
    k.alternative_title,
    k.description,
    k.status,
    k.country_id,
    k.view_count,
    k.vote_count,
    k.bookmark_count,
    k.cover_image_url,
    k.created_date,
    k.rank,
    k.release_year,
    k.external_id,
    k.data_source,
    k.updated_at,
    dm.external_id as mapped_external_id,
    dm.confidence_score,
    dm.mapping_type
FROM "mKomik" k
LEFT JOIN "mDataMapping" dm ON k.id = dm.internal_id AND dm.table_name = 'mKomik';

-- Step 11: Create function to check for potential duplicates
CREATE OR REPLACE FUNCTION check_manga_duplicates(
    p_title TEXT,
    p_external_id TEXT DEFAULT NULL
) RETURNS TABLE (
    id UUID,
    title TEXT,
    external_id TEXT,
    similarity_score FLOAT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        k.id,
        k.title,
        k.external_id,
        CASE 
            WHEN k.external_id = p_external_id THEN 1.0
            WHEN LOWER(k.title) = LOWER(p_title) THEN 0.9
            WHEN LOWER(k.title) LIKE '%' || LOWER(p_title) || '%' THEN 0.7
            WHEN LOWER(p_title) LIKE '%' || LOWER(k.title) || '%' THEN 0.7
            ELSE 0.0
        END as similarity_score
    FROM "mKomik" k
    WHERE 
        (k.external_id = p_external_id AND p_external_id IS NOT NULL)
        OR LOWER(k.title) LIKE '%' || LOWER(p_title) || '%'
        OR LOWER(p_title) LIKE '%' || LOWER(k.title) || '%'
    ORDER BY similarity_score DESC;
END;
$$ LANGUAGE plpgsql;
