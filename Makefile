
PACKAGE_NAME=PySixel
DEPENDENCIES=Pillow
PYTHON=python
SETUP_SCRIPT=setup.py
RM=rm -rf
PIP=pip
CYTHON=cython

.PHONY: smoketest nosetest build setuptools install uninstall clean update

build: smoketest
	ln -f sixel/converter.py /tmp/sixel_cimpl.pyx
	$(CYTHON) /tmp/sixel_cimpl.pyx -o sixel/sixel_cimpl.c
	$(PYTHON) $(SETUP_SCRIPT) sdist
	$(PYTHON) $(SETUP_SCRIPT) bdist_egg

setup_environment:
	if test -d tools; do \
		ln -f tools/gitignore .gitignore \
		ln -f tools/vimprojects .vimprojects \
    fi

setuptools:
	$(PYTHON) -c "import setuptools" || \
		curl http://peak.telecommunity.com/dist/ez_$(SETUP_SCRIPT) | $(PYTHON)

install: smoketest setuptools build
	$(PYTHON) $(SETUP_SCRIPT) install

uninstall:
	for package in $(PACKAGE_NAME) $(DEPENDENCIES); \
	do \
		$(PIP) uninstall -y $$package; \
	done

clean:
	for name in dist cover build *.egg-info *.egg htmlcov; \
		do find . -type d -name $$name || true; \
	done | xargs $(RM)
	for name in *.pyc *.o .coverage; \
		do find . -type f -name $$name || true; \
	done | xargs $(RM)

test: smoketest nosetest

smoketest:
	$(PYTHON) $(SETUP_SCRIPT) test

nosetest:

update: build clean test
	$(PYTHON) $(SETUP_SCRIPT) register
	$(PYTHON) $(SETUP_SCRIPT) sdist upload
	$(PYTHON) $(SETUP_SCRIPT) bdist_egg upload

cleanupdate: update
	ssh zuse.jp "rm -rf $(PACKAGE_NAME)"
	ssh zuse.jp "git clone git@github.com:saitoha/$(PACKAGE_NAME) --recursive"
	ssh zuse.jp "cd $(PACKAGE_NAME) && $(PYTHON) $(SETUP_SCRIPT) bdist_egg upload"

