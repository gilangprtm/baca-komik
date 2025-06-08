package database

import (
	"context"
	"fmt"
	"log"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"baca-komik-api/config"
)

type DB struct {
	Pool *pgxpool.Pool
}

func Connect(cfg *config.Config) (*DB, error) {
	log.Printf("Attempting to connect to database: %s:%s", cfg.DBHost, cfg.DBPort)

	// Build connection string for Supabase
	var dsn string
	var password string

	// Determine password to use
	if cfg.DBPassword != "" {
		password = cfg.DBPassword
		log.Printf("Using DB_PASSWORD auth with user: %s", cfg.DBUser)
	} else if cfg.SupabaseServiceKey != "" {
		password = cfg.SupabaseServiceKey
		log.Printf("Using Supabase service key auth with user: %s", cfg.DBUser)
	} else {
		return nil, fmt.Errorf("no password or service key provided for database connection")
	}

	// For pooler connections, always use the password-based auth
	dsn = fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=%s connect_timeout=30",
		cfg.DBHost,
		cfg.DBPort,
		cfg.DBUser,
		password,
		cfg.DBName,
		cfg.DBSSLMode,
	)

	// Configure connection pool
	poolConfig, err := pgxpool.ParseConfig(dsn)
	if err != nil {
		return nil, fmt.Errorf("failed to parse database config: %w", err)
	}

	// Set pool configuration for production
	poolConfig.MaxConns = 10  // Reduced for Railway limits
	poolConfig.MinConns = 2
	poolConfig.MaxConnLifetime = time.Minute * 30
	poolConfig.MaxConnIdleTime = time.Minute * 10
	poolConfig.HealthCheckPeriod = time.Minute * 2
	poolConfig.ConnConfig.ConnectTimeout = time.Second * 30

	// Create connection pool
	pool, err := pgxpool.NewWithConfig(context.Background(), poolConfig)
	if err != nil {
		return nil, fmt.Errorf("failed to create connection pool: %w", err)
	}

	// Test connection
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := pool.Ping(ctx); err != nil {
		pool.Close()
		return nil, fmt.Errorf("failed to ping database: %w", err)
	}

	log.Println("Successfully connected to database")

	return &DB{Pool: pool}, nil
}

func (db *DB) Close() {
	if db.Pool != nil {
		db.Pool.Close()
		log.Println("Database connection closed")
	}
}

func (db *DB) Health() error {
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	return db.Pool.Ping(ctx)
}
