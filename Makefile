# Makefile-workarea.in
# Copyright 1984-2016 Cisco Systems, Inc.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

MAKEFLAGS += --no-print-directory
PREFIX=

build:
	(cd src/c ; $(MAKE))
	(cd src/s ; $(MAKE))

clean:
	(cd src/s ; $(MAKE) clean)
	(cd src/c ; $(MAKE) clean)

install:
	cp -v out/scheme /usr/bin/scheme
	mkdir -p /usr/lib/scheme
	cp -v out/scheme.boot /usr/lib/scheme/scheme.boot

uninstall:
	rm -v /usr/bin/scheme
	rm -rvf /usr/lib/scheme

