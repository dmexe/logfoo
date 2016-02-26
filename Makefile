all: build

deps:
	go get github.com/constabulary/gb/...
	gb vendor restore

build:
	gb build all
