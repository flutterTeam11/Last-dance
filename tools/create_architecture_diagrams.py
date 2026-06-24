from pathlib import Path
import math
import textwrap

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "assets" / "diagrams"

W, H = 1920, 1080

COLORS = {
    "bg": (11, 17, 30),
    "panel": (22, 32, 50),
    "panel2": (28, 42, 64),
    "line": (83, 104, 132),
    "text": (239, 246, 255),
    "muted": (166, 180, 202),
    "cyan": (42, 196, 255),
    "blue": (72, 128, 255),
    "green": (78, 215, 137),
    "amber": (255, 194, 79),
    "red": (255, 91, 105),
    "purple": (170, 125, 255),
}


def font(size, bold=False):
    names = [
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
        if bold
        else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
        "/usr/share/fonts/truetype/liberation2/LiberationSans-Bold.ttf"
        if bold
        else "/usr/share/fonts/truetype/liberation2/LiberationSans-Regular.ttf",
    ]
    for name in names:
        path = Path(name)
        if path.exists():
            return ImageFont.truetype(str(path), size)
    return ImageFont.load_default()


F_TITLE = font(54, True)
F_SUB = font(25)
F_H = font(30, True)
F_BODY = font(23)
F_SMALL = font(19)
F_TINY = font(16)


def rounded(draw, box, fill, outline=None, width=2, radius=26):
    draw.rounded_rectangle(box, radius=radius, fill=fill, outline=outline, width=width)


def text_size(draw, text, fnt):
    box = draw.textbbox((0, 0), text, font=fnt)
    return box[2] - box[0], box[3] - box[1]


def center_text(draw, box, text, fnt, fill=COLORS["text"], spacing=8):
    x1, y1, x2, y2 = box
    lines = text.split("\n")
    heights = [text_size(draw, line, fnt)[1] for line in lines]
    total = sum(heights) + spacing * (len(lines) - 1)
    y = y1 + (y2 - y1 - total) / 2
    for line, h in zip(lines, heights):
        w, _ = text_size(draw, line, fnt)
        draw.text((x1 + (x2 - x1 - w) / 2, y), line, font=fnt, fill=fill)
        y += h + spacing


def wrap_lines(text, width):
    lines = []
    for part in text.split("\n"):
        lines.extend(textwrap.wrap(part, width=width) or [""])
    return lines


def box(draw, xy, title, body, accent, width=360, height=180):
    x, y = xy
    rounded(draw, (x, y, x + width, y + height), COLORS["panel"], (61, 78, 104), 2, 24)
    draw.rounded_rectangle((x, y, x + 10, y + height), radius=10, fill=accent)
    draw.text((x + 30, y + 24), title, font=F_H, fill=COLORS["text"])
    yy = y + 72
    for line in wrap_lines(body, 32):
        draw.text((x + 30, yy), line, font=F_SMALL, fill=COLORS["muted"])
        yy += 28
    return (x, y, x + width, y + height)


def pill(draw, xy, text, color):
    x, y = xy
    tw, th = text_size(draw, text, F_TINY)
    rounded(draw, (x, y, x + tw + 32, y + 34), color, None, 0, 17)
    draw.text((x + 16, y + 8), text, font=F_TINY, fill=(8, 14, 25))
    return (x, y, x + tw + 32, y + 34)


def arrow(draw, start, end, color=COLORS["cyan"], width=5, label=None, label_offset=(0, -38)):
    x1, y1 = start
    x2, y2 = end
    draw.line((x1, y1, x2, y2), fill=color, width=width)
    angle = math.atan2(y2 - y1, x2 - x1)
    head = 18
    pts = [
        (x2, y2),
        (x2 - head * math.cos(angle - math.pi / 6), y2 - head * math.sin(angle - math.pi / 6)),
        (x2 - head * math.cos(angle + math.pi / 6), y2 - head * math.sin(angle + math.pi / 6)),
    ]
    draw.polygon(pts, fill=color)
    if label:
        lx = (x1 + x2) / 2 + label_offset[0]
        ly = (y1 + y2) / 2 + label_offset[1]
        tw, th = text_size(draw, label, F_TINY)
        rounded(draw, (lx - 14, ly - 8, lx + tw + 14, ly + th + 12), (18, 27, 43), color, 1, 12)
        draw.text((lx, ly), label, font=F_TINY, fill=COLORS["text"])


