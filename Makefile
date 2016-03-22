# Mostly lifted from https://andreypopp.com/posts/2013-05-16-makefile-recipes-for-node-js.html
# Thanks @andreypopp

export BIN := $(shell npm bin)
export NODE_ENV = test
LIB = lib
DIST = dist
SRC_JS = $(shell find src -name "*.es6")
LIB_JS = $(patsubst src/%.es6,lib/%.js,$(SRC_JS))
BROWSER = $(DIST)/react-draggable.js
BROWSER_MIN = $(DIST)/react-draggable.min.js
BABEL_PRESETS = es2015,stage-1,react

.PHONY: test dev lint build fast_babel clean release-patch release-minor release-major publish

clean:
	rm -rf $(DIST) $(LIB)

lint:
	# FIXME this is usually global
	flow check
	@$(BIN)/eslint $(LIB_JS) specs/*

build: fast_babel $(BROWSER) $(BROWSER_MIN)

# Allows usage of `make install`, `make link`
install link:
	@npm $@

dist/%.min.js: dist/%.js $(BIN)
	@$(BIN)/uglifyjs $< \
	  --output $@ \
	  --source-map $@.map \
	  --source-map-url $(basename $@.map) \
	  --in-source-map $<.map \
	  --compress warnings=false

dist/%.js: $(BIN)
	@$(BIN)/rollup -c

fast_babel: $(BIN)
	@$(BIN)/babel --presets $(BABEL_PRESETS) src/ --out-dir lib/

$(LIB_JS): lib/%.js: src/%.es6
	@mkdir -p $(dir $@)
	@$(BIN)/babel --presets $(BABEL_PRESETS) $< --out-file $@

test: $(LIB_JS) $(BIN)
	@$(BIN)/karma start --single-run

dev: $(BIN)
	script/build-watch

node_modules/.bin: install

define release
	VERSION=`node -pe "require('./package.json').version"` && \
	NEXT_VERSION=`node -pe "require('semver').inc(\"$$VERSION\", '$(1)')"` && \
	node -e "\
		['./package.json', './bower.json'].forEach(function(fileName) {\
			var j = require(fileName);\
			j.version = \"$$NEXT_VERSION\";\
			var s = JSON.stringify(j, null, 2);\
			require('fs').writeFileSync(fileName, s);\
		});" && \
	git add package.json bower.json CHANGELOG.md && \
	git add -f dist/ && \
	git commit -m "release v$$NEXT_VERSION" && \
	git tag "v$$NEXT_VERSION" -m "release v$$NEXT_VERSION"
endef

release-patch: test clean build
	@$(call release,patch)

release-minor: test clean build
	@$(call release,minor)

release-major: test clean build
	@$(call release,major)

publish: clean build
	git push --tags origin HEAD:master
	npm publish
