import os
import socket
import time

from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse, Response
from prometheus_client import CONTENT_TYPE_LATEST, Counter, Histogram, generate_latest

APP_VERSION = os.getenv("APP_VERSION", "dev")

app = FastAPI(title="Diploma demo app", version=APP_VERSION)

REQUESTS = Counter(
    "app_requests_total",
    "Total HTTP requests",
    ["method", "path", "status"],
)
LATENCY = Histogram(
    "app_request_duration_seconds",
    "HTTP request latency in seconds",
    ["method", "path"],
)


@app.middleware("http")
async def collect_metrics(request: Request, call_next):
    if request.url.path == "/metrics":
        return await call_next(request)

    started = time.perf_counter()
    response = await call_next(request)
    elapsed = time.perf_counter() - started

    path = request.url.path
    REQUESTS.labels(request.method, path, response.status_code).inc()
    LATENCY.labels(request.method, path).observe(elapsed)
    return response


@app.get("/", response_class=HTMLResponse)
async def index() -> str:
    return f"""<!doctype html>
<html lang="ru">
  <head><meta charset="utf-8"><title>Diploma demo app</title></head>
  <body style="font-family: sans-serif; margin: 3rem;">
    <h1>Дипломный проект: тестовое приложение</h1>
    <p>Версия: <b>{APP_VERSION}</b></p>
    <p>Под: <b>{socket.gethostname()}</b></p>
    <p><a href="/health">/health</a> &middot; <a href="/metrics">/metrics</a></p>
  </body>
</html>"""


@app.get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok", "version": APP_VERSION}


@app.get("/metrics")
async def metrics() -> Response:
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)
