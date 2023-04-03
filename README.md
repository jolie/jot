# JoT - Jolie testing suite • Artefact Evaluation Branch

This repository comprises the source code of a code generator that transforms [LEMMA](https://github.com/SeelabFhdo/lemma) domain models into [Jolie](https://jolie-lang.org) APIs.

# Documentation

[Please, follow this link to consult the JoT documentation](documentation.md).

# Artefact Evaluation

To execute the software and generate the results for the artefact evaluation, please follow the steps below.

## Requirements

To run the evaluation, it's necessary to have installed Bash and Docker with Docker compose.

## Procedure

1. Clone the repository `git clone --branch ete repository_url`; `cd` into the cloned folder and run `ete/ete-test` the `docker_start.sh` Bash script. The script can execute the two scenarios found under the `ete/ete-test/test` folder. 

2. To run a test scenario, type the command `docker_start.sh X` where `X` is the name of the scenario. `X` can either be `scenario1` or `scenario2`.

3. In both scenarios, the execution outputs on the terminal the (successful) execution of the selected test.
