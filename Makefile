.SUFFIXES:
ifeq ($(strip $(PSL1GHT)),)
$(error "Defina PSL1GHT")
endif

include $(PSL1GHT)/ppu_rules
LD := $(CC)

TARGET   := ytps3
BUILD    := build
SOURCES  := source
INCLUDES := include
TITLE    := YT PS3
APPID    := YTPS30001
CONTENTID := UP0001-$(APPID)_00-0000000000000000
SFOXML   := sfo.xml

CFLAGS   := -O2 -Wall -mcpu=cell $(MACHDEP) $(INCLUDE)
LDFLAGS  := $(MACHDEP) -Wl,-Map,$(notdir $@).map
LIBS     := -lnet -lnetctl -lsysmodule -lsysutil -lio -lrt -llv2

ifneq ($(BUILD),$(notdir $(CURDIR)))
export OUTPUT   := $(CURDIR)/$(TARGET)
export VPATH    := $(foreach d,$(SOURCES),$(CURDIR)/$(d))
export BUILDDIR := $(CURDIR)/$(BUILD)
export DEPSDIR  := $(BUILDDIR)
CFILES  := $(foreach d,$(SOURCES),$(notdir $(wildcard $(d)/*.c)))
export OFILES := $(CFILES:.c=.o)
export INCLUDE := $(foreach d,$(INCLUDES),-I$(CURDIR)/$(d)) \
                  -I$(PORTLIBS)/include -I$(CURDIR)/$(BUILD) -I$(PSL1GHT)/ppu/include
export LIBPATHS := -L$(PSL1GHT)/ppu/lib -L$(PORTLIBS)/lib

.PHONY: $(BUILD) clean pkg
$(BUILD):
	@mkdir -p $@
	@$(MAKE) --no-print-directory -C $(BUILD) -f $(CURDIR)/Makefile

clean:
	rm -rf $(BUILD) $(TARGET).elf $(TARGET).self $(TARGET).pkg

pkg: $(BUILD)
	@$(MAKE) --no-print-directory -C $(BUILD) -f $(CURDIR)/Makefile $(OUTPUT).pkg
else
$(OUTPUT).self: $(OUTPUT).elf
$(OUTPUT).elf: $(OFILES)
endif