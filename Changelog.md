# esioCI changelog
## v0.6 - 12.03.2017
* Other
    - Add pooling, now projects in database has repository collumn. EsioCI polls that repository and builds if detect changes.
    - Fix code style.
    - Upgrade elixir and hex packages.

## v0.5 - 27.09.2016
* API
    - get build log
* Other
    - EsioCi.Builder module refactoring, add test, increase code coverage
    - save build log to file in addition to standard application log

## v0.4.1 - 4.09.2016
* Fixes
    - fix problem with build continues if step fails
    - fix esioci.yaml file

## v0.4 - 24.08.2016
* API
    - add support for bitbucket
* YAML
    - basic support for artifacts, esioci copies files to /tmp
* Fixes
    - fix run_cmd if cmd directory doesn't exist
    - fix non deterministic unit tests
* Other
    - Enable logging to file, by default all log comes to debug.log

## v0.3 - 10.08.2016
* API
    - get all builds from project
    - get all projects
    - get project by id
* YAML
    - run multiple exec from one esioci.yml file
* Fixes
    - Bug with build stuck in RUNNING state if parse yaml fails
    - Bug with parse only one command from esioci.yaml

## v0.2 - 30.07.2016
* API
    - get build by id
    - get project by name
* Improvement code quality and code coverage

## v0.1 - 24.07.2016
* Support for github requests
* exec() command in esioci.yaml
* API
    - check last build status via api