def base(title, subtitle):
    img = Image.new("RGB", (W, H), COLORS["bg"])
    draw = ImageDraw.Draw(img)
    for y in range(H):
        blend = y / H
        r = int(COLORS["bg"][0] * (1 - blend) + 14 * blend)
        g = int(COLORS["bg"][1] * (1 - blend) + 24 * blend)
        b = int(COLORS["bg"][2] * (1 - blend) + 43 * blend)
        draw.line((0, y, W, y), fill=(r, g, b))
    draw.text((80, 58), title, font=F_TITLE, fill=COLORS["text"])
    draw.text((84, 132), subtitle, font=F_SUB, fill=COLORS["muted"])
    draw.rounded_rectangle((80, 178, 380, 188), radius=5, fill=COLORS["cyan"])
    return img, draw


def diagram_auth_flow():
    img, draw = base(
        "Splash, Onboarding and Auth Relationship",
        "Code path: GoRouter -> SplashScreen -> AuthCubit -> Onboarding/Auth -> Home",
    )
    b1 = box(draw, (110, 330), "Splash Screen", "Initial route /splash\nLogo animation\ncheckAuthStatus()", COLORS["cyan"])
    b2 = box(draw, (560, 240), "Auth Gate", "AuthCubit reads local flag\nthen FirebaseAuth currentUser\nand users/{uid}", COLORS["amber"], 420, 220)
    b3 = box(draw, (1100, 220), "Home", "AuthSuccess routes to /home\nDroneMainShell opens main app", COLORS["green"], 390, 180)
    b4 = box(draw, (560, 610), "Onboarding", "4-page PageView\nSkip or Start now\nroutes to /sign-in", COLORS["purple"], 420, 210)
    b5 = box(draw, (1110, 610), "Auth Screens", "Sign in, sign up, OTP\nGoogle sign-in\npassword reset", COLORS["red"], 400, 210)
    b6 = box(draw, (1540, 610), "Firebase Auth", "Email/password\nGoogle credential\nFirestore user doc", COLORS["amber"], 300, 210)

    arrow(draw, (b1[2], 420), (b2[0], 350), COLORS["cyan"], label="on app start", label_offset=(-70, -72))
    arrow(draw, (b2[2], 320), (b3[0], 310), COLORS["green"], label="logged in")
    arrow(draw, (770, b2[3]), (770, b4[1]), COLORS["purple"], label="not logged in", label_offset=(-55, -5))
    arrow(draw, (b4[2], 715), (b5[0], 715), COLORS["purple"], label="skip / start")
    arrow(draw, (b5[2], 715), (b6[0], 715), COLORS["amber"], label="credentials")
    arrow(draw, (1310, b5[1]), (1300, b3[3]), COLORS["green"], label="AuthSuccess", label_offset=(-120, -20))

    pill(draw, (112, 925), "Routes: /splash -> /onboarding -> /sign-in|/sign-up|/otp|/forgot-password -> /home", COLORS["cyan"])
    pill(draw, (112, 970), "Storage: LocalStorageService setLoggedIn(true) after successful auth", COLORS["green"])
    return img


