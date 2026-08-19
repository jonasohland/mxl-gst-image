FROM jonasohland/mxl:3518992 AS builder

USER 0:0
RUN apt-get update && apt-get install -y \
	pkg-config \
	build-essential \ 
	libclang-dev \
	libgstreamer1.0-dev \
	libgstreamer-plugins-base1.0-dev

COPY mxl/rust mxl/rust
RUN chown -R mxl:mxl mxl/rust

USER mxl:mxl
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > install-rust.sh && \
	chmod +x install-rust.sh && \
	./install-rust.sh -y 

RUN cd mxl/rust && \
	/home/mxl/.cargo/bin/cargo build --release --features mxl-sys/mxl-not-built

FROM jonasohland/mxl:3518992

USER 0:0
RUN apt-get update && apt-get install -y \
	gstreamer1.0-tools \
	gstreamer1.0-plugins-base \
	gstreamer1.0-plugins-good \
	gstreamer1.0-plugins-bad \
	gstreamer1.0-plugins-ugly \
	dumb-init \
	&& rm -r /var/lib/apt/lists/*

COPY --from=builder /home/mxl/mxl/rust/target/release/libgstmxl.so /usr/lib/x86_64-linux-gnu/gstreamer-1.0/libgstmxl.so

USER mxl:mxl
ENTRYPOINT ["/usr/bin/dumb-init", "--", "/usr/bin/gst-launch-1.0"]
