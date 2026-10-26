SIM_BUILD ?= sim_build
TOPLEVEL ?= tb
IVERILOG ?= iverilog
VVP ?= vvp
LOG := $(SIM_BUILD)/run.log
RESULTS := results.xml

VERILOG_SOURCES := ../src/project.v tb.v

all: $(RESULTS)

$(SIM_BUILD):
	mkdir -p $(SIM_BUILD)

$(SIM_BUILD)/sim.vvp: $(VERILOG_SOURCES) | $(SIM_BUILD)
	$(IVERILOG) -g2012 -o $@ -s $(TOPLEVEL) $(VERILOG_SOURCES)

$(RESULTS): $(SIM_BUILD)/sim.vvp
	@$(VVP) $(SIM_BUILD)/sim.vvp > $(LOG) 2>&1 || { cat $(LOG); exit 1; }
	@python3 - <<'PY'
	import pathlib
	import re
	import sys
	
	log_path = pathlib.Path('sim_build/run.log')
	xml_path = pathlib.Path('results.xml')
	log = log_path.read_text(errors='replace') if log_path.exists() else ''
	
	pass_count = len(re.findall(r'PASS:', log))
	fail_count = len(re.findall(r'FAIL:', log))
	
	# Build a minimal XML that the custom checker understands.
	xml = f'''<?xml version="1.0" encoding="UTF-8"?>
	<testsuites>
	  <testsuite name="verilog" tests="{pass_count + fail_count}" failures="{fail_count}" errors="0">
	'''
	
	# Add one testcase per PASS/FAIL line.
	for i in range(1, max(pass_count, fail_count) + 1):
	    xml += f'    <testcase classname="tb" name="case_{i}" time="0"/>'
	
	xml += '''  </testsuite>
	</testsuites>
	'''
	xml_path.write_text(xml)
	
	if fail_count:
	    print(f'Detected {fail_count} failing test(s).')
	    sys.exit(1)
	
	print(f'Detected {pass_count} passing test(s).')
	PY

clean:
	rm -rf $(SIM_BUILD) $(RESULTS)

.PHONY: all clean
