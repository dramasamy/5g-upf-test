FROM golang:1.15-alpine3.13 as build
RUN mkdir /build
WORKDIR /build
COPY . .
RUN unset GOPATH && go mod tidy
RUN unset GOPATH && go build server.go

FROM alpine:3.13.5
RUN mkdir /app
WORKDIR /app
COPY --from=build /build/server /app/
CMD ["/app/server"]

