.PHONY: spec
spec:
	crystal spec
	crystal run src/myst_cli.cr -- spec/myst/spec.mt

default:
	shards build

check:
	crystal spec/
