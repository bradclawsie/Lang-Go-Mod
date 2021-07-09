module github.com/example/my-project

go 1.16

exclude (
	example.com/whatmodule v1.4.0
)

replace (
	github.com/example/my-project/pkg/app => ./pkg/app
	github.com/example/my-project/pkg/app/client => ./pkg/app/client
	github.com/example/my-project/pkg/env => ./pkg/env
	github.com/example/my-project/pkg/schemas => ./pkg/schemas
	github.com/example/my-project/pkg/security => ./pkg/security
	github.com/example/my-project/pkg/state => ./pkg/state
)

require (
	github.com/dgrijalva/jwt-go v3.2.0+incompatible
	github.com/go-chi/chi/v5 v5.0.3
	github.com/google/uuid v1.2.0
	github.com/matthewhartstonge/argon2 v0.1.4
	github.com/mattn/go-sqlite3 v1.14.7
	github.com/stretchr/testify v1.7.0
	go.uber.org/zap v1.17.0
	golang.org/x/sys v0.0.0-20210510120138-977fb7262007 // indirect
)

exclude example.com/thismodule v1.3.0
exclude example.com/thatmodule v1.2.0

replace github.com/example/my-project/pkg/old => ./pkg/new

require github.com/example/greatmodule v1.1.1