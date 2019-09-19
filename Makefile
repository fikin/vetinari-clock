# LICENSE : GPL v3  : see LICENSE file
# Author: Nikolay Fiykov

PRJ_DIR := $(shell pwd)
PRJ_SRC_DIR := $(PRJ_DIR)/lua
PRJ_CONTRIB_SRC_DIR := $(PRJ_DIR)/contrib

GIT_ROOT_DIR := $(shell cd $(PRJ_DIR)/../.. && pwd)

LUA_PATH := $(PRJ_SRC_DIR)/?.lua\;$(PRJ_CONTRIB_SRC_DIR)/?.lua

LUA_TEST_CASES := $(wildcard $(PRJ_DIR)/test*est*.lua)

.PHONY: help clean test dist upload-rock $(LUA_TEST_CASES)

help:
	@echo type: make clean
	@echo type: make test
	@echo type: make dist

clean:
	rm -rf $(PRJ_DIR)/dist

$(LUA_TEST_CASES):
	@echo [INFO] : Running tests in $@ ...
	@export LUA_PATH=$(LUA_PATH) && lua $@

test: $(PRJ_DIR)/target $(LUA_TEST_CASES)

dist:
	cp $(PRJ_SRC_DIR)/*.lua $(PRJ_DIR)/dist/
