export GDSL:=gdsl
export MANAGED:=1

archs:=x86 avr

$(archs):
	$(MAKE) -f Makefile_$@

$(archs:=-libs):
	$(MAKE) -f Makefile_$(@:%-libs=%) libs

$(archs:=-tools):
	$(MAKE) -f Makefile_$(@:%-tools=%) tools

$(archs:=-clean):
	$(MAKE) -f Makefile_$(@:%-clean=%) clean

clean: $(archs:=-clean)
