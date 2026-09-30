# Linux Makefile to build NOVAS C library and test application
# using solsys1.c and fetch ephemeris file.

OBJ_DIR := ./obj
LIB_DIR := ./lib
APP_DIR := ./bin
BUILD_DIRS = $(OBJ_DIR) $(LIB_DIR) $(APP_DIR)

CC  := gcc
LD  := ld
AR  := ar
STRIP := strip

CFLAGS += -c -O2 -Wall -W -MMD -MP -MF $(subst .o,.d,$@)

COMPILE_C=@$(CC) -o $@ $(CFLAGS) $<
LINK=$(CC) $(LDFLAGS) -o $@ $^ -lm
MKLIB=@$(AR) -cr $@ $^


OBJS = $(patsubst %.c, $(OBJ_DIR)/%.o, $(SOURCES))
BUILD_TARGET_LIB = $(patsubst %, $(LIB_DIR)/%.a, $(TARGET_LIB))
DEPS = $(patsubst %.o, %.d, $(OBJS) $(TEST_OBJS))

TARGET_LIB := libnovas

SOURCES := \
	novas.c \
	novascon.c \
	nutation.c \
	solsys1.c \
	eph_manager.c \
	readeph0.c


all: $(BUILD_DIRS) $(BUILD_TARGET_LIB) JPLEPH check

# Builds a test and example executable to check library.
check: $(APP_DIR)/checkout-stars-full $(APP_DIR)/example
	$(APP_DIR)/checkout-stars-full > checkout-stars-full-local.txt
	@echo Comparing test output.
	diff -w checkout-stars-full-usno.txt checkout-stars-full-local.txt
	$(APP_DIR)/example > exampple-local.txt
	@echo Comparing example output.
	diff -w example-usno.txt example-local.txt

$(OBJ_DIR) $(LIB_DIR) $(APP_DIR):
	mkdir -p $@

$(OBJ_DIR)/%.o : %.c Makefile
	@echo $@
	$(COMPILE_C)

$(BUILD_TARGET_LIB): $(OBJS)
	@echo Updating library $@
	$(MKLIB)

JPLEPH:
	@echo Fetching $@
	# Fetch DE405 binary (little-endian), for 1900-2049
	wget -q -O $@ https://ssd.jpl.nasa.gov/ftp/eph/planets/Linux/de405/lnx1900.405

$(APP_DIR)/checkout-stars-full: $(OBJ_DIR)/checkout-stars-full.o $(BUILD_TARGET_LIB)
	@echo $@
	$(LINK)

$(APP_DIR)/example: $(OBJ_DIR)/example.o $(BUILD_TARGET_LIB)
	@echo $@
	$(LINK)


clean:
	@rm -rf $(LIB_DIR)/ $(OBJ_DIR)/ $(APP_DIR)/

realclean: clean
	@rm JPLEPH

-include $(DEPS)




