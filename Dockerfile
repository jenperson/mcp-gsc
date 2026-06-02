FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim
WORKDIR /app

# Copy dependency files first for layer caching — deps only reinstall when these change
COPY pyproject.toml README.md ./
RUN uv sync --no-cache --no-install-project

# Copy application code
COPY gsc_server.py .

# Use SSE transport and bind to all interfaces so traffic can reach the container.
# MCP_API_KEY must be injected at runtime (e.g. via -e or a secrets manager).
# For Google auth, mount a service account key and set GSC_CREDENTIALS_PATH,
# or mount client_secrets.json and token.json for OAuth.
ENV MCP_TRANSPORT=sse
ENV MCP_HOST=0.0.0.0
ENV MCP_PORT=8000

EXPOSE 8000

CMD ["uv", "run", "--no-sync", "python", "gsc_server.py"]
