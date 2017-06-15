CXX ?= g++
CFLAGS = -Wall -Wconversion -O3 -fPIC
SHVER = 2
OS = $(shell uname)

all: svm-train svm-predict svm-scale

lib: svm.o
	if [ "$(OS)" = "Darwin" ]; then \
		SHARED_LIB_FLAG="-dynamiclib -Wl,-install_name,libsvm.so.$(SHVER)"; \
	else \
		SHARED_LIB_FLAG="-shared -Wl,-soname,libsvm.so.$(SHVER)"; \
	fi; \
	$(CXX) $${SHARED_LIB_FLAG} svm.o -o libsvm.so.$(SHVER)

.PHONY: gtsvm
gtsvm:
	$(MAKE) -C gtsvm all

svm-predict: svm-predict.c svm.o gtsvm
	$(CXX) $(CFLAGS) svm-predict.c svm.o -o svm-predict -L./gtsvm/lib -lm -lgtsvm -lcudart
svm-train: svm-train.c svm.o gtsvm
	$(CXX) $(CFLAGS) svm-train.c svm.o -o svm-train -L./gtsvm/lib -lm -lgtsvm -lcudart
svm-scale: svm-scale.c
	$(CXX) $(CFLAGS) svm-scale.c -o svm-scale
svm.o: svm.cpp svm.h
	$(CXX) -I./gtsvm/lib $(CFLAGS) -c svm.cpp
clean:
	rm -f *~ svm.o svm-train svm-predict svm-scale libsvm.so.$(SHVER)
