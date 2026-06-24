import cv2
import socket
import struct
import time
import logging

# إعدادات الاتصال بالسيرفر (اللاب توب)
# يجب تغيير هذا الـ IP إلى الـ IP الخاص باللاب توب على نفس شبكة الواي فاي
SERVER_IP = "192.168.1.17" # الـ IP الفعلي للاب توب
SERVER_PORT = 9000 # البورت الخاص بـ tcp_receiver

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger("camera_stream")

def start_streaming():
    camera = cv2.VideoCapture(0) # 0 يعني الكاميرا الافتراضية الموصلة بالـ Pi
    
    # تصغير حجم الفيديو لتقليل الضغط على الواي فاي وتحسين سرعة النقل
    camera.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
    camera.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)
    
    if not camera.isOpened():
        logger.error("لم يتم العثور على كاميرا!")
        return

    while True:
        try:
            # محاولة الاتصال باللاب توب
            client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            logger.info(f"جاري الاتصال بسيرفر اللاب توب {SERVER_IP}:{SERVER_PORT}...")
            client_socket.connect((SERVER_IP, SERVER_PORT))
            logger.info("تم الاتصال بنجاح! جاري إرسال الفيديو...")

            while True:
                ret, frame = camera.read()
                if not ret:
                    logger.error("فشل في قراءة الإطار من الكاميرا")
                    break

                # ضغط الصورة إلى JPEG
                encode_param = [int(cv2.IMWRITE_JPEG_QUALITY), 70]
                result, encoded_frame = cv2.imencode('.jpg', frame, encode_param)
                
                if not result:
                    continue

                # تحويل الصورة إلى Bytes
                data = encoded_frame.tobytes()
                
                # إرسال حجم الصورة أولاً (4 bytes) ثم الصورة نفسها
                # وهذا يتطابق تماماً مع ما يتوقعه ملف tcp_receiver.py في اللاب توب
                message = struct.pack("!I", len(data)) + data
                client_socket.sendall(message)
                
                # تأخير بسيط جداً لتخفيف الضغط
                time.sleep(0.03)

        except ConnectionRefusedError:
            logger.warning("فشل الاتصال باللاب توب. هل سيرفر اللاب توب يعمل؟ سأحاول مجدداً بعد 3 ثوانٍ...")
            time.sleep(3)
        except Exception as e:
            logger.error(f"حدث خطأ أثناء الإرسال: {e}")
            time.sleep(3)
        finally:
            try:
                client_socket.close()
            except:
                pass

if __name__ == "__main__":
    start_streaming()
