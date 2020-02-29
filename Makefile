# LICENSE : GPL v3  : see LICENSE file
# Author: Nikolay Fiykov

PRJ_DIR := $(shell pwd)
PRJ_SRC_DIR := $(PRJ_DIR)
PRJ_CONTRIB_SRC_DIR := $(PRJ_DIR)/contrib

LUA_PATH := $(PRJ_SRC_DIR)/lua/?.lua\;$(PRJ_CONTRIB_SRC_DIR)/lua/?.lua\;$(PRJ_SRC_DIR)/test/?.lua

LUA_TEST_CASES := $(wildcard $(PRJ_DIR)/test/*est*.lua)

.PHONY: help clean test $(LUA_TEST_CASES)

help:
	@echo type: make test

clean:
	@rm -rf $(PRJ_CONTRIB_SRC_DIR)

$(LUA_TEST_CASES):
	@echo [INFO] : Running tests in $@ ...
	@export LUA_PATH=$(LUA_PATH) && lua $@

$(PRJ_CONTRIB_SRC_DIR):
	@git clone https://github.com/fikin/nodemcu-lua-mocks.git $(PRJ_CONTRIB_SRC_DIR)

test: $(PRJ_CONTRIB_SRC_DIR) $(LUA_TEST_CASES)
