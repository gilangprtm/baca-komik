-- Add external_id columns to track original IDs from external API
-- This allows us to maintain mapping between our IDs and their IDs

-- Add external_id to mKomik table
ALTER TABLE "mKomik" ADD COLUMN IF NOT EXISTS external_id VARCHAR(255);
CREATE UNIQUE INDEX IF NOT EXISTS idx_mkomik_external_id ON "mKomik"(external_id);

-- Add external_id to mChapter table  
ALTER TABLE "mChapter" ADD COLUMN IF NOT EXISTS external_id VARCHAR(255);
CREATE UNIQUE INDEX IF NOT EXISTS idx_mchapter_external_id ON "mChapter"(external_id);

-- Add chapter_title to mChapter table (from API response)
ALTER TABLE "mChapter" ADD COLUMN IF NOT EXISTS chapter_title VARCHAR(255);

-- Add pages_data to mChapter table to store page information as JSON
ALTER TABLE "mChapter" ADD COLUMN IF NOT EXISTS pages_data JSONB;

-- Add updated_at columns for tracking changes
ALTER TABLE "mKomik" ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT NOW();
ALTER TABLE "mChapter" ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT NOW();
ALTER TABLE "mGenre" ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT NOW();
ALTER TABLE "mGenre" ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT NOW();
ALTER TABLE "mFormat" ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT NOW();
ALTER TABLE "mFormat" ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT NOW();
ALTER TABLE "mType" ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT NOW();
ALTER TABLE "mType" ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT NOW();
ALTER TABLE "mAuthor" ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT NOW();
ALTER TABLE "mAuthor" ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT NOW();
ALTER TABLE "mArtist" ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT NOW();
ALTER TABLE "mArtist" ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT NOW();

-- Create URL configuration table for managing external URLs
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

-- Insert initial URL configurations
INSERT INTO "mUrlConfig" (service_name, url_type, url_value) VALUES
('shinigami_storage', 'base_url', 'https://storage.shngm.id'),
('shinigami_storage', 'base_url_low', 'https://storage.shngm.id/low/unsafe/filters:format(webp):quality(70)'),
('shinigami_api', 'api_base', 'https://api.shngm.io/v1')
ON CONFLICT (service_name, url_type) DO NOTHING;

-- Create asset table for tracking image/file URLs
CREATE TABLE IF NOT EXISTS "mAsset" (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_type VARCHAR(20) NOT NULL,
    original_url TEXT NOT NULL,
    relative_path TEXT NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    manga_id UUID REFERENCES "mKomik"(id) ON DELETE CASCADE,
    chapter_id UUID REFERENCES "mChapter"(id) ON DELETE CASCADE,
    page_order INTEGER,
    is_available BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_masset_manga_id ON "mAsset"(manga_id);
CREATE INDEX IF NOT EXISTS idx_masset_chapter_id ON "mAsset"(chapter_id);
CREATE INDEX IF NOT EXISTS idx_masset_type ON "mAsset"(asset_type);

-- Create crawl progress tracking table
CREATE TABLE IF NOT EXISTS "mCrawlProgress" (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mode VARCHAR(50) NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP,
    total_items INTEGER DEFAULT 0,
    processed_items INTEGER DEFAULT 0,
    success_items INTEGER DEFAULT 0,
    failed_items INTEGER DEFAULT 0,
    current_page INTEGER DEFAULT 1,
    status VARCHAR(20) DEFAULT 'running',
    error_message TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Create index for crawl progress
CREATE INDEX IF NOT EXISTS idx_mcrawlprogress_mode ON "mCrawlProgress"(mode);
CREATE INDEX IF NOT EXISTS idx_mcrawlprogress_status ON "mCrawlProgress"(status);
