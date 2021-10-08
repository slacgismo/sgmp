FROM python:3.8-slim-buster

WORKDIR /app

ADD . /app

RUN pip install -r requirements.txt
RUN pip install gunicorn

ENV WORKER=4

EXPOSE 80

CMD ["sh", "-c", "gunicorn -w $WORKER -b 0.0.0.0:80 main:app"]