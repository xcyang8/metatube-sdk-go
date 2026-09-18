package engine

import (
	"fmt"

	"github.com/metatube-community/metatube-sdk-go/database"
	"github.com/metatube-community/metatube-sdk-go/model"
)

func (e *Engine) DBAutoMigrate(v bool) error {
	if !v || e.noDB {
		return nil
	}
	// Create Case-Insensitive Collation for Postgres.
	if e.DBDriver() == database.Postgres {
		e.db.Exec(`CREATE COLLATION IF NOT EXISTS NOCASE (
		provider = icu,
		locale = 'und-u-ks-level2',
		deterministic = FALSE)`)
	}
	return e.db.AutoMigrate(
		&model.MovieInfo{},
		&model.ActorInfo{},
		&model.MovieReviewInfo{},
	)
}

func (e *Engine) DBDriver() string {
	if e.noDB {
		return "none"
	}
	return e.db.Name()
}

func (e *Engine) DBVersion() (version string, err error) {
	if e.noDB {
		return "", fmt.Errorf("no database mode enabled")
	}
	switch dbType := e.DBDriver(); dbType {
	case database.Postgres:
		err = e.db.Raw("SELECT version();").Scan(&version).Error
	case database.Sqlite:
		err = e.db.Raw("SELECT sqlite_version();").Scan(&version).Error
	default:
		err = fmt.Errorf("unsupported DB type: %s", dbType)
	}
	return
}
