IMG = b7j0c/perl:5.34.0
CWD = $(shell pwd)
WORKDIR = /perl
DOCKER_RUN = docker run --rm -it -v $(CWD):$(WORKDIR) -w $(WORKDIR)
DZIL = dzil
TEST_RUNNER = prove
TIDY = perltidy
CRITIC = perlcritic
CRITIC_ARGS =
TCRITIC_ARGS = --theme=tests
LIBS = $(shell find lib -type f -name \*pm)
LIB_TESTS = $(shell find t -type f)

.PHONY: shell
shell:
	$(DOCKER_RUN) --env PERL5LIB=$(WORKDIR)/lib $(IMG) /bin/bash

.PHONY: clean
clean:
	$(DOCKER_RUN) $(IMG) $(DZIL) clean

.PHONY: build
build: clean
	$(DOCKER_RUN) $(IMG) $(DZIL) build

.PHONY: check
check: clean
	$(DOCKER_RUN) --env PERL5LIB=$(WORKDIR)/lib $(IMG) make ci-check

.PHONY: test
test: clean
	$(DOCKER_RUN) $(IMG) make ci-test

.PHONY: tidy
tidy:
	$(DOCKER_RUN) $(IMG) make ci-tidy

.PHONY: critic
critic:
	$(DOCKER_RUN) -e PERLCRITIC=$(WORKDIR)/.perlcritic $(IMG) make ci-critic

.PHONY: ci-check
ci-check:
	for i in `find . -name \*.pm`; do perl -c $$i; done
	for i in `find . -name \*.t`; do perl -c $$i; done

.PHONY: ci-test
ci-test:
	$(DZIL) test

.PHONY: ci-tidy
ci-tidy:
	find -name \*.pm -print0 | xargs -0 $(TIDY) -b
	find -name \*.t -print0 | xargs -0 $(TIDY) -b
	find -name \*bak -delete

.PHONY: ci-critic
ci-critic:
	$(CRITIC) $(CRITIC_ARGS) $(LIBS)
	$(CRITIC) $(TCRITIC_ARGS) $(LIB_TESTS)
