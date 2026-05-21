#!/bin/sh

brew ls --versions gh || (echo "Installing gh" && brew install gh)
