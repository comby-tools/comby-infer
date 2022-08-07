###############################################
### Use comby binary distribution image     ###
###############################################
# FROM comby/comby:latest AS comby-binary-distribution

###############################################
### Build rule inference server             ###
###############################################
FROM ocaml/opam:ubuntu-20.04-ocaml-4.14

# Install Comby
RUN sudo apt-get update && sudo apt-get install -y libev4 libev-dev libpcre3-dev 
RUN curl -sL get-comby.netlify.app > install.sh
RUN chmod +x install.sh
RUN sudo ./install.sh

## Source build InferRules binary
COPY InferRules /home/comby-infer/InferRules
RUN sudo chown -R $(whoami) /home/comby-infer
WORKDIR /home/comby-infer/InferRules
RUN sudo apt-get install -y ca-certificates-java  default-jdk
RUN ./gradlew build -x test --no-daemon
RUN tar xvf ./build/distributions/InferRules-1.0-SNAPSHOT.tar -C ./build/distributions

## Source build client
RUN curl -L -o elm.gz https://github.com/elm/compiler/releases/download/0.19.1/binary-for-linux-64-bit.gz
RUN gunzip elm.gz
RUN chmod +x elm
RUN sudo mv elm /usr/local/bin

COPY client /home/comby-infer/client
RUN sudo chown -R $(whoami) /home/comby-infer
WORKDIR /home/comby-infer/client
RUN sudo apt-get install -y npm
RUN sudo npm install uglify-js -g
RUN make release

## Source build server
COPY server /home/comby-infer/server
RUN sudo chown -R $(whoami) /home/comby-infer
WORKDIR /home/comby-infer/server
RUN sudo apt-get install -y pkg-config openssl libssl-dev
RUN opam exec -- opam install dune
RUN opam exec -- opam install . --deps-only 
RUN opam exec -- make release

EXPOSE 8080/tcp

###############################################
### Start the server                        ###
###############################################
ENTRYPOINT ["./_build/default/server.exe"]
