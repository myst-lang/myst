.PHONY: spec
spec:
	crystal spec
	crystal run src/myst.cr -- spec/myst/spec.mt
