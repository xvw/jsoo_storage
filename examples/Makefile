OCAML    = ocamlfind ocamlc -g -package js_of_ocaml -package js_of_ocaml.ppx
DEP      = -package jsoo_storage
JSOCAML  = js_of_ocaml --pretty --sourcemap +weak.js +toplevel.js

.PHONY: storage.ml

# Specific rule
all: storage.js clean



# Generic rules

%.byte: %.ml
	$(OCAML) $(DEP) -linkpkg -o $(@) $(<)

%.js: %.byte
	$(JSOCAML) -o $(@) $(<)

clean:
	rm -rf *.byte
	rm -rf *.cm*
	rm -rf *.out
