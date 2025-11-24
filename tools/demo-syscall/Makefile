KDIR			?= $(abspath ../..)
KBUILD_OUTPUT		?=
OUT_DIR		?= $(CURDIR)/build
HEADERS_DIR		?= $(OUT_DIR)/headers

INIT_BINARY		:= $(OUT_DIR)/init
INITRAMFS_LIST		:= $(OUT_DIR)/initramfs.list
INITRAMFS		:= $(OUT_DIR)/initramfs.cpio.gz
HEADERS_STAMP		:= $(HEADERS_DIR)/.stamp

CC			?= gcc
CFLAGS			?= -O2 -g -Wall -Wextra -static -std=gnu11

KMAKE			:= $(MAKE) -C $(KDIR)
ifneq ($(KBUILD_OUTPUT),)
KMAKE			+= O=$(KBUILD_OUTPUT)
endif

.PHONY: all clean headers initramfs

all: $(INITRAMFS)

clean:
	rm -rf $(OUT_DIR)

headers: $(HEADERS_STAMP)

initramfs: $(INITRAMFS)

$(OUT_DIR):
	mkdir -p $(OUT_DIR)

$(HEADERS_STAMP): | $(HEADERS_DIR)
	$(KMAKE) headers_install INSTALL_HDR_PATH=$(HEADERS_DIR)
	touch $@

$(HEADERS_DIR):
	mkdir -p $(HEADERS_DIR)

$(INIT_BINARY): init.c $(HEADERS_STAMP) | $(OUT_DIR)
	$(CC) $(CFLAGS) -I$(HEADERS_DIR)/include -o $@ $<

$(INITRAMFS_LIST): $(INIT_BINARY) | $(OUT_DIR)
	@echo "file /init $(INIT_BINARY) 755 0 0" > $@
	@echo "dir /dev 755 0 0" >> $@
	@echo "nod /dev/console 0600 0 0 c 5 1" >> $@
	@echo "dir /proc 755 0 0" >> $@
	@echo "dir /sys 755 0 0" >> $@
	@echo "dir /tmp 1777 0 0" >> $@

$(INITRAMFS): $(INITRAMFS_LIST)
	$(KDIR)/usr/gen_init_cpio $< | gzip -9 > $@
	@echo "Built $@"
