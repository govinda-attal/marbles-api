.PHONY: init install test build clean pack deploy ship compile_proto generate_gw generate_swagger

include .env
export $(shell sed 's/=.*//' .env)

APP_NAME=$(shell basename $(CURDIR))
TAG?=$(shell git rev-list HEAD --max-count=1 --abbrev-commit)



export TAG
export APP_NAME

init:
	rm -rf ./dist/ && mkdir dist

install: init
	dep ensure

test: init
	go test ./...

build: init
	cd dist; mkdir grpc; cp ../config ./grpc -r
	cd cmd/grpc; GOOS=linux GOARCH=amd64 go build -ldflags "-X main.version=$(TAG)" -o ../../dist/grpc/app .
	cd cmd/gw; GOOS=linux GOARCH=amd64 go build -ldflags "-X main.version=$(TAG)" -o ../../dist/gw/app .	

clean:
	rm ./dist/ -rf

pack:	
	docker build -t asia.gcr.io/fabric-blockchain/$(APP_NAME)-grpc:$(TAG) .
	docker build --build-arg TARGET="gw" -t asia.gcr.io/fabric-blockchain/$(APP_NAME)-gw:$(TAG) .

pack1:	
	#docker build --build-arg TARGET="grpc" -t asia.gcr.io/fabric-blockchain/$(APP_NAME)-grpc:$(TAG) .
	#docker build --build-arg TARGET="gw" -t asia.gcr.io/fabric-blockchain/$(APP_NAME)-gw:$(TAG) .
	
upload:
	gcloud docker -- push asia.gcr.io/fabric-blockchain/$(APP_NAME)-grpc:$(TAG)
	gcloud docker -- push asia.gcr.io/fabric-blockchain/$(APP_NAME)-gw:$(TAG)

deploy:	
	envsubst < k8s/deployment.yaml | kubectl apply -f -
	envsubst < k8s/service.yaml | kubectl apply -f -
	envsubst < k8s/ingress.yaml | kubectl apply -f -
ship: init test pack upload deploy clean


compile_proto:
	cd ./api/; protoc -I. -I$(GOPATH)/src/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis -I$(GOPATH)/src  --go_out=plugins=grpc:$(GOPATH)/src/ proto/*.proto
generate_gw:
	cd ./api/; protoc -I/usr/local/include -I. \
		-I$(GOPATH)/src \
		-I$(GOPATH)/src/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis \
		--grpc-gateway_out=logtostderr=true:$(GOPATH)/src/ proto/marbles.srv.proto

generate_swagger:
	cd ./api/; protoc -I/usr/local/include -I. \
		-I$(GOPATH)/src \
		-I$(GOPATH)/src/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis \
  		--swagger_out=logtostderr=true:. proto/marbles.srv.proto
