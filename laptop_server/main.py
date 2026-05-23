import asyncio
import json
import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.responses import JSONResponse

from config import WS_HOST, WS_PORT, SERVER_IP, TCP_PORT
from receivers.tcp_receiver import TcpReceiver
from broadcast.ws_manager import ConnectionManager
from ai_integration.detector import Detector
from ai_integration.pipeline import Pipeline

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
)
logger = logging.getLogger(__name__)

frame_queue: asyncio.Queue = asyncio.Queue(maxsize=60)
manager = ConnectionManager()
detector = Detector()
pipeline = Pipeline(frame_queue, detector)
tcp_receiver = TcpReceiver(frame_queue)


@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info(f"Server IP: {SERVER_IP}")
    logger.info(f"TCP port: {TCP_PORT}")
    logger.info(f"WS port: {WS_PORT}")
    await tcp_receiver.start()
    await pipeline.start()
    asyncio.create_task(_broadcaster())
    yield
    await tcp_receiver.stop()
    await pipeline.stop()


app = FastAPI(title="Phoenix Drone Server", lifespan=lifespan)


async def _broadcaster():
    while True:
        jpeg_bytes, data_json = await pipeline.get_output()
        tasks = []
        if manager.video_client_count > 0:
            tasks.append(manager.broadcast_video(jpeg_bytes))
        if manager.detection_client_count > 0:
            tasks.append(manager.broadcast_detections(data_json))
        if tasks:
            await asyncio.gather(*tasks)


@app.get("/health")
async def health():
    return JSONResponse({
        "status": "ok",
        "server_ip": SERVER_IP,
        "tcp_port": TCP_PORT,
        "ws_port": WS_PORT,
        "video_clients": manager.video_client_count,
        "detection_clients": manager.detection_client_count,
        "pipeline_queue": pipeline.output_queue_size(),
    })


@app.websocket("/ws/video")
async def video_endpoint(ws: WebSocket):
    await manager.connect_video(ws)
    try:
        while True:
            await ws.receive_text()
    except WebSocketDisconnect:
        await manager.disconnect(ws)


@app.websocket("/ws/detections")
async def detections_endpoint(ws: WebSocket):
    await manager.connect_detection(ws)
    try:
        while True:
            await ws.receive_text()
    except WebSocketDisconnect:
        await manager.disconnect(ws)


@app.websocket("/ws/commands")
async def commands_endpoint(ws: WebSocket):
    await manager.connect_command(ws)
    try:
        while True:
            data = await ws.receive_text()
            try:
                msg = json.loads(data)
                logger.info(f"Command received: {msg}")
                await _handle_command(msg)
            except json.JSONDecodeError:
                logger.warning(f"Invalid command JSON: {data}")
    except WebSocketDisconnect:
        await manager.disconnect(ws)


async def _handle_command(msg: dict):
    cmd_type = msg.get("type")
    if cmd_type == "move":
        logger.debug(f"Move command: {msg.get('data')}")
    elif cmd_type == "start_mission":
        logger.info("Mission started")
    elif cmd_type == "stop_mission":
        logger.info("Mission stopped")
    elif cmd_type == "land":
        logger.info("Land command received")


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host=WS_HOST, port=WS_PORT)
