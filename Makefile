.PHONY: default apply switch build trace check check_all update gc clean ansible ansible_reqs
default: switch

apply: switch
switch:
	./make.sh switch

build:
	./make.sh build

trace:
	./make.sh trace

check:
	./make.sh check

check_all:
	./make.sh check_all

update:
	./make.sh update

gc:
	./make.sh gc

clean:
	./make.sh clean

ansible:
	./make.sh ansible

ansible_reqs:
	./make.sh ansible_reqs

%:
	./make.sh $@
