#!/bin/bash

set -ex

export CI="true"
export PYTHON="3.9"
export RAY_USE_RANDOM_PORTS="1"
export RAY_DEFAULT_BUILD="1"
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
export BUILD="1"
export DL="1"


bisect() {
  # setup environment and build toolspt
  MINIMAL_INSTALL=1 . ./ci/ci.sh init && source ~/.zshenv
  source ~/.zshrc

  # run bisect
  test="$1"
  passing_revision="$2"
  failing_revision="$3"
  bazel run //ci/ray_ci:bisect_test -- $test $passing_revision $failing_revision
}


run_single_test() {
  # install dependencies
  pip install -U --ignore-installed \
    -c python/requirements_compiled.txt \
    -r python/requirements.txt \
    -r python/requirements/test-requirements.txt \
    -r python/requirements/ml/dl-cpu-requirements.txt

  # install ray
  ./ci/ci.sh build

  # run test
  bazel test --config=ci \
    --test_env=CONDA_EXE --test_env=CONDA_PYTHON_EXE \
    --test_env=CONDA_SHLVL --test_env=CONDA_PREFIX --test_env=CONDA_DEFAULT_ENV \
    --test_env=CONDA_PROMPT_MODIFIER --test_env=CI "$1"
}

"$@"