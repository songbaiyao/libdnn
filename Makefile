CC=gcc
CXX=g++-4.6
CFLAGS=
NVCC=nvcc -arch=sm_21 -w

BOTON_UTIL_ROOT=/usr/local/boton/
CUMATRIX_ROOT=../libcumatrix
MATH_EXT_ROOT=../math_ext/

INCLUDE= -I include/ \
	 -I $(BOTON_UTIL_ROOT)/include/ \
	 -I $(CUMATRIX_ROOT)/include \
	 -I $(MATH_EXT_ROOT) \
 	 -isystem /usr/local/cuda/samples/common/inc/ \
	 -isystem /usr/local/cuda/include

CPPFLAGS= -std=c++0x -Werror -Wall $(CFLAGS) $(INCLUDE)

SOURCES=dnn.cu\
	dnn-utility.cu\
	rbm.cu\
	feature-transform.cu\
	dataset.cpp\
	config.cpp

EXECUTABLES=dnn-train dnn-predict dnn-init
.PHONY: debug all o3 example ctags
all: $(EXECUTABLES) ctags

o3: CFLAGS+=-O3
o3: all
debug: CFLAGS+=-g -DDEBUG
debug: all

vpath %.h include/
vpath %.cpp src/
vpath %.cu src/

OBJ:=$(addprefix obj/, $(addsuffix .o,$(basename $(SOURCES))))

LIBRARY=-lmatrix -lpbar -lcumatrix
CUDA_LIBRARY=-lcuda -lcudart -lcublas
LIBRARY_PATH=-L$(BOTON_UTIL_ROOT)/lib/ -L$(CUMATRIX_ROOT)/lib -L/usr/local/cuda/lib64

$(EXECUTABLES): % : %.cpp $(OBJ)
	$(CXX) $(CFLAGS) $(INCLUDE) -o $@ $^ $(LIBRARY_PATH) $(LIBRARY) $(CUDA_LIBRARY)
# +==============================+
# +===== Other Phony Target =====+
# +==============================+
obj/%.o: %.cpp
	$(CXX) $(CPPFLAGS) -o $@ -c $<

obj/%.o: %.cu include/%.h
	$(NVCC) $(CFLAGS) $(INCLUDE) -o $@ -c $<

obj/%.d: %.cpp
	@$(CXX) -MM $(CPPFLAGS) $< > $@.$$$$; \
	sed 's,\($*\)\.o[ :]*,obj/\1.o $@ : ,g' < $@.$$$$ > $@;\
	rm -f $@.$$$$

-include $(addprefix obj/,$(subst .cpp,.d,$(SOURCES)))

.PHONY: ctags
ctags:
	@ctags -R --langmap=C:+.cu *
clean:
	rm -rf $(EXECUTABLES) obj/*
