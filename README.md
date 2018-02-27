Packer builders for Windows server core images optimized for containers.

# Windows Server Core

This builds different versions of Windows server images ready for containers.

To be used for on-premise deployments of docker hosts or Kubernetes nodes.

## Images

| Name                           | Build   |  Core  |
| ------------------------------ | ------- | ------ |
| windows-server-core-1709       | 16299   | yes    |
| windows-server-insider-preview | 17093   | yes    |
| windows-server-2016            |         | no     |


## Status

`Experimental`

This is a work in progress.

### What works

TBD

### What doesn't work

Virtualbox images cannot currently be used for kubelet because of lack of support for winstats performance counters.

```bash
error: failed to run Kubelet: unable to read physical memory
```


## Prerequisites

Install [VirtualBox](https://www.virtualbox.org/) (or [libvirt](https://libvirt.org/) on Linux based systems), [packer](https://www.packer.io/), [packer-provisioner-windows-update plugin](https://github.com/rgl/packer-provisioner-windows-update) and [vagrant](https://www.vagrantup.com/).
If you are using Windows and [Chocolatey](https://chocolatey.org/), you can install everything with:

```batch
choco install -y virtualbox packer packer-provisioner-windows-update vagrant
```

## Usage

### libvirt

*Libvirt is preferred, because kubelet doesn't work well on virtualbox*

Build the base box for the [vagrant-libvirt provider](https://github.com/vagrant-libvirt/vagrant-libvirt) with:



```bash
make build-windows-server-core-1709-libvirt
```

You can then add the base box to your local vagrant installation with:

```bash
vagrant box add -f windows-server-core-1709 windows-server-core-1709-virtualbox.box
```

And test this base box by launching an example Vagrant environment:

```bash
cd example
vagrant up --provider=libvirt # or --provider=virtualbox
```

**NB** if you are having trouble running the example with the vagrant libvirt provider check the libvirt logs in the host (e.g. `sudo tail -f /var/log/libvirt/qemu/example_default.log`) and in the guest (inside `C:\Windows\Temp`).

Then test with a more complete example:

```bash
git clone https://github.com/rgl/customize-windows-vagrant
cd customize-windows-vagrant
vagrant up --provider=virtualbox # or --provider=libvirt
```

If you want to access the UI run:

```bash
spicy --uri 'spice+unix:///tmp/packer-windows-2016-amd64-libvirt-spice.socket'
```

### QCOW2

To build compatible qcow2 images, e.g for OpenStack, do:

```bash
make windows-server-core-1709.qcow2
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


## Troubleshooting

**NB** if the build fails with something like `Post-processor failed: write /tmp/packer073329394/packer-windows-2016-amd64-virtualbox-1505050546-disk001.vmdk: no space left on device` you need to increase your temporary partition size or change its location [as described in the packer TMPDIR/TMP environment variable documentation](https://www.packer.io/docs/other/environment-variables.html#tmpdir).

**NB** if you are having trouble building the base box due to floppy drive removal errors try adding, as a
workaround, `"post_shutdown_delay": "30s",` to the `windows-server-2016.json` file.

### Build warnings

#### Docker hyper-v

Some errors about Hyper-V during Docker EE installation will appear.

This is normal for now, packer+qemu doesn't enable nested virtualization (is it possible?)

```
windows-server-core-1709-libvirt: Installing Docker EE preview...
    windows-server-core-1709-libvirt: WARNING: A restart is required to enable the one or more features. Please restart your machine.
    windows-server-core-1709-libvirt: Install-Package : A prerequisite check for the Hyper-V feature failed.
    windows-server-core-1709-libvirt: 1. Hyper-V cannot be installed: The processor does not have required virtualization capabilities.
    windows-server-core-1709-libvirt: At C:\Windows\Temp\script-5a907637-3848-8817-1cc6-b042712d42db.ps1:15 char:1
    windows-server-core-1709-libvirt: + Install-Package -Name docker -ProviderName DockerProvider -RequiredVe ...
    windows-server-core-1709-libvirt: + ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    windows-server-core-1709-libvirt:     + CategoryInfo          : InvalidOperation: (Hyper-V:String) [Install-Package], Exception
    windows-server-core-1709-libvirt:     + FullyQualifiedErrorId : Alteration_PrerequisiteCheck_Failed,Microsoft.Windows.ServerManager.Commands.AddWindowsF
    windows-server-core-1709-libvirt:    eatureCommand,Microsoft.PowerShell.PackageManagement.Cmdlets.InstallPackage
```

# Credits

This is a fork of https://github.com/rgl/windows-2016-vagrant