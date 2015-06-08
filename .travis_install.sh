#!/usr/bin/env bash
set -x

local_deb_extract()
{
    wget $1
    ar vx *.deb
    tar xvf data.tar.gz
    rm -f *.tar.gz *deb*
}

get_binutils()
{
    BINUTILS_PREFIX='https://launchpad.net/~pwntools/+archive/ubuntu/binutils/+files/binutils-'
    BINUTILS_SUFFIX='-linux-gnu_2.22-6ubuntu1.1cross0.11pwntools12~precise_amd64.deb'
    local_deb_extract "${BINUTILS_PREFIX}${1}${BINUTILS_SUFFIX}"
}

setup_travis()
{
    export PATH=$PWD/usr/bin:$PATH
    export LD_LIBRARY_PATH=$PWD/usr/lib

    if [ ! -d usr/bin ];
    then
        which arm-linux-as     || get_binutils arm
        which mips-linux-as    || get_binutils mips
        which powerpc-linux-as || get_binutils powerpc
        local_deb_extract http://mirrors.mit.edu/ubuntu/ubuntu/pool/universe/b/binutils/binutils-multiarch_2.22-6ubuntu1_amd64.deb
        rm -rf usr/share
    fi

    pushd usr/lib
    ln -sf libbfd-2.22-multiarch.so libbfd-2.22.so
    ln -sf libopcodes-2.22-multiarch.so libopcodes-2.22.so
    popd

    which arm-linux-gnu-as
    which mips-linux-gnu-as
    which powerpc-linux-gnu-as
}

setup_linux()
{
    sudo apt-get install -y software-properties-common openssh-server ssh
    sudo apt-add-repository --yes ppa:pwntools/binutils
    sudo apt-get update
    sudo apt-get install binutils-arm-linux-gnu binutils-mips-linux-gnu binutils-powerpc-linux-gnu
    sudo service ssh restart
}

setup_osx()
{
    brew update
    brew install binutils
    brew install capstone
}

if [[ "$USER" == "travis" ]]; then
    setup_travis
elif [[ "$USER" == "shippable" ]]; then
    sudo apt-get install ssh
    sudo sshd -f /etc/ssh/sshd_config &
    setup_travis
elif [[ "$(uname)" == "Darwin" ]]; then
    setup_osx
elif [[ "$(uname)" == "Linux" ]]; then
    setup_linux
fi

service ssh status
ps auxf
sudo cat /etc/ssh/sshd_config