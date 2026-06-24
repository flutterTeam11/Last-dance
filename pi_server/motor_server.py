#!/usr/bin/env python3
"""
Minimal HTTP motor control server for Raspberry Pi.
Uses only Python stdlib + gpiozero (pre-installed on Raspberry Pi OS).

Endpoints:
  GET /start  - Start motors moving forward
  GET /stop   - Stop motors
  GET /status - Get motor running status

Usage:
  python motor_server.py
  # or specify port: MOTOR_SERVER_PORT=5000 python motor_server.py
"""

import http.server
import json
import os
import signal
import sys
import threading
import time

from gpiozero import OutputDevice

# Motor GPIO pins (BCM numbering)
PUL1 = OutputDevice(17)
DIR1 = OutputDevice(27)
EN1 = OutputDevice(22)
PUL2 = OutputDevice(23)
DIR2 = OutputDevice(24)
EN2 = OutputDevice(25)

# Enable motors (EN low = enabled for most drivers)
EN1.off()
EN2.off()

MOTORS_RUNNING = False
motor_thread = None


def step():
    PUL1.on()
    PUL2.on()
    time.sleep(0.001)
    PUL1.off()
    PUL2.off()
    time.sleep(0.001)


def motor_loop():
    global MOTORS_RUNNING
    DIR1.on()
    DIR2.off()
    while MOTORS_RUNNING:
        PUL1.on()
        PUL2.on()
        time.sleep(0.001)
        PUL1.off()
        PUL2.off()
        time.sleep(0.001)


def start_motors():
    global MOTORS_RUNNING, motor_thread
    if MOTORS_RUNNING:
        return False
    MOTORS_RUNNING = True
    motor_thread = threading.Thread(target=motor_loop, daemon=True)
    motor_thread.start()
    return True


def stop_motors():
    global MOTORS_RUNNING
    MOTORS_RUNNING = False
    PUL1.off()
    PUL2.off()
    return True


def cleanup():
    global MOTORS_RUNNING
    MOTORS_RUNNING = False
    PUL1.off()
    PUL2.off()
    EN1.on()
    EN2.on()


class MotorHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        try:
            if self.path == '/start':
                ok = start_motors()
                self._send_json({
                    'status': 'ok' if ok else 'already_running',
                    'motors_running': True,
                })
            elif self.path == '/stop':
                stop_motors()
                self._send_json({
                    'status': 'stopped',
                    'motors_running': False,
                })
            elif self.path == '/status':
                self._send_json({
                    'motors_running': MOTORS_RUNNING,
                })
            else:
                self.send_response(404)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps({'error': 'not found'}).encode())
        except Exception as e:
            self.send_response(500)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps({'error': str(e)}).encode())

    def _send_json(self, data):
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps(data).encode())

    def log_message(self, format, *args):
        print(f"[MotorServer] {args[0]} {args[1]} {args[2]}")


def main():
    port = int(os.environ.get('MOTOR_SERVER_PORT', '5000'))
    server = http.server.HTTPServer(('0.0.0.0', port), MotorHandler)
    print(f"[MotorServer] Listening on port {port}...")

    def shutdown(sig, frame):
        print("[MotorServer] Shutting down...")
        cleanup()
        server.shutdown()
        sys.exit(0)

    signal.signal(signal.SIGTERM, shutdown)
    signal.signal(signal.SIGINT, shutdown)

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        shutdown(None, None)


if __name__ == '__main__':
    main()
