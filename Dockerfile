# build stage
FROM golang:1.10-alpine AS build-env
ENV APP_NAME=goapp
WORKDIR /go/src/github.com/govinda-attal/marbles-api
COPY . .
RUN apk add --no-cache curl 
RUN curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh
#RUN dep ensure
RUN cd ./cmd/grpc && go build -o /dist/grpc/app
RUN cp ./config /dist/grpc -r
RUN cd ./cmd/gw && go build -o /dist/gw/app

FROM alpine:3.7
ARG TARGET=grpc
RUN apk -U add ca-certificates
VOLUME [ "/app/config" ]
WORKDIR /app
COPY --from=build-env /dist/$TARGET/ /app/
ENTRYPOINT ./app
EXPOSE 10000
