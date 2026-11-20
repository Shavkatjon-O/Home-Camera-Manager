CXX ?= g++
DS_INCLUDES ?= /opt/nvidia/deepstream/deepstream/sources/includes
CUDA_INCLUDES ?= /usr/local/cuda/include
CXXFLAGS := -O2 -Wall -std=c++17 -shared -fPIC -I$(DS_INCLUDES) -I$(CUDA_INCLUDES)
LDLIBS := -lnvinfer
TARGET := libnvds_rfdetr_parser.so

all: $(TARGET)

$(TARGET): rfdetr_parser.cpp
	$(CXX) $(CXXFLAGS) -o $@ $< $(LDLIBS)

clean:
	rm -f $(TARGET)

.PHONY: all clean
