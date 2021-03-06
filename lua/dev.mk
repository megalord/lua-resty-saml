include ../src/Makefile

TEST_ARGS?=.
DATA_DIR=$(shell pwd)/.build/data/
TEST_DATA_DIR=$(shell pwd)/../test-data/

.PHONY: prepack
prepack:
	rm -rf .build
	mkdir .build
	cp -R resty ../data ../src lua_saml.c Makefile saml-$(VERSION)-1.rockspec .build
	rm -f .build/src/saml.o

.PHONY: release
release: prepack
	cp -R .build saml-$(VERSION)
	rm saml-$(VERSION)/*.rockspec
	tar -czvpf lua.tar.gz saml-$(VERSION)
	rm -rf saml-$(VERSION)

.PHONY: build
build: prepack
	$(MAKE) -C .build build

.PHONY: test
test: build
	(cd t && TEST_DATA_DIR=$(TEST_DATA_DIR) DATA_DIR=$(DATA_DIR) ~/.luarocks/bin/busted --lpath=`pwd`/../.build/?.lua --cpath=`pwd`/../.build/?.so $(TEST_ARGS))

.PHONY: example
example: prepack
	docker run --rm -it --name resty-saml-example \
		-v `pwd`/.build:/tmp/.build \
		-v `pwd`/t/data:/ssl \
		-v `pwd`/example:/example \
		-p 8088:8088 \
		-p 8089:8089 \
		-e DATA_DIR=/usr/local/openresty/luajit/lib/luarocks/rocks/saml/$(VERSION)-1/data/ \
		resty-saml:latest \
		bash -c "cd /tmp/.build && luarocks make && cd /example && openresty -c /example/nginx.conf -g 'daemon off;'"

.PHONY: debug
debug: build-local
	LUA_CPATH=`pwd`/.build/?.so valgrind lua -l saml t/debug.lua

.PHONY: gdb
gdb: build-local
	gdb -ex "set environment LUA_CPATH=`pwd`/.build/?.so" -ex 'run -l saml t/debug.lua' lua

.PHONY: test-docker
test-docker: prepack
	docker run --rm -it \
		-v `pwd`/.build:/tmp/.build \
		-v `pwd`/t:/t \
		-w /t \
		-e DATA_DIR=/usr/local/openresty/luajit/lib/luarocks/rocks/saml/$(VERSION)-1/data/ \
		resty-saml-test:latest \
		bash -c "cd /tmp/.build && luarocks make && cd /t && busted --lua=/usr/local/openresty/bin/resty -lpath /usr/local/openresty/lualib/?.lua -cpath /usr/local/openresty/lualib/?.so $(TEST_ARGS)"

