This builds Windows server core images for local development of Kubernetes Windows nodes.

# Status

`Experimental`

This is a work in progress.

## What works

TBD

## What doesn't work

Virtualbox images cannot currently be used for kubelet because of lack of support for winstats performance counters.

```bash
error: failed to run Kubelet: unable to read physical memory
```

# Usage

Install [VirtualBox](https://www.virtualbox.org/) (or [libvirt](https://libvirt.org/) on Linux based systems), [packer](https://www.packer.io/), [packer-provisioner-windows-update plugin](https://github.com/rgl/packer-provisioner-windows-update) and [vagrant](https://www.vagrantup.com/).
If you are using Windows and [Chocolatey](https://chocolatey.org/), you can install everything with:

```batch
choco install -y virtualbox packer packer-provisioner-windows-update vagrant
```

To build the base box based on the [Windows Server 2016 Evaluation](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2016) ISO run:

```bash
packer build -only=windows-2016-amd64-virtualbox windows-2016.json # or make build-libvirt
```

If you want to use your own ISO, run the following instead:

```bash
packer build -var iso_url=<ISO_URL> -var iso_checksum=<ISO_SHA256_CHECKSUM> -only=windows-2016-amd64-virtualbox windows-2016.json
```

**NB** if the build fails with something like `Post-processor failed: write /tmp/packer073329394/packer-windows-2016-amd64-virtualbox-1505050546-disk001.vmdk: no space left on device` you need to increase your temporary partition size or change its location [as described in the packer TMPDIR/TMP environment variable documentation](https://www.packer.io/docs/other/environment-variables.html#tmpdir).

**NB** if you are having trouble building the base box due to floppy drive removal errors try adding, as a
workaround, `"post_shutdown_delay": "30s",` to the `windows-2016.json` file.


You can then add the base box to your local vagrant installation with:

```bash
vagrant box add -f windows-2016-amd64 windows-2016-amd64-virtualbox.box
```

And test this base box by launching an example Vagrant environment:

```bash
cd example
vagrant up --provider=virtualbox # or --provider=libvirt
```

**NB** if you are having trouble running the example with the vagrant libvirt provider check the libvirt logs in the host (e.g. `sudo tail -f /var/log/libvirt/qemu/example_default.log`) and in the guest (inside `C:\Windows\Temp`).

Then test with a more complete example:

```bash
git clone https://github.com/rgl/customize-windows-vagrant
cd customize-windows-vagrant
vagrant up --provider=virtualbox # or --provider=libvirt
```


## libvirt

Build the base box for the [vagrant-libvirt provider](https://github.com/vagrant-libvirt/vagrant-libvirt) with:

```bash
make build-libvirt
```

If you want to access the UI run:

```bash
spicy --uri 'spice+unix:///tmp/packer-windows-2016-amd64-libvirt-spice.socket'
```

## Remote powershell

TBD

## WinRM access

You can connect to this machine through WinRM to run a remote command, e.g.:

```batch
winrs -r:localhost:55985 -u:vagrant -p:vagrant "whoami /all"
```

**NB** the exact local WinRM port should be displayed by vagrant, in this case:

```plain
==> default: Forwarding ports...
    default: 5985 (guest) => 55985 (host) (adapter 1)
```

# Credits

This is a fork of https://github.com/rgl/windows-2016-vagrant
