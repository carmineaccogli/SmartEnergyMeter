FROM python:3.11-alpine3.16

COPY requirements.txt .

RUN python3 -m pip install -r requirements.txt --no-cache-dir

COPY . .

EXPOSE 80

ENV FLASK_APP=hvac.py
CMD ["flask", "run", "--host=0.0.0.0", "--port=80"]