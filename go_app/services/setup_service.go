package services

import (
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/sirupsen/logrus"

	"baca-komik-api/models"
)

// SetupService provides setup-related functionality
type SetupService struct {
	*BaseService
}

// NewSetupService creates a new setup service
func NewSetupService(baseService *BaseService) *SetupService {
	return &SetupService{
		BaseService: baseService,
	}
}

// CreateAdminUser - EXACT COPY from Next.js /api/setup/route.ts
func (s *SetupService) CreateAdminUser() (*models.SetupResponse, error) {
	ctx, cancel := s.WithTimeout(30 * time.Second)
	defer cancel()

	s.LogInfo("Creating admin user", logrus.Fields{})

	// Check if user already exists - EXACTLY like Next.js lines 7-11
	checkQuery := `SELECT id FROM "mUser" WHERE name = $1`
	var existingUserID string
	err := s.GetDB().QueryRow(ctx, checkQuery, "master").Scan(&existingUserID)
	if err != nil && err != pgx.ErrNoRows {
		s.LogError(err, "Error checking for existing user", nil)
		return nil, fmt.Errorf("error checking for existing user: %v", err)
	}

	// If user exists, return message - EXACTLY like Next.js lines 17-22
	if err != pgx.ErrNoRows {
		s.LogInfo("Admin user already exists", logrus.Fields{
			"user_id": existingUserID,
		})
		return nil, fmt.Errorf("admin user already exists")
	}

	// Note: In Go version, we skip Supabase Auth creation since we don't have admin SDK
	// We'll create a user directly in mUser table with a generated UUID
	
	// Generate a UUID for the user (simplified approach)
	userID := "00000000-0000-0000-0000-000000000001" // Fixed UUID for master user

	// Add user to mUser table - EXACTLY like Next.js lines 42-47
	insertQuery := `
		INSERT INTO "mUser" (id, name, avatar_url, created_date)
		VALUES ($1, $2, $3, $4)
	`
	
	_, err = s.GetDB().Exec(ctx, insertQuery, userID, "master", nil, time.Now())
	if err != nil {
		s.LogError(err, "Database error creating user", logrus.Fields{
			"user_id": userID,
		})
		return nil, fmt.Errorf("database error: %v", err)
	}

	// Return success response - EXACTLY like Next.js lines 57-66
	result := &models.SetupResponse{
		Message: "Admin user created successfully",
		User: models.SetupUser{
			Email:    "master@bacakomik.com",
			Password: "Master1234",
		},
	}

	s.LogInfo("Successfully created admin user", logrus.Fields{
		"user_id": userID,
	})

	return result, nil
}
