BUF_VERSION:=v1.32.2
SWAGGER_UI_VERSION:=v4.15.5

run:
	go run cmd/main.go

generate:
	go run github.com/bufbuild/buf/cmd/buf@$(BUF_VERSION) generate

lint:
	go run github.com/bufbuild/buf/cmd/buf@$(BUF_VERSION) breaking --against 'https://github.com/zcking/clean-api-lite.git#branch=main'

docker:
	docker build -t clean-api-lite .

docker/run:
	docker run --rm -it -p 8080:8080 -p 8081:8081 clean-api-lite