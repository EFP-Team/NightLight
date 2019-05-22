#!/usr/bin/env bash

set -e

source dependencies.sh

#ensure the Dockerfile version matches the dependencies.sh version
line=$(head -n 1 Dockerfile)
if [[ $line != *"$BYOND_MAJOR.$BYOND_MINOR"* ]]; then
  echo "Dockerfile BYOND version in FROM command does not match dependencies.sh (Or it's not on line 1)!"
  exit 1
fi

if [ $BUILD_TOOLS = false ] && [ $BUILD_TESTING = false ]; then
    curl https://sh.rustup.rs -sSf | sh -s -- -y --default-host i686-unknown-linux-gnu
    source ~/.profile

    mkdir rust-g
    cd rust-g
    git init
    git remote add origin https://github.com/tgstation/rust-g
    git fetch --depth 1 origin $RUST_G_VERSION
    git checkout FETCH_HEAD
    cargo build --release
    cmp target/rust_g.dm ../code/__DEFINES/rust_g.dm

    mkdir -p ~/.byond/bin
    ln -s $PWD/target/release/librust_g.so ~/.byond/bin/rust_g

    mkdir -p ../BSQL/artifacts
    cd ../BSQL
    git init
    git remote add origin https://github.com/tgstation/BSQL
    git fetch --depth 1 origin $BSQL_VERSION
    git checkout FETCH_HEAD

    if [ -f "$HOME/MariaDB/libmariadb.so.2" ] && [ -f "$HOME/MariaDB/libmariadb.so" ] && [ -d "$HOME/MariaDB/include" ];
    then
        echo "Using cached MariaDB library."
    else
        echo "Setting up MariaDB."
        rm -rf "$HOME/MariaDB"
        mkdir -p "$HOME/MariaDB"
        cp /usr/lib/i386-linux-gnu/libmariadb.so.2 $HOME/MariaDB/
        cp /tmp/extract/usr/include $HOME/MariaDB/
    fi

    cd artifacts
    export CXX=g++-7
    cmake .. -DMARIA_INCLUDE_DIR=$HOME/MariaDB/include
    make
    mv src/BSQL/libBSQL.so ../../
fi
