OCAML    = ocamlfind ocamlc -g -package js_of_ocaml -package js_of_ocaml.ppx
DEP      = -package lwt.ppx -package jsoo_storage
JSOCAML  = js_of_ocaml --pretty --sourcemap +weak.js +toplevel.js

.PHONY: storage.ml

# Specific rule
all: storage.js eventStorage.js clean

serve: storage.js eventStorage.js clean
	python -m SimpleHTTPServer 8000

# Generic rules

%.byte: %.ml
	$(OCAML) $(DEP) -linkpkg -o $(@) $(<)

%.js: %.byte
	$(JSOCAML) -o $(@) $(<)

clean:
	rm -rf *.byte
	rm -rf *.cm*
	rm -rf *.out
