# Conventions

- **Device-specific values go in the personal repo at `personal/`**, not here — hostnames, domains, addresses, MACs, leases, the adblock endpoint.
  Roles keep generic defaults; see `personal/README.md` for the variables expected.
- **Always use `just` commands** instead of invoking tools directly.
- **Keep CLAUDE.md and README files general** — describe purpose and scope, not implementation details.
- **Comment only what is truly non-obvious** — keep comments short and don't restate values, paths, or names defined elsewhere, since those drift.
- **Before reporting done**, run the `docs-curator` agent (if the task touched code, config, or prose), then `pre-commit run --all-files`.
- **`server.butane`** only takes effect on a fresh install; use Ansible roles for changes to a running host.
