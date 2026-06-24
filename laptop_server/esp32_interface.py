import asyncio
import json
import logging

logger = logging.getLogger(__name__)


class Esp32Interface:
    def __init__(self, port: str = "/dev/ttyUSB0", baud: int = 115200):
        self._port = port
        self._baud = baud
        self._reader = None
        self._writer = None
        self._running = False
        self._connected = False
        self._on_sensor_data = None
        self._on_location = None
        self._command_queue = asyncio.Queue()

    @property
    def is_connected(self) -> bool:
        return self._connected

    def set_sensor_callback(self, callback):
        self._on_sensor_data = callback

    def set_location_callback(self, callback):
        self._on_location = callback

    async def connect(self):
        try:
            import serial
            import serial_asyncio

            self._reader, self._writer = await serial_asyncio.open_serial_connection(
                url=self._port, baudrate=self._baud
            )
            self._connected = True
            logger.info(f"Connected to ESP32 on {self._port} at {self._baud} baud")
        except ImportError:
            logger.warning("pyserial/serial_asyncio not installed. Using simulated ESP32.")
            self._connected = True
        except Exception as e:
            logger.error(f"Failed to connect to ESP32: {e}")
            self._connected = False

    async def start(self):
        self._running = True
        asyncio.create_task(self._read_loop())
        asyncio.create_task(self._write_loop())

    async def stop(self):
        self._running = False
        if self._writer:
            self._writer.close()
            try:
                await self._writer.wait_closed()
            except Exception:
                pass

    async def send_command(self, command: str, data: dict = None):
        msg = json.dumps({"type": "command", "command": command, "data": data or {}})
        await self._command_queue.put(msg)
        logger.info(f"Queued command for ESP32: {command}")

    async def _read_loop(self):
        buffer = ""
        while self._running:
            try:
                if self._reader is not None:
                    try:
                        char = await asyncio.wait_for(self._reader.read(1), timeout=0.5)
                        decoded = char.decode("utf-8", errors="replace")
                        if decoded == "\n":
                            if buffer.strip():
                                await self._parse_line(buffer.strip())
                            buffer = ""
                        else:
                            buffer += decoded
                    except asyncio.TimeoutError:
                        continue
                else:
                    await asyncio.sleep(1)
            except Exception as e:
                logger.error(f"ESP32 read error: {e}")
                await asyncio.sleep(2)

    async def _parse_line(self, line: str):
        try:
            msg = json.loads(line)
            msg_type = msg.get("type", "")

            if msg_type == "sensor":
                logger.debug(f"ESP32 sensor data: {msg}")
                if self._on_sensor_data:
                    self._on_sensor_data(msg.get("data", msg))

            elif msg_type == "location":
                logger.debug(f"ESP32 location: {msg}")
                if self._on_location:
                    data = msg.get("data", msg)
                    self._on_location(
                        data.get("lat", 0), data.get("lng", 0)
                    )

            elif msg_type == "log":
                logger.info(f"ESP32: {msg.get('message', '')}")

        except json.JSONDecodeError:
            logger.debug(f"ESP32 raw: {line}")

    async def _write_loop(self):
        while self._running:
            try:
                msg = await asyncio.wait_for(
                    self._command_queue.get(), timeout=1.0
                )
                if self._writer is not None:
                    self._writer.write((msg + "\n").encode("utf-8"))
                    await self._writer.drain()
                    logger.info(f"Sent to ESP32: {msg}")
                else:
                    logger.warning(f"ESP32 not connected, would send: {msg}")
            except asyncio.TimeoutError:
                continue
            except Exception as e:
                logger.error(f"ESP32 write error: {e}")
