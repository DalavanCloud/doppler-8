.PONY: all build deps image test

help: ## Show this help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {sub("\\\\n",sprintf("\n%22c"," "), $$2);printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

all: deps test build ## Run the tests and build the binary.

build: ## Build the binary.
	go build -ldflags "-X github.com/rybit/doppler/cmd.Version=`git rev-parse HEAD`"

build_linux: ## Build the binary.
	GOOS=linux GOARCH=amd64 go build -ldflags "-X github.com/rybit/doppler/cmd.Version=`git rev-parse HEAD`" -o doppler_linux_amd64

deps: ## Install dependencies.
	go get -u github.com/Masterminds/glide && glide install

image: ## Build the Docker image.
	docker build --tag rybit/doppler .

test: ## Run tests.
	go test -v `go list ./... | grep -v /vendor/`

release:
	@if [ "$(strip $(VERSION))" == "" ]; then echo "No version provided"; exit 1; fi
	go build -ldflags "-X github.com/rybit/doppler/cmd.Version=`git rev-parse HEAD`" -o doppler-${VERSION}
	tar -czf doppler-darwin-amd64-${VERSION}.tar.gz doppler-${VERSION}
	GOOS=linux GOARCH=amd64 go build -ldflags "-X github.com/rybit/doppler/cmd.Version=`git rev-parse HEAD`" -o doppler-${VERSION}
	tar -czf doppler-linux-amd64-${VERSION}.tar.gz doppler-${VERSION}
	rm doppler-${VERSION}
