FROM wulan17/artixlinux:zen
COPY PKGBUILD /home/wulan17/
RUN chown -R wulan17 /home/wulan17