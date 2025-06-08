package services

import (
	"time"

	"github.com/sirupsen/logrus"
	"baca-komik-api/database"
)

// TestService provides database connection testing functionality
type TestService struct {
	*BaseService
}

// NewTestService creates a new test service
func NewTestService(db *database.DB) *TestService {
	return &TestService{
		BaseService: NewBaseService(db),
	}
}

// TestConnection tests the database connection
func (s *TestService) TestConnection() error {
	ctx, cancel := s.WithTimeout(5 * time.Second)
	defer cancel()

	s.LogInfo("Testing database connection", nil)

	// Test basic connection
	if err := s.GetDB().Ping(ctx); err != nil {
		s.LogError(err, "Database ping failed", nil)
		return err
	}

	s.LogInfo("Database ping successful", nil)
	return nil
}

// TestBasicQuery tests a basic query to verify database access
func (s *TestService) TestBasicQuery() error {
	ctx, cancel := s.WithTimeout(10 * time.Second)
	defer cancel()

	s.LogInfo("Testing basic database query", nil)

	// Test basic query - get count of comics
	var count int
	query := "SELECT COUNT(*) FROM \"mKomik\""
	
	if err := s.GetDB().QueryRow(ctx, query).Scan(&count); err != nil {
		s.LogError(err, "Basic query failed", logrus.Fields{
			"query": query,
		})
		return err
	}

	s.LogInfo("Basic query successful", logrus.Fields{
		"comics_count": count,
		"query":        query,
	})

	return nil
}

// TestTablesExist tests if required tables exist
func (s *TestService) TestTablesExist() error {
	ctx, cancel := s.WithTimeout(10 * time.Second)
	defer cancel()

	s.LogInfo("Testing required tables existence", nil)

	requiredTables := []string{
		"mKomik",
		"mChapter", 
		"mPage",
		"mGenre",
		"mAuthor",
		"mArtist",
		"mFormat",
		"mPopular",
		"mRecomed",
		"mUser",
		"trUserBookmark",
		"mKomikVote",
		"trChapterVote",
		"mComment",
	}

	for _, table := range requiredTables {
		var exists bool
		query := `
			SELECT EXISTS (
				SELECT FROM information_schema.tables 
				WHERE table_schema = 'public' 
				AND table_name = $1
			)
		`
		
		if err := s.GetDB().QueryRow(ctx, query, table).Scan(&exists); err != nil {
			s.LogError(err, "Failed to check table existence", logrus.Fields{
				"table": table,
				"query": query,
			})
			return err
		}

		if !exists {
			s.LogError(nil, "Required table does not exist", logrus.Fields{
				"table": table,
			})
			continue
		}

		s.LogDebug("Table exists", logrus.Fields{
			"table": table,
		})
	}

	s.LogInfo("Table existence check completed", logrus.Fields{
		"tables_checked": len(requiredTables),
	})

	return nil
}

// RunAllTests runs all database tests
func (s *TestService) RunAllTests() error {
	s.LogInfo("Starting comprehensive database tests", nil)

	// Test 1: Basic connection
	if err := s.TestConnection(); err != nil {
		return err
	}

	// Test 2: Basic query
	if err := s.TestBasicQuery(); err != nil {
		return err
	}

	// Test 3: Tables existence
	if err := s.TestTablesExist(); err != nil {
		return err
	}

	s.LogInfo("All database tests completed successfully", nil)
	return nil
}
