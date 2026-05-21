#!/bin/sh

brew ls --versions jj || (echo "Installing jj" && brew install jj)
