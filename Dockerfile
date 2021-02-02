FROM alpine:3.13

# Add run dependencies in its own layer
RUN apk add --no-cache --virtual .run-deps python3 lzo curl pv postgresql-client go

ENV GOROOT /usr/lib/go
ENV GOPATH /go
ENV PATH $GOPATH/bin:$PATH

COPY requirements.txt /
RUN mkdir -p $GOPATH/src $GOPATH/bin && apk add --no-cache --virtual .build-deps make musl-dev git libffi-dev openssl-dev build-base gcc libc-dev lzo-dev python3-dev py-pip bash cmake && \
    python3 -m pip install --no-cache-dir -r requirements.txt && \
    go get github.com/wal-g/wal-g | true &&\
    cd $GOPATH/src/github.com/wal-g/wal-g && \
    make install && \
    CGO_ENABLED=0 make deps && \
    make pg_build && \
    mv $GOPATH/src/github.com/wal-g/wal-g/main/pg/wal-g /usr/local/bin/ &&\
    apk del .build-deps

COPY src/wale-rest.py .
COPY run.sh /

CMD [ "/run.sh" ]
