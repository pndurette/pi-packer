
# pi-packer

An opinionated [HashiCorp Packer](https://www.packer.io) template for Raspberry Pi images, built around the [`packer-builder-arm`](https://github.com/mkaczanowski/packer-builder-arm) ARM Packer builder plugin.

## Usage
(e.g. using the [`usb-gadget/usb_gadget.pkrvars.hcl`](usb-gadget/usb\_gadget.pkrvars.hcl) [variable override file](https://www.packer.io/docs/templates/hcl_templates/variables#variable-definitions-pkrvars-hcl-and-auto-pkrvars-hcl-files) for the inputs below)
```bash
docker run --rm --privileged \
    -v /dev:/dev \
    -v ${PWD}:/build \
    mkaczanowski/packer-builder-arm \
        build \
        -var-file=usb_gadget.pkrvars.hcl \
        pi.pkr.hcl
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_boot_cmdline"></a> [boot\_cmdline](#input\_boot\_cmdline) | [`/boot/cmdline.txt`](https://www.raspberrypi.org/documentation/configuration/cmdline-txt.md) Linux kernel boot parameters, as a list, which will be joined into a space-delimited string | `list(string)` | <pre>[<br>  "console=serial0,115200",<br>  "console=tty1",<br>  "root=PARTUUID=9730496b-02",<br>  "rootfstype=ext4",<br>  "elevator=deadline",<br>  "fsck.repair=yes",<br>  "rootwait",<br>  "quiet",<br>  "init=/usr/lib/raspi-config/init_resize.sh"<br>]</pre> | no |
| <a name="input_boot_config"></a> [boot\_config](#input\_boot\_config) | [`/boot/config.txt` Raspberry Pi configs](https://www.raspberrypi.org/documentation/configuration/config-txt/README.md) as a list. | `list(string)` | `[]` | no |
| <a name="input_boot_config_filters"></a> [boot\_config\_filters](#input\_boot\_config\_filters) | [`/boot/config.txt` Raspberry Pi *conditional filters* configs](https://www.raspberrypi.org/documentation/configuration/config-txt/conditional.md), as a map of the type `<filter>: [<configs list>]`.<br/><br/>e.g. `{"[pi0]": ["item1", "item2"]}` will yield:<br/>`[pi0]`<br/>`item1`<br/>`item2` | `map(list(string))` | `{}` | no |
| <a name="input_cloudinit_metadata_file"></a> [cloudinit\_metadata\_file](#input\_cloudinit\_metadata\_file) | The local path to a cloud-init metadata file | `string` | n/a | yes |
| <a name="input_cloudinit_userdata_file"></a> [cloudinit\_userdata\_file](#input\_cloudinit\_userdata\_file) | The local path to a cloud-init userdata file | `string` | n/a | yes |
| <a name="input_file_checksum_type"></a> [file\_checksum\_type](#input\_file\_checksum\_type) | The checksum type of `file_checksum_url`. See [packer-builder-arm](https://github.com/mkaczanowski/packer-builder-arm#remote-file) | `string` | `"sha256"` | no |
| <a name="input_file_checksum_url"></a> [file\_checksum\_url](#input\_file\_checksum\_url) | The checksum file URL of `file_url`. See [packer-builder-arm](https://github.com/mkaczanowski/packer-builder-arm#remote-file) | `string` | n/a | yes |
| <a name="input_file_target_extension"></a> [file\_target\_extension](#input\_file\_target\_extension) | The file extension of `file_url`. See [packer-builder-arm](https://github.com/mkaczanowski/packer-builder-arm#remote-file) | `string` | `"zip"` | no |
| <a name="input_file_url"></a> [file\_url](#input\_file\_url) | The URL of the OS image file. See [packer-builder-arm](https://github.com/mkaczanowski/packer-builder-arm#remote-file) | `string` | n/a | yes |
| <a name="input_image_path"></a> [image\_path](#input\_image\_path) | The file path the new OS image to create | `string` | n/a | yes |
| <a name="input_kernel_modules"></a> [kernel\_modules](#input\_kernel\_modules) | List of Linux kernel modules to enable, as seen in `/etc/modules` | `list(string)` | `[]` | no |
| <a name="input_locales"></a> [locales](#input\_locales) | List of locales to generate, as seen in `/etc/locale.gen` | `list(string)` | <pre>[<br>  "en_CA.UTF-8 UTF-8",<br>  "en_US.UTF-8 UTF-8"<br>]</pre> | no |
| <a name="input_wpa_supplicant_country"></a> [wpa\_supplicant\_country](#input\_wpa\_supplicant\_country) | The [ISO 3166-1 alpha-2](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) country code in which the device is operating, for `wpa_supplicant`. Necessary for [country-specific radio regulations](https://www.oreilly.com/library/view/learn-robotics-programming/9781789340747/5027f394-f16e-4096-bbaf-05e19070e84e.xhtml) | `string` | `"CA"` | no |
| <a name="input_wpa_supplicant_enabled"></a> [wpa\_supplicant\_enabled](#input\_wpa\_supplicant\_enabled) | Create a [`wpa_supplicant.conf` file](https://www.raspberrypi.org/documentation/configuration/wireless/wireless-cli.md) on the image.<br/>If `wpa_supplicant_path` exists, it will be copied to the OS image, otherwise a basic `wpa_supplicant.conf` file will be created using `wpa_supplicant_ssid`, `wpa_supplicant_pass` and `wpa_supplicant_country` | `bool` | `true` | no |
| <a name="input_wpa_supplicant_pass"></a> [wpa\_supplicant\_pass](#input\_wpa\_supplicant\_pass) | The WiFi password | `string` | `""` | no |
| <a name="input_wpa_supplicant_path"></a> [wpa\_supplicant\_path](#input\_wpa\_supplicant\_path) | The local path to existing `wpa_supplicant.conf` to copy to the image. | `string` | `"/tmp/dummy"` | no |
| <a name="input_wpa_supplicant_ssid"></a> [wpa\_supplicant\_ssid](#input\_wpa\_supplicant\_ssid) | The WiFi SSID | `string` | `""` | no |
