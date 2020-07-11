package database

import (
	"errors"
	"strings"

	"github.com/lib/pq"
)

const DuplicatePrimaryKeyViolation = "23505"

var ErrSqlDuplicatePrimaryKey = errors.New("Duplicate entity error")

func IsDuplicateError(err error) bool {
	var pqErr *pq.Error
	if errors.As(err, &pqErr) {
		return pqErr.Code == DuplicatePrimaryKeyViolation
	}
	return false
}

func UniqueViolation(err error, column string) bool {
	var pqErr *pq.Error
	if errors.As(err, &pqErr) {
		isUniqueViolation := pqErr.Code.Name() == "unique_violation"
		return isUniqueViolation && strings.Contains(pqErr.Detail, column)
	}
	return false
}
