FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim
WORKDIR /app

# Copy dependency files first for layer caching — deps only reinstall when these change
COPY pyproject.toml README.md ./
RUN uv sync --no-cache --no-install-project

# Copy application code
COPY gsc_server.py .

# Use streamable-http transport — exposes /mcp endpoint expected by Mistral Connectors
# and other MCP clients. Bind to all interfaces so traffic can reach the container.
# MCP_API_KEY must be injected at runtime (e.g. via -e or a secrets manager).
# For Google auth, set GSC_CREDENTIALS_JSON to your service account JSON content.
ENV MCP_TRANSPORT=streamable-http
ENV MCP_HOST=0.0.0.0
ENV MCP_PORT=8000

EXPOSE 8000

CMD ["uv", "run", "--no-sync", "python", "gsc_server.py"]
