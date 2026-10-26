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
	@python3 -c 'import pathlib, re, sys; log_path = pathlib.Path("sim_build/run.log"); xml_path = pathlib.Path("results.xml"); log = log_path.read_text(errors="replace") if log_path.exists() else ""; pass_count = len(re.findall(r"PASS:", log)); fail_count = len(re.findall(r"FAIL:", log)); xml = "<?xml version=\\"1.0\\" encoding=\\"UTF-8\\"?>\\n<testsuites>\\n  <testsuite name=\\"verilog\\" tests=\\"%d\\" failures=\\"%d\\" errors=\\"0\\">\\n" % (pass_count + fail_count, fail_count); xml += "".join(f"    <testcase classname=\\"tb\\" name=\\"case_{i}\\" time=\\"0\\"/>\\n" for i in range(1, max(pass_count, fail_count) + 1)); xml += "  </testsuite>\\n</testsuites>\\n"; xml_path.write_text(xml); print(f"Detected {fail_count} failing test(s).") if fail_count else print(f"Detected {pass_count} passing test(s)."); sys.exit(1 if fail_count else 0)'

clean:
	rm -rf $(SIM_BUILD) $(RESULTS)

.PHONY: all clean
