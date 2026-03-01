CXX ?= g++
CCFLAGS = -W -Wall -std=c++11 `pkg-config --cflags dbus-1`
BINARY := mako-notify
LIBRARIES = `pkg-config --libs dbus-1`
SOURCES := mako-notify.cpp

all:
	$(CXX) $(CCFLAGS) $(SOURCES) -o $(BINARY) $(LIBRARIES)

clean:
	rm -f $(BINARY)
