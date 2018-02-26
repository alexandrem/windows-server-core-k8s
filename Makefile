help:
	@echo type make build-libvirt or make build-virtualbox

build-windows-server-core-1709-libvirt: windows-server-core-1709-libvirt.box

build-windows-server-core-1709-virtualbox: windows-server-core-1709-virtualbox.box

build-core-insider-libvirt: windows-core-insider-2016-libvirt.box

build-core-insider-virtualbox: windows-core-insider-2016-virtualbox.box

windows-server-core-1709-libvirt.box: windows-server-core-1709.json windows-server-core-1709/autounattend.xml Vagrantfile.template *.ps1 drivers
	rm -f $@
	packer build -only=windows-server-core-1709-libvirt -on-error=abort windows-server-core-1709.json
	@echo BOX successfully built!
	@echo to add to local vagrant install do:
	@echo vagrant box add -f windows-server-core-1709 $@

windows-server-core-1709-virtualbox.box: windows-server-core-1709.json windows-server-core-1709/autounattend.xml Vagrantfile.template *.ps1
	rm -f $@
	packer build -only=windows-server-core-1709-virtualbox -on-error=abort windows-server-core-1709.json
	@echo BOX successfully built!
	@echo to add to local vagrant install do:
	@echo vagrant box add -f windows-server-core-1709 $@

windows-core-insider-2016-libvirt.box: windows-core-insider-2016.json windows-core-insider-2016/autounattend.xml Vagrantfile.template *.ps1 drivers
	rm -f $@
	packer build -only=windows-core-insider-2016-libvirt -on-error=abort windows-core-insider-2016.json
	@echo BOX successfully built!
	@echo to add to local vagrant install do:
	@echo vagrant box add -f windows-core-insider-2016 $@

windows-core-insider-2016-virtualbox.box: windows-core-insider-2016.json windows-core-insider-2016/autounattend.xml Vagrantfile.template *.ps1
	rm -f $@
	packer build -only=windows-core-insider-2016-virtualbox -on-error=abort windows-core-insider-2016.json
	@echo BOX successfully built!
	@echo to add to local vagrant install do:
	@echo vagrant box add -f windows-core-insider-2016 $@

windows-server-insider-preview-libvirt.box: windows-server-insider-preview.json windows-server-insider-preview/autounattend.xml Vagrantfile.template *.ps1 drivers
	rm -f $@
	packer build -only=windows-server-insider-preview-libvirt -on-error=abort windows-server-insider-preview.json
	@echo BOX successfully built!
	@echo to add to local vagrant install do:
	@echo vagrant box add -f windows-server-insider-preview $@

drivers:
	rm -rf drivers.tmp
	mkdir -p drivers.tmp
	@# see https://fedoraproject.org/wiki/Windows_Virtio_Drivers
	wget -P drivers.tmp https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.141-1/virtio-win-0.1.141.iso
	7z x -odrivers.tmp drivers.tmp/virtio-win-*.iso
	mv drivers.tmp drivers

.PHONY: clean
clean:
	rm -fr output-*
	rm -f *.box
	rm -f *.qcow2

windows-server-core-1709.qcow2: windows-server-core-1709-libvirt.box
	@set -e; \
	mv output-windows-server-core-1709-libvirt/* $@; \
	rm -r output-windows-server-core-1709-libvirt

windows-core-insider-2016.qcow2: windows-core-insider-2016-libvirt.box
	@set -e; \
	mv output-windows-core-insider-2016-libvirt/* $@; \
	rm -r output-windows-core-insider-2016-libvirt

windows-server-insider-preview.qcow2: windows-server-insider-preview-libvirt.box
	@set -e; \
	mv output-windows-server-insider-preview-libvirt/* $@; \
	rm -r output-windows-server-insider-preview-libvirt
