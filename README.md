
# pi-packer

An opinionated [HashiCorp Packer](https://www.packer.io) template for Raspberry Pi images, built around the [`packer-builder-arm`](https://github.com/mkaczanowski/packer-builder-arm) ARM Packer builder plugin.

## Usage
```bash
docker run --rm --privileged \
    -v /dev:/dev \
    -v ${PWD}:/build \
    mkaczanowski/packer-builder-arm \
        build \
        -var-file=base.pkrvars.hcl \
        -var-file=usb_gadget.pkrvars.hcl \
        pi.pkr.hcl
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_boot_cmdline"></a> [boot\_cmdline](#input\_boot\_cmdline) | n/a | `list(string)` | `[]` | no |
| <a name="input_boot_config"></a> [boot\_config](#input\_boot\_config) | n/a | `list(string)` | `[]` | no |
| <a name="input_boot_config_filters"></a> [boot\_config\_filters](#input\_boot\_config\_filters) | n/a | `map(list(string))` | `{}` | no |
| <a name="input_cloudinit_metadata_file"></a> [cloudinit\_metadata\_file](#input\_cloudinit\_metadata\_file) | n/a | `string` | `""` | no |
| <a name="input_cloudinit_userdata_file"></a> [cloudinit\_userdata\_file](#input\_cloudinit\_userdata\_file) | n/a | `string` | `""` | no |
| <a name="input_file_checksum_type"></a> [file\_checksum\_type](#input\_file\_checksum\_type) | The checksum type of `file_checksum_url`. See [packer-builder-arm](https://github.com/mkaczanowski/packer-builder-arm#remote-file) | `string` | `"sha256"` | no |
| <a name="input_file_checksum_url"></a> [file\_checksum\_url](#input\_file\_checksum\_url) | The checksum file URL of `file_url`. See [packer-builder-arm](https://github.com/mkaczanowski/packer-builder-arm#remote-file) | `string` | n/a | yes |
| <a name="input_file_target_extension"></a> [file\_target\_extension](#input\_file\_target\_extension) | The file extension of `file_url`. See [packer-builder-arm](https://github.com/mkaczanowski/packer-builder-arm#remote-file) | `string` | `"zip"` | no |
| <a name="input_file_url"></a> [file\_url](#input\_file\_url) | The URL of the OS image file. See [packer-builder-arm](https://github.com/mkaczanowski/packer-builder-arm#remote-file) | `string` | n/a | yes |
| <a name="input_image_path"></a> [image\_path](#input\_image\_path) | The file path the new OS image to create | `string` | n/a | yes |
| <a name="input_kernel_modules"></a> [kernel\_modules](#input\_kernel\_modules) | n/a | `list(string)` | n/a | yes |
| <a name="input_locales"></a> [locales](#input\_locales) | List of locales to generate, as seen in `/etc/locale.gen` | `list(string)` | <pre>[<br>  "en_CA.UTF-8 UTF-8",<br>  "en_US.UTF-8 UTF-8"<br>]</pre> | no |
| <a name="input_wpa_supplicant_country"></a> [wpa\_supplicant\_country](#input\_wpa\_supplicant\_country) | n/a | `string` | `"CA"` | no |
| <a name="input_wpa_supplicant_enabled"></a> [wpa\_supplicant\_enabled](#input\_wpa\_supplicant\_enabled) | Create a [`wpa_supplicant.conf` file](https://www.raspberrypi.org/documentation/configuration/wireless/wireless-cli.md).<br/>If `wpa_supplicant_path` exists, it will be copied to the OS image, otherwise a basic `wpa_supplicant.conf` file will be created using `wpa_supplicant_ssid`, `wpa_supplicant_pass` and `wpa_supplicant_country` | `bool` | `true` | no |
| <a name="input_wpa_supplicant_pass"></a> [wpa\_supplicant\_pass](#input\_wpa\_supplicant\_pass) | n/a | `string` | `""` | no |
| <a name="input_wpa_supplicant_path"></a> [wpa\_supplicant\_path](#input\_wpa\_supplicant\_path) | n/a | `string` | `""` | no |
| <a name="input_wpa_supplicant_ssid"></a> [wpa\_supplicant\_ssid](#input\_wpa\_supplicant\_ssid) | n/a | `string` | `""` | no |
