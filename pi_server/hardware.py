import logging
import random
import time
from types import SimpleNamespace

logger = logging.getLogger("pi-hardware")

_hw_ok = False

# GPIO pin objects
PUL1 = None
PUL2 = None
DIR1 = None
DIR2 = None


class _GpioPin:
    def __init__(self, pin_num, name=""):
        self.pin = pin_num
        self.name = name
        self._state = False

    def on(self):
        self._state = True
        if _hw_ok:
            import RPi.GPIO as GPIO
            GPIO.output(self.pin, GPIO.HIGH)

    def off(self):
        self._state = False
        if _hw_ok:
            import RPi.GPIO as GPIO
            GPIO.output(self.pin, GPIO.LOW)

    def __repr__(self):
        return f"<GPIO {self.pin} ({self.name})={'ON' if self._state else 'OFF'}>"


def _setup_rpi_gpio():
    global _hw_ok
    try:
        import RPi.GPIO as GPIO
        GPIO.setmode(GPIO.BCM)
        GPIO.setwarnings(False)
        pins = {
            "PUL1": 17, "DIR1": 27, "EN1": 22,
            "PUL2": 23, "DIR2": 24, "EN2": 25,
        }
        for name, pin in pins.items():
            GPIO.setup(pin, GPIO.OUT)
            GPIO.output(pin, GPIO.LOW)
        _hw_ok = True
        logger.info("RPi.GPIO initialized successfully")
        return True
    except (ImportError, RuntimeError):
        logger.info("RPi.GPIO not available (not on a Pi)")
        return False


def get_sensors():
    if _hw_ok:
        return _read_real_sensors()
    return _read_simulated_sensors()


def set_motor_direction(direction):
    if None in (DIR1, DIR2):
        return False
    if direction == "forward":
        DIR1.on()
        DIR2.off()
    elif direction == "backward":
        DIR1.off()
        DIR2.on()
    elif direction == "left":
        DIR1.off()
        DIR2.on()
    elif direction == "right":
        DIR1.on()
        DIR2.on()
    else:
        return False
    return True


def step_motors(count=1, delay=0.002):
    if None in (PUL1, PUL2):
        return False
    for _ in range(max(0, int(count))):
        PUL1.on()
        PUL2.on()
        time.sleep(delay)
        PUL1.off()
        PUL2.off()
        time.sleep(delay)
    return True


def stop_motors():
    if PUL1:
        PUL1.off()
    if PUL2:
        PUL2.off()


def run_start_mission(steps=600, delay=0.002):
    if not set_motor_direction("forward"):
        return False
    return step_motors(steps, delay)


def _read_real_sensors():
    import RPi.GPIO as GPIO
    GPIO.setmode(GPIO.BCM)
    sensors = {"temperature": 0, "humidity": 0, "mq2": 0, "mq8": 0, "ir_left": 0, "ir_right": 0}
    try:
        import adafruit_dht
        dht = adafruit_dht.DHT11(4)
        sensors["temperature"] = dht.temperature
        sensors["humidity"] = dht.humidity
        dht.exit()
    except Exception:
        sensors["temperature"] = 25
        sensors["humidity"] = 60
    return sensors


def _read_simulated_sensors():
    return {
        "temperature": round(random.uniform(22, 35), 1),
        "humidity": round(random.uniform(40, 80), 1),
        "mq2": random.randint(100, 500),
        "mq8": random.randint(50, 300),
        "ir_left": random.choice([0, 1]),
        "ir_right": random.choice([0, 1]),
    }


def cleanup():
    global PUL1, PUL2, DIR1, DIR2
    if _hw_ok:
        try:
            import RPi.GPIO as GPIO
            GPIO.cleanup()
        except Exception:
            pass
    PUL1 = PUL2 = DIR1 = DIR2 = None
    logger.info("Hardware cleaned up")


_setup_rpi_gpio()

PUL1 = _GpioPin(17, "PUL1")
PUL2 = _GpioPin(23, "PUL2")
DIR1 = _GpioPin(27, "DIR1")
DIR2 = _GpioPin(24, "DIR2")
