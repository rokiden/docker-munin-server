FROM alpine:3

RUN apk add --no-cache munin spawn-fcgi perl-cgi-fast ttf-dejavu tzdata
COPY munin.conf /etc/munin/

VOLUME /etc/munin/munin-conf.d/
VOLUME /usr/share/webapps/munin/html/
VOLUME /run/fcgi/

ENV TZ=UTC

COPY run.sh munin_cron.sh /      
RUN chmod +x /run.sh /munin_cron.sh
RUN echo "*/5 * * * * /munin_cron.sh" >> /etc/crontabs/root

CMD ["/run.sh"]
