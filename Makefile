PY?=python3
PELICAN?=pelican
PELICANOPTS=

BASEDIR=$(CURDIR)
INPUTDIR=$(BASEDIR)/content
OUTPUTDIR=$(BASEDIR)/output
CONFFILE=$(BASEDIR)/pelicanconf.py
PUBLISHCONF=$(BASEDIR)/publishconf.py


DEBUG ?= 0
ifeq ($(DEBUG), 1)
	PELICANOPTS += -D
endif

RELATIVE ?= 0
ifeq ($(RELATIVE), 1)
	PELICANOPTS += --relative-urls
endif

help:
	@echo 'Makefile for a pelican Web site                                           '
	@echo '                                                                          '
	@echo 'Usage:                                                                    '
	@echo '   make html                           (re)generate the web site          '
	@echo '   make clean                          remove the generated files         '
	@echo '   make regenerate                     regenerate files upon modification '
	@echo '   make publish                        generate using production settings '
	@echo '   make serve [PORT=8000]              serve site at http://localhost:8000'
	@echo '   make serve-global [SERVER=0.0.0.0]  serve (as root) to $(SERVER):80    '
	@echo '   make devserver [PORT=8000]          serve and regenerate together      '
	@echo '   make ssh_upload                     upload the web site via SSH        '
	@echo '   make rsync_upload                   upload the web site via rsync+ssh  '
	@echo '   make deploy-strapi                  deploy Strapi CMS backend          '
	@echo '                                                                          '
	@echo 'Set the DEBUG variable to 1 to enable debugging, e.g. make DEBUG=1 html   '
	@echo 'Set the RELATIVE variable to 1 to enable relative urls                    '
	@echo '                                                                          '

html:
	$(PELICAN) $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE) $(PELICANOPTS)

clean:
	[ ! -d $(OUTPUTDIR) ] || rm -rf $(OUTPUTDIR)

regenerate:
	$(PELICAN) -r $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE) $(PELICANOPTS)

serve:
ifdef PORT
	$(PELICAN) -l $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE) $(PELICANOPTS) -p $(PORT)
else
	$(PELICAN) -l $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE) $(PELICANOPTS)
endif

serve-global:
ifdef SERVER
	$(PELICAN) -l $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE) $(PELICANOPTS) -p $(PORT) -b $(SERVER)
else
	$(PELICAN) -l $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE) $(PELICANOPTS) -p $(PORT) -b 0.0.0.0
endif


devserver:
ifdef PORT
	$(PELICAN) -lr $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE) $(PELICANOPTS) -p $(PORT)
else
	$(PELICAN) -lr $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE) $(PELICANOPTS)
endif

publish:
	$(PELICAN) $(INPUTDIR) -o $(OUTPUTDIR) -s $(PUBLISHCONF) $(PELICANOPTS)

# Strapi #

strapi/deploy:
	git subtree push --prefix strapi heroku main

strapi/download-about:
	python3 get_content_from_strapi.py about https://pyconth-strapi.herokuapp.com/about

strapi/download-coc-procedure:
	python3 get_content_from_strapi.py coc-procedure https://pyconth-strapi.herokuapp.com/coc-procedure

strapi/download-code-of-conduct:
	python3 get_content_from_strapi.py code-of-conduct https://pyconth-strapi.herokuapp.com/code-of-conduct

strapi/download-covid-19:
	python3 get_content_from_strapi.py covid-19 https://pyconth-strapi.herokuapp.com/covid-19

strapi/download-event:
	python3 get_content_from_strapi.py event https://pyconth-strapi.herokuapp.com/event

strapi/download-speakers-advice:
	python3 get_content_from_strapi.py speakers-advice https://pyconth-strapi.herokuapp.com/speakers-advice

strapi/download-speakers-info:
	python3 get_content_from_strapi.py speakers-info https://pyconth-strapi.herokuapp.com/speakers-info

strapi/download-sponsor:
	python3 get_content_from_strapi.py sponsor https://pyconth-strapi.herokuapp.com/sponsor

strapi/download-the-conference:
	python3 get_content_from_strapi.py the-conference https://pyconth-strapi.herokuapp.com/the-conference

# Download all content from Strapi
strapi/download: strapi/download-sponsor strapi/download-about strapi/download-coc-procedure
strapi/download: strapi/download-code-of-conduct strapi/download-covid-19 strapi/download-speakers-advice strapi/download-event
strapi/download: strapi/download-speakers-info strapi/download-sponsor strapi/download-the-conference

.PHONY: html help clean regenerate serve serve-global devserver publish
