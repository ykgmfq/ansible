#!/usr/bin/bash
psql -U postgres -h localhost -d icingadb -f $@
