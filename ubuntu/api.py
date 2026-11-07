from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from .core import AGENTS, Orchestrator, observe_system

engine = Orchestrator()

@asynccontextmanager
async def lifespan(app: FastAPI):
    yield

app = FastAPI(title="Ubuntu AI System", lifespan=lifespan)

class TaskRequest(BaseModel):
    agent: str
    type: str = "observe"

@app.get("/api/health")
async def health():
    return {"status": "ok", "agents": AGENTS, "runtime": "ubuntu-python"}

@app.get("/api/observe")
async def observe():
    return await observe_system()

@app.get("/api/tasks")
async def tasks():
    return list(engine.tasks.values())

@app.post("/api/tasks", status_code=202)
async def create_task(req: TaskRequest):
    try:
        return await engine.create(req.agent, req.type)
    except ValueError as exc:
        raise HTTPException(400, str(exc))
