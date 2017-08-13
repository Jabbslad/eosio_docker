FROM ubuntu

RUN apt-get update && apt-get -y install wget libssl-dev python-dev git g++ libbz2-dev libgmp-dev autoconf libtool make

WORKDIR ~

RUN wget https://cmake.org/files/v3.9/cmake-3.9.0.tar.gz && \
	tar -xvf cmake-3.9.0.tar.gz && \
	cd cmake-3.9.0/ && \
	./bootstrap && \
	make -j4 && \
	make install

RUN git clone https://github.com/cryptonomex/secp256k1-zkp.git && \
	cd secp256k1-zkp && \
	./autogen.sh && \
	./configure && \
	make && \
	make install

RUN mkdir  ~/wasm-compiler && \
	cd ~/wasm-compiler && \
	git clone --depth 1 --single-branch --branch release_40 https://github.com/llvm-mirror/llvm.git && \
	cd llvm/tools && \
	git clone --depth 1 --single-branch --branch release_40 https://github.com/llvm-mirror/clang.git && \
	cd .. && \
	mkdir build && \
	cd build && \
	cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=.. -DLLVM_ENABLE_RTTI=1 -DLLVM_TARGETS_TO_BUILD= -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD=WebAssembly -DCMAKE_BUILD_TYPE=Release ../ && \
	make -j4 install

RUN wget -O boost_1_64_0.tar.gz http://sourceforge.net/projects/boost/files/boost/1.64.0/boost_1_64_0.tar.gz/download && \
	tar xzvf boost_1_64_0.tar.gz && \
	cd boost_1_64_0/ && \
	./bootstrap.sh && \
	./b2 install

RUN mkdir  ~/eos-src && \
	cd ~/eos-src && \
	git clone https://github.com/eosio/eos --recursive && \
	mkdir -p eos/build && cd eos/build && \
	export WASM_LLVM_CONFIG=~/wasm-compiler/llvm/bin/llvm-config && \
	export LLVM_DIR=~/wasm-compiler/llvm/build/lib/cmake/llvm && \
	cmake .. && \
	make -j4