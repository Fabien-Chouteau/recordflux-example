GNATPROVE = gnatprove

project_name = example

specs = $(wildcard ./*.rflx)
rflx_gen_dir = generated
rflx_gen_src = $(rflx_gen_dir)/rflx.ads

manual_src_dir = src
manual_src = $(wildcard $(manual_src_dir)/*.ads $(manual_src_dir)/*.adb)

bin = bin/$(project_name)

.PHONY: all clean check generate graph build prove run

all: clean check graph build prove run

run: $(bin)
	$^

build: $(bin)

prove: $(rflx_gen_src) $(manual_src)
	$(GNATPROVE) -P $(project_name)

graph: $(specs)
	rflx graph -d generated $^

generate: $(rflx_gen_src)

check: $(specs)
	rflx check $^

clean:
	rm -rf $(rflx_gen_dir) obj bin

$(rflx_gen_src): $(specs)
	mkdir -p $(rflx_gen_dir)
	rflx generate -d $(rflx_gen_dir) $^

$(bin): $(rflx_gen_src) $(manual_src)
	gprbuild -P $(project_name)

