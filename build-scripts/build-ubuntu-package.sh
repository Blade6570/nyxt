#!/usr/bin/env bash
# SPDX-FileCopyrightText: Atlas Engineer LLC
# SPDX-License-Identifier: BSD-3-Clause

# Inspired by https://gitlab.com/ralt/linux-packaging/-/blob/eae586eaad5d6448121c53412ff3f2de712b24ca/.ci/build.sh.

set -xe

sudo gem install --no-document fpm &> /dev/null

export PATH=~/.gem/ruby/$(ls ~/.gem/ruby)/bin:$PATH

git clone --depth=1 --branch=sbcl-2.1.0 https://github.com/sbcl/sbcl.git ~/sbcl &> /dev/null
(
    cd ~/sbcl
    set +e
    sh make.sh --fancy --with-sb-linkable-runtime --with-sb-dynamic-core &> sbcl-build.log
    code=$?
    set -e
    test $code = 0 || (cat sbcl-build.log && exit 1)

    sudo sh install.sh &> /dev/null
)

export SBCL_HOME=/usr/local/lib/sbcl

curl -O https://beta.quicklisp.org/quicklisp.lisp && sbcl --load quicklisp.lisp --eval '(quicklisp-quickstart:install)' --eval '(ql:add-to-init-file)' --quit &> /dev/null
rm quicklisp.lisp

mkdir -p ~/common-lisp
git clone --depth=1 https://gitlab.com/ralt/linux-packaging.git ~/common-lisp/linux-packaging/ &> /dev/null
## Modern ASDF needed.
git clone --depth=1 --branch=3.3.4 https://gitlab.common-lisp.net/asdf/asdf.git ~/common-lisp/asdf/ &> /dev/null

mkdir -p ~/.config/common-lisp/source-registry.conf.d/
echo "(:tree \"$(pwd)/\")" >> ~/.config/common-lisp/source-registry.conf.d/linux-packaging.conf

echo
echo "==> ASDF diagnostic"
ls -la ~/.config/common-lisp/source-registry.conf.d/
sbcl \
  --eval '(require "asdf")' \
  --eval '(format t "- ASDF version: ~a~%" (asdf:asdf-version))' \
  --eval '(format t "- ASDF default registries: ~a~%" asdf:*default-source-registries*)' \
  --eval '(format t "- ASDF user source registry directory: ~a~%" (asdf/source-registry:user-source-registry-directory))' \
  --quit

echo
echo "==> Build package"
sbcl \
    --eval '(setf *debugger-hook* (lambda (c h) (declare (ignore h)) (format t "~A~%" c) (sb-ext:quit :unix-status -1)))' \
    --eval '(require "asdf")' \
    --load ~/quicklisp/setup.lisp \
    --eval "(ql:quickload :linux-packaging)" \
    --eval "(ql:quickload :nyxt)" \
    --eval "(ql:quickload :nyxt-ubuntu-package)" \
    --eval "(asdf:make :nyxt-ubuntu-package)" \
    --quit
