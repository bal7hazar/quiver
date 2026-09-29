# quiver

Cairo packages for Starknet games: **pure Cairo libraries and pure Starknet components, no
Dojo**. One repository, a Scarb workspace, **one package per feature**, each published on
[scarbs.xyz](https://scarbs.xyz) and versioned on its own, with its own changelog and `GAS.md`.

The first packages are native rewrites of the owner's
[Arcade](https://github.com/cartridge-gg/arcade) packages, needed by the game
[Grim World](https://github.com/bal7hazar/grimworld):

| Package | Does | State |
|---|---|---|
| `quiver_quest` | Quests made of tasks with a target count; one-off or recurring; prerequisites checked at acceptance; at most 4 held quests per player; claim through a hook the consumer implements | **0.1.0 on [scarbs.xyz](https://scarbs.xyz/packages/quiver_quest)** |
| `quiver_achievement` | Achievements made of tasks, with tiers sharing a task; points; **event mode only** in 0.1.0 (progress as events, tiers derived by an indexer); storage mode planned later | **0.1.0 on [scarbs.xyz](https://scarbs.xyz/packages/quiver_achievement)** |

Names: packages of our own take the prefix of the repository (`quiver_quest`); a mirror of a
Rust crate keeps the crate's name (Grim World, D-126). Names are confirmed at gate A-G1 with
the registry's availability.

## Shape of a package

| | |
|---|---|
| Logic | A Cairo library without storage: state in, state out |
| Component | A Starknet component around it: storage, events, and hooks the consumer implements |
| Modes | Storage when a rule of the consumer reads the data; events when it is only shown; chosen per call |
| Access control | Only contracts the consumer registers may report progress |

## Toolchain

Scarb 2.19.4 (Cairo 2.19), Starknet Foundry 0.61; `snforge_std` is a dev-dependency.
Engineering rules: [docs/CAIRO.md](docs/CAIRO.md): execution cost first, test-driven, a gas
budget on every test.

## How the work is done

The repository is run by an orchestrator session that answers to the project manager of Grim
World, under the game's
[OPERATIONS.md](https://github.com/bal7hazar/grimworld/blob/main/OPERATIONS.md): committed
briefs, one agent per task in its own worktree, pull requests merged on green CI after audit.

| | |
|---|---|
| [PLAN.md](PLAN.md) | Track ARC: tasks, order, gates |
| [STATUS.md](STATUS.md) | Live state, dated |
| [docs/](docs/README.md) | Briefs, research, decisions, reports |
| [scripts/agent.sh](scripts/agent.sh) | The launcher of sub-agents; [scripts/lock.sh](scripts/lock.sh) the build lock |

## Licence

[MIT](LICENSE).
