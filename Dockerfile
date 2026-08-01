# CORRECCIÓN CONTENEDOR: Imagen base moderna y actualizada
FROM python:3.11-slim
WORKDIR /app
# Crear usuario no privilegiado
RUN useradd -m appuser
COPY app/ /app/
RUN pip install --no-cache-dir -r requirements.txt
# Cambiar a usuario no-root
USER appuser
EXPOSE 8080
# CORRECCIÓN CHECKOV: Healthcheck del contenedor
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8080/buscar')" || exit 1
CMD ["python", "app.py"]
