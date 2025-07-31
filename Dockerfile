FROM python:3.9-slim-buster AS builder

WORKDIR /app
COPY requirements.txt .

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      gcc pkg-config default-libmysqlclient-dev \
  && pip install --no-cache-dir mysqlclient \
  && pip install --no-cache-dir -r requirements.txt \
  && apt-get purge -y --auto-remove gcc pkg-config \
  && rm -rf /var/lib/apt/lists/*

FROM python:3.9-slim-buster AS runtime
WORKDIR /app

COPY --from=builder /usr/local/lib/python*/site-packages /usr/local/lib/python*/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin
COPY . /app

EXPOSE 8000
CMD ["gunicorn", "backend.wsgi:application", "--bind", ":8000"]




#RUN python manage.py migrate
#RUN python manage.py makemigrations
