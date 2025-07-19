FROM ubuntu:22.04 AS builder

COPY init.sh /init.sh
RUN chmod +x /init.sh

RUN /init.sh

FROM ubuntu:22.04

COPY --from=builder /etc/apt/sources.list /etc/apt/sources.list

CMD ["/bin/bash"]
