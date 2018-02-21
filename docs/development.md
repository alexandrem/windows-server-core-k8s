# WinRM and UAC (aka LUA)

This base image uses WinRM. WinRM [poses several limitations on remote administration](http://www.hurryupandwait.io/blog/safely-running-windows-automation-operations-that-typically-fail-over-winrm-or-powershell-remoting),
those were worked around by disabling User Account Control (UAC) (aka Limited User Account (LUA)) in `autounattend.xml`.

If needed, you can later enable it with:

```powershell
Set-ItemProperty -Path 'HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name EnableLUA -Value 1
Set-ItemProperty -Path 'HKLM:SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Policies\System' -Name EnableLUA -Value 1
Restart-Computer
```


# Windows Unattended Installation

When Windows boots from the installation media its Setup application loads the `a:\autounattend.xml` file.
It contains all the answers needed to automatically install Windows without any human intervention. For
more information on how this works see [OEM Windows Deployment and Imaging Walkthrough](https://technet.microsoft.com/en-us/library/dn621895.aspx).

`autounattend.xml` was generated with the Windows System Image Manager (WSIM) application that is
included in the Windows Assessment and Deployment Kit (ADK).

## Windows ADK

To create, edit and validate the `a:\autounattend.xml` file you need to install the Deployment Tools that
are included in the [Windows ADK](https://developer.microsoft.com/en-us/windows/hardware/windows-assessment-deployment-kit).

If you are having trouble installing the ADK (`adksetup`) or running WSIM (`imgmgr`) when your
machine is on a Windows Domain and the log has:

```plain
Image path is [\??\C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\DISM\wimmount.sys]
Could not acquire privileges; GLE=0x514
Returning status 0x514
```

It means there's a group policy that is restricting your effective permissions, for an workaround,
run `adksetup` and `imgmgr` from a `SYSTEM` shell, something like:

```batch
psexec -s -d -i cmd
adksetup
cd "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\WSIM"
imgmgr
```

For more information see [Error installing Windows ADK](http://blogs.catapultsystems.com/chsimmons/archive/2015/08/17/error-installing-windows-adk/).


# Libvirt base images left over cleanup

Creating new images with packer and loading them into vagrant-libvirt with same name will results in bad caching and latest changes will NOT be loaded into your virsh domain.

When generating a new image, do something like:

```
sudo virsh pool-list
sudo virsh vol-list default
sudo virsh vol-delete windows-server-core-1709-lv-ssh2_vagrant_box_image_0.img --pool default
```

Then you can use `vagrant-libvirt` to load this new image in libvirt store with a `vagrant up --provider libvirt`