def diagram_project_overview():
    img, draw = base(
        "Phoenix Project Overview",
        "AI-assisted drone search and rescue: live video, map tracking, telemetry and control",
    )

    mission = box(
        draw,
        (690, 385),
        "Search & Rescue Mission",
        "Rescue team monitors the drone\nfrom one mobile ground station\nwith live context and control",
        COLORS["red"],
        540,
        230,
    )
    pi = box(
        draw,
        (95, 280),
        "Raspberry Pi Drone",
        "Camera captures video\nSensors read environment\nGPIO drives motors\nFirebase sync runs onboard",
        COLORS["green"],
        420,
        300,
    )
    laptop = box(
        draw,
        (710, 700),
        "Laptop Server",
        "FastAPI middleware\nTCP video receiver\nOpenCV + AI detection\nWebSocket broadcaster",
        COLORS["cyan"],
        500,
        250,
    )
    firebase = box(
        draw,
        (1365, 285),
        "Firebase Cloud",
        "Auth for users\nFirestore location/status\nReports and commands\nRealtime snapshots",
        COLORS["amber"],
        430,
        300,
    )
    app = box(
        draw,
        (735, 230),
        "Flutter Mobile App",
        "Onboarding and Auth\nLive video + detections\nOpenStreetMap tracking\nJoystick and mission UI",
        COLORS["blue"],
        455,
        270,
    )

    arrow(draw, (pi[2], 415), (app[0], 365), COLORS["green"], label="field data", label_offset=(-35, -62))
    arrow(draw, (pi[2] - 15, pi[3]), (laptop[0] + 40, laptop[1]), COLORS["cyan"], label="TCP video", label_offset=(-95, 8))
    arrow(draw, (laptop[0] + 250, laptop[1]), (app[0] + 230, app[3]), COLORS["blue"], label="video + AI", label_offset=(-80, -48))
    arrow(draw, (pi[2], 500), (firebase[0], 430), COLORS["amber"], label="telemetry + location", label_offset=(-165, -56))
    arrow(draw, (firebase[0], 500), (pi[2], 545), COLORS["red"], label="mission commands", label_offset=(-150, 18))
    arrow(draw, (firebase[0] + 20, firebase[1]), (app[2] - 20, app[1] + 70), COLORS["amber"], label="auth + realtime data", label_offset=(-170, -20))
    arrow(draw, (app[0] + 210, app[3]), (mission[0] + 270, mission[1]), COLORS["blue"], label="operator view", label_offset=(-80, -35))
    arrow(draw, (mission[0] + 270, mission[3]), (laptop[0] + 250, laptop[1]), COLORS["red"], label="control decisions", label_offset=(-120, 6))

    pill(draw, (100, 930), "Intro line: Phoenix connects drone hardware, AI video processing, Firebase realtime data, and a Flutter control app.", COLORS["cyan"])
    pill(draw, (100, 975), "Outcome: faster awareness for rescue teams during field missions.", COLORS["green"])
    return img


def diagram_mapping_firebase():
    img, draw = base(
        "Mapping With Firebase and Mission Flow",
        "Code path: DroneRepositoryImpl streams Firestore docs into Cubits and map widgets",
    )
    firebase = box(draw, (760, 260), "Cloud Firestore", "drone/location\ndrone/status\ndrone/reports/entries\ndrone/commands", COLORS["amber"], 420, 300)
    pi = box(draw, (110, 270), "Raspberry Pi Sync", "firebase_sync.py\nwrites sensors/status\nwrites location every 10s\nreads commands", COLORS["green"], 430, 290)
    repo = box(draw, (1350, 230), "Flutter Repository", "watchDroneLocation()\nwatchDroneStatus()\nwatchDroneReports()\nsendCommand()", COLORS["cyan"], 430, 310)
    cubits = box(draw, (1120, 650), "Cubits", "DroneTrackingCubit keeps path\nDroneStatusCubit updates stats\nVideoFeedCubit controls mode", COLORS["purple"], 400, 210)
    mapv = box(draw, (540, 650), "Map UI", "FlutterMap + OSM tiles\nDrone marker\nUser marker\nPolyline path history", COLORS["blue"], 420, 230)
    mission = box(draw, (112, 650), "Mission Button", "StartMissionButton\nsends start_mission\ncommand to Firestore", COLORS["red"], 360, 210)

    arrow(draw, (pi[2], 360), (firebase[0], 360), COLORS["green"], label="status + location")
    arrow(draw, (firebase[2], 370), (repo[0], 370), COLORS["cyan"], label="snapshots")
    arrow(draw, (repo[0] + 180, repo[3]), (cubits[0] + 240, cubits[1]), COLORS["purple"], label="streams")
    arrow(draw, (cubits[0], 755), (mapv[2], 755), COLORS["blue"], label="lat/lng + path")
    arrow(draw, (mission[2], 755), (firebase[0], 500), COLORS["red"], label="commands")
    arrow(draw, (firebase[0], 455), (pi[2], 455), COLORS["amber"], label="poll command")

    pill(draw, (80, 930), "Map center defaults to Cairo when Firestore location doc is missing", COLORS["amber"])
    pill(draw, (80, 975), "Disconnect state is emitted if no location update arrives for 10 seconds", COLORS["red"])
    return img


