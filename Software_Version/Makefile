RCS = $(wildcard *.cpp)
PROGS = $(patsubst %.cpp,%,$(SRCS))
OBJS = $(SRCS:.cpp=.o)
TEMPS = $(SRCS:.cpp=.txt)
SRC = kMeans.cpp
OUT	= kMeans

CFLAGS = `pkg-config --cflags --libs opencv` -O3
LDFLAGS = `pkg-config --libs opencv`


$(OUT): $(SRC)
	g++ $(SRC) $(CFLAGS)  -o $@

clean:
	@rm -f $(PROGS) $(OBJS) $(TEMPS)
	@echo "CLEAANNNN!"
