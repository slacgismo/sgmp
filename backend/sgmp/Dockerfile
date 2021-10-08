FROM python:3.8-slim-buster

WORKDIR /app

RUN apt-get update
RUN apt-get install -y default-libmysqlclient-dev libpq-dev build-essential

ADD requirements.txt /app
RUN pip install -r requirements.txt
RUN pip install gunicorn

ADD . /app

ENV WORKER=4

EXPOSE 80

CMD ["sh", "-c", "gunicorn -w $WORKER -b 0.0.0.0:80 app:app"]
