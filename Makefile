# only build in parallel where it is necessary, and try to build serially where possible
NUMCPU:=4
#$(shell getconf _NPROCESSORS_ONLN)

all:
	make -C shofel2/exploit
	make -C u-boot nintendo-switch_defconfig CROSS_COMPILE=aarch64-linux-gnu- 
	make -C u-boot  CROSS_COMPILE=aarch64-linux-gnu- 
	cp misc/tegra_mtc.bin coreboot
	make -C coreboot nintendo_switch_defconfig
	make -C coreboot iasl
	make -C coreboot -j $(NUMCPU)
	make -C linux nintendo-switch_defconfig ARCH=arm64  CROSS_COMPILE=aarch64-linux-gnu-
	make -C linux ARCH=arm64  CROSS_COMPILE=aarch64-linux-gnu- -j$(NUMCPU)
	make -C imx_usb_loader
	cd shofel2/usb_loader ; ../../u-boot/tools/mkimage -A arm64 -T script -C none -n "boot.scr" -d switch.scr switch.scr.img
	mkdir -p dist
	cp -r shofel2/usb_loader shofel2/exploit linux/arch/arm64/boot/dts/nvidia/tegra210-nintendo-switch.dtb linux/arch/arm64/boot/Image.gz coreboot/build/coreboot.rom dist
	tar czf dist.tgz dist
with_docker:
	sudo docker build docker -t sw_build
	sudo docker run -v `pwd`:/work sw_build make all