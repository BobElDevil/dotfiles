#!/bin/sh

brew ls --versions aviator-co/tap/av || (echo "Installing av" && brew install aviator-co/tap/av)
