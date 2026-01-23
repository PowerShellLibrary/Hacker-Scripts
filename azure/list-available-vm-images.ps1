# Full URNs format for Azure VM images: 'Publisher:Offer:Sku:Version'

az vm image list --publisher Debian --offer debian-12 --all --output table --sku 12-gen2

# Example output:
# Architecture    Offer            Publisher    Sku      Urn                                             Version
# --------------  -------------- - ---------- - ------ - ----------------------------------------------  -------------- -
# x64             debian-12        Debian       12-gen2  Debian:debian-12:12-gen2:0.20230531.1397        0.20230531.1397
# x64             debian-12        Debian       12-gen2  Debian:debian-12:12-gen2:0.20230612.1409        0.20230612.1409

# To get the latest version only - Debian 12 Gen2 image use: Debian:debian-12:12-gen2:latest
