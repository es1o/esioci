#esioci

EsioCi is an OpenSource Continuous Integration software

[![Build Status](https://travis-ci.org/esioci/esioci.svg?branch=master)](https://travis-ci.org/esioci/esioci)
[![Coverage Status](https://coveralls.io/repos/github/esioci/esioci/badge.svg)](https://coveralls.io/github/esioci/esioci)
[![Deps Status](https://beta.hexfaktor.org/badge/all/github/esioci/esioci.svg)](https://beta.hexfaktor.org/github/esioci/esioci)
[![codebeat badge](https://codebeat.co/badges/7480d1d8-cd6e-4565-977d-8ee8260db250)](https://codebeat.co/projects/github-com-esioci-esioci)

## Requirements
* Elixir >= 1.2
* OTP 19
* PostgreSQL database
* Redis database

## How To Use
### Installation and Configuration
1. Download source code
2. Configure application via ENV variables
  1. ESIOCI_API_PORT       => port witch esioci starts, default is 4000
  2. ESIOCI_DB             => database name, default is "esioci"
  3. ESIOCI_DB_USER        => database user
  4. ESIOCI_DB_PASSWD      => database password
  5. ESIOCI_DB_HOST        => database host
  6. ESIOCI_POLLER_NTERVAL => poller run interval in ms, default 60000
  3. Set artifacts directory, default is /tmp/artifacts
3. Create database:
  HINT: You can run dev database instance in docker: `docker run --name some-postgres -p 5432:5432 -d postgres`
4. Run migration `mix ecto.migrate`
5. Seed database `mix run priv/repo/seeds.exs`
6. Run application `screen iex -S mix run`
7. Configure github push webhook and point it to `address:port/api/v1/default/bld/gh`

### Configuration file
All app configuration in config/config.exs, see comments for details


### esioci.yaml
esioci.yaml file is a file with all builds configuration. This file should be placed in your's repository root.

#### Example esioci.yaml:
```
---
build:
  - exec: "cmd1"
  - exec: "cmd2"
artifacts: "artifacts_file.txt"
```

#### yaml commands:

* build: master build configuration
* exec: command to execute, supports multiple commands. Each command will be execute in order from up to down in file.
* artifacts: one file or directory, or pattern to copy to artifacts directory

### API endpoints

#### Builds
##### GET api/v1/**project_name**/bld/last
Returns json with last build status for project: project_name

##### GET api/v1/**project_name**/bld/**build_id**
Returns json with specific build

##### GET api/v1/**project_name**/bld/all
Returns json with all builds for specific project

#### Projects

##### GET api/v1/**project_name**
Returns json with information about specific project

##### GET api/v1/projects/**project_id**
Returns json with information about project with id

##### GET api/v1/projects/all
Returns json with information about all project

#### POST api/v1/**project_name**/bld/gh
Run github project

#### GET artifacts/**build_id**/build_**build_id**.txt
Get build log.

## How To Develop
### Run app first time
1. get dependencies `mix deps.get`
1. compile `mix compile`
1. Run docker images with psql and Redis
  1. `docker run -p 5432:5432 -d postgres:10.2`
  1. `docker run -d -p 6379:6379 redis`
1. Create database `mix ecto.create`
1. Migrate database `mix ecto.migrate`
1. Seed database `mix run priv/repo/seeds.exs`
1. run `iex -S mix run`

### Unit tests
1. Prepare test database
  1. `MIX_ENV=test mix ecto.create`
  1. `MIX_ENV=test mix ecto.migrate`
  1. `MIX_ENV=test mix run priv/repo/seeds.exs`
1. Run unit tests and generate html coverage report `mix coveralls.html`
2. Coverage html report in cover directory

## Changelog:

[Changelog](Changelog.md)

Authors
-----
Grzegorz "esio" Eliszewski - http://esio.one.pl
