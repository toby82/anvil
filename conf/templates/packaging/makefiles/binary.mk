SRC_REPO_DIR := $SRC_REPO_DIR
LOGS_DIR := $LOGS_DIR
RPMBUILD := rpmbuild
RPMBUILD_FLAGS := $RPMBUILD_FLAGS

#raw
YUM_BUILDDEP := yum-builddep
YUM_BUILDDEP_FLAGS := -q -y

REPO_NAME := $(shell basename $(SRC_REPO_DIR))
BUILDDEP_MARK := builddep-$(REPO_NAME).mark
MARKS := $(foreach archive,$(shell (cd $(SRC_REPO_DIR) && echo *src.rpm)),$(archive).mark)


all: $(MARKS)


# NOTE(aababilov): yum-builddep is buggy and can fail when several
# package names are given, so, pass them one by one
$(BUILDDEP_MARK):
	@echo "Installing build requirements for $(REPO_NAME)"
	@for pkg in $(SRC_REPO_DIR)/*; do                    \
		$(YUM_BUILDDEP) $(YUM_BUILDDEP_FLAGS) $$pkg; \
	done &> $(LOGS_DIR)/yum-builddep-$(REPO_NAME).log
	@touch "$@"
	@echo "Build requirements are installed"


%.mark: $(SRC_REPO_DIR)/% $(BUILDDEP_MARK)
	@$(RPMBUILD) $(RPMBUILD_FLAGS) -- $< &> $(LOGS_DIR)/rpmbuild-$*.log
	@touch "$@"
	@echo "$* has been processed."
#end raw
