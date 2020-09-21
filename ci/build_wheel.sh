#!/bin/bash
set -e -x

PYBINS=(
  # "/opt/python/cp27-cp27m/bin"
  "/opt/python/cp27-cp27mu/bin"
  # "/opt/python/cp33-cp33m/bin"
  # "/opt/python/cp34-cp34m/bin"
  # "/opt/python/cp35-cp35m/bin"
  "/opt/python/cp36-cp36m/bin"
  "/opt/python/cp37-cp37m/bin"
  "/opt/python/cp38-cp38/bin"
  )

mkdir -p /io/wheelhouse
# ls -la /io
# ls -la /io/convertbng
echo $LD_LIBRARY_PATH
mkdir -p /usr/local/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
export DOCKER_BUILD=true
cp /io/convertbng/liblonlat_bng.so /usr/local/lib
# cp /io/convertbng/cutil.so /usr/local/lib

# Compile wheels
for PYBIN in ${PYBINS[@]}; do
    ${PYBIN}/pip install -r /io/dev-requirements.txt
    ${PYBIN}/pip wheel /io/ -w wheelhouse/ --no-deps
done

# output possibly-renamed wheels to new dir

mkdir /io/wheelhouse_r

pip install auditwheel==2.1.1

# Bundle external shared libraries into the wheels
for whl in wheelhouse/*.whl; do
    auditwheel repair $whl -w /io/wheelhouse_r/
done

# remove the 2010 wheels, since we're manylinux1-compatible
rm /io/wheelhouse_r/*2010*
FILES=/io/wheelhouse_r/*
for f in $FILES
do
  auditwheel show $f
done

# Install packages and test
for PYBIN in ${PYBINS[@]}; do
    ${PYBIN}/pip install convertbng --no-index -f /io/wheelhouse_r
    (cd $HOME; ${PYBIN}/nose2 convertbng)
done
