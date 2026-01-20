FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
default-mysql-client \
    && rm -rf /var/lib/apt/lists/*


COPY requirements.txt .

RUN python -m pip install --upgrade pip \
 && python -m pip install --no-cache-dir -r requirements.txt

ARG UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    appuser

COPY --chown=appuser:appuser . .

USER appuser


EXPOSE 5000


CMD ["gunicorn", "-w", "2", "-b", "0.0.0.0:5000", "--access-logfile", "-", "--error-logfile", "-", "EmpApp:app"]