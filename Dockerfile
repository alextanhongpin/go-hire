ARG POSTGRES_VERSION=latest
FROM postgres:$POSTGRES_VERSION

RUN apk update && apk upgrade && \
	apk add --no-cache bash git make perl perl-dev alpine-sdk postgresql-dev

# NOTE: Override PG_CONFIG location, since
# /usr/bin/pg_config does not work.
ENV PG_CONFIG=/usr/local/bin/pg_config

# Install pg_tap.
RUN git clone https://github.com/theory/pgtap \
	&& cd pgtap \
	&& make && make install

# Install pg_prove.
RUN cpan TAP::Parser::SourceHandler::pgTAP
