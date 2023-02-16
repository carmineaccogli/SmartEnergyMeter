FROM python:3.11-alpine3.16

COPY requirements.txt .

RUN python3 -m pip install -r requirements.txt --no-cache-dir

COPY . .

EXPOSE 5001

ENV FLASK_APP=sensors.py
CMD ["flask", "run", "--host=0.0.0.0", "--port=5001"]