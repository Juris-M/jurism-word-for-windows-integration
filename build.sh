#!/bin/bash

set -e

# Release-dance code goes here.

# Constants
PRODUCT="Juris-M Word for Windows Integration"
IS_BETA="false"
FORK="jurism-word-for-windows-integration"
BRANCH="master"
CLIENT="jurism-word-for-windows-integration"
VERSION_ROOT="3.5.4m"
COMPILED_PLUGIN_URL="https://download.zotero.org/integration/Zotero-WinWord-Plugin-3.5.4.xpi"
#COMPILED_PLUGIN_URL="https://download.zotero.org/integration/Zotero-WinWord-Plugin-3.1.20.xpi"
SIGNED_STUB="juris_m_word_for_windows_integration-"

function xx-make-build-directory () {
    if [ -d "build" ]; then
        rm -fR build
    fi
    mkdir build
}

function xx-grab-install-rdf () {
    cp ../install.rdf .
}

function xx-retrieve-compiled-plugin () {
    trap booboo ERR
    echo "Fetch Zotero plugin"
    wget -O compiled-plugin.xpi "${COMPILED_PLUGIN_URL}" >> "${LOG_FILE}" 2<&1
    trap - ERR
    unzip compiled-plugin.xpi >> "${LOG_FILE}" 2<&1
    rm -f compiled-plugin.xpi
}

function xx-fix-product-ids () {
    # LO
    sed -si "s/zoteroOpenOfficeIntegration@zotero.org/jurismOpenOfficeIntegration@juris-m.github.io/g" install.rdf
    sed -si "s/zoteroOpenOfficeIntegration@zotero.org/jurismOpenOfficeIntegration@juris-m.github.io/g" resource/installer.jsm
    # Mac
    sed -si "s/zoteroMacWordIntegration@zotero.org/jurismMacWordIntegration@juris-m.github.io/g" install.rdf
    sed -si "s/zoteroMacWordIntegration@zotero.org/jurismMacWordIntegration@juris-m.github.io/g" resource/installer.jsm
    # Win
    sed -si "s/zoteroWinWordIntegration@zotero.org/jurismWinWordIntegration@juris-m.github.io/g" install.rdf
    sed -si "s/zoteroWinWordIntegration@zotero.org/jurismWinWordIntegration@juris-m.github.io/g" resource/installer.jsm
}

function xx-fix-product-name () {
    sed -si "/Copyright.*Zotero/n;/Zotero *=/n;s/Zotero\( \|\"\|$\)/Juris-M\\1/g" install.rdf
    sed -si "/Copyright.*Zotero/n;/Zotero *=/n;s/Zotero\( \|\"\|$\)/Juris-M\\1/g" resource/installer.jsm
    sed -si "/Copyright.*Zotero/n;/Zotero *=/n;s/Zotero\( \|\"\|$\)/Juris-M\\1/g" components/zoteroWinWordIntegration.js
    #sed -si "/Copyright.*Zotero/n;/Zotero *=/n;s/Zotero\( \|\"\|$\)/Juris-M\\1/g" components/errorHandler.js
}

function xx-fix-contributor () {
    sed -si "/<\/em:developer>/a\    <em:contributor>Frank Bennett</em:contributor>" install.rdf
}

function xx-install-icon () {
    cp ../additives/mlz_z_32px.png install/zotero.png
    cp ../additives/mlz_z_32px.png chrome/zotero.png
}

function xx-add-install-check-module () {
    cp ../additives/install_check.jsm resource
}

function xx-apply-patch () {
    patch -p1 < ../additives/word-install-check.patch >> "${LOG_FILE}" 2<&1
}

function xx-make-the-bundle () {
    zip -r "${XPI_FILE}" * >> "${LOG_FILE}"
}

function xx-fix-uuids () {
    sed -si "s/f123467c-0e8f-471a-89cb-c5c71f157f80/9478F426-2DDC-11E5-B116-B9D91D5D46B0/g" chrome.manifest
#    sed -si "s/f123467c-0e8f-471a-89cb-c5c71f157f80/9478F426-2DDC-11E5-B116-B9D91D5D46B0/g" components/errorHandler.js
    sed -si "s/c7a7eec5-f073-4db4-b383-f866f4b96b1c/AB3016FE-2DDC-11E5-9101-C0D91D5D46B0/g" chrome.manifest
    sed -si "s/c7a7eec5-f073-4db4-b383-f866f4b96b1c/AB3016FE-2DDC-11E5-9101-C0D91D5D46B0/g" components/zoteroWinWordIntegration.js
}

function xx-fix-install () {
    # ID everywhere
    sed -si "s/zotero@chnm.gmu.edu/juris-m@juris-m.github.io/g" resource/installer.jsm
    sed -si "s/zotero@chnm.gmu.edu/juris-m@juris-m.github.io/g" resource/installer_common.jsm
    # URLs
    sed -si "s/\(url: *\"\)\([^\"]*\)/\\1juris-m.github.io\/downloads/g" resource/installer.jsm
}

# Are we clever enough now not to need this?
function xx-insert-copyright-blocks () {
    sed -si "/BEGIN LICENSE/r ../additives/copyright_block.txt" resource/installer.jsm
    sed -si "/END OF INSERT/,/END LICENSE/d" resource/installer.jsm
    sed -si "/BEGIN LICENSE/r ../additives/copyright_block.txt" resource/installer_common.jsm
    sed -si "/END OF INSERT/,/END LICENSE/d" resource/installer_common.jsm
    sed -si "/BEGIN LICENSE/r ../additives/copyright_block.txt" components/zoteroWinWordIntegration.js
    sed -si "/END OF INSERT/,/END LICENSE/d" components/zoteroWinWordIntegration.js
#    sed -si "/BEGIN LICENSE/r ../additives/copyright_block.txt" components/errorHandler.js
#    sed -si "/END OF INSERT/,/END LICENSE/d" components/errorHandler.js
}

function build-the-plugin () {
        xx-make-build-directory
        cd build
        xx-grab-install-rdf
        xx-retrieve-compiled-plugin
        set-install-version
        xx-install-icon
        xx-fix-product-ids
        xx-fix-product-name
        xx-fix-contributor
        xx-install-icon
        xx-add-install-check-module
        xx-fix-uuids
        xx-fix-install
        xx-apply-patch
        xx-insert-copyright-blocks
        xx-make-the-bundle
        cd ..
    }
    
. jm-sh/frontend.sh
