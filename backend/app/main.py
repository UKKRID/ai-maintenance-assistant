from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

from app.config import settings
from app.api import ai, auth, machine, repair, pm_task, spare_part, dashboard


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    print("Starting AI Maintenance Assistant API...")
    yield
    # Shutdown
    print("Shutting down...")


app = FastAPI(
    title="AI Maintenance Assistant API",
    description="API สำหรับวิเคราะห์อาการเสียเครื่องจักรด้วย AI",
    version="1.0.0",
    lifespan=lifespan
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Routes
app.include_router(auth.router, prefix="/api/auth", tags=["Authentication"])
app.include_router(ai.router, prefix="/api/ai", tags=["AI Analysis"])
app.include_router(machine.router, prefix="/api/machines", tags=["Machine Management"])
app.include_router(repair.router, prefix="/api/repairs", tags=["Repair Management"])
app.include_router(pm_task.router, prefix="/api/pm-tasks", tags=["PM Task Management"])
app.include_router(spare_part.router, prefix="/api/spare-parts", tags=["Spare Part Management"])
app.include_router(dashboard.router, prefix="/api/dashboard", tags=["Dashboard"])


@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "AI Maintenance Assistant"}


@app.get("/")
async def root():
    return {
        "message": "AI Maintenance Assistant API",
        "version": "1.0.0",
        "docs": "/docs"
    }
