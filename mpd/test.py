from qrcode.main import QRCode, make
from qrcode.constants import *
from qrcode import image

qr = QRCode(border=1)
qr.add_data("http://192.168.23.7:8080/1")
im = qr.make_image()
im.save("qrcode.png")
