FROM ubuntu:22.04 AS builder

COPY init.sh /init.sh
RUN chmod +x /init.sh

RUN /init.sh

FROM ubuntu:22.04

RUN apt-get update && apt-get install -y bash && rm -rf /var/lib/apt/lists/*


CMD ["/bin/bash"]
