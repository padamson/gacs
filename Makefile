
MAKEFLAGS = --no-print-directory

CHPL = chpl

TARGETS = \
	generateCluster \

default: all

all: $(TARGETS)

clean: FORCE
	rm -f $(TARGETS)

generateCluster: generateCluster.chpl
	$(CHPL) -o ~/Research/bin/generateCluster $<

FORCE:
