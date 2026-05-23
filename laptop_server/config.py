import socket
import multiprocessing

TCP_HOST = "0.0.0.0"
TCP_PORT = 9000

WS_HOST = "0.0.0.0"
WS_PORT = 8000

FRAME_WIDTH = 640
FRAME_HEIGHT = 480
JPEG_QUALITY = 75

FRAME_SKIP = 3

AI_MODEL_PATH = "models/yolov8n.pt"
THERMAL_ENABLED = False

MAX_CLIENTS = 10
BUFFER_SIZE = 65536

SERVER_IP = socket.gethostbyname(socket.gethostname())
CPU_COUNT = multiprocessing.cpu_count()
