package services

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/sirupsen/logrus"
	"baca-komik-api/database"
)

// BaseService provides common functionality for all services
type BaseService struct {
	db     *database.DB
	logger *logrus.Logger
}

// NewBaseService creates a new base service
func NewBaseService(db *database.DB) *BaseService {
	logger := logrus.New()
	logger.SetFormatter(&logrus.JSONFormatter{})
	
	return &BaseService{
		db:     db,
		logger: logger,
	}
}

// GetDB returns the database connection pool
func (s *BaseService) GetDB() *pgxpool.Pool {
	return s.db.Pool
}

// GetLogger returns the logger instance
func (s *BaseService) GetLogger() *logrus.Logger {
	return s.logger
}

// WithTimeout creates a context with timeout
func (s *BaseService) WithTimeout(timeout time.Duration) (context.Context, context.CancelFunc) {
	return context.WithTimeout(context.Background(), timeout)
}

// LogError logs an error with context
func (s *BaseService) LogError(err error, message string, fields logrus.Fields) {
	if fields == nil {
		fields = logrus.Fields{}
	}
	fields["error"] = err.Error()
	s.logger.WithFields(fields).Error(message)
}

// LogInfo logs an info message with context
func (s *BaseService) LogInfo(message string, fields logrus.Fields) {
	if fields == nil {
		fields = logrus.Fields{}
	}
	s.logger.WithFields(fields).Info(message)
}

// LogDebug logs a debug message with context
func (s *BaseService) LogDebug(message string, fields logrus.Fields) {
	if fields == nil {
		fields = logrus.Fields{}
	}
	s.logger.WithFields(fields).Debug(message)
}
