CXX ?= gcc
CFLAGS += -W -Wall -std=c++11

BINARY = gptokeyb
LIBRARIES = -levdev -lSDL2
SOURCES = "gptokeyb.cpp"

all:
	$(CXX) $(CFLAGS) $(SOURCES) -o $(BINARY) $(LIBRARIES)

clean:
	rm -f $(BINARY)