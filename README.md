# docker-ghr

[![CircleCI](https://circleci.com/gh/trussworks/docker-ghr/tree/master.svg?style=svg)](https://circleci.com/gh/trussworks/docker-ghr/tree/master)

This image is used to create Github releases.

This docker image is built off of CircleCI's python 3.8.5 convenience image [`cimg/python:3.8.5`](https://hub.docker.com/r/cimg/python) with the following tools installed on top:

- [AWS CLI](https://aws.amazon.com/cli/)
- [GHR](https://github.com/tcnksm/ghr)
- [SHELLCHECK](https://github.com/koalaman/shellcheck)