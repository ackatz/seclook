FROM python:slim

COPY . /app

RUN addgroup --system app && adduser --system --group app

ENV PATH="/home/app/.local/bin:${PATH}"
ENV PYTHONPATH="/app"
ENV PYTHONUNBUFFERED=1

RUN pip install --upgrade --no-cache-dir -r /app/requirements/app.txt
RUN chmod +x /app/run.sh && chown -R app:app /app

EXPOSE 8080

USER app

CMD [ "/app/run.sh" ]