# Makefile to build NOVAS C library and test applications

OBJ_DIR := ./obj
LIB_DIR := ./lib
APP_DIR := ./bin
BUILD_DIRS = $(OBJ_DIR) $(LIB_DIR) $(APP_DIR)

CC  := gcc
LD  := ld
AR  := ar
STRIP := strip

CFLAGS += -c -O2 -Wall -W -MMD -MP -MF $(subst .o,.d,$@)

COMPILE_C=@$(CC) -o $@ $(CFLAGS) $(DEFINES) $(INCLUDES) $<
LINK=$(CC) $(LDFLAGS) -o $@ $^ -lm
MKLIB=@$(AR) -cr $@ $^


OBJS = $(patsubst %.c, $(OBJ_DIR)/%.o, $(SOURCES))
BUILD_TARGET_LIB = $(patsubst %, $(LIB_DIR)/%.a, $(TARGET_LIB))
DEPS = $(patsubst %.o, %.d, $(OBJS) $(TEST_OBJS))


SUBDIRS :=

TARGET_LIB := libnovas

SOURCES := \
	novas.c \
	novascon.c \
	nutation.c \
	solsys1.c \
	eph_manager.c \
	readeph0.c

INCLUDES :=


all: $(BUILD_DIRS) $(BUILD_TARGET_LIB)

# Builds a test executable to check library.
check: $(APP_DIR)/checkout-stars-full

$(OBJ_DIR) $(LIB_DIR) $(APP_DIR):
	mkdir -p $@

$(OBJ_DIR)/%.o : %.c Makefile
	@echo $@
	$(COMPILE_C)

$(BUILD_TARGET_LIB): $(OBJS)
	@echo Updating library $@
	$(MKLIB)


$(APP_DIR)/checkout-stars-full: $(OBJ_DIR)/checkout-stars-full.o $(BUILD_TARGET_LIB)
	@echo $@
	$(LINK)



clean:
	@rm -rf $(LIB_DIR)/ $(OBJ_DIR)/ $(APP_DIR)/

-include $(DEPS)




