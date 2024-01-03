from fastapi import FastAPI, Request
from starlette.templating import Jinja2Templates
from starlette.staticfiles import StaticFiles
from starlette.responses import HTMLResponse, FileResponse

app = FastAPI(docs_url=None, redoc_url=None, openapi_url=None)

templates = Jinja2Templates(directory="/app/templates")
app.mount("/static", StaticFiles(directory="/app/static"), name="static")

@app.get("/", response_class=HTMLResponse, include_in_schema=False)
async def get(request: Request):
    context = {"request": request}
    return templates.TemplateResponse("index.html", context)

# Serve the appcast.xml file
@app.get("/appcast.xml", response_class=FileResponse, include_in_schema=False)
async def get_appcast_xml():
    return FileResponse("/app/static/appcast.xml", media_type='application/xml')
