.PHONY: spec
spec:
	crystal spec
	crystal run src/myst.cr -- spec/myst/spec.mt

default:
	shards build

check:
	crystal spec/
