```bash
docker run --rm --privileged \
    -v /dev:/dev \
    -v ${PWD}:/build \
    mkaczanowski/packer-builder-arm \
        build \
        -var-file=_example.pkrvars.hcl \
        -var="image_path=rpi.img" \
        pi.pkr.hcl
```