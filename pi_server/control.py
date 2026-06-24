import asyncio
import json
import sys
import termios
import tty
import signal

import websockets

PI_WS = "ws://192.168.1.2:8000/ws/control"


def get_key():
    fd = sys.stdin.fileno()
    old = termios.tcgetattr(fd)
    try:
        tty.setraw(fd)
        return sys.stdin.read(1)
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old)


async def print_sensors(ws):
    await ws.send(json.dumps({"command": "sensors"}))
    resp = await ws.recv()
    data = json.loads(resp)
    print(f"\rTemp: {data.get('temperature', 'N/A')}°C  "
          f"Hum: {data.get('humidity', 'N/A')}%  "
          f"MQ2: {data.get('mq2', 'N/A')}  "
          f"MQ8: {data.get('mq8', 'N/A')}  "
          f"IR-L:{data.get('ir_left', 'N/A')} IR-R:{data.get('ir_right', 'N/A')}  ", end="")


async def main():
    print("Connecting to Pi server...")
    async with websockets.connect(PI_WS) as ws:
        print("Connected! Controls:")
        print("  W=Forward  S=Backward  A=Left  D=Right  Space=Stop")
        print("  T=Sensors  Q=Quit")
        await print_sensors(ws)
        while True:
            key = get_key().lower()
            cmd = None
            if key == "w":
                cmd = {"command": "move", "direction": "forward"}
            elif key == "s":
                cmd = {"command": "move", "direction": "backward"}
            elif key == "a":
                cmd = {"command": "move", "direction": "left"}
            elif key == "d":
                cmd = {"command": "move", "direction": "right"}
            elif key == " ":
                cmd = {"command": "move", "direction": "stop"}
            elif key == "t":
                await print_sensors(ws)
                continue
            elif key == "q":
                break
            if cmd:
                await ws.send(json.dumps(cmd))
                resp = await ws.recv()
    print("\nDisconnected")


if __name__ == "__main__":
    signal.signal(signal.SIGINT, signal.SIG_DFL)
    asyncio.run(main())
