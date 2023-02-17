#!/bin/bash

download_lj_speech () {
    mkdir -p "$1"
    wget --output-document "$1"/LJSpeech.tar.bz2 "$2" \
    && tar -xvf "$1"/LJSpeech.tar.bz2 --directory "$1" \
    && mv "$1"/LJSpeech-1.1 "$1"/lj_speech \
    && rm "$1"/LJSpeech.tar.bz2
}

download_libri_speech () {
    mkdir -p "$1"
    wget --output-document "$1"/"$2".tar.gz https://www.openslr.org/artifacts/12/"$2".tar.gz \
    && tar -xzvf "$1"/"$2".tar.gz --directory "$1" \
    && mv "$1"/LibriSpeech "$1"/libri_speech \
    && rm -rf "$1"/LibriSpeech \
    && rm "$1"/"$2".tar.gz
}

"$@"
