// Code generated by sqlc. DO NOT EDIT.
// source: select.sql

package entity

import (
	"context"
)

const select1 = `-- name: Select1 :one
SELECT 1
`

func (q *Queries) Select1(ctx context.Context) (interface{}, error) {
	row := q.db.QueryRowContext(ctx, select1)
	var column_1 interface{}
	err := row.Scan(&column_1)
	return column_1, err
}