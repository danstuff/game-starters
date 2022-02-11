NAME=bin/boomslap
SRC=main game level menu music title player box option colorwheel input ball

ODIR=bin
SDIR=src

CXX=g++
CPPFLAGS=-g -MP -MD -I $(SDIR)

LDFLAGS=-g -I $(SDIR)
LDLIBS=-lsfml-graphics -lsfml-audio -lsfml-window -lsfml-system -lneuroscapes

OBJS=$(SRC:%=$(ODIR)/%.o)
SRCS=$(SRC:%=$(SDIR)/%.cpp)
DEPS=$(SRC:%=$(ODIR)/%.d)

-include $(DEPS)
	
$(ODIR)/%.o: $(SDIR)/%.cpp
	$(CXX) $(CPPFLAGS) -c -o $@ $<
	
all: $(NAME)
$(NAME): $(OBJS)
	$(CXX) $(LDFLAGS) -o $@ $^ $(LDLIBS)

.PHONY: clean
clean: 
	rm -f $(OBJS) $(DEPS) $(NAME)
