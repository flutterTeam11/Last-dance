import asyncio
import json
import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.responses import JSONResponse

from config import WS_HOST, WS_PORT, SERVER_IP, TCP_PORT, ESP32_PORT, ESP32_BAUD
from receivers.tcp_receiver import TcpReceiver
from broadcast.ws_manager import ConnectionManager
from ai_integration.detector import Detector
from ai_integration.pipeline import Pipeline
from esp32_interface import Esp32Interface
from firebase_sync import LaptopFirebaseSync

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
esp32 = Esp32Interface(port=ESP32_PORT, baud=ESP32_BAUD)
fb_sync = LaptopFirebaseSync()


@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info(f"Server IP: {SERVER_IP}")
    logger.info(f"TCP port: {TCP_PORT}")
    logger.info(f"WS port: {WS_PORT}")

    await tcp_receiver.start()
    await pipeline.start()

    esp32.set_sensor_callback(_on_esp32_sensor)
    esp32.set_location_callback(_on_esp32_location)
    await esp32.connect()
    await esp32.start()

    fb_sync.start()

    asyncio.create_task(_broadcaster())
    yield
    await esp32.stop()
    await tcp_receiver.stop()
    await pipeline.stop()
    fb_sync.stop()


app = FastAPI(title="Phoenix Drone Server", lifespan=lifespan)


def _on_esp32_sensor(data: dict):
    fb_sync.update_sensors(data)


def _on_esp32_location(lat: float, lng: float):
    fb_sync.update_location(lat, lng)


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
        "esp32_connected": esp32.is_connected,
        "fb_sync_running": fb_sync.is_running,
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
    cmd_data = msg.get("data", {})

    if cmd_type == "move":
        logger.info(f"Move command: {cmd_data}")
        await esp32.send_command("move", cmd_data)

    elif cmd_type == "start_mission":
        logger.info("Mission started via Flutter")
        await esp32.send_command("start_mission")
        fb_sync.write_command("start_mission")
        fb_sync.add_report("mission_complete", "Mission started from Flutter app")

    elif cmd_type == "stop_mission":
        logger.info("Mission stopped")
        await esp32.send_command("stop_mission")
        fb_sync.write_command("stop_mission")

    elif cmd_type == "land":
        logger.info("Land command received")
        await esp32.send_command("land")

    elif cmd_type == "set_speed":
        logger.info(f"Set speed: {cmd_data}")
        await esp32.send_command("set_speed", cmd_data)

    else:
        logger.warning(f"Unknown command type: {cmd_type}")


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host=WS_HOST, port=WS_PORT)
