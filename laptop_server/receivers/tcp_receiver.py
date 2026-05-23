import asyncio
import struct
import logging
import numpy as np
import cv2

from config import TCP_HOST, TCP_PORT, BUFFER_SIZE

logger = logging.getLogger(__name__)

class TcpReceiver:
    def __init__(self, frame_queue: asyncio.Queue):
        self.frame_queue = frame_queue
        self._server = None
        self._running = False

    async def start(self):
        self._running = True
        self._server = await asyncio.start_server(
            self._handle_client, TCP_HOST, TCP_PORT
        )
        logger.info(f"TCP receiver listening on {TCP_HOST}:{TCP_PORT}")

    async def stop(self):
        self._running = False
        if self._server:
            self._server.close()
            await self._server.wait_closed()

    async def _handle_client(self, reader, writer):
        addr = writer.get_extra_info("peername")
        logger.info(f"Pi connected: {addr}")
        buffer = bytearray()

        try:
            while self._running:
                chunk = await reader.read(BUFFER_SIZE)
                if not chunk:
                    break
                buffer.extend(chunk)

                while len(buffer) >= 4:
                    frame_size = struct.unpack("!I", buffer[:4])[0]
                    if frame_size > 1_000_000:
                        buffer = buffer[4:]
                        continue
                    if len(buffer) < 4 + frame_size:
                        break

                    jpeg_bytes = bytes(buffer[4 : 4 + frame_size])
                    buffer = buffer[4 + frame_size :]

                    frame = cv2.imdecode(
                        np.frombuffer(jpeg_bytes, dtype=np.uint8),
                        cv2.IMREAD_COLOR,
                    )
                    if frame is not None:
                        await self.frame_queue.put(frame)
        except asyncio.CancelledError:
            pass
        except Exception as e:
            logger.error(f"TCP client error: {e}")
        finally:
            writer.close()
            await writer.wait_closed()
            logger.info(f"Pi disconnected: {addr}")
