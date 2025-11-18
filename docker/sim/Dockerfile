FROM python:3.11-slim

WORKDIR /app

COPY sim_service.py /app/sim_service.py

RUN pip install --no-cache-dir flask prometheus_client

EXPOSE 8000

CMD ["python", "sim_service.py"]
