FROM rust:1.57-buster as build

# RUN apt-get update
# RUN apt-get install -y --no-install-recommends pkg-config libssl-dev musl-tools

RUN USER=root cargo new --bin app
WORKDIR /app

COPY ./Cargo.toml ./Cargo.toml
COPY ./Cargo.lock ./Cargo.lock

RUN cargo build --release 
RUN rm src/*.rs

COPY ./src ./src

RUN rm ./target/release/deps/backend*
RUN cargo build --release

FROM rust:1.57-slim-buster

COPY --from=build /app/target/release/backend .

ENV ROCKET_ADDRESS=0.0.0.0
EXPOSE 8000

CMD ["./backend"]
