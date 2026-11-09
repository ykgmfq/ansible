# ssh_keys

Authorizes a configured set of public keys for root, additively.

## Purpose

Root access must survive losing any one controller or key, and the keys are device-specific, so they come from the personal repo.
Keys already on a host stay; removing one is manual.
