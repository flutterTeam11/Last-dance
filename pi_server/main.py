import asyncio
import json
import logging
import time
from contextlib import asynccontextmanager

from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.responses import JSONResponse

import hardware
from firebase_sync import FirebaseSync

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
)
logger = logging.getLogger("pi-server")

running = False
direction = "forward"
current_speed = 0.001
fb_sync = None


def step(speed=None):
    if hardware.PUL1 is None or hardware.PUL2 is None:
        return
    s = speed or current_speed
    hardware.PUL1.on()
    hardware.PUL2.on()
    time.sleep(s)
    hardware.PUL1.off()
    hardware.PUL2.off()
    time.sleep(s)


@asynccontextmanager
async def lifespan(app: FastAPI):
    global fb_sync
    logger.info("Pi Drone Server started")
    fb_sync = FirebaseSync()
    fb_sync.start()
    yield
    if fb_sync:
        fb_sync.stop()
    hardware.cleanup()
    logger.info("Pi Drone Server stopped")


app = FastAPI(title="Phoenix Pi Drone", lifespan=lifespan)


@app.get("/health")
async def health():
    return JSONResponse({
        "status": "ok",
        "running": running,
        "hw_ok": hardware._hw_ok,
        "fb_sync": fb_sync.is_running if fb_sync else False,
    })


@app.get("/sensors")
async def sensors():
    return JSONResponse(hardware.get_sensors())


@app.post("/move/{direction}")
async def move(direction: str):
    if hardware.PUL1 is None:
        return JSONResponse({"error": "GPIO not initialized"}, status_code=503)
    if direction == "forward":
        hardware.DIR1.on(); hardware.DIR2.off()
    elif direction == "backward":
        hardware.DIR1.off(); hardware.DIR2.on()
    elif direction == "left":
        hardware.DIR1.off(); hardware.DIR2.on()
        for _ in range(80):
            step(0.002)
        hardware.DIR1.on(); hardware.DIR2.off()
    elif direction == "right":
        hardware.DIR1.on(); hardware.DIR2.on()
        for _ in range(80):
            step(0.002)
        hardware.DIR1.on(); hardware.DIR2.off()
    elif direction == "stop":
        hardware.PUL1.off(); hardware.PUL2.off()
    else:
        return JSONResponse({"error": "unknown direction"}, status_code=400)
    return JSONResponse({"status": "ok", "direction": direction})


@app.post("/steps/{count}")
async def steps(count: int):
    if hardware.PUL1 is None:
        return JSONResponse({"error": "GPIO not initialized"}, status_code=503)
    for _ in range(count):
        step()
    return JSONResponse({"status": "ok", "steps": count})


@app.websocket("/ws/control")
async def control_endpoint(ws: WebSocket):
    await ws.accept()
    logger.info("Client connected")
    try:
        while True:
            data = await ws.receive_text()
            msg = json.loads(data)
            cmd = msg.get("command")
            if cmd == "sensors":
                await ws.send_json(hardware.get_sensors())
            elif cmd == "move":
                if hardware.PUL1 is None:
                    await ws.send_json({"error": "GPIO not initialized"})
                    continue
                dir = msg.get("direction", "forward")
                if dir == "forward":
                    hardware.DIR1.on(); hardware.DIR2.off()
                elif dir == "backward":
                    hardware.DIR1.off(); hardware.DIR2.on()
                elif dir == "left":
                    hardware.DIR1.off(); hardware.DIR2.on()
                    for _ in range(80):
                        step(0.002)
                    hardware.DIR1.on(); hardware.DIR2.off()
                elif dir == "right":
                    hardware.DIR1.on(); hardware.DIR2.on()
                    for _ in range(80):
                        step(0.002)
                    hardware.DIR1.on(); hardware.DIR2.off()
                elif dir == "stop":
                    hardware.PUL1.off(); hardware.PUL2.off()
                await ws.send_json({"status": "ok", "command": cmd, "direction": dir})
            elif cmd == "step":
                if hardware.PUL1 is None:
                    await ws.send_json({"error": "GPIO not initialized"})
                    continue
                count = msg.get("count", 1)
                for _ in range(count):
                    step()
                await ws.send_json({"status": "ok", "steps": count})
            else:
                await ws.send_json({"error": f"unknown command: {cmd}"})
    except WebSocketDisconnect:
        logger.info("Client disconnected")
    except Exception as e:
        logger.error(f"Error: {e}")




@app.websocket("/ws/commands")
async def commands_endpoint(ws: WebSocket):
    await ws.accept()
    logger.info("Commands client connected")
    try:
        while True:
            data = await ws.receive_text()
            msg = json.loads(data)
            cmd_type = msg.get("type")
            cmd_data = msg.get("data", {})
            logger.info(f"Command: {cmd_type} {cmd_data}")

            if cmd_type == "move":
                if hardware.PUL1 is None:
                    await ws.send_json({"error": "GPIO not initialized"})
                    continue
                x = float(cmd_data.get("x", 0))
                y = float(cmd_data.get("y", 0))
                if abs(y) > abs(x):
                    if y > 0:
                        hardware.DIR1.on(); hardware.DIR2.off()
                    else:
                        hardware.DIR1.off(); hardware.DIR2.on()
                elif abs(x) > abs(y):
                    if x > 0:
                        hardware.DIR1.on(); hardware.DIR2.on()
                    else:
                        hardware.DIR1.off(); hardware.DIR2.off()
                    for _ in range(80):
                        step(0.002)
                else:
                    hardware.PUL1.off(); hardware.PUL2.off()
                await ws.send_json({"status": "ok", "command": cmd_type})
            elif cmd_type == "start_mission":
                ok = await asyncio.to_thread(hardware.run_start_mission)
                if fb_sync:
                    import firebase_sync
                    firebase_sync._add_report(
                        "mission_complete",
                        "Mission started via Flutter" if ok else "Mission start failed",
                    )
                status = "ok" if ok else "error"
                await ws.send_json({"status": status, "command": cmd_type})
            else:
                await ws.send_json({"error": f"unknown command: {cmd_type}"})
    except WebSocketDisconnect:
        logger.info("Commands client disconnected")
    except Exception as e:
        logger.error(f"Commands error: {e}")


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
