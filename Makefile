# Because env `SHELL` might be 
# some extremely weird shell
SHELL = bash

# Parse makefiles named *.mk in the dir `local`
# for local extra makefile targets if wanted.
# It is smart to set MYSTBUILD to your myst dev-build there
-include local/*.mk

# https://www.gnu.org/software/make/manual/html_node/One-Shell.html
.ONESHELL:

# The docs says i should do this
.SUFFIXES: .cr .mt

MYST_CLI = src/myst_cli.cr

MYST_INTERPRETER_SPEC = spec/all_spec.cr
MYST_IN_LANG_SPEC 		= spec/myst/spec.mt

SOURCE_FILES := $(shell find src    -type f -name '*.cr')
SPEC_FILES   := $(shell find spec   -type f -name '*.cr' -o -name '*.mt')
STDLIB_FILES := $(shell find stdlib -type f -name '*.mt')
ALL_FILES    := $(SPEC_FILES) $(STDLIB_FILES) $(SOURCE_FILES)

INSTALL_LOCATION ?= /usr/local/bin/myst
MYSTBUILD				 ?= myst

O ?= bin

info ?= true

# If another default is intentionally wished for,
# set it in local/*.mk, like this:
# .DEFAULT_GOAL = goal
# 
.DEFAULT_GOAL ?= spec

info_log = $(if $(subst false,,$(info)),$(info $(1)))

# Make convention 
all: $(O)/myst $(O)/spec

.PHONY: spec
spec: $(O)/myst $(O)/spec ## Runs all specs
	$(call info_log,Running interpreter spec)
	$(O)/spec
	$(call info_log,Running in-language spec)
	$(O)/myst $(MYST_IN_LANG_SPEC)

myst-spec: $(O)/myst ## Runs just the in-language specs
	$(O)/myst $(MYST_IN_LANG_SPEC)

.PHONY: install
install: $(INSTALL_LOCATION) ## Install myst to INSTALL_LOCATION		

.PHONY: build
build: $(O)/myst ## Builds myst into an executable

.PHONY: myst-spec_with_build
myst-spec_with_build: ## Runs the in-language specs with MYSTBUILD
	$(MYSTBUILD) $(MYST_IN_LANG_SPEC)

$(O)/myst: $(SOURCE_FILES)
	$(call info_log,Building myst...)
	mkdir -p $(O)
	crystal build -o $(O)/myst $(MYST_CLI)

$(O)/spec: $(ALL_FILES)
	$(call info_log,Building specs...)
	mkdir -p $(O)
	crystal build -o $(O)/spec $(MYST_INTERPRETER_SPEC)

$(INSTALL_LOCATION): $(SOURCE_FILES)
	$(call info_log,Installing myst to $(INSTALL_LOCATION) ...)
	mkdir -p $(dir $(INSTALL_LOCATION))	
	sudo crystal build --release -o $(INSTALL_LOCATION) $(MYST_CLI)	

.PHONY: clean
clean: ## Cleans (deletes) docs and executables	
ifdef O	
	@[ -f $(O)/myst ] && rm -f $(O)/myst*
	@[ -f $(O)/spec ] && rm -f $(O)/spec*
endif
	@rm -rf docs
	@

# Thanks https://stackoverflow.com/questions/4219255/how-do-you-get-the-list-of-targets-in-a-makefile/26339924#26339924
define TARGET_LIST =
$(shell \
	$(MAKE) -pRrq -f $(MAKEFILE_LIST) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' |\
	sort |\
	egrep -v -e '^[^[a-zA-Z0-9]]' -e '^$@$$' |\
	xargs )
endef

# Used in help target
list:
	@echo $(TARGET_LIST)

HELP_INDENTATION 	 ?= 2
HELP_NAME-DESC_SEP ?= 2

LENGTH_OF_LONGEST_TARGET_NAME = $(shell ruby -e 'puts ARGV.sort_by(&:size)[-1].size' $$(make list))

parse_help = perl -n -e \
	'if(/^(\S*)?(?=:).*$(HELP_MARK)\s*(.*)/){ \
		print((" " x $(HELP_INDENTATION)) . "$$1" . (" " x ($(LENGTH_OF_LONGEST_TARGET_NAME) + $(HELP_NAME-DESC_SEP) - length($$1))) . "- $$2\n") \
	}' $(1) |\
	sort

# Help target that reads text after two '#'s in a target definition and prints it after the target name
.PHONY: help
help: ## Show this help
	@echo "The main targets are:"
	@$(call parse_help, $(firstword $(MAKEFILE_LIST))); echo
	# Iterate through the extra optional makefiles
	@for makefile in $(wordlist 2, $(words $(MAKEFILE_LIST)), $(MAKEFILE_LIST)); do 
		echo "Targets defined in $$makefile:"
			$(call parse_help, $$makefile)
		echo
	done
	@echo "The default target is '$(.DEFAULT_GOAL)'"

define HELP_MARK
##
endef
