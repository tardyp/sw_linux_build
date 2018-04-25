# only build in parallel where it is necessary, and try to build serially where possible
NUMCPU:=$(shell getconf _NPROCESSORS_ONLN)

all:
	make -C shofel2/exploit
	make -C u-boot nintendo-switch_defconfig CROSS_COMPILE=aarch64-linux-gnu- 
	make -C u-boot  CROSS_COMPILE=aarch64-linux-gnu- 
	make -C coreboot nintendo_switch_defconfig
	make -C coreboot iasl
	make -C coreboot -j $(NUMCPU)
	make -C linux nintendo-switch_defconfig ARCH=arm64  CROSS_COMPILE=aarch64-linux-gnu-
	make -C linux ARCH=arm64  CROSS_COMPILE=aarch64-linux-gnu- -j$(NUMCPU)
	make -C imx_usb_loader
with_docker:
	sudo docker build docker -t sw_build
	sudo docker run -v `pwd`:/work sw_build make all