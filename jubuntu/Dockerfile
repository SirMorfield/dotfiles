FROM ubuntu:22.04 AS builder

COPY init.sh /init.sh
RUN chmod +x /init.sh

# This is not great for layer caching but we also want to run the init script on a already running os
RUN /init.sh

CMD ["/bin/bash"]
