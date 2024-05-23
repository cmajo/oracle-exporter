
# Build is starting here
FROM docker.io/library/golang:1.22 AS build

WORKDIR /go/src/oracledb_exporter
COPY . .
RUN go get -d -v


ENV VERSION ${VERSION:-0.1.0}


ENV CGO_ENABLED ${CGO_ENABLED:-1}

RUN CGO_ENABLED=${CGO_ENABLED} GOOS=linux GOARCH=s390x go build -v -ldflags "-X main.Version=${VERSION} -s -w"

FROM ubuntu as exporter
LABEL org.opencontainers.image.authors="Seth Miller,Yannig Perré <yannig.perre@gmail.com>"
LABEL org.opencontainers.image.description="Oracle DB Exporter"

ENV VERSION ${VERSION:-0.1.0}
ENV DEBIAN_FRONTEND=noninteractive

ENV LEGACY_TABLESPACE=legacy_tablespace
COPY --from=build /go/src/oracledb_exporter/oracledb_exporter /oracledb_exporter
ADD ./default-metrics.${LEGACY_TABLESPACE}.toml /default-metrics.toml

ENV DATA_SOURCE_NAME system/oracle@oracle/xe

EXPOSE 9161

USER 1000

ENTRYPOINT ["/oracledb_exporter"]