def diagram_system_video():
    img, draw = base(
        "Raspberry Pi, Video, Laptop Server and Firebase",
        "Code path: camera_stream.py -> laptop_server TCP/FastAPI -> Flutter WebSockets + Firestore telemetry",
    )
    pi = box(draw, (80, 260), "Raspberry Pi 5", "Camera module\nDHT11, MQ-2, MQ-8\nMPU6050, IR sensors\nGPIO motors", COLORS["green"], 420, 310)
    tcp = box(draw, (610, 230), "Laptop FastAPI Server", "TCP receiver :9000\nOpenCV frame decode\nAI pipeline\nWS endpoints :8000", COLORS["cyan"], 460, 340)
    app = box(draw, (1320, 220), "Flutter Mobile App", "WsClient connects to\n/ws/video\n/ws/detections\n/ws/commands", COLORS["blue"], 430, 300)
    fb = box(draw, (620, 690), "Firebase", "status + telemetry\nlocation\nreports\ncommands", COLORS["amber"], 420, 240)
    control = box(draw, (1320, 690), "Control Paths", "Joystick sends move\nStart mission command\nPi executes GPIO steps", COLORS["red"], 430, 220)

    arrow(draw, (pi[2], 345), (tcp[0], 345), COLORS["cyan"], label="JPEG frames over TCP", label_offset=(-72, -58))
    arrow(draw, (tcp[2], 325), (app[0], 325), COLORS["blue"], label="video bytes")
    arrow(draw, (tcp[2], 455), (app[0], 455), COLORS["purple"], label="detections JSON")
    arrow(draw, (app[0] + 40, app[3]), (control[0] + 40, control[1]), COLORS["red"], label="joystick / mission UI", label_offset=(-150, 12))
    arrow(draw, (control[0], 805), (fb[2], 805), COLORS["red"], label="Firestore command", label_offset=(-135, -52))
    arrow(draw, (fb[0], 810), (pi[2] - 5, 520), COLORS["amber"], label="Pi reads command", label_offset=(-25, -58))
    arrow(draw, (pi[0] + 300, pi[3]), (fb[0], 730), COLORS["green"], label="sensor sync", label_offset=(-95, 18))
    arrow(draw, (fb[2] - 20, 715), (app[0] + 210, app[3]), COLORS["amber"], label="map/status streams", label_offset=(-95, -54))

    pill(draw, (80, 930), "Video is real-time via TCP -> WebSocket, separate from Firebase telemetry", COLORS["cyan"])
    pill(draw, (80, 975), "Firebase keeps map, status, reports, and mission commands synchronized", COLORS["amber"])
    return img


def main():
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    outputs = {
        "00_project_overview.png": diagram_project_overview(),
        "01_splash_onboarding_auth.png": diagram_auth_flow(),
        "02_mapping_firebase_flow.png": diagram_mapping_firebase(),
        "03_pi_video_laptop_firebase.png": diagram_system_video(),
    }
    for name, image in outputs.items():
        image.save(OUT_DIR / name)
        print(OUT_DIR / name)


if __name__ == "__main__":
    main()
