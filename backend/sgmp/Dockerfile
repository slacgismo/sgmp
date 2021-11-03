FROM python:3.8-slim-buster AS builder

WORKDIR /tmp

RUN apt-get update && \
    apt-get install -y default-libmysqlclient-dev libpq-dev build-essential && \
    rm -rf /var/lib/apt/lists/*

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

ADD requirements.txt /tmp
RUN pip install -r requirements.txt
RUN pip install gunicorn

FROM python:3.8-slim-buster

RUN apt-get update && \
    apt-get install -y libpq5 default-libmysqlclient-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /opt/venv /opt/venv
COPY . /app

ENV WORKER=4
ENV PATH="/opt/venv/bin:$PATH"

EXPOSE 80

CMD ["sh", "-c", "gunicorn -w $WORKER -b 0.0.0.0:80 app:app"]
