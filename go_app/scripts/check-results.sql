-- Check crawling results in database
-- Run these queries in your PostgreSQL client

-- 1. Check total manga count
SELECT 
    'Total Manga' as table_name,
    COUNT(*) as total_count,
    COUNT(CASE WHEN external_id IS NOT NULL THEN 1 END) as with_external_id
FROM "mKomik";

-- 2. Check chapters count
SELECT 
    'Total Chapters' as table_name,
    COUNT(*) as total_count,
    COUNT(CASE WHEN external_id IS NOT NULL THEN 1 END) as with_external_id,
    COUNT(CASE WHEN pages_data IS NOT NULL THEN 1 END) as with_pages_data
FROM "mChapter";

-- 3. Check recent chapters (last 50)
SELECT 
    c.external_id,
    c.chapter_number,
    c.chapter_title,
    c.view_count,
    c.created_date,
    CASE WHEN c.pages_data IS NOT NULL THEN 'Yes' ELSE 'No' END as has_pages,
    m.title as manga_title
FROM "mChapter" c
LEFT JOIN "mKomik" m ON c.id_komik = m.id
WHERE c.external_id IS NOT NULL
ORDER BY c.created_date DESC
LIMIT 50;

-- 4. Check chapters by manga (top 10 manga with most chapters)
SELECT 
    m.title as manga_title,
    m.external_id as manga_external_id,
    COUNT(c.id) as chapter_count,
    COUNT(CASE WHEN c.pages_data IS NOT NULL THEN 1 END) as chapters_with_pages
FROM "mKomik" m
LEFT JOIN "mChapter" c ON m.id = c.id_komik AND c.external_id IS NOT NULL
WHERE m.external_id IS NOT NULL
GROUP BY m.id, m.title, m.external_id
ORDER BY chapter_count DESC
LIMIT 10;

-- 5. Check sample pages data structure
SELECT 
    external_id,
    chapter_number,
    chapter_title,
    LEFT(pages_data::text, 200) as pages_data_sample
FROM "mChapter"
WHERE pages_data IS NOT NULL
LIMIT 5;

-- 6. Check for any errors or missing data
SELECT 
    'Chapters without manga' as issue_type,
    COUNT(*) as count
FROM "mChapter" c
LEFT JOIN "mKomik" m ON c.id_komik = m.id
WHERE m.id IS NULL AND c.external_id IS NOT NULL

UNION ALL

SELECT 
    'Manga without chapters' as issue_type,
    COUNT(*) as count
FROM "mKomik" m
LEFT JOIN "mChapter" c ON m.id = c.id_komik AND c.external_id IS NOT NULL
WHERE m.external_id IS NOT NULL AND c.id IS NULL;
