.PHONY: default ansible
default: switch

ansible:
	./make.sh ansible

%:
	./make.sh $@
