#!/bin/bash
set -e -x
ls $HOME/build/urschrei/convertbng/convertbng
fi

if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
    cd $HOME/build/urschrei/convertbng && source venv/bin/activate
fi
# run the tests!
cd $HOME/build/urschrei/convertbng && nosetests -v --with-xcoverage --cover-package=convertbng --cover-tests

if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then
    docker run --rm -v `pwd`:/io $DOCKER_IMAGE $PRE_CMD /io/ci/build_wheel.sh
    ls wheelhouse/
