.PHONY: help clean spec mystspec

spec:      ## Runs all specs
	crystal spec
	crystal run src/myst_cli.cr -- spec/myst/spec.mt

myst-spec: ## Runs just the in-language specs
	crystal run src/myst_cli.cr -- spec/myst/spec.mt
	
build:     ## Builds myst into an executable
	shards build

check:     ## Runs all crystal specs
	crystal spec/

clean:     ## Cleans (deletes) docs and executables
	rm -rf docs
	rm bin/*

# https://gist.github.com/prwhite/8168133 "Help target"
help:      ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'
