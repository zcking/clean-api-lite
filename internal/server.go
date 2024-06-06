package internal

import (
	"context"

	userspb "github.com/zcking/clean-api-lite/gen/go/users/v1"
)

type UsersServer struct {
	userspb.UnimplementedUserServiceServer

	db *Database
}

func NewUsersServer(databaseLocation string) (*UsersServer, error) {
	db, err := NewDatabase(databaseLocation)
	if err != nil {
		return nil, err
	}
	return &UsersServer{
		db: db,
	}, nil
}

func (s *UsersServer) CreateUser(ctx context.Context, req *userspb.CreateUserRequest) (*userspb.CreateUserResponse, error) {
	return s.db.CreateUser(ctx, req)
}

func (s *UsersServer) ListUsers(ctx context.Context, req *userspb.ListUsersRequest) (*userspb.ListUsersResponse, error) {
	return s.db.GetUsers(ctx)
}

func (s *UsersServer) Close() error {
	return s.db.Close()
}
