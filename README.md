
# pi-packer

An opinionated [HashiCorp Packer](https://www.packer.io) template for Raspberry Pi images, built around the [`packer-builder-arm`](https://github.com/mkaczanowski/packer-builder-arm) ARM Packer builder plugin. It implements [cloud-init](https://cloudinit.readthedocs.io/en/latest/index.html) for last-mile OS configuration and management.

See [`pi.pkr.hcl`](pi.pkr.hcl).

## Usage

### 1. Configuration values

Copy [`example.pkrvars.hcl`](example.pkrvars.hcl) and edit.

*(See [Packer docs](https://www.packer.io/docs/templates/hcl_templates/variables#assigning-values-to-build-variables) for more ways to set input variables)*.

### 2. Build

(e.g. using the [`usb-gadget/usb_gadget.pkrvars.hcl`](usb-gadget/usb\_gadget.pkrvars.hcl) [variable override file](https://www.packer.io/docs/templates/hcl_templates/variables#variable-definitions-pkrvars-hcl-and-auto-pkrvars-hcl-files) for the inputs below)
```bash
docker run --rm --privileged \
    -v /dev:/dev \
    -v ${PWD}:/build \
    mkaczanowski/packer-builder-arm \
        build \
        -var-file=usb-gadget/usb_gadget.pkrvars.hcl \
        pi.pkr.hcl
```
*(Using the above Docker image and run command is the easiest way to build cross-platform ARM images. See [`packer-builder-arm`](https://github.com/mkaczanowski/packer-builder-arm#quick-start) for alternative ways to run Packer with the `packer-builder-arm` plugin)*

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_boot_cmdline"></a> [boot\_cmdline](#input\_boot\_cmdline) | [`/boot/cmdline.txt`](https://www.raspberrypi.org/documentation/configuration/cmdline-txt.md) config.<br>    <br>Linux kernel boot parameters, as a list. Will be joined as a space-delimited string.<br><br>e.g.:<pre>boot_cmdline = [<br>    "abc",<br>    "def"<br>]</pre>Will create `/boot/cmdline.txt` as<pre>abc def</pre> | `list(string)` | <pre>[<br>  "console=serial0,115200",<br>  "console=tty1",<br>  "root=PARTUUID=9730496b-02",<br>  "rootfstype=ext4",<br>  "elevator=deadline",<br>  "fsck.repair=yes",<br>  "rootwait",<br>  "quiet",<br>  "init=/usr/lib/raspi-config/init_resize.sh"<br>]</pre> | no |
| <a name="input_boot_config"></a> [boot\_config](#input\_boot\_config) | [`/boot/config.txt`](https://www.raspberrypi.org/documentation/configuration/config-txt/README.md)<br><br>Raspberry Pi system configuration, as a list. Will be joined by newlines.<br><br>e.g.:<pre>boot_cmdline = [<br>    "abc=123",<br>    "def=456"<br>]</pre>Will begin `/boot/config.txt` with:<pre>abc=123<br>def=456</pre> | `list(string)` | `[]` | no |
| <a name="input_boot_config_filters"></a> [boot\_config\_filters](#input\_boot\_config\_filters) | [`/boot/config.txt`](ttps://www.raspberrypi.org/documentation/configuration/config-txt/conditional.md)<br><br>Raspberry Pi system *conditional filters* configuration, as a map.<br><br>e.g.:<pre>boot_config_filters =<br>    "[pi0]": [<br>        "jhi=123",<br>        "klm=456"<br>    ],<br>    "[pi0w]": [<br>        "xzy",<br>        "123"<br>    ],<br>}</pre>Will end `/boot/config.txt` with:<pre>[pi0]<br>jhi=123<br>klm=456<br>[pi0w]<br>xyz<br>123</pre> | `map(list(string))` | <pre>{<br>  "[pi4]": [<br>    "dtoverlay=vc4-fkms-v3d",<br>    "max_framebuffers=2"<br>  ]<br>}</pre> | no |
| <a name="input_cloudinit_metadata_file"></a> [cloudinit\_metadata\_file](#input\_cloudinit\_metadata\_file) | The local path to a cloud-init metadata file.<br>    <br>See the `cloud-init` [`NoCloud` datasource](https://cloudinit.readthedocs.io/en/latest/topics/datasources/nocloud.html) | `string` | n/a | yes |
| <a name="input_cloudinit_userdata_file"></a> [cloudinit\_userdata\_file](#input\_cloudinit\_userdata\_file) | The local path to a cloud-init userdata file.<br>    <br>See the `cloud-init` [`NoCloud` datasource](https://cloudinit.readthedocs.io/en/latest/topics/datasources/nocloud.html) | `string` | n/a | yes |
| <a name="input_file_checksum_type"></a> [file\_checksum\_type](#input\_file\_checksum\_type) | The checksum type of `file_checksum_url`.<br>    <br>See [packer-builder-arm](https://github.com/mkaczanowski/packer-builder-arm#remote-file). | `string` | `"sha256"` | no |
| <a name="input_file_checksum_url"></a> [file\_checksum\_url](#input\_file\_checksum\_url) | The checksum file URL of `file_url`.<br>    <br>See [packer-builder-arm](https://github.com/mkaczanowski/packer-builder-arm#remote-file). | `string` | n/a | yes |
| <a name="input_file_target_extension"></a> [file\_target\_extension](#input\_file\_target\_extension) | The file extension of `file_url`.<br>    <br>See [packer-builder-arm](https://github.com/mkaczanowski/packer-builder-arm#remote-file). | `string` | `"zip"` | no |
| <a name="input_file_url"></a> [file\_url](#input\_file\_url) | The URL of the OS image file.<br>    <br>See [packer-builder-arm](https://github.com/mkaczanowski/packer-builder-arm#remote-file). | `string` | n/a | yes |
| <a name="input_image_path"></a> [image\_path](#input\_image\_path) | The file path the new OS image to create. | `string` | n/a | yes |
| <a name="input_kernel_modules"></a> [kernel\_modules](#input\_kernel\_modules) | List of Linux kernel modules to enable, as seen in `/etc/modules` | `list(string)` | `[]` | no |
| <a name="input_locales"></a> [locales](#input\_locales) | List of locales to generate, as seen in `/etc/locale.gen`. | `list(string)` | <pre>[<br>  "en_CA.UTF-8 UTF-8",<br>  "en_US.UTF-8 UTF-8"<br>]</pre> | no |
| <a name="input_wpa_supplicant_country"></a> [wpa\_supplicant\_country](#input\_wpa\_supplicant\_country) | The [ISO 3166-1 alpha-2](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) country code in which the device is operating.<br>    <br>Required by the wpa\_supplicant. | `string` | `"CA"` | no |
| <a name="input_wpa_supplicant_enabled"></a> [wpa\_supplicant\_enabled](#input\_wpa\_supplicant\_enabled) | Create a [`wpa_supplicant.conf` file](https://www.raspberrypi.org/documentation/configuration/wireless/wireless-cli.md) on the image.<br>    <br>If `wpa_supplicant_path` exists, it will be copied to the OS image, otherwise a basic `wpa_supplicant.conf` file will be created using `wpa_supplicant_ssid`, `wpa_supplicant_pass` and `wpa_supplicant_country`. | `bool` | `true` | no |
| <a name="input_wpa_supplicant_pass"></a> [wpa\_supplicant\_pass](#input\_wpa\_supplicant\_pass) | The WiFi password. | `string` | `""` | no |
| <a name="input_wpa_supplicant_path"></a> [wpa\_supplicant\_path](#input\_wpa\_supplicant\_path) | The local path to existing `wpa_supplicant.conf` to copy to the image. | `string` | `"/tmp/dummy"` | no |
| <a name="input_wpa_supplicant_ssid"></a> [wpa\_supplicant\_ssid](#input\_wpa\_supplicant\_ssid) | The WiFi SSID. | `string` | `""` | no |
