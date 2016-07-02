#!/bin/bash

INTERFACE=""

pathspider -i $INTERFACE /usr/share/doc/pathspider/examples/webtest.csv /tmp/output.txt
mv /tmp/output-$INTERFACE.txt /monroe/results

