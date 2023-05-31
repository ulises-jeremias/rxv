<div align="center">
<h1>Reactive V</h1>

[vlang.io](https://vlang.io) |
[Docs](https://ulises-jeremias.github.io/rxv) |
[Contributing](https://github.com/ulises-jeremias/rxv/blob/main/CONTRIBUTING.md)

</div>
<div align="center">

[![Continuous Integration][workflowbadge]][workflowurl]
[![Deploy Documentation][deploydocsbadge]][deploydocsurl]
[![License: MIT][licensebadge]][licenseurl]

</div>

Reactive Extensions for the V language

## ReactiveX

[ReactiveX](http://reactivex.io/), or Rx for short, is an API for programming with Observable streams. This is the official ReactiveX API for [the V Programming language](https://vlang.io/).

ReactiveX is a new, alternative way of asynchronous programming to callbacks, promises, and deferred. It is about processing streams of events or items, with events being any occurrences or changes within the system. A stream of events is called an [Observable](http://reactivex.io/documentation/contract.html).

An operator is a function that defines an Observable, how and when it should emit data. The list of operators covered is available [here](README.md#supported-operators-in-rxv).

## RxV

The RxV implementation is based on the concept of pipelines. A pipeline is a series of stages connected by channels, where each stage is a group of routines running the same function.

### Install rxv

```sh
v install rxv
```

Done. Installation completed.

## Testing

To test the module, just type the following command:

```sh
./bin/test # execute `./bin/test -h` to know more about the test command
```

[workflowbadge]: https://github.com/ulises-jeremias/rxv/actions/workflows/ci.yml/badge.svg
[deploydocsbadge]: https://github.com/ulises-jeremias/rxv/actions/workflows/deploy-docs.yml/badge.svg
[licensebadge]: https://img.shields.io/badge/License-MIT-blue.svg
[workflowurl]: https://github.com/ulises-jeremias/rxv/actions/workflows/ci.yml
[deploydocsurl]: https://github.com/ulises-jeremias/rxv/actions/workflows/deploy-docs.yml
[licenseurl]: https://github.com/ulises-jeremias/rxv/blob/main/LICENSE
