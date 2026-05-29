FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# Remove the original 0005 patch (broken DMA API usage) and replace with
# our fixed version that includes hashtable lookup, correct dma_free_pages
# pairing, and 40-bit DMA mask on the MGM platform device.
SRC_URI:remove = "file://0005-Fix-translation-faults-by-using-dma_alloc_pages-for-.patch"

SRC_URI += " \
    file://0005-Fix-translation-faults-by-using-dma_alloc_pages-for-.patch \
    file://load-mali-modules-xen.sh \
"

do_install:append() {
    if ${@bb.utils.contains('DISTRO_FEATURES', 'xen', 'true', 'false', d)}; then
        install -m 0755 ${WORKDIR}/load-mali-modules-xen.sh ${D}/usr/bin/load-mali-modules.sh
    fi
}
