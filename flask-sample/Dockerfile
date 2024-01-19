FROM python:3.13.0a3-alpine

WORKDIR /usr/src/app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py ./

ENV PYTHONUNBUFFERED 1
CMD [ "python", "./app.py" ]
