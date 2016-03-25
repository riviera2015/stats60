SHELL = /bin/bash
PY_VER = $(shell python -c 'import sys; print(sys.version_info.major)')
NOTEBOOK_DIR = notebooks
BUILD_DIR = build

NOTEBOOKS = $(wildcard $(NOTEBOOK_DIR)/*.ipynb)
NB_OUTPUTS = $(patsubst $(NOTEBOOK_DIR)/%.ipynb, $(BUILD_DIR)/%.ipynb, $(NOTEBOOKS))
SLIDE_OUTPUTS = $(patsubst %.ipynb, %.slides.html, $(NB_OUTPUTS))

$(warning NB_OUTPUTS is $(NB_OUTPUTS));
$(BUILD_DIR)/%.ipynb: $(NOTEBOOK_DIR)/%.ipynb
	mkdir -p $(BUILD_DIR); 
	jupyter nbconvert --execute --inplace --output=$@ --ExecutePreprocessor.timeout=-1 $<;
	echo $@;
	echo $<;

	jupyter trust $<;

$(BUILD_DIR)/%.slides.html:$(BUILD_DIR)/%.ipynb
	jupyter nbconvert --to slides --reveal-prefix=http://cdn.jsdelivr.net/reveal.js/3.2.0 $<;
	# it seems to dump in this directory instead of $(BUILD_DIR)
	mv `basename $@` $(BUILD_DIR);

html: $(NB_OUTPUTS)

	pip install -q -r requirements.docs.txt

	cp -r code $(BUILD_DIR)/code;
	cp -r data $(BUILD_DIR)/data;
	cp -r images $(BUILD_DIR)/images;
	cp -r exercises $(BUILD_DIR)/exercises;

slides: $(SLIDE_OUTPUTS)

$(BUILD_DIR)/$(TABLES_DIR)%.html:$(BUILD_DIR)/$(TABLES_DIR)%.ipynb

	jupyter nbconvert --to html $<;
	mv `basename $@` $(BUILD_DIR)/$(TABLES_DIR);

tables : $(NB_OUTPUTS)

	jupyter nbconvert --to=html $(BUILD_DIR)/Symmetric_normal_table.ipynb ;
	mv Symmetric_normal_table.html $(BUILD_DIR);

	jupyter nbconvert --to=html $(BUILD_DIR)/Tail_Chisquared_table.ipynb ;
	mv Tail_Chisquared_table.html $(BUILD_DIR);

	jupyter nbconvert --to=html $(BUILD_DIR)/Tail_T_table.ipynb ;
	mv Tail_T_table.html $(BUILD_DIR);

	jupyter nbconvert --to=html $(BUILD_DIR)/Tail_normal_table.ipynb ;
	mv Tail_normal_table.html $(BUILD_DIR);

$(BUILD_DIR)/index.html :
	
	mkdir -p sphinx;
	notedown index.md > index.ipynb;
	jupyter nbconvert --to=rst index.ipynb --output=index;
	rm index.ipynb;
	mv index.rst sphinx;
	sphinx-build -E -b html sphinx _build/html ;
	cp -r _build/html/* build;

clean:
	
	rm -fr $(BUILD_DIR);
	rm -fr _build;

all: html slides tables $(BUILD_DIR)/index.html