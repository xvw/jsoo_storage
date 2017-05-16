OCAML    = ocamlfind ocamlc -g -package js_of_ocaml -package js_of_ocaml.ppx
DEP      = -package jsoo_storage
JSOCAML  = js_of_ocaml --pretty --sourcemap +weak.js +toplevel.js

all: index.js event.js

run: all
	python -m SimpleHTTPServer 8000

%.byte: %.ml
	$(OCAML) $(DEP) -linkpkg -o $(@) $(<)

%.js: %.byte
	$(JSOCAML) -o $(@) $(<)
	rm -rf *.byte
	rm -rf *.cm*
	rm -rf *.out

	