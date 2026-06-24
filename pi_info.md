# Raspberry Pi 5 - معلومات

## النظام
- **OS:** Debian GNU/Linux 13 (trixie)
- **Hostname:** raspberrypi
- **IP (آخر ظهور):** 192.168.1.2
- **Laptop IP على WED63D3E:** 192.168.1.17/24
- **WiFi متصل بـ:** WED63D3E (باسورد: 123123**)

## المستخدم
- **Username:** beso
- **Password:** 123123**
- **Password hash:** `$y$j9T$LiW5lw9H8FrI7aW/CBwv5.$Muj0qya9ICVzwnd1HbCUb9PFGLTdZD4crim8NMWbAz8` (yescrypt)
- **UID/GID:** 1000:1000
- **Shell:** /bin/bash
- **SSH Key:** تم إضافة مفتاح `id_ed25519` للاب في `authorized_keys`
- **SSH:** مفعل (بقى مفعل بعد أول boot)

## شبكات WiFi محفوظة
| الشبكة | الباسورد | Priority |
|---|---|---|
| WED63D3E | 123123** | 10 (الأولوية العليا) |
| Pi-Project | 123123** | 1 (hotspot fallback) |
| Ahmed | 123321123 | - |
| Unknown | 031323ahmed | - |
| You don't have Internet | parkjimin | - |
| Elmenshawy | (مشفّر) | - |

## مشاريع على الـ Pi

### 1. ملفات بايثون في `/home/beso/`
| الملف | الحجم | الوظيفة |
|---|---|---|
| `project3.py` | 5492 bytes (416 lines) | تحكم في موتورين + حساسات (MQ-2, MQ-8, DHT11, MPU6050, IR) + **sound localization** باستخدام sounddevice — أحدث إصدار |
| `project2.py` | 3292 bytes (164 lines) | تحكم في موتورين + حساسات غاز (MQ-2, MQ-8) + DHT11 + MPU6050 + IR — بدون sound |
| `motor-gas.py` | 1707 bytes | نسخة أقدم من project2.py |
| `motor.py` | 219 bytes | اختبار موتور بسيط |
| `motorir2.py` | 1000 bytes | اختبار IR sensor |
| `motorsound-test.py` | 1861 bytes (94 lines) | روبوت تتبع الصوت (إصدار أقدم، موتور واحد فقط) |
| `servo.py` | 420 bytes (22 lines) | اختبار سيرفو على GPIO 12 (min/mid/max) |
| `proo.py` | 2479 bytes | نسخة تجريبية |
| `proo1.py` | 1904 bytes | نسخة تجريبية |
| `proo2.py` | 2166 bytes | نسخة تجريبية |
| `proo3.py` | 2108 bytes | نسخة تجريبية |
| `proo4.py` | 1972 bytes | نسخة تجريبية |
| `projecttest1.py` | 2308 bytes | نسخة اختبار |
| `projecttest1clean.py` | 2571 bytes | نسخة اختبار نظيفة |

### 2. مجلد `dht_project/`
| الملف | الوظيفة |
|---|---|
| `DHTT11.py` (873 bytes) | قراءة DHT11 وتشغيل LED عند تجاوز 30°C |
| `venv/` | بيئة Python virtual environment (فيه `adafruit_dht`, `adafruit_blinka`, `smbus2`) |

### 3. مجلد `env/`
بيئة Python أخرى — فيها `pip` فقط (فارغة تقريباً).

### 4. مجلد `myenv/`
بيئة Python — فيها `adafruit_dht`, `adafruit_blinka`, `smbus2` (تطابق dht_env).

### 5. مجلد `pigpio/`
مكتبة pigpio (مستنسخة من GitHub).

### 6. `dht_env/`
بيئة Python — فيها `adafruit_dht`, `adafruit_blinka`, `smbus2`.

## Python Packages (نظامية)
| الحزمة | الإصدار |
|---|---|
| `gpiozero` | 2.0.1 |
| `numpy` | 2.2.4 |
| `smbus2` | 0.4.3 |
| `smbus` | 1.1 |
| `spidev` | 3.6 |
| `sounddevice` | (مثبت ولكن ليس في dist-packages — اتثبت بـ pip) |

## الـ GPIO المستخدم
- **Stepper PUL:** GPIO 17
- **Stepper DIR:** GPIO 27
- **Stepper EN:** GPIO 22
- **Stepper2 PUL:** GPIO 23
- **Stepper2 DIR:** GPIO 24
- **Stepper2 EN:** GPIO 25
- **Servo:** GPIO 12 (جديد في servo.py)
- **IR Left:** GPIO 13
- **IR Right:** GPIO 12 (motor-gas.py كان 18, 19 — project2/3 يستخدم 13, 12)
- **I2C:** MPU6050 (عنوان 0x68)
- **SPI:** MQ-2 (channel 0), MQ-8 (channel 1)
- **DHT11:** GPIO 4

## الخدمات المفعلة
- **SSH:** `ssh.service` + `sshswitch.service` (مفعلة)
- **WayVNC:** `wayvnc.service` (مفعل — إعدادات: port مفتوح على ::, auth PAM + TLS)

## ملاحظات
- الـ Pi 5 منفذ USB-C للشحن فقط — مش بيدعم USB gadget mode
- تم ضبط WiFi مزدوج: WED63D3E (priority 10) > Pi-Project (priority 1)
- الباسورد الجديد للمستخدم beso: **123123** (تم تغييره)
- SSH key access شغال بدون باسورد
- Python version: 3.13
- الـ Pi 5 عنده زر nRPIBOOT لدخول وضع Flash Drive
- Pi 5 CPU: BCM2712 (Cortex-A76)

## Pi Server (`pi_server/`)

| الملف | الوظيفة |
|---|---|
| `main.py` | FastAPI server (REST + WebSocket للتحكم) |
| `hardware.py` | تهيئة الحساسات والـ GPIO (DHT11, MQ-2, MQ-8, MPU6050, IR, Motors) |
| `firebase_sync.py` | يكتب بيانات الحساسات في Firestore كل 5 ثواني + يقرا الأوامر |
| `service_account.json` | مفتاح Firebase Service Account للـ API |
| `control.py` | Laptop control script (WASD) |
| `install_firebase.sh` | Script لتثبيت firebase-admin على الـ Pi |

## Firebase Collections الـ Pi يكتب فيها

| Collection | Fields | تردد الكتابة |
|---|---|---|
| `drone/status` | `battery, humanCount, height, speed, isConnected, temperature` | كل 5 ثواني |
| `drone/location` | `lat, lng, timestamp` | كل 10 ثواني (placeholder د Cairo) |
| `drone/reports/entries` | `type, message, timestamp` | عند حدوث حدث |
| `drone/commands` | `command, data, timestamp` | يقرا الأوامر من Flutter |

## لسه فاضل
- تثبيت `firebase-admin` على الـ Pi لما يشتغل (`bash install_firebase.sh`)
- ربط Flutter بالـ Pi Server بدل الـ laptop server
